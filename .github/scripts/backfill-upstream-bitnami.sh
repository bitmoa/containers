#!/usr/bin/env bash
#
# One-time backfill: replay upstream (bitnami/containers) commit-by-commit onto
# the current branch, from the current merge-base up to upstream/<branch>.
#
# For every upstream mainline commit that touches bitnami/ (and every "Release"
# commit), this creates one sync commit that:
#   - records the upstream commit in history via a `-s ours` merge (so it is
#     tracked and the merge-base advances), and
#   - brings the bitnami/ files to that commit's state, with the same rules as
#     the hourly sync:
#       * only ./bitnami/ changes,
#       * a whole version dir  bitnami/{app}/{version}  removed upstream is KEPT,
#       * a whole app dir       bitnami/{app}            removed upstream is KEPT,
#       * file deletions inside a surviving version dir ARE applied.
#   - tags each "[bitnami/{app}] Release {ver}" commit as {app}/{ver}, pointing
#     at that release's sync commit (so CD builds the correct historical tree).
#
# Upstream commits that don't touch bitnami/ are skipped; they still become
# tracked ancestors once a later bitnami/-changing commit (or the final tip
# merge) is recorded.
#
# Idempotent / resumable: commits already merged into HEAD are skipped, so a
# re-run continues where it left off. This script commits locally but does NOT
# push (set PUSH=1 to push main + tags at the end).
set -euo pipefail

trap 'rc=$?; echo "ERROR: line ${BASH_LINENO[0]}: ${BASH_COMMAND} (exit=$rc)" >&2' ERR

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/bitnami/containers.git}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"
SUBDIR="bitnami"
DRY_RUN="${DRY_RUN:-0}"          # 1 = show the plan, make no commits/tags
PUSH="${PUSH:-0}"                # 1 = push main and created tags at the end
LIMIT="${LIMIT:-0}"             # >0 = process at most this many commits (testing)
FETCH="${FETCH:-1}"             # 0 = skip fetching upstream (use local ref)

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Release commit subject -> "app/version", e.g.
#   [bitnami/redis-cluster] Release 8.8.1-debian-12-r0 (#95871)  ->  redis-cluster/8.8.1-debian-12-r0
release_tag_of() {
  printf '%s\n' "$1" | sed -nE 's#^\[bitnami/([^]]+)\] Release ([^ ]+).*#\1/\2#p'
}

# Apply upstream's bitnami/ change between two upstream commits to the working
# tree, honouring the version/app-dir protection rules.
apply_bitnami_diff() {
  local from="$1" to="$2"
  git diff --no-renames --name-status "$from" "$to" -- "$SUBDIR" \
  | while IFS=$'\t' read -r status path _; do
      [[ -z "$path" ]] && continue
      if [[ "$status" == D* ]]; then
        local rel app after ver
        rel="${path#"$SUBDIR"/}"     # app/...  (path is always under bitnami/)
        app="${rel%%/*}"
        after="${rel#*/}"
        if ! git cat-file -e "${to}:${SUBDIR}/${app}" 2>/dev/null; then
          continue                     # whole app removed upstream -> keep ours
        fi
        if [[ "$after" == */* ]]; then
          ver="${after%%/*}"
          if git cat-file -e "${to}:${SUBDIR}/${app}/${ver}" 2>/dev/null; then
            git rm -q --ignore-unmatch -- "$path"   # file removed, version survives
          fi
          # else: whole version dir removed upstream -> keep ours (skip)
        else
          git rm -q --ignore-unmatch -- "$path"     # app-level file, app survives
        fi
      else
        git checkout "$to" -- "$path"               # add / modify / typechange
      fi
    done
}

# --- Ensure upstream is available -------------------------------------------
if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
fi
if [[ "$FETCH" == "1" ]]; then
  git fetch --no-tags "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"
fi

UP_REF="refs/remotes/${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
UP_TIP="$(git rev-parse "$UP_REF")"
DEFAULT_BASE="$(git merge-base HEAD "$UP_REF")"
BASE=${BASE:-$DEFAULT_BASE}
echo "HEAD           : $(git rev-parse --short HEAD)"
echo "upstream tip   : $(git rev-parse --short "$UP_TIP") (${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH})"
echo "merge-base     : $(git rev-parse --short "$BASE")"

if [[ "$BASE" == "$UP_TIP" ]]; then
  echo "Already up to date with upstream; nothing to backfill."
  exit 0
fi

mapfile -t COMMITS < <(git rev-list --reverse --first-parent "${BASE}..${UP_TIP}")
echo "Upstream mainline commits to consider: ${#COMMITS[@]}"
[[ "$DRY_RUN" == "1" ]] && echo "(DRY_RUN: no commits or tags will be created)"

# Commits in the range that are already reachable from HEAD cannot be replayed:
# `git merge -s ours <ancestor>` is a no-op, so they get skipped. This happens
# when HEAD already tracks upstream (e.g. bitmoa mods were *merged* from an
# already-synced branch rather than cherry-picked onto the old base).
replayable="$(git rev-list --count --first-parent "${BASE}..${UP_TIP}" ^HEAD)"
already=$(( ${#COMMITS[@]} - replayable ))
if (( already > 0 )); then
  echo "NOTE: ${already}/${#COMMITS[@]} of these are already ancestors of HEAD and will be skipped."
  if (( already > replayable )); then
    echo "" >&2
    echo "WARNING: HEAD already contains most of the upstream range as ancestors, so the" >&2
    echo "         replay would only cover ${replayable} commits. If you meant to replay the" >&2
    echo "         whole range, start from a base WITHOUT upstream history and cherry-pick" >&2
    echo "         (do not merge) your bitmoa commits:" >&2
    echo "             git checkout -b backfill $(git rev-parse --short "$BASE")" >&2
    echo "             git cherry-pick <your bitmoa commits>   # see: git log --first-parent ${BASE:0:11}..HEAD" >&2
    echo "         then re-run. Set ALLOW_ANCESTOR_SKIP=1 to proceed anyway." >&2
    if [[ "${ALLOW_ANCESTOR_SKIP:-0}" != "1" ]]; then
      echo "Aborting (set ALLOW_ANCESTOR_SKIP=1 to override)." >&2
      exit 1
    fi
  fi
fi

git config --get user.name  >/dev/null || git config user.name  "bitmoa-sync"
git config --get user.email >/dev/null || git config user.email "bitmoa-sync@bitmoa.net"

prev="$BASE"
processed=0; synced=0; tagged=0
declare -a NEW_TAGS=()

for C in "${COMMITS[@]}"; do
  # Already replayed (resume) -> just advance the upstream cursor.
  if git merge-base --is-ancestor "$C" HEAD 2>/dev/null; then
    prev="$C"; continue
  fi

  subject="$(git log -1 --format=%s "$C")"
  tag="$(release_tag_of "$subject")"
  # Does this commit touch bitnami/? Use --quiet (exit code) rather than
  # `... | head`, which under `set -o pipefail` dies with 141 (SIGPIPE) when
  # git is still writing as head closes the pipe.
  if git diff --quiet "$prev" "$C" -- "$SUBDIR"; then changed=""; else changed=1; fi

  # Skip commits that neither touch bitnami/ nor are releases.
  if [[ -z "$changed" && -z "$tag" ]]; then
    prev="$C"; continue
  fi

  processed=$((processed+1))
  short="$(git rev-parse --short "$C")"
  echo "[$processed] ${short} ${subject}"

  if [[ "$DRY_RUN" == "1" ]]; then
    [[ -n "$tag" ]] && echo "        -> would tag ${tag}"
    prev="$C"
    [[ "$LIMIT" -gt 0 && "$processed" -ge "$LIMIT" ]] && break
    continue
  fi

  # Record the upstream commit (tracked, tree unchanged), then bring bitnami/
  # to this commit's state and finalise as one merge commit.
  git merge -s ours --no-commit --no-ff "$C" >/dev/null
  apply_bitnami_diff "$prev" "$C"
  git add -A "$SUBDIR"

  if [[ -z "$(git status --porcelain "$SUBDIR")" && -z "$tag" ]]; then
    # All changes were protected deletions and it isn't a release: no need for
    # an empty merge commit; this commit will be tracked via a later ancestor.
    git merge --abort 2>/dev/null || true
    prev="$C"
    continue
  fi

  # Preserve upstream's message + authorship + timestamps so the replayed
  # history reads exactly like upstream's. `-C` reuses the full message and the
  # author identity/date; GIT_COMMITTER_DATE keeps the committer timestamp too.
  GIT_COMMITTER_DATE="$(git log -1 --format=%cI "$C")" \
    git commit -q -C "$C"
  synced=$((synced+1))

  prev="$C"
  [[ "$LIMIT" -gt 0 && "$processed" -ge "$LIMIT" ]] && break
done

# Ensure the upstream tip itself is a tracked ancestor (covers the case where
# the newest upstream commits don't touch bitnami/).
if [[ "$DRY_RUN" != "1" && "$LIMIT" -le 0 ]]; then
  if ! git merge-base --is-ancestor "$UP_TIP" HEAD 2>/dev/null; then
    git merge -s ours --no-edit --no-ff "$UP_REF" >/dev/null
    echo "Recorded upstream tip $(git rev-parse --short "$UP_TIP") as tracked."
  fi
fi

echo "----------------------------------------------------------------"
echo "Processed: ${processed}  Sync commits: ${synced}  New tags: ${tagged}"

if [[ "$DRY_RUN" != "1" && "$PUSH" == "1" ]]; then
  echo "Pushing main..."
  git push origin HEAD:"$(git rev-parse --abbrev-ref HEAD)"
  for t in "${NEW_TAGS[@]}"; do
    echo "Pushing tag ${t}"
    git push origin "refs/tags/${t}"
  done
fi

echo "Done."
