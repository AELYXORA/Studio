# X01 consolidated borrow/check candidate — 2026-11-01

**Observed execution:** Linux x86-64 Clang 17 native executable exited 0; Windows x64 COFF cross-assembly succeeded. Sources: [integrated code](../../tests/native/x01_with_typed_ref.S), [harness](../../tests/native/x01_with_typed_ref_test.S), and [existing atomic gate](../../tests/native/x01_atomic_borrow_gate.S).

```sh
clang -no-pie tests/native/x01_atomic_borrow_gate.S tests/native/x01_with_typed_ref.S tests/native/x01_with_typed_ref_test.S -o x01_typed_borrow_test
./x01_typed_borrow_test
# observed: exit 0
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_with_typed_ref.S -o x01_typed_borrow.obj
file x01_typed_borrow.obj
# observed: x86-64 COFF object file
```

**What this consolidates:** instead of calling a snapshot-only preflight and then separately doing a pointer lookup, the new wrapper checks that `tableBytes` can hold all declared entries *before dereferencing a selected entry*, then obtains the **embedded per-entry atomic gate borrow**, verifies exact Ref64 index/generation, sealed state, expected descriptor kind, host ownerLease, positive request size, power-of-two alignment, bounded extent and pointer overflow before invoking one synchronous trusted callback. It finally releases its borrow on the normal return path. Request is 32 bytes with `Ref64@0, tablePtr@8, bytes@16, alignment@20, expectedKind@24, trustedTableBytes@28`. Entry remains an **experimental** 40-byte record.

Test has eight separate failure exits: success callback value 23; short table; mismatched expectedKind; stale generation; retiring gate; callback count exactly once; gate state preserved. The first local build failed on mixed-width `cmp r10d, word ptr [r15]`; changed to `cmp r10d,dword ptr [r15]`, after which build and execution succeeded.

**Hard stop (not a production Arena Manager):** `tableBytes` and table pointer are trusted host metadata; table is not OS-allocated/pinned/locked by this module. Concurrent table reallocation/rewrite, descriptor mutation, callback unwind, pointer escape and forged callback pointers are unresolved. Return=0 remains ambiguous with a valid callback returning 0. This does **not** settle BR01–BR16, Win64 runtime verification, allocator ownership, source Unicode policy, IAI-v1 acceptance or T0 compiler implementation. X01 and D1–D8 OPEN.

**Next concrete implementation order:** (1) host-owned immutable table allocation/lifetime and per-slot serialized Publish/Retire; (2) explicit status/output records plus non-unwinding callback boundary; (3) Win64 executable running tests; (4) first LexerScan UTF-8 and golden tests. Never silently ship old `x01_with_bound_ref` as a production API.
