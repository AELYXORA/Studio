# AUI Runtime, State and Rendering — Design Specification

**Status: proposed.** No AUI runtime implementation currently exists.

## Runtime services

- Immutable desired-view descriptions, stable identity and component lifecycle.
- Typed state store with explicit owner, revision, scope and lifetime.
- Reconciliation of previous/next views to preserve compatible state and compute minimal changes.
- Deterministic binding dependency evaluation and observable invalidation.
- Typed event and command routing with permission/effect gates.
- Explicit Task/Worker/Scheduler services and bounded inter-thread communication.
- Rendering display list with separate platform-specific backends.
- Structured diagnostics, performance counters and safe shutdown.

## Update transaction

Input event or worker result -> enqueue typed command -> validate target/effect/revision -> mutate candidate state -> evaluate affected computed/bindings in dependency order -> reconcile view descriptions -> compute layout invalidations -> publish coherent frame and event results. Failure before commit leaves previous state authoritative.

Thread-affinity and lifetime rules are explicit. Render callbacks must not block on device I/O. State crossing threads uses messages or explicitly atomic/locked storage, never unsynchronized shared pointers.

## Memory / allocation

State ownership and view lifetimes are defined separately. Favor stack/arena/value layouts where safe. Dynamic allocation is allowed when justified, observable and bounded; zero-cost abstractions do not imply an allocation-free application. DMA and MMIO resources are represented by capability-gated handles, not ordinary UI pointers.

## Layout and renderer

Constraint/measure/layout algorithm must define size proposals, min/max/intrinsic sizes, flex/grid distribution, clipping, transforms, stacking, scroll, pixel density and deterministic invalidation. Text shaping, fonts, cursor/selection, IME, bidi and accessibility require dedicated services. Display lists should support batched primitives; CPU/GPU backend choice is a target capability, not part of view identity.

## Scheduling

Separate UI, render, I/O, worker and real-time/interrupt domains. Bounded queues, cancellation, deadlines, backpressure and failure delivery are normative. Real-time guarantees require platform-specific measured evidence; do not claim universal hard-real-time behavior.

## Open decisions

Canonical state store format, diff algorithm, event loop, graphic backend, text stack, exact frame timing, device telemetry ingestion and leak/resource instrumentation. No platform support is declared before end-to-end rendering and input tests.

## State identity and ownership contract

A state slot is addressed conceptually by `(project, component instance, stable view key, state declaration ID)`, not by a transient pointer or current canvas position. Reconciliation preserves a slot only when identity, component type and declared state type remain compatible. Removing an instance invalidates its state handles and cancels only tasks whose explicit lifetime is attached to that instance.

Resource-bearing state uses move/borrow/owned contracts defined at the component boundary. No borrowed pointer may outlive its declared owner, cross a task boundary without an explicit lifetime guarantee, or be retained across a reconciliation invalidation.

## Event-to-frame ordering

```text
external input / completed worker message
 -> typed event envelope (origin, sequence, target)
 -> select command handler and check capability
 -> produce candidate state revision
 -> validate data-flow writes and effects
 -> evaluate affected pure bindings
 -> reconcile identities and dependencies
 -> compute invalidated layout/render regions
 -> publish committed revision
 -> schedule frame and effectful follow-up tasks
```

A committed state revision must be internally consistent even if a later rendering operation fails. Failed drawing must preserve the last valid state and surface a renderer diagnostic. Cross-thread messages carry immutable values or explicitly synchronized owned buffers.

## D2 first-profile execution mapping (design proposal)

[D2 Execution and Consistency](d2-execution-consistency.md) defines the proposed architecture-level per-instance FIFO ordering, bounded workflow admission, typed command-success/failure signals, cancellation-request vs confirmed-stop, terminal publication, ownership and graph CAS boundaries. The AUI runtime must **not** treat a cancellation request or a deadline as physical device quiescence. Follow-up events enqueue instead of recursive transition processing; a committed instance transition must not be rolled back by renderer failure. Running instances pin their previous validated graph snapshot; view generation does not grant lifetime of device buffers. D4/D5 still owe exact scheduler algorithm, native memory atomics, thread-safety and cancellation correctness proof; this cross-reference is not implementation evidence.

## Task and channel semantics

- Channel capacity is explicit. D2 graph interchange uses **block** (runtime wait), **drop-oldest**, **drop-newest**, or **reject** (runtime error). The older runtime terms `wait` and `error` are descriptive aliases, **not separate serialized policies**. UI/IRQ/nonblocking domains cannot use `block`. Observable drop/rejection counts and ownership cleanup are mandatory.
- Delivery order is FIFO **within one channel**; cross-channel ordering is unspecified unless a sequence/merge contract defines it.
- An interrupt handler may only perform operations declared safe for its context; heavyweight parsing/rendering is deferred to worker tasks.
- Task cancellation requests cannot revoke a physical hardware operation already in progress unless the device contract supports it.
- Shutdown must quiesce queues, revoke subscriptions, and release owned memory and OS handles without use-after-free.

## Runtime acceptance scenarios

A 1,000-event burst into a bounded sensor queue must remain bounded; event loss and latency must be measurable. A stale view instance may not receive a late completion as if it were a new instance. An invalid binding transaction cannot partially publish state. A renderer failure cannot cause an approved driver operation to silently rerun.

## D3+ UI state and async integration — PROPOSED

[L2 State/Derived/Bind](d3-state-derived-binding-contract.md) explicitly bounds atomic local UI StateRevision transactions, pure topological invalidation and one writer per statically keyed view property. A renderer fault after a committed UI revision does not roll back that revision or re-run an external command. [L3 Task/Result](d3-task-result-lifecycle.md) separates UI event ingress (candidate 64 per view), task slot admission, D2 provider command ticket, and bounded completion delivery. Cancellation request != terminal Cancelled; stale ViewIdentity/generation cannot receive a late TaskOutcome. The TaskSlot proposal is limited to one active task per slot and D5 must still prove overall queue limits, fairness, atomics and memory cleanup. [Source snapshot owner](d3-source-snapshot-reconciliation.md) forbids a standalone proposed link-map from granting execution. No runtime implementation is claimed.

## D3+ state and task integration (PROPOSED)

[L2 State/Derived/Bind](d3-state-derived-binding-contract.md) specifies atomic local UI StateRevision, pure invalidation and single writer to statically keyed views. A renderer failure after UI commit cannot undo state or re-run a provider command. [L3 Task/Result](d3-task-result-lifecycle.md) separates UI event ingress, task slot admission, D2 provider CommandTicket and bounded completion ingress. Cancellation-request is not Cancelled; old ViewIdentity generation cannot receive the new view's result. [Source snapshot approval](d3-source-snapshot-reconciliation.md) is mandatory before GRAPH_LINKED evidence. Native scheduler/atomics/allocator, memory budgets and tests remain open.
