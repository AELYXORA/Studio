# Local Verification and Release Gates

**Policy:** GitHub Actions and automated CI are disabled until release preparation. All checks are local, manual invocations. No CI workflow is permitted on the active branch before that decision changes.

## Present baseline

There is a limited Linux x86-64 Assembly JSON lexical preflight, but no complete JSON parser, Project Graph validator, native AUI compiler or general build coordinator. The preflight is **not** a verification baseline for graph semantics. For every future verification fixture, record the exact local invocation, target, expected outcome and observed **not run / pass / fail** result. Do not claim test execution without evidence.

## Planned gates

- G0: target triple, ABI layout and error-code conformance.
- G1: declarative parser, malformed-input rejection and stable identity.
- G2: deterministic tree diff, state preservation and binding validation.
- G3: layout and display-list contracts.
- G4: real window creation, rendering, input and accessibility.
- G5: source ownership and regeneration safety.
- G6: component permission boundaries and isolation.
- G7: end-to-end IDE functionality, packaging and cross-target tests.

Record pass/fail/not-run with evidence. No mock or unexecuted test counts as a pass. Cross-platform claims require executing tests on each target.


[Local Build System and Verification Architecture](local-build-verification.md) defines the local build DAG, tool execution permissions, incremental cache, cancellation/recovery and per-artifact verification evidence. Proposed only; CI stays disabled.
