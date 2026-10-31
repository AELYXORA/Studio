# Canonical Project Graph — One-Architecture Consistency Audit

**Status: PROPOSED design review. No architect approval, executable compiler, signed module, real device access or native test.** Owner: [One Canonical Project Graph](canonical-project-graph-and-components.md). Schemas: [Graph](../../schemas/canonical-project-graph.schema.json), [Component Package](../../schemas/canonical-component-package.schema.json), [TypeReference](../../schemas/aui-type-reference.schema.json).

## Decision

ONE Project Graph is the product's sole semantic architecture. There is no feature-based numbered graph family. Historical experimental documents and frozen SHA fixtures are retained as provenance only and cannot override the unified contract. A project revision counts edits, not product architecture editions.

## Cross-owner verification matrix

| Area | Unified requirement | Blocking proof |
| --- | --- | --- |
| Typed component | Exact package owner, operation contract and typed port mirrors | Verified public export closure, native binding |
| Generic type | Full owner, template, ordered argument contracts and digest | Acyclic generic resolver, canonical bytes |
| Graph topology | Stable node/edge IDs and exact type/direction constraints | Full semantic validation |
| Workflow | Explicit states, typed signals, reachability, deterministic transition and terminal-once | Real scheduler, cancellation race tests |
| DataFlow | Bind existing data edges, enforce copy/move/borrow and capacity policies | Runtime queue, Send/ownership proof |
| Hardware | Claims attached to real resource/owner nodes and edge IDs with target requirements | Qualified target adapter and live permission |
| Retired identities | Preserve no-reuse of stable IDs | Persistent tombstone closure |
| Graph revision | One CAS update to architecture, independent of runtime state | D6 immutable transaction and recovery |
| AUI | Typed source-to-Graph links, generation-safe events and result delivery | Compiler and D5 native runtime |
| Native ABI | Full logical type contract separate from target machine layout | Win64 PE/COFF, allocator and module verification |
| Signed review | Architecture approval distinct from executable approval and live scoped capability | Real reviewer keys, signatures and anti-replay |
| Security/persistence | No signed graph/source/receipt or device effect can be implied by schema success | Native tests, FS crash injection and human signoff |

## Proposed unified sensor reference

[One unified sensor project](../../examples/canonical-graph/sensor-project.auiproj.json) and [its illustrative typed component package](../../examples/canonical-graph/sensor-package.auipkg.json) preserve seven graph nodes, six edges, a full cancellation workflow, two dataFlow channels and DMA/IRQ/MMIO/memory declarations. Its placeholder 64-hex strings are NOT actual type/export/package SHA-256 hashes. No target adapter is qualified and no device is accessed.

A standalone **partial structural/cross-reference check** found no missing required fields, unexpected keys, mismatched constants/enums, missing workflow state/signal references or missing dataFlow edge references in this example. The checker did not implement complete JSON Schema Draft 2020-12, package exports, byte hashing, OS ABI or hardware permission validation. These remain NOT-RUN.

## Risks of retaining prior experimental documents

Historic filenames still contain obsolete exploratory labels and hash domains; deleting or silently rewriting them would damage traceability and old known-answer fixtures. Instead their architecture documents are headed HISTORICAL / SUPERSEDED. The active README and architecture navigation point only to the one unified model. Any importer must interpret historic source formats as unsupported inputs until a meaning-preserving translator with explicit reviews exists.

## Next Phase I closure, no implementation yet

1. Freeze one exhaustive canonical graph semantic projection containing workflows, channels, topology, resources, retired identities and typed exports; establish one stable public hashing input and true golden vectors.
2. Approve the canonical package export and operation digest closure; resolve typed workflow signals, generic/record owner identity, effects and target capabilities.
3. Define typed AUI link and signed review receipt against the unified graph, without self-referential snapshot digests.
4. Qualify Win64 native ABI, build/signing trust, D5 UI input/renderer/IME, D6 Windows durable filesystem and runtime ownership through later real tests.
5. Record explicit architect accept/reject/defer for all D1–D8; only then proceed to implementation.

**No architecture gate is accepted by this audit.**

[35 negative-case designs](../../examples/canonical-graph/negative-cases.json) enumerate expected validation, lifecycle, capability and persistence errors. They are NOT-RUN and diagnostic identifiers are proposals, not registered native engine output.

## Canonical projection ownership reconciliation — 2026-10-31

The [canonical graph owner](canonical-project-graph-and-components.md) now enumerates complete projection coverage, semantic-vs-presentation classification, deterministic ordering requirements and seven cross-contract rejection invariants. The older [Project Graph](project-graph.md) and [historical partial D2/D6 projection](d2-d6-semantic-projection.md) no longer claim competing current ownership. This is a **documentation authority correction**, not a final byte encoding, accepted hash domain, schema conformance, executable validator or test result. Canonical projection encoding and positive/negative golden vectors remain P0 OPEN.


## Focused D1–D8 documentation re-audit — 2026-10-31

**Scope and method:** compared the live canonical graph/package/TypeReference schemas, the unified sensor project/package, the active graph behavior and source-link contracts, and selected D1, D3, D4, D5, D6, D7 and verification/process documents. This is a focused cross-contract review, **not** a new whole-repository link count or an exhaustive formal proof. The earlier broad link counts remain historical and were not remeasured here.

### Confirmed documentation defects corrected in main

| Finding | Severity | Observed contradiction | Resolution in owning file |
| --- | --- | --- | --- |
| R-01 | P0 | Old Project Graph / behavior / hash-projection / persistence texts claimed competing semantic ownership alongside ONE graph | Restrained their scope: [one graph](canonical-project-graph-and-components.md) defines current semantics; former projections and their numbered hash domains are historical candidates |
| R-02 | P0 | [Graph↔AUI](project-graph-aui-contract.md) described TypeID without the complete current TypeReference digest and delegated identity authority to the older Project Graph | Require verified TypeReference with exact contractDigest, and bind source linking to the canonical owner |
| R-03 | P0 | [Source ownership](source-ownership.md) called view definitions “canonical” without saying that presentation/source ownership cannot redefine architecture | Separated authored source/presentation from graph authority and required reviewed reconciliation |
| R-04 | P1 | [Canonical sensor project](../../examples/canonical-graph/sensor-project.auiproj.json) referenced an `example.sensor/app` instance missing from [its package](../../examples/canonical-graph/sensor-package.auipkg.json) | Added the missing typed app export and planned source declaration. Source files and public digest verification still absent |
| R-05 | P1 | Expected error identifiers in [negative cases](../../examples/canonical-graph/negative-cases.json) disagreed with [graph behavior contract](graph-behavior-contract.md) for unresolved dispatch/edge, cross-domain borrow and structurally invalid snapshot | Aligned these expectations and added same-domain queued borrow, result-type mismatch and unverified-export rejections; now 35 **NOT-RUN** proposals |
| R-06 | P0 | Canonical operation dispatch was described as “verified” without acknowledging that the current package schema has no stored per-command digest nor an accepted digest projection | [Canonical owner](canonical-project-graph-and-components.md) now requires deriving and verifying exact operation/component exports and rejecting unproven public hashes; framing remains explicitly P0 OPEN |
| R-07 | P1 | First AUI profile, platform contract and Architecture-to-Execution summary continued to point at exploratory graph/syntax texts as current owners | Redirected authority to the single graph and bounded first AUI grammar, preserving former files as supporting research |
| R-08 | P0 | [Canonical Graph](canonical-project-graph-and-components.md) called declared project dependencies “dependency locks”, while its schema stores only packageId/version; D6 separately locks exact immutable package bytes | Explicitly separated graph requirements from D6 lockfile/object digests and rejected execution on lock mismatch |
| R-09 | P0 | [Canonical sensor package](../../examples/canonical-graph/sensor-package.auipkg.json) imports `aui.core/Bytes` and `aui.core/F64` but the exploratory [13-type inventory](../../examples/aui-language/d3-core-registry-proposal.json) does not export them | Added a single [15-entry current candidate inventory](../../examples/canonical-graph/core-registry-candidate.json), qualified missing semantics under [D3 CR11](d3-core-registry-value-contract.md), preserved all historical hashes; public registry fingerprint remains unverified |

### Targeted fixture inspection (design-only)

- A limited independent recursive check of relevant JSON Schema constructs against the [unified sensor graph](../../examples/canonical-graph/sensor-project.auiproj.json) and [package](../../examples/canonical-graph/sensor-package.auipkg.json) reported **0 shape errors**. The check supports `$ref`, `oneOf`, `anyOf`, `allOf`, `if/then/else`, `not`, required properties, constraints and ordinary recursion, but is **not** a standards-complete JSON Schema Draft 2020-12 validator.
- A separate static cross-reference inspection reported **0 missing component exports, 0 port-mirror mismatches, 0 incompatible endpoint/binding references, and 0 unresolved example workflow dispatch lookups**. Seven nodes, six edges, one workflow and two flow channels were inspected.
- These findings do **not** turn the example into a valid locked build: synthetic 64-hex placeholders, unmaterialized ASM sources, missing real package locks, unavailable qualified target adapter and unverified operation/export signatures remain **hard blockers**. No Studio engine, on-host ABI, compiler or security/runtime test ran.

### Remaining design gaps requiring decisions, not wording cleanup

| Gate | Priority | Exact unresolved boundary | Required closure evidence before D1–D8 acceptance |
| --- | --- | --- | --- |
| D2/D6 | P0 | Complete field-by-field semantic projection, normalized bytes, hash domain, order/absence handling and golden hashes are not frozen as ONE current graph profile | Approved single projection with meaningful-change/no-change tables, independent byte vectors and reject-on-unknown rules |
| D2/D3 | P0 | Verified core registry, recursive type export closure, exact operation/component digest composition and Graph/Source operation linkage are not proven | One approved type/export algorithm, target/domain/effect checks and end-to-end positive/negative source→graph vectors |
| D2/D4/D5 | P0 | Execution ownership, provider cancellation/quiescence, caller buffers, terminal-once atomics and device transfer safety lack machine-level verification | Accepted logical invariant + target-specific ABI contract + future race/fault tests |
| D2/D5 | P0 | Hardware target feature registry, qualified OS/bare-metal adapters and true privilege boundaries are not accepted | Target-qualified declaration/authorization matrix; explicit rejection when unavailable |
| D3/D5 | P0 | Full State/Derived/Bind/Task/Result/keyed view, event fairness, focus/IME/accessibility and bounded publication are proposed but unaccepted | Exact grammar/type/runtime semantics with sources, negative fixtures, budget and lifecycle acceptance matrices |
| D4/D6 | P0 | Native component layout, ABI, unsigned-vs-signed artifact chain, reviewer/key trust and replay/revocation policies remain design proposals | Verified receipt-to-module binding and documented key custody/approval policy; native proof in later phase |
| D6 | P0 | Safe package path inventory, snapshot crash atomicity, historical tombstone continuity and operation-ID replay retention are unproven | Approved durable state/HEAD/retention protocol and later filesystem fault injection |
| D7 | P0 | Official ChatGPT subscription-backed integration eligibility, auth scopes and real connected-app flow are not demonstrated | Actual provider eligibility/registration plus consent and failure-mode contract; no implicit Plus→API entitlement |
| D1/D8 | P1 | Human usability acceptance and explicit architect sign-off of the complete design baseline are absent | Single reviewed D1–D8 record, bounded exclusions and one consistent first-host/target trace |

**No new architecture edition, new branch, product code or CI is introduced by this audit.** Earlier frozen reference bytes remain unchanged. Every acceptance gate remains **OPEN** until explicitly signed off; a passed documentation checker is never native verification.


## Unified C9/C10 field-completeness pass — 2026-10-31 (Phase I only)

The [ONE Canonical Project Graph](canonical-project-graph-and-components.md) now contains a **single C9 field-level candidate projection** and **C10 logical type/operation/component closure**. [D6 byte encoding](d6-canonical-persistence.md) explicitly limits its historical `AELYXORA/semantic-graph/v1` domain to older reference fixtures. The [older partial semantic projection](d2-d6-semantic-projection.md) and [older logical export-digest proposal](d2-export-contract-identity.md) no longer claim independent current ownership. **No current canonical hash profile is accepted yet.**

A static source-schema field inventory checked every canonical Graph **top-level** authored field: `format` is transformed into the projection marker, `revision` is excluded as history metadata, and all **eleven other** authored keys are covered by C9 (including optional `resourceModel`). This is a manual/structural completeness check and does not prove nested schema completeness across later schema edits.

The [26-item semantic projection mutation matrix](../../examples/canonical-graph/semantic-projection-change-matrix.json) specifies 6 same-projection, 8 different-projection, and 12 rejection expectations. These are **NOT-RUN documentation scenarios**, and the reference graph contains synthetic public digests. An independent, **limited structural projection-skeleton** inspection of seven selected modifications matched all seven expected same/different classifications (label, revision, unordered array reorder, stream capacity, workflow mailbox capacity, retired identity, MMIO base). It **did not** resolve real public exports, calculate approved digest bytes, use an AELYXORA native validator, qualify hardware/OS permissions, or verify cryptographic golden hashes.

### Remaining C9/C10 P0 design acceptance work

1. Approve the complete logical core/type registry and real package/object lock closure; resolve nominal/generic type cycles and independently derived operation/component digest inputs.
2. Freeze the exact current domain framing, canonical byte encoder, Unicode bounds and resource/target registry semantics, with real independent positive and negative golden vectors.
3. Decide stable operation identities and effect/capability registry; verify dispatch target **ID versus triple** mapping, signal payload source and error/publication behavior.
4. Prove signed source/Graph review and D6 immutable snapshot binding without self-hash recursion; record what remains native/security testing in Phase III.
5. Confirm complete per-field coverage when schema changes; a new semantic field MUST fail closed until included in the same current projection.

**Status:** documentation proposal expanded; all D1–D8 architect sign-off gates remain OPEN. The above arithmetic/skeleton checks do not constitute compiler, ABI, runtime or hardware verification.


## D2/D3 core registry and derived operation exports — focused review, 2026-10-31

The [single current core inventory](../../examples/canonical-graph/core-registry-candidate.json) now lists **15 proposed entries**, including the missing sensor `Bytes` and `F64`, with [documentary schema](../../schemas/canonical-core-registry-candidate.schema.json). The old 13-entry draft and computed hashes remain **unchanged historical research**, not the current verified registry. [D3 CR11](d3-core-registry-value-contract.md) flags F64 bit/equality/serialization, exact bounded Bytes ownership, `TaskOutcome` control/error definitions, conditional Send traits and native ABI proof as outstanding. The active registry candidate contains **no trusted public digest**.

[Canonical Graph C12](canonical-project-graph-and-components.md) now maps actual package `commands[].id` to derived `operationId`, and requires **ordered** inputs, exact result/error TypeReference, effects, capabilities, domain, retry and target triples. Component public digests incorporate separately checked operation digests and exact typed ports, but exclude implementation source lists and qualification evidence. Native loader approval and runtime capabilities remain separate.

The [26 new operation/core review cases](../../examples/canonical-graph/operation-export-review-cases.json) consist of **6 same, 8 different and 12 reject expectations; all NOT-RUN**. A limited independent inventory check found 15 unique validly named IDs, declared generic arities, unique traits and presence of all five core types referenced in the sensor package. Eight structural-only derived-operation mutation comparisons matched their expected same/different result; these changes were **not** semantically revalidated or hashed by AELYXORA.

### Still-blocking acceptance decisions

1. Approve one **content-bound exact logical semantic definition** per current core export; `semanticSummary` text in inventory must not be quietly treated as a public hash projection.
2. Decide F64 NaN/infinity/signed-zero and portable bit/value policy, Bytes ownership/limits and the closed AdmissionError/ProviderError/CancellationConfirmation contracts, without inventing fake golden digests.
3. Approve complete typed operation/component/public export-set canonical byte inputs, unique naming, bounded generic portability and target ID vs triple mapping.
4. Compute independent real golden vectors only after a pinned verified registry and exact package lock exist, with signed review and ABI/OS tests subsequently performed in their proper phases.

**D2/D3/D4/D6 and all remaining D1–D8 gates: OPEN / NOT-RUN.** No product parser, AUI compiler, runtime, CI or signed module has been produced during this documentation work.


## CR12 and T9 detailed value/uncertainty design audit — 2026-10-31

The single active [D3 logical type owner](d3-core-registry-value-contract.md) now contains **CR12**, a proposed bounded portable typed-value layer for the existing [15-entry current core candidate](../../examples/canonical-graph/core-registry-candidate.json). This is a reviewable policy proposal, **not** an accepted core export hash, separate registry, native ABI, source-language feature or execution authorization.

### Confirmed design ambiguities resolved as explicit candidates

| Item | Before | Proposed candidate / remaining proof |
| --- | --- | --- |
| `Bytes` | Only an unbounded prose octet-sequence description | Immutable owned finite bytes, 0..1 MiB per portable value, typed lowercase hex encoding; native allocator/retain/copy/move proof still P0 |
| `F64` | NaN/infinity/signed zero/subnormal serialization and comparison undefined | Finite IEEE-754 bit patterns only; sign-zero and subnormals retained, all exponent 0x7ff rejected, typed 16-hex bit notation; no L0/L1 arithmetic, D4 floating-point/FTZ proof still P0 |
| `U32/U64/Bool` | Exact domains defined but typed JSON tokens not explicitly distinguished | U32 canonical JSON integer token, U64 unsigned decimal **string**, Bool true/false only; no floating-point coercion |
| `TaskOutcome` internal errors | Admission/Provider/Confirmation names lacked closed category boundaries | Candidate runtime-only category sets and trusted quiescence proof requirements; **no invented/verified portable public TypeReference** |
| Provider link loss | Five-case TaskOutcome left post-dispatch effect uncertainty ambiguous | [D3 Task T9](d3-task-result-lifecycle.md) distinguishes no dispatch from uncertain after admission; UI slot finality separate from ongoing native provider resource ownership; explicit no-retry without reviewed idempotency/compensation |

[41 core value boundary cases](../../examples/canonical-graph/core-value-boundary-cases.json) contain **18 proposed accept** and **23 proposed reject** expectations. A small independent JavaScript typed-token and binary64 exponent classifier matched all **41** labels; this was **not a Studio native test**. The largest Bytes case is symbolic (specified by a future generator), not 2 MiB of serialized test data in the repository. [16 task outcome/uncertainty scenarios](../../examples/canonical-graph/task-outcome-lifecycle-cases.json) are **NOT-RUN** specification cases; none was exercised by a real task runner.

### Residual design gates

1. **Human architecture acceptance** of finite-only F64, typed-hex Bytes, portability caps and exact scalar wire carriers; these candidates may be revised only with deliberate contract review.
2. Full structured core public contracts and independently calculated verified 15-type registry fingerprint, operation/component/graph hashes and reusable golden bytes. The 13-entry historical core fixture and old hash vectors must not be relabeled.
3. Complete portable public error/control exports (AdmissionError, ProviderError, CancellationConfirmation) or a reviewed alternative with the same closed semantics, with exact TaskOutcome ABI and compile-time source gating.
4. D4 proof of binary64 subnormal/zero bit preservation across target callbacks, Bytes allocation and owned transfer, provider ticket/terminal linearization; D5 bounded queue/result retention and deterministic stale-generation behavior.
5. D6 recovery of indeterminate external effects as **records**, never automatic operation replays; real filesystem and privilege tests only in their later authorized phases.

**All D1–D8 acceptance gates remain OPEN.** A source- and token-level inspection cannot prove correctness, native memory safety, actual provider cancellation, cryptographic source authenticity or target hardware permissions.


## CR13 control payload closure and immutable core semantic identity pass — 2026-10-31

**Focused scope:** reviewed [D3 Core Registry CR13](d3-core-registry-value-contract.md), [D3 Task T9/T10](d3-task-result-lifecycle.md), the one [15-type current core candidate](../../examples/canonical-graph/core-registry-candidate.json), its [structural schema](../../schemas/canonical-core-registry-candidate.schema.json), and the active [Canonical Graph](canonical-project-graph-and-components.md). This is a focused review, **not** a new whole-repository consistency count.

### Changes made in current Phase I

1. **Closed three nested TaskOutcome control values (PROPOSED):** `AdmissionError(code)` with five fixed codes; `ProviderError(phase,code)` with an allowed no-dispatch/uncertain-after-admission pair matrix; and `CancellationConfirmation(state=confirmed-quiescent)`, constructible only by trusted runtime proof. These are **not three new importable core TypeIDs**, public native handles or executable permissions.
2. **Single current core inventory augmented, not forked:** each of the 15 entries now declares a proposed `semanticModel` (category, type-parameter/variant order, carrier, ownership class, graph payload eligibility and semantic rule references) and explicitly `exportStatus: UNVERIFIED`. The JSON Schema now validates each entry's expected category/arity/variant/carrier/ownership shape with 15 type-specific constraints.
3. **Trust must be verified independently of shape:** [control payload schema](../../schemas/canonical-task-control-payload-candidate.schema.json) rejects impossible phase/code pairs and untyped fields; [28 design cases](../../examples/canonical-graph/task-control-payload-cases.json) distinguish shape validity from authenticated no-dispatch or quiescence proof.
4. **Structural change expectations:** [25 core-definition scenarios](../../examples/canonical-graph/core-definition-review-cases.json) distinguish unchanged review skeleton, semantically modified definitions and invalid unverified exports. Historical vectors remain untouched. [Canonical C10/C12](canonical-project-graph-and-components.md) now explicitly requires **immutable normative rule-content identity**, not only a mutable `ruleId` string.

### Bounded independent checks performed (NOT native verification)

A standalone limited JSON Schema-subset evaluator matched expected shapes for **28/28** payload cases and found **15/15** current inventory entries matching their type-specific structural rules, with no duplicate TypeIDs. A separate structural normalized-skeleton comparison matched **9/9** selected same/different model mutations. These checks did **not** validate all JSON Schema Draft 2020-12 behavior, type semantics, cryptographic public contracts, signer trust, native atomics, actual provider dispatch, OS capabilities or persistence.

All **28+25** proposed scenarios are `NOT-RUN` by AELYXORA. Schema-conforming user-controlled `Cancelled` remains rejected when runtime proof is untrusted. A syntactically valid `ProviderUnavailable(never-admitted)` cannot override evidence that dispatch may have occurred.

### Remaining acceptance gates (unchanged OPEN)

- Approve immutable normalized **semantic rule contents** for all 15 types and CR13 nested cases before computing trusted public contract digests and a new core registry fingerprint; rule-ID-only hashes are insufficient.
- Decide precise trusted constructor/provenance and UI/provider ticket lifecycle, bounded indeterminate retention, per-generation CAS and native memory teardown, and a typed L3 source match binding.
- Confirm final portable carrier/ownership constraints, independently computed source-locked positive/negative crypto vectors, signer/target/ABI/FS recovery contracts, and explicit architect D1–D8 sign-off.
- Preserve Phase I documentation-first policy, no feature branches, no native implementation, no CI and no invented PASS/ACCEPTED status.


## Compiler-first implementation design alignment — 2026-10-31

**Architectural scope:** AUI compiler **documentation only**, not implementation. The new [first compiler implementation contract](aui-compiler-first-implementation-contract.md) reconciles current [D3 L0/L1 grammar](d3-first-language-profile.md), [D3 type/visual/effects](d3-type-and-binding-profile.md), [AST/TypedHIR](aui-ast-semantic-analysis.md), [AUI compiler](aui-compiler.md), [target backend](aui-targetmir-native-codegen.md), [Canonical Project Graph](canonical-project-graph-and-components.md), [D6 source links](d3-source-snapshot-reconciliation.md) and [Phase I→II design rules](design-completion-gates.md).

### Confirmed first-compiler design gaps and explicit resolutions

1. **Unbounded "compiler" milestone** was previously described as one pipeline starting from untrusted source and ending in native executable without a concrete first step. P00–P06 are now an explicit proposed native Assembly frontend that can emit a deterministic **UNVERIFIED_SOURCE_ONLY** typed plan; P07 verified graph link and P08–P10 native backend remain independently gated.
2. **Architecture/source authority:** source syntax, compiler-local IDs and provisional imports cannot claim GraphNodeID/OperationID nor checked public digests. Source-only reports must not contain runtime/executable approval fields. The first [strict plan shape](../../schemas/aui-compiler-source-only-plan.schema.json) structurally enforces this separation.
3. **Missing deterministic input/output shapes and proof fixtures:** introduced a declared provisional [catalogue](../../examples/aui-compiler-first-slice/review-type-catalog.json), [expected L0 source-only output](../../examples/aui-compiler-first-slice/status-panel-l0.source-only-plan.expected.json) and [47 NOT-RUN stage/gate cases](../../examples/aui-compiler-first-slice/acceptance-cases.json) anchored to unchanged existing AUI files.
4. **Backend path ambiguity:** first compiler contract proposes an Assembly-only frontend and, **later after target qualification**, readable x86-64 Windows Assembly emitted through a Clang/LLVM-compatible COFF/PE toolchain. LLVM IR is optional research, not parallel architecture or proof of portability.
5. **Process contradiction guarded:** existing Project Graph first native validator G1 remains a *prerequisite to linked/native product compiler*, not an unqualified reason to rewrite first AUI source grammar. The current documentation-only task introduces no Phase II permission and no D1–D8 architect sign-off.

### Focused reference review, not compiler tests

A limited independent JSON-schema-keyword and source-offset check found the proposed **296-byte** unchanged [StatusPanel L0 source](../../examples/aui-language/status-panel-l0.aui) and its manually authored source-only plan consistent for **3 static Views, two accessibility labels and 12 contained source spans**; [47 case IDs](../../examples/aui-compiler-first-slice/acceptance-cases.json) are unique and every case remains **NOT-RUN**. This did not run a UTF-8 lexer, AUI parser, Unicode normalization table, type checker, native Assembly generator, Win64 renderer or signed module.

### Specific COMP gate checklist — all pending explicit approval

- **COMP-01:** first host/toolchain, native Assembly implementation, bounded staging/permission under Phase I→II rules.
- **COMP-02:** literal first-slice grammar/profile error handling, Unicode XID/NFC release, deterministic byte spans and compiler resource limits.
- **COMP-03:** source-only provisional import catalogue, untrusted plan shape and explicit no-execution contract.
- **COMP-04:** internal AST/TypedHIR, order-preserving static View identities and deterministic output byte format.
- **COMP-05:** strict builtin visual accessibility, named argument typing, local event/command effects.
- **COMP-06–08:** verified core and package export hashes, exact D2/D6 source→Graph reviewer closure, D4 Windows native ABI and D5 UI runtime/renderer; required for linked/native compiler, **not inferred from successful source-only checks**.
- **COMP-09:** real locally observed evidence and diagnostic fixture reporting after authorized implementation.

**Conclusion:** first compiler development is now *documented as a bounded staged candidate* but not yet **approved for coding**. A design fixture is not an executed test, and no partial plan hash or source-only check can authorize external effects or physical device access.


## Full native compiler product scope correction — 2026-10-31

**Architect clarified intent:** design **the entire production AUI compiler** at documentation level before writing compiler implementation. The previous L0/L1 `source-only` P00–P06 deliverable was only an engineering checkpoint, never a product compiler. [AUI compiler PC0–PC8](aui-compiler.md) now owns one complete end-to-end scope (L0–L4, public record/enum/service contract units, one Canonical Graph, types/exports, Reactive/Async/Keyed/OwnershipIR, qualified target-native Assembly/COFF/PE, linker, runtime, reproducibility, signed admission, debug and IDE integration).

Confirmed initial D3 design omissions: **L3 source mentioned a TaskSlot without declaring grammar**; [T1](d3-task-result-lifecycle.md) now proposes `taskSlot ID: TaskSlot<T,E>;`, the L3 [ReviewPanel source](../../examples/aui-language/review-panel-l3.aui) includes it, and [three additional negative mutations](../../examples/aui-language/d3plus-negative-cases.json) cover missing/mismatched/duplicate slots. **L2 `Text()` bound property initialization** previously said "may allow"; [S1](d3-state-derived-binding-contract.md) now requires exactly one matching static-key binding writer and rejects ambiguous/uninitialized sources. The existing [broader syntax owner](aui-syntax.md) now describes integrated L0–L4 profile boundaries and a specific candidate `record`/`enum`/`service` interface-only source unit, with [design fixture](../../examples/aui-compiler-production/sensor-contract.aui). [Compiler AST/IR owner](aui-ast-semantic-analysis.md), [native backend](aui-targetmir-native-codegen.md), [runtime service inventory](aui-platform-runtime-services.md) and [complete workstreams](aui-compiler-implementation-backlog.md) now refer to this same product, not parallel architectures.

**New production tests**: [66 acceptance design scenarios](../../examples/aui-compiler-production/complete-compiler-acceptance.json), all NOT-RUN, separate from 47 source-only frontend and 35 lexical scenarios. The 15-type current core exports are UNVERIFIED; exact Graph/source public hashes and signatures, full shipping grammar and public enum/service semantics, machine/renderer runtime imports, Win64 ABI/toolchain and artifact goldens remain **OPEN**. This documentation is progress on a complete target, not proof of architect-accepted or working compiler.

## Compiler first-slice consistency corrections — implementation re-audit, 2026-10-31

The [practical readiness audit](implementation-readiness.md) confirms one consistent L0/L1 compiler architecture. Explicit fixes: **L0 denies L1 declarations/event attachments at P02**, both successful source-only plan and failed captured-source diagnostic report include the **exact provisional catalog byte SHA**, `check` does not publish a successful plan while `emit-plan` does, and a fully typed [L1 source-only expected trace](../../examples/aui-compiler-first-slice/linked-consumer-panel-l1.source-only-plan.expected.json) now covers command/event/handler/visual modifiers. A detected invalid parameter source span in that manually authored L1 trace was fixed.

The current [compiler fixture inventory](../../examples/aui-compiler-first-slice/acceptance-cases.json) is **47 NOT-RUN**, including two new L0/L1 boundary checks, plus [35 Unicode/lexical NOT-RUN cases](../../examples/aui-compiler-first-slice/unicode-and-diagnostics-cases.json). These are not observed compiler test results. Remaining P0 before unconditional source-only implementation: COMP-01..05 human acceptance, real Win64 Assembly toolchain/host wrappers, pinned UCD data SHA, private compiler module layout, exact output byte format and enough materialized negative sources to test the first parser. **P07–P10 remain blocked by verified core/public exports, canonical Graph source-link trust and D4/D5 native runtime contracts.**

## First AUI compiler COMP-01–05 engineering handoff review — 2026-10-31

**Scope:** the requested compiler work in this turn remains **Phase I architecture documentation**. We reviewed the existing strict [D3 L0/L1 grammar](d3-first-language-profile.md), first [P00–P10 compiler contract](aui-compiler-first-implementation-contract.md), [AST and TypedHIR](aui-ast-semantic-analysis.md), [D3 source-only typing](d3-type-and-binding-profile.md), [local event semantics](d3-event-delivery-and-command-linkage.md) and [implementation process](design-completion-gates.md).

### Concrete clarified implementation blockers

1. **COMP-01 / host and ownership:** the [front-end closure](aui-compiler-frontend-closure.md) specifies candidate Win64 Assembly CLI, narrow OS adapter, bounded CompilationContext/arena lifecycle, pass-module data flow, no implicit network/process execution and explicit toolchain qualification. The [implementation backlog](aui-compiler-implementation-backlog.md) records future source modules and tasks, but no source was created or compiled.
2. **COMP-02 / lexical reproducibility:** proposes **Unicode 15.1.0** versioned XID_Start/XID_Continue and NFC, with pinned offline UCD files, future SHA-256 and normalization corpus; includes explicit lexical states, UTF-8/string/number failure handling and proposed 64 MiB compilation budget. No UCD tables have been independently hashed or compiled into ASM.
3. **COMP-03 / registry trust:** updated the explicit [provisional review catalogue](../../examples/aui-compiler-first-slice/review-type-catalog.json) and its [schema](../../schemas/aui-compiler-review-type-catalog.schema.json) to reject undeclared source-only exports without ever granting public type digests or execution. Both `ui` and `io-worker` command-domain atoms are syntactically recognized in L1; exact provider blocking/domain conflict remains a **P07 graph-link** diagnostic.
4. **COMP-04 / intermediate output:** a successful [source-only plan schema](../../schemas/aui-compiler-source-only-plan.schema.json) stays wholly separate from the [error report schema](../../schemas/aui-compiler-source-only-diagnostics.schema.json). A recovered syntax tree cannot produce successful TypedHIR. Child Views get local preorder IDs, and original AUI byte spans are never treated as persistent Graph IDs.
5. **COMP-05 / UI/event safety:** explicit first-slice catalog rules require one Button accessibility label, typed visual arguments and children, single activated Event<Unit> attachment, one local handler/send, no unverified effects and no accidental OS-native dispatch. UI accessibility at runtime is still D5, **not** passed by these static rules.

### Reference and check evidence (limited; all native tests NOT-RUN)

The future [47 compiler acceptance cases](../../examples/aui-compiler-first-slice/acceptance-cases.json) are augmented by [35 UTF-8/XID/NFC/number/profile examples](../../examples/aui-compiler-first-slice/unicode-and-diagnostics-cases.json), including precise raw hexadecimal byte sequences for malformed UTF-8. All cases remain explicitly **NOT-RUN** by AELYXORA.

A separate [negative materialized AUI file](../../examples/aui-compiler-first-slice/status-panel-invalid-spacing.aui) has a confirmed 304-byte source, with SHA-256 `1231502beaa755aa1dd4b235621ccf4f10e1aa03cbb72e105875f3f5eca4f96a`. Its [manual expected error report](../../examples/aui-compiler-first-slice/status-panel-invalid-spacing.diagnostics.expected.json) identifies P04 / `AUI_NUMBER_RANGE` / exact original byte span `[153,163)`. The existing positive StatusPanel source is 296 bytes with independently checked source SHA-256. A limited independent schema-subset check of the **proposed** review catalogue, successful plan and error report found no structural contradictions. No AELYXORA lexical/semantic engine, Windows compiler build, Unicode 15.1 table, signed type export or native ABI test executed.

**Remaining gate:** human acceptance of COMP-01–05, authentic Unicode 15.1 UCD input hashes/conformance, exact Win64 toolchain/SDK qualification and complete output byte conventions. COMP-06–08 (verified public registry/Graph source linkage/Win64 ABI/D5 renderer) still block graph-linked and native artifacts. All D1–D8 architect gates are OPEN and no Phase II implementation authorization is inferred.

## AUI full-compiler source grammar and public type mapping audit — 2026-10-31

**Scope:** source and public-contract design consistency only, not a running compiler or native test. The existing [AUI Syntax owner](aui-syntax.md) now contains one combined L0–L4 component source grammar, together with the separately selected contract module source grammar for record/enum/service. [Types/ownership owner](aui-types-and-ownership.md) now requires exact TypeReferences, source profile, named args, generic arity, pure-call contract and per-context ownership/effect admission. No competing Graph or new source language edition was introduced.

**Original discrepancy, now structurally addressed in the same schema:** [canonical component package schema](../../schemas/canonical-component-package.schema.json) previously had `types[].kind` fixed to `record`; it now contains a PROPOSED distinct closed `enum/variants` branch. `components[].commands[]` still requires additional domain, sideEffectClass, retryPolicy, requiredCapabilities, declaredTargets and typed outputs. Source `enum` and nonvisual `service` declarations cannot be trusted public exports, graph links or runnable native operations from their abbreviated syntax alone. The current owner must approve exact enum value/variant encoding and service-to-component/operation mapping, then include them in the existing public digest/lock/ABI chain. No default fields or sidecar service graph.

**Bounded documentation check:** 2 exact EBNF blocks within the owner (integrated + contract), **55 production definitions, zero undefined nonterminal references** under a local textual grammar-name consistency script; 36 new [grammar cases](../../examples/aui-compiler-production/integrated-grammar-cases.json) have unique IDs, all `NOT-RUN`, and every referenced base source exists in the repository. This textual check is **not** a grammar parser ambiguity, Unicode lexer, semantic type checker, native compiler or actual test; EBNF alone cannot prove runtime behavior. The escaped backtick Markdown syntax was repaired after authoring, and `.key` was added explicitly as a recognized contextual modifier.

**Remaining production P0:** architect-accepted token/reserved-name policy; source module kinds and proof of immutable public package namespace; core/record/enum/service exact type/value semantics and pure-call effects; source profile and type-export golden vectors; complete current canonical Graph closure and target-specific D4/D5 ABI; actual compiler-generated errors, native objects and full runtime evidence. D1–D8 remain OPEN. [Production compiler PC7](aui-compiler.md) still requires the 66 separate native/end-to-end design cases to be observed before product completeness.


## Enum and service public contract shape audit — 2026-10-31

The ONE [canonical package schema](../../schemas/canonical-component-package.schema.json) now accepts record or enum under the same `types[]` owner, using strict `oneOf` branches, nonempty ordered enum `variants[]`, each with `name` and optional full `typeRef`. No field/variant mixing and no `service` public type kind. The existing three record entries in the [sensor package](../../examples/canonical-graph/sensor-package.auipkg.json) remain structurally compatible. The [proposed enum fixture](../../examples/aui-compiler-production/sensor-error-enum-entry.proposed.json) carries **no fake digest**. [Canonical C10/C12](canonical-project-graph-and-components.md) now states exact enum projection fields and requires verified transitive payload TypeReference closure; service source maps to **existing** fully specified `components[].commands` (not a new service graph).

**Limited evidence only:** eight selected independent structural predicates matched expectations (record, enum, empty/mixed variant and invalid kind/null/unknown fields); every proposed [public export case](../../examples/aui-compiler-production/public-export-closure-review-cases.json), all **28**, remains NOT-RUN. The predicate does **not** implement complete JSON Schema Draft 2020-12, normalize rule content, compute public contract hashes, prove native enum tag semantics or verify a service provider.

**Remaining true blockers:** full enum value/constructor/pattern syntax, immutable public rule-content normalizations and code/ABI portability, exact command side-effect/capability/target/source verifier, independently validated hash vectors, full target toolchain and signed D1–D8 architecture acceptance. No compiler/runtime code or trusted export has been built.

