# X01 per-entry gate bound ResolveRef — executable candidate (2026-11-01)

**Local observed result:** Linux x86-64 executable from the Assembly source returned 0; Clang 17 emitted Windows x64 COFF for resolver. Sources: [resolver](../../tests/native/x01_with_bound_ref.S), [test](../../tests/native/x01_with_bound_ref_test.S), and earlier [atomic gate](../../tests/native/x01_atomic_borrow_gate.S).

Build commands:
```sh
clang -no-pie bound.S gate.S test.S -o test
./test  # observed exit 0
clang --target=x86_64-pc-windows-msvc -c bound.S -o bound.obj
file bound.obj # x86-64 COFF
```

**What changed:** the caller cannot pass an independent gate address. The resolver derives the 40-byte entry from a trusted table and Ref64 arena index, then acquires the atomic gate **embedded at entry offset +32** before validating index, generation, sealed state, ownerLease, bounds, alignment and resolving the pointer. It executes one synchronous trusted callback and releases the acquired count afterward. The seven-failure-branch test observes a callback beginning retirement, blocked finish during callback, successful finish afterward and stale-generation rejection.

**CRITICAL — candidate only, X01 still OPEN:** table length, allocation, synchronization and ownership remain trusted external preconditions. In particular, table entry address and backing storage must remain pinned; callback MUST NOT escape pointer or unwind through the wrapper. There is no allocator/free, descriptor-kind enforcement, callback authentication, table-wide lock, verified caller capability, Windows runtime or adversarial multithreaded integrated test. The test manually resets the gate for its stale-generation scenario; this is a fixture, **not** a supported production state transition. The 40-byte record is a new experimental layout, not the accepted compiler ABI. Return 0 still conflates failures and valid callback 0. No D1–D8 gate accepted.
