# Local Verification and Release Gates

**Policy:** GitHub Actions and automated CI are disabled until release preparation. All checks are local, manual invocations. No CI workflow is permitted on the active branch before that decision changes. **Design the tests during Phase I; execute them only after implementation in Phase III; apply corrections and regression testing in Phase IV.** [Design Gates](design-completion-gates.md) and [Specification Matrix](specification-completion-matrix.md) govern traceability.

## AUI compiler-first design fixture baseline (NOT-RUN)

[First compiler architecture contract](aui-compiler-first-implementation-contract.md) proposes P00–P06 UTF-8 lexer, L0/L1 parser and typed source-only plan before any linked/native compiler stage. [47 designed scenarios](../../examples/aui-compiler-first-slice/acceptance-cases.json) cover legal L0/L1, lexical corruption, unsupported future syntax, type/event/accessibility diagnostics, snapshot trust and no artifact publication on failure. [Provisional source-only catalogue](../../examples/aui-compiler-first-slice/review-type-catalog.json), [expected L0 output](../../examples/aui-compiler-first-slice/status-panel-l0.source-only-plan.expected.json) and [output shape](../../schemas/aui-compiler-source-only-plan.schema.json) are review artifacts only. The source-only plan's explicit `UNVERIFIED_SOURCE_ONLY` status must never be reported as a validated native executable or approved graph. Every new scenario remains NOT-RUN by AELYXORA.

## Full production AUI compiler verification — product release criterion

The [single complete AUI compiler specification](aui-compiler.md) requires far more than a syntax checker. The [66 production compiler scenarios](../../examples/aui-compiler-production/complete-compiler-acceptance.json) include **actual** L0–L4 language, public record/enum/service interfaces, exact canonical public types/Graph/source links, reactive state, async task/late-cancel races, keyed lists, OwnershipIR/optimizer correctness, Win64 native machine object and runtime ABI, deterministic clean builds and signed admission. All are designed but **NOT-RUN**, and an accepted test must record source and package byte hashes, target, OS/ABI/toolchain, exact command and native object/results.

A full compiler verification campaign must include: (a) positive complete AUI source → target-native linked build → actual target UI/runtime behavior, (b) negative source/type/effect/ownership/capability/Graph/ABI cases that reject without modified trusted output, (c) adversarial Unicode/arena bounds/invalid inputs, (d) signed artifact and runtime import/permission rejection, (e) repeated deterministic unsigned PE/COFF builds, (f) independent codegen/ABI inspection and error-path teardown, and (g) IDE edit/map/review/debug/build/run source mapping. Source-only L0/L1 fixture success is only an incremental engineering signal.

[Full acceptance fixtures](../../examples/aui-compiler-production/README.md) and [source-profile rules](aui-syntax.md) are candidate contracts; nothing here asserts native test PASS, complete grammar freeze, approved 15-type core exports or real Windows app execution. D1–D8 remain OPEN.

## Complete AUI parser/typechecker grammar review — design-only

[Integrated AUI Syntax L0–L4 and contract-only source](aui-syntax.md) is now accompanied by [36 candidate grammar and semantic rejection cases](../../examples/aui-compiler-production/integrated-grammar-cases.json). The cases cover component vs contract module input, exact profile feature admission, L2 Text init/binding, L3 taskSlot/TaskOutcome, L4 ForEach/StableKey and *mandatory rejection* when public enum/service exports cannot be represented or linked by the existing canonical package.

**Testability gap:** most cases are described semantic mutations of existing source examples, not materialized full source files or compiler-emitted diagnostics. Before marking PASS, materialize immutable byte-exact positive and negative test inputs, target/import/core/lock context, expected diagnostic code+source span, correct emitted typed IR and actual Graph/native output where applicable. Record real compiler tool version, hashes and observed results. Even a full parser PASS cannot satisfy [66 production native compiler acceptance cases](../../examples/aui-compiler-production/complete-compiler-acceptance.json) without backend/runtime verification. All currently **NOT-RUN**.

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
