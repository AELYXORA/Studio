# Project Graph — Canonical Model

**Status:** authoritative graph topology design **candidate**, pending explicit D2 architect acceptance. No implementation started. [Graph Behavior Contract](graph-behavior-contract.md) owns detailed workflows/data-flow semantics; this document owns canonical node/edge identities and graph structure.

## 1. Purpose and ownership

The **Project Graph** is the canonical, typed architecture model. The interactive mind-map/UML-like canvas is one projection of it. Changing coordinates never changes behavior; changing typed nodes or edges is a revisioned model transaction. Human architects own the graph. AI may propose edits but never commits them without explicit approval.

## 2. Minimum entities

| Entity | Key | Required semantics |
| --- | --- | --- |
| Project | projectId | schemaVersion, revision, target profiles, modules |
| Module / Group | stable id | hierarchical organization, imported dependencies |
| Component | stable id | typeId, contractVersion, ports, owned source, targets |
| Port | componentId + portId | direction, type, multiplicity, protocol, effect/capability |
| Connection | stable id | source port, target port, kind, policies |
| Device / Bus / CPU | stable id | hardware description and target constraints |
| Contract | stable id + revision | invariants, ABI, ownership, errors, acceptance tests |
| Evidence | immutable id | target, toolchain, source hash, check, outcome, timestamp |
| Map View | viewId | positions, grouping, zoom, collapsed state, selection |

All references use IDs, not screen labels, coordinates or file paths. Renaming does not regenerate identity.

## 3. Typed graph and rules — D2 design candidate

**Identity:** ProjectID, GraphNodeID, EdgeID, and GraphNodeID/PortID are stable under rename, source formatting and map rearrangement. A TypeID resolves to an exact locked package export. WorkflowID, WorkflowID/StateID, WorkflowID/TransitionID and DataFlowID reference this same canonical graph, never a detached diagram. Identifier normalization and canonical digest/encoding remain P0 design questions; do not confuse AUI Unicode source names with persistent graph IDs.

**Node kinds (first proposed profile):** module, component, interface, cpu, bus, device, driver, firmware-interface, protocol, storage, service, external-system. Unknown extension kinds may be imported/preserved only under an explicit compatible extension policy; they are not executable by default.

**Edge kinds (proposed exact interchange spelling):**

| Kind | Rule |
| --- | --- |
| containment | Organizational hierarchy only, acyclic and independent from runtime ownership |
| hosts | Physical topology for initial profile: cpu -> bus, bus -> device; no OS/privileged access or execution-host inference |
| dependency | Build or package dependency requiring exact resolution |
| call | Explicit typed command/call relationship and target/effect contract |
| event | Declared typed event source/listener relationship |
| data-flow | Typed output port -> typed input port with one authoritative DataFlow binding |
| interrupt | Hardware IRQ source to authorized handler, validated against target |
| protocol | Compatible declared interfaces and versioned protocol |
| resource-access | Scoped resource/address-space claim with permission and exclusivity |
| ownership | Explicit owner of a resource/handle, lifetime rules and sharing policy |

This resolves the *documentation candidate* for the sensor example's 'hosts' edges: they represent hardware topology, not containment, platform access, execution deployment or privilege. The enum and semantics are **Proposed** until architect review and schema/fixture reconciliation. Unrecognized kinds must not be assigned implicit behavior. Portless topology edges are valid; data-flow/call/event require exported typed endpoints or operations. The [Graph Behavior Contract](graph-behavior-contract.md) owns detailed channel/workflow behavior and diagnostics.

**Port constraints:** direction and cardinality, exact qualified value type, units, mutability, declared event/command/data role, owner/lifetime, execution domain, required capability and target must all agree. Validate endpoint existence, fan-in policy, exclusivity, type conversion (explicit pure adapter only), scheduler/ownership transfer and unsupported target. An attractive connection line does not grant execution rights.

**Cycle policy:** organizational containment and first-profile physical 'hosts' must be acyclic; synchronous computed/binding edges are acyclic unless an explicit state/delay boundary is declared. Runtime event loops and state-machine cycles may be legitimate, with explicit scheduling/queue/backpressure semantics; do not globally prohibit cycles.

**Model versus projections:** a workflow timeline, data-flow canvas, architecture map, AUI design view and diagnostic overlay reference canonical graph IDs. Editing any of them creates a proposed graph transaction; only an approved, validated revision changes semantic truth. A diagram's screen coordinates are never semantic edges.

**Required design evidence:** the sensor fixture must show a correct graph, exact typed channel bindings, one workflow state machine, valid and invalid references, forbidden effects, queue limits, and separate positive/negative target assumptions. These are designed fixtures, not executed tests.

## 4. Hardware profile

Target profiles specify OS or bare-metal environment, CPU architecture, required ISA extensions, ABI, endian, pointer width, alignment, execution privilege, and linker/object format. Hardware nodes may provide register windows, address spaces, interrupt lines, DMA constraints, caches, bus transport and timing assumptions. **Never assume physical access exists from a diagram.**

A component must distinguish:
- required features versus optional optimizations;
- proven target support versus planned support;
- user/kernel/firmware execution;
- device capability versus permission to access it;
- simulator result versus actual hardware validation.

Memory-region ownership and DMA buffers require explicit allocation/deallocation, alignment, visibility/synchronization and trust-boundary policies. Overlapping MMIO or interrupt claims are rejected unless a sharing contract explains them.

## 5. View semantics

Canvas supports pan/zoom, groups, folding, search, filtering by target, keyboard navigation, and semantic coloring for unsupported and unverified nodes. A map selection is a list of IDs. The visible AI context preview must enumerate the exact selected subgraph and dependencies included in the request.

The map may render several views (logical, deployment, hardware, runtime, data flow) of the **same model**, rather than storing contradictory diagrams.

## 6. Persistence and transactions (D2 model; D6 encoding and durability)

Use a versioned, deterministic, human-inspectable format. Exact serialization syntax is undecided; do not claim JSON or custom binary is final. Record schemaVersion separately from architecture concept. Normalize ordering for stable diffs. Never infer edges from proximity.

Atomic command transaction contract: expected revision, stable operation ID, candidate graph/workflow/data-flow changes, declared capabilities, validation diagnostics, new revision or no change. Referenced edge deletion must either co-delete/rebind all dependent flow/workflow references in the same transaction or be rejected. Semantic changes to queue capacity, transfer policy, target or workflow transition invalidate relevant build artifacts and evidence; layout-only operations do not. Commands include add/remove/rename node, set contract, connect/disconnect ports, set target requirements and edit presentation. Remove operations must surface affected references, with an explicit deletion policy. Undo/redo must preserve invariant validation.

## 7. Example acceptance fixture

```text
[ARM64 SoC]--hosts-->[I2C bus]--connects-->[Sensor]
                                   |
                              [Sensor driver]
                                   |
                             [Sample protocol]
                                   |
                             [Telemetry app]
```

Test: invalid address range, conflicting exclusive bus claim, wrong-width register access, incompatible ABI, unresolved port, stale revision and deleted-component edge all produce clear diagnostics with node IDs.

## 8. Out of scope for first implementation

Live device discovery, automatic reverse engineering of binaries, full UML coverage, remote multiplayer graph editing, universal hardware knowledge, and auto-generated drivers without human review.


[Project Graph ↔ AUI Formal Integration Contract](project-graph-aui-contract.md) defines identity, exports, typed edges, source synchronization and D2/D3 acceptance fixtures. **Proposed, not accepted or implemented.**

**D2 review tracking:** [Specification Completion Matrix](specification-completion-matrix.md), requirements D2-01 through D2-10. No human acceptance or runtime verification is claimed.
