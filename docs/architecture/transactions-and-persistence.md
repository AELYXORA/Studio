# Model Transactions, Persistence and Recovery

**Status:** proposed normative contract; not implemented.

## Transaction model

All durable model mutations are commands against a revisioned snapshot. A transaction contains transactionId, expectedRevision, operations, preconditions, validation policy and origin (human/AI/import). Commands reference stable IDs, not UI positions or mutable names.

Result is either a new validated revision plus change-set and diagnostics, or a rejection with **no model mutation**. No partial object graph writes.

## Concurrency

Use optimistic concurrency control: commit if expected revision matches current revision; otherwise return conflict details and offer explicit rebase/retry. An external file watcher invalidates stale snapshots. Never auto-merge competing structural edits without validation.

## Undo and redo

Undo records semantic inverse operations plus required revision context, not merely widget state. Undo may fail safely when external edits invalidate preconditions. Redo must not reapply stale side effects. Actions that touch external resources or deployment are not blindly undoable.

## Persistence

- Store canonical project metadata as UTF-8 text with a deterministic serialization order.
- Parse into an untrusted temporary representation; enforce schema size/depth limits, stable ID uniqueness and references before publication.
- Back up or checkpoint before destructive schema migration.
- Write to temp path, flush, atomically replace when filesystem supports it, then update project revision.
- Do not claim cross-file atomicity from individual file renames; use journal/manifest and recovery.
- Validate project root boundaries and symlinks before writing.

## Migration

Version persisted schema independently of product branding. Migration plan identifies source/target schema, transformations, lossiness and required backup. Migrations are idempotent where feasible, chainable, validated on fixtures and refuse unsupported future versions without rewriting them.

## Recovery

Detect interrupted transactions through write journal and file hashes. On restart, offer replay/rollback to a verified snapshot; never silently discard unknown edits. Persisted state and generated output consistency are checked separately.

## Test matrix

Roundtrip, crash injection at each commit stage, conflict revisions, rename/reference stability, failed migration, rollback preservation, stale undo, malformed project, symlink escape and external editor change.
