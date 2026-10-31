# D2/D3/D6 — Versioned TypeReference v2 and Transitive Typed Export Resolution

**HISTORICAL EXPLORATORY DESIGN — SUPERSEDED AS ACTIVE ARCHITECTURE.** The single current design is [ONE Canonical Project Graph and Component Model](canonical-project-graph-and-components.md). Numbered experimental formats, schemas and test hashes below remain in the repository only as immutable research/provenance references. They are NOT alternative product architectures, not implementation gates and not accepted release formats. Do not develop new features by creating another numbered graph model.

**Status: PROPOSED design; NOT approved, implemented, typechecked by AELYXORA, or admitted in existing 0.1-draft project schemas.** [v1 public export](d2-export-contract-identity.md), [project schema](../../schemas/project.schema.json), [component-package schema](../../schemas/component-package.schema.json), [locked pure fixture](../../examples/locked-pure-reference/README.md), v1/v2-core and G1 vectors all remain unchanged. [D3 core registry](d3-core-registry-value-contract.md), [G1](d2-d3-generic-instantiation-identity.md) and [D6 canonical P1](d6-canonical-persistence.md) retain their own ownership.

## TR1. Exact versioned boundaries

New TypeReference profile **aui.type-ref/v2-draft** is a strict typed JSON representation, NOT a replacement for original v1 nominal TypeID fields. New record export profile **aui.export-contract/v2-record** replaces each v1 string field type with a v2 TypeReference only inside a separately versioned future package/Graph. User-record-aware generic profile **aui.generic-instantiation/v2-record-args** supports core or newly validated v2 record nominal arguments, without nested generic/recursive arguments in this first slice. G1 v1-draft supports only core primitive args and remains unchanged.

## TR2. Two closed reference variants

[TypeReference structural schema](../../schemas/aui-type-reference-v2.schema.json) uses oneOf with no additional fields:

Nominal: profile=aui.type-ref/v2-draft, kind=nominal, ownerPackageId, typeId, exportProfile (aui.export-contract/v2-core or aui.export-contract/v2-record), contractDigest (64 lowercase SHA hex).

Generic: profile=aui.type-ref/v2-draft, kind=generic, instanceProfile=aui.generic-instantiation/v2-record-args, template (nominal TypeReference), arguments (ordered array of 1 or 2 NOMINAL TypeReferences), instanceDigest (64 lowercase SHA hex).

A core nominal MUST have ownerPackageId=aui.core and match exact pinned core-registry TypeID/digest. A user record MUST resolve an exact v2-record owner/package/TypeID/digest from the verified lock. Same name does not imply same nominal identity. Generic template MUST be a validated aui.core/List, Result or TaskOutcome with arities 1/2/2 and source gating; argument ownership/digests verified transitively. A generic object cannot contain nested generic arguments or alias a native pointer. The generic has no invented display typeId: full template + ordered verified arguments + digest are its identity.

## TR3. v2 record export projection and digest

[Record v2 schema](../../schemas/aui-record-export-v2.schema.json) requires exactly profile=aui.export-contract/v2-record, exportKind=type, packageId, typeId, kind=record, and fields containing ordered {name,typeRef} objects. This object itself is the exact **meaning-bearing projection**; it excludes source bytes, ABI offsets and UI state. Validate field-name uniqueness, exact type references, owner and acyclic dependencies first.

    recordDigest = SHA256(
      ASCII("AELYXORA/export-contract/v2-record") + 0x00 +
      D6P1CanonicalUTF8(recordProjection)
    )

Record fields preserve declaration order. A zero-field v2 record is legal but MUST NOT reuse the digest of an equal-looking v1 record (domain separation). Source reformatting with equivalent exported fields preserves the logical hash but changes source/package/build identities. Reject duplicate names, unknown owners and recursive graphs. Use explicit gray/black DFS over exact owner+TypeID dependency nodes; recursion through generic arguments is also a cycle, never a placeholder hash.

## TR4. v2 user-record-aware generic instantiation projection

For a validated generic TypeReference, compute the digest over a separate object with EXACT fields: profile=aui.generic-instantiation/v2-record-args, exportKind=generic-instantiation, template=verified nominal TypeReference, arguments=ordered array of verified nominal TypeReferences. InstanceDigest is NOT included in this digest input.

    instanceDigest = SHA256(
      ASCII("AELYXORA/generic-instantiation/v2-record-args") + 0x00 +
      D6P1CanonicalUTF8(instanceProjection)
    )

All references and source gates must resolve under an approved new core/user v2 profile. Existing G1 generic hashes do not change or become equivalent merely because printed type names are the same. Row containing List<Row> is recursive and rejects; List<List<Row>> is nested and rejects in the bounded candidate even if not recursive. List<Row> where Row is a verified acyclic **v2 record** is a conceptual positive design case, while Row from the v1 project package is incompatible until explicitly migrated. See [v2 reference vectors](../../examples/aui-language/d2-typeref-v2-vectors.json).

## TR5. Resolver, graph, and D6 source/approval pipeline

1. Check explicitly selected new package/project/source profile, not silently reinterpret legacy manifest fields. Existing [project.schema.json](../../schemas/project.schema.json) still rejects v2 meaning-bearing fields.
2. Verify offline exact lock/source bytes/core registry and public export ownership. Resolve core nominals and record DAG topologically, then generic instances and dependent component contract types.
3. Validate referenced digests independently, not by trusting supplied text; no implicit type conversions, layout casts or v1/v2 aliases.
4. Require a **separately versioned typed component/Graph semantic projection** that expresses full TypeReference objects for port/command/result/error and runtime effects. v1 component contract and semanticGraphDigest/v1 cannot silently hash this new content. Without future approved typed Graph schema, return GRAPH_PROFILE_UNSUPPORTED.
5. Store approved source-to-Graph bundle, exact typed registry/export/lock bytes and [signed review receipt](d2-d6-signed-approval-receipt.md) in a **new immutable D6 snapshot**. Record receipt without circularly hashing its own final snapshot digest; use a committed pre-approval proposal manifest and detached receipt.
6. D4 Win64 LayoutID, signed module and exact current live capabilities remain additional independent conditions for dispatch.

A future v2 component schema, user-record migration, target type layout and complete package fixture are unresolved **P0**, so none of the source samples becomes executable through this document.

## TR6. Error precedence and acceptance cases (all NOT-RUN)

Strict schema/profile -> locked owners/type registry -> record dependency DAG -> generic arity/arguments/digest -> typed component+Graph -> authenticated approval -> target native ABI -> live capability.

- Copy template digest into a List<Row> instance: TYPE_GENERIC_DIGEST_MISMATCH.
- Swap Result<U32,String> arguments but reuse old digest: TYPE_GENERIC_DIGEST_MISMATCH.
- Reference only-v1 record Row inside v2 generic: CORE_PROFILE_MISMATCH.
- Field refers to itself, including through List: TYPE_RECURSION_UNSUPPORTED.
- Missing package/type export, same display name different owner: GRAPH_EXPORT_UNRESOLVED.
- Generic inside generic argument: TYPE_GENERIC_PROFILE_UNSUPPORTED.
- Insert v2 object in an old v1 package field: SCHEMA_INVALID.
- Reuse logical type digest after native layout change: rebuild/re-approve native ABI, do not rehash logical contract.
- Source or Graph changed since review: AUI_APPROVAL_STALE.

**P0:** approve typed v2 project/package/component/Graph schemas, complete record+generic type resolution, source/Graph signed receipt, D6 immutable snapshot vectors, native Win64 ABI and proof, migration, Unicode canonical vectors and architect sign-off.

## TR7. First bounded typed Project Graph v2 consumer (PROPOSED)

[Typed Project Graph v2](d2-d6-project-graph-v2-typed-contract.md) now defines a **separate** 0.3-typed-slice-draft project format, public operation digest, component digest, transitive TypeReference export set and new semanticGraphDigest domain. [Typed fixture](../../examples/typed-graph-v2/typed-component-contract-vectors.json) demonstrates v2 Row/List<Row> in exact port and command signatures, but is design-only. The source schema requires empty workflows/dataFlows and forbids hardware resourceModel; **do not migrate** v1 semantics by omission. A signed [typed source-to-Graph link](../../schemas/aui-typed-source-graph-link-v2.schema.json) and native ABI verification are still required before any command can run.
