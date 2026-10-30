# ADR-0005 — Revisioned Transactions and Recovery

**Status:** proposed

## Context

Designer, AI and external editor may edit the same project. Multi-file operations and schema migrations can fail partway through.

## Decision

Use immutable snapshots and revision-checked semantic commands. Validate before commit, reject stale revisions, preserve undo inverses, journal multi-file operations and perform crash recovery on restart. Do not claim filesystem-wide atomicity from per-file rename.

## Consequences

Adds transactional infrastructure before UI breadth, but prevents silent overwrites and provides a foundation for safe AI-mediated edits.
