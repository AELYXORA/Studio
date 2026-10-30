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
5. **Semantic unordered collections** sort by immutable ID: targets/id; nodes/id; nodes/ports/id; edges/id; workflows/id; each workflow states/id, signals/id and transitions/id; dataFlows/id and channels/edgeId; packageDependencies/(packageId,version); locked resolvedPackages/(packageId,contentDigest). Sorting is bytewise ASCII per approved ID policy. Other lists that represent ordering (e.g. command parameters, record fields, explicit priority sequences in future profiles) preserve order.
6. Unknown required schema fields reject instead of being quietly dropped. Presentation-only positions, hover/selection, ViewRevision, compiler caches, runtime evidence and GraphRevision are **not** in the semantic projection.
7. Semantic projection includes format marker, schema compatibility marker, ProjectID, all validated meaning-bearing targets/nodes/edges/workflows/dataFlows/package dependencies and exact locked package digests/export contracts. Source file byte hashes are recorded separately in the snapshot index. This is a projection over a resolved project, not identical to project.auiproj.json.
8. Digest is lowercase hex SHA-256 over UTF-8 bytes of ASCII domain string **AELYXORA/semantic-graph/v1** followed by a single zero byte, then the exact canonical semantic projection bytes. Record algorithm and profile ID; never hash a pretty-printed source manifest as if it were semanticGraphDigest.

A standalone **reference-fixture-only** canonical input and expected digest is specified in [Canonical Vectors](../../examples/architecture-sensor/d2-canonical-vectors.json). Test vectors are design artifacts: independent hash implementations and native parser agreement will be required later. Until reference vectors are reviewed, the above algorithm is a **candidate**, not an accepted wire format.

## P2. Package and file identity

An exact package content identity is not merely packageId/version. The package digest covers canonical manifest representation and all declared content files in an explicit inventory. The proposed file-set frame is:

    domain: AELYXORA/package-files/v1 + NUL
    for each sorted path:
      u64-be(pathUtf8ByteCount) || pathUtf8 ||
      u64-be(fileByteCount) || sha256(rawFileBytes)

The package manifest participates as the canonical file inventory entry with the **exact canonical manifest bytes**, not a recursive digest field. Paths are relative UTF-8, separated by forward slash, cannot be empty/absolute/dot-dot, cannot traverse a symlink or case-fold collide on the target filesystem. The hash of an empty collection is well-defined but an empty executable package is rejected if required sources are absent. The lockfile records packageId, exact packageVersion, contentDigest, supported targets, sourceRoot and dependency closure. **Verify package content before semantic graph hashing.**

For each project source, store exact SHA-256 of its bytes. The snapshot includes the immutable source inventory, package lock hash, canonical graph hash and target metadata. Full snapshot identity is a different digest from semanticGraphDigest; a formatting change to ASM or AUI source changes source digest and snapshot identity even if architecture semantics are unchanged.

**Known outstanding choices:** exact manifest canonicalization profile, binary framing test vectors, source-file inclusion/exclusion, platform path casefold model and package-signing authenticity. SHA-256 supplies integrity relative to a trusted expected digest, not proof of publisher authenticity.

## P3. Semantic GraphRevision versus ViewRevision

- GraphRevision N is a monotonic document revision advanced by each **accepted semantic mutation**. An explicitly accepted semantic no-op does not increment N and yields no new graph snapshot. Use separate ViewRevision for map-only changes.
- semanticGraphDigest H is a content identity **not a revision counter**. It can recur if a later approved edit restores the exact old semantic content, but GraphRevision still advances on the restorative semantic transaction.
- A changed source file without exported contract changes leaves semanticGraphDigest unchanged but advances the immutable **source/snapshot revision**, and invalidates build results derived from source bytes.
- AI-approved change sets have expectedGraphRevision and expectedSemanticDigest **plus** expected source inventory digests. A mismatched semantic revision -> PROJECT_STALE_REVISION; a source mismatch -> SOURCE_STALE_REVISION. Even if H matches after a revert, a stale revision precondition still rejects.
- ViewRevision can advance without changing H, source hashes or generated binary build inputs. A view-only edit must use a separate presentation commit; a mixed edit atomically stages both in the full project snapshot.

## P4. Crash-consistent immutable snapshots and two HEAD slots

**Proposed design** (requires actual per-target feasibility review): a project uses immutable, content-addressed snapshot directories plus two short head records at fixed paths. Files never change after their snapshot hash has been published.

    project-root/
      HEAD.0.json
      HEAD.1.json
      snapshots/<snapshotDigest>/index.json
      snapshots/<snapshotDigest>/project.auiproj.json
      snapshots/<snapshotDigest>/sources/...
      snapshots/<snapshotDigest>/package-lock.json
      views/ (optional independently versioned presentation material)
      staging/<uniqueOperationId>/...
      .aui/ (derived caches, never authoritative)

A HEAD record contains projectId, epoch (monotonic), graphRevision, semanticGraphDigest, snapshotDigest, predecessorEpoch and a SHA-256 **checksum of all preceding canonical head fields** under a distinct head-record domain separator. The record itself is canonical JSON; any torn/truncated/mismatched record is invalid. Current valid HEAD is the highest-epoch record whose snapshot inventory and content hashes verify, unless a separate explicit rollback decision is required.

**Commit protocol from revision N to N+1:**
1. Hold one local project writer lease. Capture expectedGraphRevision, expectedSemanticDigest and expected source hashes; validate the full change set against immutable N and locked package content. A stale condition fails without writing a HEAD.
2. Serialize canonical project/lock/source inventory; place new files in unique staging directory on the **same durable volume**. Path traversal and symlink escapes must fail before writes.
3. Write and flush every file, including the snapshot index; verify hashes, reject missing/short writes. Ensure immutable snapshot directory is durable (rename/publish directory and flush parent metadata using OS-supported mechanism). Duplicate identical snapshot digest may be reused only after byte-level verification.
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

## P6. Cross-gate acceptance blockers

Before declaring D6 design accepted:
1. Freeze exact JSON scalar constraints and unknown-field/extension rules for all semantic model fields.
2. Freeze the list of semantically unordered arrays and decide how nested types, hardware constraints and generic extensions are canonicalized.
3. Produce externally independently verified canonical JSON, SHA-256 and package-framing reference vectors with positive **and** negative cases.
4. Finalize the complete project manifest/index/HEAD schemas, source inventory and tombstone persistence rules.
5. Prove a portable implementation strategy for selected first host filesystem and atomic/flush semantics; define concurrent writers and OS crash behavior.
6. Define migration/rollback/incomplete commit recovery through explicit state-machine fixtures; provide crash cut-points.
7. Review source ownership, permission paths, symlink/case collisions, lockfile signing/authenticity and secrets exclusion.
8. Record architect approval. Native crash testing and power-loss evidence remain **Phase III**, not a fabricated design-stage pass.

D2 graph CAS cannot claim durable atomicity until these conditions are satisfied. This document deliberately distinguishes **a precise proposal** from **an implemented and verified guarantee**.
