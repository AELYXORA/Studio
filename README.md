# AELYXORA Studio

**Project phase: documentation-first.** [Design completion gates](docs/architecture/design-completion-gates.md) control readiness before further implementation. [ChatGPT Plus integration design](docs/architecture/chatgpt-connection.md) covers eligible official sign-in and account consent; not yet implemented.

**Current implementation status:** [verified artifacts, missing components and authoritative milestones](docs/architecture/PROJECT-STATUS.md).

**Imagine. Design. Engineer.**

**Architecture-first, AI-native RAD for native systems software.** Its primary interface is an **interactive Project Architecture Map with an integrated, context-aware AI chat**. The center is neither a form designer nor a source editor: it is the live system graph. **Architecture, workflows and data flows come first; AI implements approved component contracts primarily in target-native Assembly.** Declarative AUI preview and UX are downstream projections. Humans own architectural decisions and approvals. The design goal is rapid translation from an idea to a verified native result, not manual widget-driven RAD.

## Main workspace

The architecture map occupies the main canvas. A dockable AI chat stays available beside it and receives the explicitly selected nodes, relationships, contracts and diagnostics as context. AI suggestions appear as reviewable graph/source diffs. Source, declarative UI, properties and test results are drill-down views reachable from map nodes.

## Hardware-oriented engineering

AELYXORA targets native systems software: device-facing applications, drivers, firmware-support tooling, protocols, embedded and desktop software, low-level libraries and performance-critical services. The project graph must represent CPU/ISA, OS/ABI, memory regions and ownership, interrupts, MMIO/IO, DMA, concurrency, real-time constraints, devices, buses and hardware interfaces where relevant. Unsupported target capabilities must be explicit.

**Technology direction:** own declarative UI language and Assembly-first core using Clang/LLVM assembler and per-target platform adapters. No Qt/QML/C++/FMX dependency in the target Studio implementation. A single native Assembly source is not portable between different CPU instruction sets.

## AI access

Preferred user experience: authorize ChatGPT through an officially supported provider integration, ideally with an eligible ChatGPT subscription. This is a goal, **not a working feature or a guarantee that ChatGPT Plus can be used as arbitrary API access**. No credential or browser-session scraping.

## Current status

Current repository contains architecture specifications, illustrative JSON fixtures, and an experimental Linux x86-64 Assembly JSON lexical preflight. It is not a complete JSON parser or Project Graph validator. There is no runnable AUI compiler, runtime, architecture map, chat integration, renderer or released Studio.

## Working documents

**Design-first work program (proposed for review):** [Architecture-to-Execution Contract](docs/architecture/architecture-to-execution-contract.md) and [Specification Completion Matrix](docs/architecture/specification-completion-matrix.md). Project sequence: complete/approve design -> implementation -> testing -> correction/re-verification. None of these proposed documents constitutes a design freeze.


- [Architecture — source of truth](docs/architecture/README.md)
- [Interactive map workspace](docs/architecture/workspace.md)
- [Canonical project graph](docs/architecture/project-graph.md)
- [AI engineer and ChatGPT integration](docs/architecture/ai-engineer.md)
- [Hardware and targets](docs/architecture/hardware-and-targets.md)
- [Short evidence-based roadmap](docs/product/roadmap.md)
- [Declarative UI](docs/architecture/declarative-ui.md)
- [Assembly-first toolchain](docs/architecture/assembly-first.md)

**Documentation policy:** architecture README is canonical, roadmap contains observable milestones, other documents support implementation. No GitHub Actions / CI before release preparation.

- [Complete Studio platform contract — roles, workflows, palettes, events, tasks, data flow, zero-cost goals](docs/architecture/studio-platform-contract.md)

**Architecture review status:** [D2/D6 integrated baseline review](docs/architecture/d2-d6-baseline-review.md) tracks open P0 decisions and distinguishes proposals from accepted contracts. No product implementation is authorized until the full D1–D8 design baseline is explicitly approved. All documentation changes are committed directly to main.

**Documentation-only integration fixture:** [Locked Pure Reference](examples/locked-pure-reference/README.md) demonstrates exact graph/package/lock/snapshot byte relationships with two illustrative Assembly source files. The source files are test inputs, not a Studio compiler/runtime or a verified ABI implementation. [Semantic projection contract](docs/architecture/d2-d6-semantic-projection.md) and [offline dependency resolution](docs/architecture/d6-offline-dependency-resolution.md) remain Proposed.

**D3 first-slice language proposal:** [AUI grammar L0/L1](docs/architecture/d3-first-language-profile.md), [typed property/effect rules](docs/architecture/d3-type-and-binding-profile.md), [event and command linkage](docs/architecture/d3-event-delivery-and-command-linkage.md) and [D3 open review](docs/architecture/d3-language-review.md). New design fixtures are [pure view](examples/aui-language/status-panel-l0.aui) and [typed command intent](examples/aui-language/linked-consumer-panel.aui). The project still has no finished AUI parser, renderer, linked executable or D3 native test evidence.

**D3+ documentation milestone:** [L2 reactive state](docs/architecture/d3-state-derived-binding-contract.md), [L3 typed Task/Result](docs/architecture/d3-task-result-lifecycle.md) and [source/Graph/snapshot reconciliation](docs/architecture/d3-source-snapshot-reconciliation.md), with [L2/L3 examples](examples/aui-language/D3PLUS-README.md). L0/L1 language remains unchanged. These are unaccepted design proposals; no Studio parser, AUI native runtime, approval validator, target ABI or executable integration test was added.

**D3 L4 documentation proposal:** [Keyed Dynamic Views](docs/architecture/d3-keyed-dynamic-view-lifecycle.md), [D3/D4/D5 lifecycle review](docs/architecture/d3-d4-d5-lifecycle-consistency-review.md) and [keyed source/trace examples](examples/aui-language/L4-README.md). Reorder preserves compatible live view identity; remove/reinsert or change parent mounts a new incarnation. The reference-model fixture is not an AELYXORA runtime test. No product implementation or accepted architecture gate follows from this specification.

**D3 L4 advanced UI proposal:** [Keyed Dynamic Views](docs/architecture/d3-keyed-dynamic-view-lifecycle.md), [D3/D4/D5 lifecycle review](docs/architecture/d3-d4-d5-lifecycle-consistency-review.md), and [keyed source/trace fixtures](examples/aui-language/L4-README.md). Same-parent reorder retains compatible identity; deletion or reinsertion gets a new incarnation. These are unaccepted specifications, not working AUI runtime tests.

**D3/D4/D5 core and bounded UI proposal:** [Core Types](docs/architecture/d3-core-registry-value-contract.md), [Native Value ABI](docs/architecture/d4-core-value-abi-contract.md), [UI Resource Budget](docs/architecture/d5-ui-resource-budget-and-publication.md), [cross-owner review](docs/architecture/d3-d4-d5-core-contract-review.md). Proposed [registry inventory](examples/aui-language/d3-core-registry-proposal.json), [StableKey byte vectors](examples/aui-language/d3-core-value-vectors.json) and [budget arithmetic vectors](examples/aui-language/d5-budget-reference-vectors.json) are not native runtime/ABI results. D1–D8 remain unaccepted, Stage I documentation only.
