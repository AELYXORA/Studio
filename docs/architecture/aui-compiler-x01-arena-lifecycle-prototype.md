# X01 Assembly arena lifecycle prototype — verification status

**Status: IMPLEMENTED AS CANDIDATE SOURCE, NOT EXECUTED/NOT COMPILED IN THIS TURN.** The [entry lifecycle](../../tests/native/x01_arena_entry_lifecycle.S) and [assembly harness](../../tests/native/x01_arena_lifecycle_test.S) were committed. An attempt to retrieve the files into a local compiler container failed due to unavailable DNS for raw.githubusercontent.com, before any source compilation. Therefore no successful compile, COFF or runtime result is claimed for these new files.

The 32-byte entry prototype has `index:u16, generation:u16, state:u32, committed:u32, kind:u32, base:u64, leaseCount:u64`. It provides `x01_entry_publish`, `x01_entry_acquire`, `x01_entry_release`, and `x01_entry_retire` using Win64 argument conventions. A successful retirement requires sealed state and zero leases, invalidates base/committed/kind, increments the generation, and permanently retires a slot when generation is 65535. The harness proposes checks for publish, acquire, refusal to retire with an outstanding lease, release, retirement, generation advance, lease underflow and republish.

**Security limits:** single-threaded pinned entry assumption; no actual allocation/free, table capacity proof, nonforgeable lease ownership, concurrency synchronization, atomic state publication, descriptor-kind checks, tests for generation exhaustion, use-after-release, or Windows runtime execution. A counter is not a lifetime guarantee; safe consumers require a held pin/lease across dereference. The design's `publish` stores a provided trusted base address and does not allocate it.

Replay once sources are accessible locally:

```sh
clang -no-pie tests/native/x01_arena_entry_lifecycle.S tests/native/x01_arena_lifecycle_test.S -o x01_lifecycle_test
./x01_lifecycle_test; echo $?
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_arena_entry_lifecycle.S -o x01_lifecycle.obj
```

Until those commands are executed and independently inspected, both test outcomes are **NOT-RUN** and X01 remains OPEN. Never elevate T0, T2 or D1–D8 evidence from this candidate.

## Follow-up execution evidence — 2026-11-01

A subsequent local verification **actually executed** the previously NOT-RUN source. Exact GitHub contents of `tests/native/x01_arena_entry_lifecycle.S` and `tests/native/x01_arena_lifecycle_test.S` were transcribed into the local build workspace and compiled without modifications to executable statements. Linux host: x86-64; Clang 17.0.0.

```sh
clang -no-pie lifecycle.S test.S -o test
./test
echo $?
# observed: 0
clang --target=x86_64-pc-windows-msvc -c lifecycle.S -o lifecycle.obj
file lifecycle.obj
# observed: x86-64 COFF object file
```

The harness has ten distinct failure exit labels; an observed exit 0 confirms all assertions in **that one sequential test run** passed. It exercises publish, acquire, blocked retire while leased, release, retire, generation 7→8, empty-lease failure, and republish. This evidence supersedes the previous **NOT-RUN** status for this specific Linux run and COFF assembly only. Still NOT-RUN: Windows execution, concurrency/races, actual allocator/free, typed descriptor checks, generation wrap, and integration with a pinned arena table. X01 and D1–D8 OPEN.
