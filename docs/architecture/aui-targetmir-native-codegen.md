# AUI TargetMIR and Native Code Generation

**Status: proposed specification, not implemented.** TargetMIR consumes verified [OwnershipIR](aui-ownership-ir.md) and typed layout information from [IR and Layout](aui-ir-layout.md). It emits target-specific Assembly or LLVM-compatible backend input. No target is verified.

## First native emitter selection — explicitly gated proposal

The first intended native target for AUI codegen is Windows x64 user-mode, `x86_64-pc-windows-msvc`, COFF/PE32+, with **readable target-specific Assembly output** and the permitted Clang/LLVM assembler/linker toolchain. This is a *candidate backend*, not a working module or approved ABI. The upstream [first compiler contract](aui-compiler-first-implementation-contract.md) initially emits only a source-only L0/L1 TypedHIR/static plan. Its current [review catalogue](../../examples/aui-compiler-first-slice/review-type-catalog.json) is UNVERIFIED and can never authorize TargetMIR/native artifacts.

A later native L0 emission must bind exact static view descriptor/value ownership to an **approved D4 Win64 module ABI and D5 renderer service contract**; use no invented permanent exported symbols or direct Windows controls as an accidental substitute for the Studio runtime. L1 command emission is a typed provider request with independently verified graph export/signature, not a raw OS or hardware function call. Until the renderer descriptor, event attachment ABI, signed graph/source approval, ABI layout and runtime admission are approved, native codegen is blocked at P08.

LLVM IR remains an optional later internal experiment, not a second required backend or a host-portable Assembly language. For a future non-Win64 target, qualify an independent backend/ABI before claiming support.

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


## Production native compiler closure — mandatory beyond a source-only plan

The [complete AUI compiler](aui-compiler.md) cannot be called a production compiler until this backend emits **actual verified target machine objects and linked modules** for the approved shipping AUI profiles. L0/L1 source-only P00–P06 is an implementation milestone only. The frontend/backend separation is **TypedHIR → GraphLinkedIR → OwnershipIR → target-qualified LayoutIR → TargetMIR → target assembly/object → linker → verifiable native image → independent signed admission**.

### Win64 native backend contract candidate (first qualified target)

1. **Target normalization:** only a reviewed exact target triple, ABI revision, ISA feature set and runtime service set may enter TargetMIR. All output functions record call conventions and verified public type contract/layout identity, not platform-neutral names masquerading as native offsets.
2. **Linkage environment:** build input closure includes approved compiler/toolchain binary SHA, exact Unicode/core registry, package lock, immutable source/Graph/review snapshot, target/D4 ABI/renderer and OS adapter identities. The command line and environment whitelist are part of the D6 build identity. A target whose module/renderer imports are missing is **unsupported**, not a linker prompt or dynamic search for nearby DLLs.
3. **Instruction selection:** map each verified SSA/block-argument instruction to target-register virtual ops with typed sizes, signedness, explicit address spaces, MMIO/volatile ordering, atomic acquire/release constraints, bounds and error paths. Reject unsupported operation/ISA instead of silently miscompiling.
4. **Calling convention:** Win64 RCX/RDX/R8/R9 and XMM argument classification, callee-saved GPR/XMM rules, shadow space and RSP alignment, target-specific aggregate/Result/owned buffer handoff, _verified_ \`AuiCallFrameV1\`/module header entrypoint layout. Public AELYXORA ABI bytes are owned by [D4 Win64 native ABI](d4-win64-native-component-abi.md) and [module/Outcome descriptors](d4-win64-module-and-result-descriptors.md).
5. **Frame and unwind:** stack slot allocation with bounded checked sizes/alignment, prolog/epilog and required \`.pdata/.xdata\` unwind descriptors on nonleaf functions, stack probing for large allocation, nonvolatile save/restore and no foreign exception escaping Assembly ABI. Native stack evidence must be compiled and inspected; text documentation is not such evidence.
6. **Constants/data:** encode immutable String/Bytes/finite-F64 payloads using approved D3 value codecs and D4 target representations. Input source strings do not become unbounded NUL-terminated native pointers. Constant payloads are in bounded read-only sections, mutable state in separately owned runtime regions, code in non-writable sections. Relocation kinds/visibility and safe static initialization remain explicit.
7. **Graph/command dispatch:** static visual components use typed D5 renderer descriptors. L1–L3 operations use a verified module operation table; every dispatched request binds exact OperationID, logical type/ABI result, domain/effect/target/capability and live runtime authorization. Never lower a declarative command into direct OS/hardware system calls solely because its text mentions an effect.
8. **L2/L3/L4 runtime lowering:** emit state-slot and derived/binding graph descriptors plus atomic commit procedures, task state-machine/terminal/cancel/unknown-result and cleanup transition functions, keyed dynamic View template factories and stable-key reconciliation descriptors. The ABI for all these services must be approved in D4/D5 **before** emitting a successful app.
9. **Object emission and inspection:** target-specific readable Assembly assembled into COFF, with symbol/section/import/export/relocation/unwind/debug records. An independent validator confirms names, lengths, ABI layout and imports match the verified build/Graph manifest. Linking uses a pinned runtime, explicitly declared OS libraries, deterministic flags and isolated output staging.
10. **Build + admission:** deterministic unsigned PE module/object evidence is separate from publisher signature, signed architecture approval and live OS capability. A successful object is neither a full running application nor authorization to load it. A linker failure or missing renderer adapter prevents release publication.

**Optimizer rule:** semantic correctness at O0 is the minimum. Each optional O1+ pass is independently enabled only after proving ownership/effect/dataflow-preserving transformations; no pass moves ordered UI event, volatile/IRQ/MMIO or task quiescence/cleanup effects. A failed optimization falls back only to a **verified semantics-equivalent** prior IR when the source/Graph/target trust remains valid; a failed trust gate is never repaired by optimizer fallback.

### Required actual native conformance matrix (NOT-RUN)

| Case | Evidence before claiming the target supported |
| --- | --- |
| Pure L0 UI | Real COFF/PE object + link, runtime creation/ownership of three Views, text rendering, accessibility labels |
| L1 event/command | Actual Button activation and bounded event queue, verified provider admission, exact ABI output/error |
| L2 state/bind | Native state slot init, derived DAG, atomic commit and renderer invalidation, no partial state on failure |
| L3 async | TaskSlot single-active, Result/TaskOutcome 5 branches, stale-generation cleanup, cancellation and unknown post-dispatch effect |
| L4 keyed rows | Nested List<T>/StableKey, reorder vs delete/reinsert lifecycle, owner/keyed generation, bounded memory |
| Machine ABI | Win64 stack/unwind and callee-save under instrumentation, relocation/import verification, module descriptor and CFG checks |
| Security | No unapproved OS/hardware import, no unverified binary executing; missing/corrupt signing/build identity rejects |
| Determinism | Independently pinned identical unsigned binary from two clean builds, toolchain/SDK hashes and exact manifest |

**Still OPEN:** exact D4/D5 renderer/state/event/task/reconciliation ABI function signatures, compiler assembler syntax and toolchain versions, native module export/symbol mangling, allocator/drop paths, reloc/unwind/debug fixture bytes, full target import capability mapping, native codegen positive/negative evidence and architecture sign-off. Win64 is a **candidate**, not an observed working backend.
