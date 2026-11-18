# OpenFeature Community Updates

A biweekly digest of the most notable pull requests, issues, and discussions across the [open-feature](https://github.com/open-feature) org. Each edition curates what actually shipped and what's worth watching, skipping routine dependency bumps and automated release PRs.

> These digests are generated automatically by an AI agent on a recurring schedule. They aim to surface signal, but may miss or misframe things; corrections and PRs welcome.

## Recent editions

<!-- BEGIN:editions -->
- [Nov 4 to Nov 18, 2026](./updates/2026-11-18.md)
- [Oct 28 to Nov 11, 2026](./updates/2026-11-11.md)
- [Oct 21 to Nov 4, 2026](./updates/2026-11-04.md)
- [Oct 14 to Oct 28, 2026](./updates/2026-10-28.md)
- [Oct 7 to Oct 21, 2026](./updates/2026-10-21.md)
<!-- END:editions -->

---

<!-- BEGIN:latest -->
# OpenFeature Community Update: Nov 4 to Nov 18, 2026

_A biweekly digest of the most notable pull requests, issues, and discussions across the [open-feature](https://github.com/open-feature) org._

## TL;DR

- **Terminal `resolve` targeting is spreading across the ecosystem:** [flagd#2090](https://github.com/open-feature/flagd/issues/2090), [flagd-schemas#238](https://github.com/open-feature/flagd-schemas/pull/238), [js-sdk-contrib#1669](https://github.com/open-feature/js-sdk-contrib/pull/1669), [dotnet-sdk-contrib#782](https://github.com/open-feature/dotnet-sdk-contrib/pull/782), and [java-sdk-contrib#1979](https://github.com/open-feature/java-sdk-contrib/pull/1979).
- **Rust’s OFREP provider tightened protocol behavior:** [rust-sdk-contrib#183](https://github.com/open-feature/rust-sdk-contrib/pull/183) and [rust-sdk-contrib#190](https://github.com/open-feature/rust-sdk-contrib/pull/190) are merged.
- **The Rust flagd RPC resolver now uses evaluation v2:** [rust-sdk-contrib#179](https://github.com/open-feature/rust-sdk-contrib/pull/179) landed, with `ResolveAll` still tracked separately.
- **The CLI is adding C++ code generation:** [cli#300](https://github.com/open-feature/cli/pull/300) adds type-safe headers, configurable namespaces, and custom templates.

## Spec & Protocol
### Shipped

- **Rust OFREP response handling now follows the protocol more closely:** [rust-sdk-contrib#183](https://github.com/open-feature/rust-sdk-contrib/pull/183) enforces successful status handling, blocks redirects, isolates rate limits per provider, and preserves response reasons and metadata. Its follow-up, [rust-sdk-contrib#190](https://github.com/open-feature/rust-sdk-contrib/pull/190), maps server error codes and details, handles code-default responses, distinguishes type mismatches, and bounds error-body reads.

### Proposals to watch

- **The remaining Rust OFREP gaps are now explicit:** [rust-sdk-contrib#191](https://github.com/open-feature/rust-sdk-contrib/issues/191) tracks a request timeout and `OFREP_*` environment-variable defaults, including the protocol’s 10-second timeout requirement.

## Terminal `resolve` targeting operator

[flagd#2090](https://github.com/open-feature/flagd/issues/2090) tracks the rollout of per-branch variants, reasons, and metadata.

- **In flight:** [flagd#2127](https://github.com/open-feature/flagd/pull/2127) defines the evaluator behavior, while [flagd-schemas#238](https://github.com/open-feature/flagd-schemas/pull/238) and [flagd-testbed#448](https://github.com/open-feature/flagd-testbed/pull/448) pin terminal placement, metadata precedence, malformed-argument fallback, and error semantics. JavaScript, .NET, and Java implementations are proposed in [js-sdk-contrib#1669](https://github.com/open-feature/js-sdk-contrib/pull/1669), [dotnet-sdk-contrib#782](https://github.com/open-feature/dotnet-sdk-contrib/pull/782), and [java-sdk-contrib#1979](https://github.com/open-feature/java-sdk-contrib/pull/1979).

## flagd & Operator
### flagd

- **Sync sources can read rotating credentials from mounted files:** [flagd#2128](https://github.com/open-feature/flagd/pull/2128) adds `authHeaderPath`, reloads the file on each request, prefers it over an inline header, and reports missing or unreadable files instead of silently omitting authentication.
- **The proxy is considering a safer selector default:** [flagd#2134](https://github.com/open-feature/flagd/issues/2134) proposes rejecting client-supplied `file:` selectors by default, with an explicit opt-in for debugging and load tests.
- **The testbed’s 4.x line is moving to TCK extensions:** [flagd-testbed#450](https://github.com/open-feature/flagd-testbed/pull/450) drops the legacy `gherkin/` suite while keeping the 3.x release branch for SDKs that still depend on it.

## flagd evaluation v2 migration

[flagd#1088](https://github.com/open-feature/flagd/issues/1088) tracks removal of deprecated evaluation v1 compatibility.

- **In flight:** [rust-sdk-contrib#179](https://github.com/open-feature/rust-sdk-contrib/pull/179) is merged and now handles optional v2 values and variants in the RPC resolver. The remaining bulk-evaluation gap is [flagd-schemas#235](https://github.com/open-feature/flagd-schemas/issues/235), which tracks `ResolveAll`.

## SDKs & Providers

- **The CLI’s C++ generator is taking shape:** [cli#300](https://github.com/open-feature/cli/pull/300) adds `openfeature generate cpp`, type-safe flag keys and clients, namespace configuration, custom templates, and golden tests.
- **The provider catalog gained broader client and server coverage:** [openfeature.dev#1636](https://github.com/open-feature/openfeature.dev/pull/1636) adds FeatBit Go, Kotlin, Python, Ruby, and Rust providers; [openfeature.dev#1624](https://github.com/open-feature/openfeature.dev/pull/1624) adds Featureflip web, React, and Android entries; [openfeature.dev#1679](https://github.com/open-feature/openfeature.dev/pull/1679) proposes Octopus Deploy’s JavaScript server provider.
- **Go SDK provider lifecycle cleanup landed:** [go-sdk#643](https://github.com/open-feature/go-sdk/pull/643) cancels comparison-strategy contexts on return, while [go-sdk#628](https://github.com/open-feature/go-sdk/pull/628) stops the event goroutine when a shared provider is replaced.
- **.NET evaluation events now use semantic error types:** [dotnet-sdk#852](https://github.com/open-feature/dotnet-sdk/pull/852) aligns emitted `error.type` values with the semantic conventions.

## Community & Governance

- **Project metadata is becoming more useful to maintainers:** [.project#4](https://github.com/open-feature/.project/pull/4) records all public OpenFeature Slack channels, and [.project#5](https://github.com/open-feature/.project/pull/5) proposes adding SDK maintainers to the project maintainers list so they can access CNCF resources.

---

_Routine dependency bumps (renovate/dependabot) and automated release PRs are omitted from this digest._

_Generated on 2026-11-18. Covers activity from 2026-11-04 to 2026-11-18._
<!-- END:latest -->
