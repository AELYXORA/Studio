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

[32 negative-case designs](../../examples/canonical-graph/negative-cases.json) enumerate expected validation, lifecycle, capability and persistence errors. They are NOT-RUN and diagnostic identifiers are proposals, not registered native engine output.

## Canonical projection ownership reconciliation — 2026-10-31

The [canonical graph owner](canonical-project-graph-and-components.md) now enumerates complete projection coverage, semantic-vs-presentation classification, deterministic ordering requirements and seven cross-contract rejection invariants. The older [Project Graph](project-graph.md) and [historical partial D2/D6 projection](d2-d6-semantic-projection.md) no longer claim competing current ownership. This is a **documentation authority correction**, not a final byte encoding, accepted hash domain, schema conformance, executable validator or test result. Canonical projection encoding and positive/negative golden vectors remain P0 OPEN.
