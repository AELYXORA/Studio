# Data Binding Engine — Executable Prototype

**Status:** experimental C++23 headless implementation; not a full reactive runtime.

`propagate_bindings` applies synchronous one-way links for same-kind properties against an immutable candidate. It validates component/property endpoints with the Component Registry; rejects multiple writers to one destination, cycles, type mismatch, invalid model and stale project revisions. It executes links in deterministic topological order, then commits all property updates together and increments revision once.

## Guarantees in scope

- No partial publication on validation or evaluation failure.
- Deterministic ordering for a static acyclic graph.
- Default values resolved from the registry when no instance override exists.
- Empty graph is a no-op.
- Errors use existing diagnostics.

## Out of scope

Bindings are supplied in memory and are **not** yet stored in project JSON. There is no event-driven/incremental propagation, scheduling, asynchronous action, converter, two-way binding, UI thread dispatch, reactive subscriptions or persistence transaction. The full Application Model and runtime architecture remain evolving documents.

Next: persist bindings with stable IDs, validate them on project load, use explicitly versioned registry entries, and implement change-triggered propagation with tests before connecting Qt 6.12/QML.
