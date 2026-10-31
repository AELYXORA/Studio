# AELYXORA — Specification Completion Matrix

**Status: proposed review tracker; no gate accepted by this document.** Last repository baseline reviewed: 2026-10-30, main at 4ea0d200. This matrix is a **navigation and closure ledger**, not a duplicate specification. Detailed semantics belong to each listed owning document. A requirement becomes **Accepted** only after an explicit human architecture decision recorded in the owning document. "Verified" is reserved for later observed evidence.

## Purpose and sequencing

AELYXORA follows four explicit phases, not an indefinite alternation of prose and implementation:

- **PHASE I — DESIGN:** complete the finite specification baseline, examples, state machines, error semantics, target assumptions and future acceptance procedures. Conduct human architecture review and mark each in-scope gate Accepted. No product source implementation. Research-only experiments are exceptions requiring explicit scope and no production acceptance claim.
- **PHASE II — IMPLEMENTATION:** implement the accepted baseline in ordered vertical slices. Do not silently reinterpret a contract. Proposed architecture changes return to the design review before inclusion.
- **PHASE III — TEST / MEASURE:** execute all specified positive, negative, integration, ABI, security, recovery and performance scenarios on actual supported hosts/targets; record exact commands, observed outputs, artifact hashes and limitations.
- **PHASE IV — CORRECTION / RE-VERIFICATION:** fix defects against the same contracts, re-run failed and regression tests, or formally reopen an incorrect requirement. A fix cannot be declared successful without renewed observed evidence.

Specifications of tests are **design deliverables**. Passing test results are **post-implementation deliverables**. The current ASM lexical preflight is an isolated historical experiment, not proof of PHASE II or III completion.

## Gate closure criteria applied to D1–D8

For every in-scope item below, reviewers must find:
1. One authoritative document and unambiguous terms/IDs.
2. Preconditions, invariants, full input/output contracts, state transitions and explicit failure behavior.
3. Positive **and** negative concrete fixtures with expected outcomes and diagnostic codes.
4. Platform, capability, trust, ownership and failure boundaries where relevant.
5. Explicit rejected alternatives/tradeoffs for decisions that materially affect implementation.
6. Future acceptance procedure: command/action, expected result, artifact/environment fields and performance budget if applicable.
7. Cross-references agree; no conflicting normative rule survives.
8. Explicit architect decision: Accepted, Rejected or bounded Deferred with rationale, impact and gate dependency. Critical P0 decisions cannot be silently Deferred.
   
If a requirement lacks any material element above, it remains **Open**. A document's completeness does not imply runtime correctness.

## D1 — Product and user workflows

**Authority:** [Architecture](README.md), [Studio Platform](studio-platform-contract.md), [Workspace](workspace.md), [Architecture-to-Execution Contract](architecture-to-execution-contract.md). **Current status: Proposed/Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D1-01 | Architecture-first RAD scope, architecture/workflow/data-flow/AI/UI priorities, supported kinds of output | Create system with UI; create headless system; choose unsupported target |
| D1-02 | Roles and permissions: human architect, AI implementer, validator and physical-device operator | AI code suggestion versus user approval versus actual execution |
| D1-03 | Architecture Map navigation, large graphs, contextual selection and immutable semantic IDs | Select/filter/rearrange; semantic digest unchanged on view-only move |
| D1-04 | Contextual chat disclosure, proposal visualization, diff/impact inspection, offline state | Partial context selection; offline; revoked consent; reject proposal |
| D1-05 | End-to-end UX: new/open/edit/connect/review/save/reopen/undo/recovery | Valid edit, invalid edge, stale revision, crash-reopen scenarios |
| D1-06 | Accessibility and keyboard paths to essential architecture operations; error/empty/loading states | Keyboard create/connect/inspect; inaccessible presentation negative case |
| D1-07 | Definition of rapid iteration and metrics for idea-to-verified-native-result | Measurable acceptance workflow, not an asserted time-saving percentage |

**P0 open:** architect confirmation of product scope and priorities; first supported host/target UX assumptions.

## D2 — Canonical Project Graph, workflows and data flows

**Authority:** [Project Graph](project-graph.md), [D2 Identity and Type Resolution](d2-identity-and-type-resolution.md), [Graph Behavior — Workflows and Data Flows](graph-behavior-contract.md), [D2 Execution and Consistency](d2-execution-consistency.md), [Project Graph ↔ AUI](project-graph-aui-contract.md), [Graph Validation](graph-validation-and-migration.md), [Project Format](project-and-package-format.md). **Current status: Proposed/Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D2-01 | Node, edge and stable identity taxonomy; qualified TypeIDs; duplicate and normalization policy | Canonical sensor graph; duplicate ID; normalized collision |
| D2-02 | Exact allowed edge kinds and endpoint constraints, including whether 'hosts' is normative | Valid containment/hosts; unknown edge kind; wrong endpoints |
| D2-03 | Component contract schema: ports, errors, effects, targets, ABI, ownership and source identity | Resolve matching export; reject missing export/port and contract drift |
| D2-04 | **Workflow model** referencing graph IDs: triggers, guards, transitions, terminals, concurrency, retries, compensation | Inspect command success/failure/timeout/cancel; forbidden effect |
| D2-05 | **Data-flow model** referencing graph IDs: type/unit, publisher, consumer, capacity, scheduling, backpressure and snapshots | Sensor stream; wrong type; duplicated writer; unbounded stream |
| D2-06 | Resource and hardware claim semantics: MMIO, DMA, IRQ, privilege, concurrency and platform capabilities | Overlap/exclusivity; unsupported address or permission |
| D2-07 | Graph versus view digests, source reconciliation, revisions, transactions and undo/conflict semantics | Move map node only; source-only change; stale graph edit |
| D2-08 | Schema evolution and unknown field policy, stable migration identity and no silent lossy changes | Upgrade valid manifest; reject unknown required schema |
| D2-09 | Deterministic diagnostics with code, graph ID, target, source/path, actual/expected values | Compare expected failures and diagnostic ordering |
| D2-10 | Package resolution and exact type/export identity across source and graph | Correctly pinned export; missing lock; duplicate export |
   
**P0 open:** 'hosts' and stable IDs remain architect-unaccepted; candidate JSON now includes bounded per-instance FIFO, typed signals and staged cancellation semantics. D2 Execution and Consistency proposes dispatch/ownership and CAS rules, but exact native ABI atomics, target resource budgets, canonical hashes, durable journal and full provider linkage remain unresolved. No D2 gate is accepted; no native semantic or runtime verification is claimed.

## D3 — AUI source language and user-facing declarative semantics

**Authority:** [D3 First Language Profile L0/L1](d3-first-language-profile.md), [D3 Type/Binding Profile](d3-type-and-binding-profile.md), [D3 Event Delivery and Command Linkage](d3-event-delivery-and-command-linkage.md), [D3 Language Review](d3-language-review.md), with broader unaccepted D3+ designs in [AUI Syntax](aui-syntax.md), [AUI Core Library](aui-core-library.md), and [Types/Ownership](aui-types-and-ownership.md). **Current status: Proposed/Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D3-01 | Complete lexer, Unicode identifiers, grammar/precedence, imports and version syntax | Standalone legal/illegal source; exact lexical error positions |
| D3-02 | Type system: records/enums/generics, values/units, explicit casts, error/result propagation | Exact-type pass; lossy conversion; generic constraint rejection |
| D3-03 | State/derived/effects, event-source attachment and command-implementation linkage | Button event -> handler -> Inspect; unresolved provider |
| D3-04 | Bindings and editing: observable source, one-way presentation, edit intent, writer policy | State -> Text; readonly destination; immediate cycle |
| D3-05 | Task/await, cancellation, ownership transfer across scheduler domains | Legal task; invalid borrow across await; terminal race |
| D3-06 | Dynamic collections, stable view keys, property addressing and child-slot rules | Insert/reorder collection; duplicate key; invalid child |
| D3-07 | Fully linked, **standalone** golden AUI module for first host; imports and providers real within fixture | Parseable event/text/command program, not pseudocode |

**P0 open:** the first L0/L1 subset has a proposed restricted grammar and event/command link map, but D3+ general expression grammar, state/derived/bind/tasks, generics, dynamic identity, final core registry and ABI, provider approval, byte-spanned compiler golden output and full executable fixture remain unaccepted. See [15 D3 review decisions](d3-language-review.md).

## D4 — Compiler, intermediate representations and binary ABI

**Authority:** [AST and Semantic Analysis](aui-ast-semantic-analysis.md), [OwnershipIR](aui-ownership-ir.md), [TargetMIR](aui-targetmir-native-codegen.md), [IR Layout](aui-ir-layout.md), [Binary ABI](aui-component-binary-abi.md). **Current status: Proposed/Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D4-01 | Lossless CST -> AST -> TypedHIR invariants and deterministic diagnostics | Legal source trace and rejected unresolved/illegal-effect trace |
| D4-02 | OwnershipIR/control flow: moved/borrowed values, cleanup, device lifetime and async races | Borrow across await, once-only release, cancellation race |
| D4-03 | TargetMIR operations, lowering, register allocation strategy and instruction selection | One function from AUI to target ABI with expected machine effects |
| D4-04 | Exact first-host ABI: descriptor offsets, alignment, allocator, call frame, error and symbol representation | Byte-layout vectors, ABI conformance cases, unsupported ABI |
| D4-05 | Object/assembler/linker/unwind/source map contracts and hermetic tooling assumptions | Host toolchain plan and cross-target non-execution warnings |
| D4-06 | Meaning and limits of no-unnecessary-runtime-dependency; baseline comparisons | Declared dynamic libraries and build-only dependencies |
| D4-07 | Optimizations preserve MMIO/atomic/volatile/effect barriers and graph origins | Negative reorder cases; disassembly comparison procedure |

**P0 open:** real descriptor layouts; backend selection; native codegen proof; first host/ABI selection.

## D5 — Runtime, native window, input, text and presentation

**Authority:** [Runtime](aui-runtime.md), [Rendering](aui-rendering-layout.md), [Platform Services](aui-platform-runtime-services.md), [Component Framework](component-framework.md), [Design-Time Engine](design-time-engine.md). **Current status: Proposed/Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D5-01 | State/revision commit, event loop order, task scheduling/affinity, backpressure and reentrancy | Event -> command -> worker -> state -> frame and failure |
| D5-02 | Window/lifecycle and platform adapter contract; thread and resource cleanup | Open/close/resize, late callback, invalid resource handle |
| D5-03 | Layout, scene/display lists, text shaping/IME, hit testing, input, accessibility | Render Text/Button; focus; unicode text; screen-reader semantics |
| D5-04 | GPU/CPU fallback, unsupported capability and device APIs without silent success | No GPU adapter; denied device; unavailable text service |
| D5-05 | Architecture Map and disconnected contextual chat rendered from validated graph | Select component, inspect contract, navigate/reopen |
| D5-06 | Performance budgets expressed as selected-host measurable scenarios | Latency/memory/large-map fixtures with no unverified promises |

**P0 open:** host native platform API, renderer/text/IME/accessibility strategy, event/frame sequence.

## D6 — Formats, package resolution, local build and persistence

**Authority:** [Project Format](project-and-package-format.md), [D6 Canonical Persistence](d6-canonical-persistence.md), [Package Resolution](package-resolution-build.md), [Local Build](local-build-verification.md), [Graph Validation](graph-validation-and-migration.md). **Current status: Proposed/Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D6-01 | Canonical project format, strict parsing, duplicate keys, size/depth limits | Positive/invalid JSON and unsupported schema vectors |
| D6-02 | Exact manifest/package content digest, canonical serialization and lockfile identity | Reference hash vectors, path collision and tamper negative |
| D6-03 | Cross-file atomicity, journal states, crash recovery and revision preconditions | Simulated crash at every durable state; byte-preserving rollback |
| D6-04 | Dependency isolation, path/symlink escape and capability manifest validation | Reject traversal, stale hash and unapproved dependency |
| D6-05 | Build DAG, cache invalidation, deterministic tool identity, cancellation and staging | Modified one component; changed toolchain flags; cancel during link |
| D6-06 | Evidence schema and data retention/redaction; reproducible inputs versus output bytes | Same inputs and isolated rebuild; identify nondeterminism |
| D6-07 | Local build on chosen host with no Python, no CI before release preparation | Manual exact commands specified; execution remains not-run |

**P0 open:** canonical hashes, full parser contract, journal state machine, linker/toolchain baseline.

## D7 — AI engineering, connection, tool permissions and privacy

**Authority:** [AI Role](ai-role-contract.md), [AI Engineering Workflow](ai-engineering-workflow.md), [ChatGPT Connection](chatgpt-connection.md), [Security](extension-and-security.md). **Current status: Proposed/Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D7-01 | Official provider authorization viability and disconnected-mode obligations | Signed in without inference scope; denied/expired/revoked |
| D7-02 | Exact consented context manifest, secret exclusion, send provenance | Selected driver scope, unrelated private file rejection |
| D7-03 | Machine-validated proposal schema, scope, graph/source diff, revision and source ownership | Valid driver patch, out-of-scope change, stale revision |
| D7-04 | Separation of draft, approval, local tool invocation, privileged effect and evidence | No implicit build, network or device action after model output |
| D7-05 | Threat model: prompt injection, generated native code, external dependencies, token storage | Malicious source comments; attempted privileged operation |
| D7-06 | Offline manual proposal handling; transparent errors without paid API fallback | No credentials/allowance; no unexpected billing |
| D7-07 | AI may be primary implementation producer, but never self-certify architecture or test results | AI says 'passed' without execution -> still not-run |

**P0 open:** app eligibility for official provider flow, native OAuth adapter, proposal JSON schema and OS sandbox threat controls.

## D8 — Cross-document integration, release of specification baseline

**Authority:** [Architecture](README.md), [Design Gates](design-completion-gates.md), [Consistency Audit](consistency-audit.md), [Architecture Closure](architecture-closure.md). **Current status: Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D8-01 | All D1–D7 in-scope requirement IDs map to one owning accepted spec | Traceability table; no unsupported orphaned requirement |
| D8-02 | Full sensor **architecture -> workflow -> data flow -> AI proposal -> AUI/ASM -> build evidence** design trace | Positive and negative scenario document with exact expected states |
| D8-03 | No conflicting grammar, edge kinds, revision terms, supported targets, milestone labels | Cross-document contradiction and broken-link review |
| D8-04 | First host/target and implementation slices S0–S4 sized against accepted contracts | Target capability matrix, dependency graph, slice exit criteria |
| D8-05 | Security, recovery, failure and performance unknowns are closed or bounded as non-blocking | Risk register with architect-approved acceptance/deferral |
| D8-06 | Human architect explicitly signs off the frozen baseline scope | Review decision record with date, baseline commit and open follow-ups |

**P0 open:** every required upstream gate remains unaccepted, so **D8 cannot pass**.

## Concrete contradictions to reconcile in owning specs

These are review findings, not silently resolved decisions:

1. **Graph edge taxonomy:** the sensor's **hosts** now has proposed physical-topology semantics in the Project Graph and the candidate schema/fixtures. Verify all consumers and architect-approve the definition; no implementation evidence exists.
2. **Milestone label collision:** product roadmap G0–G7 and verification plan G0–G7 denote different activities. Use distinct namespaces (recommended product milestones **M0–M7**, test layers **V0–V7**); edit owning files and links consistently.
3. **Documentation versus implementation status:** roadmap/implementation-readiness may call S0 the "next implementation task" while design-gate policy forbids advancing before accepted specs. Present S0 as the **first planned implementation** *after* PHASE I.
4. **JSON example versus canonical representation:** structural JSON Schemas exist, while Project Graph persistence encoding is still an open decision. Avoid calling illustrative format final.
5. **Golden AUI source:** syntax/event examples still depend on unavailable imports, error types and command providers. Require a self-contained proposed module and exact expected semantic trace before gate approval.
6. **Host confusion:** Linux x86-64 lexical experiment is not evidence for proposed Windows x64 native Studio; Linux AArch64 sensor target is not a tested target.
7. **Verification semantics:** a local uncommitted reference checker and the current Assembly delimiter scanner do not constitute an executable native schema or graph validation system.
8. **Provider allowance:** published provider options do not prove AELYXORA registration or eligible subscription-backed inference.
9. **Hardware promises:** graph capabilities and example device nodes do not prove access to devices, interrupts, MMIO or DMA on a physical target.
10. **Runtime dependency promise:** distinguish external runtime frameworks, required OS APIs, system libraries, toolchain inputs and optional explicitly approved libraries.

## D2/D6 baseline review register — explicit sign-off pending

[Baseline Review](d2-d6-baseline-review.md) separates resolved *documentation contradictions* from fifteen remaining first-slice decisions. [Export Contract Identity](d2-export-contract-identity.md) corrects semantic graph identity to ignore implementation-only source-byte changes. [Export Contract Vectors](../../examples/architecture-sensor/d2-export-contract-vectors.json) and updated [D6 Integrity Vectors](../../examples/architecture-sensor/d6-integrity-vectors.json) are reference calculations, **not native test results**. Both D2 and D6 remain Proposed/Open pending full fixture coverage, architect approval, and later native verification.

## How to close a requirement

For each ID: write/update the **owning existing document**, add fixtures, reconcile all consumers, fill expected diagnostics and future test cases, then request architect acceptance. Mark tracker status only after the owning spec records approval. Never treat a Git commit, AI review or design checklist as automatic approval.

### Design review record template

~~~text
Requirement IDs:
Owning spec and revision:
Decision: Accepted | Rejected | Deferred | Open
Approved scope and target assumptions:
Required invariants / contracts:
Positive design fixtures:
Negative design fixtures and expected diagnostic codes:
Security / failure / rollback cases:
Alternatives and rationale:
Known limits or bounded deferrals:
Future implementation milestone:
Future test procedure and evidence:
Architect acceptance (explicit) and date:
~~~

No sign-off is recorded yet. Until the user accepts the relevant baseline, the project remains PHASE I — DESIGN.

## D2 documentation pass (proposal, not gate completion)

The [Graph Behavior Contract](graph-behavior-contract.md) now gives proposed definitions of workflow state machines, typed channel bindings, ownership, overflow, diagnostic precedence, graph revision isolation and topology edge kinds. The example sensor project/package and JSON Schemas were extended with draft `workflows`, `dataFlows` and `commands`; [D2 invalid cases](../../examples/architecture-sensor/d2-invalid-cases.json) specify expected diagnostics. **These are not accepted or native-validated.** Pending architecture decisions and later phase-dependent tests remain listed under D2 and the owning specifications.

**D2 pass update (2026-10-30):** [Execution and Consistency](d2-execution-consistency.md) proposes ordering, bounded admission, command tickets, cancellation, ownership and graph CAS. The [sensor runtime test design](../../examples/architecture-sensor/d2-runtime-scenarios.md) contains 18 expected scenarios, all **NOT-RUN**. These are design artifacts, not sign-off.

## D2/D6 identity-and-persistence design pass (proposed, not accepted)

[D2 Identity and Type Resolution](d2-identity-and-type-resolution.md) now proposes persistent ASCII graph IDs, a retired-identity ledger, exact nominal TypeID resolution through pinned package exports and explicit source/graph/ABI identity separation. [D6 Canonical Persistence](d6-canonical-persistence.md) proposes deterministic UTF-8 semantic encoding, separate graph/source/package/snapshot digests and immutable snapshots with two HEAD records. Draft [canonical vectors](../../examples/architecture-sensor/d2-canonical-vectors.json) contain four expected SHA-256 values; [HEAD](../../schemas/project-head.schema.json) and [snapshot-index](../../schemas/project-snapshot-index.schema.json) schemas describe candidate structures; [30 recovery scenarios](../../examples/architecture-sensor/d6-recovery-scenarios.md) define future fault injection. **No D2/D6 gate accepted; no native codec, recovery or ABI proof.** Remaining P0: complete semantic projection field coverage, canonical package framing and digests, full retired-ID migration, first host filesystem durability, conflict handling and target ABI layouts.

## D6 detailed contract pass (proposed, not accepted)

[D6 Package Integrity](d6-package-integrity.md) defines candidate exact BE64 framed SHA-256 for canonical manifest and declared source bytes; [integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json) provide positive and mutated raw bytes plus expected package/snapshot/HEAD digests. [D6 Filesystem Adapters](d6-filesystem-adapters.md) records separate Windows/Linux atomicity, file flushing and recovery preconditions and qualification gaps. This eliminates *some* specification ambiguity but does not freeze target filesystems or guarantee crash safety. **D6 stays Proposed/Open** pending full production-valid lock/index vectors, schema completeness, host-specific feasibility, signed design review and later observed fault injection.

## D2/D6 byte-linked reference and resolver design pass (Proposed)

[Canonical Semantic Projection](d2-d6-semantic-projection.md) provides field-by-field digest input, excluding implementation bytes. [Offline Dependency Resolver](d6-offline-dependency-resolution.md) defines one exact package version per packageId, closure, source-object integrity, export digest and failure ordering. [Locked Pure Reference](../../examples/locked-pure-reference/README.md) contains actual **reference** Assembly bytes (not a verified AELYXORA ABI implementation), package manifest, semantic project, lock, snapshot, HEAD and [negative fixtures](../../examples/locked-pure-reference/negative-cases.json). This is a design baseline candidate, **NOT a native result, sign-off or successful build**. Full primitive core type system, D4 ABI and selected first-host durability remain P0.

## D3 first-slice language documentation pass (PROPOSED, NOT ACCEPTED)

[First Language Profile](d3-first-language-profile.md) defines strict UTF-8/NFC lexing, explicit imports, named-only arguments and L0/L1 grammar. [D3 Types/Bindings](d3-type-and-binding-profile.md) proposes pinned aui.core, nominal type and property/effect checks. [D3 Event Delivery](d3-event-delivery-and-command-linkage.md) defines one-handler bounded UI event admission, stale-generation handling and a separate source-to-graph [link-map schema](../../schemas/aui-command-link.schema.json). Two positive [L0](../../examples/aui-language/status-panel-l0.aui) and [L1](../../examples/aui-language/linked-consumer-panel.aui) source examples, [proposed link map](../../examples/aui-language/linked-consumer-panel.link.json), and [28 expected negative cases](../../examples/aui-language/d3-first-profile-negative-cases.json) exist. [D3 Review](d3-language-review.md) records fifteen P0 decisions. All native parser/renderer/runtime tests NOT-RUN and no product source implementation authorized.

## Cross-specification findings and disposition (2026-10-31)

[Cross-Specification Audit](cross-specification-audit-2026-10-31.md) checked 71 Markdown files and 657 relative internal links (zero missing targets), reconciled ten documentation-level inconsistencies, and lists fourteen unresolved D1–D8 design blockers/risks. The most material corrected ambiguities: no Phase II S0 before full design approval; exact offline lock/export resolution **before** typed Project Graph references; asynchronous stream/snapshot borrowing rejected in first D2 profile; package-object versus export-digest equality; exact version strings and stable error codes. **D1–D8 remain Proposed/Open, native tests NOT-RUN, human acceptance absent.**

## D2 hardware resources — targeted P0 design work (NOT ACCEPTED)

[Typed Resource Contract](d2-hardware-resource-contract.md) proposes schemaVersion 0.2-hw-draft with required resourceModel target requirements and scoped MMIO/IRQ/DMA/memory claims. [Project Schema](../../schemas/project.schema.json) permits the new profile while keeping existing 0.1-draft pure graphs/resource digests unchanged. A separate [hardware sensor fixture](../../examples/architecture-sensor/hardware-resource-profile-project.auiproj.json) is syntactically shaped but **not package/target-adapter linked**. [29 negative design cases](../../examples/architecture-sensor/hardware-resource-negative-cases.json) include 9 structural mutations observed rejected by an independent limited JS checker, 20 unrun semantic/target/projection scenarios. See [D2↔D3 Authority](d2-d3-hardware-command-boundary.md): no native device access from AUI. **Remaining P0:** accepted target feature/adapter registries, actual memory/IRQ/DMA proof, source/ABI and capability linkage, immutable hardware source/lock fixture, full native/OS/physical tests and architect approval. D2, D3, D4, D5 and D6 remain Open.

## D3+ State, Derived, Bind, Task/await and Result — design pass

[D3 L2](d3-state-derived-binding-contract.md) now proposes one owner per UI state slot, typed derived DAG, explicit static-key one-way binding and atomic UI StateRevision; [D3 L3](d3-task-result-lifecycle.md) proposes a bounded one-active TaskSlot, one provider await, five exhaustive TaskOutcome variants, cancellation as a request and view-generation isolation. [D3 Source/Snapshot](d3-source-snapshot-reconciliation.md) defines proposed exact source-profile/bundle/lock/Graph linking and separates cryptographically verified human approval from a text status field; [schema](../../schemas/aui-source-link-bundle.schema.json). [L2/L3 source fixtures](../../examples/aui-language/D3PLUS-README.md) and [24 source/review and 7 runtime design cases](../../examples/aui-language/d3plus-negative-cases.json) are NOT-RUN. **D3 P0 still OPEN** for full advanced grammar, core/ABI, dynamic keyed children, real approval and runtime/Phase III evidence. L0/L1 remain unchanged and do not admit these extensions.

## D3 L4 dynamic keyed view and D4/D5 lifecycle integration — proposed

[Keyed Dynamic View Contract](d3-keyed-dynamic-view-lifecycle.md) proposes aui.source/l4-keyed/v1 ForEach over bounded immutable List<T>, explicit StableKey, source TemplateSymbolID, deterministic same-parent reorder preservation and fresh generation on remove/reinsert or reparent. [D3/D4/D5 Lifecycle Review](d3-d4-d5-lifecycle-consistency-review.md) defines 12 cross-owner risks: task/result subscriptions, ABA-safe native handles, provider buffer retention, renderer focus/IME/accessibility and fail-closed candidate reconciliation. [Keyed view design fixture and reference trace](../../examples/aui-language/L4-README.md) plus [40 source/runtime test design cases](../../examples/aui-language/l4-negative-cases.json) are **not AELYXORA runtime results**. [L4 template source registry schema](../../schemas/aui-source-link-bundle.schema.json) requires exact source identity/approval; source manifest, native ABI, first host, target renderer and proof remain OPEN. Earlier L0–L3 profile inputs/hashes are unchanged. D1–D8 still await human acceptance.

## D3 L4 keyed dynamic views / D4 and D5 lifecycle — PROPOSED

[Keyed Dynamic View Contract](d3-keyed-dynamic-view-lifecycle.md) proposes aui.source/l4-keyed/v1 ForEach with explicit tagged StableKey, stable source TemplateSymbolID, same-parent reorder preservation, fresh generation on reparent/remove/reinsert, and bounded fail-closed reconciliation. [D3/D4/D5 Lifecycle Review](d3-d4-d5-lifecycle-consistency-review.md) records 12 native/rendering interface risks, including event/TaskTicket subscription identity, callback drain, ownership and focus/IME accessibility. [L4 fixture and 12-step reference trace](../../examples/aui-language/L4-README.md), plus [40 source/runtime design cases](../../examples/aui-language/l4-negative-cases.json), have no AELYXORA native test evidence. [Source-link schema](../../schemas/aui-source-link-bundle.schema.json) now requires keyed template entries for L4 sources. The List/StableKey core types, ABI, native memory ordering, renderer, source approval and architect sign-off remain P0. L0-L3 remain unchanged; D1-D8 Open.

## D3/D4/D5 core type and first-host UI budget candidate — NOT ACCEPTED

[D3 Core Registry](d3-core-registry-value-contract.md) separates existing first-slice Unit/Bool/U32/String/Event/Result from proposed U64/List/StableKey/StateRevision/TaskOutcome/TaskSlot/TaskTicket. [Structural registry inventory](../../schemas/aui-core-registry-proposal.schema.json) with [13 proposed entries](../../examples/aui-language/d3-core-registry-proposal.json) deliberately has **no export-contract hashes or approved ABI layouts**. [D4 ABI](d4-core-value-abi-contract.md) requires separate Win64/SysV physical proofs. [D5 Runtime Budget](d5-ui-resource-budget-and-publication.md) proposes simultaneous count/byte limits, 160 MiB total candidate per-root heap allocation, source-sensitive generation safety and atomic UI state/tree publication distinct from frame present; OS/GPU/device quotas remain separate. [9 valid/8 invalid StableKey vectors](../../examples/aui-language/d3-core-value-vectors.json) and [16 resource boundary cases](../../examples/aui-language/d5-budget-reference-vectors.json) are standalone arithmetic, NOT native AELYXORA observations. [D3/D4/D5 core review](d3-d4-d5-core-contract-review.md) lists 12 P0/P1 findings; D3/D4/D5 and entire D1-D8 architecture remain Open.
