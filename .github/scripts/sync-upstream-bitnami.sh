#!/usr/bin/env bash
#
# Mirror ./bitnami/ from upstream (bitnami/containers) into the working tree,
# and list the release tags introduced since the previous sync.
#
# This script does NOT commit, merge, or push -- the workflow drives git.
# It expects the upstream remote-tracking branch (upstream/<branch>) to already
# be fetched, and a `-s ours` merge to be in progress (so upstream commits are
# recorded in history); it only shapes the bitnami/ tree and emits the tag list.
#
# Directory layout is  bitnami/{app}/{version}/...
#
# Rules:
#   - Only ./bitnami/ is touched.
#   - Files added/updated/removed upstream are mirrored, EXCEPT:
#       * a whole version dir  bitnami/{app}/{version}  removed upstream is KEPT,
#       * a whole app dir       bitnami/{app}            removed upstream is KEPT.
#   - File-level deletions *inside* a surviving version dir ARE applied.
set -euo pipefail

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/bitnami/containers.git}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"
SUBDIR="bitnami"
MIN_APP_COUNT="${MIN_APP_COUNT:-100}"     # abort if upstream tree looks this small
MAX_RELEASE_TAGS="${MAX_RELEASE_TAGS:-1000}"  # skip tagging if the range is implausibly large

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# Pre-merge main commit; the range ORIG_REF..upstream/BRANCH is the set of
# upstream commits newly introduced by this sync (empty on a no-op run).
ORIG_REF="${SYNC_ORIG_REF:-}"

TAGS_FILE="${SYNC_TAGS_FILE:-$ROOT/sync-tags.txt}"
: > "$TAGS_FILE"

# --- Ensure upstream is available -------------------------------------------
if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
fi
if ! git rev-parse -q --verify "refs/remotes/${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}" >/dev/null; then
  git fetch --no-tags --filter=blob:none "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"
fi

UPSTREAM_REF="refs/remotes/${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
NEW_SHA="$(git rev-parse "$UPSTREAM_REF")"
UPSTREAM_SHORT="$(git rev-parse --short "$UPSTREAM_REF")"
echo "Upstream ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH} @ ${UPSTREAM_SHORT}"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "UPSTREAM_SHORT=${UPSTREAM_SHORT}" >> "$GITHUB_ENV"
  echo "SYNC_TAGS_FILE=${TAGS_FILE}" >> "$GITHUB_ENV"
fi

# --- Collect release tags for upstream commits new since the last sync ------
# Release commits look like: "[bitnami/redis-cluster] Release 8.8.1-debian-12-r0 (#95871)"
# -> tag  redis-cluster/8.8.1-debian-12-r0  (the exact format .github/parse-tag.sh expects).
if [[ -z "$ORIG_REF" ]]; then
  echo "No baseline ref (SYNC_ORIG_REF) provided -- skipping tag collection."
elif ! git merge-base --is-ancestor "$ORIG_REF" "$NEW_SHA" 2>/dev/null && \
     [[ "$(git rev-list --count "${ORIG_REF}..${NEW_SHA}")" -eq 0 ]]; then
  echo "No new upstream commits since ${ORIG_REF} -- no tags."
else
  count="$(git rev-list --count "${ORIG_REF}..${NEW_SHA}")"
  echo "Upstream commits new since baseline: ${count}"
  if (( count > MAX_RELEASE_TAGS )); then
    echo "WARN: ${count} new commits exceeds MAX_RELEASE_TAGS=${MAX_RELEASE_TAGS}; skipping tag creation." >&2
  else
    ALL_TAGS="$(mktemp)"
    git log --no-merges --format='%s' "${ORIG_REF}..${NEW_SHA}" \
      | sed -nE 's#^\[bitnami/([^]]+)\] Release ([^ ]+).*#\1/\2#p' \
      | sort -u > "$ALL_TAGS"

    # A long gap between syncs piles up many releases per line; only build the
    # newest patch/revision of each {app, major.minor, os} line, e.g.
    #   clickhouse/26.8.21-debian-12-r1, 26.8.22-debian-12-r0, 26.8.22-debian-12-r1,
    #   clickhouse/26.9.0-debian-12-r0
    #   -> clickhouse/26.8.22-debian-12-r1, clickhouse/26.9.0-debian-12-r0
    # Tags not in NAME/X.Y.Z-OSTYPE-OSVER-rREV form are kept as-is.
    # Output is ordered in "rounds": every app's oldest line first, then each
    # app's next line, ... so the tag step can push older versions first.
    sort -V "$ALL_TAGS" | awk '
      {
        key = $0
        if (match($0, /\/[0-9]+(\.[0-9]+)*-[^-]+-[^-]+-[^-]+$/)) {
          app = substr($0, 1, RSTART - 1)
          ver = substr($0, RSTART + 1)
          split(ver, p, "-"); split(p[1], n, ".")
          mm  = (n[2] == "") ? n[1] : n[1] "." n[2]
          key = app "|" mm "|" p[2] "-" p[3]
        } else {
          app = $0
        }
        if (!(key in last)) { order[++nkeys] = key; keyapp[key] = app }
        last[key] = $0          # sort -V input: the final one per key is newest
      }
      END {
        for (i = 1; i <= nkeys; i++) {
          k = order[i]
          printf "%d\t%s\n", ++round[keyapp[k]], last[k]
        }
      }' | sort -t$'\t' -k1,1n -k2,2V | cut -f2 > "$TAGS_FILE"

    echo "Release tags: $(wc -l < "$ALL_TAGS") in range, $(wc -l < "$TAGS_FILE") latest per line to create"
    comm -23 "$ALL_TAGS" <(sort -u "$TAGS_FILE") | sed 's/^/  superseded: /'
    rm -f "$ALL_TAGS"
  fi
fi

# --- Materialise upstream bitnami/ tree into a temp dir ---------------------
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git archive --format=tar "$NEW_SHA" "$SUBDIR" | tar -x -C "$TMP"

if [[ ! -d "$TMP/$SUBDIR" ]]; then
  echo "ERROR: upstream has no '${SUBDIR}/' directory at ${UPSTREAM_SHORT}" >&2
  exit 1
fi

# --- Safety guard: never mirror an implausibly small tree -------------------
up_app_count="$(find "$TMP/$SUBDIR" -mindepth 1 -maxdepth 1 -type d | wc -l)"
echo "Upstream app dirs: ${up_app_count}"
if (( up_app_count < MIN_APP_COUNT )); then
  echo "ERROR: only ${up_app_count} app dirs upstream (< ${MIN_APP_COUNT}); aborting to avoid mass deletion." >&2
  exit 1
fi

# --- Build protect rules for directories upstream has removed ---------------
# rsync protect ('P') rules keep matching paths in the destination from being
# deleted by --delete. Paths are anchored to the transfer root (bitnami/).
RULES="$TMP/protect.rules"
: > "$RULES"

if [[ -d "$SUBDIR" ]]; then
  while IFS= read -r -d '' app_path; do
    app="$(basename "$app_path")"
    if [[ ! -d "$TMP/$SUBDIR/$app" ]]; then
      # Whole app dir removed upstream -> keep the entire app.
      printf 'P /%s\n'     "$app" >> "$RULES"
      printf 'P /%s/***\n' "$app" >> "$RULES"
      continue
    fi
    # App survives: keep any version dir that upstream removed.
    while IFS= read -r -d '' ver_path; do
      ver="$(basename "$ver_path")"
      if [[ ! -d "$TMP/$SUBDIR/$app/$ver" ]]; then
        printf 'P /%s/%s\n'     "$app" "$ver" >> "$RULES"
        printf 'P /%s/%s/***\n' "$app" "$ver" >> "$RULES"
      fi
    done < <(find "$SUBDIR/$app" -mindepth 1 -maxdepth 1 -type d -print0)
  done < <(find "$SUBDIR" -mindepth 1 -maxdepth 1 -type d -print0)
fi

protected="$(grep -c '\*\*\*$' "$RULES" || true)"
echo "Protecting ${protected} dir(s) removed upstream from deletion."

# --- Mirror upstream bitnami/ into local, honouring the protect rules -------
# --checksum (not size+mtime): a fresh checkout and a fresh tar extract share
# near-identical mtimes, so same-size content changes (v1 -> v2) would be
# missed by the default quick-check. Compare by content instead.
rsync -a --checksum --delete \
  --filter=". $RULES" \
  "$TMP/$SUBDIR/" "$SUBDIR/"

echo "Sync of ${SUBDIR}/ complete (upstream @ ${UPSTREAM_SHORT})."
