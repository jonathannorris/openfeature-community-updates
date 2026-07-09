#!/usr/bin/env bash
# Regenerate the auto-managed regions of README.md from the dated editions.
# Rewrites only the content between these marker pairs, leaving intro/disclosure alone:
#   <!-- BEGIN:editions --> ... <!-- END:editions -->   (5 most recent, newest first)
#   <!-- BEGIN:latest -->   ... <!-- END:latest -->      (full body of newest edition)
# Editions live in updates/YYYY-MM-DD.md. Usage: scripts/update-readme.sh
set -euo pipefail

cd "$(dirname "$0")/.."   # folder root (README.md here; editions in updates/)
README="README.md"
UPDATES="updates"

# Collect dated editions (updates/YYYY-MM-DD.md), newest first. bash 3.2 safe (no mapfile).
EDITIONS=()
while IFS= read -r f; do EDITIONS+=("$f"); done < <(
  ls -1 "$UPDATES" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' | sort -r
)
if [ "${#EDITIONS[@]}" -eq 0 ]; then
  echo "error: no dated editions (updates/YYYY-MM-DD.md) found" >&2
  exit 1
fi
LATEST="$UPDATES/${EDITIONS[0]}"

# Build the "Recent editions" list (up to 5). Link text is derived from each
# edition's H1 by stripping the "# OpenFeature Community Update:" prefix.
LIST_TMP="$(mktemp)"
trap 'rm -f "$LIST_TMP"' EXIT
count=0
for f in "${EDITIONS[@]}"; do
  [ "$count" -ge 5 ] && break
  title="$(grep -m1 '^# ' "$UPDATES/$f" | sed -E 's/^# OpenFeature Community Update:? *//')"
  [ -z "$title" ] && title="$f"
  printf -- '- [%s](./%s/%s)\n' "$title" "$UPDATES" "$f" >> "$LIST_TMP"
  count=$((count + 1))
done

# Rewrite the two managed regions in place.
awk -v listfile="$LIST_TMP" -v bodyfile="$LATEST" '
  /<!-- BEGIN:editions -->/ { print; while ((getline l < listfile) > 0) print l; close(listfile); skip=1; next }
  /<!-- END:editions -->/   { skip=0; print; next }
  /<!-- BEGIN:latest -->/   { print; while ((getline l < bodyfile) > 0) print l; close(bodyfile); skip=1; next }
  /<!-- END:latest -->/     { skip=0; print; next }
  skip { next }
  { print }
' "$README" > "$README.tmp"
mv "$README.tmp" "$README"

echo "Updated $README (latest: $LATEST, ${count} edition(s) listed)"
