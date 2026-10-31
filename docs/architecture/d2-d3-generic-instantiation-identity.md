# D2/D3/D6 — Closed Generic Instantiation Identity (Candidate G1)

**HISTORICAL EXPLORATORY DESIGN — SUPERSEDED AS ACTIVE ARCHITECTURE.** The single current design is [ONE Canonical Project Graph and Component Model](canonical-project-graph-and-components.md). Numbered experimental formats, schemas and test hashes below remain in the repository only as immutable research/provenance references. They are NOT alternative product architectures, not implementation gates and not accepted release formats. Do not develop new features by creating another numbered graph model.

**Status: PROPOSED / OPEN.** This document is a *design* refinement of [core export v2](d2-d3-core-export-digest-contract.md), [D3 logical registry](d3-core-registry-value-contract.md), and [D6 canonical writer](d6-canonical-persistence.md). It does **not** modify the exportedContractDigest/v1 user-record/component format, existing snapshot hashes or the 13 previously calculated template digests. No native compiler/generic layout tests have run.

## GI1. Minimal profile and identity

Candidate token **aui.generic-instantiation/v1-draft** applies only to the exact approved-in-future extended aui.core registry; today its inputs are *unapproved reference vectors*. For the bounded first extended profile, generic templates are **List<T>**, **Result<T,E>**, and **TaskOutcome<T,E>**. Each template's exact arity and template exportedContractDigest must resolve from the same pinned registry. Type arguments must be **non-generic, fully resolved nominal core types** with complete type contract digests in this bounded profile. A user record, a nested generic argument, recursive specialization, type variable, alias, optional unknown trait or mixed v1/v2 argument is **not** accepted under this specific slice. This limitation means the L4 List<Row> sample remains illustrative until an explicit compatible user-record extension is accepted.

Canonical instantiated identity is a *tuple*, not a pretty-printed name, source path, pointer or invented GraphNodeID:

- registryId: **aui.core/extended-0.2-draft**;
- packageId: **aui.core**;
- templateTypeId and verified **templateContractDigest**;
- ordered array of exact argument **typeId** + **typeContractDigest** pairs;
- explicit generic instantiation profile ID and resolved feature gate.

No identity equivalence based on String names alone. Aliases must resolve to the exact original nominal owner or reject. Ordered type arguments are meaningful: Result<U32,String> differs from Result<String,U32>. The logical digest excludes target ABI, native LayoutID, allocator, source formatting, binary file hash and runtime TaskTicket.

## GI2. Exact canonical projection and SHA-256

The validated projection contains **exactly** these keys:

| Key | Meaning |
| --- | --- |
| profile | literal aui.generic-instantiation/v1-draft |
| exportKind | literal generic-instantiation |
| packageId | literal aui.core |
| registryId | literal aui.core/extended-0.2-draft |
| templateTypeId | exact fully qualified nominal template ID |
| templateContractDigest | exact referenced 64-hex digest from [core export vectors](../../examples/aui-language/d2-d3-core-export-digest-vectors.json) |
| featureGate | template's exact L0/L1, L3 or L4 gate |
| typeArguments | ordered array of exactly {typeId,typeContractDigest} objects |

The exact [structural schema](../../schemas/aui-generic-instantiation.schema.json) owns shape; semantic checks require every referenced digest to agree with the pinned core registry, arity and allowed template, and all arguments to be approved primitive/core **non-generic** type contracts. The normalized projection omits presentation/source spelling and toolchain state. All object keys are canonical bytewise UTF-8 sorted, no extra whitespace; typeArguments order is **preserved** and must never be sorted.

    genericInstanceDigest = SHA256(
      ASCII("AELYXORA/generic-instantiation/v1") ||
      byte(0) || D6P1CanonicalUTF8(projection)
    )

This hash identifies a specific *logical instantiated type*. It is not equal to the template exportedContractDigest. Its usage in a future D2 referring field must be guarded by a separately approved **typed-reference schema version**; the existing v1 string typeId field cannot silently be reinterpreted as a runtime generic descriptor.

## GI3. Trait derivation and variance

For this narrow candidate: **invariant** arguments for all three templates; no subtyping/co/contravariance, wildcard/default parameter, reflection, structural duck typing, implicit numeric/String conversion or native pointer reinterpretation. The instantiated logical Send proof requires the template's declared conditional Send policy **and every reachable value argument's verified ownership/Send proof**. For List<T>, the list's immutable owner/retain semantics must also be verified; a U64 copy proof does not prove a List<U64> pointer safe.

A generic Result<T,E> or TaskOutcome<T,E> is a closed tagged union as specified in [D3 core value](d3-core-registry-value-contract.md); equality of logical instance digest does **not** prove target Win64 union offsets or exact destructor. ABI_LAYOUT_UNVERIFIED blocks execution until D4 layout proof. Result/TaskOutcome with transposed type arguments have different contract digest even if their native payload sizes accidentally match.

## GI4. Resolver and invalidation

Validate strict core registry bytes and template digest first. Resolve argument ownership, kind, digest and feature gate; reject unresolved/mixed/nested/recursive cases. Construct GI2 projection, SHA-256, then record the complete instantiated identity in a **new approved** type-reference/lock metadata profile. A change to template public traits/gate, any argument TypeID/digest or generic policy revision invalidates the instance digest and all dependent component exportedContractDigests/graph approvals. Changing only Assembly source bytes with identical public contracts leaves logical instance digest unchanged but invalidates source/build/ABI evidence.

- Unknown or unapproved template: TYPE_GENERIC_PROFILE_UNSUPPORTED
- Arity mismatch: TYPE_GENERIC_ARG_MISMATCH
- Wrong/disallowed argument owner/profile: CORE_PROFILE_MISMATCH
- Unresolved argument or digest mismatch: GRAPH_EXPORT_UNRESOLVED / CORE_CONTRACT_DIGEST_MISMATCH
- Nested/recursive or unapproved specialization: TYPE_GENERIC_PROFILE_UNSUPPORTED
- Missing ownership/Send proof: TYPE_TRAIT_UNPROVEN
- Same named type but differing logical contract: reject, never bind by display name.

[Generic reference vectors](../../examples/aui-language/d2-generic-instantiation-vectors.json) include ordered args, canonical bytes, SHA-256 and mutation expectations; these are independent reference arithmetic only.

## GI5. Remaining P0

Approve the full generic/recursive type syntax and exported TypeReference representation in D2 schemas, mixed v1/v2 compatibility for user-defined Row/Failure types, exact error/variant registry, source-to-Graph inclusion and actual D4 target LayoutIR and ABI generic values. **This G1 slice is deliberately nonrecursive**; it is not full D3 sign-off and does not make List<Row> executable.

## GI6. Separate future user-record-aware TypeReference v2 profile — still OPEN

[TypeReference v2](d2-d6-typeref-v2-resolution.md) proposes a **different** aui.generic-instantiation/v2-record-args digest domain using full nominal TypeReference objects, allowing a separately accepted v2-record Row as an argument. This DOES NOT expand G1 in place: all five G1 hash vectors, core-only argument bounds and old v1 pure fixtures remain unchanged. [New Row/List<Row> digest vectors](../../examples/aui-language/d2-typeref-v2-vectors.json) are independently checked ASCII reference arithmetic, not an AUI compiler. Legacy v1 Row still rejects CORE_PROFILE_MISMATCH, nested generics/cycles remain unsupported, and a full typed Project Graph v2 must be approved first.
