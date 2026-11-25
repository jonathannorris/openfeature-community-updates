# OpenFeature Community Updates

A biweekly digest of the most notable pull requests, issues, and discussions across the [open-feature](https://github.com/open-feature) org. Each edition curates what actually shipped and what's worth watching, skipping routine dependency bumps and automated release PRs.

> These digests are generated automatically by an AI agent on a recurring schedule. They aim to surface signal, but may miss or misframe things; corrections and PRs welcome.

## Recent editions

<!-- BEGIN:editions -->
- [Nov 11 to Nov 25, 2026](./updates/2026-11-25.md)
- [Nov 4 to Nov 18, 2026](./updates/2026-11-18.md)
- [Oct 28 to Nov 11, 2026](./updates/2026-11-11.md)
- [Oct 21 to Nov 4, 2026](./updates/2026-11-04.md)
- [Oct 14 to Oct 28, 2026](./updates/2026-10-28.md)
<!-- END:editions -->

---

<!-- BEGIN:latest -->
# OpenFeature Community Update: Nov 11 to Nov 25, 2026

_A biweekly digest of the most notable pull requests, issues, and discussions across the [open-feature](https://github.com/open-feature) org._

## TL;DR

- **The terminal `resolve` operator moved from design into implementation:** [flagd#2127](https://github.com/open-feature/flagd/pull/2127) is merged, with the schema, testbed, and SDK ports still in flight.
- **Three spec proposals tighten cross-SDK behavior:** [spec#459](https://github.com/open-feature/spec/pull/459) covers context passed to later hooks, [spec#460](https://github.com/open-feature/spec/pull/460) standardizes provider names, and [spec#461](https://github.com/open-feature/spec/pull/461) defines numeric coercion failures.
- **Operator cluster-scoped configuration is becoming safer:** [open-feature-operator#872](https://github.com/open-feature/open-feature-operator/pull/872), [open-feature-operator#873](https://github.com/open-feature/open-feature-operator/pull/873), and [open-feature-operator#875](https://github.com/open-feature/open-feature-operator/pull/875) are merged.
- **flagd is adding resource bounds to sync processing:** [flagd#2138](https://github.com/open-feature/flagd/pull/2138) limits response size and evaluator expansion work.
- **Rust added spec 4.6 HookData support:** [rust-sdk#140](https://github.com/open-feature/rust-sdk/pull/140) gives each hook isolated state across its evaluation stages.

## Spec & Protocol
### Proposals to watch

- **Later hooks would receive context returned by earlier `before` hooks:** [spec#459](https://github.com/open-feature/spec/pull/459) adds Requirement 4.3.10 and a conformance scenario. [python-sdk#687](https://github.com/open-feature/python-sdk/pull/687) implements the corresponding sequential propagation and reports a passing test suite.
- **Provider metadata and numeric coercion are being made more consistent:** [spec#460](https://github.com/open-feature/spec/pull/460) recommends the same provider metadata name across languages without a `provider` suffix, while [spec#461](https://github.com/open-feature/spec/pull/461) requires `TYPE_MISMATCH` when a numeric result cannot be represented by the requested accessor.

## Terminal `resolve` targeting operator

[flagd#2090](https://github.com/open-feature/flagd/issues/2090) tracks per-branch variants, reasons, and metadata.

- **Reference behavior is now merged:** [flagd#2127](https://github.com/open-feature/flagd/pull/2127) makes `resolve` terminal, supports nested `if` and `fractional` results, and defines rule, flag, and flag-set metadata precedence. Malformed computed arguments fall back to the default variant.
- **The rollout remains in flight across the ecosystem:** [flagd-schemas#238](https://github.com/open-feature/flagd-schemas/pull/238) defines placement and argument validation, [flagd-testbed#448](https://github.com/open-feature/flagd-testbed/pull/448) adds conformance scenarios, and implementations are proposed in [js-sdk-contrib#1669](https://github.com/open-feature/js-sdk-contrib/pull/1669), [dotnet-sdk-contrib#782](https://github.com/open-feature/dotnet-sdk-contrib/pull/782), and [java-sdk-contrib#1979](https://github.com/open-feature/java-sdk-contrib/pull/1979).

## flagd & Operator
### flagd

- **Sync source processing is getting bounded:** [flagd#2138](https://github.com/open-feature/flagd/pull/2138) adds configurable `maxResponseSize`, rejects oversized updates without discarding the current ETag or flag state, and replaces unbounded `$evaluators` string expansion with parsed-JSON expansion and cycle detection.
- **Metadata-change event behavior is gaining conformance coverage:** [flagd-testbed#454](https://github.com/open-feature/flagd-testbed/pull/454) distinguishes effective flag metadata changes from inherited values and documents remaining file-mode differences in Java, Python, and .NET providers.

### Operator

- **Cluster-scoped sources now require explicit, controlled sharing:** [open-feature-operator#872](https://github.com/open-feature/open-feature-operator/pull/872) moves source-reference validation into the webhook and reconciler, [open-feature-operator#873](https://github.com/open-feature/open-feature-operator/pull/873) merges cluster resources first so namespaced values win, and [open-feature-operator#875](https://github.com/open-feature/open-feature-operator/pull/875) adds namespace conditions where no condition means no access.
- **Custom flagd ports have a routing fix under review:** [open-feature-operator#886](https://github.com/open-feature/open-feature-operator/pull/886) makes Services target the named ports that flagd actually listens on, including evaluation, OFREP, sync, and management endpoints.

## SDKs & Providers

- **Computed fractional bucket support is spreading:** [js-sdk-contrib#1671](https://github.com/open-feature/js-sdk-contrib/pull/1671) and [python-sdk-contrib#484](https://github.com/open-feature/python-sdk-contrib/pull/484) are open implementations, while [rust-sdk-contrib#198](https://github.com/open-feature/rust-sdk-contrib/issues/198), [dotnet-sdk-contrib#783](https://github.com/open-feature/dotnet-sdk-contrib/issues/783), [python-sdk-contrib#482](https://github.com/open-feature/python-sdk-contrib/issues/482), [java-sdk-contrib#1988](https://github.com/open-feature/java-sdk-contrib/issues/1988), and [js-sdk-contrib#1670](https://github.com/open-feature/js-sdk-contrib/issues/1670) track the remaining ports.
- **The Python OFREP provider now has environment-based configuration in review:** [python-sdk-contrib#483](https://github.com/open-feature/python-sdk-contrib/pull/483) supports `OFREP_ENDPOINT`, `OFREP_HEADERS`, and `OFREP_TIMEOUT_MS`, with explicit arguments taking precedence and invalid values rejected.
- **Evaluation and event semantics continue to converge:** [dotnet-sdk#860](https://github.com/open-feature/dotnet-sdk/pull/860) fixes API, transaction, client, invocation, and hook context ordering, while [go-sdk#658](https://github.com/open-feature/go-sdk/pull/658) prevents newer provider events from overtaking pending registration handlers.
- **The ecosystem catalog added five Railflag providers:** [openfeature.dev#1688](https://github.com/open-feature/openfeature.dev/pull/1688) lists JavaScript, web JavaScript, Python, Go, and Java providers that share in-process test vectors and stream changes.

## Community & Governance

- **Maintainer coverage expanded:** [community#588](https://github.com/open-feature/community/pull/588) adds a Rust approver and [community#590](https://github.com/open-feature/community/pull/590) adds a flagd triager. [community#589](https://github.com/open-feature/community/pull/589) proposes adding another active flagd and operator contributor to the organization and triager group.

---

_Routine dependency bumps (renovate/dependabot) and automated release PRs are omitted from this digest._

_Generated on 2026-11-25. Covers activity from 2026-11-11 to 2026-11-25._
<!-- END:latest -->
