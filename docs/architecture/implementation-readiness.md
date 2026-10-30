# Architecture Freeze Readiness and Implementation Strategy

**Status: design-review decision, not an architecture freeze or implementation claim.** AELYXORA currently contains architecture documents, JSON schemas and illustrative sensor fixtures, but no executable compiler, Studio, runtime, package resolver or local build coordinator.

## Readiness decision

**Not ready for global architecture freeze. Ready for a narrowly scoped first implementation slice after explicit host selection and fixture semantics.** Keep the architecture-first Project Graph and human-approval principles stable while treating storage encoding, compiler backend, runtime ABI and platform renderer as changeable.

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

## Recommended host and first milestone

Recommend **Windows x64** as the first Studio host only as a planning choice, not an architectural dependency. The host/target distinction is mandatory: the **sensor example targets Linux AArch64**, and Windows hosting does not imply it can execute the target binary. Treat initial sensor work as structural and semantic verification. Alternate hosts remain possible with the same project and component contracts.

The first milestone is **G1: a working, locally invoked Project Graph validator and persistent CLI round-trip**, not a decorative architecture canvas and not a full AUI compiler. It must use real project/package inputs, report diagnostics and never silently mutate source. A tiny CLI is an implementation tool, not a replacement for the long-term Assembly-first AUI and native Studio design.

## Sequenced vertical slices

### S0 — executable graph foundation (first implementation)

- Confirm chosen host and implementation language/tool for a minimal validator; this bootstrap choice must be explicit and may be replaced later.
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

- Freeze only the subset required to produce the first UI: module, component, input/state, basic view calls, binding and event dispatch.
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

1. **Host choice** and acceptable temporary implementation tooling for S0.
2. **Canonical schema semantics:** duplicate-key/identifier normalization, exact type registry, dependency lock format and integrity vectors.
3. **First source grammar subset:** particularly event-to-command wiring.
4. **Safe persistent transactions:** single-file atomicity vs multi-file recovery journal, lock/revision semantics.
5. **AUI runtime bootstrapping strategy:** exact assembler/compiler path and ABI on first host.
6. **Native window/text/graphics dependencies** for S1/S2 with accessibility requirements.

Decide only those needed by the next slice. Avoid freezing speculative ABI and ARM64 device details in advance of experiments.

## Non-goals and enforcement

No generic component marketplace, multi-target claims, speculative AI login hack, full-featured renderer, OS rewrite, unnecessary prototype history, or CI. No generated source overwrite without ownership review. No production/release version labels attached to draft documents. All project changes require observable validation and transaction rules.

## Practical local acceptance record

Every local run stores: `fixtureId`, `command`, `host`, `target`, `inputDigest`, `toolDigest`, `expected`, `observed` (`pass/fail/not-run`), `diagnostics` and `limitations`. A test remains `not-run` until actually executed. **Current S0–S4 implementation gates: not-run.**

## Next concrete repository work

Implement the **S0 CLI validator** after selecting first host/tooling. Keep work on focused graph-model and validation modules, adopt the existing schemas as candidate input contracts, add negative fixtures, and perform local tests manually. Preserve clear distinction between design agreement and implemented correctness.
