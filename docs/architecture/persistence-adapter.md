# Experimental Persistence Adapter

**Status:** C++23 prototype, not production-safe. No verified current Windows/Linux CI result.

The adapter uses Boost.JSON 1.81+ behind optional CMake flag `AELYXORA_WITH_BOOST_JSON`. The core model has no Qt or Boost dependency.

## Implemented subset

- JSON parse and serialize for Project, Targets, Modules, Components and dependencies.
- Schema version, graph validation, unknown-field rejection, maximum JSON size and parsing-depth bound.
- New-project save requires absent destination and revision zero.
- Existing-project save requires an expected revision and a new revision exactly one higher.
- Cooperative per-project directory lock (`.aelyxora-lock`) and checked staging file (`.aelyxora-stage`).
- Before replacement, current file bytes are compared with the bytes read while the lock was held.
- Tests include revision conflicts and an occupied cooperative lock.

## What this does NOT guarantee

- No `fsync`/`FlushFileBuffers`/directory sync or durable transaction journal: **power loss can lose changes**.
- Lock directories are honored only by cooperating writers, and stale locks require manual inspection and cleanup.
- Comparing file contents before rename is **not** atomic compare-and-swap against external editors.
- `std::filesystem::rename` may fail when replacing an existing file on Windows; the adapter returns an error and **does not remove the existing file**.
- Staging is deterministic, not unique. An abandoned staging file is intentionally left for explicit recovery.
- No symlink/path-boundary policy, sandboxing, secure file handles or schema migration.
- No independent JSON Schema validation run: C++ validation covers a subset of the declared schema.
- No in-repository verification of the current exact source through Windows/Linux builds was available at the time of this update.

## Build

```sh
cmake -S . -B build -DBUILD_TESTING=ON -DAELYXORA_WITH_BOOST_JSON=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

## Next engineering gate

Implement platform-specific durable replacement with unique staging names, flush and directory sync, explicit lock/recovery policy, journaled crash injection and multi-process race tests. Prove the guarantee independently on Windows and Linux before calling persistence production-ready.
