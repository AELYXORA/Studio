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

**Authority:** [Project Graph](project-graph.md), [Project Graph ↔ AUI](project-graph-aui-contract.md), [Graph Validation](graph-validation-and-migration.md), [Project Format](project-and-package-format.md). **Current status: Proposed/Open.**

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
   
**P0 open:** exact 'hosts' relation; workflow/data-flow serialization; canonical JSON or alternative; required normalization rules; no runnable semantic validation.

## D3 — AUI source language and user-facing declarative semantics

**Authority:** [AUI Syntax](aui-syntax.md), [Event/Binding Semantics](aui-event-binding-semantics.md), [AUI Core Library](aui-core-library.md), [Types and Ownership](aui-types-and-ownership.md). **Current status: Proposed/Open.**

| ID | Required design closure | Evidence fixture |
| --- | --- | --- |
| D3-01 | Complete lexer, Unicode identifiers, grammar/precedence, imports and version syntax | Standalone legal/illegal source; exact lexical error positions |
| D3-02 | Type system: records/enums/generics, values/units, explicit casts, error/result propagation | Exact-type pass; lossy conversion; generic constraint rejection |
| D3-03 | State/derived/effects, event-source attachment and command-implementation linkage | Button event -> handler -> Inspect; unresolved provider |
| D3-04 | Bindings and editing: observable source, one-way presentation, edit intent, writer policy | State -> Text; readonly destination; immediate cycle |
| D3-05 | Task/await, cancellation, ownership transfer across scheduler domains | Legal task; invalid borrow across await; terminal race |
| D3-06 | Dynamic collections, stable view keys, property addressing and child-slot rules | Insert/reorder collection; duplicate key; invalid child |
| D3-07 | Fully linked, **standalone** golden AUI module for first host; imports and providers real within fixture | Parseable event/text/command program, not pseudocode |

**P0 open:** expression grammar/precedence, generics, dynamic identity, provider linkage, full golden fixture.

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

**Authority:** [Project Format](project-and-package-format.md), [Package Resolution](package-resolution-build.md), [Local Build](local-build-verification.md), [Graph Validation](graph-validation-and-migration.md). **Current status: Proposed/Open.**

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

1. **Graph edge taxonomy:** the illustrative sensor project uses the relation kind **hosts**; the normative graph taxonomy lists containment and other edges without specifying 'hosts'. Resolve meaning and validation in Project Graph, schema and fixtures together.
2. **Milestone label collision:** product roadmap G0–G7 and verification plan G0–G7 denote different activities. Use distinct namespaces (recommended product milestones **M0–M7**, test layers **V0–V7**); edit owning files and links consistently.
3. **Documentation versus implementation status:** roadmap/implementation-readiness may call S0 the "next implementation task" while design-gate policy forbids advancing before accepted specs. Present S0 as the **first planned implementation** *after* PHASE I.
4. **JSON example versus canonical representation:** structural JSON Schemas exist, while Project Graph persistence encoding is still an open decision. Avoid calling illustrative format final.
5. **Golden AUI source:** syntax/event examples still depend on unavailable imports, error types and command providers. Require a self-contained proposed module and exact expected semantic trace before gate approval.
6. **Host confusion:** Linux x86-64 lexical experiment is not evidence for proposed Windows x64 native Studio; Linux AArch64 sensor target is not a tested target.
7. **Verification semantics:** a local uncommitted reference checker and the current Assembly delimiter scanner do not constitute an executable native schema or graph validation system.
8. **Provider allowance:** published provider options do not prove AELYXORA registration or eligible subscription-backed inference.
9. **Hardware promises:** graph capabilities and example device nodes do not prove access to devices, interrupts, MMIO or DMA on a physical target.
10. **Runtime dependency promise:** distinguish external runtime frameworks, required OS APIs, system libraries, toolchain inputs and optional explicitly approved libraries.

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
