# Canonical Project Graph — unified sensor example

**PROPOSAL ONLY. NOT a validated or executable project.** This illustrates the ONE AELYXORA semantic graph; it does not define product/architecture editions.

- [sensor-project.auiproj.json](sensor-project.auiproj.json): seven nodes, six edges, one complete typed state machine with cancellation, one dataFlow, retired IDs and four hardware claims (DMA, IRQ, MMIO and memory) inside the SAME Project Graph.
- [sensor-package.auipkg.json](sensor-package.auipkg.json): all three graph-referenced component declarations (`driver`, `decoder`, `app`), typed ports, commands and record representation. The referenced `src/aarch64/*.S` files are planned **unmaterialized source paths**, not executable components.

**Every 64-character hex digest inserted during this conversion is deliberately SYNTHETIC PLACEHOLDER DATA, not a computed public contract digest, approved core registry, signed operation, or package lock.** The example's hardware target is NOT certified or executable, and the package source has no qualified native ABI. Semantic verification must reject unproven type/operation/target exports and reject unapproved physical access.

The historical sensor example was read without editing. We converted its meaning-bearing workflows, dataFlow policies, resource claims and edges into one design-only graph without omitting them.

Authoritative design direction: [One Canonical Project Graph and Component Model](../../docs/architecture/canonical-project-graph-and-components.md). The JSON schemas check shape, not signer permissions, actual hardware, runtime scheduling or ABI. D1–D8 still await human approval.

[35 proposed rejection scenarios](negative-cases.json) cover type mismatches, workflow transitions, dataFlow ownership/backpressure, hardware claims, retired identity reuse and approval; they are test designs, not executed outcomes.

**Focused inspection evidence (documentation stage, 2026-10-31):** a limited independent recursive check of JSON Schema keywords (`required`, `type`, `properties`, `$ref`, `const`, `enum`, `oneOf`, `anyOf`, `allOf`, `if/then/else`, `not` and basic array/string constraints) found 0 structural errors in the project and package after the missing `app` export was added. A separate graph/package reference check found 0 component-port mirror, data-flow endpoint/binding or workflow operation lookup mismatches. This is **not** full Draft 2020-12 conformance, proof of hashes, native component resolution, qualified hardware authorization or a runnable test. All placeholder 64-hex values remain unverified.

## Current unified projection review fixtures

[Semantic Projection Change Matrix](semantic-projection-change-matrix.json) defines **26 NOT-RUN expectations**: six nonsemantic changes that preserve projected bytes, eight semantic changes that require a distinct projection after complete validation, and twelve inputs that must be rejected before an authoritative digest can exist. This matrix is a design companion to [Canonical Graph C9/C10](../../docs/architecture/canonical-project-graph-and-components.md), not an alternative schema or hash profile.

The reference package still contains only planned `src/aarch64/*.S` paths and deliberately synthetic digest placeholders. The matrix cannot be evaluated as released SHA golden vectors without real locked public exports, a frozen canonical byte encoder and independent calculations. No source code or native tests were run.

## Current core registry and operation linkage review — Phase I

The [single current core inventory proposal](core-registry-candidate.json) contains **15 logical type entries**, including `aui.core/Bytes` and `aui.core/F64` that the canonical sensor package actually references but the historical 13-entry exploratory registry omitted. Its [schema](../../schemas/canonical-core-registry-candidate.schema.json) checks documentary shape, **not** trait ownership, public contract digest, full F64 semantics or native ABI. There are still no trusted coreRegistryFingerprint, typeExportSetDigest or public component operation digests.

The [operation/export review matrix](operation-export-review-cases.json) contains **26 future NOT-RUN design cases**: six logical-invariance, eight semantic-change, twelve rejection. [Canonical C12](../../docs/architecture/canonical-project-graph-and-components.md) owns the derived operation/component contract keys. An independent limited field/identity inspection found the inventory has 15 unique correctly scoped TypeIDs, expected generic arities and all five types needed by sensor package; eight **structural-only** operation-projection mutation comparisons matched expected same/different classifications. This is **not** a runtime, compiler, native type checker or cryptographic verification.

## Portable values and asynchronous provider uncertainty

[41 portable core value boundary cases](core-value-boundary-cases.json) describe CR12's proposed finite-only F64 bit string, signed-zero/subnormal preservation, rejection of nonfinite patterns, bounded owned Bytes and exact U32/U64/Bool typed value carriers. A limited independent JavaScript token/bit classifier matched all **41** expected accept/reject categories; **AELYXORA has not executed any of these tests**. The symbolic oversize Bytes case is a future generator specification, not materialized test bytes.

[16 task outcome lifecycle cases](task-outcome-lifecycle-cases.json) cover pre-admission rejection, ambiguous provider loss after dispatch, confirmed cancellation, late completions, view-generation replacement, ownership and forbidden automatic retries. These are **NOT-RUN design expectations**, not evidence that actual provider callbacks, D4 atomics or real hardware cleanup work. [D3 Task T9](../../docs/architecture/d3-task-result-lifecycle.md) owns the proposed five-outcome/indeterminate boundary.
