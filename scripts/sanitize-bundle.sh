#!/usr/bin/env bash
# Neutralize untrusted text in the gather bundle before the agent reads it.
#
# Usage: scripts/sanitize-bundle.sh <bundle-dir>
#
# Why this exists: gh-aw's `tools.github.min-integrity` only filters content that
# arrives through the sandboxed GitHub tooling. The gather step is a custom
# workflow step, so it runs OUTSIDE the sandbox and its output is not filtered at
# all. PR and issue titles are writable by any GitHub user, and they reach the
# agent verbatim every run. This rewrites every string in the bundle so a title
# cannot smuggle instructions, comment delimiters, or invisible characters.
set -euo pipefail

BUNDLE="${1:?usage: sanitize-bundle.sh <bundle-dir>}"
SRC="$BUNDLE/search-results.json"

command -v jq >/dev/null 2>&1 || { echo "error: jq is required" >&2; exit 1; }
[ -f "$SRC" ] || { echo "error: $SRC not found" >&2; exit 1; }

PROGRAM=$(mktemp)
trap 'rm -f "$PROGRAM"' EXIT

# The program goes in a quoted heredoc rather than inline: it contains both
# quote characters and backticks, which are hostile to shell quoting.
cat > "$PROGRAM" <<'JQ'
def clean:
  if type == "string" then
      # Control characters, including the newlines a title should never contain.
      gsub("[\\x00-\\x08\\x0a-\\x1f\\x7f]"; " ")
      # Zero-width and bidirectional-override characters: invisible to a
      # reviewer, meaningful to a model.
    | gsub("[\\x{200b}-\\x{200f}\\x{202a}-\\x{202e}\\x{2066}-\\x{2069}\\x{feff}]"; "")
      # HTML comment delimiters, which can hide text from a rendered diff.
    | gsub("<!--"; "(") | gsub("-->"; ")")
      # Backticks become apostrophes, so a title cannot close the inline-code
      # span or fenced block it is quoted inside and escape into prompt context.
    | gsub("`"; "'")
      # No title is legitimately this long; anything longer is payload.
    | .[0:200]
  else . end;
walk(clean)
JQ

jq -f "$PROGRAM" "$SRC" > "$SRC.tmp"
mv "$SRC.tmp" "$SRC"
echo "Sanitized $SRC"
