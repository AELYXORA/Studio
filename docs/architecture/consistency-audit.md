# Architecture Consistency and Completeness Audit

**Status: reviewed design findings, not implementation evidence.** Scope: current Studio architecture specifications and sensor JSON examples. This audit checks conceptual alignment; there is no AUI compiler, schema validator, runtime, renderer, or AI provider integration.

## Confirmed invariants

- The canonical Project Graph owns architecture. Architecture Map, AUI source, inspector, data-flow and AI chat are projections/workflows over it.
- Humans authorize architecture changes; AI generates reviewable proposals and cannot silently execute tools or privileged device operations.
- AUI is a proposed portable declarative language; target-specific Assembly, system ABI and adapters are distinct.
- Pure static components may be specialized; zero-cost is a measurement target rather than a universal guarantee.
- Runtime events, task cancellation, resource ownership and hardware capabilities require explicit contracts.
- Manual local verification only; no CI before release preparation.

## Findings and disposition

| ID | Severity | Issue | Resolution / owner |
| --- | --- | --- | --- |
| C-01 | High | Language principles included a superseded restricted grammar and a second newer grammar, creating competing examples | [D3 First Language Profile](d3-first-language-profile.md) now owns bounded L0/L1 syntax; [AUI Syntax](aui-syntax.md) is a broader D3+ proposal. Earlier illustrative grammar remains non-normative; all require eventual design approval |
| C-02 | Medium | Artificial v0.1 labels persisted after decision to keep architectural specs unversioned | Removed found draft wording in language, library and validation docs. Schema and actual package revisions in fixtures are **compatibility fields**, not product releases; their concrete placeholder values still need a later schema decision |
| C-03 | High | Example package declares Assembly files that do not exist; JSON source manifests therefore cannot be built | Retain as **illustrative design fixtures only**, never runnable demos. Authoritative note: [Project Format](project-and-package-format.md) |
| C-04 | High | Project JSON stores string type names such as RawSample without a canonical type-definition registry; package metadata cannot yet prove type resolution | Define canonical type IDs, package export table, type compatibility and import resolution before calling format accepted |
| C-05 | High | Version resolution calls for lockfile/hash but original sensor example has no lockfile or source bytes, although a separate [locked pure fixture](../../examples/locked-pure-reference/README.md) now includes actual byte-linked package/lock/snapshot references | Add lockfile grammar and digest canonicalization; no reproducible build claim beforehand |
| C-06 | High | Formal structural schemas were originally absent; draft schemas now exist | [Project](../../schemas/project.schema.json) and [package](../../schemas/component-package.schema.json) draft schemas now exist; independent full-schema and semantic validation remain pending |
| C-07 | High | Compiler backend is described as either LLVM IR generation or target Assembly; no chosen bootstrap approach | Resolve explicit compiler implementation language, backend ownership and first OS/ISA using feasibility evidence |
| C-08 | High | Public component ABI descriptor offsets, allocator contract and cancellation atomics remain open | Resolve ABI layouts per target, allocation rules and task race model before binary compatibility claims |
| C-09 | High | UI input/text shaping/accessibility platform dependencies and renderer choices are still open | Specify first host platform and minimal text/graphics strategy with testable acceptance |
| C-10 | High | ChatGPT sign-in via Plus is an experience goal, not a validated authorization method | Keep AI provider boundary independent. Do not treat Plus subscription as arbitrary API access |
| C-11 | Medium | Legacy source remains illustrative; D3 L0/L1 now has an explicit typed event/command design fixture and derived [link-map](../../examples/aui-language/linked-consumer-panel.link.json), but no compiler/runtime proof | Add complete legal source fixture and exact semantic wiring grammar before freezing AUI language |
| C-12 | Medium | Detailed documents overlap on ownership, tasks and platform rules, which risks divergence | Authority map below governs edits; other documents link instead of redefining conflicting semantics |
| C-13 | Medium | Design has no measurable end-to-end UX and performance budget for the map workspace | Define scenario fixtures, acceptance thresholds and source-linked diagnostics before implementation claims |
| C-14 | High | Multi-file project changes have a conceptual journal but no failure/recovery protocol | Specify durable commit state machine, torn-write and migration test cases before persistence implementation |

## Document authority map

| Topic | Authoritative source |
| --- | --- |
| Product invariants and implementation reality | [Architecture README](README.md) |
| Human roles, workflows and palette breadth | [Studio Platform Contract](studio-platform-contract.md) |
| Canonical graph semantics | [Project Graph](project-graph.md) |
| Serialization, dependencies and revisions | [Project and Package Format](project-and-package-format.md), [Validation](graph-validation-and-migration.md) |
| AUI syntax | [AUI Syntax](aui-syntax.md) |
| Visual/nonvisual component semantics | [Component Framework](component-framework.md); [AUI.Core](aui-core-library.md) for builtin signatures |
| AST and name/type/effect checking | [AST and Semantic Analysis](aui-ast-semantic-analysis.md) |
| Ownership, lifetime and transfers | [OwnershipIR](aui-ownership-ir.md) |
| Binary component calling interface | [Component Binary ABI](aui-component-binary-abi.md) |
| Native code lowering | [TargetMIR](aui-targetmir-native-codegen.md) |
| State and task scheduling | [Runtime](aui-runtime.md) |
| OS and hardware boundary | [Platform Services](aui-platform-runtime-services.md), [Hardware Targets](hardware-and-targets.md) |
| Layout and scene generation | [Rendering and Layout](aui-rendering-layout.md) |
| User-facing project editing | [Design-Time Engine](design-time-engine.md) |
| AI scope, proposals, tools and approval | [AI Engineering Workflow](ai-engineering-workflow.md) |

## Required design closure sequence

1. **P0: one executable-by-spec sensor example** with canonical type declarations, locked component contracts, AUI event wiring, targeted source ownership and explicit expected diagnostics.
2. **P0: formal project/package schemas and dependency lock** with correct/incorrect fixtures. Draft identifiers should not be mistaken for release versions.
3. **P0: AUI language freeze criteria** and complete examples for state, binding, event-command bridge and task/await; remove superseded grammar.
4. **P0: public binary ABI and cross-domain ownership** including cancellation race, descriptor size/alignment and resource cleanup.
5. **P1: first platform decision and minimal UI/renderer capability set** supporting map + AI-chat placeholder.
6. **P1: AI authorization feasibility and tool sandbox design**, with offline functionality independent from provider.

## Completion definition

Architecture can be considered coherent when there is one authority for each contract; all illustrative examples agree with it; all hard ambiguities are either resolved or explicitly experimental with acceptance criteria; no cross-document links break; and negative fixtures and local verification methodology are defined. **Passing design review is not the same as proving machine code correctness or production security.**


[Architecture Design Closure — Sensor Slice](architecture-closure.md) defines canonical type IDs, package exports and the end-to-end graph-to-code contract. The sensor fixtures use qualified types. This is a proposed design and has not been run.

**Audit update:** C-04 has a concrete proposed resolution in the closure document and sensor fixtures; it remains unverified until formal schema validation. Other findings remain open unless individually evidenced.


[Manifest Schema and Validation Contract](schema-validation-contract.md) documents the proposed JSON schemas, semantic rules, observed fixture checks and unresolved lockfile requirements. Structural schemas: [project](../../schemas/project.schema.json), [component package](../../schemas/component-package.schema.json).


[Package Resolution and Reproducible Build Contract](package-resolution-build.md) defines offline locked dependency resolution and reproducibility gates. [Lock schema](../../schemas/package-lock.schema.json) and [actual byte-linked documentation fixture](../../examples/locked-pure-reference/README.md) now exist. No runnable native build has been verified.

## D2 design-pass update (proposed)

The [Graph Behavior Contract](graph-behavior-contract.md) proposes an exact interpretation of `hosts` as **physical topology** and models data channels/workflow state transitions using canonical graph IDs. [Project Graph](project-graph.md), [Project Format](project-and-package-format.md), draft [project schema](../../schemas/project.schema.json) and sensor fixtures reflect this candidate. This reduces taxonomy ambiguity **at documentation level only**. The schema cannot prove semantic references, actual command implementation, workflow execution, buffer ownership or D6 crash safety. D2 remains Proposed/Open pending architect review, full fixtures and native validator evidence.

## Identity/persistence documentation update (proposed)

[Identity and Type Resolution](d2-identity-and-type-resolution.md) defines durable IDs versus resolved TypeIDs, AUI symbol IDs and native ABI representations. [D6 Canonical Persistence](d6-canonical-persistence.md) now proposes an explicitly domain-separated semantic hash and two-slot immutable snapshot protocol, with [canonical bytes](../../examples/architecture-sensor/d2-canonical-vectors.json), [schema drafts](../../schemas/project-head.schema.json) and [fault scenarios](../../examples/architecture-sensor/d6-recovery-scenarios.md). This closes **description gaps**, not proof obligations. Still requiring human review: portable ID collision/tombstone import, complete canonical projection, package digest vectors, native fsync/replace guarantees, ABI lowering and provider linkage. Do not call D2/D6 verified.

## D6 package/snapshot consistency (proposed)

[D6 Package Integrity](d6-package-integrity.md) defines length-framed content address for declared manifest/source bytes and strict portable source paths. [D6 Canonical Persistence](d6-canonical-persistence.md) distinguishes snapshot-index and HEAD hash domains, with [codec-only vectors](../../examples/architecture-sensor/d6-integrity-vectors.json). [Filesystem Adapters](d6-filesystem-adapters.md) forbids cross-host durability claims without qualification. Remaining gaps: complete native-build package inventory, contract digest, full snapshot schemas, Windows/NTFS durable HEAD feasibility, and fault-injection evidence. No accepted gate.

## Baseline contradiction register and exported type identity (proposed)

[D2/D6 Baseline Review](d2-d6-baseline-review.md) records the conflict between nominal logical type identity and package source byte digests and its correction in [Export Contract Identity](d2-export-contract-identity.md). The [Export Vectors](../../examples/architecture-sensor/d2-export-contract-vectors.json) have reference SHA-256 arithmetic, while a real graph/package/ABI source linkage remains absent. The HEAD/index now expose an operationId candidate, but two HEAD slots do NOT constitute unlimited durable deduplication; recovered operation history and selected filesystem safety remain unapproved P0 decisions. No gate is Accepted.

## D3 exact first-slice grammar versus broader unaccepted syntax (reviewed in documents only)

The earlier syntax documentation included wide state/task/bind/await rules and positional modifier examples while no exact lexer/compiler existed. [D3 First Language Profile](d3-first-language-profile.md) now proposes the L0/L1 restricted exact source grammar; [D3 Type Rules](d3-type-and-binding-profile.md) and [D3 Event/Linkage](d3-event-delivery-and-command-linkage.md) govern first-slice types, queue/admission and derived graph command link. [D3 Review](d3-language-review.md) records 15 open decisions and distinguishes the [positive source fixtures](../../examples/aui-language/linked-consumer-panel.aui) from [unrun negative scenarios](../../examples/aui-language/d3-first-profile-negative-cases.json). The original audit C-01 description now applies to broad D3+ proposals, not the restricted L0/L1 authority. **These are specification updates, not compiler validation.**

## Hardware resource extension (2026-10-31, P0 still OPEN)

[D2 Resource Model](d2-hardware-resource-contract.md) now proposes a gated schemaVersion 0.2-hw-draft with targetRequirements and MMIO/IRQ/DMA/memory claims tied to canonical resource-access edges. [D2↔D3 Authority](d2-d3-hardware-command-boundary.md) prevents direct UI/device permission inference. [Hardware fixture](../../examples/architecture-sensor/hardware-resource-profile-project.auiproj.json) and [29 design cases](../../examples/architecture-sensor/hardware-resource-negative-cases.json) add cross-owner evidence. Nine structural mutations were rejected in an independent subset checker; twenty semantic/ABI cases are NOT-RUN. This is progress on audit O-01, not architect closure: unresolved adapters, claim tombstone durability, source/ABI, live capability semantics and first physical target remain P0.

## D3+ cross-document consistency — PROPOSED

Broad older AUI state/task/await sketches are now explicitly subordinate to [bounded L2 State/Derived/Bind](d3-state-derived-binding-contract.md) and [L3 Task/Result](d3-task-result-lifecycle.md) proposals. L1 send remains request-only; L2 UI StateRevision is separate from D2 GraphRevision; L3 one-active TaskSlot/TaskTicket is separate from D2 CommandTicket; a cancel request cannot publish Cancelled without provider quiescence. [Source/snapshot reconciliation](d3-source-snapshot-reconciliation.md) prevents unapproved source-link data from being treated as executable permission. [24 source/review + 7 runtime design cases](../../examples/aui-language/d3plus-negative-cases.json) are NOT-RUN; dynamic children, core registry, actual source approvals/ABI/renderer and native race tests remain P0.
