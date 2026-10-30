# AELYXORA Design-Time Engine and Studio Workspace

**Status: proposed specification, not implemented.** [Workspace](workspace.md) owns product UX invariants; [Project Graph](project-graph.md) owns canonical architecture semantics; [Source Ownership](source-ownership.md) governs source edits. This document defines editor operations and their synchronization.

## Primary workspace

The Architecture Map is the primary full-size canvas; contextual AI Chat is dockable alongside it. Palette, Property Inspector, Data Flow, Source, Build and Diagnostics are contextual panels, not competing main workspaces. Keyboard, accessibility, focus and screen-size adaptations are first-class. User can operate offline; AI remains visibly disconnected without authorized access.

## One model, multiple projections

- Canonical Project Graph: stable nodes, typed ports, edges, target capabilities, revision, ownership and contracts.
- View layout: zoom, pan, grouping, coordinates, collapsed groups and panel geometry, stored separately from graph semantics.
- AUI declaration source: owned declarative view/component definitions; edits are parsed to validated change proposals.
- Native Assembly source: component implementations, never silently rewritten by visual edits.
- Design-time index: disposable derived mappings from graph IDs to AST spans, source files, UI instances and diagnostics.

No projection silently becomes a second source of truth. When AUI source and graph have conflicting proposed edits, require explicit review and reconciliation.

## Interaction workflows

1. **Explore:** open project -> restore map viewport -> select node/subgraph -> inspect contracts, dependencies, diagnostic evidence and target.
2. **Insert:** search palette by category/capability -> drag component -> show target and slot compatibility -> preview transaction -> commit graph instance with stable ID. Location changes affect only saved view.
3. **Connect:** drag between typed ports -> validate direction, type, ownership, execution domain, queue policy and hardware constraints -> show proposed relationship -> approve.
4. **Edit:** inspector presents properties, validation rules, units, defaults and origin (explicit/inherited/computed). Staged edits are validated before commit.
5. **Data Flow:** inspect dependency DAG, writers, scheduling domains and change propagation; connections use the same canonical edge IDs as Architecture Map.
6. **Source:** open associated AUI/ASM from a node; use stable origin mapping. Human source changes are protected; code editing creates revisioned candidates and diagnostics.
7. **AI:** choose node, show context manifest, receive graph/source change set, inspect diff, confirm scope and approve before apply. AI cannot approve itself or trigger privileged hardware operations.
8. **Debug:** map overlays compilation failures, runtime traces and observed test evidence tied to artifact/target/revision. Unknown and not-run are never displayed as passed.

## Transaction semantics

Editor operations use `expectedRevision`, `actor`, `operationId`, `graphPatch`, `viewPatch`, `sourcePatch`, and `capabilityProof` where required. Validate entire candidate before commit. A graph edit is authoritative only upon atomic revision publish; view-only changes do not alter executable semantics. If source files participate, stage and hash them, then coordinate project manifest and file commits via recoverable journal, not naive multi-file rename.

Undo/redo records inverse operations with preconditions and provenance. A stale revision, external file modification or changed ABI prevents blind undo and triggers a conflict preview. Undo of device actions is not promised; physical effects are outside project-history reversal.

## Drag/drop and keyboard interaction

Pointer operations have reversible previews, clear invalid-target feedback and cancel behavior. Every action has an equivalent keyboard path where feasible: searchable palette, node selection, connection command, inspector navigation, undo/redo, command palette. Focus is restored predictably after a panel closes. Visual affordances must not be the only channel of diagnostics.

## AI proposal pipeline

```text
Selected graph scope -> explicit context disclosure -> AI proposal
 -> structured patch + source diffs + requested capabilities
 -> schema/type/effect/ownership/hardware checks
 -> human review -> atomic commit -> local verification evidence
```

An AI suggestion is never an automatically committed graph/source update. Chat history is not a substitute for project revisions, and private source/context is sent only as authorized.

## Design-time/runtime consistency

Palette and inspector consume the same component contract as the AUI compiler. Runtime ViewIdentity differs from persistent GraphNodeID and design-time instance ID. Preview executes under restricted capabilities; native hardware operations require separate operator authority. Component changes causing unsupported targets or lost state compatibility are surfaced before publish.

## Acceptance scenarios

- Insert component, connect valid ports and save/reopen without changing stable IDs.
- Invalid port direction/type and unauthorized capability show errors without mutation.
- Dragging a node updates map coordinates only, with unchanged build hash of semantic graph.
- Inspector edit changes one validated property and emits targeted diagnostics.
- AST span maps back to selected node after source reformatting.
- External source conflict and stale revision produce reviewable merge, never silent overwrite.
- Undo/redo preserves graph invariants and does not replay physical I/O.
- AI patch outside approved scope is rejected.
- Offline project supports full architecture and source editing; AI panel clearly reports disconnected.
- Thousands-of-nodes performance remains a measured goal, not a guaranteed capability.

## Open decisions

Exact change-set serialization, multi-file journal format, AST-to-graph reconciliation protocol, viewport persistence, keyboard shortcuts, accessibility implementation, plugin palette discovery and remote collaboration. No runnable editor exists.
