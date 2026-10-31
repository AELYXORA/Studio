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
4. **Calling convention:** Win64 RCX/RDX/R8/R9 and XMM argument classification, callee-saved GPR/XMM rules, shadow space and RSP alignment, target-specific aggregate/Result/owned buffer handoff, _verified_ `AuiCallFrameV1`/module header entrypoint layout. Public AELYXORA ABI bytes are owned by [D4 Win64 native ABI](d4-win64-native-component-abi.md) and [module/Outcome descriptors](d4-win64-module-and-result-descriptors.md).
5. **Frame and unwind:** stack slot allocation with bounded checked sizes/alignment, prolog/epilog and required `.pdata/.xdata` unwind descriptors on nonleaf functions, stack probing for large allocation, nonvolatile save/restore and no foreign exception escaping Assembly ABI. Native stack evidence must be compiled and inspected; text documentation is not such evidence.
6. **Constants/data:** encode immutable String/Bytes/finite-F64 payloads using approved D3 value codecs and D4 target representations. Input source strings do not become unbounded NUL-terminated native pointers. Constant payloads are in bounded read-only sections, mutable state in separately owned runtime regions, code in non-writable sections. Relocation kinds/visibility and safe static initialization remain explicit.
7. **Graph/command dispatch:** static visual components use typed D5 renderer descriptors. L1–L3 operations use a verified module operation table; every dispatched request binds exact OperationID, logical type/ABI result, domain/effect/target/capability and live runtime authorization. Never lower a declarative command into direct OS/hardware system calls solely because its text mentions an effect.
8. **L2/L3/L4 runtime lowering:** emit state-slot and derived/binding graph descriptors plus atomic commit procedures, task state-machine/terminal/cancel/unknown-result and cleanup transition functions, keyed dynamic View template factories and stable-key reconciliation descriptors. The ABI for all these services must be approved in D4/D5 **before** emitting a successful app.
9. **Object emission and inspection:** target-specific readable Assembly assembled into COFF, with symbol/section/import/export/relocation/unwind/debug records. An independent validator confirms names, lengths, ABI layout and imports match the verified build/Graph manifest. Linking uses a pinned runtime, explicitly declared OS libraries, deterministic flags and isolated output staging.
10. **Build + admission:** deterministic unsigned PE module/object evidence is separate from publisher signature, signed architecture approval and live OS capability. A successful object is neither a full running application nor authorization to load it. A linker failure or missing renderer adapter prevents release publication.

**Optimizer rule:** semantic correctness at O0 is the minimum. Each optional O1+ pass is independently enabled only after proving ownership/effect/dataflow-preserving transformations; no pass moves ordered UI event, volatile/IRQ/MMIO or task quiescence/cleanup effects. A failed optimization falls back only to a **verified semantics-equivalent** prior IR when the source/Graph/target trust remains valid; a failed trust gate is never repaired by optimizer fallback.

### User-enum and nested generic ABI admission — required before native full-compiler release

A public AUI enum becomes a native value **only after** verified TypeReference/variant definition, portable codec or explicit nonportable local use, target ABI and error/ownership service qualification. TargetMIR must receive `EnumLayout{exactPublicTypeRef,tagEncoding,orderedVariantToTagMap,payloadLayouts,overallSize,alignment,moveDropTraits,callingConvention}` (conceptual contract; exact descriptor struct bytes still D4 P0). Its verifier rejects missing/overlapping case tags, invalid padding/size, unaligned payload, uninitialized payload storage, impossible exhaustive switch, missing drop on unused case, wrong pass-by-register/indirect ABI and unverified native providers.

For `EnumMatch`, generate one scrutinee evaluation, one **exhaustive** branch per public variant (not a guessed default arm) and typed payload binder/cleanup edges. Preserve the original AUI source span and Graph/type provenance through each native basic block and unwind edge. A native tag number is never an authored source/API value or a public enum semantic digest input. A variant reorder changes the type identity and must invalidate ABI/type evidence even if physical layout happens to match.

A nested generic `List<Result<Measurement,SensorError>>` needs a **fully admitted template/argument layout and ownership/send/drop support inside-out**, and an authenticated operation/Graph source contract if it crosses module/provider boundaries. A structurally valid recursive TypeReference or D2 identity-only `@inst` ID is not proof of a binary layout. Unsupported generic ABI or transport => explicit target error; no opaque pointer shape fallback, erased generics guess or JSON interpreter substitution.

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


## Qualified physical machine opcode tag catalogue — design-only

The [one IR tag/payload contract](aui-compiler-ir-payload-contract.md) now enumerates **eight T5 LayoutIR** and **23 T6 TargetMIR** candidate tags with exact `Layout64`, `MachineInstruction64` and `MachineTerminator48` byte templates and typed `Ref64` descriptor targets. A `MachineCall` requires a qualified native import/layout proof and preserved effect token; matching byte fields do not validate Win64 register allocation, stack alignment, caller shadow space, relocations, unwind or runtime imports. The [candidate catalog](../../schemas/aui-compiler-ir-payload-layout-candidate.json) and [16 payload byte vectors](../../examples/aui-compiler-production/ir-payload-template-byte-vectors.json) require separate GAS/COFF native offset and object probes. All 77 tag review cases are NOT-RUN. Public D4 user component ABI and target runtime services remain independent and unqualified.

## TM0. Exact target-neutral-to-Win64 lowering verifier — production candidate

**Status: PROPOSED / NO NATIVE TARGET QUALIFIED / ALL TESTS NOT-RUN.** This section is the machine-code owner corresponding to the [single T0–T8 full compiler contract](aui-ir-layout.md) and the [OwnershipIR worklist proof](aui-ownership-ir.md). It never authorizes a direct source→Assembly shortcut. TargetMIR is a **verified target-specific internal machine program**, not public TypeReference/Graph identity, an LLVM IR replacement product or a JSON file consumed by the OS. The [review MIR shape](../../schemas/aui-compiler-targetmir-candidate.schema.json) is only a limited inspection example, not ABI bytes.

### TM1. Closed module/function/block/instruction records

- **Module:** exact `targetTriple,abiRevision,requiredIsaFeatures,codegenPolicy,verifiedGraphLinkIdentity,verifiedOwnershipIRIdentity,verifiedLayoutIdentity,qualifiedRuntimeTableIdentity`, ordered functions, data/constants, imports/exports and candidate relocs. The target triple `x86_64-pc-windows-msvc` is the first Win64 *candidate*, not a verified target. Unapproved variants reject.
- **Function:** one target-specific symbol identity, exact D4 calling convention and typed argument/result classification, frame policy, blocks, address-space/effect summary, unwind strategy, prologue/epilogue constraints, source/Graph origins. Duplicate mangled exports or hidden calling convention coercions reject.
- **Block:** unique compiler-local ID, explicit typed live-in block args/virtual-register values, zero-or-more checked machine instructions and **one** terminator. Every edge passes matching live-in definitions; no generic textual `phi` fallback.
- **Machine instruction:** closed target opcode or abstract preselection operation; exact typed operands/results, virtual/assigned register classes, memory address space, access width/alignment, source origin, effect token dependencies, optional relocation/import proof. Unknown opcode or unsupported target ISA **rejects**, it never emits a no-op.
- **Data layout:** immutable type graph/target layout revision + concrete `size,align,fields,variantTag,perVariantPayloadOffsets,copyMoveDrop` evidence. Physical layout is approved by **D4**, not reconstructed from a source pretty-type name or by omitting a `Result` error arm.

### TM2. Lowering order and machine verifier per pass

| Pass | Required checked inputs | Output + mandatory invariant |
| --- | --- | --- |
| M0 — gate and specialization | Verified T4 OwnershipProof, authenticated public type/Graph/source, qualified target/runtime/ABI | Closed monomorphized operation/value set; no untrusted codegen inputs |
| M1 — type layout | Exact D3 public type and D4 target ABI/classifier, target pointer/endian/ISA | `LayoutIR`: checked aggregate size/align/offsets, enum payload/tag, Result/TaskOutcome tag and cleanup; no overflow |
| M2 — machine CFG | Owned SSA/block-argument CFG and complete effect/cleanup edges | Target typed MIR with preserved branch/error/cancel/uncertain-result paths, no duplicate drop or forged provider terminal |
| M3 — instruction selection | Exact permitted target opcode/ISA features/address spaces | Full instruction selection, operand width/sign semantics, volatile/atomic/sync ordering and capability-call barriers |
| M4 — register and frame | Machine CFG liveness, Win64 ABI, target D4 call frames | Deterministic virtual-register allocation/spills, callee-saved preservation, 32-byte Win64 shadow space where applicable, 16-byte call-site stack alignment, bounds and stack probes |
| M5 — unwind/import/reloc | Pinned D4 native module/service table and toolchain | Exact `.pdata/.xdata` unwind entries for applicable nonleaf code, versioned import symbols, relocation/section constraints, no unwinding foreign exception into Assembly ABI |
| M6 — Assembly/COFF | Verified M5 MIR and fixed target assembler version/flags | Readable GAS/Clang-compatible Assembly and real COFF with independently checked symbols, sections, relocs, imports, unwind/debug and codegen/source maps |
| M7 — link and build | Exact runtime/OS import allowlist and D6 build closure | Real linked PE executable or module, reproducibility manifest, immutable staged output; no fake references or unsupported runtime |
| M8 — admitted runtime | Native binary qualification plus separately signed source/Graph/release policy | Real D5 L0–L4 UI/event/state/task/keyed scenario tests, live permission and secure teardown evidence; no automatic execution from `M7` success |

Every pass records input/output compiler-local artifact identity, contract revision, exact target/ABI/toolchain identity, effect ordering and drop equivalence, diagnostic origin and **verifier result**. A successful transformation is not proof until its verifier runs on that output. Optimization O1+ is permitted only after O0 semantic equivalence: it must not move provider dispatch, UI commit, volatile/MMIO/atomics, cancellation, quiescence or resource cleanup across observable boundaries.

### TM3. Win64 ABI conformance (first target candidate, no code)

The target classifier must separately handle integer/pointer and floating/vector arguments, by-value versus **indirect aggregate** passing, explicit `Result<T,E>` and enum tagged layout, return buffer ownership, caller shadow space, incoming `RSP` and callee-saved GPR/XMM state, stack probes/alignment, and frame pointer/unwind metadata according to the **qualified D4 revision**. The documented Windows ABI baseline is **not** an approved AELYXORA runtime descriptor. The first user-visible AUI app also needs the D5 native renderer, state/event/task/keyed services and accessibility/IME; a COFF file that links but cannot run these is not a completed compiler.

`AuiCallFrameV1` (if accepted), public module headers, operation descriptors and runtime symbol names come **only** from [D4 Win64 ABI](d4-win64-native-component-abi.md) and [module/result descriptors](d4-win64-module-and-result-descriptors.md); this section does not invent struct bytes. An unresolved descriptor or missing service entry prevents native emission. Address-space provenance is typed: ordinary process memory, renderer-owned buffers, OS handles, MMIO/DMA/IRQ resources are **not interchangeable** even when the machine pointer width is identical.

### TM4. Effect and ownership preservation proof

The backend must have an explicit cross-pass relation from each verified T4 owner/value/effect lane to one or more T6 machine values, memory locations or qualified runtime service obligations:

1. Each owned return/drop/move/retain path remains accounted for after register allocation, helper calls and error/unwind insertion. A spill is not an additional owner; a runtime retain/release is observable and must have exactly the D4-owned contract.
2. A provider-admitted request with indeterminate final state retains actual native resource owner/ticket until trusted quiescence; codegen cannot turn UI `ProviderUnavailable` into an immediate `free`. Cancellation/late completion/lifecycle remain generation-scoped.
3. L2 state commit and L4 keyed reconciliation publish only on the verified success branch and must roll back or leave the old UI state authoritative on failure. There is no physical partial-update fallback.
4. Enum `matchEnum` maps every authenticated logical variant to one target tag with complete tagged-value layout, exhaustive branches and correct payload drop/borrow. A target-chosen numeric tag can never be serialized as public enum identity.
5. The D2/D6 core/type/operation/Graph digests, source review and package lock are **inputs to trust**, not machine-code optimization constants that can be rewritten, stripped or implicitly inferred. No source-only `UNVERIFIED` context passes M0.

### TM5. Exact rejection and independent object evidence

| Rejection | Candidate class and required proof |
| --- | --- |
| Unsupported target/runtime/ABI/ISA import, unqualified D4 layout | `MIR_TARGET_UNSUPPORTED`, no object emitted |
| Missing/unsupported typed opcode, bad SSA/CFG mapping, illegal effect barrier elision | `MIR_INVALID_LOWERING` / `MIR_EFFECT_REORDER` |
| Stack/argument/result ABI, shadow space, alignment, stack probe or callee-save mismatch | `MIR_ABI_MISMATCH` |
| Unwind metadata/relocation/section/import mismatch | `MIR_OBJECT_INVALID` |
| Public variant tag/payload, ownership cleanup or cross-domain transfer incompatibility | `MIR_LAYOUT_INVALID` / `MIR_OWNER_LOST` |
| Unverified source/Graph/operation/core, fake signature or stale build input | `MIR_TRUST_UNRESOLVED`; cannot override upstream trust gate |
| Reproducibility mismatch of unsigned code/manifest across clean pinned builds | `BUILD_NOT_REPRODUCIBLE`; refuse release |
| Native test failure in L0–L4, source-map, ABI or runtime teardown | `NATIVE_CONFORMANCE_FAILED`; no shipping compiler claim |

The [target MIR inspection schema](../../schemas/aui-compiler-targetmir-candidate.schema.json) and [full IR negative/review cases](../../examples/aui-compiler-production/full-ir-pass-review-cases.json) are **NOT-RUN design cases**. None replaces independent COFF/PE inspection, a real assembler/linker invocation or a running UI/native module. The qualified target, actual D4/D5 service signatures/offsets, assembler directives and complete backend reference machine traces remain **P0**.
