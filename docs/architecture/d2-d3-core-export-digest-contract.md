# D2/D3/D6 — Versioned Core Export Contract Digests

**HISTORICAL EXPLORATORY DESIGN — SUPERSEDED AS ACTIVE ARCHITECTURE.** The single current design is [ONE Canonical Project Graph and Component Model](canonical-project-graph-and-components.md). Numbered experimental formats, schemas and test hashes below remain in the repository only as immutable research/provenance references. They are NOT alternative product architectures, not implementation gates and not accepted release formats. Do not develop new features by creating another numbered graph model.

**Status: PROPOSED, not architect-approved, compiled, native-validated, or signed.** The [D2 Export Identity v1](d2-export-contract-identity.md) and existing first-profile [locked pure reference](../../examples/locked-pure-reference/integrity-vectors.json) remain unchanged. [D3 Core Registry](d3-core-registry-value-contract.md) owns logical types; [D6 Canonical JSON](d6-canonical-persistence.md) owns byte normalization. This document defines a separate candidate extension, not a silent replacement for the existing public export digest.

## CD1. Versioned export profiles

- Existing **aui.export-contract/v1** retains its exact type-record/component projection and ASCII domain separator AELYXORA/export-contract/v1. Existing reference hashes and semanticGraphDigest are not modified.
- Proposed **aui.export-contract/v2-core** applies ONLY to the separately proposed extended compiler-provided core registry. It uses ASCII domain separator AELYXORA/export-contract/v2-core. It does not authorize L2/L3/L4 implementation or retroactively change core TypeID resolution in the existing pure projects.
- A digest is lowercase 64-hex SHA-256 of a *validated normalized public contract*, not source bytes, package content, compiled output, ABI layout, signature or OS permission.

## CD2. Exact core type projection

One [core inventory entry](../../examples/aui-language/d3-core-registry-proposal.json) is projected into JSON with exactly these field names and meanings:

| Field | Value |
| --- | --- |
| profile | literal aui.export-contract/v2-core |
| exportKind | literal type |
| packageId | literal aui.core |
| registryId | literal aui.core/extended-0.2-draft |
| typeId | exactly qualified, case-sensitive entry typeId |
| kind | exact entry kind |
| typeArity | exact integer arity 0..2 |
| featureGate | exact L0/L1, L2, L3 or L4 |
| logicalTraits | unique ASCII trait IDs sorted by raw UTF-8 bytes |

The normalized projection has **no other keys**. The inventory's nativeLayoutStatus, semanticsOwner, document path, native alignment, source SHA, target and build artifact are intentionally excluded: they are not *logical* type semantics. Feature gate and traits are included because type availability/ownership changes are public contracts. Reject unknown kinds/traits, duplicate TypeIDs/traits, invalid identifiers, and unapproved registry revisions before hashing.

The type template (for example List<T>) is not equivalent to one instantiated List<Row>. Future generic instances require a separate formally defined normalized instantiation projection containing the base template digest and all **ordered resolved nominal argument TypeIDs and full argument contract digests**. Generic instance digest normalization, recursive generics and variance are P0 and must reject instead of using a placeholder.

## CD3. Exact canonical hashing and registry fingerprint

1. Parse and structurally validate the [registry inventory schema](../../schemas/aui-core-registry-proposal.schema.json); then independently check semantic uniqueness, type traits and source registry identity.
2. Select CD2's exact fields, sort the logicalTraits set bytewise, and encode **canonical P1 UTF-8 JSON** from [D6](d6-canonical-persistence.md): raw UTF-8 key ordering, exact escaping, no insignificant whitespace.
3. Concatenate bytes: ASCII(AELYXORA/export-contract/v2-core), one NUL 00 byte, then exact canonical JSON UTF-8 bytes. SHA-256 of that frame is the exportedContractDigest for the core type.
4. For a core-registry **logical set fingerprint** (NOT a signature), create one canonical JSON object with profile aui.core-registry/v1, registryId aui.core/extended-0.2-draft and entries sorted by full typeId; each entry contains exactly typeId and exportedContractDigest. Hash ASCII(AELYXORA/core-registry/v1), NUL 00, canonical UTF-8 JSON bytes.
5. File-byte SHA of the registry inventory itself is an independent exact-source hash. Neither logical fingerprint nor SHA arithmetic establishes trusted publisher, compiler ABI compatibility or an approved software artifact.

[Proposed exact digest vectors](../../examples/aui-language/d2-d3-core-export-digest-vectors.json) contain the normalized objects, exact canonical strings and reference SHA-256 values. They are independent reference arithmetic, not AELYXORA native tests.

## CD4. Compatibility and transitive invalidation

- A compiler must explicitly pin approved registry bytes/ID and import before resolving bare core names. No ambient library fallback or spoofing by user packages.
- For future explicitly approved mixed v1/v2 sources, every referring record field, component port/command input/result/error must embed the **correct full referenced core type contract digest**, then transitively recompute dependent exported component digests.
- **The mixed-profile compatibility policy is not accepted** in this document. Using a proposed v2-core digest inside an existing v1-only project without approved migration fails CORE_PROFILE_MISMATCH. It is not a reason to update prior immutable snapshots.
- Pure source formatting changes alter source/file SHA and possibly package/snapshot bytes, but not validated logical export contracts. Changes to public type/trait/featureGate/target/effect semantics must invalidate dependent logical contracts and approvals.
- Build/ABI identity separately pins exact package/source bytes, Windows ABI and toolchain/layout proof. Native layout change does not silently mutate a logical contract hash but always invalidates ABI evidence.
- A registry digest on its own is NOT a reviewed source-to-Graph approval or a hardware permission grant.

## CD5. Diagnostics and test matrix (future native tests NOT-RUN)

| Failure | Candidate diagnostic |
| --- | --- |
| No approved registry bytes/core import | CORE_REGISTRY_UNRESOLVED |
| Unknown profile/silent v1-v2 mixing | CORE_PROFILE_MISMATCH |
| Duplicate TypeID or trait | CORE_DUPLICATE_EXPORT / CORE_DUPLICATE_TRAIT |
| Mismatched referenced verified core type digest | CORE_CONTRACT_DIGEST_MISMATCH |
| Unsupported generic instance derivation | TYPE_GENERIC_PROFILE_UNSUPPORTED |
| Missing compiler-native layout or ABI proof | ABI_LAYOUT_UNVERIFIED |
| Invalid manifest/UTF-8/canonical bytes | SCHEMA_INVALID / CANONICAL_INVALID |

Reference invariants: source JSON object key/whitespace reformatting and trait-order permutations preserve *logical* digests; removing a trait or changing feature gate/arity changes it; changes to native layout alone do not change it; the existing D2 v1 vectors and all prior locked pure graph/snapshot hashes remain unchanged.

**Open P0:** complete approved core export/trait registry and semantic type errors, exact generic instantiation policy, mixed-profile migration, source publisher/authenticity and ABI/Win64 native proof. Never assert architect acceptance merely from reference SHA-256 calculations.

## CD6. Bounded G1 generic specialization and v1/v2 barrier

[Exact generic instance identity](d2-d3-generic-instantiation-identity.md) defines a **new** domain-separated, ordered-argument logical digest for core List<T>, Result<T,E> and TaskOutcome<T,E>, distinct from these 13 template export digests. [v1/v2 compatibility policy](d2-d6-core-profile-compatibility.md) forbids silently inserting v2-core/generic references into existing v1 exported fields/Graph. User-defined v1 records such as Row in List<Row> remain unsupported in G1 until a new typed TypeReference and migration profile is architect-approved. [G1 vectors](../../examples/aui-language/d2-generic-instantiation-vectors.json) are reference SHA-256 only, NOT native compiler tests.
