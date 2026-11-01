# AELYXORA Studio — Current Technical Status

**Authoritative status: Phase I (design), all D1–D8 architect acceptance gates OPEN.** No native product release, no approved executable ABI and no implementation of the complete Studio. This file reports evidence rather than interpreting design documents as passing tests.

## X01 borrow-lifetime contract — 2026-11-01

[Borrow-scoped ResolveRef design](aui-compiler-x01-borrow-scoped-resolve.md) identifies the unsafe global-leaseCount/return-raw-pointer boundary, specifies synchronized callback-scoped borrows and retire quiescence, and adds [16 NOT-RUN concurrency/negative cases](../../examples/aui-compiler-production/x01-borrow-race-test-matrix.json). Existing sequential Assembly probes remain only test infrastructure. X01 and D1–D8 OPEN.

## X01 integrated Assembly execution — 2026-11-01

[Lifecycle + table resolver integrated test](aui-compiler-x01-integrated-assembly-test.md) executed on Linux x86-64 (exit 0), with all three Assembly modules cross-assembled to Win64 COFF after removing a Linux-only directive. Stale-generation rejection verified sequentially. **Caller-held lease, concurrent retire, real allocation and Windows execution remain unverified.** X01 / D1–D8 OPEN.

## X01 arena lifecycle runtime verification — 2026-11-01

The previously NOT-RUN [Assembly lifecycle harness](../../tests/native/x01_arena_lifecycle_test.S) was subsequently **compiled and executed on Linux x86-64**, returning 0 after its complete sequential assertion path. The lifecycle source also cross-assembled successfully to Win64 COFF. [Updated evidence](aui-compiler-x01-arena-lifecycle-prototype.md#follow-up-execution-evidence--2026-11-01). No Windows runtime execution, concurrent safe arena manager, allocator/free or generation-exhaustion test; X01 and D1–D8 remain OPEN. The older section below describes the historical earlier attempted run, not the current test status.

## X01 arena entry lifecycle prototype — 2026-11-01

[Lifecycle source and harness](aui-compiler-x01-arena-lifecycle-prototype.md) were committed; local source retrieval failed due to DNS, so **no compilation or runtime test has occurred for this new prototype**. The implementation remains single-threaded and does not allocate or free backing memory. X01 and D1–D8 OPEN.

## X01 arena-table execution — 2026-11-01

[Arena-table ResolveRef runtime evidence](aui-compiler-x01-arena-table-runtime-evidence.md) records five executed Linux x86-64 checks (exit code 0), plus successful Win64 COFF cross-assembly. No actual Win64 execution, safe concurrent arena lifecycle or descriptor-kind enforcement. X01 and D1–D8 remain OPEN.

## X01 first executed Assembly ResolveRef tests — 2026-11-01

[Local runtime report](aui-compiler-x01-resolve-ref-runtime-evidence.md): six-case Assembly-only harness executed on Linux x86-64 with exit code 0, testing one valid pointer and five invalid Ref64/lease/alignment cases. Win64 COFF cross-build also succeeded. **Not Windows runtime, not a full arena table or certified ResolveRef**; X01/D1–D8 remain OPEN.

## X01 third actual COFF probe — 2026-11-01

[One-entry ResolveRef COFF probe](aui-compiler-x01-resolve-ref-one-probe.md) cross-assembled successfully on Linux for Win64. It adds candidate sealed-state/lease, checked size, alignment and pointer overflow validation, but **no Windows execution, real arena table, concurrency/lifetime or typed descriptor proof**. X01 and D1–D8 remain OPEN.

## X01 second actual COFF probe — 2026-11-01

[Second COFF cross-build evidence](aui-compiler-x01-ref-bounds-crossbuild.md) confirms successful cross-assembly and disassembly of a candidate Ref64 bounds function. Native Windows execution and arena lifetime validation remain NOT-RUN; X01 and D1–D8 OPEN.

## X01 first actual COFF probe — 2026-11-01

[Observed Win64 cross-assembly evidence](aui-compiler-x01-actual-coff-probe.md) records successful local Linux-host Clang 17 Windows x64 COFF assembly of [probe](../../tests/native/x01_abi_probe.S). Static 48/32/16-byte fixture assertions passed and `.rdata` measured 0x60 bytes. **Windows runtime tests, arena validation and full ABI approval NOT-RUN**. X01 and D1–D8 remain OPEN.

## X01 zero-length and Span16 design progress — 2026-11-01

[Zero-length String/Span contract](aui-compiler-x01-zero-length-span-contract.md) specifies candidate empty String descriptor `dataRef=0,byteLength=0` with a real nonzero TokenV1.valueRef, canonical empty typed Ref64 Span16 and synthetic nonempty span. Three [byte arithmetic vectors](../../examples/aui-compiler-production/x01-zero-length-span-byte-vectors.json) are available. No native ABI/layout tests; X01 OPEN.

## X01 TokenV1 field candidate — 2026-11-01

[TokenV1 field layout candidate](aui-compiler-x01-token-field-layout.md) adds draft profile-mask and flag semantics plus 32-byte decoded-value descriptor via Ref64. One [48-byte layout vector](../../examples/aui-compiler-production/x01-token-v1-byte-layout-candidate.json) demonstrates little-endian arithmetic, **not** a successful compiler/ABI probe. Exact profile masks and native validation remain OPEN.

## X01 native lexer handoff — 2026-11-01

[Lexer ABI handoff](aui-compiler-x01-native-lexer-abi.md) and [13 candidate golden byte vectors](../../examples/aui-compiler-production/x01-lexer-golden-vectors.json) now specify token/trivia byte offsets and failure cases. No native lexer is implemented or tested; flags/profileMask and Ref64 pool layouts are still awaiting review. X01 remains OPEN, as do D1–D8.

## X01 normalized Predict review — 2026-11-01

[Token-normalized Predict review](aui-compiler-x01-token-normalized-predict.md) reports the same three overlaps for the 57-production candidate after numeric token/contextual ID conversion. The calculation is in-memory review-only; complete lexical classification, independent replay and native tokenizer evidence remain OPEN. X01 is not closed.

## X01 token reconciliation progress — 2026-11-01

The `settled` candidate is now explicitly **fixed keyword token 80 with parser-context L3+ admission**, rather than an unresolved token-class ambiguity. [16 fragment-level X01 fixtures](../../examples/aui-compiler-production/x01-lexer-context-fixtures.json) are added and all **NOT-RUN**. X01 remains OPEN pending terminal-normalized Predict Sets and native lexer verification.



The [X01 token reconciliation](aui-compiler-x01-token-reconciliation.md) now binds 60 EBNF literals to proposed lexer codes/contextual Identifier matches and explicitly lists unowned numeric codes. The `settled` classification mismatch and keyword scope still need resolution. This is **review data only**, not an accepted lexer, token tests, or closed X01 gate.

## Cross-gate compiler readiness audit — 2026-11-01

[End-to-end T0–T8 audit](aui-compiler-t0-t8-readiness-audit.md) identifies **14 explicit unresolved cross-stage gaps X01–X14**, ordered into source, public trust, physical/semantic and native/release closure gates. The T0 formal EBNF and grammar checker documentation are candidate designs, not implementation. Core public exports, typed Graph linkage, native IR validators, Win64/ABI qualification and T8 runtime admission remain unverified. Isolated Assembly ABI probes are reasonable engineering experiments; **no production native compiler is ready for release**. D1–D8 remain OPEN.

## One current architectural direction

[ONE Canonical Project Graph](canonical-project-graph-and-components.md) owns typed components/ports and operation contracts, targets, graph topology, workflows and state machines, typed dataFlow policies, hardware resource claims and retired stable identities. There are **no numbered product/architecture editions**. Project revision is an edit-history counter. Historical experimental source encodings and hashes are not the active architecture.

Current proposed source schemas: [Graph](../../schemas/canonical-project-graph.schema.json), [Component Package](../../schemas/canonical-component-package.schema.json), [TypeReference](../../schemas/aui-type-reference.schema.json). [Unified sensor design example](../../examples/canonical-graph/README.md) illustrates all key domains in the same graph. Its hashes are **synthetic placeholders** and are NOT verified public exports.

## What the repository actually contains

- Architecture specifications, proposed JSON schema drafts and design/test vectors, including historical immutable fixture snapshots.
- A limited experimental Linux x86-64 Assembly JSON lexical preflight. It does **not** constitute a complete Studio JSON parser, Graph validator or working native compiler.
- AUI grammar/state/task/keyed-view/lifecycle research, Win64 ABI layout proposals, signed architecture/executable approval designs, D5 resource-budget and renderer requirements.
- Independent arithmetic/reference checks for some historical SHA-256 input projections and a partial structural/cross-reference check of the new unified example.

## Not yet implemented or demonstrated

- A complete canonical graph parser, schema+semantic validator, type resolver, workflow/dataFlow engine and hardware adapter.
- A native AUI compiler, linked component ABI, typed source-to-Graph resolver, interactive architecture map, renderer, IME/accessibility and full desktop Studio.
- Signed trustworthy code/reviewer enrollment and approval verification, actual Win64 PE/COFF operation dispatch, secure ownership/cancellation/resource teardown and reproducible signed build.
- D6 real NTFS crash-durable immutable snapshot/HEAD publication and recovery, full test framework, measured performance and released installer.

## Latest focused consistency re-audit (2026-10-31)

[Canonical Graph C9/C10](canonical-project-graph-and-components.md) now documents a complete **candidate** field-level projection and logical operation/component closure. Its [26 change/invariance/rejection cases](../../examples/canonical-graph/semantic-projection-change-matrix.json) are documentation scenarios only, without independently verified hash goldens. Historical D6 hash domains are not authoritative for the unified graph.

The [canonical graph consistency audit](canonical-graph-consistency-audit.md) now records nine specific repaired documentation defects (R-01–R-09) and nine cross-gate remaining design/proof gaps. Missing `example.sensor/app` export was added to the [unified sensor package](../../examples/canonical-graph/sensor-package.auipkg.json). A limited independent schema-keyword and graph-reference inspection reported zero **structural** discrepancies in the updated canonical sensor graph/package; [35 negative cases](../../examples/canonical-graph/negative-cases.json) remain **design-only, NOT-RUN**. This did **not** validate package hashes, signature trust, native binaries, hardware, a Draft 2020-12-complete validator or crash durability.

Current priority: approve one complete field-level graph projection and operation/type export closure; finalize source→Graph binding, target-qualified ABI/resource safety, D6 durable snapshot and D3/D5 lifecycle; then seek explicit human D1–D8 architecture acceptance. No product implementation has been authorized by the audit.

## Core registry and operation export closure follow-up (2026-10-31)

[Current D3 core inventory](../../examples/canonical-graph/core-registry-candidate.json) proposes **15** types, including `Bytes` and `F64` absent from the historical 13-entry exploratory list but referenced by the sensor records. [D3 CR11](d3-core-registry-value-contract.md) documents the missing portability/error contracts; [Canonical Graph C12](canonical-project-graph-and-components.md) maps authored commands to derived operation/component public projections. [26 operation review cases](../../examples/canonical-graph/operation-export-review-cases.json) remain **NOT-RUN**. A limited type inventory/port-reference check and eight structural-only operation-projection comparisons found no identified discrepancies; no verified digest, native ABI, signed trust or release artifact exists.

The `coreRegistryFingerprint`, type-export-set and component public digests in the sensor project remain deliberately **synthetic placeholders**. Missing resolved F64 semantics, closed TaskOutcome error/control types and approved executable/native layouts prevent treating the proposed registry as a verified import or authorizing execution.

## Portable values and post-dispatch uncertainty — design pass (2026-10-31)

[D3 CR12](d3-core-registry-value-contract.md) now defines a **proposed** finite-only bit-preserving F64 carrier (NaN/infinity rejected, signed zero/subnormals preserved), owned Bytes with a proposed 1 MiB first-interchange cap, and typed U32/U64/Bool rules. The [41 boundary cases](../../examples/canonical-graph/core-value-boundary-cases.json) are NOT-RUN reference expectations. A limited independent token/bit classifier matched all 41 expected accept/reject labels, but **no AELYXORA parser or ABI was exercised**.

[D3 Task T9](d3-task-result-lifecycle.md) now explicitly distinguishes never-admitted from **indeterminate-after-admission** provider failure. An indeterminate UI TaskOutcome is not a claim that an external effect failed or never ran; an old UI slot may finish while provider buffers and cleanup still require ownership. [16 lifecycle scenarios](../../examples/canonical-graph/task-outcome-lifecycle-cases.json) remain NOT-RUN. No automatic retry of externally observable effects is allowed.

**Design closure still OPEN:** human acceptance of value codecs/limits, full structured core semantic definitions and error-control public exports, independently validated hash vectors, native bit/ownership/terminal ordering, signed approval, qualified targets and D6 durable recovery. All existing Phase I/II/III/IV rules continue to apply.

## Structured core and TaskOutcome public control candidate — 2026-10-31

[CR13](d3-core-registry-value-contract.md) now specifies **three closed nested runtime control payload candidates** for `TaskOutcome` without increasing the single 15-type core registry or claiming three independent public TypeIDs. The [current inventory](../../examples/canonical-graph/core-registry-candidate.json) has machine-checkable `semanticModel` fields and all 15 `exportStatus: UNVERIFIED`; the [schema](../../schemas/canonical-core-registry-candidate.schema.json) constrains type/arity/variant/carrier shapes.

[28 control-payload shape/provenance cases](../../examples/canonical-graph/task-control-payload-cases.json) and [25 core-definition mutation cases](../../examples/canonical-graph/core-definition-review-cases.json) are future designs, **NOT-RUN**. A limited standalone JSON Schema-subset shape check matched the 28 expected shapes and 15 inventory entries; nine independent structural-skeleton comparisons matched same/different expectations. None is native type checking, cryptographic verification or proof of dispatch/quiescence.

**New explicit P0:** document `ruleId` alone cannot serve as a public digest preimage — exact normative semantic rule content must be frozen/verified first. Typed error/control payload semantics and trusted constructors require D3/D4/D5 review. All gates stay OPEN; no production registry fingerprint, real golden hash, compiled ABI, signed approval or running Studio is claimed.

## First AUI compiler architecture handoff — 2026-10-31

A concrete [first implementation specification](aui-compiler-first-implementation-contract.md) has been added for the future native Assembly compiler: capture source, strict UTF-8/lexing, bounded L0/L1 parser, symbols/imports, type/property/event/effect verification, source-only TypedHIR/plan and diagnostics. Graph linkage, native Win64 code generation, signed execution and renderer remain **separate future gates**. [First compiler fixtures](../../examples/aui-compiler-first-slice/README.md) contain 47 **NOT-RUN** acceptance expectations, a non-executable provisional type catalogue and a manually authored expected L0 source-only plan bound to the unchanged 296-byte source.

A limited independent **structural** check found the expected plan conforms to the new proposed schema subset, all twelve included source byte spans are within the reference file, and its v0/v1/v2 traversal corresponds to VStack/Text/Button. This is not evidence of a functioning AUI compiler, real typed Graph resolver, native backend or executable ABI.

**First actual development approval still OPEN:** COMP-01–05 (host/toolchain decision, lexer Unicode/profile/budgets, provisional import catalogue policy, TypedHIR/static-plan format, accessibility/event/effect checks), plus explicit human in-scope D1–D8 Phase I sign-off or reviewed bounded authorization. COMP-06–08 (verified exports/lock, source-to-Graph approvals, Win64 ABI+runtime) remain prerequisites for linked/native output. No product code was added during this documentation task.

## First AUI compiler COMP-01–05 implementation-level design (2026-10-31)

[Front-End Closure](aui-compiler-frontend-closure.md) now specifies the first Win64 Assembly source-only compiler module ownership, the **proposed** Unicode 15.1.0 XID/NFC tables, exact L0/L1 lexical/profile precedence and budgets, provisional typed catalogue, TypedHIR and static accessibility/event/effect rules. [Future implementation backlog](aui-compiler-implementation-backlog.md) breaks those contracts into named native Assembly modules with explicit failure criteria; it **does not create source code**.

The [first compiler fixture set](../../examples/aui-compiler-first-slice/README.md) now contains 47 original NOT-RUN acceptance designs, 35 additional Unicode/lexical designs, an explicitly unverified type catalogue/schema, the positive L0 manual plan and a materialized negative AUI with exact P04/U32-range diagnostic shape. A limited independent JSON Schema-keyword check found no structural discrepancies in the three example/schema pairs; the negative literal span matches the 304-byte file, and source SHA values have been independently calculated for the exact positive/negative bytes. **No AELYXORA compiler, native ABI or test runner produced those results.**

Remaining COMP-01–05 review blockers are explicit human acceptance, actual pinned Unicode 15.1.0 UCD input hashes and normalization data, installed Win64 toolchain qualification, agreed memory/diagnostic bounds and final source-only output byte conventions. COMP-06–08 still block linked/native compiler output, and Phase II implementation is **NOT AUTHORIZED**.

## Compiler readiness re-audit — 2026-10-31

The [implementation-facing COMP-01..05 audit](implementation-readiness.md) now distinguishes **P00–P06 source-only compiler design: mostly specified, NOT ACCEPTED** from **P07 Graph-linked / P08–P10 native compilation: NOT READY**. This review repaired explicit L0-vs-L1 parser admission, added real unverified catalogue-byte SHA to success/error outputs, separated `check` from `emit-plan`, and prepared a [579-byte L1 expected plan](../../examples/aui-compiler-first-slice/linked-consumer-panel-l1.source-only-plan.expected.json) in addition to L0 and invalid-U32 cases. An invalid parameter span in the new L1 fixture was found and corrected before use.

There are now **47 NOT-RUN compiler acceptance designs** plus **35 NOT-RUN Unicode/lexer cases**. A standalone limited structural check of the current L0/L1 plans and diagnostic envelope is not a compiler test. True Win64/COFF host qualification, pinned Unicode 15.1 data hashes, private Assembly module ABI/arena layout, exact output byte serialization, more runnable negative vectors and explicit human approval are still needed. No source-only/compiler code or D1–D8 approval was created.

## Full AUI compiler target clarification — 2026-10-31

The user's **product requirement is a fully functional native AUI compiler designed end-to-end in documentation before any coding**, NOT a source-only L0/L1 checker presented as finished. [ONE compiler product contract PC0–PC8](aui-compiler.md) now defines the full L0–L4 + public record/enum/service source model through symbols, exact public types/Graph binding, TypedHIR, ReactiveIR, AsyncIR, KeyedIR, OwnershipIR, target MIR, real Win64 Assembly/COFF/PE, runtime/renderer, deterministic build, testing and signed admission. The [complete compiler acceptance matrix](../../examples/aui-compiler-production/complete-compiler-acceptance.json) contains **66 proposed NOT-RUN cases** across the production pipeline. [Contract-module source](../../examples/aui-compiler-production/sensor-contract.aui) is a design example, not a trusted native service.

D3 now proposes explicit L3 `taskSlot ID: TaskSlot<T,E>;` ([ReviewPanel fixture](../../examples/aui-language/review-panel-l3.aui) updated) and a precise L2 bound `Text()` initialization/single-writer rule. [D3 full source grammar composition](aui-syntax.md), [production TypedHIR node families](aui-ast-semantic-analysis.md), [native codegen qualification](aui-targetmir-native-codegen.md), [D5 runtime service import inventory](aui-platform-runtime-services.md) and the [complete Assembly workstreams](aui-compiler-implementation-backlog.md) now share a single target. The 47 L0/L1 frontend scenarios and 35 Unicode cases remain separate **incremental engineering tests**, not release criteria.

**Current verdict: production compiler architecture substantially elaborated but NOT FROZEN / NOT ACCEPTED; no AUI compiler source implementation or real native test has been performed.** Remaining D3 language/record/enum/service rule closures, exact verified core/Graph/signatures, private IR/pass verifier definitions, D4 machine/runtime symbol ABI, D5 renderer, reproducibility/native evidence and human D1–D8 sign-off block any claim of complete compiler readiness.

## Full compiler source grammar and type rules — 2026-10-31

The [AUI Syntax owner](aui-syntax.md) now includes one proposed combined L0-L4 component grammar and separately selected record/enum/service contract units. [Full type and ownership admission](aui-types-and-ownership.md) defines profile-scoped type resolution, immutable values, pure function checks and effect/ownership rules. [36 grammar review cases](../../examples/aui-compiler-production/integrated-grammar-cases.json) are NOT-RUN, separate from the 66 full native compiler acceptance cases.

**Updated P0:** the ONE canonical package `types[]` now has a **PROPOSED additive enum variant** beside unchanged record entries. Public enum identities remain UNVERIFIED until complete semantic values, D4 tag layout, TypeReference closure, digest vectors and approval exist. Service interfaces map to verified `components[].commands`, with signed target/source/capability/effect metadata; no independent service type kind or implicit native provider is permitted. Full grammar and human sign-off remain OPEN; no parser or codegen exists.

## Public enum and service export reconciliation — 2026-10-31

The original [canonical package schema](../../schemas/canonical-component-package.schema.json) has a **proposed backward-compatible type entry discriminator**: `record/fields` or `enum/variants`. The [single Canonical Graph C10/C12](canonical-project-graph-and-components.md) now describes ordered enum logical projections and exact service interface-to-existing-component/operation mapping. [AUI Syntax](aui-syntax.md) and [Types/Ownership](aui-types-and-ownership.md) carry the same constraints. [28 additional design cases](../../examples/aui-compiler-production/public-export-closure-review-cases.json) are **NOT-RUN**, and a [zero-payload enum entry example](../../examples/aui-compiler-production/sensor-error-enum-entry.proposed.json) contains no invented digest.

A limited structural predicate accepted the 3 existing record type entries and the proposed enum entry, with 8/8 selected shape comparisons as expected. This is **not full JSON Schema, approved logical hashing, a parser or native ABI evidence**. All core types, enum codec, service package lock, digest framing and D1–D8 approval remain OPEN.

## Full compiler enum values and nested generic identity — 2026-10-31

[D3 AUI Types/Ownership](aui-types-and-ownership.md) now proposes exact enum zero/one payload constructors, pure exhaustive L2+ `matchEnum`, typed carrier/ownership, and nested generic depth <=8 / total TypeReference nodes <=128. The [single AUI Syntax owner](aui-syntax.md) admits the candidate constructor/match grammar, with existing L3 TaskOutcome match remaining distinct. [Canonical TypeReference schema](../../schemas/aui-type-reference.schema.json) now structurally admits nested generic arguments, but public traits/contract meaning and ABI are NOT verified. [D2 I9](d2-identity-and-type-resolution.md) proposes a reserved structural-identity-only `@inst` generated `exportId` separate from public type contract digest; [Canonical C9/C10](canonical-project-graph-and-components.md) now records that dependency distinction.

[36 enum/generic acceptance designs](../../examples/aui-compiler-production/enum-generic-value-cases.json) remain NOT-RUN; three negative source cases are materialized. [Three enum logical digest reference vectors](../../examples/aui-compiler-production/enum-logical-digest-reference-vectors.json) and [two generic export ID reference vectors](../../examples/aui-compiler-production/generic-export-identity-reference-vectors.json) were independently checked arithmetically against Python hashlib and OpenSSL — **not approved public digest authority**. Exact core semantic rule content, enum payload codecs/ABI, generic owner/ID namespace and public contract hash closure, native implementation and D1–D8 sign-off remain OPEN.

## D3 CR14 core semantic rule-content progress — 2026-10-31

The same [15-entry current Core Registry](../../examples/canonical-graph/core-registry-candidate.json) now contains **34 explicit candidate `semanticRules` definitions**, one for every existing `semanticModel.ruleIds` reference. [CR14](d3-core-registry-value-contract.md) requires content-bearing candidate comparison, strict ID-to-definition set equality, deterministic UTF-8 ordering, and a separate UNVERIFIED admission gate; [the existing schema](../../schemas/canonical-core-registry-candidate.schema.json) requires that field. [36 candidate semantic-content mutation scenarios](../../examples/canonical-graph/core-rule-content-review-cases.json) remain NOT-RUN. A limited independent registry check found 15 unique entries, 34 matching nonempty definitions and detected same-ID content mutation; it is **not** a full JSON Schema, approved normative semantic review, digest certification or native test.

**Remaining P0:** architect approval of every definition and unresolved typed codec/TaskOutcome proof, authentic source identities and exact public hash domain/preimage/goldens, complete dependent public types/operations/Graph closure, D4/D5/D6 target/runtime evidence and D1–D8 sign-off. All 15 exports still `UNVERIFIED`; no authoritative `coreRegistryFingerprint` or public contractDigest is emitted.

## Full production compiler public hash-chain closure candidate — 2026-10-31

[Current D2/D3/D6 public digest pipeline](d2-d6-public-contract-digest-pipeline.md) now identifies exact candidate domain-separated derived projections and trust order through core type, full 15-core fingerprint, records/enums/generics, operations, components, type-export set, unified C9 Graph, source links and native evidence. The preexisting package **exportedTypeSetDigest** and Graph **typeExportSetDigest** now have explicit DISTINCT closed derived scopes: `scope:"package"/packageId` versus `scope:"graph"/projectId`, with separately defined root and transitive closure rules, **not interchangeable**. [Six candidate derived projections](../../examples/canonical-graph/public-contract-projection-shapes-candidate.json) were structurally checked, [two scope-distinct SHA vectors](../../examples/canonical-graph/scoped-type-export-set-arithmetic-vectors.json) are **symbolic arithmetic** (fabricated a/b/c input digests), and [50 digest mutation scenarios](../../examples/canonical-graph/public-digest-pipeline-review-cases.json) remain NOT-RUN. The public type projection schema and scoped fingerprint/set schema are candidate-only; no release digest or GraphLinkedIR is trusted. Core remains 15/15 UNVERIFIED; signed source/lock, full D6 digest domains/goldens, native D4/D5 ABI and D1–D8 architect acceptance remain OPEN.

## End-to-end public digest arithmetic verification — 2026-10-31

The [single D2/D3/D6 public digest owner](d2-d6-public-contract-digest-pipeline.md) now has [15 candidate core CR14 type vectors and one complete fingerprint](../../examples/canonical-graph/core-15-content-digest-arithmetic-vectors.json), plus the [sensor arithmetic end-to-end chain](../../examples/canonical-graph/sensor-full-digest-chain-arithmetic.json): 3 records → 1 operation → 3 components → package/Graph scoped sets → full C9 candidate Graph. [Six Unicode/canonical byte vectors](../../examples/canonical-graph/d6-unicode-canonical-byte-arithmetic-vectors.json) cover canonical control/U+00E9/unordered key order boundaries. All 32 stored SHA-256 values and byte lengths rechecked, with correct derived Graph TypeReference/component links and independently Python/OpenSSL-confirmed Bool + RawSample spot checks. Original authored sensor hashes remain deliberately bogus, the entire core is 15/15 UNVERIFIED, Graph target/source signatures and native ABI/runtime tests have NOT run. **This is a validated candidate arithmetic corpus, NOT an authenticated public digest chain.** D1–D8 remain OPEN.

## Full production compiler IR handoff/ownership/machine verifier — 2026-10-31

The [one full T0–T8 IR/target pass model](aui-ir-layout.md) now defines TypedHIR, verified [GraphLinkedIR provenance](aui-ast-semantic-analysis.md), ReactiveIR/AsyncIR/KeyedIR, owned block-argument CFG, LayoutIR, qualified Win64 TargetMIR and actual native artifact/admission gates. [OwnershipIR](aui-ownership-ir.md) now includes closed instruction/terminator families, effect-token lanes, a finite worklist/dataflow meet, exactly-once resource exit and provider uncertainty cleanup. [Win64 TargetMIR](aui-targetmir-native-codegen.md) defines M0–M8 instruction selection/frame/relocation/unwind verification. [72 new IR review scenarios](../../examples/aui-compiler-production/full-ir-pass-review-cases.json) and two structural JSON review schemas plus six review envelopes are design-only; all cases NOT-RUN. T2+ cannot promote UNVERIFIED_SOURCE_ONLY into GraphLinkedIR or machine code. Exact D4/D5 runtime ABI structs/service exports, verified 15-type public contracts, native toolchain and D1–D8 architect acceptance still OPEN.

## Complete compiler internal Assembly ABI candidate — 2026-10-31

[IAI-v1 internal Assembly design](aui-compiler-internal-assembly-abi.md) now explicitly separates **compiler in-process records** from the external D4 user-component ABI. It proposes **10 exact structs (99 fields)**, arena-generation checked `Ref64`, immutable pass outputs with atomic lease publication, Win64 internal PassRequest/PassReply and **19 resource ceilings**. [Machine-readable layout](../../schemas/aui-compiler-internal-abi-layout-candidate.json), [5 Ref64 + 5 little-endian record examples](../../examples/aui-compiler-production/internal-abi-layout-byte-vectors.json) and [54 NOT-RUN review cases](../../examples/aui-compiler-production/internal-abi-and-arena-review-cases.json) are now available. Arithmetic inspection found no overlaps, alignment, field-width or packed-byte mismatch. This is NOT native layout proof: no compiler code or Assembly offset tests, no exact per-node-tag payload layouts, no verified D2/Graph source proof, no D4/D5 runtime ABI and no D1–D8 approval.

## Full compiler IR tag/payload physical contract — 2026-11-01

The [single IAI-v1 IR tag/payload owner](aui-compiler-ir-payload-contract.md) now has a **PROPOSED exhaustive numeric catalogue of 139 T1–T6 tags** across typed, Graph-linked, reactive, async, keyed, owned, layout and Win64 machine stages. The [catalog](../../schemas/aui-compiler-ir-payload-layout-candidate.json) defines **16 exact templates / 138 physical fields / 85 typed Ref64 pointees** and per-tag required/forbidden values, profile/effect/ownership requirements and candidate operand/result arity. [Catalog structural schema](../../schemas/aui-compiler-ir-payload-catalog.schema.json), [16 exact byte-placement vectors](../../examples/aui-compiler-production/ir-payload-template-byte-vectors.json) and [77 tag review cases](../../examples/aui-compiler-production/ir-tag-payload-review-cases.json) are available. Limited arithmetic checking found unique non-overlapping tag ranges and correct template offsets/packing; all scenarios NOT-RUN in any native compiler.

**Remaining P0:** approve numeric tag and per-tag semantic contract meaning, T0 lexer/CST physical memory layout, real GAS/LLVM Assembly offset tests and actual all-tag validator/lowering coverage, the 15 still-UNVERIFIED core public contracts, signed C9/operation link and D4/D5 runtime/target ABI, and human D1–D8 gates. This does not constitute implemented or approved compiler IR.

## Open critical design gates

[Canonical cross-contract audit](canonical-graph-consistency-audit.md) identifies type/export closure, full semantic hash projection (including workflows/channels/hardware/tombstones), runtime cancellation ownership, signed approval, platform ABI and durable persistence as OPEN. [Specification completion matrix](specification-completion-matrix.md) remains a detailed historical work ledger. Older numbered experimental planning documents are superseded as architecture branches; they can inform review but may not silently dictate the active model.

## Delivery discipline

1. Finish one complete architecture and obtain **explicit human acceptance** (D1–D8).
2. Implement only the approved contracts in Phase II.
3. Perform native Win64 and other qualified-target security, ABI, runtime, compiler and durability tests in Phase III, recording true observations.
4. Fix and reverify in Phase IV. Do not mark a scenario PASS from a design vector or a SHA arithmetic self-check.

Work directly on main. Preserve older immutable pure reference bytes and hashes. No GitHub Actions/CI until release preparation. The architecture remains **PROPOSED / OPEN**.
