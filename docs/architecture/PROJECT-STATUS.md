# AELYXORA Studio — Current Technical Status

**Authoritative status: Phase I (design), all D1–D8 architect acceptance gates OPEN.** No native product release, no approved executable ABI and no implementation of the complete Studio. This file reports evidence rather than interpreting design documents as passing tests.

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

A concrete [first implementation specification](aui-compiler-first-implementation-contract.md) has been added for the future native Assembly compiler: capture source, strict UTF-8/lexing, bounded L0/L1 parser, symbols/imports, type/property/event/effect verification, source-only TypedHIR/plan and diagnostics. Graph linkage, native Win64 code generation, signed execution and renderer remain **separate future gates**. [First compiler fixtures](../../examples/aui-compiler-first-slice/README.md) contain 45 **NOT-RUN** acceptance expectations, a non-executable provisional type catalogue and a manually authored expected L0 source-only plan bound to the unchanged 296-byte source.

A limited independent **structural** check found the expected plan conforms to the new proposed schema subset, all twelve included source byte spans are within the reference file, and its v0/v1/v2 traversal corresponds to VStack/Text/Button. This is not evidence of a functioning AUI compiler, real typed Graph resolver, native backend or executable ABI.

**First actual development approval still OPEN:** COMP-01–05 (host/toolchain decision, lexer Unicode/profile/budgets, provisional import catalogue policy, TypedHIR/static-plan format, accessibility/event/effect checks), plus explicit human in-scope D1–D8 Phase I sign-off or reviewed bounded authorization. COMP-06–08 (verified exports/lock, source-to-Graph approvals, Win64 ABI+runtime) remain prerequisites for linked/native output. No product code was added during this documentation task.

## First AUI compiler COMP-01–05 implementation-level design (2026-10-31)

[Front-End Closure](aui-compiler-frontend-closure.md) now specifies the first Win64 Assembly source-only compiler module ownership, the **proposed** Unicode 15.1.0 XID/NFC tables, exact L0/L1 lexical/profile precedence and budgets, provisional typed catalogue, TypedHIR and static accessibility/event/effect rules. [Future implementation backlog](aui-compiler-implementation-backlog.md) breaks those contracts into named native Assembly modules with explicit failure criteria; it **does not create source code**.

The [first compiler fixture set](../../examples/aui-compiler-first-slice/README.md) now contains 45 original NOT-RUN acceptance designs, 35 additional Unicode/lexical designs, an explicitly unverified type catalogue/schema, the positive L0 manual plan and a materialized negative AUI with exact P04/U32-range diagnostic shape. A limited independent JSON Schema-keyword check found no structural discrepancies in the three example/schema pairs; the negative literal span matches the 304-byte file, and source SHA values have been independently calculated for the exact positive/negative bytes. **No AELYXORA compiler, native ABI or test runner produced those results.**

Remaining COMP-01–05 review blockers are explicit human acceptance, actual pinned Unicode 15.1.0 UCD input hashes and normalization data, installed Win64 toolchain qualification, agreed memory/diagnostic bounds and final source-only output byte conventions. COMP-06–08 still block linked/native compiler output, and Phase II implementation is **NOT AUTHORIZED**.

## Open critical design gates

[Canonical cross-contract audit](canonical-graph-consistency-audit.md) identifies type/export closure, full semantic hash projection (including workflows/channels/hardware/tombstones), runtime cancellation ownership, signed approval, platform ABI and durable persistence as OPEN. [Specification completion matrix](specification-completion-matrix.md) remains a detailed historical work ledger. Older numbered experimental planning documents are superseded as architecture branches; they can inform review but may not silently dictate the active model.

## Delivery discipline

1. Finish one complete architecture and obtain **explicit human acceptance** (D1–D8).
2. Implement only the approved contracts in Phase II.
3. Perform native Win64 and other qualified-target security, ABI, runtime, compiler and durability tests in Phase III, recording true observations.
4. Fix and reverify in Phase IV. Do not mark a scenario PASS from a design vector or a SHA arithmetic self-check.

Work directly on main. Preserve older immutable pure reference bytes and hashes. No GitHub Actions/CI until release preparation. The architecture remains **PROPOSED / OPEN**.
