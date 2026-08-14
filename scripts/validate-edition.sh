#!/usr/bin/env bash
# Validate a generated edition. This runs unattended, in place of human review,
# so every check here is blocking.
#
# Usage:
#   scripts/validate-edition.sh                 # CI: today's edition + git checks
#   scripts/validate-edition.sh FILE [FILE...]  # content checks only, for auditing
#                                               # previously published editions
#
# Requires `gh` for link resolution. Set SKIP_LINK_CHECK=1 to skip it (useful
# when auditing the whole archive offline; never set it in CI).
set -euo pipefail

cd "$(dirname "$0")/.."

MIN_LINES=30
H1_PREFIX="# OpenFeature Community Update"

FAILURES=0
fail() { echo "  FAIL: $*" >&2; FAILURES=$((FAILURES + 1)); }

# ---------------------------------------------------------------- link checking

LINK_CACHE=$(mktemp -d)
trap 'rm -rf "$LINK_CACHE"' EXIT

# Resolve one GitHub URL. Returns non-zero if it does not point at something real.
resolve_link() {
  local url="$1"
  local key
  key=$(printf '%s' "$url" | tr -c 'A-Za-z0-9' '_')

  # Each URL usually appears more than once per edition; only pay for it once.
  if [ -f "$LINK_CACHE/$key" ]; then
    return "$(cat "$LINK_CACHE/$key")"
  fi

  local path="${url#https://github.com/}"
  local rc=0

  case "$path" in
    */pull/*)
      local repo="${path%%/pull/*}" num="${path##*/pull/}"
      gh api "repos/$repo/pulls/$num" --jq .number >/dev/null 2>&1 || rc=1
      ;;
    */issues/*)
      local repo="${path%%/issues/*}" num="${path##*/issues/}"
      gh api "repos/$repo/issues/$num" --jq .number >/dev/null 2>&1 || rc=1
      ;;
    */discussions/*|*/blob/*|*/tree/*|*/releases/*|*/actions/*|*/compare/*|*/wiki*)
      # No clean REST equivalent. An unauthenticated fetch is enough to tell a
      # real page from a fabricated one, since every org repo is public.
      curl -sfL --retry 2 --max-time 20 -o /dev/null "$url" || rc=1
      ;;
    */*)
      gh api "repos/$path" --jq .name >/dev/null 2>&1 || rc=1
      ;;
    *)
      gh api "orgs/$path" --jq .login >/dev/null 2>&1 \
        || gh api "users/$path" --jq .login >/dev/null 2>&1 || rc=1
      ;;
  esac

  echo "$rc" > "$LINK_CACHE/$key"
  return "$rc"
}

check_links() {
  local file="$1"
  if [ "${SKIP_LINK_CHECK:-0}" = "1" ]; then
    echo "  (link check skipped)"
    return 0
  fi
  command -v gh >/dev/null 2>&1 || { fail "gh is required for the link check"; return 0; }

  local urls url bad=0 total=0
  # Trailing punctuation is stripped by the character class, which deliberately
  # excludes the delimiters markdown puts after a URL.
  urls=$(grep -oE 'https://github\.com/[A-Za-z0-9._/#-]+' "$file" \
         | sed -E 's/[.,)]+$//' | sort -u || true)

  [ -z "$urls" ] && { fail "no GitHub links found; an edition without links is wrong"; return 0; }

  while IFS= read -r url; do
    [ -z "$url" ] && continue
    total=$((total + 1))
    if ! resolve_link "$url"; then
      fail "unresolvable link: $url"
      bad=$((bad + 1))
    fi
  done <<< "$urls"

  echo "  links: $total checked, $bad unresolvable"
}

# ------------------------------------------------------------- content checking

check_content() {
  local file="$1"
  echo "Checking $file"

  [ -f "$file" ] || { fail "$file does not exist"; return 0; }
  [ -s "$file" ] || { fail "$file is empty"; return 0; }

  local lines
  lines=$(wc -l < "$file" | tr -d ' ')
  if [ "$lines" -lt "$MIN_LINES" ]; then
    fail "only $lines lines; expected at least $MIN_LINES (a short edition means the run degraded)"
  fi

  local first
  first=$(head -1 "$file")
  case "$first" in
    "$H1_PREFIX"*) ;;
    *) fail "first line is not an '$H1_PREFIX' heading: $first" ;;
  esac

  # FORMAT.md line 45 forbids em dashes outright.
  if grep -q '—' "$file"; then
    local n
    n=$(grep -c '—' "$file")
    fail "contains $n em dash(es); FORMAT.md forbids them"
    grep -n '—' "$file" | sed 's/^/    /' >&2
  fi

  check_links "$file"
}

# ------------------------------------------------------------------ git checking

check_git_state() {
  local edition="$1"

  # Exactly two paths may change: the new edition, and the README regenerated
  # from it. Anything else means the agent or a script wrote where it shouldn't.
  local changed
  changed=$(git status --porcelain | sed -E 's/^.{3}//' | sort)

  local expected
  expected=$(printf '%s\n%s\n' "README.md" "$edition" | sort)

  if [ "$changed" != "$expected" ]; then
    fail "unexpected set of changed files"
    echo "    expected:" >&2; sed 's/^/      /' <<< "$expected" >&2
    echo "    actual:" >&2;   sed 's/^/      /' <<< "$changed" >&2
  fi

  # Belt and braces: published editions are immutable, so no tracked file under
  # updates/ may be modified or deleted.
  local touched
  touched=$(git status --porcelain -- updates/ | grep -vE '^\?\? ' | sed -E 's/^.{3}//' || true)
  if [ -n "$touched" ]; then
    fail "modified already-published edition(s):"
    sed 's/^/    /' <<< "$touched" >&2
  fi
}

# ----------------------------------------------------------------------- driver

if [ "$#" -gt 0 ]; then
  for f in "$@"; do check_content "$f"; done
else
  RUN_DATE=$(date -u +%F)
  EDITION="updates/$RUN_DATE.md"
  check_content "$EDITION"
  check_git_state "$EDITION"
fi

if [ "$FAILURES" -gt 0 ]; then
  echo
  echo "$FAILURES check(s) failed." >&2
  exit 1
fi

echo
echo "All checks passed."
