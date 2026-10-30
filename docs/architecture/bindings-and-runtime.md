# Data Binding and Runtime Semantics

**Status:** proposed; semantic rules must be implemented before broad component expansion.

## Binding kinds

1. **One-time:** evaluate on activation or explicit refresh.
2. **One-way:** source updates propagate to destination.
3. **Two-way:** user edits propagate back through validated conversion and commit; cycles are prevented by transaction origin/version checks.
4. **Command/event:** discrete actions with input, result and failure.
5. **Stream:** bounded asynchronous delivery with explicit backpressure.

Each connection declares source and destination typed paths, binding mode, converter identity, null policy, error handling and scheduling domain. No implicit lossy numeric conversions.

## State and scheduling

Properties have explicit ownership and persistence scope. Runtime recomputations use a consistent transaction snapshot. Dependency order is deterministic for acyclic reactive graphs; cycles are rejected unless a named state/delay operator breaks them. No arbitrary synchronous reentrant event dispatch.

Visual properties update on their UI thread via marshalled notifications. Background actions declare cancellation, completion, error and concurrency rules. Avoid blocking the UI thread with I/O.

## Data access

Repositories expose typed queries, filtering, pagination, mutations and transactional operations. SQLite is the first adapter; database schema migrations are versioned separately from project schema. Validation runs before persistence; DB constraints remain authoritative. Secrets and credentials are not saved in visual model files.

## Error semantics

Bindings surface errors with component ID, path, error code, recoverability and causal operation. Missing paths, invalid converters and unsupported target capabilities fail validation or produce explicit runtime diagnostics, never silent default values.

## MVP acceptance

A list selection populates an edit form; save validates and persists a customer; reload preserves data; errors show clearly; invalid binding does not compile into a silently broken app; undo in the designer does not pretend to undo a committed database action.
