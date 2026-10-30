# Linked Pure Reference — D2/D6 Design Fixture

**Status: DOCUMENTATION-STAGE LINKED INTEGRITY FIXTURE. Not a runnable AELYXORA project, not an implemented Studio parser/runtime, not a released native ABI.** This fixture intentionally uses a harmless pure component graph instead of device access. It supplies **real exact source-file bytes**, a structurally complete package and project, a concrete lock, canonical semantic export identities, immutable package objects, a snapshot index and a genesis HEAD. These are inputs to *future* native validation and compilation tests.

## What exists

- Project graph: source.tick -> consumer.tick through edge e1 and a bounded stream DataFlow.
- Workflow accept-tick, triggered by a Tick; it dispatches a declared consumer.Accept operation and has typed success, failure and cooperative cancellation states.
- Two exported zero-field nominal record types: example.locked/Tick and example.locked/Failure. No external primitive registry is needed for those type exports.
- Package example.locked/1.0.0: actual source files in objects/packages/<contentDigest>/src/source.S and consumer.S, declared by a concrete manifest.
- package-lock.json pins the exact package content digest plus independently normalized public type/component export-contract digests, with a planned x86-64 Linux target.
- snapshots/<snapshotDigest>/index.json references the exact project/lock/view bytes and the immutable package object, and HEAD.0.json references its hash.
- integrity-vectors.json records canonical semantic projection bytes, export digest registry, package/snapshot/HEAD checksums and every raw file content hash.

## Deliberate non-implementation boundary

The Assembly files are **reference source inputs** for hashing, source ownership and build-input resolution. They contain valid-looking GNU x86-64 syntax but do **not** fulfill the proposed AELYXORA component binary ABI or the input/output/error handling promised by the logical commands. There is no emitted module header, descriptor, loader, compiler, scheduler, verified execution, active capability provider or real test result. Source existence is not executable ABI compatibility.

The target manifest status is planned, **not supported**. The lock records unverified toolchain labels. It would be dishonest to label this fixture successfully built or to mark D4/D5 gates as passed. A future native linker may reject the declared component provider with ABI_SOURCE_UNLINKED or a more precise D4 diagnostic; that is expected until a real accepted ABI implementation exists.

The current directory tree is a Git-friendly copy of the designed immutable layout; it does not establish fsync, atomic rename, locking, writer lease, two-slot durability or power-loss recovery on an OS. Only a genesis HEAD exists; no durable operation-history or crash test was performed.

## Reference procedure (future Stage III test, currently NOT-RUN)

1. Strictly parse and validate package/project/lock/HEAD/index shapes with the draft JSON Schemas.
2. Load the exact declared manifest and ASM source bytes from objects/packages/<packageDigest>. Normalize the manifest as specified, hash framed sorted file-set and match the lock digest.
3. Recompute each exported logical contract digest from the two types and two components, including transitive TypeIDs. Compare the lock exports array. Reject duplicate and unknown exporters.
4. Resolve graph node/ports and the workflow command/signal types. Build the exact projection in integrity-vectors.json; compare canonical bytes and semanticGraphDigest.
5. Verify project/lock/view byte SHA-256 hashes in the immutable snapshot index; verify packageObjects equality to the lock.
6. Hash the canonical index to confirm snapshotDigest; check all matching HEAD fields and checksum. Never skip a missing package object.
7. Attempt a negative variant (alter source byte, change exported command type, remove package object, corrupt HEAD checksum, move map coordinate). Verify the expected layer-specific diagnostics and which digests change.
8. Independently prove target ABI, source exports and actual assembly toolchain before claiming a runnable component; this last step is BLOCKED in Phase I and is not part of this fixture's passed status.

## Expected digest record

The authoritative current calculation values are in [integrity-vectors.json](integrity-vectors.json). They are **reference calculation values only**, not native AELYXORA observed test outcomes. The SHA-256 inputs include literal line endings and whitespace of the raw sources.

## Known blockers before D2/D6 sign-off

Full core type registry beyond the zero-field records; cross-file source ownership and D3 declarative origin; exact package dependency-version conflict policy for multiple versions; complete safe resource profile; real D4 native ABI and operation symbol linkage; first host filesystem atomic/durable publication; committed operationId retention policy; independently exercised parser/hash implementation. The [baseline review](../../docs/architecture/d2-d6-baseline-review.md) tracks these under P0.

**Repository discipline:** documentation-stage changes are made directly in main; no feature branches/PRs, no product implementation and no CI.
