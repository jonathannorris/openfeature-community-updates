#!/usr/bin/env bash
# Commit the new edition and push it to main. Runs only in the privileged publish
# job, only after verify-incoming.sh and validate-edition.sh have both passed.
#
# Usage: scripts/publish.sh
set -euo pipefail

cd "$(dirname "$0")/.."

BOT_NAME="OpenFeature Bot"
BOT_EMAIL="109696520+openfeaturebot@users.noreply.github.com"
BRANCH="${PUBLISH_BRANCH:-main}"

RUN_DATE=$(date -u +%F)
EDITION="updates/$RUN_DATE.md"

[ -f "$EDITION" ] || { echo "error: $EDITION does not exist" >&2; exit 1; }

git config user.name "$BOT_NAME"
git config user.email "$BOT_EMAIL"

git add "$EDITION" README.md

if git diff --cached --quiet; then
  echo "error: nothing staged; refusing to push an empty commit" >&2
  exit 1
fi

# -s is mandatory: DCO sign-off is enforced org-wide at OpenFeature.
git commit -s -m "docs: community update for $RUN_DATE"

# The scheduled run is the only writer in practice, but a concurrent human push
# would otherwise lose the edition to a rejected non-fast-forward.
for attempt in 1 2 3; do
  if git push origin "HEAD:$BRANCH"; then
    echo "Published $EDITION to $BRANCH"
    exit 0
  fi
  echo "warning: push rejected (attempt $attempt/3); rebasing onto $BRANCH" >&2
  git fetch origin "$BRANCH"
  # Only ever replays this run's single commit; it never rewrites shared history.
  git rebase "origin/$BRANCH"
  sleep $((attempt * 5))
done

echo "error: could not push after 3 attempts" >&2
exit 1
