# X01 integrated lifecycle + ResolveRef — actual local execution

**2026-11-01. Linux x86-64 native test PASSED (exit 0). Win64 COFF cross-assembly PASSED for all three modules. Windows runtime NOT-RUN.** The three committed sources are [resolver](../../tests/native/x01_resolve_table.S), [lifecycle](../../tests/native/x01_arena_entry_lifecycle.S), and [integrated test](../../tests/native/x01_arena_integrated_test.S).

Observed local commands, with exact instruction-equivalent source written to the local compilation directory (GitHub raw host DNS was unavailable):
```sh
clang -no-pie resolve.S lifecycle.S integrated.S -o integrated
./integrated
# observed exit 0
clang --target=x86_64-pc-windows-msvc -c resolve.S -o resolve.obj
clang --target=x86_64-pc-windows-msvc -c lifecycle.S -o lifecycle.obj
clang --target=x86_64-pc-windows-msvc -c integrated.S -o integrated.obj
file *.obj
# all three: x86-64 COFF
```

The initial Win64 cross-assembly of the harness failed because the Linux-only `.note.GNU-stack` directive was invalid for COFF. The directive was removed in commit `61d2179`; the subsequent three-object Win64 cross-build succeeded. The integrated harness has twelve numbered error exits; exit zero indicates the entire expected path passed: publish generation 7, acquire, valid table resolve, attempted retire while leased rejected, release, successful retire, old ref rejected, republish generation 8, acquire, old generation still rejected, new ref accepted, release.

**Security qualification:** all checks are single-threaded and use static pinned backing storage and a host-supplied trusted table pointer. There is no allocation/free, OS memory protection, descriptor-kind check, table byte-length validation, concurrency synchronization, actual platform lease/borrow ownership, or generation 65535 exhaustion test. The existing `x01_resolve_table` returns a pointer on the basis of a nonzero global leaseCount; it **cannot prove that the caller owns that lease**. A future protected lookup/borrow API must close this boundary before production. No T0 proof, compiler acceptance, D2/D3 public trust or D1–D8 gate closure follows. X01 remains OPEN.
