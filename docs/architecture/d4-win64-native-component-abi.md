# D4 — Win64 Native Assembly Component ABI, Exact First-Host Candidate

**Status: PRECISE DESIGN CANDIDATE, not architect-approved, compiled, linked, ABI-probed or released.** The Windows x64 system calling convention is documented by [Microsoft x64 calling convention](https://learn.microsoft.com/en-us/cpp/build/x64-calling-convention) and [Microsoft x64 exception handling](https://learn.microsoft.com/en-us/cpp/build/exception-handling-x64). The AUI descriptors below are **AELYXORA-owned proposals**, not Microsoft structs or an established Studio runtime. [D3 Core Registry](d3-core-registry-value-contract.md) owns logical semantics, [D2 Export Identity](d2-export-contract-identity.md) owns logical component contracts, [D4 ABI overview](d4-core-value-abi-contract.md) owns portable lowerings, [D5 Budget](d5-ui-resource-budget-and-publication.md) owns capacity and actual OS pressure.

## W1. First-host scope

Candidate target: **x86_64-pc-windows-msvc ABI**, Windows x64 user-mode, little-endian, 64-bit pointer/unsigned integer machine width, PE32+/COFF, 16-byte aligned stack call boundary, no red zone. Actual minimum Windows build, security policy, toolchain/assembler/unwind interoperability and NTFS durability qualification remain separate explicit P0 decisions.

The external entrypoint *conceptual C signature* is one pointer argument and a 32-bit status return:

    uint32_t AuiInvokeV1(const AuiCallFrameV1* frame);

A native Assembly implementation is free to use Assembly internals, but its exported function is invoked with the **Win64 x64 ABI**, not SysV, vectorcall or arbitrary inline register ABI. The host resolves a verified operation function pointer from a signed/approved module descriptor. A function pointer is never serialized as a Project Graph identity. Status returns in the low 32 bits of RAX (EAX); RCX carries one valid pointer to the caller-owned frame. Large values and Result/TaskOutcome payloads travel only in validated descriptor-owned spans, not by returning an arbitrary struct in registers.

At the call site the caller reserves at least **32 bytes of shadow/home space**, maintains 16-byte RSP alignment before CALL, and restores it on return (callee entry RSP modulo 16 equals 8 because of the return address). Nonvolatile GPRs include RBX, RBP, RSI, RDI, R12-R15 and RSP; nonvolatile XMM lower 128-bit registers are XMM6-XMM15. Caller-volatiles include RAX, RCX, RDX, R8-R11 and XMM0-XMM5. Clear direction flag. Code allocating stack/changing nonvolatiles/calling others needs correct unwind metadata and legal prolog/epilog; PE32+ .pdata/.xdata must describe nonleaf frames. Large-stack allocation needs target-correct probing; arbitrary private prolog/SEH assumptions are forbidden.

## W2. AELYXORA candidate native data layout policy

All three descriptors below are **exactly specified project candidates** for native Win64 **version 1**, little-endian, natural alignment 8 except explicit 32-bit fields. Each field is required. Reserved bits/fields must be zero; unknown required flags/unsupported major version reject before native dereference. Access uses explicit offset/width and checked unsigned arithmetic; never cast project JSON bytes to these descriptors.

**AuiCallFrameV1**, exactly **64 bytes**, alignment 8:

| Offset | Size | Field | Contract |
| --- | --- | --- | --- |
| 0 | 4 | magic | fixed 0x31495541 (LE bytes 41 55 49 31, ASCII AUI1) |
| 4 | 2 | abiMajor | 1 |
| 6 | 2 | abiMinor | 0 for candidate |
| 8 | 4 | frameSize | 64 |
| 12 | 4 | flags | required known feature bits; 0 first profile |
| 16 | 8 | moduleHandle | opaque verified generation-checked host module identity |
| 24 | 4 | operationIndex | index into **validated module** operation table, not Graph OperationID |
| 28 | 4 | callerDomain | host validated numeric domain registry, no guessed mapping |
| 32 | 8 | inputSpanPtr | in-process aligned address of read-only AuiSpanV1 array for this synchronous call; zero if count zero |
| 40 | 4 | inputCount | bounded count checked before array reads |
| 44 | 4 | outputCount | bounded count checked before array reads |
| 48 | 8 | outputSpanPtr | in-process aligned address of writable AuiSpanV1 array; zero if count zero |
| 56 | 8 | admissionContextPtr | in-process aligned address of AuiAdmissionContextV1 with validated lifetime |

**AuiSpanV1**, exactly **48 bytes**, alignment 8:

| Offset | Size | Field | Contract |
| --- | --- | --- | --- |
| 0 | 8 | ownerHandle | opaque allocation/arena/lease table handle, never raw physical device address |
| 8 | 8 | byteOffset | unsigned 64-bit checked against owner capacity |
| 16 | 8 | byteLength | committed readable/writable bytes, byteOffset + byteLength checked |
| 24 | 8 | byteCapacity | maximum accessible bytes **from byteOffset**, validate bounds and byteLength <= byteCapacity |
| 32 | 8 | ownerGeneration | ABA-safe generation of owner handle |
| 40 | 4 | accessFlags | exactly one of read=1 or write=2, or read-write=3 only if approved |
| 44 | 4 | reserved | must be zero |

**AuiAdmissionContextV1**, exactly **64 bytes**, alignment 8:

| Offset | Size | Field | Contract |
| --- | --- | --- | --- |
| 0 | 4 | contextSize | 64 |
| 4 | 4 | flags | zero in first profile |
| 8 | 8 | capabilityLeaseHandle | live scoped runtime authorization, never raw permission bytes in project |
| 16 | 8 | allocatorHandle | exact host allocator/retain/drop table identity |
| 24 | 8 | taskTicketHandle | zero for pure synchronous call; otherwise reserved admitted ticket |
| 32 | 8 | graphSnapshotHandle | pinned validated Project Graph/lock/source approval |
| 40 | 8 | callerGeneration | live component/UI owner generation |
| 48 | 8 | inputBudgetBytes | aggregate accepted input bytes, bounded |
| 56 | 8 | outputBudgetBytes | aggregate reserved maximum output capacity, bounded |

These structures are a **host-to-verified-native-component contract inside one trusted process**, not a stable cross-process wire format. Raw in-process addresses inputSpanPtr, outputSpanPtr and admissionContextPtr are only allowed after module and caller permission verification and remain valid for the bounded duration of the invocation. The native callee cannot retain those pointers for asynchronous work. Async work requires separately owned/generation-checked handles via a future explicitly specified ticket/lease API.

The frame's moduleHandle + operationIndex is checked against a previously verified **symbolic OperationID** and full exported type/contract digest; a 32-bit ordinal is *not* the Graph OperationID or a stable serialization ID. No pointer or token is persisted into D6 project JSON. Native ownerHandle is looked up in the allocation table with ownerGeneration; rejected or stale handles never dereference memory.

## W3. Validation, ownership and memory bounds

Before invoking the native entrypoint:

1. Pin approved source profile, exact core registry and public exportedContractDigest; check exact package/source bytes and qualified Win64 layout ID, signed/approved module and operation table. A user-supplied function pointer must never bypass the registry.
2. Verify frame and context bytes and alignment without dereferencing arrays beyond bounded lengths; validate exact magic, major/minor, size, flags and provenance of module/operation/domain/capability/graph/allocator handles.
3. Checked multiply inputCount * 48 and outputCount * 48 in a widened bounded unsigned integer; ensure allocated arrays lie in accessible caller-owned regions. Zero count implies null pointer; nonzero requires aligned, validated live pointer with sufficient extent. Overflows or unknown backing-memory extent reject.
4. For each span, check byteOffset <= owner size; byteCapacity <= owner size - byteOffset; byteLength <= byteCapacity. Validate permissions, ownerGeneration, in/out aliasing and one-writer/ownership constraints. Input/output byte budgets use overflow-checked sums.
5. Reserve all required output/result ownership and bounded completion queue capacity **before** transferring any input ownership or executing effectful work.
6. On admission rejection, preserve caller ownership and do not call provider; return a distinct admission error, never fabricated provider Result<T,E>. On accepted invoke, move ownership exactly once and retain callable generation snapshot. Call-scoped borrows cannot be stored, queued, awaited or DMA-mapped.
7. A valid native return status describes **transport/admission completion**; separate provider Result<T,E> is decoded only from checked output payload descriptors and a verified logical type/discriminant. A pending async ticket is not a successful business Result.
8. Cancellation is a request; a provider may still complete. D4 terminal publication requires one winner with acquire/release atomics and owner-safe cleanup; a stale view cannot inherit it. On exception/fault, isolate/terminate according to approved host policy, never assume arbitrary SEH/C++ exception may unwind across this Assembly ABI.

**No direct MMIO, DMA or IRQ spans.** Target/device memory is owned by independent capability-gated adapters. No covert automatic conversion of an opaque memoryHandle into a physical address.

## W4. ABI layout and platform compatibility matrix

[Machine-readable layout fixture](../../examples/abi/win64-native-layout-v1.json) gives exact integer field offsets/widths and positive/negative design cases. This is a **future ABI probe specification**, not a runnable COFF binary.

Required future native conformance:
- NASM (or approved assembler) emits PE/COFF exports, module descriptor, legal call frames and valid Windows unwind metadata;
- host and caller independently check sizeof/alignof/offsetof for 64/48/64 structures, both debug/release and every targeted instruction-feature profile;
- Win64 callee correctly preserves nonvolatiles, shadow space, stack alignment, ABI status register, no exception propagation and structured error/Result separation;
- descriptor and token failures rejected before reading untrusted owner pointers, including count overflow, zero-count pointer mismatch, stale generations and wrong-ABI version;
- allocation/move/borrow/retain/release and terminal cancellation/result race checked with sanitization/fault injection;
- native Windows window/input/render integration and qualified target OS/NTFS durability verified **separately** from ABI.

The Linux x86-64 SysV example uses different register/stack/ELF assumptions. It cannot be reused as Win64 ABI evidence just because both targets use x86-64 instructions.

## W5. P0 not closed by exact proposed offsets

Host/compiler runtime implementation; verified operation-table and module signing/admission; true native layout IDs and registry binding; 32-bit handle-index mapping/versioning; allocator and buffer memory ownership proof; callbacks/unwind/SEH/fault isolation; Windows OS versions/CPU features/COFF toolchain/reproducibility; actual tests and architect acceptance. **This proposal does not create a product ABI implementation or establish Windows compatibility.**

## W6. Proposed module header, operation table and tagged result descriptors

[D4 Win64 Module and Result Descriptors](d4-win64-module-and-result-descriptors.md) extends the above 64/48/64-byte call/span/admission records with a candidate 80-byte AuiModuleHeaderV1, 80-byte AuiOperationEntryV1, 64-byte AuiValueRefV1 and 80-byte AuiTaggedOutcomeV1. [Supplemental layout fixture](../../examples/abi/win64-module-and-outcome-v1.json) records exact offsets and 16 rejection scenarios. The module's native operation ordinal is not the persistent Graph OperationID. A provider Result<T,E> is a two-way typed envelope; UI TaskOutcome<T,E> has five distinct cases, including admission failures before a provider ticket exists. The design is NOT a COFF implementation: module contract-set digest normalization, signature/trust, native generic payload layout, Win64 unwind tests and owner lifetime proof remain P0.
