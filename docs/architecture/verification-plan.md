# Architecture Verification Plan

**Status:** planned, with no passing implementation evidence.

## Traceability

Each normative contract should have stable requirement IDs, linked tests and observable evidence. Requirements and test results are maintained separately. A test marked N/A requires a technical rationale.

## Gate sequence

| Gate | Required evidence |
| --- | --- |
| G0 Model integrity | parsing, deterministic save/load, stable IDs, malformed-input rejection |
| G1 Transactions | stale-revision conflict, undo/redo, interrupted-write recovery |
| G2 Generation safety | ownership enforcement, external edit preservation, reproducible file manifest |
| G3 Bindings | type checks, update ordering, cycles, validation and errors |
| G4 Runtime | real SQLite CRUD persistence, restart/reload, lifecycle and cancellation |
| G5 AI changes | scoped diff, security denial, schema validation, rollback |
| G6 Toolchain | clean builds, platform matrix, packaged standalone runtime |
| G7 Security | path escaping, plugin isolation claims tested, secret scanning, dependency audit |

A gate is **not run**, **pass**, **fail** or **not applicable with rationale**. Tests never pass by documentation assertion.

## End-to-end demonstration

Create a CustomerDesk app using visual form/table composition and SQLite; generate code; add a custom business-rule source module; regenerate without losing the module; reject a broken typed binding; use AI to propose and roll back a change; build and run on Windows and Linux; install/export independently of the IDE.

## Continuous architecture checks

Documentation links, schema fixtures, ADR consistency, build dependency direction, generation manifest drift and target capability validation should be machine-checkable locally during development; local verification remains disabled until release preparation.
