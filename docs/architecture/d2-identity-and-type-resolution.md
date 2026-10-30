# D2 — Identity, Type Resolution and Contract Evolution

**Status: Proposed for architect review; not accepted, implemented, or native-tested.** This is the D2 **identity authority**. [Project Graph](project-graph.md) owns topology, [Graph Behavior](graph-behavior-contract.md) owns workflow/data-flow semantics, [Project Format](project-and-package-format.md) owns on-disk representation, and [Graph/AUI Contract](project-graph-aui-contract.md) owns projection/source reconciliation. The proposed examples are not a published ABI or a frozen persistence format.

## I1. Identity domains are disjoint

| Identity | Namespace / scope | Meaning | Lifetime |
| --- | --- | --- | --- |
| ProjectID | repository-independent global identifier supplied at project creation | Durable logical project | Stable across saves, migration and rename |
| GraphNodeID | one ProjectID | Specific architecture instance | Stable from creation, never reused |
| EdgeID | one ProjectID | One explicit typed architectural relationship | Stable from creation, never reused |
| PortID | one GraphNodeID | Port declaration/instance endpoint | Stable while contract instance remains; no silent reuse |
| WorkflowID | one ProjectID | One workflow *definition* | Stable, distinct from running instance |
| StateID / TransitionID / SignalID | one WorkflowID each | State machine elements | Stable inside definition; old IDs never silently reassigned |
| DataFlowID | one ProjectID | One explicitly named group of bound graph EdgeIDs | Stable |
| OperationID | one exported component TypeID and contract revision | Command export identity | Name alone never establishes provider |
| TypeID | one exact package namespace and export | Nominal logical type | Resolved through a pinned package |
| Runtime ExecutionID / generation | execution engine | Instance/ticket, not project schema identity | Ephemeral; never reused while stale callbacks may exist |
| AUI symbol ID / ViewIdentity | compiler/runtime scope | Source declaration and view instance | Not a GraphNodeID |
| Source span | file content digest + byte offsets | Diagnostic mapping only | Invalidated by source edits |
| ViewID / ViewRevision | presentation storage | Layout of canonical IDs | Independent from GraphRevision |
| EvidenceID | immutable evidence record | Observation tied to exact artifact | Never converted to a passing new revision automatically |

Identifiers from independent scopes are never compared as if interchangeable. An EdgeID may have the same short spelling as a GraphNodeID without aliasing either; serialized references carry a **typed context**.

## I2. First-slice textual identifier policy

For the proposed first-slice **persistent local IDs** (node, port, edge, workflow, state, signal, transition, data flow, operation), use the ASCII grammar:

    ID := [A-Za-z][A-Za-z0-9._-]*

Byte-exact, case-sensitive comparison; no whitespace, null bytes, slash, backslash, Unicode normalization or filesystem case folding. Leading/trailing case variations are distinct IDs (NodeA is not nodea). Do not derive IDs from filename, display label, array index, pointer, AST location or map coordinates.

AUI *source identifiers* remain governed by the D3 Unicode/NFC policy; source names are NOT persistent graph IDs. All mapping uses explicit symbol-ID-to-graph-ID records.

ProjectID and packageId have separate validation: projectId is a nonempty opaque stable string in current draft, packageId is a nonempty package namespace; both require an explicit final policy before freeze. **The ASCII rule is a D2 first-profile proposal, not a global Unicode ban.**

No newly created element may reuse an ID already used by a different element in the same scope, including a deleted ID. To make this guarantee portable across exported snapshots, retain a per-project **retiredIdentity ledger** with kind/scope/id; older revisions and tombstones remain sufficient to reject reuse. The current draft manifest proposes a retained list of tombstone tuples with fields kind, scopeId, id; scopeId is the owning GraphNodeID or WorkflowID for nested declarations, or the literal project for project-wide IDs. The tuples are sorted bytewise by (kind,scopeId,id), must be unique, and are included in the semantic projection. The exact ledger retention, signed import/migration integrity and immutability under compaction remain D6 acceptance blockers. Renaming display text does not retire identity. A deliberate *replacement* creates a new ID and an explicit migration mapping; it must not forge identity continuity.

## I3. Logical TypeID versus resolved type identity

The spelling **example.sensor/Measurement** is a package-qualified logical TypeID, not a complete proof of identity. For a compiled project the actual type registry key is:

    ResolvedType = (packageId, lockedPackageContentDigest,
                    exportedTypeID, exportedTypeContractDigest)

- An exact package lock binds package bytes and exported declarations; a version label alone does not pin a type. Two packages exporting the same display spelling but different digests are not interchangeable.
- Each exported type definition has exactly one owner in the resolved dependency graph. Duplicate export at the same namespace/TypeID -> PKG_DUPLICATE_EXPORT.
- A change in structure, units, field IDs, ownership, serialization or effect contract must change its exported contract digest. Compatibility is a separately checked relation; identical spelling is not compatibility.
- No structural duck-typing, implicit lossy conversions, silent unit conversion or implicit network fetch at graph boundaries. An explicit approved converter component or pure adapter is mandatory for distinct resolved types.
- Built-in primitive names such as U32, U64, Bool, F64 and Bytes are resolved through a pinned compiler/core type registry and its language revision, not dynamically inferred project-local package exports.
- Semantic logical TypeID equality is target-independent; native layout and calling ABI are **target-specific**. Equality does not imply identical offsets, endianness or ownership representation on two ABIs.

The current illustrative project JSON uses short TypeID strings and a package version without a real package lock or exported-contract hash. Therefore it is a **partial design example**. It may pass structural checks but cannot be declared linked, buildable or fully TypeID-verified until D6 lock resolution exists.

## I4. Component/operation/port resolution

A node TypeID references one exact component export. Each exposed PortID resolves to a declared typed port contract; each workflow command action resolves to exactly one exported OperationID of a component instance, bound to a target execution domain and capability/effect contract. The canonical resolution chain is:

    project lock -> exact package bytes -> type registry -> component export
      -> node instance -> port or command export -> graph edge/action

Mismatched port direction -> GRAPH_PORT_DIRECTION; nominal mismatch -> GRAPH_TYPE_MISMATCH; missing export -> GRAPH_EXPORT_UNRESOLVED; missing operation -> WORKFLOW_PROVIDER_UNRESOLVED; multiple ambiguous owners -> PKG_DUPLICATE_EXPORT. A source file path listed in the package but absent from disk can be **declared** in a design fixture, but a native build must fail missing-source/link verification; it must not become an implicit generated stub.

Operation compatibility includes input/output/error TypeIDs, effects, execution domain, cancellation behavior, sideEffectClass, retryPolicy and ownership-transfer rules. Changes to any of these are semantic and must invalidate compatible generated artifacts and runtime approval scope.

## I5. Contract revisions and migration

- The project schema revision, project GraphRevision, package version, export contract revision, AUI source grammar and native ABI revision are **separate version dimensions**.
- A new package version never automatically replaces a locked package in an existing project.
- A compatibility review may accept additive optional fields or safe exact conversions, but a validator may not assume that a higher SemVer number guarantees compatibility.
- A graph edit referencing a changed export produces a reviewable reconciliation patch. Source edits changing exports likewise require graph-level review. Source whitespace does not change TypeID, GraphNodeID or contract digest.
- A semantic no-op edit may advance a document/view revision but MUST NOT change the semanticGraphDigest; exact handling of a semantic project revision increment for such a no-op needs a documented transaction rule.
- Migration is an explicit old-schema -> new-schema transformation, preserving IDs or creating a mapping with user approval. Unknown required fields and lossy conversion reject with SCHEMA_UNSUPPORTED_VERSION or MIGRATION_INCOMPATIBLE.
- Existing runtime executions are pinned to their old validated graph and package snapshot. A new compatible project version does not retroactively replace their providers, override live capabilities or invalidate retained buffers.

## I6. Identity and digest separation

There are at least four independent, noninterchangeable digests:

1. **semanticGraphDigest**: meaning-bearing project graph, workflow/data-flow definitions and resolved package export identities. Excludes map coordinates and runtime observations.
2. **sourceContentDigest**: exact bytes of a source file, including whitespace, which change independently of graph semantics.
3. **packageContentDigest**: exact declared package file set and manifest, pinned in a lockfile.
4. **buildArtifactDigest**: final compiled artifact bytes plus an evidence record tying toolchain/target and inputs to their origin.

An additional **viewDigest** covers presentation-only view bytes. No artifact is considered current if its required upstream digests differ. Actual canonical algorithms and byte-level reference vectors belong to [D6 Canonical Persistence](d6-canonical-persistence.md). A declaration that two graphs look identical on screen never proves digest equality.

## I7. Positive and negative design scenarios

| ID | Candidate input/change | Expected result |
| --- | --- | --- |
| ID-01 | Rename node display label without changing GraphNodeID | Same identity, no new node |
| ID-02 | Move graph layout coordinates only | Same semantic graph digest; separate ViewRevision |
| ID-03 | Reorder keys/elements in canonicalized unordered collections | Same semantic graph digest after deterministic normalization |
| ID-04 | Delete GraphNodeID and create same ID for different instance | IDENTITY_REUSE_REJECTED |
| ID-05 | Two nodes use identical ID within one project | GRAPH_DUPLICATE_ID |
| ID-06 | Two packages export same canonical TypeID under one resolved namespace | PKG_DUPLICATE_EXPORT |
| ID-07 | Same spelling TypeID from changed pinned package content | Different resolved type identity; require compatibility decision |
| ID-08 | Change command error type without changing graph action | AUI_CONTRACT_DRIFT or WORKFLOW_SIGNAL_TYPE (according to validation stage) |
| ID-09 | Rename AUI symbol/source span while retaining explicit graph mapping | No GraphNodeID reassignment; source index refresh |
| ID-10 | Missing package source file declared in the example | Link/build failure, not silently provided code |
| ID-11 | Use undeclared target ABI for a resolved operation | PKG_TARGET_UNSUPPORTED / GRAPH_UNKNOWN_TARGET as applicable |
| ID-12 | Migration drops an unknown required graph extension | MIGRATION_INCOMPATIBLE, prior revision untouched |

All rows are *expected*, not outcomes measured by an AELYXORA implementation. D2 cannot pass until exact collision/retirement encoding, contract digest and lockfile rules align with D6 and receive explicit architect approval.
