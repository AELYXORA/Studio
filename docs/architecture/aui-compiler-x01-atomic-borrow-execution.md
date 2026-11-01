# X01 atomic borrow gate — first executed Assembly probe (2026-11-01)

**Actual execution: Linux x86-64 exit 0.** [Atomic gate Assembly](../../tests/native/x01_atomic_borrow_gate.S) and [test harness](../../tests/native/x01_atomic_borrow_gate_test.S) also cross-assembled successfully into separate Windows x64 COFF objects using Clang 17.

Local verification commands (run in local workspace using byte-for-byte equivalent assembly of the committed routines):
```sh
clang -no-pie atomic_gate.S atomic_test.S -o atomic_test
./atomic_test
# observed exit: 0
clang --target=x86_64-pc-windows-msvc -c atomic_gate.S -o atomic_gate.obj
clang --target=x86_64-pc-windows-msvc -c atomic_test.S -o atomic_test.obj
# both observed x86-64 COFF
```

The atomic aligned 64-bit gate packs state in low 32 bits and activeBorrowCount in high 32 bits. `x01_borrow_try_acquire` increments count via `lock cmpxchg` only in OPEN state (1); `x01_borrow_begin_retire` CAS switches OPEN to RETIRING (2), preserving count; `x01_borrow_release` decrements nonzero count; `x01_borrow_try_finish_retire` atomically sets state to VACANT (0) only when RETIRING and count is zero. The test has eight failure exit sites and asserts the expected sequential transition path.

**Critical limitations:** no multithreaded execution, synchronization with allocation ownership/arena table, descriptor-kind checking, actual memory pinning, callback-scoped capability enforcement, OS wake/wait, Windows execution or safe retirement/free. A nonzero count does not prove caller ownership. The release routine is not a secure per-caller borrow-token API and must not be exposed to untrusted callers. The test does not prove linearizability under scheduler races. X01 and D1–D8 remain OPEN.
