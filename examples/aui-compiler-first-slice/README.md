# First AUI Compiler — Phase I Design Fixtures (NOT-RUN)

These are **future acceptance expectations** for the bounded [first Assembly compiler architecture contract](../../docs/architecture/aui-compiler-first-implementation-contract.md), not executable tests and not evidence of a working compiler, renderer, native module, Graph resolver or sign-off.

## Fixture inventory

- [Acceptance cases](acceptance-cases.json): 45 designed source-only, graph-link, native, limit, trust, deterministic emission and no-publication checks. Every case has `observed: NOT-RUN`.
- [Provisional L0/L1 review catalogue](review-type-catalog.json): exact type names/builtin property signatures for local source-only checks, including the historical fixture aliases `Tick` and `Failure`. **Not** an authenticated `coreRegistryFingerprint`, public type/operation digest, Win64 runtime or permission.
- [StatusPanel expected source-only plan](status-panel-l0.source-only-plan.expected.json): one proposed normalized output for [unchanged L0 source](../aui-language/status-panel-l0.aui), with three view nodes and two static accessibility labels. This file is a **manually authored design vector**, not compiler-produced output; field shape is described by the [source-only plan schema](../../schemas/aui-compiler-source-only-plan.schema.json).
- [D3 first-profile negative cases](../aui-language/d3-first-profile-negative-cases.json): historical design fixture mutations reused without modifying the original sources. The [L1 ConsumerPanel](../aui-language/linked-consumer-panel.aui) has a **historical, unapproved** link JSON, not proof of the current complete canonical graph.

## Intended developer workflow after architectural authorization

1. Capture the exact unchanged source bytes and SHA. Reject mutation fixture search/replace unless it matches exactly once; do not accidentally edit fixture baselines.
2. Parse/validate source under an explicit `l0` or `l1` profile with the provisional catalogue. Emit real source-spanned diagnostics or a successful **UNVERIFIED_SOURCE_ONLY** TypedHIR/plan.
3. Compare an actual compiler-emitted plan with the expected shape and source origins. Verify the reference L0 file's source SHA-256 `aaccb407277bd686fa561c2eecbb539a97a626112b6727d7f9c1a7597ce5b1e5` and byte length `296` before using this expectation. Whitespace/source changes require regenerated spans and SHA, not silent acceptance.
4. Verify all negative fixtures reject in the designated stage without successful TypedHIR or published native artifacts. Confirm repeat runs give deterministic result bytes for the same exact inputs/toolchain.
5. Do **not** run linked/native outputs until the current 15-type core registry/public exports, canonical Graph locks and typed links, D4 ABI, D5 UI renderer and authentic authorizations are independently accepted.
6. Record **real** input digests, commands, host, build tool identity, output bytes, diagnostics and status when tests are eventually executed. A source-only PASS does not convert any linked/native expected case to PASS.

## Non-goals

No additional graph model, compiler DSL, runtime or third-party UI toolkit is introduced. This folder contains JSON documentation, not a compiler implementation or new product architecture edition. No Python, CI, synthetic signed-approval status, implicit internet dependency or target ABI assumption.
