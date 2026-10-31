# First AUI Compiler — Phase I Design Fixtures (NOT-RUN)

These are **future acceptance expectations** for the bounded [first Assembly compiler architecture contract](../../docs/architecture/aui-compiler-first-implementation-contract.md), not executable tests and not evidence of a working compiler, renderer, native module, Graph resolver or sign-off.

## Fixture inventory

- [Acceptance cases](acceptance-cases.json): 47 designed source-only, graph-link, native, limit, trust, deterministic emission and no-publication checks. Every case has `observed: NOT-RUN`.
- [Provisional L0/L1 review catalogue](review-type-catalog.json): exact type names/builtin property signatures for local source-only checks, including the historical fixture aliases `Tick` and `Failure`. **Not** an authenticated `coreRegistryFingerprint`, public type/operation digest, Win64 runtime or permission.
- [StatusPanel expected source-only plan](status-panel-l0.source-only-plan.expected.json): one proposed normalized output for [unchanged L0 source](../aui-language/status-panel-l0.aui), with three view nodes and two static accessibility labels. This file is a **manually authored design vector**, not compiler-produced output; field shape is described by the [source-only plan schema](../../schemas/aui-compiler-source-only-plan.schema.json).
- [ConsumerPanel L1 expected source-only plan](linked-consumer-panel-l1.source-only-plan.expected.json): manually authored 579-byte L1 type/event/command/handler and two-modifier view tree. Catalogue bytes and source SHA are pinned, but public Tick/Failure exports and operation provider are UNVERIFIED. This tests P02–P06 mapping only.
- [D3 first-profile negative cases](../aui-language/d3-first-profile-negative-cases.json): historical design fixture mutations reused without modifying the original sources. The [L1 ConsumerPanel](../aui-language/linked-consumer-panel.aui) has a **historical, unapproved** link JSON, not proof of the current complete canonical graph.

## COMP-01–05 detailed closure and first error vector

[Front-end closure specification](../../docs/architecture/aui-compiler-frontend-closure.md) now proposes the Win64 Assembly module boundaries, Unicode 15.1.0 identifier XID/NFC policy, strict lexical states, bounded 64 MiB CompilationContext, name/type/accessibility/event rules, and deterministic data/diagnostic publication. The [implementation backlog](../../docs/architecture/aui-compiler-implementation-backlog.md) describes future Module/Task ordering, **not created source code or an approved Phase II**.

The [review-type-catalogue schema](../../schemas/aui-compiler-review-type-catalog.schema.json) structurally constrains the provisional [catalogue](review-type-catalog.json), whose imports remain **UNVERIFIED** and authorize no graph link or executable. For exact error-output inspection, [invalid-spacing.aui](status-panel-invalid-spacing.aui) is a materialized 304-byte source changing only spacing to 4294967296; the [diagnostic expectation](status-panel-invalid-spacing.diagnostics.expected.json) predicts P04 / AUI_NUMBER_RANGE / [153,163), using a distinct [failed-report schema](../../schemas/aui-compiler-source-only-diagnostics.schema.json). The SHA-256 was computed independently for those exact bytes; this is **not compiler-generated output**.

The [35 Unicode/lexical design cases](unicode-and-diagnostics-cases.json) cover strict UTF-8, invalid surrogate escapes, NFC-identical source names, typed integers and future-profile rejection. They are **NOT-RUN**; the official UCD 15.1.0 inputs/sha and native source compiler remain outstanding.

## Verified scope of today's source-only reference designs

The [L0 success plan](status-panel-l0.source-only-plan.expected.json), [L1 success plan](linked-consumer-panel-l1.source-only-plan.expected.json) and [invalid U32 failure report](status-panel-invalid-spacing.diagnostics.expected.json) now all bind the **exact current provisional catalogue SHA-256** `8446fb67384923b0ff4baf6c90509b34a3fd711a1880526034300f66153b22b0`. The L1 plan was checked against the 579-byte original, and a bad manually entered command parameter span was corrected. Both success plans have three source-ordered Views; L1 also has one event, one command, one handler and three modifiers. These are **manually constructed design expectations**, NOT compiler-generated artifacts.

[First compiler practical readiness matrix](../../docs/architecture/implementation-readiness.md) distinguishes code handoff from signed acceptance. [47 compiler acceptance cases](acceptance-cases.json) and [35 Unicode cases](unicode-and-diagnostics-cases.json) remain NOT-RUN. Most mutation scenarios are still descriptions and need materialized input/expected diagnostics before executable golden testing.

## Intended developer workflow after architectural authorization

1. Capture the exact unchanged source bytes and SHA. Reject mutation fixture search/replace unless it matches exactly once; do not accidentally edit fixture baselines.
2. Parse/validate source under an explicit `l0` or `l1` profile with the provisional catalogue. Emit real source-spanned diagnostics or a successful **UNVERIFIED_SOURCE_ONLY** TypedHIR/plan.
3. Compare an actual compiler-emitted plan with the expected shape and source origins. Verify the reference L0 file's source SHA-256 `aaccb407277bd686fa561c2eecbb539a97a626112b6727d7f9c1a7597ce5b1e5` and byte length `296` before using this expectation. Whitespace/source changes require regenerated spans and SHA, not silent acceptance.
4. Verify all negative fixtures reject in the designated stage without successful TypedHIR or published native artifacts. Confirm repeat runs give deterministic result bytes for the same exact inputs/toolchain.
5. Do **not** run linked/native outputs until the current 15-type core registry/public exports, canonical Graph locks and typed links, D4 ABI, D5 UI renderer and authentic authorizations are independently accepted.
6. Record **real** input digests, commands, host, build tool identity, output bytes, diagnostics and status when tests are eventually executed. A source-only PASS does not convert any linked/native expected case to PASS.

## Non-goals

No additional graph model, compiler DSL, runtime or third-party UI toolkit is introduced. This folder contains JSON documentation, not a compiler implementation or new product architecture edition. No Python, CI, synthetic signed-approval status, implicit internet dependency or target ABI assumption.
