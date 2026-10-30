# D6 — Filesystem Adapter and Durable Publication Capability Matrix

**Status: Proposed; no target adapter implemented or power-loss tested.** This document owns first-host OS file durability constraints, not portable graph semantics. [D6 Canonical Persistence](d6-canonical-persistence.md) owns snapshot layout and HEAD records; [D6 Package Integrity](d6-package-integrity.md) owns portable path restrictions. Do not claim crash safety merely because an OS provides a rename operation or a file flush API.

## F1. Proposed native adapter interface (logical, not frozen ABI)

    openProjectRoot(rootPath, noFollowLinks) -> RootHandle | error
    acquireSingleWriterLease(rootHandle, expectedEpoch) -> Lease | error
    createExclusiveStaging(rootHandle, operationId) -> StagingHandle | error
    writeAllAndFlushFile(stagingHandle, relativePath, bytes, permissions) -> FileDigest | error
    publishImmutableDirectory(stagingHandle, digestDirectory) -> PublishedHandle | error
    syncDirectoryMetadata(directoryHandle) -> Durable | Unproven | Error
    writeFlushAndReplaceHead(slot, bytes, expectedEpoch) -> Published | Ambiguous | Unsupported | Error
    openAndVerifyHead(slot) -> HEAD record | Corrupt | Missing
    removeOrphanStagingAfterRecovery(rootHandle) -> CleanupReport | error

The above operations never take uncontrolled path strings from AI output without validation. The actual native ABI, synchronization, cancellation, handles and error code mapping remain D4/D5/P0. The API must use handle-relative paths where possible, verify root containment and prevent symlink/reparse escapes or alias races.

## F2. Guarantees are capability-scoped

Three distinct properties must be reported separately:

1. **Atomic visibility:** readers either observe the old or new record, never a torn mixed record.
2. **Crash durability:** after reported success and power loss, record and directory entries survive; file contents are fully flushed to persistent media under the host storage stack's own guarantees.
3. **Recoverability:** after a fault, at least one HEAD record and all referenced snapshot bytes can be cryptographically verified, or recovery stops safely with a diagnostic.

An API returning success is not automatically evidence of all three. Network shares, FUSE, removable media, cloud-sync folders, cross-volume moves, unsupported write-through layers, unknown controller flush behavior and reparse aliases must initially be **UNSUPPORTED or UNVERIFIED**, not granted broad crash-safe status.

## F3. Linux local filesystem candidate

For a supported and separately qualified local filesystem:

- Create staging under the same mounted filesystem as snapshots and HEAD slots. Open root and directories with safe flags/dirfd-relative operations and verify symlink restrictions.
- Write full file bytes; check short writes and errors. Call fsync on each newly written file before considering its bytes durable.
- Publish an immutable snapshot directory by same-filesystem rename only after every declared file and index has been hashed and flushed. Sync affected source and target parent directories after directory entry changes.
- Generate the inactive HEAD record at a temporary sibling path, fsync its file descriptor, rename into the inactive slot, then fsync the parent directory. Only then may the adapter **claim its platform-qualified durability preconditions**.
- On EIO, ENOSPC, EROFS, short write, interrupted flush, failed rename or failed directory fsync, return a typed failed/ambiguous durability result; do not announce an accepted revision without recovering and verifying committed HEAD.

Linux fsync(2) explicitly explains that flushing a file does not ensure its directory entry is durable, hence the separate directory fsync. The rename(2) contract describes atomic name replacement when supported, but does not independently establish persistence after power loss.

Authoritative API context:
- https://man7.org/linux/man-pages/man2/fsync.2.html
- https://man7.org/linux/man-pages/man2/rename.2.html

**Open:** exact first supported filesystem and mount options, sandbox and ACL model, lock lifetime and behavior on abrupt process death, metadata sync error propagation, storage hardware caveats and actual fault-injection evidence.

## F4. Windows local NTFS candidate

The initial Windows Studio host is **proposed**. On local NTFS the candidate native adapter would use CreateFileW/WriteFile, explicit FlushFileBuffers on every written file, safe directory and reparse-point containment, and either ReplaceFileW or an evaluated MoveFileExW strategy for the inactive HEAD slot. All paths and files must reside on one local volume. A cross-volume move/copy-delete path is **not** an atomic snapshot publish.

**Do not assert:** ReplaceFileW, MoveFileExW with MOVEFILE_WRITE_THROUGH, FlushFileBuffers, or any combination automatically provides a universal directory-metadata persistence guarantee identical to Linux fsync(directory). Microsoft describes file flushing and replacement behavior separately. Their suitability for a provably crash-durable HEAD protocol must be established for the selected Windows/NTFS/storage configuration, and ambiguous success must be recoverable. If no suitable documented or experimentally verified path meets the contract, the adapter reports PERSIST_DURABILITY_UNSUPPORTED, while allowing a separately labeled best-effort save mode if approved.

Relevant Microsoft references:
- https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-flushfilebuffers
- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-replacefilew
- https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-movefileexw

**Open:** Windows directory handle durability feasibility, NTFS/volume qualification, antivirus sharing violations, ACL/reparse/junction containment, File ID/file replacement behavior, cloud sync/OneDrive relocation, locking and power-loss evidence.

## F5. Reader, writer, and recovery coordination

The writer lease is not the sole correctness mechanism: it must be combined with a revision/epoch CAS and validation of current HEAD before publication. Readers do not read staging; they verify a published HEAD/checksum, immutable snapshot index and every referenced required file before trusting code. The two HEAD slots are redundant candidate publication records, not two independent always-current projects.

On startup, evaluate both slots and snapshot digests; select highest *fully verified* epoch. A newest record whose checksum is intact but whose snapshot is corrupt is a **degraded recovery** condition: flag potential loss, do not silently claim it was a clean rollback. Both invalid -> PERSIST_RECOVERY_REQUIRED. Preserve evidence and avoid garbage collection until recovery decisions are made. Never auto-replay an external side effect after reopening.

## F6. Acceptance matrix (all NOT-RUN)

| Target / storage | Proposed capability status | Required evidence |
| --- | --- | --- |
| Linux x86-64, explicitly qualified local FS | UNVERIFIED | Actual file/directory sync, rename, crash-cutpoint, force-kill and corruption fixtures |
| Windows x64, explicitly qualified local NTFS | UNVERIFIED | Actual FlushFileBuffers/HEAD replace behavior, access/locking, power-cut and recovery tests |
| Linux AArch64 target with unspecified FS | UNSUPPORTED for durability claims | Board/system/fs qualification first |
| Network/SMB/NFS/FUSE/cloud-synced workspace | UNSUPPORTED for strong durability in first profile | New documented adapter/qualification |
| Removable or unknown mount/volume | UNSUPPORTED for strong durability in first profile | Device flush/atomicity and failure testing |
| Raw firmware/bare-metal | NO FILESYSTEM CONTRACT | Separate storage journal and hardware design required |

See [30 recovery scenarios](../../examples/architecture-sensor/d6-recovery-scenarios.md) and [integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json). None has been executed by AELYXORA.

## F7. Blocking decisions

1. Pick first host and supported storage class (Windows x64 local NTFS or Linux x86-64 qualified local filesystem).
2. Verify whether a durable inactive-HEAD replacement can be implemented on that exact platform under supported permissions.
3. Define OS-specific guarantee and fallback behavior independently from generic graph correctness.
4. Freeze directory/snapshot retention, write lease collision and post-crash operationId reconciliation.
5. Specify platform error codes and fault-injection harness design for the selected target.
6. Require explicit architect sign-off before any claim that this adapter is ready.

The first-runtime/declarative UI system may later be architected even if crash-durable publication is unsupported on a target, but release claims must never silently upgrade best-effort saves into strong durability.
