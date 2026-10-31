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

The architect has requested to **finish documentation sufficient for building an AUI compiler**, not to implement it now. [The explicit first compiler contract](aui-compiler-first-implementation-contract.md) defines a separately reviewable native Assembly P00–P06 source-only compiler, then P07 verified graph linkage and P08–P10 Win64 backend/runtime gates. Its source-only outcome is a legitimate future intermediate engineering milestone, **not** the complete project implementation or a graph-approved executable. [45 design-only first compiler scenarios](../../examples/aui-compiler-first-slice/acceptance-cases.json) and an explicit unverified [frontend catalog](../../examples/aui-compiler-first-slice/review-type-catalog.json) anchor this plan.

The earlier **G1 Graph validator + CLI round-trip** remains a required *linked/native product foundation*. It need not prevent designing and, once **explicitly approved** under Phase I rules, building a source-only AUI compiler frontend in parallel as an isolated bounded engineering slice; it **does** block any claim of P07 graph-linked/native compiler capability. No default exception to [the D1–D8 design gate](design-completion-gates.md) is inferred, and no implementation is authorized by this document.

COMP-01–05 are compiler-front-end architecture decisions; COMP-06–08 remain linked/native dependencies. Record the architect's explicit approval before entering Phase II or conducting implementation experiments.

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
