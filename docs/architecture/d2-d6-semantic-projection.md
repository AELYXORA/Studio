# D2/D6 — Exact Semantic Graph Projection

**Status: HISTORICAL PARTIAL PROJECTION / PROPOSED, not architect-approved, implemented, or tested by AELYXORA.** This document defines historical scoped projection experiments; it is **not** the authoritative full projection of the single current architecture. [One Canonical Project Graph](canonical-project-graph-and-components.md) requires a complete unified projection covering all semantic fields. Until that full contract and byte vectors are accepted, historical digest domains must not be used to certify the current graph. [One Canonical Project Graph C9/C10](canonical-project-graph-and-components.md) exclusively owns current meaning and the current full projection/verified logical export requirements. [Project Graph](project-graph.md), [Graph Behavior](graph-behavior-contract.md) and [Export Contract Identity](d2-export-contract-identity.md) are supporting historical proposals, not competing owners. [Canonical Persistence](d6-canonical-persistence.md) retains candidate byte serialization and durability mechanics, but this historical projection's specific hash domain is not a current authority. This document does not establish a runnable compiler.

## SP1. Preconditions and identity

Only a **fully validated, lock-resolved** project may produce an authoritative semanticGraphDigest. Order: strict UTF-8/JSON and schema -> exact package objects and lock checks -> core/user type registry -> transitive exportedContractDigests -> graph, port, workflow and data-flow semantic validation -> normalized projection -> canonical UTF-8 JSON -> SHA-256.

The digest is lowercase SHA-256 of ASCII AELYXORA/semantic-graph/v1, then one zero byte, then canonical projection bytes. A structural parser that has not resolved exports may produce a **candidate display-only projection**, but must not mark its digest as the validated semanticGraphDigest.

GraphRevision, display-only labels, source file hashes, packageContentDigest, local sourceRoot, exact compiler/toolchain hashes, ViewRevision, map layout, runtime state, evidence, execution/permission tokens and command tickets are **excluded**. Meaning-bearing target constraints and public exported type/command/effect identities are **included**. A source byte change can invalidate build/evidence without changing architecture.

## SP2. Exact top-level object (first profile)

For the existing PURE 0.1-draft profile, exactly these required fields apply; arrays are present even when empty. A new, explicitly versioned 0.2-hw-draft proposal adds a resourceModel field as described in SP11; never confuse it with the pure hash projection:

| Field | Exact projection and ordering |
| --- | --- |
| format | Constant aui.semantic-graph |
| schemaVersion | 0.1-draft for pure first slice; 0.2-hw-draft only when the separately specified resourceModel is fully validated (not a product release version) |
| projectId | The project's stable authored opaque ID |
| targets | Array from SP3, sorted by id |
| packageDependencies | Objects with exact keys packageId and version; sorted by packageId,version, unique packageId in first slice |
| resolvedExports | Array from SP4, sorted by kind,typeId,contractDigest |
| nodes | Array from SP5, sorted by immutable node id |
| edges | Array from SP6, sorted by immutable edge id |
| dataFlows | Array from SP7, sorted by immutable data-flow id |
| workflows | Array from SP8, sorted by immutable workflow id |
| retiredIdentities | Objects {kind,scopeId,id} sorted bytewise by kind,scopeId,id, no duplicates/live collisions |

No permissive unknown fields. Unknown required semantic extensions need a new reviewed profile version. Object keys use P1 canonical bytewise UTF-8 ordering, all persistent local IDs use the first-profile case-sensitive ASCII grammar; string values retain their exact Unicode scalar sequences.

## SP3. Targets

Each target includes exactly id, triple, execution (as authored), sorted by id. The execution value is a constraint, **not** a runtime privilege grant. The **0.1-draft pure profile** cannot express ISA features, MMIO/IRQ/DMA ranges or OS permission scopes, and must reject hardware requirements with GRAPH_PROFILE_UNSUPPORTED. The proposed [0.2-hw-draft resourceModel](d2-hardware-resource-contract.md) adds explicit meaning-bearing constraints **in the same canonical graph**, but has no accepted target registry/adapter and cannot yet produce executable support evidence.

## SP4. Logical exports and primitive registry

Each resolvedExports entry has exactly kind (type or component), typeId (fully package-qualified), contractDigest (64 lowercase hex). These are **LogicalExportIdentity** values, not package file hashes. Every referenced user-defined type/component and its transitive field/command types must have an entry. The export digest derives from the normalized public export under [Export Contract Identity](d2-export-contract-identity.md), with no fabricated placeholder.

Core primitives (U64, U32, Bool, Bytes, F64, etc.) require a pinned core-registry version and reviewed representations. A fixture can explicitly scope a subset of these to a candidate core-registry for documentation, but that does not finalize all D3/D4 semantics.

The existing sensor example has an application node without a resolved typeRef and absent Assembly source files. It remains an **incomplete illustrative design graph**, not a full linked native baseline.

## SP5. Nodes and ports

Each node includes exactly id and kind; optional keys typeRef, target, ports are included only when present in the authored graph. Each port includes exactly id, direction, type and sorts by PortID. The authored human-readable label is **excluded**. Unknown extra semantic fields do not disappear; reject unless an explicit profile extension defines them.

Port contracts, ownership and effects must be checked against exact resolved component export types. Hardware topology-only nodes may omit typeRef; nodes intended to execute commands must link to a provider export. No diagram node can invent an operation.

## SP6. Edges

Each edge includes exactly id, kind, from and to; each endpoint includes node and optional port, with no other fields. Sort edges by EdgeID. D2 edge taxonomy/endpoint checks apply, including hosts as physical topology only. A data-flow edge must be output-port to input-port and have exactly one authorized binding. Edges never grant permissions by themselves.

## SP7. Data flows

Each dataFlow has id and channels, sorted by edgeId. Each channel has the required keys edgeId, mode, senderDomain, receiverDomain, transfer, ordering and errorPolicy; stream adds capacity and overflow; snapshot forbids both. Transfer modes, ownership and backpressure are semantic and MUST be hashed, not host defaults.

## SP8. Workflows

Each workflow includes exactly id, ownerNodeId, trigger, initialState, states, transitions, signals, scheduling, maxConcurrentInstances, onLimit, mailboxCapacity, mailboxOverflow.

The trigger is a typed data-arrival edge reference; each state has id and optional terminal, sorted by id; each transition has id/from/to/signal/action, sorted by id; each signal has id/source and its source-required references and type, sorted by id. The action object contains kind and only its permitted target references. Duplicate transitions for one state/signal and unresolved operations fail before projection.

Runtime instance state, in-flight tickets and mailbox content are **never** architectural values.

## SP9. Change-and-digest acceptance cases

| Change | Semantic graph | Package/snapshot/build |
| --- | --- | --- |
| Rename display label or move map node | No change | View or authored manifest may change; no native rebuild from view alone |
| Reorder object keys or unordered graph arrays | No change | Raw file bytes may change |
| Change data-channel capacity/transfer or workflow action | Changes | Changes |
| Change public record fields, command error type, capability requirement | Changes transitively through exportedContractDigest | Changes |
| Change only Assembly whitespace with same public contract | No change | Package/content/snapshot/build hashes change; test evidence stale |
| Change sourceRoot locator with identical package bytes | No change | Lock/snapshot change, containment must be checked |
| Delete ID and add retired-identity tombstone | Changes | Changes |
| Change live runtime permission token | No change | Runtime authorization state changes, not the graph |

## SP10. Explicit first-slice limitations

The pure 0.1-draft profile does not capture target hardware resource claims. A separate, proposed 0.2-hw-draft extension models typed requirements, but still lacks verified adapters/feature registries. User-defined units, extension semantics beyond this scoped profile, complete primitives, generic/recursive type layouts and ABI binary offsets remain open. They are **unresolved design blockers**, not details to defer invisibly to implementation. No D2/D6 gate is accepted merely by writing this candidate.

[Project Format](project-and-package-format.md) and [D2/D6 Baseline Review](d2-d6-baseline-review.md) track the remaining cross-document and implementation-readiness checks.

## SP11. Hardware resource profile — versioned semantic extension (PROPOSED)

The [D2 Hardware Resource Contract](d2-hardware-resource-contract.md) defines schemaVersion 0.2-hw-draft and a **required** resourceModel field; [project.schema.json](../../schemas/project.schema.json) gates that field to the hardware version. Under the unchanged AELYXORA/semantic-graph/v1 digest domain, the canonical projection contains all the same fields as 0.1-draft PLUS exactly resourceModel with profile aui.hardware-resources/v1, targetRequirements sorted by targetId and claims sorted by immutable claim id. Each target requirement includes addressBits, endian, privilege, featureRegistryId, adapterContractId and sorted unique isaFeatures. Each claim includes id, kind, targetId, ownerNodeId, resourceNodeId, edgeId, addressSpaceId, sharing, sorted unique requiredCapabilities and exactly one complete mmio/irq/dma/memory typed object. All numeric ranges are canonical lowercase hexadecimal strings; no target address-space alias or permission is inferred from spelling.

Pure 0.1-draft inputs, semantic projections, stored hashes and reference fixtures MUST remain byte-identical to their prior definition. An attempted hardware claim in 0.1-draft fails schema/profile validation, never silently gains an un-hashed privilege. Conversely, 0.2-hw-draft resourceModel is mandatory and every meaningful claim field participates in its graph hash; no partial projection is an authoritative digest. A changed resource range, owner, IRQ/DMA binding, privilege, ISA feature or required capability changes the hardware semantic graph projection. The extension is a **candidate compatibility profile** and cannot be declared accepted until D2/D6 target adapter, claim-ID retirement, canonical test vectors and physical proof decisions close.
