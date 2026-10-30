# AUI IR and Layout

Status: proposed. TypedHIR -> OwnershipIR -> TargetMIR. Target-dependent data layout and ABI lowering require explicit tests.

## Representation contract

AUI types are target-neutral identities. TypedHIR records resolved types, effects, source spans and project graph IDs. OwnershipIR records moves, borrows, lifetimes and cleanup paths. TargetMIR lowers to concrete registers, stack slots, native data layout, calling convention and target ISA. Internal IR structs are not binary-compatible APIs.

Represent primitives as fixed-width Bool/integers/floats and aggregate Record/Array/Optional/Result; resource types have Owned, Borrow and capability-bearing Handle forms. String is UTF-8 with explicit byte length, never an assumed C++ or OS object layout. Device address spaces are separate from normal pointers.

## Data layout algorithm

The target profile supplies primitive size/alignment, pointer model, endianness and ABI rules. For record fields in order: offset = alignUp(current end, field alignment). Final size = alignUp(last field end, aggregate alignment). Array stride = alignUp(element size, alignment); multiplication overflow must fail compilation. Internal optional/result niche optimizations need proof; exported representations require explicit tags or ABI-defined layout. Padding is not initialized data.

Example with U32 alignment 4 and U64 alignment 8: record {count:U32, timestamp:U64} has offsets 0,8; size 16 and alignment 8.

## Ownership verifier

Values are uninitialized, available, moved or maybe-invalid. All control-flow predecessors must prove available before use. Move invalidates source; mutable borrow is exclusive; shared borrow excludes mutation. Dropping an owner with live borrows, retaining a borrow past its region or using an invalid generation is rejected. An async suspension cannot preserve a borrow without an explicitly proven stable lifetime. Non-Send resources cannot cross scheduler domains. Unsafe FFI and MMIO are explicit effect/capability boundaries, not implicit pointer casts.

## Target lowering evidence

Each exported component emits an ABI report with parameter classification, register/stack placement, alignment, ownership/allocator rules, error status, supported execution domains and ISA requirements. x86-64 and AArch64 need separate reports and conformance fixtures; target acceptance is never inferred solely from successful assembly.

## Rejection fixtures

Use-after-move, overlapping exclusive borrow, use after owner drop, borrow escaping into an unbounded Task, uninitialized merge path, array-size overflow, invalid address-space cast, non-Send transfer, incompatible public layout and wrong ISA must produce stable diagnostic categories.

Open: allocator ABI, full region inference, public descriptor representation, pinning, atomic memory model and exact foreign calling conventions.
