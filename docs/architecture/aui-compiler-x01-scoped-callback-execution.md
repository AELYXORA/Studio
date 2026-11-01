# X01 callback-scoped ResolveRef — executed prototype

**2026-11-01. Linux x86-64 execution PASS (exit code 0). Win64 x86-64 COFF cross-assembly PASS for wrapper. Production safety NOT ESTABLISHED.**

Sources: [callback-scoped wrapper](../../tests/native/x01_with_resolved_ref.S) and [Assembly harness](../../tests/native/x01_with_resolved_ref_test.S), linked with earlier [atomic gate](../../tests/native/x01_atomic_borrow_gate.S) and [table resolver](../../tests/native/x01_resolve_table.S).

Local commands, using assembly source equivalent to the committed files:
```sh
clang -no-pie deps.S with_ref.S harness.S -o run
./run
# observed exit code 0
clang --target=x86_64-pc-windows-msvc -c with_ref.S -o with_ref.obj
# file: x86-64 COFF object file
```

The wrapper uses Win64 calling convention, takes a trusted request pointing to Ref64/table/gate/bytes/alignment, and a trusted callback. It acquires a count from the atomic gate **before** resolving the pointer; calls the callback synchronously with the temporary pointer; releases the gate after the callback returns. The test checks valid bytes, calls begin-retire *within the callback*, confirms finish-retire fails while callback holds the borrow; after callback returns, confirms no second callback invocation and finish-retire succeeds. Seven distinct assertion exits; successful process status 0.

**Known security boundaries:** request, gate, table and callback addresses are trusted host-owned inputs; wrapper does not authenticate that the gate actually governs the requested table entry or backing allocation. The existing resolver still checks legacy leaseCount; no descriptor-kind contract, byte-size of table, genuine OS allocation/free or concurrent lifetime integration. Only normal callback return is covered — no exception, cancellation or longjmp/unwind cleanup. Callback pointer escape is forbidden by contract, not prevented by this API. Return code 0 conflates a valid callback returning 0 and errors. No Windows execution or adversarial real thread race in this integrated test. Do not expose wrapper to untrusted source or move into T0 compiler production. X01, D1–D8 remain OPEN.

Next required proof: bind each verified arena entry to its unique atomic gate, enforce lexical callback lifetime and typed descriptor at trusted API boundary, distinguish errors from callback results, and run a true multi-thread allocation/retire harness on Windows.
