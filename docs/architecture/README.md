# AELYXORA Studio — Architecture

**Current policy:** complete and review design before further implementation. [Design gates](design-completion-gates.md) establish acceptance; [official ChatGPT Plus integration contract](chatgpt-connection.md) addresses user consent, eligible allowance and offline operation.

**Current implementation status:** [verified artifacts, missing components and authoritative milestones](PROJECT-STATUS.md).

**Product invariant:** the primary UI is one interactive **Architecture Project Map + contextual AI Chat** for designing and implementing **software close to hardware**. A form designer, file explorer and code editor are subordinate views.

## D2/D6 exact projection and linked reference — proposed

[Exact Semantic Graph Projection](d2-d6-semantic-projection.md) and [Offline Dependency Closure](d6-offline-dependency-resolution.md) now govern the candidate digest/lock pipeline. The [Locked Pure Reference](../../examples/locked-pure-reference/README.md) supplies real reference ASM bytes and an internally cross-linked project, lock and immutable snapshot for future validation tests. Its source bytes are **not** a compiled AELYXORA component ABI or runtime success.

## D2/D6 baseline consistency review — proposed

[Contradiction and decision register](d2-d6-baseline-review.md) now tracks the integrated architecture-to-storage boundary, remaining P0 choices and acceptance criteria. [Logical Export Contract Identity](d2-export-contract-identity.md) explains why changing ASM source bytes can invalidate a package/build without changing semantic architecture. [Export Reference Vectors](../../examples/architecture-sensor/d2-export-contract-vectors.json) distinguish those digests. D2/D6 have NOT been approved or implemented.

## D6 package integrity and filesystem guarantees — proposed

[Package Integrity](d6-package-integrity.md) defines exact first-profile package inventory, path safety, digest framing and lock boundary. [Filesystem Adapters](d6-filesystem-adapters.md) identifies unsupported and unverified host durability claims on Windows and Linux. [Integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json) are codec-only, not a native build or proven crash recovery. No additional implementation has begun.

## D2 identity and D6 persistence — proposed

[Persistent identities and nominal TypeID resolution](d2-identity-and-type-resolution.md) establishes the candidate first-slice ID/type policies and explicit Graph/AUI/native ABI identity boundaries. [Canonical snapshot and crash recovery design](d6-canonical-persistence.md) specifies candidate UTF-8 encoding, semantic/source/package digests, immutable revision publication and recovery checks. [Byte/hash vectors](../../examples/architecture-sensor/d2-canonical-vectors.json) and [recovery scenarios](../../examples/architecture-sensor/d6-recovery-scenarios.md) are documentation artifacts only; no native implementation/tests exist.

## D2 execution and consistency — proposed

[Concurrency, Command Dispatch, Resource Ownership and Transaction Semantics](d2-execution-consistency.md) defines the bounded single-process execution policy, typed signals, cancellation/completion races, safe ownership transfer and separated graph/runtime/external-effect transaction boundaries. [Sensor D2 runtime scenarios](../../examples/architecture-sensor/d2-runtime-scenarios.md) cover 18 designed future tests, all NOT-RUN. The Studio runtime and graph validator do not yet exist.

## D2 architecture behavior design — proposed

[Workflow and Data Flow Semantics](graph-behavior-contract.md) formalizes the D2 design candidate: explicit state-machine workflows, bounded typed channels, source/target ownership, event-to-command boundaries, and invariant-preserving graph revisions. Draft [sensor fixtures](../../examples/architecture-sensor/project.auiproj.json) and [negative behavior cases](../../examples/architecture-sensor/d2-invalid-cases.json) are **documentation-stage artifacts, not a runnable graph engine**. Owning contracts remain proposed pending architect sign-off.

## Product doctrine — architecture-first RAD

**Confirmed product intent:** AELYXORA is RAD for an AI-native development workflow: the human architects the system; AI primarily implements the components and their native code. Success means the shortest **architectural idea -> approved contracts -> native implementation -> verified result** loop, not faster manual coding or visual placement of widgets.

**Priority is Architecture -> Workflows -> Data Flows -> AI implementation -> Verification -> UX/declarative UI.** Workflow/data-flow diagrams must be typed semantic projections of one canonical Project Graph, not independently authoritative pictures. Declarative AUI and interactive preview matter for software that needs UI, but are secondary to the architecture. Headless applications, services, libraries and hardware-oriented systems must remain first-class.

**Implementation constraints remain Assembly-first and framework-free at runtime**, with platform-native APIs and target-specific adapters explicitly declared; the Clang/LLVM build toolchain is not a required target-application runtime framework. No claim of binary portability, zero-cost abstraction or total absence of OS dependencies is permitted without per-target verification.

**Process is sequential:** complete and approve the full in-scope specification baseline; then implement; then execute the prescribed tests and measurements; then correct and re-verify. Design fixtures and expected diagnostic outcomes are authored in the documentation phase but not presented as executed tests. The [Architecture-to-Execution Contract](architecture-to-execution-contract.md) is a proposed end-to-end design trace and the [Specification Completion Matrix](specification-completion-matrix.md) tracks remaining D1–D8 closure work. Neither document automatically closes a gate.

## Experience

- **Center: live architecture graph.** Modules, components, interfaces, devices and runtime services are typed nodes; dependencies, data/control flows and resource ownership are typed edges. Mind-map ergonomics, UML-level precision. Zoom, groups, navigation and selection are map affordances, not architecture truth.
- **Side: AI chat.** Chat is dockable and grounded in the user's explicitly selected node or subgraph. The UI shows exactly which contracts, code and diagnostics would be sent. AI proposes a change set; an architectural/source diff and verification precede human approval.
- **Details on demand.** Component contracts, Assembly source, registers, test evidence, declarative UI and debugging views open from map nodes. No disconnected secondary source of truth.
- **Human architect / AI implementer.** Human owns boundaries, semantics and approval; AI predominantly writes and tests components, not silently restructures the graph.

## Hardware-aware project graph

Each node can carry target triples, ISA extensions, ABI/calling convention, execution context (user/kernel/firmware), hardware capabilities, memory ownership/alignment, resource ranges, thread/interrupt constraints, and supported toolchains. Explicit graph kinds include **CPU/SoC, device, bus, driver, firmware interface, protocol, runtime service, component and external dependency**. Typed edges may express **calls, events/interrupts, data flow, MMIO/I/O access, DMA ownership, protocol and dependency**.

Hardware constraints are **optional typed capabilities**, not clutter on every node. Hard gating matters: an unsafe or unsupported IRQ/MMIO/DMA operation must not be inferred from an attractive diagram. Require target-specific tests; on-device debug and physical access are later capabilities.

## System boundaries

```text
     Interactive Architecture Map  |  Contextual AI Chat
                         |
          Typed Project Graph + Contracts
                         |
      Human-reviewed transactions and AI proposals
                         |
       Assembly components + device/OS adapters
                         |
       LLVM/Clang toolchain + local verification
                         |
               Supported hardware targets
```

- **Studio technology:** own declarative UI framework and Assembly-first core. No Qt/QML/C++/FMX runtime in the intended Studio stack.
- **Portability:** graph and ABI contracts are target-neutral; native Assembly is ISA-specific and OS/ABI-specific.
- **AI:** officially supported authorization only. ChatGPT Plus is not automatically a general API credential. AI access is unimplemented. Local project work never requires an AI login.
- **Safety:** select context → propose → validate → inspect graph/source diffs → approve → apply → locally test. No untrusted hardware operations in IDE process; builds/probes are isolated where supported.
- **Evidence:** every status distinguishes supported/unsupported and passed/failed/not tested, per target. No CI until release preparation.

## Minimal product milestone

A native AELYXORA window containing **architecture map plus contextual AI chat area**; load a hardware-aware project graph, select a component, inspect its contracts, create an approved change, and see local build/test evidence. Chat can be a clearly marked non-connected UI placeholder until official authorization is available.

**Reality:** design specifications and illustrative fixtures exist, but no executable AUI compiler, runtime, map, renderer, AI integration or hardware support is implemented.

## Documentation policy

This document is the **canonical architectural source**. [Roadmap](../product/roadmap.md) defines a small set of proof-oriented gates. Technical contracts are supporting references; don't generate parallel strategy documents that contradict this one. Record consequential decisions in the owning current specification; historical ADR files are not maintained.

References: [Declarative UI](declarative-ui.md), [Assembly ABI](assembly-first.md), [Component contracts](component-contract.md), [State and bindings](bindings-and-runtime.md), [Security](extension-and-security.md).

## Normative implementation contracts

Read in order: [Workspace and first-screen UX](workspace.md) → [Canonical Project Graph](project-graph.md) → [Hardware and target contracts](hardware-and-targets.md) → [AI Engineer and ChatGPT access](ai-engineer.md).

Supporting documents: [Component ABI](component-contract.md), [Declarative UI](declarative-ui.md), [Assembly-first implementation](assembly-first.md), [Binding semantics](bindings-and-runtime.md), [Source ownership](source-ownership.md), [Security boundaries](extension-and-security.md), [Local verification](verification-plan.md).

**Documentation authority:** this index defines product invariants; Project Graph specifies graph semantics; Workspace specifies interaction; Hardware and Targets specifies device constraints; AI Engineer specifies AI permissions and workflow. The [Roadmap](../product/roadmap.md) orders work but does not override technical contracts. When conflicts appear, update the owning document rather than duplicating rules.

## Complete platform contract

[Studio platform contract](studio-platform-contract.md) defines user roles, end-to-end workflows, visual/nonvisual component palette, task and event lifecycle, threading, data flow and binding semantics, accessibility and measurable zero-cost abstraction goals. It is the authoritative specification for these topics; the graph, hardware and AI documents define their specialized constraints.

## Design-first engineering policy

The complete architecture and user workflows may be specified **before** broad implementation. The aim is a coherent, implementable AUI language, compiler, Assembly runtime, rendering/OS adapters, component SDK, hardware-aware Project Graph and AI Engineering workflow. Detailed design is not the same as demonstrated portability.

Every normative design decision must explicitly describe: invariants, API/data contracts, target-specific ABI assumptions, failure behavior, dependencies, examples, tradeoffs and acceptance criteria. Mark items **accepted**, **proposed**, **open**, or **verified**; only actual test evidence may justify verified status.

The canonical project graph remains the heart of Studio; AUI is its implementation technology, not a competing source of architectural truth. Documentation-first is not documentation-only: proofs and prototypes validate uncertain ABI, compiler, rendering and runtime assumptions before irreversible commitments. No GitHub Actions until release preparation.

## AUI language/compiler/runtime design package

The [theoretical design plan](aui-design-plan.md) tracks the design's completeness and unresolved decisions. Its dedicated contracts are [AUI language](aui-language.md), [compiler and target lowering](aui-compiler.md) and [state/runtime/rendering](aui-runtime.md). These are **proposed technical specifications**, not running implementations. They remain subordinate to the canonical Project Graph and this architecture's human-led, map-centric product invariants.

## AUI low-level semantic contracts

- [Types, memory and ownership](aui-types-and-ownership.md) — lifetime, borrowed/owned values, device memory capabilities and concurrency.
- [Component ABI and asynchronous commands](aui-abi-and-async.md) — effect boundaries, target-specific calling contracts, task outcomes and cancellation races.


### Binary component contract

[AUI Component Binary ABI](aui-component-binary-abi.md) specifies proposed descriptors, ownership transfer, allocation, asynchronous completion, version negotiation and target conformance tests. It is not a verified or released ABI.

## Project and component persistence

[Project and Package Format](project-and-package-format.md) documents the proposed versioned graph and package manifests, with illustrative [sensor project](../../examples/architecture-sensor/project.auiproj.json), [component package](../../examples/architecture-sensor/component.auipkg.json) and [map view](../../examples/architecture-sensor/views/main.auiview.json). Fixtures are design examples, not tested builds.

## Project-format verification

[Graph Validation and Migration](graph-validation-and-migration.md) specifies integrity, schema evolution, lockfile resolution, crash recovery and diagnostics. The [negative sensor fixture matrix](../../examples/architecture-sensor/invalid-cases.json) is proposed, not executed.


[AUI Component Framework](component-framework.md) defines visual/nonvisual palette categories, component lifecycle, properties, events, commands, bindings, layout and design-time behavior. Proposed and not implemented.


[AUI.Core library](aui-core-library.md): draft APIs for visual and nonvisual components, unimplemented.


[AUI Syntax and Semantics](aui-syntax.md) defines the current proposed extended grammar and rules for state, events, commands, bindings, tasks and modifiers. Syntax is not frozen or implemented.


[AUI AST and Semantic Analysis](aui-ast-semantic-analysis.md) defines compiler tree nodes, scopes, type/effect checking, bindings and TypedHIR output. Proposed and not implemented.


[OwnershipIR and Compile-Time Safety](aui-ownership-ir.md) defines ownership CFG, borrow conflicts, async transfer and cleanup checks. Proposed, not implemented.


[AUI TargetMIR and Native Code Generation](aui-targetmir-native-codegen.md) specifies ISA-aware lowering, registers, stack, ABI, optimization limits and target-specific verification. Proposed; not implemented.


[AUI Platform Abstraction and Native Runtime Services](aui-platform-runtime-services.md) specifies OS adapters for windows, graphics, text, input, accessibility, memory, concurrency, timers, filesystem and hardware capabilities. Proposed; not implemented.


[AUI Rendering and Layout Engine](aui-rendering-layout.md) specifies constraints, scene graph, display lists, text, accessibility, hit testing, animations and CPU/GPU backends. Proposed, not implemented.


[Design-Time Engine and Studio Workspace](design-time-engine.md) specifies map interactions, palette, inspector, data-flow editor, AI proposal review, transactions, undo/redo and source synchronization. Proposed; not implemented.


[AI Engineering Workflow and Tool Integration](ai-engineering-workflow.md) defines scoped context disclosure, structured proposals, human approval, controlled tool execution and verification evidence. Proposed, not implemented.


## Architecture consistency review

[Architecture Consistency and Completeness Audit](consistency-audit.md) records confirmed invariants, unresolved incompatibilities, authoritative documents and prioritized closure criteria. Findings are design-review results, not verified implementation.


[Architecture Design Closure — Sensor Slice](architecture-closure.md) defines canonical type IDs, package exports and the end-to-end graph-to-code contract. The sensor fixtures use qualified types. This is a proposed design and has not been run.


[Manifest Schema and Validation Contract](schema-validation-contract.md) documents the proposed JSON schemas, semantic rules, observed fixture checks and unresolved lockfile requirements. Structural schemas: [project](../../schemas/project.schema.json), [component package](../../schemas/component-package.schema.json).


[Package Resolution and Reproducible Build Contract](package-resolution-build.md) defines offline locked dependency resolution, digest design, target checks and reproducibility gates. [Proposed lockfile schema](../../schemas/package-lock.schema.json). No fabricated lockfile or verified build.


[Local Build System and Verification Architecture](local-build-verification.md) defines the local build DAG, tool execution permissions, incremental cache, cancellation/recovery and per-artifact verification evidence. Proposed only; CI stays disabled.


[Architecture Freeze Readiness and Implementation Strategy](implementation-readiness.md) concludes global freeze is premature and orders S0 graph validation, S1 architecture workspace, S2 minimal AUI native build, S3 controlled AI workflow and S4 on-target hardware verification. **All implementation gates remain not-run; CI disabled.**


## S0 implementation status

The earlier Python validator and tests have been removed. S0 has a limited Linux x86-64 Assembly lexical preflight but **no complete JSON parser or Project Graph validator**. See [Implementation Language Policy](language-policy.md) and [S0 status](s0-graph-implementation.md).


**Implementation restriction:** Python is prohibited in the Studio codebase, build tooling and tests. [Policy](language-policy.md).


[AI Role and Human-in-the-Loop Contract](ai-role-contract.md) separates human decisions, AI proposals and deterministic local validation. Proposed for review.


[Project Graph ↔ AUI Formal Integration Contract](project-graph-aui-contract.md) defines identity, exports, typed edges, source synchronization and D2/D3 acceptance fixtures. **Proposed, not accepted or implemented.**


[Event, Command and Binding Semantics](aui-event-binding-semantics.md) proposes explicit AUI event wiring and diagnostics; the design gate remains open.
