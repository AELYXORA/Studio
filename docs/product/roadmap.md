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

The current D2 documentation now includes bounded execution/admission, typed workflow signals, truthful cancellation, command dispatch/ownership, semantic CAS and 18 future runtime acceptance scenarios. **D2 is still Proposed/Open** until P0 cross-contract decisions and explicit architect approval; no runtime results exist. The current additional documentation includes D2 identity/type resolution and D6 proposed canonical encoding/snapshot recovery, with draft HEAD/index schemas and designed hash/fault scenarios. **No implementation or runtime acceptance is implied.** The next work is **documentation closure**, not coding S0, UI, compiler or AI integration.
