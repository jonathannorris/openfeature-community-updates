#!/usr/bin/env bash
# Verify the artifact the agent produced, then move it into updates/.
#
# Usage: scripts/verify-incoming.sh <incoming-dir>
#
# The downloaded artifact is untrusted input: the agent chose its filename and
# its contents. Everything about the path is re-checked here, in the privileged
# job, before a single byte is written into the working tree.
set -euo pipefail

INCOMING="${1:?usage: verify-incoming.sh <incoming-dir>}"
TODAY=$(date -u +%F)

fail() { echo "error: $*" >&2; exit 1; }

[ -d "$INCOMING" ] || fail "$INCOMING is not a directory"

# Exactly one file, anywhere in the artifact tree.
FILES=()
while IFS= read -r f; do FILES+=("$f"); done < <(find "$INCOMING" -type f | sort)

[ "${#FILES[@]}" -eq 0 ] && fail "the agent uploaded no files"
if [ "${#FILES[@]}" -ne 1 ]; then
  printf 'error: expected exactly 1 file, got %s:\n' "${#FILES[@]}" >&2
  printf '  %s\n' "${FILES[@]}" >&2
  exit 1
fi

SRC="${FILES[0]}"
BASE=$(basename "$SRC")

# The name must be a bare ISO date, and it must be today's date. A stale or
# guessed date would either overwrite history or publish under the wrong day.
echo "$BASE" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' \
  || fail "filename '$BASE' does not match YYYY-MM-DD.md"
[ "${BASE%.md}" = "$TODAY" ] \
  || fail "filename date ${BASE%.md} is not today's UTC date ($TODAY)"

DEST="updates/$BASE"

# Published editions are immutable. This is also what makes a same-day re-run
# safe: the second run stops here instead of rewriting the first one's work.
[ -e "$DEST" ] && fail "$DEST already exists; refusing to overwrite a published edition"

[ -s "$SRC" ] || fail "$SRC is empty"

mkdir -p updates
cp "$SRC" "$DEST"
echo "Accepted $DEST ($(wc -l < "$DEST" | tr -d ' ') lines)"
