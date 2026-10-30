# D6 — Immutable Snapshot and Recovery Acceptance Design

**Status: future test specifications; observed result of every case is NOT-RUN.** The [canonical persistence contract](../../docs/architecture/d6-canonical-persistence.md) is proposed and not architect-approved. No native parser, checksum validator, snapshot index writer, filesystem adapter, crash journal, or storage durability test harness exists. These scenarios must not be described as successful tests. [HEAD record schema](../../schemas/project-head.schema.json) and [snapshot index schema](../../schemas/project-snapshot-index.schema.json) are structural proposals, not a complete snapshot implementation.

## Fixture foundations

- Initial state: immutable fully validated snapshot S0 at graph revision 10, active HEAD.0 epoch 20, valid HEAD.1 epoch 19 referencing previous validated snapshot. All actual digests are **to be calculated from real fixture bytes during test implementation**, not fabricated here.
- Candidate S1: one changed data channel capacity in the canonical semantic graph and a changed generated source file; expected graph revision 11 and different semantic/source/snapshot digests. View-only candidate V1 changes ViewRevision but not graph revision or semantic digest.
- Every test must record exact host/filesystem, directory durability support, toolchain version, fsync barriers, source/lock/index content digests, HEAD bytes/checksum, fault injection point, expected/observed revision, limitations and cleanup behavior.
- Do not issue any actual external I/O/device command during project recovery or replay unresolved in-flight workflows.

## Crash cut-point matrix

| ID | Inject fault / scenario | Required recovery observation |
| --- | --- | --- |
| REC-01 | Prior valid HEAD and snapshot, no pending transaction | Select S0 and verify every declared file hash |
| REC-02 | Crash after one source staged, before remaining files | Select S0; incomplete staging is not a project |
| REC-03 | Crash during project manifest write in staging | Select S0; truncated candidate never used |
| REC-04 | Crash after all candidate files written but before file flush | Select S0 or fully durable previous state; never trust staging |
| REC-05 | Crash during index creation/checksum before flush | Select S0; no candidate HEAD published |
| REC-06 | Crash after file flush but before durable snapshot directory publication | Select S0; orphan candidate quarantined |
| REC-07 | Crash while renaming staging directory to content-addressed snapshot | Select S0 or verified immutable S1 not yet HEAD-referenced, never mixed tree |
| REC-08 | Candidate snapshot fully durable, crash before inactive HEAD temporary write | Select S0; candidate is not published |
| REC-09 | Crash during temporary HEAD write, before atomic replace | Select S0, ignore partial temporary pointer |
| REC-10 | Crash after temporary HEAD flush but before inactive slot replacement | Select S0; new HEAD not yet published |
| REC-11 | Crash during inactive HEAD atomic replace | Select highest checksum-valid, snapshot-valid slot; S0 or S1 depending OS atomicity, no torn slot accepted |
| REC-12 | Crash immediately after HEAD replacement, before directory durability | Report ambiguous commit result; select only a fully verified S0/S1 |
| REC-13 | Crash after durable HEAD success but before UI acknowledgement | On reopen select S1; operationId reconciliation prevents accidental second publication |
| REC-14 | Active slot corrupted, previous slot intact | Recover previous fully valid snapshot and report loss/degraded integrity, do not silently certify newest |
| REC-15 | Highest epoch HEAD valid checksum, but snapshot index missing | Reject highest; open prior verified slot only with explicit degraded-recovery notice |
| REC-16 | Both HEAD slots checksum invalid | PERSIST_RECOVERY_REQUIRED, no fabricated project |
| REC-17 | Snapshot index hash valid but declared source content differs | PERSIST_SNAPSHOT_CORRUPT, do not execute changed source |
| REC-18 | Package lock digest differs from immutable index | PERSIST_SNAPSHOT_CORRUPT / PKG_DIGEST_MISMATCH by validation stage |
| REC-19 | Attempt path traversal or symlink to outside project during snapshot publication | PKG_PATH_ESCAPE or PERSIST_PATH_ESCAPE; never follow escape |
| REC-20 | Concurrent writers both assume epoch 20 and graph rev 10 | Exactly one accepted commit, second PROJECT_STALE_REVISION; no mixed source sets |
| REC-21 | Reuse committed operationId with identical exact input hash | Idempotent observed prior result or explicit ambiguous-success reconciliation; do not duplicate side effects |
| REC-22 | Reuse operationId with a different content digest | PERSIST_OPERATION_CONFLICT, no publication |
| REC-23 | Same semantic graph, changed source whitespace | semanticGraphDigest unchanged, source and snapshot digests changed; rebuild affected artifact only |
| REC-24 | Node moved on map, only view revision changes | semantic graph digest unchanged; no native rebuild caused by view-only edit |
| REC-25 | Commit valid semantic no-op | No GraphRevision increment; no false semantic change |
| REC-26 | Older workflow execution pins S0 while S1 becomes current | Retain S0 files/exports/tickets until safe quiescence; later S1 not retroactive |
| REC-27 | Garbage collector encounters active/previous HEAD snapshot | Never deletes referenced or pinned snapshot |
| REC-28 | Unsupported filesystem with unproven atomic/durable HEAD replace | PERSIST_DURABILITY_UNSUPPORTED; do not claim successful safe commit |
| REC-29 | Unexpected restart after hardware/network effect with unknown outcome | Persist graph definitions only; do not automatically replay operation |
| REC-30 | Rollback/repair from corrupted newest snapshot | Explicit degraded-recovery report and user approval; do not pretend latest successful commit remained intact |

## Important unresolved proof obligations

1. **HEAD record checksum:** exact canonical HEAD-fields byte sequence and domain separator must be frozen; the proposed two-slot design must preserve a valid prior record through atomic replacement and power loss.
2. **Snapshot inventory:** exact canonical index byte representation, complete file inventory, symlink/path/case behavior and content digest framing are open until reference vectors agree.
3. **OS adapters:** Windows and Linux atomic replacement, file/directory flush semantics, permissions, locks and rename guarantees require separate first-host contract and actual tests.
4. **Durability versus atomic visibility:** atomic file replacement does not guarantee persistence without flush; do not conflate the two.
5. **Ambiguous commit recovery:** after crash between durable replacement and acknowledgement, callers must discover if operationId committed before attempting a new edit; it is never safe to blindly replay a non-idempotent external effect.
6. **Snapshot retention and tamper response:** how far back recovery can go, when garbage collection is safe and whether signature/authenticity is required remain explicit P0 choices.
7. **Version/migration:** a new schema version must not bypass old hash verification, retire stable IDs, reinterpret topology, or silently discard unknown required extension data.

## Later acceptance record

Each scenario needs exact acceptance result, host/target/FS, parser and serializer executable identity, fixture/digest provenance, observed HEAD choice, error code, potential data loss and rerun evidence. Until those executable observations exist, every case is NOT-RUN and no release or power-loss reliability claim follows.
