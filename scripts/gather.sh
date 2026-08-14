#!/usr/bin/env bash
# Gather raw OpenFeature org activity for the community update digest.
#
# Usage: scripts/gather.sh [days] [outdir]
#   days    size of the activity window, default 14
#   outdir  where to write the bundle, default ./.gather-bundle
#
# Writes a bundle the agent reads:
#   RUN_DATE.txt          the run date, YYYY-MM-DD (end of the window)
#   window.txt            human-readable window bounds
#   search-results.json   { merged_prs, new_prs, new_issues, active_issues }
#   counts.txt            result count per query, and whether it hit the cap
#
# Requires an authenticated `gh` (public reads only) and `jq`.
set -euo pipefail

DAYS="${1:-14}"
OUTDIR="${2:-./.gather-bundle}"

# Cap well above the expected volume. The old value of 100 silently truncated:
# a 14-day window across ~60 repos routinely exceeds it, especially for
# active_issues, and a truncated query is indistinguishable from a quiet week.
LIMIT=500

# Exclude bot authors in the query itself rather than filtering downstream, so
# the result budget is spent on human activity instead of noise the digest
# discards anyway. These must be appended to the query STRING, not passed as
# separate arguments: a bare `-author:...` argv entry is parsed as a CLI flag.
EXCLUDE_BOTS="-author:app/renovate -author:app/dependabot -author:openfeaturebot"

for tool in gh jq; do
  command -v "$tool" >/dev/null 2>&1 || { echo "error: $tool is required" >&2; exit 1; }
done

# Dates in UTC so local runs and CI agree.
if date -u -v-1d +%F >/dev/null 2>&1; then
  SINCE=$(date -u -v-"${DAYS}"d +%F)        # macOS / BSD
else
  SINCE=$(date -u -d "${DAYS} days ago" +%F)  # GNU / Linux
fi
TODAY=$(date -u +%F)

mkdir -p "$OUTDIR"
printf '%s\n' "$TODAY" > "$OUTDIR/RUN_DATE.txt"
printf 'Activity window: %s to %s (%s days)\n' "$SINCE" "$TODAY" "$DAYS" > "$OUTDIR/window.txt"
: > "$OUTDIR/counts.txt"

# A single transient failure used to abort the whole gather under `set -e`.
# Retry each query a few times before giving up.
search() {
  local label="$1"; shift
  local out="$OUTDIR/${label}.json"
  local attempt
  for attempt in 1 2 3; do
    if gh "$@" > "$out" 2>"$OUTDIR/${label}.err"; then
      local n
      n=$(jq 'length' < "$out")
      if [ "$n" -ge "$LIMIT" ]; then
        printf '%s: %s AT CAP (limit %s) - bundle is incomplete\n' \
          "$label" "$n" "$LIMIT" >> "$OUTDIR/counts.txt"
      else
        printf '%s: %s\n' "$label" "$n" >> "$OUTDIR/counts.txt"
      fi
      rm -f "$OUTDIR/${label}.err"
      return 0
    fi
    echo "warning: $label failed (attempt $attempt/3)" >&2
    sleep $((attempt * 5))
  done
  echo "error: $label failed after 3 attempts:" >&2
  cat "$OUTDIR/${label}.err" >&2
  return 1
}

search merged_prs search prs --owner open-feature \
  "merged:>=${SINCE} ${EXCLUDE_BOTS}" --limit "$LIMIT" \
  --json title,url,repository,author,closedAt,number

search new_prs search prs --owner open-feature \
  "created:>=${SINCE} ${EXCLUDE_BOTS}" --limit "$LIMIT" \
  --json title,url,repository,author,createdAt,number,state

search new_issues search issues --owner open-feature \
  "created:>=${SINCE} ${EXCLUDE_BOTS}" --limit "$LIMIT" \
  --json title,url,repository,author,createdAt,number,state

search active_issues search issues --owner open-feature \
  "updated:>=${SINCE} ${EXCLUDE_BOTS}" --limit "$LIMIT" \
  --json title,url,repository,author,updatedAt,number,state,commentsCount

jq -n \
  --slurpfile merged_prs    "$OUTDIR/merged_prs.json" \
  --slurpfile new_prs       "$OUTDIR/new_prs.json" \
  --slurpfile new_issues    "$OUTDIR/new_issues.json" \
  --slurpfile active_issues "$OUTDIR/active_issues.json" \
  --arg since "$SINCE" --arg today "$TODAY" \
  '{window: {since: $since, until: $today},
    merged_prs: $merged_prs[0],
    new_prs: $new_prs[0],
    new_issues: $new_issues[0],
    active_issues: $active_issues[0]}' \
  > "$OUTDIR/search-results.json"

rm -f "$OUTDIR"/merged_prs.json "$OUTDIR"/new_prs.json \
      "$OUTDIR"/new_issues.json "$OUTDIR"/active_issues.json

echo "Bundle written to $OUTDIR"
cat "$OUTDIR/counts.txt"
