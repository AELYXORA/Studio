# AUI Backend and Component Execution

**Status: proposed, unimplemented.** Covers graph-based linking, native call dispatch, data-flow specialization, and runtime boundaries. Project Graph is the source of truth; generated code never silently changes the architecture.

## Build pipeline

1. Snapshot canonical graph revision, contracts, target triple and required capabilities.
2. Resolve component versions and build dependencies; distinguish build cycles from legitimate runtime invocation cycles.
3. Type/effect/ownership validation -> TypedHIR -> OwnershipIR -> TargetMIR.
4. Specialize static bindings and calls only when semantics and code size permit.
5. Emit target-specific Assembly and object modules with source-to-graph diagnostic mappings.
6. Link OS/device adapters and only required runtime capabilities.
7. Publish artifact manifest with graph revision, target, features, compiler, hashes, ownership and observed verification status.

Builds must be reproducible without AI connectivity. Generated source ownership and graph approval are separate contracts.

## Component call strategies

**Static:** direct native call or safe inlining when type, target and effects are known. Avoid mandatory registry lookup/heap allocation for such calls.

**Dynamic:** typed function-table lookup with module/contract version and capability verification. Indirection cost is explicit.

**Cross-domain:** a scheduler/channel boundary, not an implicit call. Explicit ownership transfer, cancellation, queue capacity and completion behavior. UI thread cannot block on device I/O; IRQ handlers cannot run rendering or unbounded allocation.

Public symbol identity conceptually includes module, component, operation and ABI revision. Exact mangling/linker contract is open.

## Data flow optimization

Binding edges define typed endpoints, units, ownership, update policy, execution domain and failure semantics. Validate missing ports, illegal writes, incompatible types, duplicate writers and undeclared feedback loops. Pure DAG segments can be ordered, fused or specialized, but never reorder across volatile/MMIO, synchronization, transaction commits, device effects or ordered events. A failed update must not partially publish state.

## Runtime contract

Event/device completion -> typed command -> validated candidate revision -> computed/binding evaluation -> committed state -> render invalidation and effect dispatch. A task publishes exactly one terminal result. Cancellation cannot silently free buffers owned by an ongoing device operation. Results carry instance generation to reject stale updates.

Feature-selected runtime services: state store, typed dispatcher, task scheduler, bounded channels, layout/render and platform adapters. No mandatory heavyweight runtime for a pure component.

## Target evidence

Each platform needs layout, calling convention, linker, target capability and semantic conformance checks. Kernel, firmware and user-mode are separate targets. No action on physical devices without explicit user authorization.

## Negative and performance fixtures

- Wrong module ABI version -> reject before native dispatch.
- MMIO side effect -> no illegal optimizer reordering.
- Two binding writers -> compile diagnostic with graph edge IDs.
- UI-to-worker message -> bounded transfer with ownership.
- Late task completion -> no mutation of new view generation.
- Static pipeline -> compare direct Assembly baseline, allocations, latency and emitted code.
- Cross-target build -> ABI-aware x86-64 and ARM64 output with separately observed test evidence.

**Open:** symbol mangling, module dynamic loading, exact MIR operations, scheduler OS adapters, cache invalidation and benchmark harness. This document does not assert working compiler or runtime.
