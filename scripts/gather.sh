#!/usr/bin/env bash
# Gather raw OpenFeature org activity for the community update digest.
# Usage: scripts/gather.sh [days]   (default 14)
# Emits JSON blocks to stdout for the agent to curate. Requires `gh` authenticated.
set -euo pipefail

DAYS="${1:-14}"
if date -v-1d +%F >/dev/null 2>&1; then
  SINCE=$(date -v-"${DAYS}"d +%F)   # macOS / BSD
else
  SINCE=$(date -d "${DAYS} days ago" +%F)  # GNU / Linux
fi
TODAY=$(date +%F)

echo "### window ${SINCE} to ${TODAY}"

echo "### merged_prs"
gh search prs --owner open-feature "merged:>=${SINCE}" --limit 100 \
  --json title,url,repository,author,closedAt,number

echo "### new_prs"
gh search prs --owner open-feature --created ">=${SINCE}" --limit 100 \
  --json title,url,repository,author,createdAt,number,state

echo "### new_issues"
gh search issues --owner open-feature --created ">=${SINCE}" --limit 100 \
  --json title,url,repository,author,createdAt,number,state

echo "### active_issues"
gh search issues --owner open-feature --updated ">=${SINCE}" --limit 100 \
  --json title,url,repository,author,updatedAt,number,state,commentsCount
