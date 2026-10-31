# AELYXORA — One Canonical Project Graph and Component Model

**Status: PROPOSED UNIFIED ARCHITECTURE; not approved, implemented, or native-tested.** This is the single design direction. There are no product architecture editions, competing graphs or separately numbered feature models. Earlier experimental documents and frozen fixtures are historical evidence, not alternative architectures.

Owner schemas: [canonical graph](../../schemas/canonical-project-graph.schema.json), [canonical component package](../../schemas/canonical-component-package.schema.json), [canonical TypeReference](../../schemas/aui-type-reference.schema.json).

## C1. One semantic owner

The ONE Project Graph owns targets, dependency locks, exact public component contracts, stable GraphNodeIDs/PortIDs/EdgeIDs, typed component ports and typed edges, workflows/states/signals/transitions, dataFlow channels and ownership policies, retired identities, and optional hardware resource claims. Architecture map, code tree, visual designer, runtime traces and AUI previews are projections of it; no sidecar graph gains independent durable authority. AUI StateRevision and runtime ExecutionID are NOT GraphRevision.

## C2. No product or architecture editions

The canonical graph contains format, projectId, revision, targets, packageDependencies, coreRegistryFingerprint, typeExportSetDigest, nodes, edges, workflows, dataFlows, retiredIdentities and optional resourceModel. Project revision is a concurrency/immutable-history counter, NOT an architecture edition. Component package versions and native ABI compatibility identifiers are external dependency facts, not separate models. Workflows, dataFlows and tombstones remain meaning-bearing, even when their arrays are empty. Missing resourceModel means NO hardware claims, never implicit permission.

Past test files with old field encodings and digests stay immutable. They are historical examples, not competing product profiles. Import from such files requires explicit meaning-preserving conversion, validation and reviewed new immutable snapshots. Never rewrite historic hashes or silently discard unsupported fields.

## C3. One type system and component contract

TypeReference has nominal ownerPackageId/typeId/contractDigest or generic template/ordered nominal arguments/contractDigest. No displayed name, index, pointer, old TypeID string or different machine layout substitutes for a verified nominal identity. First bounded generic subset allows at most two acyclic nominal arguments. Exact record and generic exports must resolve from pinned packages.

An operation has a stable owner/component/OperationID, ordered typed inputs, success/error types, domain, effects, capabilities, retry policy and targets. A component pins exact verified operation contract digests and typed port exports. Graph node ports are checked mirrors, not editable independent contracts. Win64 native ABI is separate from logical public contract; provider Result and UI TaskOutcome are separate typed concepts.

## C4. Workflows, dataFlows and hardware are FIRST-CLASS in the same graph

Workflow: one explicit owner, trigger edge, initial state, unique states/signals/transitions, bounded per-ExecutionID mailbox, deterministic same-state/signal transition and one terminal publication. Terminal states have no outgoing edges; unreachable states reject. Requesting cancellation is not confirmed quiescence. Dispatch refers to an exact authorized component operation, never an arbitrary function address.

DataFlow: one declared binding per actual compatible data-flow edge, stream/snapshot mode, sender/receiver domains, move/copy/borrow policy, FIFO/latest ordering, capacity, overflow and error handling. Cross-domain borrowed values require independently proven ownership, otherwise reject. No edge implies automatic network/device I/O.

Hardware: targetRequirements and MMIO/IRQ/DMA/memory resource claims refer to real owner/resource nodes, target IDs and resource-access/ownership edges. Capabilities are declarative; runtime needs a qualified target adapter and live scope. No desktop user-mode graph can grant itself kernel/bare-metal permissions. Device buffers survive UI unmount until provider completion/quiescence.

Retired IDs: tombstones prevent accidental ID reuse and incorrect binding of old completions, resource owners or source links to new graph entities.

## C5. One dependency and semantic hash DAG

Immutable source/package bytes and core registry -> verified nominal/record/generic types -> public operation contracts -> component contracts -> transitive type-export set -> validated FULL graph -> canonical semanticGraphDigest -> typed AUI source-to-Graph link -> nonrecursive review proposal and approval -> verified native artifact -> new immutable D6 snapshot.

The complete future graph projection MUST include every meaning-bearing workflow, dataFlow, hardware claim, retired ID and typed graph edge. Unknown meaning rejects. No self-hash or approval referring to its own enclosing final snapshot. The final public canonical byte/hash profile remains P0 awaiting one architect decision; do not fabricate a new golden hash until ALL field semantics are frozen. Frozen earlier SHA fixtures remain reference-only.

## C6. Fail-closed validation ordering

Strict schema -> target and offline package closure -> complete TypeReference and export identity -> node/port mirror -> topology/edge direction -> workflow signals/reachability/cancellation -> dataFlow ownership/capacity -> resource claims/target privileges -> full graph semantic projection -> AUI typed source link -> authentic architect and executable approval -> native ABI and LIVE capability. Schema validation or SHA arithmetic alone never authorizes execution.

## C7. Open design and proof gates

Fully approved typed workflow signal contract, data-flow payload/ownership and resource claim interplay; exhaustive semantic projection and deterministic byte normalization; native package export and effect registry; source/Graph signed review and D6 immutable closure; Win64 module/ABI/renderer/IME/NTFS durability; actual Phase III tests and explicit D1–D8 human acceptance. **Only one architecture; its acceptance remains OPEN.**
