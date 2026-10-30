# AUI TargetMIR and Native Code Generation

**Status: proposed specification, not implemented.** TargetMIR consumes verified [OwnershipIR](aui-ownership-ir.md) and typed layout information from [IR and Layout](aui-ir-layout.md). It emits target-specific Assembly or LLVM-compatible backend input. No target is verified.

## Invariants

- Source-language/component identity is target neutral; binary artifacts are target-specific.
- Every function has an explicit target triple, calling convention, feature set, stack policy, effects and ownership summary.
- No optimization may move MMIO/volatile operations, atomics, I/O or synchronization past required barriers.
- No implicit heap allocation, reflection or dynamic dispatch on a statically resolved pure component path.
- Generated code has source/graph origin mapping and predictable failure behavior.

## TargetMIR module

```text
Module(target, abiRevision, features, functions, constants, imports, exports)
Function(id, signature, callConvention, blocks, frameRequirements, effects)
Block(id, parameters, instructions, terminator)
Value(type, virtualRegister, liveness, ownership)
Instruction(opcode, operands, result, memoryEffects, sourceOrigin)
```

Core logical operations: constant, arithmetic, compare, branch, phi/block arguments, load/store(address-space, alignment), call, return, stack-slot, move, atomic, barrier, trap and explicit error branch. Hardware accesses require capability-checked adapters, not arbitrary numeric addresses.

## Lowering phases

1. Validate OwnershipIR invariants; select target and runtime features.
2. Monomorphize only justified static generics; lower aggregates and tagged results using target layout rules.
3. Lower calls with ABI classification, including argument/return locations and ownership handoff.
4. Build machine CFG; preserve exception-free cleanup and cancellation/error edges.
5. Instruction selection for target ISA and supported extensions.
6. Liveness and register allocation (spills into explicitly aligned stack slots).
7. Insert prologue/epilogue, stack alignment, saved registers, relocation references and unwind/debug information as required.
8. Emit target-specific Assembly/object; link via Clang/LLVM and declared platform adapters.
9. Produce build manifest with toolchain, ISA/ABI, source graph revision, generated hashes and test status.

## Target contracts

| Target | Specific obligations |
| --- | --- |
| Linux x86-64 SysV | integer/SIMD argument classification, caller/callee-saved registers, 16-byte call-stack alignment, PIC/ELF and unwind |
| Windows x64 | Win64 register convention, home/shadow space, stack probes where required, SEH unwind and COFF |
| Linux AArch64 | AAPCS64 register conventions, stack alignment, branch relocations and ELF |
| Apple arm64 | Apple-specific ABI and Mach-O constraints, platform linker/code signing rules |
| Bare-metal | board-specific calling ABI, linker script, startup, memory map and privilege model |

These rows are **requirements**, not claims of working support.

## Optimization boundaries

Allow constant folding, dead pure computations, static component specialization, inlining and register coalescing only when semantics are preserved. Zero-cost is evaluated per case: generated machine code, allocations, code size and latency against equivalent hand-authored Assembly. Debug builds may deliberately retain metadata and checks; performance policy must be explicit.

## Verification obligations

- ABI call fixtures: argument and result placement, preserved registers, stack alignment, recursion and mixed aggregate types.
- Memory fixtures: correct offsets, alignment, endian and address-space restrictions.
- Error path fixtures: exactly-once release on all exits; no use-after-move after lowering.
- Async fixtures: suspension state preserved correctly and cancellation race emits one terminal result.
- Effects: barriers prevent illegal MMIO/atomic reordering; device I/O never inferred from UI binding.
- Link fixtures: unresolved symbol, wrong target/ABI or unsupported feature fails before execution.
- Compare debug/source mapping and equivalent results on each validated target.

## Open design questions

Precise machine opcode set, register allocator algorithm, LLVM IR versus handwritten Assembly emission strategy, ABI classifier implementation, atomics/memory model, debug format and object-level integration. Decide via focused target-specific experiments before design freeze. No CI before release preparation.
