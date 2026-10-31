# AELYXORA — Design, Implementation, Verification and Correction Roadmap

**Status: documentation-first; specification baseline is NOT accepted or frozen.** The authoritative implementation facts are in [PROJECT-STATUS](../architecture/PROJECT-STATUS.md); this roadmap is a plan, not a claim of working software. No GitHub Actions/CI before release preparation. No Python in Studio source, tooling or tests.

**Product:** architecture-first, AI-native, Assembly-first RAD for native applications and systems. The primary interface is the Architecture Map with contextual AI Chat. **Architecture -> Workflows -> Data Flows -> AI implementation -> Verification -> UX/AUI preview** is the priority order. The human owns architecture and approvals; AI primarily produces code within accepted component contracts. A declarative UI is downstream from the graph, not a separate primary editor.

**Four sequential phases:** **I Design / Documentation -> II Implementation -> III Tests & Measurements -> IV Corrections & Re-verification**.

## Phase I — Full documentation and architecture closure (CURRENT)

- **D1 Product / experience** — architect decisions, workflows, offline UI, map and chat.
- **D2 Canonical Project Graph** — typed components, exact edge kinds, workflow and data-flow semantics, hardware resources, revisions and identity.
- **D3 AUI language** — complete grammar, events/commands/bindings, ownership-facing constructs, valid and invalid golden source.
- **D4 Compiler / native ABI** — AST, TypedHIR, OwnershipIR, TargetMIR, binary layout and target toolchain contracts.
- **D5 Runtime / native UI** — scheduling, state, events, cancellation, window, text, IME, accessibility and rendering.
- **D6 Build / persistence** — project/package representation, lock/digests, atomic revision journal, local build inputs and diagnostics.
- **D7 AI / authorization** — context privacy, provider eligibility, consent, structured diffs, execution permission separation, offline operation.
- **D8 Cross-document closure** — no contradictory normative rules, end-to-end positive/negative design scenario, target feasibility assumptions and **explicit human architect acceptance** of the whole in-scope baseline.

Each gate is governed by [Design Completion Gates](../architecture/design-completion-gates.md) and tracked by the [Specification Completion Matrix](../architecture/specification-completion-matrix.md). An authored fixture is a *design test specification*, not a passed test. A gate is not accepted merely because an agent wrote or committed prose.

**End-to-end design specimen:** model a sensor/device -> driver -> bounded data channel -> decoder -> observable state -> optional AUI text view, with a reverse explicit UI event -> command -> permitted adapter path. Also specify AI-proposed ASM patch, scope approval, transaction/recovery, build and test evidence mapping. Actual hardware support is not asserted.

**Phase I exit:** all in-scope D1–D8 accepted, first host and target decisions documented, contradictions resolved, positive/negative fixtures specified, and no unbounded P0 decisions. Do not proceed to code merely because one individual gate looks complete. Research-only feasibility experiments, if separately approved, do not constitute Phase II.

## Phase II — Implementation (NOT STARTED)

Implement the **accepted** baseline in coherent vertical slices. Any material semantic change returns to Phase I for its owning specification and explicit approval. Compilation while developing is part of implementation bring-up, not automatically post-implementation acceptance evidence.

| Slice | Planned deliverable |
| --- | --- |
| **S0** | Native strict parser -> typed Project Graph -> semantic diagnostics -> local package resolution -> revision-safe persistence |
| **S1** | Native Architecture Map workspace, contract inspection, manual graph edit/revision, disconnected contextual AI panel |
| **S2** | Minimal AUI syntax/compiler/runtime path -> first native UI; source-to-graph identity, event-command dispatch and one-way state binding |
| **S3** | Scoped AI proposal import/validation/approval, source ownership protection, tool permission boundary; official provider connection only if eligible and permitted |
| **S4** | Chosen real target/hardware and target-specific ABI/adapter integration where in approved scope |

The existing Linux x86-64 JSON delimiter/string preflight is a **limited research artifact**, not a complete S0 parser. Neither Windows x64 Studio nor Linux AArch64 sensor execution is currently verified.

### Product milestones (namespace M, not test namespace)

- **M0 — Design baseline accepted** (Phase I, prerequisite to implementation).
- **M1 — Hardware-aware Project Graph foundation** (S0): real graph/project and package inputs.
- **M2 — First Studio workspace** (S1/S2): native Architecture Map + contextual disconnected chat; inspect components.
- **M3 — Safe editing**: atomic revision-aware edits, rollback, no silent AI mutations.
- **M4 — Component implementation workflow**: approved ASM source, AUI where needed, visible evidence links.
- **M5 — Authorized ChatGPT integration**: only if approved official authentication and inference entitlement exist; otherwise stay disconnected.
- **M6 — Hardware-aware tools**: target ABI/capability/resource inspect, optional authorized debugging.
- **M7 — Verified target expansion**: only after separate actual target execution and evidence.

Milestones describe implementation scope and are not claims of completed tests.

**Phase II exit:** all selected milestone deliverables are implemented to the frozen baseline and can be built/invoked on their declared host. Known deviations and limitations are inventoried. No performance, correctness, security, cross-target or product release claim without Phase III evidence.

## Phase III — Post-implementation tests and measurements (NOT RUN)

Run the pre-authored positive and negative acceptance procedures for the implemented scope. The verification layers in [Verification Plan](../architecture/verification-plan.md) use **V0–V7**, not the milestone M identifiers. Verify schema/parser errors, graph consistency, ABI calls, native runtime, input/accessibility, project recovery, AI sandbox/permission boundaries, provenance and reproduction. Record observed result, exact command, input/output digests, host, target, toolchain, error code, memory/performance numbers and limitations.

**Phase III exit:** explicit evidence ledger for every requirement; no missing test disguised as a pass. Any unsupported or not-run target is declared as such, and blockers to the intended release gate are visible.

## Phase IV — Corrections, contract updates and re-verification (NOT STARTED)

For every failure, link the finding to its architectural requirement, artifact digest and smallest repro. If implementation violates accepted semantics, fix the implementation and rerun the affected and regression checks. If the design itself is wrong, reopen and correct the authoritative specification with architect approval **before** coding the changed behavior. Recompute artifacts and evidence; never silently reuse passing status from an old binary.

**Phase IV exit:** required scenarios on supported targets pass with actual evidence, remaining limitations are explicitly accepted, and the architect decides readiness for alpha/release.

## Current unresolved risks

- First host and native UI/text/IME/accessibility baseline not selected or implemented.
- Canonical graph/workflow/data-flow serialization, strict JSON parser, duplicate keys, lock digests and transaction recovery not accepted.
- Exact event/command grammar, AUI standalone golden source and first ABI byte layouts not frozen.
- Provider authorization and AELYXORA eligibility unverified.
- Source-only Assembly Linux bootstrap is not proof of the Studio, native parser, AUI codegen or on-target hardware behavior.
- Documentation collision found between product G0–G7 and former verification G0–G7; this roadmap now uses M0–M7 and verification uses V0–V7.

The current D2 documentation now includes bounded execution/admission, typed workflow signals, truthful cancellation, command dispatch/ownership, semantic CAS and 18 future runtime acceptance scenarios. **D2 is still Proposed/Open** until P0 cross-contract decisions and explicit architect approval; no runtime results exist. The current additional documentation includes D2 identity/type resolution and D6 proposed canonical encoding/snapshot recovery, with draft HEAD/index schemas and designed hash/fault scenarios. **No implementation or runtime acceptance is implied.** D6 now has proposed exact package content framing, host filesystem adapter capability matrix and codec-only HEAD/snapshot/package hash vectors. **No durable save, package resolver, validator or native test has run.** The next work is **documentation closure**, not coding S0, UI, compiler or AI integration.

**Current documentation review (D2/D6):** [Baseline review and P0 decisions](../architecture/d2-d6-baseline-review.md). Public exported logical contract hashes are now documented separately from source/package bytes; package objects must remain pinned for fully verified snapshot recovery; two HEAD records cannot provide unlimited operationId deduplication. D2/D6 status remains Proposed/Open and does not authorize Phase II implementation.

**Current documentation milestone:** [Linked Pure Reference](../../examples/locked-pure-reference/README.md) demonstrates first-slice package/lock/semantic graph/snapshot byte consistency, and [Offline Resolver](../architecture/d6-offline-dependency-resolution.md) defines deterministic version conflicts and diagnostics. Neither is a native build, executable component ABI implementation or crash-tested durable store. Continue Phase I until all D1–D8 reviewed.

**D3 language documentation milestone:** [L0/L1 Grammar](../architecture/d3-first-language-profile.md), [Type/Core Profile](../architecture/d3-type-and-binding-profile.md), [UI Event and Command Link](../architecture/d3-event-delivery-and-command-linkage.md), [D3 review and remaining P0](../architecture/d3-language-review.md). The [L0](../../examples/aui-language/status-panel-l0.aui) / [L1](../../examples/aui-language/linked-consumer-panel.aui) examples and [28 negative scenarios](../../examples/aui-language/d3-first-profile-negative-cases.json) are designed inputs only. AUI compiler, renderer, D3+ state/data/task grammar, physical ABI and tests remain open. **No new product code or CI.**

**D2 hardware-contract documentation milestone:** [Typed resource claims](../architecture/d2-hardware-resource-contract.md) and [D2↔D3 authority boundary](../architecture/d2-d3-hardware-command-boundary.md) are proposed, including version-gated 0.2-hw-draft schema, illustrative MMIO/IRQ/DMA/memory fixture and 29 design negatives. The existing pure reference/hashes remain untouched; the hardware proposal has **no verified locked source, adapter, native ABI or device tests**. The D1–D8 documentation and human approval gate still blocks product implementation.

**D3+ advanced language documentation:** [L2 State/Derived/Bind](../architecture/d3-state-derived-binding-contract.md), [L3 Task/Result](../architecture/d3-task-result-lifecycle.md) and [source-to-Graph snapshot approval](../architecture/d3-source-snapshot-reconciliation.md) propose typed atomic UI state, one-way keyed bindings, bounded task tickets, exhaustive outcomes and exact source approval boundaries. [L2/L3 design examples](../../examples/aui-language/D3PLUS-README.md) and [31 future scenarios](../../examples/aui-language/d3plus-negative-cases.json) are NOT-RUN. Do not claim AUI runtime, first host ABI, signed source approval or a completed D3 gate; dynamic views, core registry and full D1–D8 design still need architect approval before implementation.

**D3 L4 dynamic-view design milestone:** [Keyed View Lifecycle](../architecture/d3-keyed-dynamic-view-lifecycle.md), [D3/D4/D5 consistency review](../architecture/d3-d4-d5-lifecycle-consistency-review.md), [keyed source + trace](../../examples/aui-language/L4-README.md). The bounded source profile proposes List<T>, StableKey and generation-scoped views. Native ABI, rendering, accessibility/focus, memory budget and provider cancellation proofs are still P0; Stage I docs only.

**D3–D5 architecture documentation:** [D3 Core Registry](../architecture/d3-core-registry-value-contract.md), [D4 Native Value ABI](../architecture/d4-core-value-abi-contract.md), [D5 Resource Budgets](../architecture/d5-ui-resource-budget-and-publication.md) and [12-issue cross-contract review](../architecture/d3-d4-d5-core-contract-review.md) propose exact logical types, separate target ABI proof and a bounded UI-root accounting model. [Registry](../../examples/aui-language/d3-core-registry-proposal.json), [portable key](../../examples/aui-language/d3-core-value-vectors.json) and [memory admission](../../examples/aui-language/d5-budget-reference-vectors.json) fixtures remain non-native design references. Phase I persists; implementation and Phase III tests cannot start before D1–D8 architecture approval.

**D2–D6 Win64-first design milestone:** [Versioned core digests](../architecture/d2-d3-core-export-digest-contract.md), [Win64 call ABI](../architecture/d4-win64-native-component-abi.md), [Win64 module/result descriptors](../architecture/d4-win64-module-and-result-descriptors.md), [Windows host](../architecture/d5-windows-host-runtime-contract.md) and [15-gate baseline review](../architecture/d2-d6-win64-baseline-review.md) propose target-specific native layouts and a signed/admitted execution boundary. Existing D2 v1 identities are unchanged. No Win64 ABI binary, native parser, renderer or on-target validation; the D1–D8 acceptance gate still blocks implementation.

**G1 generic/type migration + Win64 signing/reproducibility architecture:** [Generic type identity](../architecture/d2-d3-generic-instantiation-identity.md), [v1/v2 compatibility](../architecture/d2-d6-core-profile-compatibility.md), [module signature and authorization](../architecture/d4-win64-module-trust-and-admission.md), [reproducible build](../architecture/d6-win64-reproducible-build-contract.md), [cross-D2–D6 review](../architecture/d2-d6-generic-trust-repro-consistency-review.md). Explicit human D1–D8 approval is still required before any Studio implementation or native phase III proof. Source/ABI/Win64 signed loader and deterministic build tests NOT-RUN.
