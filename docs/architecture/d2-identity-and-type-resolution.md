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

    LogicalExportIdentity = (packageId, exportedTypeID, exportedContractDigest)
    ResolvedImplementationIdentity = (LogicalExportIdentity,
                                      lockedPackageContentDigest,
                                      targetABI, sourceContentDigests)

- [Export Contract Identity](d2-export-contract-identity.md) owns the proposed public export canonical projection and its domain-separated SHA-256. A logical contract does not change merely because an Assembly implementation's whitespace changes; exact implementation identity **does**. Both levels require an exact independently verified package lock.
- Identical export spelling with a **different exportedContractDigest** is not compatible by default. A different packageContentDigest with the same exact verified export contract retains logical type identity but requires a fresh build/evidence/permission assessment; do not mistake logical identity for equivalent executable behavior.
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

1. **semanticGraphDigest**: meaning-bearing project graph, workflow/data-flow definitions and **logical exported contract identities** (not implementation-file digests). Excludes map coordinates and runtime observations.
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
| ID-07 | Same spelling TypeID from changed pinned package source bytes | Different implementation identity; logical export identity stays the same only when independently recomputed public contract digest is unchanged. Rebuild and reverify required |
| ID-08 | Change command error type without changing graph action | AUI_CONTRACT_DRIFT or WORKFLOW_SIGNAL_TYPE (according to validation stage) |
| ID-09 | Rename AUI symbol/source span while retaining explicit graph mapping | No GraphNodeID reassignment; source index refresh |
| ID-10 | Missing package source file declared in the example | Link/build failure, not silently provided code |
| ID-11 | Use undeclared target ABI for a resolved operation | PKG_TARGET_UNSUPPORTED / GRAPH_UNKNOWN_TARGET as applicable |
| ID-12 | Migration drops an unknown required graph extension | MIGRATION_INCOMPATIBLE, prior revision untouched |

All rows are *expected*, not outcomes measured by an AELYXORA implementation. D2 cannot pass until exact collision/retirement encoding, contract digest and lockfile rules align with D6 and receive explicit architect approval.

**Normative cross-link (proposed):** [Export Contract Identity](d2-export-contract-identity.md) resolves the prior contradiction between source-only edits and semantic type identity. [Computed export contract vectors](../../examples/architecture-sensor/d2-export-contract-vectors.json) remain design fixtures, not native test results.

## I8. Hardware resource claim identity — separate stable namespace (PROPOSED)

[Hardware Resource Contract](d2-hardware-resource-contract.md) introduces ResourceClaimID under ProjectID (case-sensitive stable ASCII), distinct from GraphNodeID, resource-access EdgeID, physical address and runtime hardware handle. A 0.2-hw-draft resourceModel claim must reference existing stable nodes/edges and target; changing an address does **not** silently create or reuse a different claim ID. The [project schema](../../schemas/project.schema.json) now recognizes kind resource-claim tombstones in retiredIdentities with scopeId=project, and the canonical projection includes these tuples. Pure 0.1-draft graphs have no resource claims; they cannot use a resource-claim tombstone to fabricate hardware permission. Import/retirement and durable compaction proof remain D6 P0 until expressly accepted.


## I9. Derived generic instance export identity — current C9 single-model candidate

**PROPOSED, not accepted, not a new type/Graph namespace or public contract digest.** An instantiated generic has no authored `typeId`, while the existing [Canonical C9 resolvedExports](canonical-project-graph-and-components.md) requires `{kind,packageId,exportId,contractDigest}`. This section proposes a *deterministic compiler-derived exportId* that is **separate from the public contractDigest** and from any source display spelling, and preserves the current nominal ID authority.

### Identity-only structural projection (exact proposed candidate)

Use a **strict closed recursive tree**, structurally constrained by the [derived identity-only candidate schema](../../schemas/aui-generic-export-identity-candidate.schema.json), after D3 source namespace/import resolution, **without any contract digest**:

- Nominal leaf: exactly `{kind:"nominal",ownerPackageId,typeId}` (the two IDs are exact locked public names, not source aliases).
- Generic node: exactly `{kind:"generic",template,arguments}`, where `template` is an identity-only nominal leaf of the exact verified core/public template and `arguments` is 1–2 **ordered** identity-only nominal or generic child nodes.
- No source positions, presentation names, public contract digests, implementation SHA, native size, trait states, target/ABI, or signer data in this **identity** projection. The missing fields must still be independently verified for the contract and runtime gates; this is not a type-check result.
- Enforce the current proposed **eight** generic applications per path and **128** total type reference nodes; validate full template arity and reject recursive source/definition dependencies before constructing output. Reject invalid/ambiguous/duplicate owner or TypeID spellings and reserved namespace collisions.

**Proposed ID framing:** `identityBytes = UTF8_D6_Canonical(identityTree)`; `idDigest = SHA256(ASCII("AELYXORA/generic-export-id/canonical") || 0x00 || identityBytes)`. The derived C9 `packageId` equals the **outer template ownerPackageId** and `exportId` equals `outerTemplateOwnerPackageId + "/@inst/" + lowercaseHex(idDigest)`. Reserve `/@inst/` as a *non-authorable* generated type-identity subtree under every package namespace; an authored public `typeId` that would collide with this subtree rejects. The leading namespace component is an exact validated package identity, not parsed from an arbitrary source path or replaced with a pretty generic spelling. Reject if the package ID/TypeID policy cannot unambiguously admit this reserved generated form.

**Crucial separation:** after resolving exact core/template/argument *semantic* contracts, compute the candidate **generic instance public contractDigest** separately from the **full verified** TypeReference closure under [Canonical C10](canonical-project-graph-and-components.md); it is NOT this identity-only `idDigest`. A change in core/result semantics may preserve `exportId` while requiring a different `contractDigest`, invalidating all dependent builds/Graph links. `exportId` never includes its own public `contractDigest`, so no circularity. An identical SHA-sized string from an untrusted source cannot create a verified instance or bypass provenance. A security-relevant digest collision is a validation failure, not a reason to select a guessed alternate name.

[Two exact identity-only reference vectors](../../examples/aui-compiler-production/generic-export-identity-reference-vectors.json) were computed from D6-style candidate canonical JSON by Python hashlib and OpenSSL SHA-256; they are **arithmetic design data**, NOT accepted D2 type IDs, C9 exports or executed AELYXORA tests. Prior authored nominal IDs and immutable historical profile vectors are untouched.

**Approval P0:** sign-off of this reserved identity namespace/domain/length, actual package/TypeID validation and collision policy, canonical UTF-8 byte writing, complete inside-out semantic generic projection and public contract digests, owner/core registry authentication, source/Graph locks and end-to-end native conformance. Until then no generated `exportId` should be published as trusted.
