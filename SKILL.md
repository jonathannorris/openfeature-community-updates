---
name: openfeature-community-update
description: Generate the biweekly OpenFeature community update digest, a curated markdown report of the most notable PRs, issues, and discussions across the open-feature GitHub org. Use when asked to write, generate, or refresh the OpenFeature community update, digest, or newsletter, or when run on the biweekly routine.
---

# OpenFeature community update

Produces a curated digest of meaningful activity across the [open-feature](https://github.com/open-feature) org over the last **14 days**, for the OpenFeature community. Favor signal over completeness. **Omit routine noise**: renovate/dependabot bumps, automated release-please/openfeaturebot PRs, dependency-dashboard issues.

Each run writes two files in this folder:
1. `YYYY-MM-DD.md`: a standalone dated edition (the run date).
2. `README.md`: updated to link the 5 most recent editions and inline the full body of the latest one.

## Workflow

1. **Gather.** Run `scripts/gather.sh` (defaults to 14 days) to dump raw org activity as JSON. This is noisy, so delegate it to a subagent and keep only the curated findings.
   ```bash
   ./scripts/gather.sh 14
   ```
   For high-signal items (high `commentsCount`; anything in `spec`, `protocol`, `community`, `ofrep`; notable features/releases), pull detail with `gh pr view <n> --repo open-feature/<repo>` or `gh issue view`.

2. **Curate.** Keep an item only if it is one of:
   - a spec or protocol change (merged, or a live proposal worth watching);
   - a cross-SDK initiative or coordinated rollout;
   - a notable feature, new provider, or significant bug fix in an SDK/provider/flagd/operator;
   - a discussion with real engagement (~5+ substantive comments) or strategic significance;
   - a governance/community change (new/archived repos, maintainer changes, new members).

   Drop dependency bumps, automated release PRs, dependency-dashboard issues, and trivial docs/typo fixes; these may be summarized in one aggregate line.

3. **Write the dated edition** `YYYY-MM-DD.md`. Follow [FORMAT.md](FORMAT.md) exactly (section skeleton, `repo#number` links, no em dashes).

4. **Update `README.md`** by running the script. It regenerates only the marked regions (recent-editions list, capped at 5, and the inlined latest body) from the dated files; the intro and disclosure are left untouched.
   ```bash
   ./scripts/update-readme.sh
   ```

5. **Publish.** If run manually, present the draft for review before pushing. When run by the routine against the public repo, commit both files with a message like `docs: openfeature community update YYYY-MM-DD` and push. Never edit or overwrite prior editions.

## Notes

- `gh search prs --merged` is a boolean flag; the date bound goes in the query string as `merged:>=DATE` (handled inside `gather.sh`).
- The window is always 14 days ending on the run date.
- The canonical format example is the most recent dated edition in this folder.
