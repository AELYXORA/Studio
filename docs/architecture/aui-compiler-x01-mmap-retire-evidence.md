# X01 real memory allocation race test — 2026-11-01

**Observed local result: 30/30 Linux x86-64 runs PASS, exit 0; Clang 17 cross-assembled the existing bound resolver to Win64 COFF. Win64 runtime NOT-RUN.**

Source: [Assembly-only pthread + mmap harness](../../tests/native/x01_bound_ref_mmap_test.S), linked against [gate](../../tests/native/x01_atomic_borrow_gate.S) and [bound resolver](../../tests/native/x01_with_bound_ref.S).

```sh
clang -pthread -no-pie tests/native/x01_atomic_borrow_gate.S tests/native/x01_with_bound_ref.S tests/native/x01_bound_ref_mmap_test.S -o mmap_test
for i in $(seq 1 30); do timeout 3s ./mmap_test || exit 1; done
# observed: PASS 30/30
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_with_bound_ref.S -o bound.obj
# observed: x86-64 COFF object file
```

The main thread calls Linux `mmap` for 4096 read/write bytes and publishes the pointer into a static test table. The worker enters `WithResolvedRef` and blocks within a callback while retaining an atomic borrow; main begins retire, confirms finish-retire fails, and new callback admission rejects. Main releases the worker and joins it, then finishes retire, `munmap`s the allocation, clears the static test pointer and verifies the old ref cannot enter callback. Ten differentiated failure exit codes.

**Important scope:** This tests a controlled two-thread interleaving with real page-backed allocation and deallocation, not true production allocation ownership. The table and gate are static and trusted, no concurrent mutation of entry fields is permitted until all borrows complete. No Win64 runtime, typed descriptor proof, secure callback identity, forced exceptional unwind, arbitrary scheduler exploration or protection against pointer escape. `munmap` failure returns a specific test code. Even 30/30 passes do not prove absence of use-after-free in arbitrary interleavings. X01 and D1–D8 remain OPEN.
