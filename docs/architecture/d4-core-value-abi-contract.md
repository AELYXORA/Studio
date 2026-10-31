# D4 — Core Value ABI Lowering, Ownership and Target Profiles

**Status: PROPOSED design, NOT approved, implemented or tested.** [D3 Core Value Registry](d3-core-registry-value-contract.md) defines *logical types and portable values*. This document is the D4 contract for lowering those types to machine-specific Assembly components and for proving ownership. [Component Binary ABI](aui-component-binary-abi.md) owns the eventual versioned module header and operation table; [ABI and Async](aui-abi-and-async.md) owns calls; [OwnershipIR](aui-ownership-ir.md) owns borrow validation. No data layout below is a released binary ABI.

## A0. Independent versions and artifacts

An executable binding requires ALL: approved source profile, exact logical TypeID/contract digest, resolved package implementation content digest, verified target triple + OS + CPU features, approved native ABI major/minor, exact compiler/assembler/target adapter artifact digests, and tested layout/frame conformance. A source-only link-map, a 64-character hash string, or a planned target never proves a callable operation.

First-host **candidate**: Windows x86-64 with Win64 ABI and qualified local NTFS; Linux x86-64 SysV remains an independent verification/bootstrap profile. Linux reference Assembly source files **do not** establish Windows COFF/linkage or Win64 calling convention compatibility. AArch64 and hardware targets remain separately unverified. Host choice needs architect acceptance, not silent inference.

## A1. Two explicitly separate representations

1. **Portable logical value framing**, used by source hashing/diagnostics and specified data interchange, is exact and endianness-independent. The D3 StableKey frame (tag + length + UTF-8 or tag + big-endian U64) is one example. It is NOT a native in-memory union and MUST NOT be cast to a machine pointer/struct.
2. **Native value representation**, used inside a verified target ABI, is explicitly described by machine layout descriptors: field offset/width/alignment, register/stack location, ownership/allocator, native endian, valid discriminants, and safe destruction. Compiler and component MUST use the same verified layout ID. No scalar/native Rust/C/Qt/Delphi layout can be inferred from source spelling.

A target layout ID is domain-separated from logical export identity and must include target/ABI revision, exact compiler layout algorithm revision, resolved generic args and relevant record/variant details. Equal exported logical types on two targets may have distinct layouts. Changing only native implementation source bytes may preserve logical identity but MUST invalidate the ABI/build evidence.

## A2. Candidate logical-to-native representation table

| D3 logical value | Required D4 proof; NOT a fixed byte layout |
| --- | --- |
| Unit | No payload; explicit status/result discriminant, never a null pointer alias |
| Bool | Native size, register extension and canonical true/false bit patterns |
| U32 / U64 | Width, endian, register class, stack alignment, no precision loss |
| String | Opaque owned descriptor (owner token + pointer/region + byte length + generation), strict UTF-8 validation and release rule; not NUL-terminated |
| List<T> | Opaque immutable owner plus count and checked element layout/stride; retain/drop/copy policies; no raw pointer across async |
| StableKey | Native discriminant + selected payload, proven against portable tagged equality; not assumed to equal canonical wire bytes |
| Result<T,E> | Exact two-case variant discriminant, aligned payload and destructor; never a C exception |
| TaskOutcome<T,E> | Exact five-case discriminant; matching payload alignment/offset, ownership/cleanup; no fabricated provider terminal for AdmissionRejected |
| StateRevision | Exact monotonic counter + owner/generation and compare-and-swap ordering; no wrap/reuse |
| TaskSlot / TaskTicket | Opaque generation-checked handle with strict owner, lifetime, capacity and cancellation status; not user-serializable |

No physical offsets, bit patterns or pointer width are *chosen* in this draft; pretending a table above supplies exact structs would be incorrect. A release-grade ABI requires mechanically verifiable layout vectors per target and ABI revision.

## A3. Safe cross-module call/admission protocol

Before invoking an Assembly provider:
1. Check verified ModuleHeader, target ISA/OS/feature flags, full logical export and native layout identities, operation ID, declared effects/domain/capability, allocator and exact function frame signature.
2. Validate every length/offset/stride and arithmetic using overflow-safe widened integers; reject bad alignment and out-of-range handles **before dereference**.
3. Reserve task/ticket, outcome delivery capacity and all owned allocations in a bounded accounting system **before** transferring owned arguments or starting an external operation.
4. A rejected admission retains original sender ownership; no provider function called. On accepted admission, transfer exactly once with explicit owner/generation. A call-scoped borrow cannot cross await, worker queue, result caching or device DMA.
5. Provider returns a checked status/typed Result through the target-specific calling convention; D4 must not unwind C++/OS exceptions across Assembly ABI boundaries. Out params remain undefined on failure unless declared otherwise.
6. Accepted async task publishes one terminal result via generation-checked native atomic protocol. A cancel request is nonterminal, and freed UI subscriptions do not imply released provider resources.
7. Every owned payload is released once by the specified owner on successful completion, rejection or quiescence. An invalid/stale generation fails without dereference or resurrecting old UI state.

## A4. ABA, teardown and visibility requirements

A ViewIdentity/TaskTicket must combine a nonreused incarnation generation with a scope/owner handle. A stale handle cannot become valid through allocator reuse; wrap/epoch exhaustion must fail closed. Source template IDs never substitute for the per-row live keyed path. A successful CAS publication uses explicit acquire/release ordering between producer and UI consumer, but **exact atomics, tables and memory ordering are still P0**, not proven by saying CAS.

Unsubscribe requires a handshake separating: close future admission, mark generation stale, drain or safely quarantine in-flight callbacks, release UI-owned resources, and later release provider-owned hardware buffers only on provider completion/confirmed quiescence. A double close must not double free. A GPU fence and native OS callback may outlive visible UI state; they must retain bounded true owners, not dangling View pointers.

## A5. Future target qualification gates — all NOT-RUN

| Gate | Windows x64 first-host candidate | Linux x86-64 reference |
| --- | --- | --- |
| Module format and toolchain | PE/COFF, Win64 register/stack/unwind verified | ELF, SysV register/stack/unwind verified |
| Scalar/string/List layout goldens | NOT-RUN | NOT-RUN |
| Result/TaskOutcome tagged payload roundtrip | NOT-RUN | NOT-RUN |
| U64 StableKey boundary values and UTF-8 | NOT-RUN | NOT-RUN |
| Owned transfer/rejected admission/cleanup | NOT-RUN | NOT-RUN |
| Callback-after-unmount and generation ABA | NOT-RUN | NOT-RUN |
| Cancellation/success terminal race | NOT-RUN | NOT-RUN |
| Cross-domain Send/borrow lifetime proof | NOT-RUN | NOT-RUN |
| Renderer/focus/resource shutdown | NOT-RUN | NOT-RUN |

The existing Linux fixture source bytes are reference inputs, **not** verified D4 module exports or a passed SysV test.

## A6. Blocking design decisions

Native struct offsets, discriminant values, allocator ABI, error payload descriptors, symbolic mangling/cross-module calling conventions, signed/untrusted module admission, per-target security checks, compiled generic layout policy, atomic teardown protocol, ABI feature negotiation, and independently observed native conformance fixtures. D4 and D5 stay **Proposed/Open**.
