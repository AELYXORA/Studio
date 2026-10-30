# Architecture Map Workspace — UX Contract

**Status:** design specification; not implemented.

## Main screen

The default, always-visible work area comprises **Architecture Map** (primary canvas) and **AI Chat** (dockable companion). Neither a form designer nor an ordinary file tree may replace the architecture map as the starting surface.

Map is optimized for architecture comprehension: hierarchical grouping like a mind map, explicit typed connections like UML, hardware-aware overlays like engineering diagrams. It must support thousands of nodes eventually, but initial performance guarantees are defined by measured fixtures, not promises.

## Interaction behavior

- Opening a project restores a named map view; selection anchors inspector, source and chat context.
- Click/select a node to show type, ports, contract summary, targets and verification state.
- Expand/group/search/filter without changing the underlying architecture graph.
- Draw a connection only between valid ports; preview incompatibility before committing.
- Keyboard navigation and accessible text equivalents are mandatory for core operations.
- Chat explains selected context and offers reviewable proposals; proposed nodes/edges render as *ghost diffs* until approval.
- Source, ABI/register inspector, local diagnostics and declarative UI editor open as contextual tabs/panels, never as competing project authorities.
- Distinguish design-time state from device/runtime telemetry; never imply a diagram is observing hardware without an actual probe.

## Primary flows

**Create architecture:** new project -> choose target profile -> create module -> add components/ports -> connect -> validate -> save.

**Implement with AI:** select node/subgraph -> inspect included context -> request ASM implementation -> preview patch and test plan -> approve -> run local checks -> attach evidence to node.

**Investigate hardware issue:** select device/driver link -> inspect address/IRQ/DMA contracts -> inspect local trace/log evidence -> propose correction -> approve change; hardware reads/writes require explicit authorization.

## UX principles

- Graph first, details on demand; minimize persistent chrome.
- Show actual results rather than confidence badges: unsupported, untested, passing, failing.
- Do not use green success merely because AI wrote code.
- No silent autolayout that disrupts user-curated positions; reversible layout actions.
- No forced cloud sign-in for local editing.
- Chat and map always share selection/transaction context, not independently edited copies.

## First window acceptance

A self-rendered native Studio window loads one project fixture, shows a navigable graph and a chat panel (marked disconnected until AI authorization works), allows selecting a component and viewing contracts, and preserves layout and selection after save/reopen. This is the first usable UX slice; current Assembly validator is merely a technical prerequisite.
