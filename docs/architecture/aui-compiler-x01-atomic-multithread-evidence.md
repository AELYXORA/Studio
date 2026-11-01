# X01 atomic borrow — actual Linux multithread stress evidence (2026-11-01)

**Executed:** 4 concurrent pthread workers in a Linux x86-64 GAS Assembly harness, calling the [Win64-register ABI atomic gate](../../tests/native/x01_atomic_borrow_gate.S). [Test source](../../tests/native/x01_atomic_thread_test.S).

Local command:
```sh
clang -no-pie -pthread x01_atomic_borrow_gate.S x01_atomic_thread_test.S -o x01_thread_test
for i in $(seq 1 20); do ./x01_thread_test; echo $?; done
```
**Observed:** twenty consecutive exit codes were `0`. The gate source also cross-assembled to x86-64 Windows COFF. This does **not** mean Windows execution; the test harness calls Linux `pthread_create` and `pthread_join`.

Each run launches four concurrent workers. Workers repeatedly acquire with locked CAS, count success, release and finish after acquisition becomes unavailable; main waits until at least 100 successful acquisitions, begins retirement, joins workers and finishes retirement. Assertions cover absence of release failures, at least one successful acquisition and one denied attempt, final gate zero and continued acquisition rejection after retirement. The initial version of the test loop allowed workers to finish before retirement and produced **sporadic exit 8**. Test sequencing was corrected before the final 20/20 runs.

**Limits:** no exhaustive race proof, no independently controlled interleaving, no TSAN or formal linearizability test; no per-caller authenticated borrow token, no real pinned arena bytes or descriptor type checks, no OS allocator/free and no Win64 runtime execution. Current release API only decrements a shared count, so it remains unsafe if exposed to arbitrary callers. X01 and D1–D8 OPEN.
