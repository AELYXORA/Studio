# D2/D3/D6 — Project Graph v2: Typed Components, Operations and Semantic Digest

**HISTORICAL EXPLORATORY DESIGN — SUPERSEDED AS ACTIVE ARCHITECTURE.** The single current design is [ONE Canonical Project Graph and Component Model](canonical-project-graph-and-components.md). Numbered experimental formats, schemas and test hashes below remain in the repository only as immutable research/provenance references. They are NOT alternative product architectures, not implementation gates and not accepted release formats. Do not develop new features by creating another numbered graph model.

**Status: PROPOSED bounded typed slice, not an accepted full graph migration, compiler or Win64 implementation.** [Original Project Graph](../../schemas/project.schema.json), [v1 semantic projection](d2-d6-semantic-projection.md), and all locked pure reference hashes stay unchanged. [TypeReference v2](d2-d6-typeref-v2-resolution.md) owns types; [D6 P1](d6-canonical-persistence.md) owns canonical JSON; [D3 source binding](d3-source-snapshot-reconciliation.md) and [Win64 ABI](d4-win64-native-component-abi.md) own later stages.

## TG1. Version and supported meaning

Strict new source format: [v2 typed graph schema](../../schemas/aui-project-graph-v2-typed-slice.schema.json); format aui.project, schemaVersion 0.3-typed-slice-draft. This is the **same canonical Project Graph** with new versioned typed component/port objects, not a competing AUI graph.

This first proposal admits Windows x64 user-mode targets, exact offline package dependencies, component-instance nodes, and typed data edges. Both workflows and dataFlows arrays are REQUIRED EMPTY. Nonempty workflows, data channels, hardware resource claims, tombstones or other v1 semantic constructs MUST NOT be silently dropped or converted. Reject GRAPH_PROFILE_UNSUPPORTED until a separate typed extension incorporates their full meaning. This bounded slice does not replace a complete v2 migration.

## TG2. Operation public contract: first digest

[Operation v2 schema](../../schemas/aui-operation-contract-v2.schema.json) is the exact canonical digest input with fields profile=aui.operation-contract/v2-typed, exportKind=operation, packageId, componentTypeId, operationId, inputs (ordered name/TypeReference v2 pairs), successTypeRef, failureTypeRef, domain, effects, requiredCapabilities, sideEffectClass, retryPolicy=never, declaredTargets.

Effects, requiredCapabilities and declaredTargets are bytewise sorted unique ASCII-ID sets. Inputs preserve declared argument order. Every typeRef must resolve to verified nominal/generic public contracts under a locked package and core registry. The provider returns Result<Success,Failure>, NOT an AUI TaskOutcome (which can also describe pre-dispatch rejection).

    operationContractDigest =
      SHA256(ASCII("AELYXORA/operation-contract/v2-typed") ||
             NUL || D6P1CanonicalUTF8(validatedOperationProjection))

The input contains neither its own digest nor parent component exportedContractDigest; OperationID is scoped by exact owner package and component TypeID. A native operationIndex is not a persistent OperationID.

## TG3. Component public contract: second digest

[Component v2 schema](../../schemas/aui-component-contract-v2.schema.json) defines exact projection with fields profile=aui.component-contract/v2-typed, exportKind=component, packageId, typeId, contractVersion, declaredTargets, ports, capabilities, commands.

Ports each contain id, direction in/out, and full TypeReference v2. Ports sorted by PortID. Commands each contain id and the already verified operationContractDigest; sorted by OperationID. Component capabilities and targets are bytewise sorted unique. A component verifier MUST check each operation owner, declared targets, effect/domain/capabilities and exact digest before accepting the component.

    componentContractDigest =
      SHA256(ASCII("AELYXORA/component-contract/v2-typed") ||
             NUL || D6P1CanonicalUTF8(validatedComponentProjection))

Implementation source hashes, package content SHA, Win64 layout, function RVA, UI labels and signer identity are excluded from logical digest; they remain independently verified requirements. Changing a meaning-bearing operation changes the component digest even if the implementation source basename and visual label stay unchanged.

## TG4. Typed graph source model

The new strict project source requires format, schemaVersion, projectId, revision, targets, packageDependencies, coreRegistryFingerprint, typeExportSetDigest, nodes, edges, workflows=[], dataFlows=[].

A node is exactly: id, kind=component-instance, packageId, componentTypeId, componentContractDigest, targetId, ports (plus optional presentation-only label). Its port entries are **checked mirrors** of the exact locked component contract, not independently authorized type definitions. Every resolved port id/direction/TypeReference must agree byte-for-byte in meaning with the component public export.

An edge is exactly: id, kind=data, from {node,port}, to {node,port}. Source must be out, destination must be in, and the full resolved TypeReference identity must match (owner, profile, nominal/generic digest). No implicit conversion, positional port matching, inferred capability or cross-domain data transfer. Unique GraphNodeIDs/EdgeIDs/PortIDs and target/dependency resolution require semantic checking beyond JSON Schema.

The [typed AUI source-Graph link supplement](../../schemas/aui-typed-source-graph-link-v2.schema.json) must independently map source symbols to GraphNodeID + OperationID + exact operationContractDigest + typed args/results. This supplement is **not** inserted into semanticGraphDigest and its own typedLinkDigest is later pinned by the review proposal; no self-referential source-to-Graph hash.

## TG5. Type export set digest: third stage

Take the transitive closure of full verified TypeReference v2 objects used by ALL nodes/ports and referenced operation inputs/success/failure, recursively including each generic template/argument and each v2 user record field type. Reject unsupported recursive or nested generics. Deduplicate by full canonical TypeReference bytes; sort the array by raw D6 canonical UTF-8 bytes for each member, not printed type name. Construct EXACT:

    {"profile":"aui.type-export-set/v2-typed-slice","types":[...verified TypeReference objects...]}

    typeExportSetDigest =
      SHA256(ASCII("AELYXORA/type-export-set/v2-typed-slice") ||
             NUL || D6P1CanonicalUTF8(typeExportSetProjection))

The coreRegistryFingerprint is separately pinned, not replaced by this set digest. Both logical hashes are distinct from signed native PE, package content digest and approval receipt.

## TG6. Graph semantic digest: fourth stage

Construct a new meaning-bearing projection with EXACT top-level keys: profile=aui.semantic-graph/v2-typed-slice, projectId, coreRegistryFingerprint, typeExportSetDigest, targets, packageDependencies, nodes, edges, workflows=[], dataFlows=[].

Sort targets by id, packageDependencies by (packageId,version), nodes by id, each node ports by id, edges by id. Exclude graph source revision and optional node label; projected node includes id,kind,packageId,componentTypeId,componentContractDigest,targetId,ports. Source graph schema excludes unapproved semantic fields so no old v1 workflow or storage claim can be lost through projection.

    semanticGraphDigestV2 =
      SHA256(ASCII("AELYXORA/semantic-graph/v2-typed-slice") ||
             NUL || D6P1CanonicalUTF8(typedGraphProjection))

No semanticGraphDigest value appears inside its own projection. This is a NEW hash domain and requires a separately versioned D6 snapshot/typed source review; it does not alter the old semanticGraphDigest/v1.

## TG7. No cycles, validation and runtime authority

Verified primitive/core/record/generic TypeReferences -> typed operation digests -> typed component digests -> verified type export closure -> typed node and edge graph -> semanticGraphDigestV2 -> source and typed source-link digests -> preapproval proposal -> signed architecture receipt -> independently approved and signed Win64 module -> D6 snapshot provenance.

Reject before hashing/execution for invalid schema/source profile, missing package lock/type export, wrong operation digest, component digest mismatch, duplicate node/port/edge, edge direction or type mismatch, unsupported target, unapproved workflows or hardware, type set mismatch, missing signed review, stale typed link, unverified ABI layout and missing live capability. Representative codes: GRAPH_PROFILE_UNSUPPORTED, GRAPH_EXPORT_UNRESOLVED, GRAPH_PORT_TYPE_MISMATCH, GRAPH_EDGE_TYPE_MISMATCH, GRAPH_EDGE_DIRECTION, TYPE_EXPORT_SET_MISMATCH, OPERATION_CONTRACT_DIGEST_MISMATCH, COMPONENT_CONTRACT_DIGEST_MISMATCH, AUI_APPROVAL_STALE.

Refer to [typed graph reference fixtures](../../examples/typed-graph-v2/) for proposed exact hash and negative cases. They are independently calculated design examples, not a native AELYXORA validator.

## TG8. P0 still open

Full typed v2 workflows, state machines, dataFlows and resourceModel/hardware, retired identities and migrations; an approved v2 component package authoring schema; target-native ABI layouts and ownership proofs; source/Graph review and signature verification; immutable D6 snapshot/NTFS durability; human acceptance of D1–D8. This is a narrow, explicit v2 graph slice, NOT a completed general-purpose Project Graph v2.
