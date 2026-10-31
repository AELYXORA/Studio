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

## Enum, exhaustive match and generic identity conformance — designed, NOT-RUN

[36 new value/type scenarios](../../examples/aui-compiler-production/enum-generic-value-cases.json) specify enum constructor payload arity, exhaustive pure match/binder scope, source profile gating, nested generic arity/depth/node budgets, recursive type cycle/Send/opaque handle rejection and trustworthy public export closure. Three cases have [materialized .aui sources](../../examples/aui-compiler-production/README.md) rather than only a prose mutation. The expected diagnostics are **candidate design outputs**, not observed compiler errors.

[Enum candidate logical digests](../../examples/aui-compiler-production/enum-logical-digest-reference-vectors.json) (3 exact ASCII D6-style projection strings) and [generic export ID candidates](../../examples/aui-compiler-production/generic-export-identity-reference-vectors.json) (2 exact recursive identity-only byte strings) were computed by Python hashlib and independently crosschecked with OpenSSL SHA-256. These are **only arithmetic reference vectors** against **unapproved domains**; the real AELYXORA compiler, D2 source resolver, D4 ABI and public core export trust were NOT-RUN / UNVERIFIED.

Future native verifier MUST prove separately: valid enum constructors and exhaustive match HIR, immutable ownership/move/drop across switch arms, exact ABI tag/payload/align/return, full typed nested generic ownership and resource limits, absence of invented public hash authority and correct source/Graph signed locks. A reference digest, a recursively valid JSON shape or successful source-only parse is **never** a production compiler PASS.

## Core rule-content review and digest trust boundary

[D3 CR14](d3-core-registry-value-contract.md) now includes a candidate content-bearing 15-type review projection. The [36 new semantic mutation cases](../../examples/canonical-graph/core-rule-content-review-cases.json) require a future verifier to detect rule-text mutation under unchanged ruleId, missing/duplicate rules, order-only equivalence, stale approved digests, forged TaskOutcome proofs and unapproved core/Graph payload admission. All 36 **NOT-RUN** as AELYXORA tests. Future release verification must independently validate the 15 full rule sets, complete normative meaning and transitive type/export dependencies, then compare approved canonical byte preimages, hash vectors, lock/signature checks and actual D4/D5 native behavior. A manual structural inspection alone is not sufficient.

## Full public digest pipeline conformance — candidate test design

[Public digest pipeline DG0–DG6](d2-d6-public-contract-digest-pipeline.md) owns dependency-order validation and scoped set boundaries, with [50 designed mutation/rejection cases](../../examples/canonical-graph/public-digest-pipeline-review-cases.json) all NOT-RUN. [Six public projection structure examples](../../examples/canonical-graph/public-contract-projection-shapes-candidate.json) and [two scoped type-set SHA calculations](../../examples/canonical-graph/scoped-type-export-set-arithmetic-vectors.json) are **untrusted arithmetic/shape test inputs**, not accepted public exports. A limited local structural checker admitted all six positive examples, rejected six selected altered shapes, and accepted both properly scoped set shapes while rejecting the wrong-scope selector; Python/OpenSSL independently agreed on both exact scope SHA preimages. Before any PASS: run an actual full JSON Schema 2020-12 resolver, native D6 canonical encoder, 15-core content/lock validator, exact operation/component/type-set/Graph recomputation, source/signature verification, target ABI tests and fail-closed error-path tests against non-placeholder approved dependencies.

## Exact public hash-chain candidate arithmetic corpus — reproducible but NOT trusted

[15 candidate CR14 core type hashes and fingerprint](../../examples/canonical-graph/core-15-content-digest-arithmetic-vectors.json), [complete sensor typed chain through C9](../../examples/canonical-graph/sensor-full-digest-chain-arithmetic.json) and [six D6 Unicode-byte vectors](../../examples/canonical-graph/d6-unicode-canonical-byte-arithmetic-vectors.json) provide full canonical input byte strings and expected candidate SHA-256. A repeat reference SHA-256 calculation verified all **32** stored hashes and byte lengths, and the complete candidate Graph TypeReference/component references were internally consistent. Python hashlib and OpenSSL independently matched both the CR14 Bool projection and sensor RawSample record; the six Unicode vectors were also computed by Python/OpenSSL. **These are data-integrity arithmetic checks, not native/compiler test PASS.** Production requires authoritative core semantic/source/signer admission, full JSON Schema and typed Graph validation, an independently implemented native D6 writer, qualified source and targets, real reproducible bytes and D1–D8 review.

## Full compiler IR verification — design-only

[72 IR acceptance designs](../../examples/aui-compiler-production/full-ir-pass-review-cases.json) cover source/Graph linking, L2 state, L3 cancellation, L4 keyed identity, SSA dominance, ownership joins, effect ordering, Win64 frames, import validation and actual native release. The [Ownership CFG](../../schemas/aui-compiler-ownership-cfg-candidate.schema.json) and [TargetMIR](../../schemas/aui-compiler-targetmir-candidate.schema.json) schemas provide structural review only. Three positive fixtures and three schema-valid but semantically invalid fixtures require **actual independent semantic verifier** tests before any PASS claim. Real COFF/PE/native runtime and D4/D5 tests are NOT-RUN.

## Internal compiler Assembly ABI conformance plan — NOT-RUN

The [IAI-v1 physical candidate](aui-compiler-internal-assembly-abi.md), [10 structure/19 limit reference table](../../schemas/aui-compiler-internal-abi-layout-candidate.json), [10 Ref64/record byte vectors](../../examples/aui-compiler-production/internal-abi-layout-byte-vectors.json) and [54 review cases](../../examples/aui-compiler-production/internal-abi-and-arena-review-cases.json) define future tests. Required actual execution: GAS/Clang integrated assembler offset and little-endian packing probes, Win64 nonvolatile register/stack/shadow-space preservation, stale Ref64 generation and exhaustion, arena lease lifecycle, atomic output seal/error rollback, deterministic allocation/step budgets, absence of pass-lifetime pointer escapes and independent D4 public app ABI. An arithmetic layout check of 10 structs/99 fields, 5 packed record vectors and 5 Ref64 words passed; **no native compiler/ABI or real arena test has run**, so all cases stay NOT-RUN.

## Candidate physical IR tag and payload conformance — native tests NOT-RUN

[139-tag T1–T6 catalog](../../schemas/aui-compiler-ir-payload-layout-candidate.json), [closed catalog Draft2020-12 shape](../../schemas/aui-compiler-ir-payload-catalog.schema.json), [16 little-endian payload reference vectors](../../examples/aui-compiler-production/ir-payload-template-byte-vectors.json) and [77 negative/positive design scenarios](../../examples/aui-compiler-production/ir-tag-payload-review-cases.json) now specify future test coverage. Limited arithmetic checks verified unique tags in correct stage ranges, all 16 payload offsets/widths/alignment, all 85 Ref64 pointee annotations, 16 byte vectors and the separate absolute-arena EnumMatch header example. This is **not** a full JSON Schema validation, independently built ABI probe, source/Graph signer, 139-tag AST/IR compiler visitor coverage or native runtime test. Required future proof: real GAS physical offsets, wrong-kind/generation Ref64 rejection, per-tag semantic/ownership/effect/ABI negative cases, deterministic arena sealing and actual T0–T8 compiled Win64 integration.

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
