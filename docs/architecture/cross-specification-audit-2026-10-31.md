# AELYXORA — Cross-Specification Consistency Audit (2026-10-31)

**Status: repository-documentation audit and repairs, NOT architect acceptance, implemented validation or release evidence.** Scope: D1–D8 contracts, current Markdown documentation, schemas, examples, ownership, source/ABI/runtime, dependency resolution, snapshot durability and project process. No Studio executable or native parser was run.

## Audit method and coverage

- Checked **71 Markdown files and 657 internal relative links** in five passes: **zero missing path targets**. External URLs, URL fragment/section anchors, and remote provider availability are outside this link result.
- Compared overlapping design owners and first-slice fixtures; reviewed the project/package/lock/HEAD/index interfaces and negative diagnostic expectations.
- Independently recalculated **one SHA-256 reference** from actual GitHub-fetched source bytes: the D3 ConsumerPanel link source digest matches exactly; no edit needed.
- Design-only consistency is not the same as standards-compliant schema testing or a working native implementation. All D1–D8 gates remain **Proposed/Open** until explicit architect approval.

## A. Confirmed contradictions corrected directly in main

| ID | Severity | Conflict | Correction | Remaining limitation |
| --- | --- | --- | --- | --- |
| A-01 | P0 | [Implementation Readiness](implementation-readiness.md) still instructed immediate S0 coding despite [Design Gates](design-completion-gates.md) forbidding any new product implementation until full in-scope D1–D8 approval | Clarified current Phase I, marked S0–S4 as **future Phase II only**, replaced immediate S0 instruction | No approval or implementation yet |
| A-02 | P0 | [Graph Validation](graph-validation-and-migration.md) resolved typed graph references before validating package lock/export identity, opposite [D6 Offline Resolver](d6-offline-dependency-resolution.md) | Defined ordered parse → schema → identities → exact lock/export resolution → typed graph → behaviors → target → semantic digest → publication | Actual validator does not exist |
| A-03 | P0 | [Graph Behavior](graph-behavior-contract.md) permitted transfer=borrow token in stream/snapshot declarations but restricted borrowed values to call-scoped synchronous delivery, **not** queued/retained channels | First-profile queued stream/snapshot borrow now explicitly rejected at semantic stage: FLOW_CROSS_DOMAIN_BORROW across domains, FLOW_BORROW_REQUIRES_SYNC in same domain. Two [negative cases](../../examples/architecture-sensor/d2-invalid-cases.json) added | Structural schema can still parse borrow for future profiles; synchronous profile not designed |
| A-04 | P1 | [Graph Validation](graph-validation-and-migration.md) described exact SemVer-style package versions, while D6 requires exact opaque versions and no ranges or auto-selection | Aligned graph validator and [Project Format](project-and-package-format.md) with exact opaque version strings | Source/package policy still proposed |
| A-05 | P1 | [Package Resolution](package-resolution-build.md) asked to compare lock's **export type registry** directly against snapshot's **packageObjects**, which contain package byte identities, not exported TypeIDs | Compare lock packageId/contentDigest tuples with index.packageObjects; separately recompute exports from verified manifest | Unimplemented resolver |
| A-06 | P1 | [Graph Validation](graph-validation-and-migration.md) used ambiguous PACKAGE_UNRESOLVED and PACKAGE_PATH_ESCAPE while D6 used PKG_LOCK_MISSING, PKG_VERSION_CONFLICT and PKG_PATH_ESCAPE | Aligned first-slice diagnostic table with D6, distinguishing missing lock from wrong exact version | Future diagnostic conformance not run |
| A-07 | P1 | [Consistency Audit](consistency-audit.md) still assigned current syntax authority to broad [AUI Syntax](aui-syntax.md), conflicting with [D3 L0/L1 Grammar](d3-first-language-profile.md) | L0/L1 is now stated as first-profile grammar; broad syntax is **future D3+ proposal** | D3+ remains unfinished |
| A-08 | P1 | Old [sensor-summary.aui](../../examples/aui-language/sensor-summary.aui) called itself a positive D3 fixture although positional modifiers/unresolved imports make it incompatible with strict L0/L1 | Marked old source and [legacy negative fragments](../../examples/aui-language/negative-cases.md) illustrative D3+, separate from current [28 L0/L1 negatives](../../examples/aui-language/d3-first-profile-negative-cases.json) | No parser exists |
| A-09 | P2 | Older [Schema Validation](schema-validation-contract.md) and [Consistency Audit](consistency-audit.md) implied no lockfile fixture existed anywhere | Distinguished incomplete sensor from [Locked Pure Reference](../../examples/locked-pure-reference/README.md) with actual bytes, lock, snapshot and hash vectors | Pure reference does **not** prove native ABI |
| A-10 | P2 | S2 plan mentioned implementing state/bind with "small subset" while [L0/L1](d3-first-language-profile.md) excludes those features and design has not been accepted | S2 now conditional on accepted design; State/Derived/Bind/Task/await remain explicit D3+ closure | No source implementation started |

**Meaning of repaired:** conflicting written proposals were aligned. A documentation edit does not approve the revised choice, implement code, or prove native tests.

## B. Major open contract gaps (not mere outdated wording)

| ID | Priority | Observed design gap | Required closure |
| --- | --- | --- | --- |
| O-01 | P0 | [D2 Semantic Projection](d2-d6-semantic-projection.md) and [Project Graph](project-graph.md) lack actual encoded MMIO/IRQ/DMA, ISA/resource exclusivity, capability scopes despite hardware-oriented product goals | Add typed resource schema, target constraints, canonical fields and rejection rules |
| O-02 | P0 | [D2 Execution](d2-execution-consistency.md) and [Component ABI](aui-component-binary-abi.md) rely on undefined target-level atomic, allocator, provider-cancellation and buffer-lifetime proofs | Close D4/D5 physical ABI and safety contracts |
| O-03 | P0 | Professional RAD capabilities State, Derived, Bind, Task/await, Result-to-UI and dynamic children are outside small L0/L1 | Fully specify D3+; do not declare all D3 accepted based only on first subset |
| O-04 | P0 | [D3 Core](d3-type-and-binding-profile.md) is only a versioned **candidate**, with unresolved core type contract hashes and exact native layout | Pin core type registry/import policy and D4 ABI bridge |
| O-05 | P0 | [D3 linked source](../../examples/aui-language/linked-consumer-panel.aui) and [command link](../../examples/aui-language/linked-consumer-panel.link.json) are not committed inside the immutable [locked pure snapshot](../../examples/locked-pure-reference/README.md) | Define reviewable graph/source binding transaction, snapshot inclusion and invalidation; do not call L1 runnable |
| O-06 | P0 | [D6 Canonical Persistence](d6-canonical-persistence.md) two HEAD slots do not preserve unbounded operationId history | Choose durable replay ledger/retention policy or explicit old-retry conflict |
| O-07 | P0 | [D6 FS Adapters](d6-filesystem-adapters.md) do not yet prove actual atomic and power-loss durable behavior on Windows/NTFS or Linux | Select qualified first host/filesystem, define permitted guarantee/fallback, later Phase III fault injection |
| O-08 | P0 | [Package Integrity](d6-package-integrity.md) lacks fully approved publisher trust/signature, extra resource inventory, and portable safe path proof | Freeze trust model, inventory and safe native adapter contract |
| O-09 | P1 | [project.schema.json](../../schemas/project.schema.json) makes retiredIdentities optional, while [Semantic Projection](d2-d6-semantic-projection.md) includes it in every canonical graph | Define absent-vs-empty normalization, legacy migration and ID-reuse protection |
| O-10 | P1 | [D6 Canonical JSON](d6-canonical-persistence.md) requires exact Unicode control escaping, scalar and key ordering but positive vectors do not cover all escaping/normalization cases | Add verified byte-for-byte positive/negative vectors and parser size bounds |
| O-11 | P1 | [D3 Event Delivery](d3-event-delivery-and-command-linkage.md) proposes a queue of 64 per ViewIdentity but total number of views and memory/fairness caps remain unspecified | Bound total UI ingress memory, fairness and user-visible backpressure |
| O-12 | P1 | [ChatGPT Connection](chatgpt-connection.md) depends on external provider eligibility and scope policies; no actual connected AELYXORA authorization flow | Verify eligible official provider program and consent contract before user-facing runtime claims |
| O-13 | P1 | Proposed Windows x64 Studio host differs from Linux x86-64 source fixture and Linux AArch64 sensor target. These are valid as design examples but not first-host ABI evidence | Separate Windows source/ABI/link golden only after accepted D4 design |
| O-14 | P1 | [D2/D6 Baseline Review](d2-d6-baseline-review.md), [D3 Review](d3-language-review.md) and [Specification Matrix](specification-completion-matrix.md) retain unapproved P0 decisions | Record architect decisions, rationale, exact baseline commit and bounded deferrals |

## C. Consistencies positively checked

- Architecture Map and AUI remain projections of one [Project Graph](project-graph.md). Stable node IDs do not derive from view coordinates or source line numbers.
- [D2 logical export identity](d2-export-contract-identity.md) is separate from exact package implementation byte hash. Source-only edits must not accidentally change semanticGraphDigest.
- The [D3 ConsumerPanel link map](../../examples/aui-language/linked-consumer-panel.link.json) sourceSha256 **matches the actual linked-consumer-panel.aui bytes** in a targeted independent calculation. This is *source integrity*, not executable Graph/ABI linkage.
- [Design Gates](design-completion-gates.md) keep Phase I documentation, Phase II implementation, Phase III actual tests, Phase IV corrections strictly separated.
- Main-only repository workflow, no early CI, Assembly-first Studio core and Python prohibition are consistent high-level restrictions.

## D. Recommended remediation order

1. Document D2 full hardware/target/resource projection and all first-profile transfer/scheduler ownership failure codes.
2. Freeze full D3+/D4 AUI type, state, event, async, command Result and physical ABI boundaries with a source-to-Graph snapshot trace.
3. Close D6 legacy tombstone and Unicode canonical vectors, operation history, package-trust and first-host FS contracts.
4. Reconcile remaining D1 UX, AI-provider eligibility, D5 renderer/performance budgets and D7/D8 build/release evidence.
5. Run another multi-owner audit and request explicit human architecture acceptance of D1–D8 before authorizing implementation.

## Evidence limits

This is a **design/documentation audit**, not a full JSON Schema standard-suite run, formally proven type system, on-host native build, compiler test, device benchmark, UI accessibility test or power-loss simulation. The counted links assert file-path existence, not URL fragment correctness. Native AELYXORA test observations remain **NOT-RUN**.

## O-01 design work — typed hardware resources (still P0)

The [D2 Hardware Resource Contract](d2-hardware-resource-contract.md) and [0.2-hw-draft structural schema](../../schemas/project.schema.json) now propose typed target requirements and MMIO/IRQ/DMA/memory claims **inside the canonical Project Graph**. The existing pure 0.1-draft fixtures and hashes are explicitly unchanged. [D2↔D3 hardware command authority](d2-d3-hardware-command-boundary.md) prevents direct AUI hardware access. [Hardware sensor fixture](../../examples/architecture-sensor/hardware-resource-profile-project.auiproj.json) and [29 design rejection cases](../../examples/architecture-sensor/hardware-resource-negative-cases.json) are not a verified linked native driver. Update to O-01 status: **MODEL PROPOSED, P0 OPEN** pending target feature/adapter registries, claim identity retention, real package resolution, exact byte hashes, native ABI, operator authorization and Phase III tests. No implied architect approval.

## O-03/O-04/O-05 — D3+ proposed remediation, not approval

[L2 State/Derived/Bind](d3-state-derived-binding-contract.md) proposes atomic typed UI state and one-way keyed bindings. [L3 Task/Result](d3-task-result-lifecycle.md) proposes explicit bounded dispatch, exhaustive typed outcomes and cancellation/lifetime boundaries. [Source/Snapshot Approval](d3-source-snapshot-reconciliation.md) and [source bundle schema](../../schemas/aui-source-link-bundle.schema.json) outline exact source profile/lock/Graph association, without pretending a proposed link map is an approved execution grant. [L2/L3 fixtures](../../examples/aui-language/D3PLUS-README.md) and [future negative/race scenarios](../../examples/aui-language/d3plus-negative-cases.json) are design-only. Thus O-03/O-04/O-05 are **PROPOSAL-ADVANCED but still P0 OPEN**: complete core registry, versioned type digests, native ABI, dynamic keyed collections, actual source approval/immutable receipt, runtime queues, target and Phase III testing are not complete. D1–D8 acceptance remains absent.

## D3-P05 / D3-P12 L4 design update — still P0 OPEN

[Keyed Dynamic Views](d3-keyed-dynamic-view-lifecycle.md) now propose exact scoped identities for repeated children, key uniqueness, generation invalidation, safe reparent/unmount and bounded atomic reconciliation. [D3/D4/D5 Cross-Layer Review](d3-d4-d5-lifecycle-consistency-review.md) records 12 explicit native/renderer/lifetime risks. [L4 source and reference trace](../../examples/aui-language/L4-README.md) plus [40 negative/race design cases](../../examples/aui-language/l4-negative-cases.json) are not product tests. O-03 is advanced at design level only: List/StableKey core registry, compiler source SymbolID provenance, native callback drain, Task/CommandTicket memory ownership and real D5 focus/IME/renderer behavior remain unproven. Nothing in this appendage retroactively changes the original 2026-10-31 audit counts or human approval status.

## Core ABI and D5 budget design follow-up — still P0

[D3 Core Registry](d3-core-registry-value-contract.md) proposes exact portable StableKey frames and 13 logical type entries, with [design vectors](../../examples/aui-language/d3-core-value-vectors.json), but **no accepted exported-contract digests**. [D4 ABI](d4-core-value-abi-contract.md) specifies required independent physical layouts for Win64 and Linux x86-64, NOT-RUN. [D5 UI Budget](d5-ui-resource-budget-and-publication.md) proposes a root memory envelope, resource-admission checks and generation-safe UI publication; [reference arithmetic vectors](../../examples/aui-language/d5-budget-reference-vectors.json) are not measured performance. [Cross-contract review](d3-d4-d5-core-contract-review.md) maintains all native proofs and approved resource budgets as OPEN. This appendage does not change the historical audit's original counts or acceptance status.

## Versioned core public digest and Win64 first-host design follow-up (P0 OPEN)

[Core export v2 proposal](d2-d3-core-export-digest-contract.md) introduces a new domain-separated logical contract hash without modifying prior D2 v1 locked pure vectors. [Win64 call ABI](d4-win64-native-component-abi.md), [module/result descriptors](d4-win64-module-and-result-descriptors.md) and [D5 Windows host](d5-windows-host-runtime-contract.md) document native field offsets, target calling-convention, DPI/IME/UIA responsibilities and security gates. [Full cross-gate review](d2-d6-win64-baseline-review.md) records 15 still OPEN P0/P1 items. The new SHA and layout arithmetic references are not native ABI, durable D6 snapshot or Windows OS tests. This appendix does not alter the historical audit findings count or imply approval.
