# AELYXORA — First AUI Compiler Assembly Implementation Backlog

**Status: PROPOSED / DESIGN-ONLY. No native compiler code, authorization, tested ABI or accepted D1–D8 gate.** This is the engineer-facing implementation sequence for the single [first compiler architecture](aui-compiler-first-implementation-contract.md) and its detailed [COMP-01–05 frontend closure](aui-compiler-frontend-closure.md). It adds neither a second compiler architecture nor feature editions.

## Entry conditions

Before coding, the human architect must approve the selected COMP-01–05 contracts and the bounded Phase II scope in accordance with [Design Completion Gates](design-completion-gates.md). The proposed first host is Windows x64; the implementation language is target-specific Assembly, linked by a verified Clang/COFF toolchain. Record actual compiler/assembler executable path, version, SDK, flags and tool hashes, and actual Unicode 15.1.0 UCD file hashes. **Those values are not yet observed and must not be fabricated.** No Python/C++/Qt/Node.js implementation, network dependency, runtime UI or implicit CI.

Source-only work P00–P06 is independent of verified native component exports. Graph-linked P07 and native output P08–P10 remain blocked by exact D2/D6 canonical export and signature trust, D4 Win64 ABI and D5 runtime/UI renderer.

## Proposed module layout (future paths, not files)

~~~text
src/auic/win64/entry.S          # CLI and target ABI
src/auic/win64/host_io.S        # Win32 paths, bounded file handles, staging
src/auic/core/context.S        # bounded arenas, allocation and cleanup
src/auic/core/utf8.S           # strict UTF-8 decoding
src/auic/core/unicode_nfc.S    # pinned XID/NFC data and lookup
src/auic/core/lexer.S          # tokens and lossless trivia
src/auic/core/parser.S         # D3 L0/L1 CST and AST only
src/auic/core/symbols.S        # scope and name/import resolution
src/auic/core/typecheck.S      # named args, properties and types
src/auic/core/view_event.S     # accessibility, local handlers and effects
src/auic/core/hir.S            # typed source-only IR
src/auic/core/plan_json.S      # deterministic success plan
src/auic/core/diag_json.S      # deterministic failed report
~~~

Each module uses the narrow owned CompilationContext contract defined by [FC1/FC4](aui-compiler-frontend-closure.md). Shared private record offsets and cross-module register conventions must be reviewed before parallel Assembly implementation. An internal pointer, arena offset or compiler-local ViewID never becomes a persistent GraphNodeID.

## Ordered future implementation tasks

| Task | Output | Required rejection or evidence |
| --- | --- | --- |
| AUIC-00 | Win64 CLI, OS adapter, exact file capture | Unknown/duplicate options, invalid file/path, or source length overflow reject; no shell/network/execution |
| AUIC-01 | Bounded CompilationContext, checked allocation, single cleanup path | Proposed 64 MiB budget; no stale arena pointers or partial publication on failure |
| AUIC-02 | UTF-8/XID/NFC identifier service | Unicode 15.1.0 tables pinned by actual source digests; invalid scalar/escape, NFC symbol collision reject |
| AUIC-03 | Lossless tokenizer and D3 L0/L1 parser | One component/one root View; error-recovered CST never yields successful AST |
| AUIC-04 | Imports/names/type resolution | Explicit unverified review catalogue, no implicit provider, untyped or unknown imported symbol rejects |
| AUIC-05 | Static properties, effects, accessibility, event handlers | Named args, U32 bounds, one Button label, one local handler/send; no hidden effect |
| AUIC-06 | TypedHIR and source-order View traversal | Preorder v0,v1,… identities; original byte spans; no GraphOrigin |
| AUIC-07 | Successful source-only JSON plan | Closed schema, UNVERIFIED_SOURCE_ONLY, deterministic bytes, zero diagnostics |
| AUIC-08 | Separate failure diagnostics writer | Correct stage/code/byte span, nonzero exit, no successful plan for invalid source |
| AUIC-09 | Output staging/commit | No overwrite on failure, complete writes and safe cleanup; D6 crash durability not claimed |
| AUIC-10 | Build/evidence handoff | Manual local observations only in Phase III, no invented test PASS or performance |

The decomposition above is an implementation backlog, **not a claim of a finished build, file tree or test run**. If a native layout/contract needs to change during implementation, reopen its owning design document before coding against the new rule.

## First two concrete end-to-end expected outcomes

**Positive L0:** [unchanged StatusPanel](../../examples/aui-language/status-panel-l0.aui), 296 bytes with exact SHA-256 aaccb407277bd686fa561c2eecbb539a97a626112b6727d7f9c1a7597ce5b1e5, is expected to produce the manually authored [unverified plan](../../examples/aui-compiler-first-slice/status-panel-l0.source-only-plan.expected.json): one component, String input, VStack/Text/Button preorder View IDs, two accessibility labels, zero graph-linked operations.

**Negative L0:** [materialized invalid U32 spacing source](../../examples/aui-compiler-first-slice/status-panel-invalid-spacing.aui), 304 bytes with exact SHA-256 1231502beaa755aa1dd4b235621ccf4f10e1aa03cbb72e105875f3f5eca4f96a, must reject at P04 with AUI_NUMBER_RANGE, original byte range [153,163), matching the proposed [diagnostic report](../../examples/aui-compiler-first-slice/status-panel-invalid-spacing.diagnostics.expected.json). No successful TypedHIR/native object or previous output alteration follows.

[45 compiler-first design cases](../../examples/aui-compiler-first-slice/acceptance-cases.json), [35 Unicode/lexical design cases](../../examples/aui-compiler-first-slice/unicode-and-diagnostics-cases.json) and existing [D3 negative cases](../../examples/aui-language/d3-first-profile-negative-cases.json) cover remaining proposed verification. All remain **NOT-RUN** by AELYXORA.

## Unapproved decision record

| Gate | Candidate | Current acceptance |
| --- | --- | --- |
| COMP-01 | Win64 Assembly CLI host, Clang/COFF toolchain, one context | PROPOSED; actual toolchain qualification OPEN |
| COMP-02 | Unicode 15.1.0 UAX XID/NFC, lexical limits, memory budgets | PROPOSED; UCD hashes and conformance OPEN |
| COMP-03 | Closed, unverified source-only type catalogue | PROPOSED; architect acceptance OPEN |
| COMP-04 | TypedHIR, deterministic plan and separate failure report | PROPOSED; independent future compiler golden output OPEN |
| COMP-05 | Strict visual/label/event/effect semantics | PROPOSED; architect acceptance OPEN |
| P07–P10 | Verified Graph exports, source approvals, Win64 ABI and renderer | BLOCKED by separate gates |
| Phase II implementation | Code AUIC-00..10 under the accepted bounded scope | **NOT AUTHORIZED** |

**Ready for first coding** requires explicit human acceptance of COMP-01..05 and the agreed scope of the Phase II gate (or an expressly recorded bounded exception under existing project policy). The completed documentation by itself is not authority to begin implementation or run unverified native modules.
