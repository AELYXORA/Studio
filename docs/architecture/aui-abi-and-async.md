# AUI Component ABI and Async Commands

**Status: proposed contract; no stable binary ABI released.** No component ABI implementation or released binary contract exists.

## Design goals

Target-neutral source contracts, target-specific layouts/calling conventions, bounded resource use, explicit ownership, deterministic failure codes and no implicit exceptions. ABI semantic version and machine representation version must be separate.

## Boundary categories

- **Synchronous pure call:** fixed-width values, immutable borrowed buffers with call-scoped lifetime, typed result.
- **Effectful call:** explicit capability handle and caller execution domain.
- **Async command:** request identity, owned or safely copied input, target affinity, cancellation handle and eventual single terminal outcome.
- **Event subscription:** explicit registration, generation token, queue capacity and unsubscribe guarantee.
- **Device operation:** address space/privilege/capability contract and target-specific adapter only.

## Illustrative conceptual ABI (not finalized structs)

```text
ComponentCall {
  ABI version; component/operation ID; target profile;
  caller domain; capability handle;
  input descriptor + byte length; output descriptor + capacity;
  allocator handle; error/diagnostic sink
}
AsyncTicket {
  request ID; source graph node ID; instance generation;
  task domain; cancellation token; lifecycle state
}
```

Do not publish this as a C layout yet: alignment, pointer width, descriptor packing, endianness and lifetime policy require explicit target ABI lowering.

## Error semantics

Outcomes: `ok`, `invalid-argument`, `invalid-state`, `unsupported-target`, `permission-denied`, `out-of-memory`, `resource-busy`, `deadline-exceeded`, `cancelled`, `device-failure`, `internal-error`. Semantic error identifiers are stable; platform error integers are supplementary evidence.

## Async state machine

```text
created -> queued -> running -> completed | failed | cancelled
               \-> cancelled
```

A request reaches **exactly one terminal state**; cancellation is a request, not proof of physical operation termination. A completed result may arrive after cancellation was requested, but delivery policy must be specified and only one terminal outcome published. Deadline expiry is distinct from guaranteed device abort. Task disposal must not free buffers still owned by drivers or DMA.

## Ordering, reentrancy and isolation

FIFO delivery is guaranteed within one declared channel, not across unrelated channels. Synchronous handlers may not recurse into unbounded nested event delivery; follow-up events are queued. UI thread cannot block on device I/O. IRQ context may not invoke UI or unbounded allocator operations. Safe publication of results uses instance generation checks and typed messages.

## Target contracts

Linux x86-64 SysV, Windows x64, AArch64 AAPCS64, Apple ARM64 and bare-metal profiles are separately versioned/tested. Platform syscalls and graphics/device APIs live behind adapters; direct inline syscalls are not a portable ABI strategy.

## Acceptance criteria

For each target: layout/offset fixture, register/stack calling fixture, owned-buffer transfer fixture, terminal-state race fixture, cancellation vs completion fixture, malformed input test and negative privilege/effect test. Failures must leave project and runtime state consistent.

## Open decisions

Stable wire/ABI serialization, descriptor representation, allocator hooks, exception-free debug diagnostics, unwind metadata, asynchronous scheduler implementation, cross-module hot reload and compatibility negotiation.
