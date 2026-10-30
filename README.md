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
