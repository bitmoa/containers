#!/usr/bin/env bash
#
# Re-run the "Trigger chart bump & verification" job of every CD run created
# since a given date (default: 2026-07-30).
#
# Only that single job is re-run -- never the whole workflow -- so the images
# are NOT rebuilt/re-pushed; the job just re-dispatches
# `container-image-published` to bitmoa/charts using the outputs kept from the
# original attempt.
#
# GitHub refuses to re-run a job whose workflow run is "over a month ago"
# (HTTP 403), which rules out most of a long backfill. For those runs the script
# falls back to triggering bitmoa/charts' image-bump.yml directly via
# workflow_dispatch -- that workflow accepts `image` + `tag` inputs and does the
# exact same work as the repository_dispatch path, with no age limit. Both
# values come straight from the pushed tag (mariadb/12.3.2-debian-12-r3 ->
# image=mariadb, tag=12.3.2-debian-12-r3). Requires push access to the charts
# repo. --mode picks which path is used.
#
# Two phases:
#   1. list   -- collect (run id, job id, tag) into a TSV cache, oldest first.
#   2. rerun  -- walk that list sequentially, sleeping between each trigger.
#
# The rerun phase is resumable: every handled run id is appended to a progress
# file and skipped on the next invocation.
#
# Usage:
#   .github/scripts/rerun-chart-bump.sh [list|rerun|status] [options]
#
#   --since DATE       only runs created on/after DATE   (default 2026-07-30)
#   --interval SECONDS wait between triggers             (default 360)
#   --mode MODE        auto | rerun | dispatch           (default auto)
#                        auto     re-run the job; on "over a month ago" fall
#                                 back to charts workflow_dispatch
#                        rerun    only re-run jobs, never dispatch
#                        dispatch always workflow_dispatch on the charts repo
#   --charts OWNER/NAME charts repository                (default bitmoa/charts)
#   --charts-workflow F charts workflow file             (default image-bump.yml)
#   --repo OWNER/NAME  target repository                 (default bitmoa/containers)
#   --workflow FILE    workflow file                     (default cd.yml)
#   --job NAME         job name to re-run                (default "Trigger chart bump & verification")
#   --limit N          max runs per date window          (default 1000)
#   --window DAYS      date window width when listing   (default 7)
#   --latest-only      per image name keep only the newest tag. charts'
#                      bump-image-tag.sh overwrites without comparing versions,
#                      so replaying every intermediate tag walks a chart up and
#                      down and cuts a release each time; the end state is the
#                      same as sending the newest tag alone.
#   --only FILE        restrict to the image names listed in FILE, one per
#                      line. Useful for a re-sync pass that only covers the
#                      charts whose values.yaml is still behind.
#   --max N            re-run at most N jobs this pass   (default: all)
#   --refresh          rebuild the TSV cache even if present
#   --reset            forget previous progress (start over)
#   --dry-run          print what would be re-run, call nothing
#   --state DIR        cache/progress directory          (default .rerun-chart-bump)
set -euo pipefail

REPO="${REPO:-bitmoa/containers}"
WORKFLOW="${WORKFLOW:-cd.yml}"
JOB_NAME="${JOB_NAME:-Trigger chart bump & verification}"
SINCE="${SINCE:-2026-07-30}"
INTERVAL="${INTERVAL:-360}"
LIMIT="${LIMIT:-1000}"        # per date-window cap (API hard limit is 1000)
WINDOW_DAYS="${WINDOW_DAYS:-7}"  # date-window width used to stay under that cap
MAX_RERUNS="${MAX_RERUNS:-0}"      # 0 = no cap
PARALLEL="${PARALLEL:-8}"          # parallelism of the *listing* phase only
STATE_DIR="${STATE_DIR:-.rerun-chart-bump}"
RERUN_MODE="${RERUN_MODE:-auto}"                    # auto | rerun | dispatch
CHARTS_REPO="${CHARTS_REPO:-bitmoa/charts}"         # workflow_dispatch target
CHARTS_WORKFLOW="${CHARTS_WORKFLOW:-image-bump.yml}"
DRY_RUN=0
REFRESH=0
RESET=0
LATEST_ONLY=0
ONLY_FILE=""
MODE="rerun"

case "${1:-}" in
  list|rerun|status) MODE="$1"; shift ;;
esac

while [ $# -gt 0 ]; do
  case "$1" in
    --since)    SINCE="$2"; shift 2 ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    --mode)     RERUN_MODE="$2"; shift 2 ;;
    --charts)   CHARTS_REPO="$2"; shift 2 ;;
    --charts-workflow) CHARTS_WORKFLOW="$2"; shift 2 ;;
    --repo)     REPO="$2"; shift 2 ;;
    --workflow) WORKFLOW="$2"; shift 2 ;;
    --job)      JOB_NAME="$2"; shift 2 ;;
    --limit)    LIMIT="$2"; shift 2 ;;
    --window)   WINDOW_DAYS="$2"; shift 2 ;;
    --max)      MAX_RERUNS="$2"; shift 2 ;;
    --state)    STATE_DIR="$2"; shift 2 ;;
    --latest-only) LATEST_ONLY=1; shift ;;
    --only)     ONLY_FILE="$2"; shift 2 ;;
    --refresh)  REFRESH=1; shift ;;
    --reset)    RESET=1; shift ;;
    --dry-run)  DRY_RUN=1; shift ;;
    -h|--help)  sed -n '2,46p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

case "$RERUN_MODE" in
  auto|rerun|dispatch) ;;
  *) echo "--mode must be auto, rerun or dispatch" >&2; exit 2 ;;
esac

command -v gh >/dev/null || { echo "gh CLI is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh is not authenticated (run: gh auth login)" >&2; exit 1; }

mkdir -p "$STATE_DIR"
JOBS_TSV="$STATE_DIR/jobs-${SINCE}.tsv"   # run_id \t job_id \t run_created_at \t conclusion \t tag
DONE_FILE="$STATE_DIR/done.txt"
FAILED_FILE="$STATE_DIR/failed.txt"
DISPATCHED_FILE="$STATE_DIR/dispatched.txt"   # tags handled via charts workflow_dispatch
LOG_FILE="$STATE_DIR/rerun.log"

if [ "$RESET" = 1 ]; then
  : > "$DONE_FILE"
  : > "$FAILED_FILE"
  : > "$DISPATCHED_FILE"
fi
touch "$DONE_FILE" "$FAILED_FILE" "$DISPATCHED_FILE"

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" | tee -a "$LOG_FILE"; }

# --- Phase 1: build the list -------------------------------------------------
build_list() {
  local runs_json="$STATE_DIR/runs.json"
  local win_dir="$STATE_DIR/windows"
  rm -rf "$win_dir"; mkdir -p "$win_dir"

  # The Actions API caps a single query at 1000 results, and this repo produces
  # ~1000 CD runs a month, so the range is swept in WINDOW_DAYS-wide slices.
  local from="$SINCE" to end_date
  end_date="$(date -u -d "tomorrow" +%F)"
  while [ "$from" \< "$end_date" ]; do
    to="$(date -u -d "$from +$WINDOW_DAYS days" +%F)"
    [ "$to" \> "$end_date" ] && to="$end_date"
    log "listing $REPO runs of $WORKFLOW created $from..$to"
    gh run list -R "$REPO" --workflow "$WORKFLOW" --created "$from..$to" --limit "$LIMIT" \
        --json databaseId,createdAt,headBranch,displayTitle,conclusion > "$win_dir/$from.json"
    local n; n=$(jq 'length' < "$win_dir/$from.json")
    log "  -> $n runs"
    if [ "$n" -ge 1000 ]; then
      log "  !! window hit the API's 1000-result cap; re-run with a smaller --window"
      exit 1
    fi
    from="$to"
  done

  # Windows overlap on their shared boundary day -> deduplicate by run id.
  jq -s 'add | unique_by(.databaseId)' "$win_dir"/*.json > "$runs_json"

  local total
  total=$(jq 'length' < "$runs_json")
  log "found $total workflow runs; probing each for the '$JOB_NAME' job (parallel $PARALLEL)"

  # Child shell used by xargs: emit one TSV line per matching job.
  # The job id (needed to re-run a *single* job) only comes from the per-run
  # jobs endpoint, so every run is probed once. Runs where the job never
  # executed (skipped, or never reached because an earlier job failed) are left
  # out -- only jobs that actually fired get replayed.
  probe() {
    local run_id="$1"
    gh api "repos/$REPO/actions/runs/$run_id/jobs?per_page=100" \
        --jq '.jobs[] | select(.name == $ENV.JOB_NAME or (.name | endswith(" / " + $ENV.JOB_NAME)))
              | select(.conclusion != null and .conclusion != "skipped")
              | [(.run_id|tostring), (.id|tostring), .conclusion] | @tsv' \
      2>/dev/null || true
  }
  export -f probe
  export REPO JOB_NAME

  jq -r '.[].databaseId' < "$runs_json" \
    | xargs -r -P "$PARALLEL" -I{} bash -c 'probe "$@"' _ {} \
    > "$JOBS_TSV.tmp"

  # Attach the run's creation time and pushed tag (seaweedfs/4.47.0-debian-12-r0).
  #
  # Ordering deliberately uses the run's created_at and not the job's
  # started_at: parallel runs finish out of order (couchdb r19's job started
  # after r20's), and a re-run moves started_at to today, which would drop the
  # run in the wrong place entirely. created_at is the tag push order, which is
  # the order the charts repo should see the bumps in.
  jq -r '.[] | [(.databaseId|tostring), .createdAt, (.headBranch // .displayTitle)] | @tsv' \
      < "$runs_json" > "$STATE_DIR/meta.tsv"
  awk -F'\t' 'NR==FNR { created[$1]=$2; tag[$1]=$3; next }
              { print $1 "\t" $2 "\t" (created[$1] ? created[$1] : "?") "\t" $3 "\t" (tag[$1] ? tag[$1] : "?") }' \
      "$STATE_DIR/meta.tsv" "$JOBS_TSV.tmp" \
    | sort -t"$(printf '\t')" -k3,3 > "$JOBS_TSV"
  rm -f "$JOBS_TSV.tmp" "$STATE_DIR/titles.tsv"

  log "collected $(wc -l < "$JOBS_TSV") '$JOB_NAME' jobs -> $JOBS_TSV (oldest first)"
}

ensure_list() {
  if [ "$REFRESH" = 1 ] || [ ! -s "$JOBS_TSV" ]; then
    build_list
  else
    log "reusing cached list $JOBS_TSV ($(wc -l < "$JOBS_TSV") jobs); pass --refresh to rebuild"
  fi
}

# --- Phase 2: sequential rerun ----------------------------------------------
#
# Re-run the single job through the Actions API. gh swallows the API's
# explanation for a 403, so the endpoint is called directly to keep the reason.
#
# GitHub turns a job down for two reasons this backfill keeps hitting:
#   "the workflow run was created over a month ago"
#   "Jobs in this workflow run cannot be re-run"  <- the run's logs have expired
# This repo keeps Actions logs for about a week, so in practice only the last
# few days of runs are re-runnable at all. Either way the answer is 403 and the
# work still has to go to the charts repo, so every 403 is reported as
# "not re-runnable" and only real errors (network, auth, 404) fail hard.
#   0 = re-run queued, 2 = not re-runnable, 1 = anything else
REASON=""
try_rerun_job() {
  local job_id="$1" out rc=0
  REASON=""
  out="$(gh api --method POST "repos/$REPO/actions/jobs/$job_id/rerun" 2>&1)" || rc=$?
  [ "$rc" = 0 ] && return 0
  printf '%s\n' "$out" >> "$LOG_FILE"
  REASON="$(printf '%s' "$out" | jq -r 'try .message catch empty' 2>/dev/null | head -n1)"
  [ -n "$REASON" ] || REASON="$(printf '%s' "$out" | head -c 200)"
  case "$out" in
    *'"status":"403"'*|*'(HTTP 403)'*) return 2 ;;
    *) return 1 ;;
  esac
}

# Fallback / alternative path: ask bitmoa/charts to bump the image itself.
# image-bump.yml only needs `image` and `tag`, both of which are just the two
# halves of the container tag (NAME/VERSION-OSTYPE-OSVER-rREV).
try_dispatch_charts() {
  local tag="$1" image image_tag
  image="${tag%%/*}"
  image_tag="${tag#*/}"
  if [ -z "$image" ] || [ "$image" = "$tag" ] || [ -z "$image_tag" ]; then
    printf 'cannot split tag %q into image/tag\n' "$tag" >> "$LOG_FILE"
    return 1
  fi
  gh workflow run "$CHARTS_WORKFLOW" -R "$CHARTS_REPO" \
      -f "image=$image" -f "tag=$image_tag" >>"$LOG_FILE" 2>&1
}

# charts' bump-image-tag.sh just overwrites whatever tag the chart carries -- it
# never compares versions -- so replaying every tag of an image in order walks
# the chart through each intermediate version, cutting a chart release per step.
# Keeping only each image's newest tag reaches the same end state in one step.
apply_filters() {
  WORK_TSV="$JOBS_TSV"

  if [ -n "$ONLY_FILE" ]; then
    [ -r "$ONLY_FILE" ] || { echo "--only file not readable: $ONLY_FILE" >&2; exit 2; }
    local only_tsv="$STATE_DIR/jobs-${SINCE}-only.tsv"
    awk -F'\t' 'NR==FNR { if ($0 != "") keep[$0] = 1; next }
                { split($5, a, "/"); if (keep[a[1]]) print }' \
        "$ONLY_FILE" "$WORK_TSV" > "$only_tsv"
    log "--only $ONLY_FILE: $(wc -l < "$WORK_TSV") -> $(wc -l < "$only_tsv") rows ($(grep -c . "$ONLY_FILE") image names)"
    WORK_TSV="$only_tsv"
  fi

  [ "$LATEST_ONLY" = 1 ] || return 0
  local latest_tsv="$STATE_DIR/jobs-${SINCE}-latest.tsv"
  awk -F'\t' 'NR==FNR { split($5, a, "/"); last[a[1]] = FNR; next }
              { split($5, a, "/"); if (last[a[1]] == FNR) print }' \
      "$WORK_TSV" "$WORK_TSV" > "$latest_tsv"
  log "--latest-only: $(wc -l < "$WORK_TSV") tags collapsed to $(wc -l < "$latest_tsv") (newest per image)"
  WORK_TSV="$latest_tsv"
}

do_rerun() {
  local total done_count=0 skipped=0 failed=0 dispatched=0 index=0 acted=0
  total=$(wc -l < "$WORK_TSV")
  log "processing up to $total jobs, ${INTERVAL}s apart (mode=$RERUN_MODE, dry-run=$DRY_RUN)"

  while IFS=$'\t' read -r run_id job_id created conclusion tag; do
    index=$((index + 1))
    [ -n "${run_id:-}" ] || continue

    if grep -qx "$run_id" "$DONE_FILE"; then
      skipped=$((skipped + 1))
      continue
    fi
    if [ "$MAX_RERUNS" != 0 ] && [ "$acted" -ge "$MAX_RERUNS" ]; then
      log "reached --max $MAX_RERUNS for this pass; run the script again to continue"
      break
    fi

    local label="[$index/$total] run=$run_id job=$job_id ($created, was $conclusion) $tag"
    if [ "$DRY_RUN" = 1 ]; then
      log "DRY-RUN would handle $label"
      acted=$((acted + 1))
      continue
    fi

    local rc=0 handled=""
    if [ "$RERUN_MODE" != dispatch ]; then
      try_rerun_job "$job_id" || rc=$?
      case "$rc" in
        0) handled="rerun" ;;
        2) if [ "$RERUN_MODE" = auto ]; then
             log "not re-runnable ($REASON); falling back to $CHARTS_REPO workflow_dispatch: $label"
           else
             log "SKIP (not re-runnable: $REASON, --mode rerun) $label"
           fi ;;
      esac
    fi

    if [ -z "$handled" ] && { [ "$RERUN_MODE" = dispatch ] || { [ "$RERUN_MODE" = auto ] && [ "$rc" = 2 ]; }; }; then
      if try_dispatch_charts "$tag"; then
        handled="dispatch"
        echo "$tag" >> "$DISPATCHED_FILE"
      fi
    fi

    case "$handled" in
      rerun)
        echo "$run_id" >> "$DONE_FILE"; done_count=$((done_count + 1)); acted=$((acted + 1))
        log "re-ran job $label" ;;
      dispatch)
        echo "$run_id" >> "$DONE_FILE"; dispatched=$((dispatched + 1)); acted=$((acted + 1))
        log "dispatched $CHARTS_WORKFLOW on $CHARTS_REPO for $label" ;;
      *)
        echo "$run_id	$job_id	$tag" >> "$FAILED_FILE"; failed=$((failed + 1)); acted=$((acted + 1))
        log "FAILED $label (see $LOG_FILE; recorded in $FAILED_FILE)" ;;
    esac

    # Space the triggers out so bitmoa/charts isn't flooded. Nothing to wait for
    # once this was the last item, or the last one --max allows.
    if [ "$index" -lt "$total" ] && { [ "$MAX_RERUNS" = 0 ] || [ "$acted" -lt "$MAX_RERUNS" ]; }; then
      sleep "$INTERVAL"
    fi
  done < "$WORK_TSV"

  log "done: $done_count re-run, $dispatched dispatched, $skipped already done, $failed failed"
}

show_status() {
  [ -s "$JOBS_TSV" ] && log "list: $(wc -l < "$JOBS_TSV") jobs in $JOBS_TSV" || log "list: not built yet"
  log "done: $(wc -l < "$DONE_FILE") (of which $(wc -l < "$DISPATCHED_FILE") via $CHARTS_REPO dispatch) | failed: $(wc -l < "$FAILED_FILE")"
}

case "$MODE" in
  list)   build_list ;;
  status) show_status ;;
  rerun)  ensure_list; apply_filters; do_rerun ;;
esac
