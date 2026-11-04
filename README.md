# OpenFeature Community Updates

A biweekly digest of the most notable pull requests, issues, and discussions across the [open-feature](https://github.com/open-feature) org. Each edition curates what actually shipped and what's worth watching, skipping routine dependency bumps and automated release PRs.

> These digests are generated automatically by an AI agent on a recurring schedule. They aim to surface signal, but may miss or misframe things; corrections and PRs welcome.

## Recent editions

<!-- BEGIN:editions -->
- [Oct 21 to Nov 4, 2026](./updates/2026-11-04.md)
- [Oct 14 to Oct 28, 2026](./updates/2026-10-28.md)
- [Oct 7 to Oct 21, 2026](./updates/2026-10-21.md)
- [Sep 30 to Oct 14, 2026](./updates/2026-10-14.md)
- [Sep 24 to Oct 8, 2026](./updates/2026-10-08.md)
<!-- END:editions -->

---

<!-- BEGIN:latest -->
# OpenFeature Community Update: Oct 21 to Nov 4, 2026

_A biweekly digest of the most notable pull requests, issues, and discussions across the [open-feature](https://github.com/open-feature) org._

## TL;DR

- **The OpenFeature Operator is preparing a breaking multi-tenancy change:** [open-feature-operator#847](https://github.com/open-feature/open-feature-operator/issues/847) and its follow-up series add cluster-scoped resources while removing implicit cross-namespace resolution.
- **Provider conformance is becoming reusable across flagd adopters:** [java-sdk-contrib#1847](https://github.com/open-feature/java-sdk-contrib/pull/1847) now runs the Provider TCK in all three flagd resolver modes, with [flagd-testbed#445](https://github.com/open-feature/flagd-testbed/pull/445) packaging shared extension scenarios.
- **flagd will recover from deleted and restored flag files without a restart:** [flagd#2117](https://github.com/open-feature/flagd/pull/2117) adds persistent re-watch behavior for file sync.
- **Swift is adding two spec-aligned capabilities:** [swift-sdk#146](https://github.com/open-feature/swift-sdk/pull/146) proposes client-level event observation, and [swift-sdk#147](https://github.com/open-feature/swift-sdk/pull/147) proposes a logging hook.

## Provider Conformance TCK

- **flagd now has a shared conformance baseline:** [java-sdk-contrib#1847](https://github.com/open-feature/java-sdk-contrib/pull/1847) merged Provider TCK coverage for RPC, in-process, and file resolvers. Each suite has no failures: 63 of 65 scenarios pass in the gRPC modes, and 62 of 65 pass for the file resolver, with the remainder explicitly skipped.
- **The extension path is moving out of legacy harnesses:** [flagd-testbed#445](https://github.com/open-feature/flagd-testbed/pull/445) adds an embedded `tck-extensions` module with 11 reusable feature files. [java-sdk-contrib#1951](https://github.com/open-feature/java-sdk-contrib/pull/1951) is the first consumer, running the remaining flagd scenarios through the shared extension hook. The work tracks the Provider TCK effort in [spec#417](https://github.com/open-feature/spec/issues/417).

## flagd & Operator
### flagd

- **File sync now has a recovery path after deletion:** [flagd#2117](https://github.com/open-feature/flagd/pull/2117) keeps retrying the watch until a deleted flag file reappears, including kubelet-style ConfigMap swaps, so in-process providers can receive restored flags without a process restart.

### Operator

- **Namespace isolation is being designed for the 0.10.0 breaking release:** [open-feature-operator#871](https://github.com/open-feature/open-feature-operator/pull/871) adds `ClusterFeatureFlagSource` and `ClusterInProcessConfiguration`, restricts namespaced references to the local namespace, and narrows Kubernetes sync RBAC. The stacked [open-feature-operator#873](https://github.com/open-feature/open-feature-operator/pull/873) and [open-feature-operator#875](https://github.com/open-feature/open-feature-operator/pull/875) define cluster-first layering and explicit namespace conditions, addressing the cross-namespace trust-boundary issue in [open-feature-operator#847](https://github.com/open-feature/open-feature-operator/issues/847).
- **Sync credentials can leave resource specifications:** [open-feature-operator#879](https://github.com/open-feature/open-feature-operator/pull/879) adds Secret-backed bearer tokens, using a kubelet-expanded `secretKeyRef` rather than having the operator read or copy the token.

## SDKs & Providers

- **Java’s numeric contract is becoming lossless:** [java-sdk-contrib#1957](https://github.com/open-feature/java-sdk-contrib/pull/1957) stops flagd-core from narrowing values when precision would be lost, while [java-sdk-contrib#1959](https://github.com/open-feature/java-sdk-contrib/pull/1959) adds lossless coercion and safe-range handling.
- **Swift is filling two SDK capability gaps:** [swift-sdk#146](https://github.com/open-feature/swift-sdk/pull/146) adds client-scoped provider event observation, and [swift-sdk#147](https://github.com/open-feature/swift-sdk/pull/147) adds the Appendix A logging hook with opt-in evaluation-context logging.

## Community & Governance

- **flagd added a new approver:** [community#582](https://github.com/open-feature/community/pull/582) promotes NeaguGeorgiana23 after the cross-language fractional hashing work.
- **The provider directory is expanding across languages:** [openfeature.dev#1636](https://github.com/open-feature/openfeature.dev/pull/1636) adds FeatBit Go, Kotlin, Python, Ruby, and Rust providers to the ecosystem listing.

---

_Routine dependency bumps (renovate/dependabot) and automated release PRs are omitted from this digest._

_Generated on 2026-11-04. Covers activity from 2026-10-21 to 2026-11-04._
<!-- END:latest -->
