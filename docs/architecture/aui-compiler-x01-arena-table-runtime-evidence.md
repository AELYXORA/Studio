# X01 Arena-Table ResolveRef — executed Assembly tests (2026-11-01)

**Observed:** Linux x86-64 GAS/Clang native execution, process exit code **0**, five test cases passed. The same resolver cross-assembled to Windows x64 **COFF**. Windows execution and a production arena allocator remain **NOT-RUN**.

Sources: [resolver](../../tests/native/x01_resolve_table.S), [test harness](../../tests/native/x01_table_test.S).

Commands executed:
```sh
clang -no-pie tests/native/x01_resolve_table.S tests/native/x01_table_test.S -o tabletest
./tabletest
# exit: 0
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_resolve_table.S -o x01_resolve_table.obj
file x01_resolve_table.obj
# x86-64 COFF object file
```

The resolver takes **Win64 register arguments** RCX=Ref64, RDX=trusted pinned table, R8D=request size, R9D=alignment and returns RAX=pointer/zero. Table prefix is u32 count, u32 reserved, followed by count * 32-byte entries; each entry carries index, generation, state=sealed, committed byte count, descriptor kind, host base pointer and lease count. A Ref64 index selects the table slot before its index and generation are checked.

| Case | Expected | Local result |
| --- | --- | --- |
| Valid sealed, leased index=1/generation=2, offset=16, size=8 | base+16 | PASS |
| Stale generation | zero | PASS |
| Index outside table count | zero | PASS |
| Extent past committed bytes | zero | PASS |
| Revoked lease | zero | PASS |

**Critical preconditions and gaps:** host must validate and pin table allocation/length, all backing arena allocations and concurrency lifetime. This routine does not validate expected descriptor kind, independently verify immutable sealed state, atomically manage leases, allocate/free arenas, advance generations, or check generation wrap. The table count itself is host-controlled and not independently bounded by buffer length. The returned pointer must not outlive its pin. It is **not safe to call with attacker-provided table pointers**. No source/Graph trust or T0 proof is established. X01 remains OPEN, all D1–D8 gates OPEN.
