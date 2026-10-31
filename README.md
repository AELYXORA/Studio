# AELYXORA Studio

**Imagine. Design. Engineer.**

Architecture-first, AI-native RAD Studio for professional native and systems software. The primary workspace is an interactive architecture map accompanied by a context-aware AI engineering assistant. Source, declarative AUI, component properties, diagnostics and tests are projections of one underlying architecture.

## One architecture — one Project Graph

**There are no numbered product or architecture editions.** AELYXORA has exactly [ONE Canonical Project Graph](docs/architecture/canonical-project-graph-and-components.md). It includes typed components and ports, public operation contracts, workflows/state machines, typed data flows, targets, hardware resource claims, ownership and retired identities. Nothing is split into separate graph models by capability. Project revision is an edit/history counter, not an architecture edition.

[Canonical Project Graph schema](schemas/canonical-project-graph.schema.json) · [Canonical Component Package schema](schemas/canonical-component-package.schema.json) · [Canonical TypeReference schema](schemas/aui-type-reference.schema.json) · [Unified sensor reference](examples/canonical-graph/README.md)

Older experimental schemas and their digest fixtures are retained as **historical research evidence**, not as parallel product architectures or development targets. Their bytes and expected historic hashes are not rewritten. Any future import must preserve all meaning-bearing fields and obtain a fresh approved immutable snapshot.

## Engineering principles

- The architecture map is the semantic center; AI proposes reviewable changes, while humans approve decisions.
- Every component operation has explicit types, effects, capabilities, ownership and target constraints.
- Workflow transitions, data-flow channels and hardware claims exist in the same canonical graph and cannot silently disappear during conversion.
- Native implementation is Assembly-first with verified target-specific ABI and adapters; AUI is the project's own declarative language. No Qt/QML/C++ runtime dependency in the Studio core.
- Project Graph updates, running task state, renderer frames, native device effects and durable D6 snapshots have separate transaction boundaries.
- Exact source/package identity, signed review provenance, runtime capabilities, memory safety and Win64 module admission are separate security checks.
- No unapproved code execution, implicit OS privilege or unknown-source integration. No CI before release preparation.

## Status — documentation phase

**Architecture contracts are PROPOSED, not architect-approved, implemented or native-tested.** D1–D8 human review gates remain OPEN. The repository has specifications, reference JSON and a limited experimental Linux x86-64 Assembly lexical preflight, **not** a working Studio compiler, full native AUI runtime, visual architecture map, Windows ABI integration or released product.

The [unified sensor example](examples/canonical-graph/README.md) demonstrates typed components, data flow, state transitions and hardware claims in a single JSON document; its inserted digest strings are explicitly **synthetic placeholders**, not validated public hashes, verified device permissions or signed modules.

Read [Architecture](docs/architecture/README.md), [Current verified status](docs/architecture/PROJECT-STATUS.md), [Specification matrix](docs/architecture/specification-completion-matrix.md), [Design gates](docs/architecture/design-completion-gates.md), [Roadmap](docs/product/roadmap.md), [Assembly-first platform](docs/architecture/assembly-first.md) and [ChatGPT integration constraints](docs/architecture/chatgpt-connection.md).

**Workflow:** complete one coherent architecture -> explicit human review/acceptance -> implementation -> native tests/security checks -> fixes/reverification. Work directly in main. Existing frozen reference artifacts are left intact.
