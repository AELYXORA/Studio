# D2–D6 — Typed v2 References, Signed Approval and Win64 Chain Audit

**Status: PROPOSED cross-owner consistency audit. Not an architect sign-off, native validator, real signing test, executable artifact, ABI proof or Windows/NTFS fault-injection result.**

Owners: [TypeReference v2](d2-d6-typeref-v2-resolution.md), [D2 export contracts](d2-export-contract-identity.md), [D3 source/Graph linker](d3-source-snapshot-reconciliation.md), [signed approval protocol](d2-d6-signed-approval-receipt.md), [D6 persistence](d6-canonical-persistence.md) and [Win64 trust](d4-win64-module-trust-and-admission.md). The [end-to-end trace](d2-d6-typed-win64-end-to-end-trace.md) is an illustrative ordering, not an implementation milestone.

## AC1. Explicit cross-owner reconciliation

| ID | Priority | Former design ambiguity | Proposed fail-closed boundary |
| --- | --- | --- | --- |
| TA-01 | P0 | v1 typeId string reused as generic ref | New strict TypeReference v2 union; v1 fields unchanged and reject new objects |
| TA-02 | P0 | G1 List<T> only core arguments vs L4 List<Row> example | Separate v2-record-args domain with typed acyclic user record; v1 Row still incompatible |
| TA-03 | P0 | Same printed Row, different package owner or profile | OwnerPackageId + exact exportProfile + TypeID + digest must all match |
| TA-04 | P0 | User record field digest might be source path / ABI dependent | New v2-record domain, deterministic fields with complete TypeReferences, no native fields |
| TA-05 | P0 | Generic digest might include itself or unordered args | Hash only template + ordered nominal TypeReferences; instanceDigest external |
| TA-06 | P0 | v2 TypeReference could be accepted in Graph v1 lacking type-aware projection | GRAPH_PROFILE_UNSUPPORTED until separate versioned typed Graph/component schema approved |
| TA-07 | P0 | Source link hash binds bytes but not fully typed nominal command | Separate typed source-link supplement digest added to mandatory preapproval proposal |
| TA-08 | P0 | A signed approval receipt might refer to its own enclosing snapshot | Sign preapproval proposal digest, then store detached receipt in *new* immutable D6 index; never embed final snapshotDigest in payload |
| TA-09 | P0 | Valid Ed25519 bytes might authorize any key/role | Independent trust registry supplies exact key/role/project/target/epoch, revocation/time policy |
| TA-10 | P0 | Architecture approval might accidentally authorize arbitrary signed PE | Separate release-approver executable receipt pins exact signed image SHA, build and operation set |
| TA-11 | P0 | Correct PE signature and typed graph proof assumed sufficient for live hardware command | Win64 ABI type/layout/operation mapping and current D2 capability must still admit invocation |
| TA-12 | P0 | D6 source publication conflated with provider result/UI state transaction | D6 snapshot durability and UI TaskTicket/StateRevision publication independent; no external-effect rollback |
| TA-13 | P1 | Signed fixture with placeholder hashes might be presented as positive executable proof | Examples are **unsigned with synthetic SHA-shaped values**, no real key, signature or approval |
| TA-14 | P1 | Arbitrary Unicode/type recursion and generic depth implicitly accepted by JSON Schema shape | Core registry canonical UTF-8 and acyclic type dependency graph enforced by semantic verifier, not schema alone |

**Status:** documentary proposals for all 14, NOT CLOSED at architect/native level.

## AC2. New design artifacts and scoped evidence

- [TypeReference v2 strict structural schema](../../schemas/aui-type-reference-v2.schema.json) and [v2 record schema](../../schemas/aui-record-export-v2.schema.json). Structurally separate from existing 0.1-draft project/package schemas.
- [Row and List<Row> reference SHA vectors](../../examples/aui-language/d2-typeref-v2-vectors.json): record and list type hashes independently recomputed using Python hashlib for ASCII canonical inputs; no AELYXORA native run.
- [Typed source-Graph supplemental link schema](../../schemas/aui-typed-source-graph-link-v2.schema.json) with full TypeReference inputs/results and target/native constraints; missing exact approved Graph v2 remains P0.
- [Nonrecursive preapproval proposal schema](../../schemas/aui-review-proposal.schema.json), [separate signed receipt envelope schema](../../schemas/aui-signed-approval-receipt.schema.json).
- [Clearly unsigned synthetic approval shapes](../../examples/architecture-approval/unsigned-approval-shapes.json) and [23 negative/design cases](../../examples/architecture-approval/approval-negative-cases.json). No actual signature validation or signer.
- [End-to-end typed AUI→Graph→Win64→TaskOutcome→StateRevision trace](d2-d6-typed-win64-end-to-end-trace.md), documentation-only.

No source files under src/ or previous pure-reference fixture files may be mutated to fabricate passing evidence.

## AC3. Remaining design P0 before Phase I sign-off

1. Normative exact new Project Graph v2 semantic projection, typed component/export operation digest and ABI-visible typed result/command links.
2. Full v2 user record/generic recursive and package/type owner policy, stable source profiles and separately reviewed v1 migration rules.
3. Exact type-export-set/operation-contract-set aggregation digests, source-link tool/target manifest provenance, full D6 receipt/index ownership.
4. Signer enrollment, key custody/rotation, Ed25519 implementation validation, offline revocation and epoch/clock trust, separation of architect/release roles.
5. Real code-signing and Win64 PE loader module identity proof, native generic layout, buffers/callback cancellation and live resource leases.
6. Qualified NTFS crash-commit, first-host Win32/IME/UIA/rendering and future controlled runtime security/race tests.
7. An explicit human architect accept/reject/defer record for every in-scope D1–D8 gate.

The design can be reviewed now; **no release-verified or production-ready claim follows**. Stage II (implementation) still requires approval of the Phase I baseline; Stage III actual Win64 tests follow implementation.
