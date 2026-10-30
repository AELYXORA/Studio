# D6 — Deterministic Offline Dependency and Locked Export Resolution

**Status: Proposed first-slice design, NOT architect-approved, implemented, or exercised by native AELYXORA tooling.** This document owns precise package dependency closure and the lock/graph connection. [Package Integrity](d6-package-integrity.md) owns manifest-and-source bytes and portable paths; [Export Contract Identity](d2-export-contract-identity.md) owns type/component public digest; [Semantic Projection](d2-d6-semantic-projection.md) owns graph hash; [Canonical Persistence](d6-canonical-persistence.md) owns snapshot publication. The sample [Locked Pure Reference](../../examples/locked-pure-reference/README.md) is a documentation fixture, not a runnable component.

## DR1. First-slice constraints

- Resolution is **offline** and read-only during build; it cannot fetch packages, rewrite manifests, install anything or pick a nearby version.
- One exact packageId resolves to **one exact packageVersion and one contentDigest** across the entire transitive closure. Side-by-side versions require a future namespaced profile. Version strings are exact opaque labels, not automatic SemVer ranges in the first slice.
- The project manifest's packageDependencies entries and each package manifest's dependencies entries have exactly packageId and packageVersion. Any incompatible requirements for the same packageId reject PKG_VERSION_CONFLICT, with a complete shortest dependency path.
- Every package in the resolved closure MUST have exactly one lock entry. Extra unreachable lock entries reject PKG_LOCK_EXTRANEOUS (except a separately reviewed workspace-optional package profile not included here).
- A package lock sourceRoot is a safe relative path locator inside a permitted project-owned store. For locked snapshots it must reference a verified immutable packageObject; not an ambient network package manager cache.
- The lock's exports registry is **recomputed from verified package manifests**, not trusted because it is a list in JSON.
- Package target status planned/unknown/unsupported never claims executable support. An introspectable design may resolve package contracts while build for a planned target must reject PKG_TARGET_UNSUPPORTED.
- The current draft package manifest testFixtures is an empty list. Nonempty/untyped extras are PKG_INVENTORY_UNSUPPORTED until D6 inventory semantics are extended.

## DR2. Exact deterministic resolution algorithm

1. Strictly parse/structurally validate project, lock and package objects; reject unknown required format versions, duplicate JSON object keys, invalid Unicode/number and path encoding before resolution.
2. Build a **requirement map** initially from project.packageDependencies; reject duplicate packageId requirements with incompatible version, and duplicate exact requirements unless a documented dedup rule permits canonical coalescing (candidate: reject duplicates).
3. Sort the pending packageId queue bytewise and resolve each lock entry by exact packageId, exact packageVersion and SHA-256 content digest. If missing -> PKG_LOCK_MISSING, wrong version -> PKG_VERSION_CONFLICT, duplicate lock entry -> PKG_LOCK_DUPLICATE.
4. Validate sourceRoot containment, case-fold path collisions, no symlink/reparse escape or TOCTOU path substitution. Read exactly the manifest and declared source file set from the immutable packageObject. Missing source -> PKG_MISSING; hash disagreement -> PKG_DIGEST_MISMATCH; extra source actually injected into build input -> PKG_UNDECLARED_SOURCE.
5. Read verified package manifest dependencies. Compare their exact packageId/packageVersion pairs to the lock entry's dependencies. Mismatch -> PKG_LOCK_DEPENDENCY_DRIFT; enqueue each unresolved dependency with its full provenance path. Unknown or conflicting packageId requirements fail deterministically without choosing arbitrary winners.
6. Reject disallowed dependency cycles with PKG_DEP_CYCLE. First profile rejects every package dependency cycle, even if header-only or type-only; introducing cycle-tolerant modules needs D3/D4 ordering semantics.
7. After reaching closure fixpoint, reject extraneous lock entries, duplicate qualified exports, duplicate type/port/operation IDs, unsupported type recursion and unresolved field/command/port nominal TypeIDs.
8. Construct the first-slice pinned core-registry identity; then normalize every type export in dependency order (leaf types before referrers) and every component export using transitive type contract digests. Compute domain-separated exportedContractDigest and compare **every entry** in the sorted lock exports list. Missing/extra/incorrect entry -> PKG_EXPORT_DIGEST_MISMATCH.
9. Resolve graph nodes against exact exports: node typeRef, port direction and TypeID; command provider; workflow success/error signals; target constraints; data-flow ownership/capacity and effect permission model. Unknown reference yields a specific D2 diagnostic, never a generated stub.
10. Only now create the exact semantic Project Graph projection using **logical exports** and project semantic fields, excluding implementation package hashes. A source-only edit requires lock reapproval/rebuild, not an invented graph semantic change.
11. Freeze exact packageObjects, source/toolchain/ABI target build inputs; generating/executing a binary requires separate D4/D5 checks and physical target support.
12. Publishing changes requires D6 revision/source hash compare-and-swap and full durable snapshot protocol; validation does not commit.

## DR3. Deterministic diagnostics

Diagnostics sort by pipeline stage, then qualified packageId and shortest provenance path, then stable type/operation ID. On multiple independent failures, report all safe-to-recover errors, but the primary code is the earliest stage. Avoid time/order-dependent filesystem iteration.

| Scenario | Expected primary diagnostic |
| --- | --- |
| Required package missing from lock | PKG_LOCK_MISSING |
| Extra unused package in lock | PKG_LOCK_EXTRANEOUS |
| Duplicate lock entry for one packageId | PKG_LOCK_DUPLICATE |
| Two parents require incompatible exact versions | PKG_VERSION_CONFLICT |
| Actual package manifest dependencies differ from lock | PKG_LOCK_DEPENDENCY_DRIFT |
| Package dependency cycle A -> B -> A | PKG_DEP_CYCLE |
| Missing source byte path from declared inventory | PKG_MISSING |
| Declared file does not match digest | PKG_DIGEST_MISMATCH |
| Package object missing from immutable store | PERSIST_SNAPSHOT_CORRUPT before restored executable trust |
| Duplicate exported type owner or operation ID | PKG_DUPLICATE_EXPORT |
| Lock export digest not recomputed value | PKG_EXPORT_DIGEST_MISMATCH |
| Unsupported core/user type dependency | GRAPH_EXPORT_UNRESOLVED / TYPE_RECURSION_UNSUPPORTED |
| Target declared planned, binary execution requested | PKG_TARGET_UNSUPPORTED |
| Undeclared extra source added to native build | PKG_UNDECLARED_SOURCE |

## DR4. Minimal closed example and a conflicting diamond

[Locked Pure Reference](../../examples/locked-pure-reference/README.md): project -> example.locked@1.0.0, no transitive dependencies; one lock entry, a verified manifest, two source files, two user record type exports, two component exports, one channel and one workflow. This fixture's recorded SHA-256 values are **design calculations**, not native results.

Negative diamond for future native tests: Project -> A@1.0, B@1.0; A -> C@1.0; B -> C@2.0. The exact-version one-packageId rule must reject PKG_VERSION_CONFLICT and include paths Project/A/C and Project/B/C. The resolver may not choose one by first-in-file or “latest version”.

## DR5. Project/package evolution and trust

A packageVersion label may stay unchanged while bytes change: lock contentDigest still rejects the change. An export digest may stay unchanged while source bytes change: logical type identity can stay but build evidence, platform permissions and executable trust must be re-evaluated. Signatures/publisher authenticity are not provided by SHA-256; first-profile unsigned local packages require a separately reviewed explicit trust warning and runtime execution gate.

**P0 still open:** exact package namespace character policy, complete source/resource manifest, core type registry beyond the minimal pure fixture, trust/signature policy, user-facing conflict resolution, target-specific native ABI, first-host safe filesystem read and durability proof, independent implementation of all negative cases. Approval of this doc does not imply implementation or test success.
