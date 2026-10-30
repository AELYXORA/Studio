# AUI Runtime, State and Rendering — Design Specification

**Status: proposed.** The current x86-64 node validator is not this runtime.

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
