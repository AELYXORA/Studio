# X01 — gate/table integration experiment and rejected TOCTOU design

**Status: cross-assembly EXECUTED, design NOT SAFE FOR PRODUCTION.** Source: [experimental gate resolver](../../tests/native/x01_gate_table_resolve_experiment.S). Local Clang integrated assembler targeting `x86_64-pc-windows-msvc` successfully emitted an x86-64 COFF object. **No runtime execution** of this experiment, no callback ownership tests, and no Win64 host execution.

The experimental table gate at a host-defined address just before the table checks OPEN and active count before tail-calling `x01_resolve_table`. **This is a deliberately rejected approach:** the check and pointer return are not atomic with the lifetime of an individual caller borrow. Even if the gate is OPEN when read, retire may start immediately afterward. The aggregate borrow count is no proof that this caller owns a borrow. There is also an unreviewed table[-8] pointer precondition. Do not integrate this experiment into the production compiler or call it safe.

**Required correction:** implement `WithResolvedRef` that acquires and retains a borrow on behalf of the calling operation (or a proven nonforgeable internal lease), resolves and uses the pointer during that borrow's scope, and releases through one cleanup path. Retirement must block new borrows and wait until existing active borrows have exited; the read gate cannot be merely polled before returning a naked pointer. The actual ArenaEntry descriptor requires a reviewed layout and type checks. Test retirement interleavings with a pinned allocation and callback-scoped readers.

The previous 20/20 concurrent gate test remains evidence for gate transitions only, not memory lifetime. The present negative design experiment does not change X01 or D1–D8 status: OPEN.
