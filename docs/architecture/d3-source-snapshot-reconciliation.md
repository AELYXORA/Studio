# D3 ↔ D2/D6 — Source Profile, Graph Link and Immutable Approval Snapshot

**Status: PROPOSED; not architect-approved, implemented or executable.** This document owns the integration of advanced AUI (L2 State, L3 Task) with [Project Graph](project-graph-aui-contract.md), [D6 Immutable Snapshots](d6-canonical-persistence.md), [Export Contract Identity](d2-export-contract-identity.md), [L2 State](d3-state-derived-binding-contract.md) and [L3 Task](d3-task-result-lifecycle.md). A source file, verified hash, design-only link JSON, or human-readable approvalStatus property alone is **not** executable authorization.

## R1. Separate identities

- Canonical ProjectID / GraphNodeID / PortID / OperationID and nominal exported TypeID stay in the Project Graph. Source symbol StableSymbolID is a separate compiler-scoped identity. Source spans/filenames are unstable references and never generate GraphNodeID.
- sourceSha256 pins **exact original AUI UTF-8 bytes** (including comments and line endings); source profile token (aui.source/l1/v1, aui.source/l2-state/v1, aui.source/l3-async/v1) pins syntax/semantics, but none is accepted by default. Changed source formatting makes a previous source-link artifact stale, even if semanticGraphDigest is unchanged.
- semanticGraphDigest pins meaning-bearing architecture and public exported contract identities; source file hash, local StateRevision, TaskTicket, current view coordinates and runtime permissions are not architectural fields.
- packageContentDigest, source SHA-256, compiled artifact digest and ABI version remain distinct. A match of public logical type identity alone cannot grant execution of modified implementation bytes.

## R2. Candidate reviewable source-to-graph bundle

Proposed bundle format = aui.source-link-bundle, version 0.2-design-draft; structural [schema](../../schemas/aui-source-link-bundle.schema.json) is proposed, not an approved wire format. The bundle contains:
1. ProjectID, exact GraphRevision, semanticGraphDigest, exact package-lock byte digest and source registry/core type revision.
2. All sourceFiles with relative path, SHA-256 and **explicit source language profile** (L0, L1, L2, L3), sorted by path; no duplicate/casefold-colliding paths; source ownership is validated from snapshot index.
3. Bindings from exact source qualified symbol and StableSymbolID to GraphNodeID, exported component TypeID, exportedContractDigest and required OperationID or component-owned internal state. State slot and TaskSlot IDs are **local source IDs**, never invented public Graph ports.
4. Effect/domain, exact input/result/error nominal TypeIDs, target and capability expectations. Missing D2 owner, export lock, provider or target is an error; source-scope Task itself does not automatically become a graph command export.
5. A content SHA-256 of the entire bundle **without any approval receipt**. Bundle digest is a candidate review fingerprint, not a signature or published snapshotDigest. Domain proposal: ASCII AELYXORA/source-link-bundle/v1 + NUL + canonical P1 JSON bytes of the complete bundle. The bundle's digest is stored outside the bundle to avoid self-reference.

A separate immutable approval receipt binds the bundle content digest, exact project/graph/lock/source snapshot state, accepted target and capability scope, reviewer/decision and any signed identity evidence. **An approvalStatus string in JSON is not sufficient**: software must prove that the receipt came from the review/authorization service and has not been revoked. The exact identity/signature and review service remain P0. Changing a resource claim, source byte, ABI-linked package, export contract or source profile invalidates the relevant receipt. An approved review of AUI UI state changes does not automatically authorize new hardware effects.

The existing [L1 link-map schema](../../schemas/aui-command-link.schema.json) has linkFormat 0.1-draft and approvalStatus=proposed ONLY, which is correct for its illustrative use. It **cannot** represent a production-approved binding and must not be silently treated as approved. The proposed new bundle is NOT a backward-compatible mutation of that legacy file; migration and coexistence must be explicit.

## R3. D6 immutable snapshot inclusion and commit

Before GRAPH_LINKED can be asserted as an observed future stage, an approved transaction must:
1. Verify exact resolved packages and graph semantic digest under the selected source profile and primitive registry, plus source ownership. Human-owned source is never silently overwritten.
2. Stage all AUI text files, source-to-graph bundle and approval receipt as **exact owned sourceFiles bytes** in the new snapshot index, with SHA-256 and sorted portable paths. No derived cache may replace those bytes.
3. Recompute source-link bundle bytes/hash, receipt content proof and graph binding against the *same* candidate snapshot. The snapshot index references every required byte; the new index changes snapshotDigest. No approval object may recursively include its own final snapshotDigest if snapshot index already hashes the approval object.
4. Perform expected GraphRevision / source digest / ViewRevision CAS and exact package lock/content checks, preserving immutable history and retired identity ledger. If source or graph changed since review, abort with AUI_LINK_STALE / SOURCE_STALE_REVISION, never rebase permission automatically.
5. Publish only through the selected D6 host filesystem's verified capability. HEAD validity requires full source/link/receipt/package closure. Compiler output can be emitted only after all static and ownership stages; physical runtime permissions are rechecked at actual dispatch.

The existing [locked pure reference](../../examples/locked-pure-reference/README.md) does not contain the AUI L1/L2/L3 source and link bundle in its immutable snapshot. Do not call those examples verified GRAPH_LINKED or ABI_LINKED. A future end-to-end fixture must construct a **new** pinned snapshot and record exact bundle/receipt/source reference vectors without altering or lying about the earlier pure reference baseline.

## R4. UI-local state does not mutate architecture

Local StateRevision tracks L2 values for one component generation, never Project Graph revision. StateSlotID and TaskSlotID are stable within verified compiler symbol origins; names/positions/array offsets cannot serve as global resource ID. Old ViewIdentity generation cannot inherit a provider TaskTicket or receive its delayed result. A UI state commit does not auto-update D6 project manifests, package locks or device capabilities.

If an AUI user edits a public component port/command/effect/target declaration, the compiler computes a **proposed** graph diff for human review. If the edit affects only private local state/derived UI or layout, the graph semantic digest may stay identical but source bytes, bundle and snapshot still change. In neither case may AI changes be auto-committed without reviewed source ownership and graph/source authority.

## R5. Cross-owner negative cases

| Trigger | Primary diagnostic |
| --- | --- |
| Source bytes differ from bundle hash | AUI_LINK_STALE |
| Public export digest differs from verified package | AUI_COMMAND_CONTRACT |
| Source TaskSlot treated as GraphNodeID | AUI_SOURCE_GRAPH_CONFLICT |
| Unbound command provider or wrong domain/target | AUI_COMMAND_UNLINKED / AUI_TARGET_UNSUPPORTED |
| L3 profile used under L0/L1 grammar | AUI_PROFILE_UNSUPPORTED |
| Approval receipt only contains a textual approved label | AUI_APPROVAL_UNVERIFIED |
| Receipt graph/source/lock digest does not match candidate | AUI_APPROVAL_STALE |
| Missing AUI bytes or receipt in immutable snapshot | PERSIST_SNAPSHOT_CORRUPT |
| User source edit races a new graph revision | SOURCE_STALE_REVISION |
| Old view receives completion after new generation | AUI_TASK_STALE |
| Resource claim exists but live capability absent | CAPABILITY_DENIED, no device effect |

## R6. Open review gates

The bundle schema is **a first structural shape**, not a signed authorization system. Stable compiler SymbolID derivation, exact signature/receipt verification, source ownership change approvals, end-to-end D6 immutable snapshot fixtures, versioned core registry, package/target proof, state/result/focus rendering and native D4/D5/Phase III tests all remain uncompleted P0. No design document grants an external provider or raw Assembly execution privilege.
