# AELYXORA Studio — Complete Platform and Interaction Contract

**Status: normative product requirements; implementation pending, design gates open.** This document defines expected product behaviors, not proof of working features. The [Architecture index](README.md) owns product principles; the [ONE Canonical Project Graph](canonical-project-graph-and-components.md) exclusively owns graph semantics, typed components and persistent identities. This document specifies user workflows, palette and interaction expectations, subordinate to that graph contract. More detailed runtime mechanics remain proposed in specialist D2–D6 documents; no duplicate graph or independent workflow model is created.

## 1. Product, roles and responsibilities

AELYXORA is an architecture-map-first engineering environment for hardware-oriented and systems software. The default screen is **interactive Project Architecture Map + contextual AI Chat**, not a form designer. The map, visual component palette, data-flow editor, source code, traces, hardware register inspector and debugging surfaces are **views of one typed project graph**.

Roles are **capabilities**, not compulsory cloud accounts or user-management infrastructure:
- **Architect (human)**: sets boundaries, platform targets, architecture and contracts; owns acceptance criteria; approves structural changes.
- **Implementer (human)**: builds/edits Assembly modules, tests and adapters within contracts; can propose architecture edits.
- **AI Component Engineer**: can explain, draft, implement and test within granted scope; does not approve its own changes or silently change architectural contracts.
- **Reviewer**: examines graph/source diffs, performance, safety and evidence; accepts or rejects a proposed change if authorized.
- **Operator / Hardware Tester**: chooses devices, authorizes physical operations and records on-target evidence. An AI request never grants device access.

Single-person projects may exercise every human capability. Authentication is not required to work on local projects. A project can assign capabilities without requiring online collaboration.

## 2. Complete user workflows

**New system:** create project → choose host and target profiles (CPU/ISA, OS/RTOS/bare metal, ABI, board/device if relevant) → create component/module/hardware nodes → add typed ports and contracts → connect → validate → save a versioned graph.

**Design from a map:** navigate/group/zoom → add components from palette → connect compatible ports → inspect dependency and data-flow views → view diagnostic overlays → commit a revisioned transaction. Layout position changes cannot alter behavior.

**Implement manually:** select node → open interface and ASM source → edit within owned source boundaries → assemble/link for selected target → run local conformance tests → attach observed evidence to node. Targets unsupported by the current assembler or device adapter remain explicitly unsupported.

**Implement with AI:** select a component/subgraph and target → preview exactly which contracts/files/context will be sent → ask AI to implement or refactor → receive structured graph/source patch plus tests → validate contract and target → inspect preview diffs → human approval → apply atomically → run local verification. Offline projects remain editable.

**Build / debug:** select target → inspect toolchain and capability checks → build locally → view errors and source locations overlaid on the map → run unit/simulator tests → optionally request explicit permission for on-device connection/flash/debug → record target- and artifact-specific results.

**Maintain / evolve:** rename components without changing stable IDs → inspect affected graph edges and ABI consumers → propose migration → review diff → apply transaction or revert → regenerate only machine-owned files. Undo/redo is revision-aware; external file changes require conflict resolution.

**Design user-facing UI:** open declarative UI view from an architectural component → drag visual components from palette → configure typed properties and accessibility → connect events and bindings to nonvisual services on the same project graph → preview/render and verify; the form is not the canonical architecture.

## 3. Component palette and contract

Palette is searchable and filtered by execution target, context, capabilities and install state. Entries describe reusable **definitions**, while placed graph nodes are **instances**. Standard components are never presumed supported on every target.

Common contract for *every* component:
- stable type ID/version and instance ID, category, visibility (visual/nonvisual), supported execution targets;
- typed properties (defaults, validation, readonly/observable, units/ranges where relevant);
- typed input/output ports; named events and commands with payload/result/error contracts;
- memory ownership, lifetime, allocator, alignment, synchronization, permissions, thread/execution domain;
- target-specific Assembly implementation or explicitly declared adapter; test fixtures and observed support status;
- capability manifest including device/network/filesystem/UI/GPU/clock/threading needs.

Initial **visual** palette (scope, not promised implementation): AppWindow/Surface, VStack/HStack/Grid, Stack/Overlay, ScrollView, SplitPane, Text, RichText, Image/Icon, Button, Toggle/Checkbox, Radio, TextField, TextArea/CodeEditor, NumericField, Slider, Select/ComboBox, List, Tree, Table, Tabs, Dialog, Menu/Toolbar, Progress/Status, Canvas/Graph, and AccessibilityNode. Design-time map-specific components include NodeCard, TypedPort, Connector, Group, MiniMap and DiagnosticsOverlay. Rendering adapters decide how accessibility and input are presented on each OS.

Initial **nonvisual** palette: State/Observable, Computed, Binding, Command, EventSource, EventBus, Timer, Task, CancellationToken, Scheduler, Worker, Channel/Queue, Mutex/RWLock/Atomic, Buffer/MemoryRegion, Stream/Serializer, File/Storage, Database/Query, NetworkClient/Socket, ProtocolCodec, Log/Trace/Metric, BuildTarget/Toolchain, Device, Bus, RegisterMap/MMIO, InterruptSource, DMABuffer, HardwareTimer, DriverInterface and SimulatorAdapter. No universal raw MMIO access from user space; the target/capability contract governs availability.

A component can expose both visual output and nonvisual services; category is presentation, not a new ownership hierarchy. Third-party code remains untrusted native code until reviewed or isolated.

## 4. State, events, actions and tasks

**State:** typed, explicit owner, initialization, lifetime, mutation authority and persistence scope (transient/session/project/device). Identity is stable across declarative reconciliation only under documented key/type conditions.

**Event:** immutable typed payload, source, sequence/order domain and timestamp provenance if applicable. Event describes something that happened; **Command/Action** asks for work and carries a typed result or error. An event handler may enqueue a command; no hidden arbitrary reentrant execution.

**Task:** explicit lifecycle `created → scheduled → running → completed | failed | cancelled`. Tasks define cancellation semantics, resource ownership, deadlines, error propagation, target execution context and progress. Cancellation is cooperative unless a platform contract states otherwise. Closing a view does not implicitly cancel device operations without policy.

**Scheduling and threading:** UI/render thread, I/O workers, CPU workers, real-time or interrupt context are separate scheduling domains. Each port/handler declares legal domain and thread affinity. The runtime must reject illegal blocking on the UI thread and unsafe calls from interrupt context. Bounded queues and backpressure are mandatory for potentially unbounded streams. Lock ordering and race requirements are explicit; tasks cannot capture invalidated component state.

## 5. Data flow and bindings

- **One-time** binding computes once.
- **One-way** binding propagates typed source changes to one or more destinations.
- **Two-way** binding is a *pair of explicitly authorized edit/commit directions* with origin tracking, not uncontrolled mutual callbacks.
- **Computed** derives state from dependencies.
- **Stream** delivers bounded asynchronous values with overflow and backpressure policies.
- **Event → Command** connects an event to an action with typed payload mapping.
- **Hardware data flow** records buffer ownership, DMA direction, cache visibility, memory barriers and execution domain where applicable.

Every binding has a stable ID, typed endpoints, conversion/null/error policies, scheduling domain and propagation direction. Implicit lossy conversions are forbidden. Validate unresolved ports, incompatible units/types, duplicate writers, write-to-readonly, unauthorized effects, and cyclic synchronous dependencies without an explicit delay/state boundary. Recompute against coherent revisions and publish only validated state. Visual redraw is incremental and separate from state transitions.

**Example:** Sensor IRQ → bounded sample queue → decode task → observable measurement → graph binding to telemetry label; commands to control hardware are not inferred from a display binding.

## 6. Zero-cost abstraction: a measurable goal, not a promise

Meaning: a high-level declarative component or typed connection **should not add unavoidable runtime work compared with the necessary equivalent hand-written native implementation**. This does **not** mean UI rendering, scheduling, allocation or cross-thread delivery are free.

Requirements:
- static contracts resolved at compile/build time where practical; avoid mandatory reflection, dynamic dispatch, allocations or boxing on critical paths;
- separate build-time graph metadata from runtime data structures; allow specialized code generation per target and known component topology;
- explicit opt-in dynamic features, instrumentation and safety checks with understood runtime costs;
- direct ABI calls or inlined native code where safe, verified and supported, without breaking component isolation and debugging;
- document overhead for callbacks, value propagation, task switching, queues and memory ownership.

Evidence: compare hand-written baseline vs generated/component path under equivalent conditions; inspect emitted object/disassembly; measure allocations, latency, memory, code size and scheduling overhead on a specified target. Never claim zero cost from source syntax alone.

## 7. Availability and target capability

Each palette entry and each graph node advertises status per target: **supported / planned / unsupported / unknown**, plus verification **pass / fail / not run**. Unsupported options may be visible but disabled with an explanation. Capabilities differ in user mode, kernel mode, firmware, simulated and real hardware execution. Capability checks precede compilation and physical deployment; availability is not inferred merely from an assembler accepting source.

## 8. Safety, accessibility and auditability

Visual components need semantic role, label, keyboard interaction, focus order, contrast and screen-reader semantics. Nonvisual tasks need resource budgets, timeouts/cancellation, permission checks and diagnostics. Device/firmware actions require explicit device selection and operator approval; no AI-generated text may trigger flashing or privileged MMIO automatically.

Local manual verification only until release preparation (CI remains disabled). Keep precise passed/failed/not-run evidence and project/target revisions; no synthetic green status for untested components.

## 9. Delivery order and minimum executable proof

First complete and persist **Project Graph + typed ports and target profiles**. Then implement a tiny slice of the above palette (GraphNode, Port, Connector, Text, Button; State, Event, Command, Task, Binding, Log) using the in-house declarative UI and Assembly runtime. Demonstrate one small device → driver → protocol → application project with a sensor stream reaching a visible label through a bounded queue and one-way binding. Add context-aware AI proposals and approval without broadening the palette until this slice works.

## 10. Decisions still open

Exact declarative syntax and persistence format; compiled graph IR; allocator and error ABI; event loop portability; renderer and text shaping; realtime scheduling guarantees; precise definition of capability negotiation; official ChatGPT subscription authorization availability. Treat these as engineering experiments and decisions, not pre-existing features.
