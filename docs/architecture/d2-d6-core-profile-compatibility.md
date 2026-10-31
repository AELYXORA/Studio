# D2/D3/D6 — v1 and Extended Core v2 Compatibility and Migration Gate

**Status: PROPOSED COMPATIBILITY POLICY, not approved, implemented or migrated.** The normative legacy hash owner is [D2 export-contract v1](d2-export-contract-identity.md); the proposed extended core owner is [Core v2 Export](d2-d3-core-export-digest-contract.md) and bounded [G1 Generic Specialization](d2-d3-generic-instantiation-identity.md). [D6](d6-canonical-persistence.md) owns immutable snapshot publication. Do not rewrite or reinterpret the [locked pure reference](../../examples/locked-pure-reference/integrity-vectors.json).

## CP1. Exact compatibility categories

| Existing source/graph | Requested consumer/type | Current design response |
| --- | --- | --- |
| Pure 0.1-draft + original v1 export identities | Pure v1 resolution | **Remain exactly v1**, existing digest vectors unchanged |
| Pure 0.1-draft + original v1 exported fields | Silent aui.core extended v2 import | CORE_PROFILE_MISMATCH, reject |
| Proposed extended core types only, separate future versioned project profile | Matching core v2 contract + G1 | Design-only candidate; not executable or approved by current project schema |
| User-defined v1 record as List<Row> argument | G1 core v2 template | CORE_PROFILE_MISMATCH until explicit user-record v2 and generic schema are accepted |
| v1 component operation with v2 TaskOutcome/Result type as *implicit* substitution | Mixed type API | CORE_PROFILE_MISMATCH / AUI_COMMAND_CONTRACT, never cast by native layout |
| New project snapshot with **explicit approved** migration bundle and transitive re-export | Fully reviewed v2 dependency closure | Candidate future supported path, but **requires a separately accepted versioned profile** |

Compatibility is governed by **declared project/source/core profile and exact contract digest**, not type spelling or memory layout. There is **no** default auto-upgrade, same-name alias, shim by copying pointers, graph CAS bypass, or fallback to a nearby package version. The mere presence of a v2-core digest in a JSON document is not a compatibility grant.

## CP2. Candidate explicit migration transaction

A future approved v1→v2 migration is a distinct **new immutable snapshot**, never a modification of existing historical records:

1. Pin old snapshotDigest, GraphRevision, old package lock and exact v1 exported-contract set; verify full D6 recovery closure.
2. Pin the proposed new core registry source bytes, registry fingerprint, every generic instance identity and exact compiler/target ABI revision; first target candidate Win64 user-mode.
3. Construct a **new separately versioned user-type/component contract projection** with exact type-reference objects carrying registry owner, TypeID, logical digest and optional generic instance digest. Do not pretend the old v1 string TypeID field already accepts G1 arbitrary instances.
4. Compute transitive export digest graph from leaves to users; reject unresolved cycles, ambiguous nominal owner, changed port direction/effect/domain/capability or mismatched signatures. Generate a *typed diff* of all changes before any publication.
5. For each persisted user data format, enumerate required value migrations. Identical public name does not imply equal serialization, enum discriminants, generic variance, U64 precision or String ownership. No automatic conversion of existing native pointers, task buffers or UI state.
6. Collect an explicit authorized architect review of graph/source/type/ABI changes, with exact old and candidate snapshot IDs and impact list. An approvalStatus string is insufficient; signed reviewer identity/permissions must verify against the approval system.
7. Stage all new source, type registry, lock files, export maps and review receipts as exact D6 index source bytes; publish via graph/source CAS only after the chosen filesystem's durable transaction capability is independently qualified.
8. Preserve old snapshots and tombstones for rollback/read-only provenance. A rollback of source/graph cannot automatically undo external workflow/device/network effects. Existing v1 binaries cannot silently load newly migrated v2 values.

A migration is **blocked** if any step requires an unknown generic instantiation profile, unsigned/untrusted source, unavailable target adapter, unknown allocator layout, or missing approval evidence. Re-pinning old source alone is not a conversion.

## CP3. Rejection precedence and diagnostics

First: strict schemaVersion/core profile -> exact D6 lock and type registry -> source/Graph compatibility -> typed migration diff -> signed approval -> target ABI/source build proof -> optional execution. Primary errors: CORE_PROFILE_MISMATCH, TYPE_GENERIC_PROFILE_UNSUPPORTED, PKG_EXPORT_DIGEST_MISMATCH, GRAPH_EXPORT_UNRESOLVED, AUI_COMMAND_CONTRACT, SOURCE_STALE_REVISION, AUI_APPROVAL_UNVERIFIED and ABI_LAYOUT_UNVERIFIED. No earlier failure can be bypassed by a later successful Win64 signature check.

## CP4. Design cases, NOT-RUN

- Source-only whitespace reformat: v1 and v2 **logical** digests unchanged, exact source/package/build hash changes.
- Rewrite a v1 record reference to v2 String without declared migration: CORE_PROFILE_MISMATCH.
- Keep v1 list field but supply G1 List<String> digest: CORE_PROFILE_MISMATCH.
- Change v1 component error type to TaskOutcome failure variant: AUI_COMMAND_CONTRACT.
- Identical native size but changed nominal/generic type digest: no compatibility.
- Human reviews graph but not new source bytes: stale/unapproved source, abort.
- New accepted target-neutral type contract and changed native layout: logical identity can remain but D4 ABI approval must be repeated.
- Old graph/snapshot after migration: preserved and still decoded by **its original** profile, never v2-rehashed.

**P0 remaining:** project format extension and human acceptance, v2 user record/component schema, typed import/export compatibility maps, data migration converters, exact signed approval receipt, D6 new immutable source bundle, Win64 native ABI and end-to-end tests. No claim that L4 List<Row> currently compiles.