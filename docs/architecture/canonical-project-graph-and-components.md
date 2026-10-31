# AELYXORA — One Canonical Project Graph and Component Model

**Status: PROPOSED UNIFIED ARCHITECTURE; not approved, implemented, or native-tested.** This is the single design direction. There are no product architecture editions, competing graphs or separately numbered feature models. Earlier experimental documents and frozen fixtures are historical evidence, not alternative architectures.

Owner schemas: [canonical graph](../../schemas/canonical-project-graph.schema.json), [canonical component package](../../schemas/canonical-component-package.schema.json), [canonical TypeReference](../../schemas/aui-type-reference.schema.json).

## C1. One semantic owner

The ONE Project Graph owns targets, exact declared package dependency requirements, referenced verified public component contracts, stable GraphNodeIDs/PortIDs/EdgeIDs, typed component ports and typed edges, workflows/states/signals/transitions, dataFlow channels and ownership policies, retired identities, and optional hardware resource claims. Architecture map, code tree, visual designer, runtime traces and AUI previews are projections of it; no sidecar graph gains independent durable authority. AUI StateRevision and runtime ExecutionID are NOT GraphRevision.

## C2. No product or architecture editions

The canonical graph contains format, projectId, revision, targets, packageDependencies, coreRegistryFingerprint, typeExportSetDigest, nodes, edges, workflows, dataFlows, retiredIdentities and optional resourceModel. Project revision is a concurrency/immutable-history counter, NOT an architecture edition. The graph's `packageDependencies` records exact package ID and requested version only; it is **not** the dependency lockfile or proof of actual package bytes. D6 binds exact resolved package-object digests, core registry identity and transitive export closure in a separately verified immutable lock/snapshot. Changing the locked bytes invalidates package/build/source-link evidence even when public graph semantics are unchanged; a lock mismatch always rejects execution rather than silently choosing a nearby package. Component package versions and native ABI compatibility identifiers are external dependency facts, not separate models. Workflows, dataFlows and tombstones remain meaning-bearing, even when their arrays are empty. Missing resourceModel means NO hardware claims, never implicit permission.

Past test files with old field encodings and digests stay immutable. They are historical examples, not competing product profiles. Import from such files requires explicit meaning-preserving conversion, validation and reviewed new immutable snapshots. Never rewrite historic hashes or silently discard unsupported fields.

## C3. One type system and component contract

TypeReference has nominal ownerPackageId/typeId/contractDigest or generic template/ordered nominal arguments/contractDigest. No displayed name, index, pointer, old TypeID string or different machine layout substitutes for a verified nominal identity. First bounded generic subset allows at most two acyclic nominal arguments. Exact record and generic exports must resolve from pinned packages.

An operation has a stable owner/component/OperationID, ordered typed inputs, success/error types, domain, effects, capabilities, retry policy and targets. A component pins exact verified operation contract digests and typed port exports. Graph node ports are checked mirrors, not editable independent contracts. Win64 native ABI is separate from logical public contract; provider Result and UI TaskOutcome are separate typed concepts.

**Export resolution is fail-closed.** The [canonical package schema](../../schemas/canonical-component-package.schema.json) currently describes authored `components[].commands[]` and typed ports; it does **not** store a trustworthy `operationContractDigest` field for each command. The resolver must compute and verify the logical operation/export closure from an exact offline-locked package, then verify the component's calculated public contract against `nodes[].component.contractDigest`. A workflow's `(nodeId, operationId)` is only a lookup key within that verified component export; a matching name without a verified operation, target, domain, result/error types and capabilities is NOT executable linkage. The exact canonical operation digest framing and component digest composition are **P0 OPEN**, not silently inherited from historical numbered proposals. Never accept placeholder digests as verified exports.

**Signal-to-operation closure.** For each workflow `command-success` or `command-failure` signal, resolve `(nodeId, operationId)` against the same pinned provider contract and require complete `payloadTypeRef` equality with that operation's success or failure TypeReference, respectively. A `trigger` signal's TypeReference must match the bound trigger edge payload. `control` signals have no authored payload; their allowed producers and permissions (especially cancellation confirmation) must be explicitly defined by the runtime contract and cannot be inferred from a user event or untrusted input. Publication must check the bound output edge/type and preserve error versus success outcomes. These checks are semantic requirements beyond the JSON schema.

**Authoring versus identity.** Source files and package declarations own their authored contents, but cannot independently redefine accepted graph contracts: a source/export change stages a checked Graph/source reconciliation and a new reviewed transaction. Every accepted source link binds exact GraphNodeID, OperationID when applicable, verified export identity, source bytes and dependency closure. A build may only use the reviewed immutable snapshot, not an editor buffer or a stale derived source-span index.

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

## C7. Canonical semantic projection completeness (normative design requirement)

The canonical graph specification and its schema jointly define **one** semantic source. Historical projections with numbered compatibility domains are not independent current owners. No canonical digest is authoritative until the exact complete projection, byte encoding and golden test vectors are explicitly approved.

A validator MUST classify each authored field as exactly one of: (a) semantic and included in the projection; (b) presentation or operation metadata deliberately excluded; or (c) unknown, therefore rejected. No field may be silently omitted because an older partial projection did not contain it. Reject a graph whose schema admits an authored meaning-bearing value for which the projection has no rule.

The projection must cover, transitively and deterministically:
- target identities and execution constraints, exact pinned dependency/public export closure and core-registry identity;
- live node identities, kinds, component exports, typed ports, target bindings and every authorized edge kind/endpoint;
- workflow trigger, owner, states, typed signals, transitions, actions, scheduling, mailbox bounds and cancellation policy;
- every dataFlow channel's bound edge, payload type determined through verified ports, domain, transfer, ordering, capacity, overflow and failure policy;
- resource target requirements and every typed MMIO/IRQ/DMA/memory claim, including ownership, address-space, authorization requirement and exclusivity;
- retired stable identities, including kind, scope and ID, even when the collection is empty.

Presentation coordinates, human labels, current selection, transient runtime state, GraphRevision counter and source-only byte changes do not change semantic meaning. Such changes may still alter persisted snapshot bytes, package/build identity or evidence freshness. A required empty semantic collection remains an encoded empty collection; optional resourceModel absence means **no resource claims** and must never be interpreted as default privileges.

Arrays representing *sets* are sorted by their unique stable IDs, and arrays with meaning-bearing order (e.g. operation arguments or generic parameters) preserve that order. Duplicate IDs, ambiguous ordering, unknown semantic extensions, unverified exports and missing cross-references reject before hashing. JSON serialization order, Unicode/number encoding, separators and hash-domain framing must be identical across all supported hosts; these are **open acceptance items**, not assumed fixed by historical hashes.

The graph's semantic digest is distinct from both its immutable storage snapshot identity and the signed approval receipt. Approval binds the validated graph digest, source and dependency closure and review scope without circularly hashing its own containing snapshot. A changed semantic projection invalidates dependent links, approvals and build evidence until regenerated and reapproved.

### Cross-contract rejection invariants

1. A dataFlow channel MUST bind one existing data-flow edge, from an exported output port to an exported input port; no two channels may claim the same edge. Reject missing, duplicated or mistyped endpoint relationships.
2. A queued stream or retained snapshot MUST NOT transfer a borrowed value. Future synchronous borrowing needs an explicit separate proven contract; merely choosing senderDomain equal to receiverDomain cannot extend a borrow's lifetime.
3. A workflow dispatch MUST resolve to an exact operation export authorized for the target and execution domain; a matching spelling of operationId is insufficient.
4. Terminal workflow states cannot initiate outgoing transitions; a cancellation request does not certify provider completion or reclaim its buffers.
5. Resource claims MUST reference a target, live owner/resource node and matching resource-access/ownership edge; no capability string grants native OS permission.
6. A retired stable identity MUST not collide with a live identity of the same kind and scope, including identities reintroduced by concurrent or imported edits.
7. The validator MUST reject any semantic change that cannot be represented by the canonical projection; it must not return the previous digest as if no change occurred.

## C8. Open design and proof gates

Fully approved typed workflow signal contract, data-flow payload/ownership and resource claim interplay; exhaustive semantic projection and deterministic byte normalization; native package export and effect registry; source/Graph signed review and D6 immutable closure; Win64 module/ABI/renderer/IME/NTFS durability; actual Phase III tests and explicit D1–D8 human acceptance. **Only one architecture; its acceptance remains OPEN.**
