# X01 bound ResolveRef vs concurrent retire — executed two-thread test

**2026-11-01. Verified local Linux x86-64 native execution: 30/30 runs with exit code 0. Windows x64 COFF cross-assembly verified for bound resolver; Windows native runtime NOT-RUN.**

Sources: [thread harness](../../tests/native/x01_bound_ref_thread_test.S), [bound resolver](../../tests/native/x01_with_bound_ref.S), [atomic gate](../../tests/native/x01_atomic_borrow_gate.S).

Commands used on local Clang 17 toolchain with copies of the corresponding GAS Assembly code:
```sh
clang -pthread -no-pie gate.S bound.S thread.S -o threadtest
timeout 3s ./threadtest
# observed exit code 0
for i in $(seq 1 30); do timeout 3s ./threadtest || echo failure; done
# observed: 0 failures
clang --target=x86_64-pc-windows-msvc -c bound.S -o bound.obj
file bound.obj
# observed: x86-64 COFF object file
```
Observed test harness SHA256: `e229be4bac4e9de765397b4c79cab3ab6d7ba3f5a5c55a88302c1eee9be5ebe8`. Exact assembled test logic was committed in the harness linked above.

Worker thread enters a trusted callback with an active borrow, checks an 8-byte value, sets an entry flag and waits. The main thread begins retire and verifies that finishing retire fails during the borrow; a new callback attempt is rejected. Main then signals the worker to complete; after joining it checks callback result 91, finishes retire and checks gate state zero. Eight numbered failure codes discriminate assertion failures.

**Limits:** the test uses a fixed backed 64-byte array, not allocated/decommitted/free'd pages; the host pins the table, gate, and allocation by fixture arrangement. There is no descriptor-kind verification, typed callback identity/capability, pointer-escape prevention, callback-unwind cleanup, real Windows execution, formal scheduling proof, or safe table relocation. The gate is bound to one entry but table and arena lifetime are not yet independently secured. Tests are controlled interleavings, not evidence of full thread-safety or compiler readiness. X01 and D1–D8 OPEN.
