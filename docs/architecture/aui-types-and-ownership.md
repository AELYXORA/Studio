# AUI Types, Memory and Ownership

**Status: proposed normative contract, not implemented.** This document owns language-level type and lifetime semantics. [Component ABI](component-contract.md) owns physical calling conventions, and [Runtime](aui-runtime.md) owns scheduling.

## Type universe

- **Value types:** Bool, I8/I16/I32/I64, U8/U16/U32/U64, F32/F64, Unit, Enum, Record, fixed-size Array<T,N>, Optional<T>, Result<T,E>. Arithmetic has explicit overflow policy; signedness and integer width are never implicitly changed.
- **Dynamically sized types:** String (valid UTF-8, byte length distinct from scalar count), Bytes, Vector<T>, Map<K,V>. Their representation is deliberately not tied to any platform ABI.
- **Opaque resource types:** Handle<Resource,Capability>, Task<T>, Channel<T>, DeviceRegion, Buffer<T>. Native pointers are not interchangeable with resource handles.
- **Borrowed views:** Slice<T>, StringView and Borrow<T> exist only within an explicitly proven lifetime and address-space domain.
- **Unit-bearing values:** Duration, Frequency, Voltage, BytesCount and addresses with separate address-space types. Conversion across units is explicit.

## Effect model

Pure expressions cannot mutate state, perform I/O, block, access hardware, allocate unbounded memory, or dispatch commands. Effectful declarations must advertise capabilities from: state-write, allocation, filesystem, network, process, blocking, device-read, device-write, privileged, realtime and asynchronous. A capability is necessary but never sufficient for OS/hardware authorization.

## Ownership rules

1. Each allocated resource has exactly one owning handle or a documented shared-ownership mechanism; destroying the owner invalidates borrows.
2. Passing an owned value across a command/worker boundary moves ownership. Reuse after move is a compile-time error when proven statically; otherwise the runtime contract requires a checked handle.
3. Borrowed references cannot outlive the owner; cannot escape into stored state or asynchronous tasks without an explicit lifetime guarantee.
4. Immutable, self-contained values may be copied or transferred. Shared mutable values require an explicit synchronization/atomic policy.
5. Device mappings, DMA buffers and MMIO regions carry address space, alignment, cache coherency and privilege capabilities; UI components never receive raw physical pointers.
6. State slots are keyed by stable graph/component identity, declaration and view generation. A replacement generation invalidates old completion targets.
7. Memory allocation failure is an ordinary typed error, not an exception unwinding across Assembly ABIs.

## Concurrency classifications (draft)

Types declare `Send` (safe to transfer to another execution domain) and `Share` (safe to share across domains). Neither property is inferred solely from pointer shape. A raw device region is not automatically Send or Share. `Task<T>` requires an explicitly declared cancellation and destruction policy. UI-owned state is confined to its scheduler unless a typed message transfers an immutable value.

## Low-level ABI separation

AUI type identity is canonical and platform-neutral. ABI lowering maps values to target-specific registers, stack slots, padding and calling conventions. A type that is logically `String` is **not** assumed to be the same structure as a C++ string or system string. Public ABI surface uses fixed-width integers and opaque handles wherever practical.

## Required negative fixtures

Borrow-after-owner-free; use-after-move; mismatched address spaces; forbidden implicit narrowing; worker transfer of non-Send device handle; UI-thread blocking device call; unbounded allocation inside IRQ handler; stale view generation completion. Each fixture requires an unambiguous diagnostic class.

## Open decisions

Precise generics, escaping rules, compile-time borrow analysis strength, shared ownership policy, allocator API, pinning and async frame layout. No ownership checker or Assembly runtime is implemented or verified.


[OwnershipIR and Compile-Time Safety](aui-ownership-ir.md) specifies CFG-based moves, borrows, async boundaries, cleanup and rejection fixtures. Proposed; not implemented.

## First-slice D3 clarification

The [D3 Type and Binding Profile](d3-type-and-binding-profile.md) restricts L0/L1 to Unit/Bool/U32/String, Event<T>, Result<T,E>, and imported verified nominal record values; generic user value construction, mutating state, bind and async lifetime syntax remain D3+ proposals. L0/L1 does not permit hidden text conversions or accessing device handles. Core registry and ABI layouts are unapproved. This avoids treating broad aspirational type tables as already supported implementation.
