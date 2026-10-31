# Local Verification and Release Gates

**Policy:** GitHub Actions and automated CI are disabled until release preparation. All checks are local, manual invocations. No CI workflow is permitted on the active branch before that decision changes. **Design the tests during Phase I; execute them only after implementation in Phase III; apply corrections and regression testing in Phase IV.** [Design Gates](design-completion-gates.md) and [Specification Matrix](specification-completion-matrix.md) govern traceability.

## AUI compiler-first design fixture baseline (NOT-RUN)

[First compiler architecture contract](aui-compiler-first-implementation-contract.md) proposes P00–P06 UTF-8 lexer, L0/L1 parser and typed source-only plan before any linked/native compiler stage. [45 designed scenarios](../../examples/aui-compiler-first-slice/acceptance-cases.json) cover legal L0/L1, lexical corruption, unsupported future syntax, type/event/accessibility diagnostics, snapshot trust and no artifact publication on failure. [Provisional source-only catalogue](../../examples/aui-compiler-first-slice/review-type-catalog.json), [expected L0 output](../../examples/aui-compiler-first-slice/status-panel-l0.source-only-plan.expected.json) and [output shape](../../schemas/aui-compiler-source-only-plan.schema.json) are review artifacts only. The source-only plan's explicit `UNVERIFIED_SOURCE_ONLY` status must never be reported as a validated native executable or approved graph. Every new scenario remains NOT-RUN by AELYXORA.

## Present baseline

There is a limited Linux x86-64 Assembly JSON lexical preflight, but no complete JSON parser, Project Graph validator, native AUI compiler or general build coordinator. The preflight is **not** a verification baseline for graph semantics. For every future verification fixture, record the exact local invocation, target, expected outcome and observed **not run / pass / fail** result. Do not claim test execution without evidence.

## Planned verification layers (V0–V7; distinct from product milestones M0–M7)

- V0: target triple, ABI layout and error-code conformance.
- V1: declarative parser, malformed-input rejection and stable identity.
- V2: deterministic tree diff, state preservation and binding validation.
- V3: layout and display-list contracts.
- V4: real window creation, rendering, input and accessibility.
- V5: source ownership and regeneration safety.
- V6: component permission boundaries and isolation.
- V7: end-to-end IDE functionality, packaging and cross-target tests.

Each V-layer must have a pre-authored positive and negative fixture, required host/target/toolchain, exact procedure, expected output and diagnostic codes, integrity and rollback assertions where relevant. During design, all actual results are **not-run**. After implementation, record pass/fail/not-run/unsupported with observable evidence; include artifact digests, timing and platform limitations. No mock or unexecuted test counts as a pass. Cross-platform claims require executing tests on each target. Failing scenarios feed Phase IV with a defect-to-requirement link and regression re-execution.


[Local Build System and Verification Architecture](local-build-verification.md) defines the local build DAG, tool execution permissions, incremental cache, cancellation/recovery and per-artifact verification evidence. Proposed only; CI stays disabled.
