# X01 ResolveRef — first executed Assembly negative-test harness

**2026-11-01. Observed Linux x86-64 native execution of an Assembly-only harness; NOT Win64 execution.** Repo sources: [one-entry ResolveRef](../../tests/native/x01_resolve_ref_one.S) and [test harness](../../tests/native/x01_resolve_ref_runtime_test.S).

### Commands and result

```sh
clang -no-pie tests/native/x01_resolve_ref_one.S tests/native/x01_resolve_ref_runtime_test.S -o x01_resolve_ref_test
./x01_resolve_ref_test
echo $?
# observed: 0
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_resolve_ref_one.S -o x01_resolve_ref_one.obj
# observed: successful x86-64 COFF
```

The harness is written entirely in GAS Assembly and calls the tested function with Windows x64 register argument ordering and 32-byte shadow-space reservation. It uses Linux's process loader only to execute the **same tested Assembly routine** locally. Six assertions executed; result was process exit code 0:

| Case | Input | Expected |
| --- | --- | --- |
| R01 | index=2, generation=1, offset=16, size=8, align=8, sealed leased entry | returns base+16 |
| R02 | generation=2 mismatches current generation=1 | zero |
| R03 | offset=60, requestedBytes=8, committed=64 | zero |
| R04 | offset=18, align=8 | zero |
| R05 | align=3 (not power of two) | zero |
| R06 | leaseCount=0 | zero |

### Strict limits

This proves only these six deterministic test outcomes in the local Linux process. It is **not a production arena manager**, and does not exercise Windows PE linking/execution, descriptor table lookup, concurrent retire, allocator pressure, u16 generation wrap, expected descriptor-kind binding, memory ownership, negative wild pointers or poison guard pages. The descriptor is a host-pinned synthetic 32-byte entry and no source-controlled pointer is admitted. No complete T0 lexer/parser, T1+ compiler, or D1–D8 acceptance is implied. **X01 remains OPEN.**

Next engineering closure: implement actual checked arena table index/generation/ownership and a separate test matrix for descriptor types, 0-byte policy and teardown; execute a Win64 test binary and independently verify results.
