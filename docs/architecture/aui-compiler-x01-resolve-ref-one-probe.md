# X01 Win64 ResolveRef single-entry probe — actual COFF cross-build

**2026-11-01 — source committed; local cross-assembly succeeded; Windows execution NOT-RUN; no full arena system.**

[Assembly source](../../tests/native/x01_resolve_ref_one.S) exports `x01_resolve_ref_one`, called with Windows x64 registers RCX=Ref64, RDX=trusted host-pinned ArenaEntry pointer, R8D=nonzero requested byte count, R9D=alignment (power-of-two <=4096). RAX is candidate pointer or zero. The 32-byte synthetic ArenaEntry contains index u16, generation u16, state u32 (1=sealed), committed u32, kind u32, base pointer u64, leaseCount u64.

Unlike the previous shape-only probe, it validates nonzero index/generation, equality with descriptor, sealed state, nonzero lease count, `offset <= committed`, `requestedBytes <= committed-offset` via subtraction, alignment of offset and base, nonzero base, and 64-bit pointer-addition carry. **No pointer is safe to dereference unless the caller independently proves descriptor pointer validity, active arena lifetime, stable allocation, protected concurrent access and expected descriptor type.** The `kind` field is reserved in this probe, not checked. This function assumes the host supplied a trusted pointer to a pinned entry; an attacker-controlled RDX would violate the precondition.

Actual local command:
```sh
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_resolve_ref_one.S -o x01_resolve_ref.obj
llvm-objdump -d x01_resolve_ref.obj
```

On the local Linux x86-64 toolchain, Clang 17 assembly succeeded, `file` identified x86-64 COFF, and `llvm-objdump` produced x86-64 disassembly including bounds and branch-on-carry checks. Local object SHA-256: `83d4adb1c6618647795d8097468fcd83bfc3bdba542e95ced05b9ec7d09b1d40`. Toolchain paths, host and binary were not published as independently authenticated artifacts; repeated builds, Windows execution, and dynamic edge-case harnesses remain **NOT-RUN**.

**Do not call this a complete `ResolveRef`**: still missing actual arena-index table lookup, pinned lifetime/concurrency protocol, descriptor-kind enforcement, u16 generation exhaustion, allocation/protection APIs, zero-length caller policy, and real negative runtime tests. X01 and all D1–D8 gates remain OPEN.
