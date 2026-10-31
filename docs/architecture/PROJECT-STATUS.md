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

## Open critical design gates

[Canonical cross-contract audit](canonical-graph-consistency-audit.md) identifies type/export closure, full semantic hash projection (including workflows/channels/hardware/tombstones), runtime cancellation ownership, signed approval, platform ABI and durable persistence as OPEN. [Specification completion matrix](specification-completion-matrix.md) remains a detailed historical work ledger. Older numbered experimental planning documents are superseded as architecture branches; they can inform review but may not silently dictate the active model.

## Delivery discipline

1. Finish one complete architecture and obtain **explicit human acceptance** (D1–D8).
2. Implement only the approved contracts in Phase II.
3. Perform native Win64 and other qualified-target security, ABI, runtime, compiler and durability tests in Phase III, recording true observations.
4. Fix and reverify in Phase IV. Do not mark a scenario PASS from a design vector or a SHA arithmetic self-check.

Work directly on main. Preserve older immutable pure reference bytes and hashes. No GitHub Actions/CI until release preparation. The architecture remains **PROPOSED / OPEN**.
