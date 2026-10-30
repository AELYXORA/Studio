# AELYXORA Architecture

**Product center: Project Architecture Map.** Not a form designer, source editor, or AI chat window. A mind-map-friendly spatial overview with UML-grade typed component relations.

## Core experience

- **Map:** nodes represent components, modules, data and external systems. Typed edges represent interfaces, calls, events, data flow and dependencies. Subgraphs provide zoomable scope and architectural grouping.
- **Architect (human):** defines component boundaries, ports, contracts, responsibilities and constraints. Approves changes.
- **AI Component Engineer:** uses the selected node/subgraph and its dependencies as bounded context; proposes implementations, tests and structured edits. It cannot silently modify the architecture.
- **Evidence:** each node exposes source ownership, target support, diagnostics, build/test status and generated artifacts. Unverified is different from passing.
- **Detail editors:** declarative UI, code, properties and tests open from the selected node. They are views of the same model.

## Canonical model

```text
Project
  Modules / groups / components / instances
  Stable IDs + typed ports + properties + capabilities
  Directed typed connections (dependency, call, event, data flow)
  Contracts + revisions + ownership + verification records
  Views: architecture map | declarative UI | source | diagnostics
```

The map is a projection of the canonical graph, not an image. Visual positions and collapsible groups are presentation metadata; architecture correctness must not depend on coordinates.

## Implementation boundaries

- **Core:** own Assembly-first implementation, LLVM/Clang integrated assembler.
- **UI:** own declarative language and rendering runtime. Qt/QML, C++, FMX and Slint runtime are not target dependencies.
- **Portability:** typed contracts are CPU-neutral; machine Assembly and OS adapters are per-target.
- **AI authentication:** target official Sign in with ChatGPT / eligible subscription authorization. Do not scrape ChatGPT browser sessions, request passwords, or assume automatic API rights. Authentication capability remains unimplemented and depends on supported provider onboarding.
- **Safety:** propose → validate → preview graph/source diff → human approval → apply → local verification. AI never replaces architecture ownership.
- **Offline:** projects and architecture remain readable/editable without AI; new AI tasks require connectivity.

## Minimal end-to-end milestone

Open a local project → display a real architecture graph → edit a component contract → ask AI (when authorized) to implement that component → review graph/source changes → run local verification. The first renderable window is a technical prerequisite, not the product milestone.

## Current evidence

Only the Linux x86-64 native Assembly UI-node validator and local test harness exist. The map UI, schema, persisted project graph, renderer, AI authorization and generation are not built.

## Documentation discipline

This README is the **single source of truth** for product architecture. [Roadmap](../product/roadmap.md) defines only the next observable gates. [ADRs](../adr/README.md) record consequential decisions. Other documents are subordinate technical references; if they disagree, update or retire them, not add another speculative layer. No automatic CI before release.

Useful references: [declarative UI](declarative-ui.md), [Assembly ABI](assembly-first.md), [component contracts](component-contract.md), [runtime bindings](bindings-and-runtime.md), [source ownership](source-ownership.md), [security](extension-and-security.md).
