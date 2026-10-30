# Declarative State and Binding Semantics

**Status:** design only; no live binding engine in the active Assembly code.

The declarative AST owns stable node keys and typed property metadata. Runtime state belongs to instances and is reconciled across tree updates by identity and compatible type. Rendering is a side effect of validated state updates; mutating drawn pixels is not the source of truth.

## Binding rules

One-way dependencies form a typed directed graph. Reject ambiguous writers, unresolved endpoints and cycles unless a declared delayed-state primitive makes the cycle intentional. Schedule changes deterministically and batch updates into coherent revisions. UI updates run through the platform event loop and must not block on I/O.

Actions and events carry typed payloads, explicit errors and cancellation; async scheduling is an isolated runtime service. No arbitrary process entry points from untrusted declaration files.

## Implementation plan

1. Declarative parser and immutable AST.
2. Registry of typed properties with stable IDs and defaults.
3. Binding graph validator and deterministic evaluator in Assembly.
4. State reconciliation and change-triggered invalidation.
5. Platform rendering and event dispatch.

No C++, Qt, QML, FMX, or imported third-party UI runtime is part of the target design.
