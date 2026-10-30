# Project Graph — Canonical Model

**Status:** normative design specification; implementation not started.

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

## 3. Typed graph and rules

Node kinds: module, component, interface, CPU/SoC, bus, device, driver, firmware interface, protocol, storage, service and external system. A node may carry typed extension data; unknown kinds are preserved on disk but unavailable for execution until understood.

Edge kinds: dependency, call, data flow, event, interrupt, protocol, resource access, containment and ownership. Each edge has direction and a compatibility rule. Containment must be acyclic. Call and data dependency cycles require explicit design review; no blanket ban because some bidirectional protocols and state machines legitimately cycle. A data-flow binding graph without a declared delayed-state boundary must be acyclic.

Ports declare direction (input/output/bidirectional), value type, optionality, multiplicity, synchronization, and effect domain. Validate endpoint existence and kind, type compatibility, target compatibility, fan-in policy, capability authorization and resource exclusivity. Different edge kinds have different validation requirements.

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

## 6. Persistence and transactions

Use a versioned, deterministic, human-inspectable format. Exact serialization syntax is undecided; do not claim JSON or custom binary is final. Record schemaVersion separately from architecture concept. Normalize ordering for stable diffs. Never infer edges from proximity.

Atomic command transaction contract: expected revision, command list, validation diagnostics, new revision or no change. Commands include add/remove/rename node, set contract, connect/disconnect ports, set target requirements and edit presentation. Remove operations must surface affected references, with an explicit deletion policy. Undo/redo must preserve invariant validation.

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
