# Project Graph ↔ AUI — Formal Integration Contract

**Status: proposed design for D2/D3 review; not accepted, implemented or executable.** [Project Graph](project-graph.md) owns canonical architecture and persistent IDs. [AUI Syntax](aui-syntax.md) owns source grammar. [AST Semantics](aui-ast-semantic-analysis.md) owns resolution/type checking. This document owns the **mapping between** those systems, not competing definitions.

## 1. Identity and ownership

- ProjectID identifies the project. GraphNodeID identifies a durable architecture instance. PortID is unique in its containing component. EdgeID identifies a relationship.
- TypeID is a package-qualified exported identity (e.g. `example.sensor/Measurement`), pinned to a resolved package content identity. Same display spelling does not imply same type.
- AUI declaration identity uses a resolved symbol identity (package/module/declaration), while a **runtime ViewIdentity** tracks an instantiated rendered view. These three identities must not be conflated.
- AUI source locations (file/byte span) are *references*, never permanent identity. Moving a line or formatting a file cannot reassign GraphNodeID.
- The canonical graph owns nodes, inter-component edges, permissions, targets and source ownership. AUI owns its declaration bodies and presentation hierarchy; proposed source changes that affect graph contracts require a graph transaction.

## 2. Resolved declarations and component instances

A component declaration exports a Contract: TypeID; contract compatibility revision; typed input/output ports; state declarations; events; commands; effects; execution domain; capability requirements; slot cardinality; source ownership. Graph instances link to a resolved exported Contract. Every declared required port must have an explicit graph representation or validated local/internal-only designation.

AUI internal view nodes do not automatically become graph nodes. Promote to canonical graph identity only when architect explicitly models an independently addressable component or service. Static child identity may be scope/position based only within documented immutability limits; dynamic collections require stable user-supplied keys (syntax remains open).

## 3. Edge semantics by kind

| Edge kind | Static checks | Runtime interpretation |
| --- | --- | --- |
| data-flow | output→input, exact canonical TypeID or explicit pure converter, units, fan-in and ownership | transport/snapshot with declared scheduling |
| event | source declared Event<T> → compatible handler input; execution domain and effect permissions | typed event delivery; never implicit action authorization |
| command/call | parameter/result types, effect set, caller capability, target ABI | explicit invocation, error outcome |
| dependency | resolved package/module identity, no forbidden build cycle | determines compilation/link order only |
| containment | acyclic parent graph, allowed child kind and cardinality | organization, not automatic UI hierarchy |
| hardware access | resource/address-space ranges, privilege, target/device capability, exclusive/shared policy | only platform adapter may perform authorized I/O |

A Graph edge never silently creates an AUI source-level event handler. Source wiring must be expressible in explicit AUI syntax and checked against the same graph contract. Until that syntax is finalized, examples remain pseudocode.

## 4. Data, state and transactions

State is owned by component instance or declared service scope, not by a painted shape. Derived values are pure, with dependency tracking. Bindings are one-way and read-only toward presentation unless a separate edit/command intent is defined. Single writer by default; sharing requires explicit synchronization policy. Cycles in synchronous bindings are errors unless a specified buffer/delay boundary exists.

Project Graph revision controls architecture edits. Runtime state revisions are separate and must never mutate project architecture by coincidence. Render redraws and map position-only updates must not change semantic graph digest. Changes requiring new capabilities, target constraints or resource ownership must be validated and reviewed before commit.

## 5. Source ↔ graph synchronization

```text
Open project -> validate graph + locked exports -> parse AUI
 -> resolve symbol/type/effect -> compare exported contracts with graph
 -> produce diagnostics and proposed reconciliation patch
 -> human review -> stage files + graph revision -> commit or rollback
```

Graph-only edits requiring AUI source changes are proposals until compatible generated declarations/edits are reviewed. Source-only edits that change exported ports/contracts likewise produce candidate graph diffs. On conflicting changes, preserve both revisions and require explicit resolution. No inferred overwrite of human-owned Assembly.

Mappings stored in a derived index: graph ID, export symbol ID, source file hash/span, contract digest and graph revision. This index is disposable and must not be trusted after hash mismatch.

## 6. Diagnostics

Common envelope: stable code, severity, source span, GraphNodeID/EdgeID, expected vs actual contract, target, proposal revision and fix suggestion. Required categories: GRAPH_MISSING_NODE, GRAPH_PORT_DIRECTION, GRAPH_TYPE_MISMATCH, GRAPH_DUPLICATE_ID, GRAPH_UNKNOWN_TARGET, AUI_UNRESOLVED, AUI_ILLEGAL_EFFECT, AUI_BIND_READONLY, AUI_CONTRACT_DRIFT, AUI_SOURCE_GRAPH_CONFLICT, AUI_IDENTITY_UNSTABLE and CAPABILITY_DENIED. No generated executable may be emitted with hard errors.

## 7. Two end-to-end design fixtures

**Sensor:** driver.sample (`example.sensor/RawSample`) → decoder.raw, decoder.reading (`example.sensor/Measurement`) → app.reading. These are valid **type/direction relationships** in the current JSON fixture; not proof of IRQ, queue, worker, real hardware or linked ASM. Missing package source files prevent a runnable build.

**Interactive view:** a typed input `Measurement` is rendered by `Text`; `Button.activated` emits a typed event, explicitly handled by a command requesting a read. The exact source syntax connecting Button.activated to that command is **open** and must be finalized in AUI Syntax before claiming a valid compiled program. Runtime input events cannot directly execute hardware commands without capability checks.

## 8. D2/D3 acceptance gate

- One canonical graph serialization/identity authority, with type registry and exact package resolution.
- Positive and negative graph fixtures, including missing export, wrong direction, duplicate writer, capability mismatch and map coordinate-only update.
- A single **complete legal AUI source fixture** whose event/command wiring and state/binding semantics are unambiguous; invalid programs with expected diagnostics.
- Source edit and graph edit produce identical canonical contract diff when semantically equivalent.
- No specification claims a runtime or parser proof before real local verification.

## Open decisions

Exact public port export syntax; AUI event connection grammar; dynamic key syntax and identity; typed value lifetime across scheduler domains; canonical graph/source hashes; package lock canonicalization; actual ABI layouts; transaction journal states. Remain Proposed until reviewed by the human architect.
