# Digest format reference

The canonical example is the most recent dated edition in this folder. When in doubt, match it.

## Dated edition (`YYYY-MM-DD.md`)

Filename is the run date. Section headings below are stable; drop a section only when it has no qualifying items that period.

```markdown
# OpenFeature Community Update: <Mon D> to <Mon D>, <YYYY>

_A biweekly digest of the most notable pull requests, issues, and discussions across the [open-feature](https://github.com/open-feature) org._

## TL;DR

- 3–5 bullets, each linking the headline item.

## Spec & Protocol
### Shipped
### Proposals to watch

## <Named cross-SDK initiative, if any>

## flagd & Operator
### flagd
### Operator

## SDKs & Providers

## Community & Governance

---

_Routine dependency bumps (renovate/dependabot) and automated release PRs are omitted from this digest._

_Generated on <YYYY-MM-DD>. Covers activity from <SINCE> to <TODAY>._
```

## Conventions

- **Link everything** with the `repo#number` convention pointing at the full GitHub URL, e.g. `[spec#385](https://github.com/open-feature/spec/pull/385)`.
- **Bold the item title/summary**, then a sentence of context.
- Group related smaller items on one line separated by ` · `.
- A coordinated cross-SDK effort gets its own top-level section named after the initiative, with an umbrella-issue link and an "in flight" / "tracking issues" breakdown.
- Plain sentence prose. **No em dashes**: use commas, semicolons, or colons.
- Length: roughly one page. Editorial, not exhaustive.

## README (`README.md`)

Don't hand-edit the generated parts. `scripts/update-readme.sh` rewrites only the two regions bounded by HTML-comment markers, from the dated edition files:

- `<!-- BEGIN:editions -->` … `<!-- END:editions -->`: the "Recent editions" list, 5 most recent, newest first. Link text is derived from each edition's H1.
- `<!-- BEGIN:latest -->` … `<!-- END:latest -->`: the full body of the newest edition, inlined verbatim.

Everything outside the markers (intro paragraph, disclosure blockquote) is hand-maintained and preserved. The script is idempotent. Structure:

```markdown
# OpenFeature Community Updates

<one-paragraph intro>

> These digests are generated automatically by an AI agent running a Claude Code skill on a recurring schedule. They aim to surface signal, but may miss or misframe things; corrections and PRs welcome.

## Recent editions

<!-- BEGIN:editions -->
- [<Mon D to Mon D, YYYY>](./YYYY-MM-DD.md)   (up to 5, newest first)
<!-- END:editions -->

---

<!-- BEGIN:latest -->
<full body of the latest dated edition, verbatim>
<!-- END:latest -->
```
