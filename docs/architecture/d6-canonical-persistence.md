# D6 Dependency for D2 — Canonical Project Bytes, Digests and Crash Recovery

**Status: proposed byte-level design candidate; NOT architect-accepted, implemented, durable, or crash-tested.** This document owns the proposed **canonical encoding and durable publication protocol**. [Project Format](project-and-package-format.md) owns project/package structure, [Package Resolution](package-resolution-build.md) owns dependencies, [Graph Validation](graph-validation-and-migration.md) owns semantic validation/migration, and [D2 Identity](d2-identity-and-type-resolution.md) owns semantic identities. This is a D6 cross-gate dependency needed before D2 digest/CAS claims can be frozen.

## P0. Scope and explicit non-goals

The first persistence profile stores project **definitions**, source revisions, exact locked packages and presentation views. It does NOT store active workflow queues, hardware effects, runtime ExecutionIDs, GUI widget pointers, process credentials, private AI conversation data or physical-device state.

All durable writes occur through a target-specific filesystem adapter. **A design cannot promise power-loss consistency from a normal JSON overwrite**, especially across multiple files or filesystems. Required capabilities: atomic replacement of a pointer-sized file within the same filesystem, durable file flush and durable metadata flush/appropriate platform equivalent. If the target cannot prove these, it must report PERSIST_DURABILITY_UNSUPPORTED and must not claim crash-safe commits.

## P1. Canonical JSON profile for reference fixtures

The initial **candidate** canonical representation is deterministic UTF-8 JSON, not normal pretty-printed JSON and not general arbitrary Javascript serialization.

**Parsing requirements**
- Strict RFC-compatible JSON lexical grammar; UTF-8 only, no BOM, invalid or overlong UTF-8, unpaired surrogate, duplicate object key, non-finite numeric values or trailing material.
- Object keys are compared **after JSON escape decoding**; duplicate decoded keys reject. All schema keys are ASCII. An extension may be accepted only with an approved namespaced schema and canonicalization rule.
- No normalization of general string *values*: decoded Unicode scalar sequences are preserved exactly. Persistent graph IDs are ASCII-only per D2 proposal; AUI source identifiers have their own Unicode/NFC rule.
- Canonical semantic JSON numbers are restricted to integers within [-(2^53-1), +(2^53-1)]. Number tokens containing decimal point, exponent or negative zero reject in the first profile. Larger U64/address/precise decimal values must be encoded as strings under an explicit typed schema.
- Reject unconstrained resource exhaustion before allocation: maximum input bytes, nesting, string length, array size and entity count are **target-profile configuration inputs that must be explicitly frozen before acceptance**.

**Canonical writing rules**
1. Start from a structurally and semantically validated model (not from raw user input). Construct a typed meaning-bearing **semantic projection**.
2. Serialize objects with keys ascending by **UTF-8 byte order** of decoded key strings; no spaces or line endings.
3. Serialize strings as double-quoted UTF-8. Escape double quote and backslash with backslash, and each U+0000..U+001F character as lowercase six-byte sequence backslash-u-00xx. Do not escape slash or non-ASCII Unicode scalar values.
4. Serialize integer tokens in shortest decimal form with no plus sign, leading zeros or negative zero. Boolean/null use lowercase JSON keywords.
5. **Semantic unordered collections** sort by immutable ID: targets/id; retiredIdentities/(kind,scopeId,id); nodes/id; nodes/ports/id; edges/id; workflows/id; each workflow states/id, signals/id and transitions/id; dataFlows/id and channels/edgeId; packageDependencies/(packageId,version); logical resolvedExports/(packageId,exportedTypeID,exportedContractDigest). Sorting is bytewise ASCII per approved ID policy. Other lists that represent ordering (e.g. command parameters, record fields, explicit priority sequences in future profiles) preserve order.
6. Unknown required schema fields reject instead of being quietly dropped. Presentation-only positions, hover/selection, node display-only labels (including the current fixture field named label), ViewRevision, compiler caches, runtime evidence and GraphRevision are **not** in the semantic projection. A **contract-bearing public name or exported operation identity** is semantic and must not be confused with a display label.
7. Semantic projection includes format marker, schema compatibility marker, ProjectID, all validated meaning-bearing targets/nodes/edges/workflows/dataFlows/package constraints, retired identity tombstones, and exact **logical export identities** (packageId, TypeID, exportedContractDigest). Exact package content hashes and source file byte hashes are recorded separately in the immutable package lock and snapshot index, **not** inside semanticGraphDigest. See [Export Contract Identity](d2-export-contract-identity.md); changing ASM whitespace must not change the graph digest. This is a projection over a resolved project, not identical to project.auiproj.json.
8. Digest is lowercase hex SHA-256 over UTF-8 bytes of ASCII domain string **AELYXORA/semantic-graph/v1** followed by a single zero byte, then the exact canonical semantic projection bytes. Record algorithm and profile ID; never hash a pretty-printed source manifest as if it were semanticGraphDigest.

A standalone **reference-fixture-only** canonical input and expected digest is specified in [Canonical Vectors](../../examples/architecture-sensor/d2-canonical-vectors.json). The semantic projection's retiredIdentity tuples are sorted by (kind,scopeId,id), included even when the ledger is empty; general source label and ViewRevision are excluded. Test vectors are design artifacts: independent hash implementations and native parser agreement will be required later. Until reference vectors are reviewed, the above algorithm is a **candidate**, not an accepted wire format.

## P2. Package identity, snapshot index and head checksum (proposal)

The precise candidate package file-set framing and portable path policy are owned by [D6 Package Integrity](d6-package-integrity.md). Package content is one canonical manifest at component.auipkg.json plus exactly declared source files, sorted by path UTF-8 bytes. The package digest is SHA-256 over the domain-separated length-framed stream. The package lock binds exact packageId, packageVersion, sourceRoot locator, digest, dependency closure and target metadata; no fake sensor lock exists while source files are absent. SHA-256 is an integrity mechanism relative to a trusted value, not publisher authenticity.

A *snapshot* contains a canonical project manifest, committed lock, source bytes, view bytes and a canonical immutable index. It also pins the exact referenced package objects in a separately retained immutable content-addressed object store; those package bytes are required to claim a *fully verified* recoverable snapshot. Source file hash is SHA-256 over **exact bytes**, including whitespace. The index is canonical UTF-8 JSON conforming to the candidate [Snapshot Index Schema](../../schemas/project-snapshot-index.schema.json). It records semanticGraphDigest, graphRevision, projectManifestDigest, lockDigest, per-file source/view byte digests, sorted packageObjects references (packageId, packageContentDigest), a commit operationId and a retiredIdentityDigest. Proposed retiredIdentityDigest is SHA-256 over the canonical JSON byte encoding of the retiredIdentities array, including the empty array. No native pointer or runtime ticket is serialized.

**Candidate snapshotDigest = SHA-256 of ASCII AELYXORA/snapshot-index/v1, one NUL, and exact P1-canonical index.json bytes.** The index must not contain its own snapshotDigest field, preventing self-reference. All referenced bytes MUST be present and verified before a HEAD may be used. SnapshotDigest is different from semanticGraphDigest and packageContentDigest. The index's viewFiles lists *committed immutable* view file bytes; a mutable top-level views/ cache can never supersede the index.

**Candidate HEAD checksum = SHA-256 of ASCII AELYXORA/head-record/v1, one NUL, and the P1-canonical HEAD object omitting only checksum.** The HEAD includes projectId, headFormat, epoch, graphRevision, semanticGraphDigest, snapshotDigest and predecessorEpoch, while its checksum property stores that lowercase hex value. A HEAD checksum is only an accidental/tamper-evident integrity check when compared against a trusted root, not a signature or proof of durability. Independent HEAD records can be coherent by internal checksum yet point to missing/corrupted snapshots; recovery must verify *both*.

[Exact package/snapshot/HEAD codec vectors](../../examples/architecture-sensor/d6-integrity-vectors.json) include a synthetic codec-only miniature whose project manifest and lock intentionally lack complete graph semantics, and a non-runnable source byte sequence. They verify representation and hashing **only**. The full sensor project is not valid as a locked build without its absent source files. The next gate must add full end-to-end valid snapshot vectors and externally verified digest compatibility.

**Open:** complete snapshot inventory normalization, source-root security, independent verification and architect approval of the proposed [export-contract digest](d2-export-contract-identity.md), package signing, graph/source/view revision tracking, lock canonicalization, full persistence schema and verified host filesystem capability.

**Operation provenance for ambiguous saves:** HEAD and snapshot index contain the same committed operationId (null only for genesis). The HEAD checksum and snapshot index hash cover it, and recovery compares them. This proves correlation for the **retained committed records only**. With two HEAD slots there is NO unlimited durable operationId replay memory: older repeated IDs require an accepted persistent operation ledger, or must be rejected as unresolvable rather than advertised as deduplicated. [D2/D6 Baseline Review](d2-d6-baseline-review.md) tracks this as P0.

## P2.1 — Canonical snapshot verification and array ordering (design candidate)

Before treating a HEAD as a fully verified project:
1. Strictly parse HEAD, reject non-canonical bytes, unknown/duplicate keys or invalid checksum; observe its epoch and operationId.
2. Read immutable index.json for the referenced snapshotDigest; verify exact SHA-256 with the snapshot-index/v1 domain. Index must be canonical bytes; an index is not its own signature.
3. Assert HEAD and index agree on projectId, graphRevision, semanticGraphDigest and operationId; no field may be silently overwritten from the other record.
4. Verify exact project manifest, lock and each listed source/view byte digest; reject undeclared, duplicate or conflicting paths in canonical inventory.
5. Require index.packageObjects to equal the committed lock's resolved exact (packageId, contentDigest) set. Verify all referenced immutable objects and manifest/source inventories before claiming a fully recoverable package-locked project. A missing object is a recovery integrity error, not a reason to download a substitute.
6. Validate the restored semantic graph, retired-identity ledger and all locked exported contracts; recompute semanticGraphDigest using logical export identities, not implementation file hashes. Reject any mismatch before loading executable code.
7. Select highest fully valid HEAD epoch, reporting degraded recovery whenever a newer record exists but fails. If no trusted slot remains, stop with PERSIST_RECOVERY_REQUIRED.

The canonical index stores sourceFiles and viewFiles **sorted by path UTF-8 bytes** and packageObjects **sorted by (packageId,contentDigest)**; duplicates, case-fold path collisions, aliased/reserved paths and cross-array path collisions are invalid. An index list is not allowed to change order merely due to filesystem enumeration. This affects snapshotDigest while leaving unrelated semanticGraphDigest unchanged.

**Commit provenance limitation:** operationId is immutable in the new HEAD and index, but TWO HEAD slots preserve at most the latest limited set of committed operation IDs. They cannot provide unlimited cross-crash replay detection; old-operation retries require an explicit durable operation-history design or a conservative conflict error. No hidden idempotency guarantee.

## P3. Semantic GraphRevision versus ViewRevision

- GraphRevision N is a monotonic document revision advanced by each **accepted semantic mutation**. An explicitly accepted semantic no-op does not increment N and yields no new graph snapshot. Use separate ViewRevision for map-only changes.
- semanticGraphDigest H is a content identity **not a revision counter**. It can recur if a later approved edit restores the exact old semantic content, but GraphRevision still advances on the restorative semantic transaction.
- A changed source file without exported contract changes leaves semanticGraphDigest unchanged but advances the immutable **source/snapshot revision**, and invalidates build results derived from source bytes.
- AI-approved change sets have expectedGraphRevision and expectedSemanticDigest **plus** expected source inventory digests. A mismatched semantic revision -> PROJECT_STALE_REVISION; a source mismatch -> SOURCE_STALE_REVISION. Even if H matches after a revert, a stale revision precondition still rejects.
- ViewRevision can advance without changing H, source hashes or generated binary build inputs. A view-only edit must use a separate presentation commit; a mixed edit atomically stages both in the full project snapshot.

## P4. Crash-consistent immutable snapshots and two HEAD slots

**Proposed design** (requires actual per-target feasibility review): a project uses immutable, content-addressed snapshot directories plus two short head records at fixed paths. Files never change after their snapshot hash has been published. The proposed [immutable snapshot index schema](../../schemas/project-snapshot-index.schema.json) enumerates project manifest, exact source bytes, package lock and view attachments, with per-file checksums; the final complete schema, package content identity and snapshotDigest framing still require D6 freeze.

    project-root/
      HEAD.0.json
      HEAD.1.json
      snapshots/<snapshotDigest>/index.json
      snapshots/<snapshotDigest>/project.auiproj.json
      snapshots/<snapshotDigest>/sources/...
      snapshots/<snapshotDigest>/package-lock.json
      views/ (optional derived working-view cache; NOT authoritative)
      objects/packages/<packageContentDigest>/component.auipkg.json
      objects/packages/<packageContentDigest>/src/...
      staging/<uniqueOperationId>/...
      .aui/ (derived caches, never authoritative)

A HEAD record contains projectId, headFormat, epoch (monotonic), graphRevision, semanticGraphDigest, snapshotDigest, predecessorEpoch and a SHA-256 checksum of all other canonical head fields; see the exact P2 candidate frame and [integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json). Proposed [HEAD structural schema](../../schemas/project-head.schema.json) validates shape, not checksum, filesystem durability or snapshot trust. The exact domain and checksum procedure remain Proposed until independent vector agreement. The record itself is canonical JSON; any torn/truncated/mismatched record is invalid. Current valid HEAD is the highest-epoch record whose snapshot inventory and content hashes verify, unless a separate explicit rollback decision is required.

**Commit protocol from revision N to N+1:**
1. Hold one local project writer lease. Capture expectedGraphRevision, expectedSemanticDigest and expected source hashes; validate the full change set against immutable N and locked package content. A stale condition fails without writing a HEAD.
2. Serialize canonical project/lock/source inventory; place new files in unique staging directory on the **same durable volume**. Path traversal and symlink escapes must fail before writes.
3. Stage and flush the exact locked content-addressed package objects before publishing a HEAD that references them; immutable object-store entries must be verified and retained while any committed snapshot references them. Write and flush every project snapshot file, including the snapshot index; verify hashes, reject missing/short writes. Ensure immutable snapshot directory is durable (rename/publish directory and flush parent metadata using OS-supported mechanism). Duplicate identical snapshot digest may be reused only after byte-level verification.
4. Re-check the writer lease and expected current HEAD epoch/revision (prevents concurrent writers). Generate the **inactive HEAD slot** with epoch E+1, reference to the verified immutable snapshot and checksum; write temporary head, flush, atomically replace inactive slot and flush required directory metadata.
5. Only after the HEAD slot durability guarantee succeeds may the transaction return success and announce the new graph/source revision. Failure before that point must not claim success; a later reopen may detect that the new HEAD became durable despite an ambiguous crash.
6. Recovery reads both HEAD slots, rejects torn/invalid records and snapshots, and selects highest fully valid epoch. If both are invalid, **stop with PERSIST_RECOVERY_REQUIRED**; never manufacture a new empty project or execute partially recovered code.
7. Garbage collection is separate and cannot delete a snapshot referenced by either HEAD slot, pending live graph execution, incomplete recovery or retained evidence. Retired-ID ledger and source-ownership evidence must survive migration/compaction.

This gives a **candidate** all-or-nothing multi-file published snapshot model. It does not imply external hardware rollback. On a platform without proven durable atomic replacement and directory sync semantics, mark the guarantee unavailable and refuse claims of safe crash publication.

**Important unresolved crash edge:** If the new HEAD becomes durable while the previous slot is corrupted, recovery may fail to offer the older snapshot; strict two-generation recovery guarantees require retention and verification of older snapshot parents. The model must define how long prior snapshots survive, how integrity failure differs from in-progress crash and whether user intervention is needed. No automatic silent rollback from a fully committed snapshot due to semantic invalidity.

## P5. Fault injection and negative conditions

| Scenario | Required expected behavior |
| --- | --- |
| Decode a project with duplicate JSON keys | JSON_DUPLICATE_KEY before graph validation |
| Different JSON object key order / unrelated pretty-printing | Same canonical semantic bytes and semanticGraphDigest |
| Reordered semantic unordered node/edge arrays | Same digest |
| Changed channel capacity, workflow transition or target capability | Different semanticGraphDigest |
| Map coordinate change only | Same graph digest, changed ViewRevision |
| Unicode literal change (different scalar sequence) | Different canonical bytes if value belongs to semantic graph |
| Floating value in semantic numeric field | CANONICAL_NUMBER_UNSUPPORTED |
| Malformed UTF-8/unpaired surrogate | JSON_INVALID_UNICODE |
| Declared package source file missing | PKG_MISSING before build |
| File symlink escapes package root | PKG_PATH_ESCAPE |
| Hash mismatch in a locked package | PKG_DIGEST_MISMATCH |
| Stale expectedGraphRevision even when digest matches | PROJECT_STALE_REVISION |
| Stale human source hash under AI patch | SOURCE_STALE_REVISION |
| Crash before HEAD publication | Previous fully valid HEAD selected |
| Crash after HEAD replacement but before success response | Either valid previous or new committed snapshot; ambiguous result requires reconciliation |
| Torn HEAD slot but other valid | Ignore invalid slot; preserve valid snapshot and report degraded durability |
| Both HEAD slots invalid | PERSIST_RECOVERY_REQUIRED; never guess |
| Power-loss on adapter with unproven flush/rename durability | PERSIST_DURABILITY_UNSUPPORTED; no validated crash-safe guarantee |
| Graph/lock/index hash disagreement | PERSIST_SNAPSHOT_CORRUPT, refuse to execute |

See [30 designed crash and recovery scenarios](../../examples/architecture-sensor/d6-recovery-scenarios.md) for future OS fault injection; all remain NOT-RUN.

## P6. Cross-gate acceptance blockers

Before declaring D6 design accepted:
1. Freeze exact JSON scalar constraints, Unicode/escape form, integer limits, unknown fields and extension rules for all semantic model fields.
2. Freeze the list of semantically unordered arrays and decide how nested types, hardware constraints and generic extensions are canonicalized.
3. Produce externally independently verified canonical JSON, SHA-256 and package-framing reference vectors with positive **and** negative cases.
4. Finalize the complete project manifest/index/HEAD schemas, source inventory and tombstone persistence rules.
5. Qualify the selected host's filesystem adapter per [D6 Filesystem Adapters](d6-filesystem-adapters.md), including atomic/flush semantics, concurrent writers and recovery behavior; actual crash proof remains Phase III.
6. Define migration/rollback/incomplete commit recovery through explicit state-machine fixtures; provide crash cut-points.
7. Review source ownership, permission paths, symlink/case collisions, lockfile signing/authenticity and secrets exclusion.
8. Record architect approval. Native crash testing and power-loss evidence remain **Phase III**, not a fabricated design-stage pass.

D2 graph CAS cannot claim durable atomicity until these conditions are satisfied. This document deliberately distinguishes **a precise proposal** from **an implemented and verified guarantee**.

**Filesystem boundary:** [Windows/Linux adapter capability matrix](d6-filesystem-adapters.md) explains why file rename/flush documentation alone cannot prove cross-platform power-loss durability. [D6 Package Integrity](d6-package-integrity.md) owns package path and hash rules; no executable package or confirmed durable save exists.

**Design correction — semantic versus implementation identity:** [Export Contract Identity](d2-export-contract-identity.md) defines a stable logical export digest independent of source byte formatting, while the lock/snapshot and build still pin exact package source bytes. The earlier use of lockedPackageContentDigest inside the semantic type identity was contradictory and is superseded. [Export vectors](../../examples/architecture-sensor/d2-export-contract-vectors.json) are design-only reference inputs.

**Package-object lifetime invariant (D6 draft):** Every committed snapshot index's packageObjects must exactly match the resolved package IDs and content digests in its committed lock; the package object store must contain verified manifest and declared source bytes. A missing package object makes a snapshot **incomplete for fully verified recoverability**, even if its index digest and HEAD checksum are correct. No garbage collection may remove package objects reachable from either HEAD slot, retained history, active runtime snapshot or recovery record. Object-store durability is subject to the same host-specific flush and metadata guarantees as snapshot publication. The codec-only reference with packageObjects=[] intentionally does not model a real locked package and is not a full project fixture.

## P7. First linked reference and explicit scope

[Semantic Projection](d2-d6-semantic-projection.md) owns the field-by-field canonical graph value; [Offline Dependency Resolution](d6-offline-dependency-resolution.md) owns package-lock closure and logical exports. [Locked Pure Reference](../../examples/locked-pure-reference/README.md) has actual fixture ASM bytes and immutable packageObjects plus project snapshot/index/HEAD, but no D4 ABI linkage or host durability. It must never be mistaken for an executable Studio build or an OS crash-safety result.

## P8. Proposed core registry digest domain and snapshot boundary

[Core Export Contract v2](d2-d3-core-export-digest-contract.md) adds a **separate** proposed type-contract profile without modifying existing v1 public export canonical input or the pure snapshot/index/head fixture. Its [reference vectors](../../examples/aui-language/d2-d3-core-export-digest-vectors.json) are independent arithmetic, not native D6 validation. Before an extended-core graph can be authoritative, D6 must capture exact registry source bytes, approved core logical contract set, source/Graph approval and compatible package lock in a *new* immutable snapshot; changing core/native ABI cannot silently revalidate a previously accepted binary. The Windows [Win64 ABI design](d4-win64-native-component-abi.md) and [first UI host](d5-windows-host-runtime-contract.md) **do not** constitute verified NTFS durability.

## P9. Generic/migration and deterministic signed-artifact separation — PROPOSED

[Typed G1 generic instances](d2-d3-generic-instantiation-identity.md) and [v1/v2 migration policy](d2-d6-core-profile-compatibility.md) cannot silently alter existing v1 public or semantic graph projections. A future approved migration builds a **new** immutable snapshot with full source/type/lock/Graph approvals. [Win64 deterministic build](d6-win64-reproducible-build-contract.md) records recipe identity, unsigned PE/PDB reproducibility, then separate signed PE and detached approval bytes; no recursive whole-image/snapshot digest. [Module trust](d4-win64-module-trust-and-admission.md) adds externally verified WinVerifyTrust/publisher and runtime capabilities; nothing here constitutes native OS verification or NTFS power-loss testing.

## P10. Preapproval signed proposal and new typed Graph profile guard (PROPOSED)

[TypeReference v2](d2-d6-typeref-v2-resolution.md) defines typed user records and a distinct generic domain; v1 Graph/source manifests and their immutable hash vectors cannot silently gain typed references. [Signed Approval Receipts](d2-d6-signed-approval-receipt.md) propose a nonrecursive order: validated sources+type exports+typed source-link → canonical [proposal](../../schemas/aui-review-proposal.schema.json) → architecture signed receipt → signed PE/build proof → executable signed receipt → **new** D6 immutable index/snapshot → HEAD. Receipt payload must NOT bind final enclosing snapshotDigest or its own raw receipt SHA. The same valid signature is never proof of Win64 module/ABI or live capability. Full typed v2 Graph semantic schema, signer trust, real receipt fixture and Windows filesystem durability remain P0.
