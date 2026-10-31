# D2/D6 — Export Contract Identity Versus Package Implementation Identity

**Status: Proposed for architect review. Not accepted, implemented or runtime-tested.** This document owns the exact candidate **logical export-contract digest**, which is intentionally different from package file-set digest and build artifact digest. [D2 Identity](d2-identity-and-type-resolution.md) owns persistent IDs; [D6 Package Integrity](d6-package-integrity.md) owns all-file package hashing; [Graph ↔ AUI](project-graph-aui-contract.md) owns reconciliation; [Binary ABI](aui-component-binary-abi.md) owns actual machine representations.

## C1. Critical invariant and earlier conflict

A project's semanticGraphDigest MUST represent its architectural meaning and explicit capability/target contracts. The existing draft previously included lockedPackageContentDigest in the equality key for a resolved logical TypeID, while also promising that a whitespace-only ASM edit would leave semanticGraphDigest unchanged. Those two definitions cannot both be true.

**Candidate resolution: two levels of resolved identity.**

- **LogicalExportIdentity** = (packageId, qualified exported TypeID, exportedContractDigest). It describes the checked public type or component **semantics**, independent of source formatting and package file location. A change to an exported type's fields, command/error types, effects, domains or supported target contract changes this identity.
- **ResolvedImplementationIdentity** = (LogicalExportIdentity, lockedPackageContentDigest, selected target triple, ABI revision, sourceContentDigests). It selects *exact implementation bytes* for build/link/verification. Changing one Assembly whitespace byte changes package/source/build identity, but **not** logical contract identity if the public contract is unchanged.
- **Deployment/approval identity** includes runtime capabilities, permission tokens and verified artifact digest, not just LogicalExportIdentity. A byte-changed implementation must be reverified and may require new execution approval even when its public signature is unchanged.

The semantic graph projection contains LogicalExportIdentity, package **constraints** and meaning-bearing target/capability contracts. It must **not** embed the complete package content hash as an architectural field solely because the current implementation package is locked. The full immutable snapshot/index and build inputs DO include the exact locked package digest. Package resolution must verify the exact lock before deriving any logical export identity.

**This resolves semantic-versus-byte provenance, not a guarantee that an unmodified public declaration implies safe or equivalent runtime behavior.** Runtime behavior still needs fresh testing for changed implementation bytes.

## C2. Export categories and type registry

Initial profile defines two distinct kinds of logical exports:

- **Type export**: nominal TypeID plus declared kind, field names/types and ordered record fields. No implicit structural duck-typing. Primitive types (U32/U64/F64/Bool/Bytes) are from a pinned language core registry revision, never untrusted project-local aliases.
- **Component export**: component TypeID, contractVersion, declared target set, typed ports, capabilities and commands. Each command has OperationID, ordered inputs, result TypeID, error TypeID, effect set, execution domain, sideEffectClass and retryPolicy.

Future generic specialization, recursive records, ABI data-layout attributes and additional effect kinds require independently versioned type rules. A record whose dependency graph has an unsupported recursive cycle rejects until the dedicated D3 type system defines canonical recursion semantics.

## C3. Candidate normalized type contract projection

For each exported user type, produce canonical JSON object with exactly these properties:

    {
      "profile": "aui.export-contract/v1",
      "exportKind": "type",
      "packageId": <packageId>,
      "typeId": <fully qualified TypeID>,
      "kind": <record|enum|... approved kind>,
      "fields": [ { "name": <name>, "type": <qualified ref>, "typeContractDigest": <64 hex> }, ... ]
    }

The first profile only supports record and a separate explicitly pinned core primitive registry. Record fields preserve declaration order. Every referenced user-defined type must already resolve to one owner under the exact package lock; include its **logical type contract digest** in the field projection. A primitive reference includes a core registry revision and its pinned type digest through the same typeContractDigest field. For a zero-field record, fields is an empty array. A type declaration with unsupported kind or unknown field representation rejects; never hash an approximate projection as final.

## C4. Candidate normalized component contract projection

For each component, produce canonical JSON with:

    {
      "profile": "aui.export-contract/v1",
      "exportKind": "component",
      "packageId": <packageId>,
      "typeId": <fully qualified component TypeID>,
      "contractVersion": <declared version>,
      "declaredTargets": [<supported-or-planned target triple strings>],
      "ports": [
        {"id": ..., "direction": ..., "typeId": ..., "typeContractDigest": ...}
      ],
      "capabilities": [<strings>],
      "commands": [
        {
          "id": ...,
          "inputs": [{"name": ..., "typeId": ..., "typeContractDigest": ...}],
          "resultTypeId": ..., "resultContractDigest": ...,
          "errorTypeId": ..., "errorContractDigest": ...,
          "effects": [<strings>], "domain": ...,
          "sideEffectClass": ..., "retryPolicy": ...
        }
      ]
    }

- declaredTargets = sorted unique target triples from package target declarations **intersected with component-declared target-specific source profiles**. Planned/supported status is readiness evidence, not an automatic right to execute; the declared triple itself is semantic. A component with no source for a target cannot claim native support.
- ports sorted bytewise by persistent PortID; commands sorted by OperationID; capabilities/effects sorted unique bytewise. Command inputs keep declared order, because call argument order can be semantic.
- Port and command type names resolve to exact LogicalExportIdentity including their typeContractDigest. An unresolvable type rejects GRAPH_EXPORT_UNRESOLVED rather than creating a fake type; conflicting package owner rejects PKG_DUPLICATE_EXPORT.
- Source path, file byte hashes, source ownership, current package status (planned/supported), document whitespace, and local sourceRoot are NOT component contract fields. The package digest and source ownership remain separate mandatory checks for build and AI approval.
- ABI-specific alignment, registers, pointer width, lowered calling convention, memory offsets and object symbol address do NOT belong to this target-neutral logical projection. They are distinct target ABI contracts and required build inputs.

## C5. Digest framing and semantic projection

For a validated normalized export object, take P1 canonical JSON bytes from [D6 Canonical Persistence](d6-canonical-persistence.md); compute:

    exportedContractDigest = SHA256(
       ASCII("AELYXORA/export-contract/v1") || byte(0) || canonicalExportBytes
    )

Encode as 64 lowercase hexadecimal characters. For any component or TypeID referenced by the semantic graph, serialize its LogicalExportIdentity **including** exportedContractDigest; do not serialize the unrelated packageContentDigest as the semantic name.

Example invariant:

    change only ASM whitespace:
      exportedContractDigest identical
      semanticGraphDigest identical
      sourceContentDigest DIFFERENT
      packageContentDigest DIFFERENT
      snapshotDigest DIFFERENT
      build-input identity DIFFERENT

    change Measurement record fields or Decode result:
      exported type/component contract digest DIFFERENT
      semanticGraphDigest DIFFERENT for dependent project
      new graph reconciliation and explicit review REQUIRED

    change only Architecture Map coordinates:
      viewDigest / ViewRevision DIFFERENT
      semanticGraphDigest identical
      sourceContentDigest identical
      generated native build input unchanged

Record output contract changes must propagate to each referring component's projection by its typeContractDigest (transitive dependency closure). No stale digest may be reused after a type change.

## C6. Stage-specific validators and evidence

1. Strict manifest and lock structural parsing, canonical bytes and package content verification.
2. Unique package/export owner and nominal type registry resolution; verify all referenced type digests.
3. Form export projections using the exact field whitelist; compute exportedContractDigest.
4. Resolve Project Graph ports and workflow signals against export identities; reject stale or mismatched contracts.
5. Create semantic projection and semanticGraphDigest, with no implementation file byte hashes embedded.
6. For actual build, *separately* match exact package lock, source file inventory, target ABI and toolchain.
7. For execution, *separately* check live permissions and verified artifact identity; source changes cannot inherit a previous security pass.

Error distinctions: GRAPH_EXPORT_UNRESOLVED, WORKFLOW_SIGNAL_TYPE, AUI_CONTRACT_DRIFT, PKG_DIGEST_MISMATCH, SOURCE_STALE_REVISION, PKG_DUPLICATE_EXPORT, ABI_TARGET_MISMATCH. AI text is never verification evidence.

## C7. Proposed reference acceptance scenarios (NOT-RUN by AELYXORA)

- C-01: reorder object keys in type/component manifest, same export digest.
- C-02: reorder component declarations, same individual component digests (package content digest may change due order-preserving manifest policy).
- C-03: change source code whitespace, same export/semantic digests but different package/snapshot/build bytes.
- C-04: reorder component ports, same digest; reorder call inputs, different digest.
- C-05: change only package target status planned -> supported, same logical export digest, and STILL no test success asserted.
- C-06: add/remove target triple or required capability, different export digest.
- C-07: change referenced Measurement field, propagate new type digest into Decode component contract and Project Graph semantics.
- C-08: duplicate command ID/port ID, reject before hashing.
- C-09: unresolvable imported user type, reject; do not hash fabricated placeholder.
- C-10: change ABI target layout with same logical type contracts, different target build/ABI identity; no cross-ISA byte compatibility claim.
- C-11: source-only AI patch against stale source digest, SOURCE_STALE_REVISION even when graph digest still matches.
- C-12: type dependency cycle unsupported by first profile, explicit TYPE_RECURSION_UNSUPPORTED.

**Blocking approval questions:** exact first-profile TypeKind set and primitive core registry IDs; formal definition of component-target support; complete project semantic projection; manifest schema extension rules; inheritance/generics/recursion policy; independent native canonicalizer and exact fixture vectors; choice of first target ABI. This candidate does not mark D2/D6 accepted.

## C8. Separate proposed D3 core type digest domain — no v1 migration implied

[Versioned Core Export Digest](d2-d3-core-export-digest-contract.md) proposes a strictly separate aui.export-contract/v2-core profile and normalized core type registry projections. It does NOT change the existing aui.export-contract/v1 user record/component canonical frames, reference vectors, or the locked pure fixture. A v1 record referring to a future v2-core type needs explicit **approved mixed-profile compatibility** before field typeContractDigest resolution; otherwise CORE_PROFILE_MISMATCH. [13 design-only hash vectors](../../examples/aui-language/d2-d3-core-export-digest-vectors.json) are not an AELYXORA native validator or approved executable registry. Logical export identity remains distinct from [Win64 native ABI layout](d4-win64-native-component-abi.md) and exact source/package bytes.

## C9. G1 specialization and v1 public-contract preservation

[Bounded G1 instance contracts](d2-d3-generic-instantiation-identity.md) use a separately domain-separated digest over template identity and ordered argument digests. They are not D2 user type/component export v1 objects, and must not be spliced into v1-only record field names without an accepted typed-reference compatibility profile. [v1/v2 policy](d2-d6-core-profile-compatibility.md) requires a new immutable source/lock/Graph snapshot and explicit review before any migration. Existing zero-field record/component vectors remain byte-identical and are not recomputed.

## C10. Proposed typed v2 references are NOT v1 fields

[TypeReference v2](d2-d6-typeref-v2-resolution.md) proposes separate aui.export-contract/v2-record and aui.generic-instantiation/v2-record-args domains with explicit type-owner/export digests, not silent v1 record/component field substitutions. [Signed review receipts](d2-d6-signed-approval-receipt.md) may authorize a **new** exact source/Graph migration but never rewrite existing v1 exportedContractDigest vectors. The original v1 Project Graph semantic hash has no approved v2 typed node/port projection, so v2 executable linkage fails GRAPH_PROFILE_UNSUPPORTED until a versioned Graph profile is accepted.

## C11. Typed v2 operation and component digest domains (PROPOSED)

[Typed Project Graph v2](d2-d6-project-graph-v2-typed-contract.md) defines separate exported operation and component SHA-256 projections over exact TypeReference v2, effects and capabilities. Component identity includes verified operation digests; the graph pins component digests and exact port mirrors. [Five reference vectors](../../examples/typed-graph-v2/typed-component-contract-vectors.json) are not AELYXORA executable validation. Existing v1 exports and pure graph hashes remain unchanged.
