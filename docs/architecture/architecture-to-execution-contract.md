# AELYXORA — Architecture-to-Execution Contract

**Status: Proposed for human architectural review.** This document refines product priorities and defines the end-to-end architectural contract. The canonical [Architecture](README.md) remains authoritative for product invariants; [Project Graph](project-graph.md), [Studio Platform](studio-platform-contract.md), [AUI Syntax](aui-syntax.md), [AI Workflow](ai-engineering-workflow.md), and their specialist specifications own their respective detailed semantics. When a conflict is discovered, correct the owning specification rather than treating this document as a competing normative definition.

## 1. Product intent and priority

AELYXORA is an **architecture-first, AI-native, Assembly-first rapid application and systems engineering studio**. RAD means reducing the time between a human architectural idea and a verified running native result — **not** accelerating human placement of widgets or manual production of boilerplate source.

### Strict product priority

1. **Architecture**: component topology, responsibilities, stable identities, typed contracts, target constraints and resources.
2. **Workflows**: how the system behaves in time, including events, commands, state transitions, concurrency, failure and recovery.
3. **Data flows**: where typed data originates, how it is transformed or stored, where it is consumed, and what happens under overload or error.
4. **AI implementation loop**: scoped generation of native code, adapters, tests and documentation from architect-approved contracts.
5. **Verification and observability**: trace every implementation artifact and observed result back to architectural elements.
6. **UX and declarative UI**: important where software has a user interface, but never the primary source of architectural truth.

An interactive **Architecture Map + contextual AI Chat** is the primary Studio workspace. Code editor, declarative UI preview, property inspector, debugger and component palette are contextual projections of the same project.

### Human and AI responsibilities

- The human architect chooses goals, boundaries, correctness requirements, source ownership, target platforms, performance budgets, acceptable tradeoffs and approvals.
- AI acts as primary implementer **within accepted contracts**: propose component implementations, cross-target adapters, AUI, tests and refactorings; it also explains architecture and surfaces uncertainties.
- Deterministic local validators decide whether proposed changes satisfy schema, graph, type/effect, ownership, target and permission constraints. A model's explanation is not evidence.
- Architectural changes, changed capabilities, dependency introduction, actual local execution and external/device side effects require their own explicitly authorized scopes.

## 2. One model, multiple projections

The canonical **Project Graph** is the durable authority for component identities, interfaces, inter-component relationships, workflows/data-flow references, capabilities and target profiles. The Architecture Map is one projection; UI preview, source, event timelines and execution diagnostics are other projections. No second independently mutable model may silently override the Project Graph.

The following representations are distinguished:

| Representation | Authority / identity | Key invariant |
| --- | --- | --- |
| Project Graph | Persistent ProjectID, GraphNodeID, PortID and EdgeID | Every semantic change is an approved revision transaction |
| Architecture Map view | ViewID, coordinates, groups, selection, zoom | Presentation-only changes cannot change semantic graph digest or build inputs |
| Workflow / data-flow view | References to canonical graph IDs | A diagram cannot invent an executable edge, permission or scheduler guarantee |
| AUI declarations and view instances | Resolved symbol identity and runtime ViewIdentity | Source/graph reconciliation is reviewed, not inferred from screen position |
| ASM and other approved native sources | Owned file digest, target, component contract | No silent overwrite of human-owned source |
| Build, test and runtime evidence | Immutable artifact and revision identity | Designed and AI-predicted behavior is never marked as observed |

The graph must support software without any UI. A UI is a client of architecture contracts, not a prerequisite for architecture design.

## 3. Component contract — minimum required information

For every implementation-bearing component, the accepted design defines:

- **Identity**: package-qualified TypeID and versioned contract; stable instance ID; source ownership and declared exports.
- **Purpose**: responsibility and explicitly excluded responsibilities.
- **Boundary**: input/output ports, events, commands, types, units, optionality, multiplicity, errors and ordering assumptions.
- **Execution**: host/target triples, operating mode/privilege, ABI, ISA features, execution domain, scheduler affinity and allowed blocking behavior.
- **Memory and resources**: ownership, lifetime, allocators, alignment, transfer/borrow, handles/generations, cleanup, and hardware-specific DMA/MMIO/IRQ if applicable.
- **Effects and security**: filesystem, network, device, process and privileged operations; capability requirements, permission escalation and isolation boundaries.
- **Performance**: measurable latency, throughput, memory, code-size or deterministic-deadline requirements **when applicable**; no invented universal zero-cost promise.
- **Failure**: invalid inputs, partial output, timeout, cancellation, retries, recovery, fallback and diagnostics.
- **Evidence**: positive/negative design fixtures, acceptance scenarios, compatible targets and actual verification status, initially **not-run**.

No component can be declared implementation-ready while a P0 property above is both material to it and undefined. A purely architectural grouping node is not required to invent a runtime ABI.

## 4. Executable workflows: semantic requirements

A workflow must have a stable identity and declared scope; its diagram refers to canonical node/edge IDs. Its executable contract must specify:

- Trigger (user intent, external event, timer, data arrival or approved tool action) with exact event payload and provenance.
- Start and terminal states, transition preconditions, guard purity, effects, success and failure results.
- Ordered/parallel branches, joins and concurrency domain; deterministic ordering where guaranteed and explicit nondeterminism elsewhere.
- Bounded queues, backpressure, timeout/deadline and cancellation semantics where work can be asynchronous or unbounded.
- Ownership/lifetime of state and in-flight resources, including completion after a consumer disappears.
- Retry safety and idempotency; compensation rules for reversible actions, and **explicit non-reversibility** for real-world effects (flash, network send, device actuation).
- External permissions and failure containment; no workflow edge is permission to execute privileged operations.
- Local trace mapping: transition, source graph ID, artifact/revision, timestamp provenance and diagnostic outcome.

A cyclic workflow is not itself invalid: state-machine loops may be intentional. An instantaneous data-binding cycle with no delay/state boundary is invalid. The validator must distinguish these cases instead of applying a blanket acyclic-graph rule.

**Design fixture required**: user chooses a sensor component -> requests an Inspect command -> authorization gate -> task queued -> target adapter -> terminal result or defined error -> state update -> observable trace. Include invalid capability, late completion, duplicate event, cancellation race, and time-out examples.

## 5. Typed data flow: semantic requirements

Every flow edge must define source and sink, canonical TypeID, units, direction, multiplicity, mutability, serialization/representation boundary, buffer ownership and execution domain. A conversion is explicit, typed and pure unless modeled separately as an effectful component. Cross-domain movement must satisfy ownership and thread-safety rules.

A data-flow design identifies:

- snapshot/state versus event versus stream versus command/result;
- update consistency, writer authority, ordering domain, exactly-what-delivery-guarantees-are-proven;
- bounded capacity and overflow policy (block, reject, drop with telemetry, or domain-specific policy);
- error/invalid data propagation and consumer recovery;
- type and unit mismatches, duplicate writers, missing endpoints, illegal borrow and unsupported target capability;
- whether persistence is requested and under which transaction/retention policy.

Sensor reference path: **device adapter -> raw sample -> bounded channel -> decoder -> validated measurement -> observable state -> AUI text**. This is a *designed trace*, not evidence of working hardware. The reverse user-intent path is separately modeled as **Button event -> explicitly declared handler -> typed Inspect command -> authorized target adapter**; a visual binding never implies device permissions.

## 6. AI architecture-to-native loop

The default user flow is:

1. **Specify** objective, constraints, target and acceptance criteria; select graph nodes/subgraph.
2. **Resolve context**: the local deterministic engine supplies exact graph revision, interfaces, relevant source ownership, target/ABI and diagnostics. Show the full disclosure manifest before provider transmission.
3. **Propose**: AI generates a typed proposal consisting of assumptions, graph diff (if necessary), source diff, AUI changes, test fixtures, requested tools/effects and expected outcomes. No proposal mutates the project.
4. **Validate**: structural/semantic checks, scope check, capability check, package and source hashes, type/effect/ownership/ABI requirements.
5. **Review and approve**: human approves the precise change set and separately approves any needed execution/network/device actions. No implicit approval by conversational wording inside untrusted sources.
6. **Apply**: stage all changes; commit against expected graph/source revision with crash recovery, or leave prior project bytes unchanged.
7. **Build and verify** in the later implementation/test phases: assembly, link, execute authorized checks, record observed evidence and relate findings to the graph.
8. **Correct**: failed checks produce a bounded change proposal against the same contracts, not silent architectural drift.

For documentation-first development, steps 1–6 are specified as contract/state machine and examples **before** implementing the engine. Actual AI inference and tool calls are not prerequisites for design completion; official authorization feasibility must remain honest.

A UI-only adjustment can be scoped to AUI and view metadata, but still must not silently change a component's public contract.

## 7. Assembly-first and dependency boundary

The implementation direction remains **native, Assembly-first and target-specific**, with AUI for declarative UI; Qt/QML/C++/FMX and Python are outside the accepted Studio implementation policy. LLVM/Clang can be used as assembly/link tooling. Target ISA, object format and OS ABI are never treated as interchangeable.

**"No additional dependencies" must be interpreted precisely:**
- Do not require an unrelated high-level application framework or language runtime merely to run a generated Studio application.
- Explicit native OS services, system libraries, SDK/ABI entry points and target-specific adapters are **platform interfaces**, not magically nonexistent dependencies.
- A build toolchain is a **build-time dependency**; it need not be bundled into every generated executable.
- Hardware/firmware targets may have different runtime requirements; supported targets are validated individually.
- Components may request external libraries only through an explicit, reviewed dependency/capability decision; never add them silently to speed up AI generation.
- Do not promise universally static, self-contained binaries where platform rules make that unrealistic.

This is a product constraint, not a proof of binary size, performance, portability or a security claim. Measure per target.

## 8. AUI and UX are downstream projections

AUI must express a UI contract declaratively: components, layout, typed inputs, state, events, explicit event-to-command dispatch, one-way bindings, accessibility, platform capabilities and failure behavior. Studio must eventually preview AUI, inspect layout issues and relate interactions to graph nodes.

**Non-goals**: pixel-first form construction as the main workflow; arbitrary dynamic code emitted by UI expressions; UI changes silently overwriting ASM; a mandatory UI for services, drivers or firmware components.

**Design acceptance**: one self-contained AUI example where Button activation dispatches an explicit typed command and committed state updates Text. Both positive and negative versions specify expected diagnostics. Preview/rendering fidelity and editor ergonomics are verified only in later phases.

## 9. Architecture-aligned verification contract

Each architectural requirement has a stable requirement ID and a trace to:
- authoritative specification and accepted decision;
- positive and negative fixture, including expected diagnostics;
- affected project/ABI/source artifacts and target;
- future implementation milestone;
- future test procedure and evidence form;
- actual measured outcome, initially **not-run**, and post-test correction reference.

Observation status is **passed / failed / not-run / unsupported** with explicit environment and artifact identity. AI-generated code, a design fixture, a successful assembler invocation or a visually plausible canvas do not by themselves certify behavior.

The full documentation gate is defined in [Design Completion Gates](design-completion-gates.md) and tracked in [Specification Completion Matrix](specification-completion-matrix.md). This document alone does not close any gate.

## 10. One complete vertical trace to specify before coding

The minimum reference system combines **Architecture Map + contextual AI panel** with a sensor graph:
1. Open an immutable, versioned project containing target, bus, device, driver, decoder, measurement state and UI projection.
2. Verify all package types, target capabilities, port directions and resource claims; show precise errors for invalid cases.
3. Select a component and preview its contract, workflow transitions, data-flow paths and candidate AI context.
4. Propose a driver implementation change; check precise allowed paths and permissions; reject stale or out-of-scope changes without mutation.
5. Apply only a human-approved diff; persist graph/source/view revisions transactionally, preserve map-only semantics.
6. Compile the minimal AUI/ASM path for the first chosen host, then display a measurement and send an Inspect intent via explicit command wiring.
7. Record exact target and artifact hashes, compiler/run evidence, negative-case diagnostics and limitations. Hardware execution remains unsupported until on-target evidence is collected.

All seven steps need **documented valid/invalid scenarios and expected outcomes during the design phase**. Executable implementations and observed results happen only after the design freeze. Reaching a window mockup alone is not success.

## 11. Items requiring architect approval before claiming acceptance

- The strict architecture / workflows / data flows / AI / UI priority described here.
- Scope boundary between a generic application architecting system and the initial hardware-oriented reference vertical.
- Formal representation of workflows and data flows within the canonical Project Graph rather than as independently editable documents.
- Host selection, memory/ABI and graphics/text baseline for the first native implementation.
- Interpretation of Assembly-first and "no extra dependencies" for generated binaries on each supported OS.
- Default AI permission workflow, offline operation, and separation of architectural approval from execution approval.

**Current disposition: Proposed.** The presence of this text in a branch or pull request does not indicate approval, implementation or observed correctness.
