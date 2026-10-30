# AUI Component Binary ABI

**Status: proposed; not implemented or verified.** Defines component metadata, memory ownership, call frames, asynchronous results, and cross-target compatibility.

The portable AUI contract is distinct from CPU calling conventions. Each module declares target triple, ABI revision, required capabilities, and its exported operations. Native pointers are never serialized in project files.

## Logical descriptors

These are semantic records, **not yet frozen byte layouts**:

- ModuleHeader: magic, ABI major/minor, declared byte size, required feature bits, target profile, exported contract hash.
- ComponentDescriptor: stable type ID, version, typed ports, capability set, operation table, lifetime policy.
- Span: address-space ID, opaque memory handle, offset, length, capacity, access mode, borrow generation.
- CallFrame: operation ID, caller domain, capability token, input/output spans, allocator token, diagnostics and revision.
- Result: stable status, committed output length, ownership transfer policy.
- TaskTicket: request ID, source node, instance generation, cancellation token, delivery channel.

Every descriptor has explicit bounds and version validation before dereference. Exported calls return a fixed status; outputs use caller-defined descriptors rather than unspecified struct-return conventions. The real register/stack ABI must be defined per target.

## Allocation and resource lifetime

Allocator capability supports allocate(size, alignment, region) and release(handle, generation); allocation failures return typed errors, never unwinding over Assembly boundaries. Borrowed input is valid only during the call unless a lease is explicitly negotiated. Owned-input transfer happens only upon accepted invocation. Owned outputs carry a matching allocator/release rule. Shared buffers need synchronization; DMA and MMIO are separate hardware capabilities, not ordinary byte spans. Invalid or stale generation handles fail without accessing resources.

## Concurrency / resource contract linkage

The logical [D2 Execution and Consistency](d2-execution-consistency.md) defines owner retention on rejected move, copy cleanup, generation checks, cancellation as request, and pinned graph snapshots. The native ABI must later prove exact descriptor offsets, atomic terminal publication, allocator compatibility, and no callback-after-release on every target. Do not infer that an architecture model commit can atomically commit network/device effects. The `cancelling` state in the sensor *workflow* is not automatically a new ABI TaskTicket terminal state.

## Async and cancellation

Task states are created, queued, running, completed, failed or cancelled. Cancellation-requested is a **flag**, not an automatic terminal state. Completion and cancellation race for one terminal outcome; publish at most once. Device work that cannot be physically stopped must retain ownership of its buffers until completion/cleanup. Completion for a former view/component generation must not mutate its replacement. Subscriptions require unsubscribe and drain semantics to prevent callback-after-destroy.

## Version compatibility

Reject unsupported major ABI, unknown required features, wrong target ISA/OS or mismatched contract identity. Minor revision negotiation may skip unknown optional fields only if descriptor sizes permit it. AUI source grammar, Project Graph schema and native ABI each have independent version lifecycles.

## Target verification matrix

- Linux x86-64 SysV: argument registers, 16-byte stack alignment, callee saves, ELF.
- Windows x86-64: Win64 shadow space, preserved registers, COFF and unwind.
- Linux AArch64: AAPCS64, stack alignment and ELF.
- macOS arm64: Apple ABI, Mach-O, unwind and runtime integration.
- Bare-metal: explicit board ABI, startup, memory map, linker script and privileges.

No target is yet verified for this ABI; no executable ABI probe is retained.

## Acceptance fixtures

1. Truncated, misaligned and wrong-version descriptors are rejected.
2. Insufficient output capacity does not publish a partial result.
3. Ownership transfer after success has a single matching release; failed acceptance leaves ownership with caller.
4. Terminal cancellation/completion races publish exactly one outcome.
5. Stale generation results never update successor instances.
6. Unsupported capabilities, execution domain and target ABI fail before native invocation.
7. Equivalent semantic results are tested on each supported target.
8. Compare dispatch latency, allocations and emitted machine code against direct native baseline.

**Open:** actual binary offsets, opaque handle representation, allocator ABI signatures, memory atomics, module linking/loading, hot reload, debugger/unwind details and privilege handshake. Freeze only after runnable tests.
