# Architecture Freeze Readiness and Implementation Strategy

**Status: design-review decision, not an architecture freeze or implementation claim.** AELYXORA currently contains architecture documents, JSON schemas and illustrative sensor fixtures, but no executable compiler, Studio, runtime, package resolver or local build coordinator.

## Readiness decision

**Design-first decision supersedes the earlier recommendation to immediately implement S0.** Until design gates are accepted, prioritize complete specifications and review. See [Design Completion Gates](design-completion-gates.md).

**Not ready for global architecture freeze OR product implementation.** A narrowly scoped first implementation slice becomes eligible only AFTER the entire in-scope D1–D8 baseline is accepted by the architect, with explicit host and fixture semantics. Keep the architecture-first Project Graph and human-approval principles stable while treating storage encoding, compiler backend, runtime ABI and platform renderer as changeable.

| Area | Readiness | Evidence / blocker |
| --- | --- | --- |
| Studio purpose, architecture map + contextual AI | Design baseline | Defined user workflow, no executable UI |
| Canonical graph node/edge model | Candidate for implementation | Structural schema and sensor fixture; semantics still need executable validator |
| Package/type identity | Candidate with restrictions | Qualified type IDs drafted; lockfile hash and missing sources block real package build |
| Source ownership and revisions | Proposed | Journal/crash recovery and conflicts not validated |
| AUI surface grammar and event binding | Open | Event wiring, expressions, generic constraints not finalized |
| AST/TypedHIR/OwnershipIR | Proposed | No executable parser, type checker or borrow checker |
| TargetMIR/ABI/assembler | Proposed | Compiler and backend selection, per-target ABI verification missing |
| Native rendering and platform services | Open | First host and graphics/text/accessibility stack not selected |
| AI provider authorization | Open and optional for first slice | Do not assume Plus supplies third-party API credentials |
| Local evidence and tests | Defined methodology only | No committed executable validator, build scripts or observed native results |

## Compiler-specific readiness — narrowed but not yet accepted

The architect has requested to **finish documentation sufficient for building an AUI compiler**, not to implement it now. [The explicit first compiler contract](aui-compiler-first-implementation-contract.md) defines a separately reviewable native Assembly P00–P06 source-only compiler, then P07 verified graph linkage and P08–P10 Win64 backend/runtime gates. Its source-only outcome is a legitimate future intermediate engineering milestone, **not** the complete project implementation or a graph-approved executable. [47 design-only first compiler scenarios](../../examples/aui-compiler-first-slice/acceptance-cases.json) and an explicit unverified [frontend catalog](../../examples/aui-compiler-first-slice/review-type-catalog.json) anchor this plan.

The earlier **G1 Graph validator + CLI round-trip** remains a required *linked/native product foundation*. It need not prevent designing and, once **explicitly approved** under Phase I rules, building a source-only AUI compiler frontend in parallel as an isolated bounded engineering slice; it **does** block any claim of P07 graph-linked/native compiler capability. No default exception to [the D1–D8 design gate](design-completion-gates.md) is inferred, and no implementation is authorized by this document.

COMP-01–05 are compiler-front-end architecture decisions; COMP-06–08 remain linked/native dependencies. Record the architect's explicit approval before entering Phase II or conducting implementation experiments.

## Detailed frontend COMP candidate (still Phase I)

The [COMP-01–05 closure](aui-compiler-frontend-closure.md) has an explicit proposed Win64 Assembly CLI/module decomposition, pinned Unicode 15.1.0 input policy, 64 MiB context budget, exact source-only reference data and failed diagnostics. [Backlog](aui-compiler-implementation-backlog.md) names future AUIC implementation slices and acceptance handoff. The new [strict catalogue and diagnostics shapes](../../examples/aui-compiler-first-slice/README.md) are source-only artefacts and no real parser, compiler or toolchain qualification has been executed.

**Do not interpret this as permission to start coding.** The original D1–D8 process, explicit bounded acceptance scope and remaining COMP public core/Graph/ABI gates still control implementation and native output.

## Recommended host and first milestone

Recommend **Windows x64** as the first Studio host only as a planning choice, not an architectural dependency. The host/target distinction is mandatory: the **sensor example targets Linux AArch64**, and Windows hosting does not imply it can execute the target binary. Treat initial sensor work as structural and semantic verification. Alternate hosts remain possible with the same project and component contracts.

The first milestone is **G1: a working, locally invoked Project Graph validator and persistent CLI round-trip**, not a decorative architecture canvas and not a full AUI compiler. It must use real project/package inputs, report diagnostics and never silently mutate source. A tiny CLI is an implementation tool, not a replacement for the long-term Assembly-first AUI and native Studio design.

## Sequenced vertical slices — FUTURE PHASE II ONLY

These describe **conditional implementation order after the full in-scope D1–D8 design is accepted**. They are not instructions to implement anything during the current Phase I. Later Phase III tests and Phase IV fixes are separate.

### S0 — executable graph foundation (first implementation)

- Implement a native Assembly JSON tokenizer/parser and semantic validator. Python and other unapproved bootstrap languages are prohibited by [Implementation Language Policy](language-policy.md).
- Read project/package JSON safely with size limits, duplicate-key rejection and strict schema validation.
- Resolve stable graph, port and qualified type IDs; check endpoint existence, direction, compatibility, duplicates and target IDs.
- Round-trip persisted project and map layout separately. Validate revision conflict and no changes on rejection.
- Run six supplied invalid fixtures plus added path, duplicate export and unsupported capability fixtures; capture command, environment and pass/fail evidence.

**Exit:** local invocation validates positive sensor fixture, rejects specified invalid fixtures with stable diagnostics, and reopens identical graph identity without an AI service.

### S1 — architecture workspace

- Native window with interactive Architecture Map as the first screen and a docked **disconnected** contextual AI panel.
- Select node, inspect contracts, add typed nodes/connections, show failures and save/reopen; keyboard and basic accessibility supported.
- Use the validated graph model; visual coordinates cannot mutate semantics.

**Exit:** screen recording plus local functional results for map select/inspect, valid/invalid connections, revisioned save and reopen.

### S2 — AUI language and local build seed

- Implement only the **approved** AUI first-slice profile after D1–D8 design approval; current [L0/L1 candidate](d3-first-language-profile.md) excludes mutable state and bind. State/Derived/Bind/Task/await remain D3+ P0 and cannot be silently introduced during S2.
- Implement parser + semantic validation, then the smallest sound TypedHIR/OwnershipIR/TargetMIR path for the chosen host.
- Generate and locally assemble/link one working UI path, keeping toolchain and ABI evidence.

**Exit:** actual executable generated from the chosen AUI subset; manually tested local runtime path, no unearned cross-platform claims.

### S3 — controlled AI engineering

- Introduce structured AI proposals and an offline-capable manual proposal importer first.
- Verify scoped diff, approvals, collision detection, source ownership and tool permissions before attaching any provider.
- Add only an officially supported authorization mechanism after checking feasibility and entitlements.

**Exit:** a human-approved proposal changes a component while an unapproved/out-of-scope proposal leaves project bytes unchanged.

### S4 — real hardware and target expansion

- Select an actual target board/device, prove toolchain and AArch64 ABI, then test driver/device interactions under authorized conditions.
- Compare measurements, memory behavior and target code against equivalent native baselines.
- Expand targets only with separately recorded on-target evidence.

## Prioritized blocking decisions

1. **Host/target contract:** Linux x86-64 Assembly is available for a local bootstrap experiment; Windows x64 is a proposed Studio host and needs a separate Win64 ABI implementation.
2. **Canonical schema semantics:** duplicate-key/identifier normalization, exact type registry, dependency lock format and integrity vectors.
3. **First source grammar subset:** particularly event-to-command wiring.
4. **Safe persistent transactions:** single-file atomicity vs multi-file recovery journal, lock/revision semantics.
5. **AUI runtime bootstrapping strategy:** exact assembler/compiler path and ABI on first host.
6. **Native window/text/graphics dependencies** for S1/S2 with accessibility requirements.

Decide every material D1–D8 contract required by the complete in-scope baseline before Phase II. Bound speculative future device/ABI extensions explicitly; do not silently waive P0 design decisions in the name of a narrow slice.

## Non-goals and enforcement

No generic component marketplace, multi-target claims, speculative AI login hack, full-featured renderer, OS rewrite, unnecessary prototype history, or CI. No generated source overwrite without ownership review. No production/release version labels attached to draft documents. All project changes require observable validation and transaction rules.

## Practical local acceptance record

Every local run stores: `fixtureId`, `command`, `host`, `target`, `inputDigest`, `toolDigest`, `expected`, `observed` (`pass/fail/not-run`), `diagnostics` and `limitations`. A test remains `not-run` until actually executed. **Current S0–S4 implementation gates: not-run.** The Linux x86-64 Assembly lexical preflight has limited separate smoke observations, but does not satisfy S0.

## Next concrete repository work — CURRENT PHASE I

Continue the D1–D8 documentation closure, cross-specification contradiction audit, and architect review. **Do not implement S0, the compiler, runtime, Studio UI or tests yet.** Once the complete in-scope baseline is explicitly accepted, Phase II may start with an approved S0 native Assembly validator; the old Linux lexical preflight is not a parser. Phase III runs actual fixtures; Phase IV corrects and re-verifies. The previous instruction to implement S0 immediately is superseded by [Design Completion Gates](design-completion-gates.md).


## Compiler-readiness re-audit — 2026-10-31

**Scope:** independent implementation-facing review of the live first-compiler contracts, L0/L1 grammar, source-only catalogue, AST/TypedHIR, plan/diagnostic schemas, 47 proposed compiler acceptance scenarios, 35 Unicode boundary scenarios, L0 and L1 source fixtures, D4/Win64 build dependencies and the repository's D1–D8 process. The question is **whether an engineer can start coding the first AUI compiler without inventing architecture**; it is not a proof of finished compiler, ABI or renderer.

### Actual engineering readiness (decide per milestone, not by vague percentage)

| Milestone | Assessment | Evidence / remaining blocker |
| --- | --- | --- |
| **P00 host CLI and bounded source capture** | **Design sufficient to plan code; formal GO not yet approved** | [FC1](aui-compiler-frontend-closure.md) owns the Win64 Assembly CLI/context/OS adapter. Real installed Clang/LLVM/lld/Windows SDK identity, OS wrapper callable ABI, bounded allocation record layout and staged-output failure behavior still need native qualification |
| **P01 lexical scanner / P02 L0/L1 parser** | **Most grammar constraints defined; formal GO not yet approved** | [D3 grammar](d3-first-language-profile.md) gives full first-slice EBNF. Explicit profile gate now rejects L1 declarations/attachments in L0. [COMP-02](aui-compiler-frontend-closure.md) proposes Unicode 15.1 XID/NFC and budgets; actual versioned UCD file byte digests, normalization/test corpus and Unicode-vs-locale implementation proof are absent |
| **P03 symbols / P04 type checking** | **Provisional source-only interface defined** | [Strict review catalogue](../../examples/aui-compiler-first-slice/review-type-catalog.json) and its [schema](../../schemas/aui-compiler-review-type-catalog.schema.json) enumerate the exact local names. The source-only output now pins catalogue byte SHA `8446fb67384923b0ff4baf6c90509b34a3fd711a1880526034300f66153b22b0`; it remains **UNVERIFIED**, not an executable core-export registry |
| **P05 UI/event/effect checks** | **Static subset defined, no runtime** | View argument/child/modifier, one Button accessible label, Event<Unit> and command intent are documented; source-only does not authorize provider/OS calls. No real AUI handler execution, Windows UI Automation or effect/provider-link tests exist |
| **P06 deterministic TypedHIR + output** | **Two positive examples and one negative example, not byte-golden** | [L0 expected plan](../../examples/aui-compiler-first-slice/status-panel-l0.source-only-plan.expected.json), [L1 expected plan](../../examples/aui-compiler-first-slice/linked-consumer-panel-l1.source-only-plan.expected.json), [invalid-spacing error report](../../examples/aui-compiler-first-slice/status-panel-invalid-spacing.diagnostics.expected.json), plan/error schemas. The precise output key/escape/LF policy, source path normalization, CLI diagnostics transport and compiler internal shared arena layout need final acceptance |
| **P07 canonical Project Graph link** | **NO-GO** | Current public core/operation digests, verified package/source locks, Graph type/operation closure and signed review missing. Historical link JSON and syntactically valid 64-hex values are not proof |
| **P08–P10 native Win64 app emission / execution** | **NO-GO** | First ABI/COFF/PE module interfaces, D5 renderer/services, target privileges and actual native test evidence unaccepted. A source-only plan cannot be promoted to a signed executable |

### Verified corrections from this audit

- **R-COMP-01: L0/L1 grammar discrimination.** The shared EBNF described both profiles, but enforcement of a L0-only rejection point was not explicit enough. D3 and first-compiler contracts now require `AUI_PROFILE_UNSUPPORTED` at P02 for **any** L1 event, command, handler or Button `.on` in `--profile l0`. [Cases COMP-FX-046/047](../../examples/aui-compiler-first-slice/acceptance-cases.json) are newly added **NOT-RUN** expected checks.
- **R-COMP-02: source-only catalogue content identity.** The former plan/diagnostic shapes contained only the review catalogue path. Both now require a **real SHA-256 of its exact bytes**. The hash was calculated from the checked-in current catalogue, with an independent known 296-byte StatusPanel hash as an algorithm self-check. It **does not** verify imported public type exports.
- **R-COMP-03: unclear `check` versus `emit-plan` publication.** `check` now validates and returns a status without publishing successful TypedHIR/plan; `emit-plan` additionally writes a staged success plan after the same checks. Both use a separate failure envelope and never publish successful output on error. Diagnostic transport still awaits a final CLI review.
- **R-COMP-04: absent L1 inspectable expected plan.** Added a review-only [ConsumerPanel L1 plan](../../examples/aui-compiler-first-slice/linked-consumer-panel-l1.source-only-plan.expected.json) from the exact 579-byte AUI source, including Event<Unit>, Accept Result<Tick,Failure>, one handler, three Views, three modifiers and original source spans. Corrected a detected **invalid command-parameter span** during independent shape inspection before marking the design fixture consistent.
- **R-COMP-05: scenario inventory drift.** The current compiler-first acceptance list contains **47 unique NOT-RUN** cases (previously 45) and the separate Unicode/malformed-source list contains **35 NOT-RUN** cases. These are test designs, not observed compiler results. Many cases are mutation descriptions rather than materialized exact source/diagnostic vectors, so they are not directly executable golden tests yet.

### Prioritized work before approving first source-only implementation

**Must close before unrestricted P00–P06 coding:**

1. **Explicit architect decision** for COMP-01..05 plus in-scope D1–D8 approval or an expressly recorded narrow Phase II exception for the source-only compiler, without exempting P07/native output. No such decision has been recorded.
2. **Actual first-host toolchain evidence** (Win64 Assembly, assembler/linker, OS wrappers, allocation/cleanup, CLI invocation) and a fixed *private intra-compiler calling convention/arena record contract*, to avoid diverging module interfaces between implementation steps.
3. **Pinned Unicode 15.1 source bytes and normalization test evidence**: exact versioned `DerivedCoreProperties.txt`, `UnicodeData.txt`, `DerivedNormalizationProps.txt` or complete composition exclusions, `NormalizationTest.txt` content SHA-256 and a deterministic table-build/verification policy. The candidate UAX #31 revision 39 is indeed Unicode 15.1; cite the [official versioned specification](https://www.unicode.org/reports/tr31/tr31-39.html). Do not imply host Unicode libraries are identical to the pinned data.
4. **Output/evidence serialization freeze**, including root-relative path handling, JSON canonical key/escape/encoding/trailing LF, stable machine-readable diagnostic reports (especially before P00 source capture), error precedence, and controlled staged output. Schema-valid JSON alone is not bytewise-golden behavior.
5. **Materialize the first small mandatory acceptance set** as actual source/expected diagnostic vectors: valid L0, valid L1, missing/invalid Button label, malformed UTF-8, NFC same-scope collision, L1 syntax in L0, invalid U32 and failure/no-output publication. Keep all broader scenarios as NOT-RUN until code and fixtures exist.

**May remain open for the first *source-only* compiler** with a deliberately scoped approval: production 15-entry core public-export hashes, full canonical Graph/source-link trust, signing, Win64 application ABI, actual renderer/window, L2–L4 syntax, live provider cancellation and OS/hardware capabilities. These remain non-negotiable for P07–P10 and the complete Studio.

### Recommended minimal authorized development cut

Implement P00→P01 strict **ASCII-path lexical smoke** first, explicitly marking any unimplemented valid Unicode identifier as `UNSUPPORTED` and **not** claiming full L0/L1 conformance. Then add the pinned Unicode 15.1 tables/conformance, P02 L0 parser, L0 local types and TypedHIR, and only then the L1 event/command subset. This is a **suggested staged implementation order**, not a change to the full accepted source grammar or a de facto authorization to code.

**Final judgement:** **SOURCE-ONLY COMPILER — DESIGN MOSTLY SPECIFIED / ACCEPTANCE OPEN; GRAPH-LINKED/NATIVE COMPILER — NOT READY.** The design now provides concrete handoff inputs and diagnostic fixtures, but it is not honest to label COMP-01..05 `ACCEPTED`, Phase II `AUTHORIZED`, or any compiler fixture `PASS` without the missing human decision and actual evidence.

## Public enum/generic compiler gate (full production scope)

The full compiler language now has a **proposed** `enum` constructor and pure exhaustive match, nested generic TypeReference tree support and clear logical-versus-native variant identity. D2 proposes a deterministic generated generic instance export ID derived from identity-only structural bytes, with the **public semantic digest separate**, and 5 candidate arithmetic vectors available for independent reproduction. [36 enum and nested generic cases](../../examples/aui-compiler-production/enum-generic-value-cases.json), including 3 materialized negative sources, remain NOT-RUN.

Do **not** treat the nested TypeReference schema change as an authenticated core/export/ABI/trait approval. The 15 current core entries remain UNVERIFIED; enum payload portable codec, generic instance semantic rule digest, `@inst` namespace and public core/graph/ABI gating must be explicitly accepted before a production compiler can link or emit.

## Core semantic rule-content handoff — no false compiler readiness

[D3 CR14](d3-core-registry-value-contract.md) now supplies the **exact candidate content** of 34 previously unbound rule IDs inside the existing 15-entry core registry. It specifies deterministic content-bearing comparison and prohibits UNVERIFIED public digest emission. [36 rule mutation scenarios](../../examples/canonical-graph/core-rule-content-review-cases.json) test the planned review verifier; all NOT-RUN. This means **rule text is no longer absent**, but the actual public semantic rule validation, dependency closure, platform ABI, canonical golden bytes and signed architecture acceptance are still open. The complete compiler cannot claim D2 type/operation/Graph links or native build trust from this documentation-only work.

## Production AUI compiler readiness supersedes the partial frontend milestone — 2026-10-31

**Clarified product goal:** the complete compiler is [AUI compiler PC0–PC8](aui-compiler.md), covering full approved L0–L4, public Record/Enum/Service contract compilation, verified one-Graph source operation link, Reactive/Async/Keyed/Ownership/Target MIR, actual native Win64 COFF/PE output, D4/D5 renderer and runtime linkage and signed reproducible build admission. [Full native acceptance matrix](../../examples/aui-compiler-production/complete-compiler-acceptance.json): **66 NOT-RUN cases**. [Production fixture readme](../../examples/aui-compiler-production/README.md) keeps native acceptance separate from the first 47+35 frontend design cases.

**Full product verdict: NO-GO FOR CLAIM OF COMPLETION / FULL ARCHITECTURAL FREEZE.** Work to close before honest Phase I acceptance: one accepted composed syntax including public contract modules and pure-expression/import rules; approved complete 15-type immutable core semantics and public hashes; verified Graph/source/signed lock, cross-profile provenance; exact L2/L3/L4 node/IR verifier and D4 machine/runtime imported symbol ABI; D5 state/event/async/keyed/UI accessibility services; pinned Win64 toolchain and full deterministic verified object/link/release golden vectors. The complete product architecture has now been **mapped and its critical gaps made explicit**, but it is not all solved or approved merely because this page was written.

The previous audit of COMP-01–05 remains useful as a frontend *implementation-step* readiness report. It is NOT a production compiler readiness assessment and should never be quoted as approval of L2–L4, native codegen or application release. [Phase I→IV gates](design-completion-gates.md) continue to apply.

