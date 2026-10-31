# D2–D6 — Type-Aware Source → Graph → Win64 ABI Review Trace

**Status: PROPOSED end-to-end architecture trace; not a runnable AUI program, approved v2 Graph profile, validated source-link map, signed receipt, native PE module or Phase III result.** This is the first unified walkthrough connecting [TypeReference v2](d2-d6-typeref-v2-resolution.md), [source/Graph approval](d3-source-snapshot-reconciliation.md), [signed receipts](d2-d6-signed-approval-receipt.md), [Win64 ABI](d4-win64-native-component-abi.md), [module result envelopes](d4-win64-module-and-result-descriptors.md), [D5 state/task](d3-task-result-lifecycle.md) and [D6 persistence](d6-canonical-persistence.md).

## ET1. Logical source/type scenario (conceptual only)

Imagine a later approved L4 AUI component containing an immutable input List<Row> and a command that loads one Row, returning Result<Row,String>. It renders keyed Row children, issues one L3 TaskSlot submit, handles Success/Failure/AdmissionRejected/confirmed Cancelled/ProviderUnavailable in an exhaustive match, and atomically commits the status to owned StateRevision. This **combines** L4 keyed views and L3 task outcome syntax; no verified compiler/runtime/profile currently exists.

The illustrative public record example.rows/Row has fields id: U64 and title: String. [Exact ASCII reference hashes](../../examples/aui-language/d2-typeref-v2-vectors.json) cover a proposal-only new record export and v2 List<Row> instance. The original v1 package *does not* contain this approved v2 type. The example explicitly assumes a **new** versioned extended-core/user-record package which is not in the current repository's verified immutable package lock.

Typed objects are not equal to rendered names:

- Row nominal: owner=example.rows, exportProfile=aui.export-contract/v2-record, full new public record contract digest.
- List<Row> generic: template verified aui.core/List TypeReference, ordered Row nominal TypeReference, new v2-record-args instance digest.
- Result<Row,String> and TaskOutcome<Row,String> similarly need independent typed instance contract digests, not the same native offset by coincidence.
- A copied source file plus a matching visual display name NEVER creates a qualified package export or authorized provider.

## ET2. Proposed ordered pipeline, one authority per stage

| Gate | Required validated input | Output if successful | Failure |
| --- | --- | --- | --- |
| 0 | Explicit new project/package profile, exact source and D6 lock | Candidate source/Graph typed context | SCHEMA_INVALID / CORE_PROFILE_MISMATCH |
| 1 | Approved core v2 type registry and user v2 record DAG | Exact nominal contract digests | CORE_REGISTRY_UNRESOLVED / TYPE_RECURSION_UNSUPPORTED |
| 2 | Generic template and ordered v2 nominal argument refs | List<Row>, Result/TaskOutcome instance digests | TYPE_GENERIC_DIGEST_MISMATCH |
| 3 | Complete v2 typed component and Graph semantic projection (NOT DEFINED/APPROVED YET) | Exact graph export/OperationID and meaning-bearing graph digest | GRAPH_PROFILE_UNSUPPORTED |
| 4 | Verified AUI source bytes, profile, typed source-to-Graph linker supplement, package/target ABI | Typed link digest and source ownership proof | SOURCE_STALE_REVISION / AUI_COMMAND_UNLINKED |
| 5 | [Preapproval proposal](../../schemas/aui-review-proposal.schema.json) binding graph+lock+core+typed link+effects+capabilities | Proposal digest from D6 P1 canonical bytes | APPROVAL_PROPOSAL_MISMATCH |
| 6 | Signed architecture receipt with verified signer project/target role and nonrevoked epoch | Architecture approval scope | APPROVAL_SIGNATURE_INVALID / APPROVAL_ROLE_UNAUTHORIZED |
| 7 | Pinned reproducible toolchain, approved Win64 module ABI and source manifest | Deterministic unsigned PE + build input digest | BUILD_NONDETERMINISTIC / ABI_LAYOUT_UNVERIFIED |
| 8 | PE signing/Authenticode, publisher, exact signed file SHA, independently signed executable receipt | Authenticated exact module admission | MODULE_SIGNATURE_UNTRUSTED / MODULE_APPROVAL_STALE |
| 9 | Validated module operation table and symbolic Graph OperationID, live scoped capabilities and bound result buffers | An admitted Win64 provider request using a validated AuiCallFrameV1 | ABI_HEADER_INVALID / CAPABILITY_DENIED |
| 10 | D4 terminal provider Result, exactly one TaskOutcome for original ViewIdentity/TaskSlot generation | Typed immutable owned completion message | AUI_TASK_STALE / ABI_PAYLOAD_TYPE_MISMATCH |
| 11 | One UI-owner L2 StateRevision CAS and pure derived/bind + keyed tree | Coherent committed UI state revision; renderer later presents | AUI_STATE_STALE / RENDER_PRESENT_FAILED |
| 12 | New immutable D6 snapshot/receipt index with full provenance closure and qualified FS adapter | Durable project/source review provenance, separately from runtime tasks | PERSIST_SNAPSHOT_CORRUPT / unsupported durability |

**Never skip gate 3.** TypeReference v2 and link bundle shape are not substitutes for an accepted, meaning-bearing **Project Graph v2** and v2 typed component contract. Gate 12 is a *durable source/provenance* obligation and is not atomically coupled to gate 9–11 runtime command execution.

## ET3. Typed link supplement and nonrecursive approval DAG

[Typed source-Graph link v2 schema](../../schemas/aui-typed-source-graph-link-v2.schema.json) is a separate strict **proposed supplemental bundle**, not a mutation of the old L1 link-map schema. It pins source path/SHA, source symbol, GraphNodeID, OperationID, full typed input/success/error/TaskOutcome TypeReference objects, effect/domain/capability and target ABI layout identity.

The candidate typedLinkDigest is:

    SHA256(ASCII("AELYXORA/typed-source-graph-link/v1") + 0x00 +
           D6P1CanonicalUTF8(fully verified typed link supplement))

The old sourceLinkBundleDigest remains a separate hash of source-to-Graph lexical symbol ownership. **Both** digest fields must be in the [preapproval proposal schema](../../schemas/aui-review-proposal.schema.json), preventing a source hash and signed graph from being rebound to different nominal generic arguments. The typed supplement cannot be marked GRAPH_LINKED merely because its JSON schema parses. The exact typed link source-symbol/Graph contracts must resolve under a future accepted v2 project schema.

One nonrecursive provenance DAG:

    fixed source bytes + package bytes + core registry
        -> exact type export digests -> typed Graph semantic digest
        -> source-link bundle and typed-link supplement digests
        -> preapproval proposal digest
        -> detached architecture receipt signature
        -> unsigned reproducible PE -> signed PE exact file digest
        -> detached executable receipt signature
        -> new immutable D6 snapshot index -> snapshotDigest -> HEAD

No signature signs itself; no approval payload embeds its own final snapshotDigest; no executable receipt can widen the architecture scope. If executable approval happens after a first source snapshot was published, create a **new** immutable snapshot revision rather than rewriting the old one. A signed receipt verifies source/Graph history but live operation permission must be rechecked on every call.

## ET4. Native ABI and D5 state/lifetime example

The approved target would be Win64 x86_64 with standard RCX pointer + EAX transport status, proposed 64-byte AuiCallFrameV1, 48-byte AuiSpanV1, 64-byte AuiAdmissionContextV1, and module header/operation entries/typed result envelope as specified by [D4 native layouts](d4-win64-module-and-result-descriptors.md). **No real PE or assembler exported entrypoint currently exercises them.**

D4 verifies the operation index maps to the *exact* Graph operation contract and the typed Result payload. A transport "pending" status means an accepted outstanding task, **not** provider Success(Row). A provider Failure(String) remains distinct from a pre-dispatch AdmissionRejected. A Cancelled outcome needs physical quiescence evidence. Row UI unmount/reinsert invalidates its old ViewIdentity generation without releasing active provider buffers before confirmed quiescence.

On valid completion, UI owner receives an immutable TaskOutcome with exact full type contract, and only a live matching TaskSlot may execute one atomic L2 StateRevision update; a late completion cannot update a new Row bearing the same displayed key. Rendering failure after commit does not retry an external effect.

## ET5. Design-stage negative/race matrix (all NOT-RUN)

- v1 Row passed as v2 generic argument: CORE_PROFILE_MISMATCH.
- G1/List template digest substituted for new v2 List<Row>: TYPE_GENERIC_DIGEST_MISMATCH.
- Edited source with unchanged semantic graph: source-link/proposal invalidated.
- Changed v2 record field order with reused digest: CORE_CONTRACT_DIGEST_MISMATCH.
- Typed Graph v2 not approved: GRAPH_PROFILE_UNSUPPORTED even with mathematically correct SHA-256.
- Architecture receipt signed by a release-only key: APPROVAL_ROLE_UNAUTHORIZED.
- Executable receipt references old signed PE hash: MODULE_ARTIFACT_MISMATCH.
- Signed PE valid, live capability revoked: CAPABILITY_DENIED before operation.
- Win64 ABI layout changed with identical logical TypeID: ABI_LAYOUT_UNVERIFIED.
- Task cancelled but device still running: cannot fabricate Cancelled or free buffers.
- Old ViewIdentity task terminal delivered after reinsert: AUI_TASK_STALE.
- UI state commit succeeded but frame present failed: StateRevision remains, no provider replay.
- Power loss after a device effect before durable source snapshot: no claim of atomic effect/snapshot rollback.

## ET6. Architecture review decision and remaining P0

To make this trace truly normative requires an accepted **Project Graph typed v2**, typed component contract/profile, exact complete type export set digest, source link + preapproval proposal, signed trust keys/epochs, on-disk D6 source/receipt artifact ownership, real Win64 module signing/loading and ABI tests, D5 renderer/TaskTicket implementation, and Windows/NTFS fault injection. All are **OPEN**. Source/profile design, hash references and fake signed-envelope examples are NOT an approved executable test.

## ET7. Typed v2 operation/component/graph contract stage — PROPOSED

[Project Graph v2](d2-d6-project-graph-v2-typed-contract.md) now defines separate domain-separated public operation, component, transitive type-export-set and typed graph digests. [Five reference hashes](../../examples/typed-graph-v2/typed-component-contract-vectors.json) were checked against independent Python hashlib. The new graph hash excludes source revision and label; the AUI source-link/approval and exact signed Win64 executable remain distinct downstream identities. No compiler or runtime test has been performed.
