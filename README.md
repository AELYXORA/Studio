<p align="center"><img src="https://raw.githubusercontent.com/AELYXORA/.github/main/assets/brand/github-readme-banner-1600x500.png" alt="AELYXORA" width="100%"></p>

# AELYXORA Studio

**Imagine. Design. Engineer.**

AELYXORA Studio is an **open-source, AI-native, architecture-driven RAD environment** in the planning and foundation phase. Inspired by the visual productivity of Delphi and WinDev, it aims to combine component-based visual design with professional source-code ownership, typed application contracts and deterministic build/test verification.

> **Project status:** Architecture and documentation. There is no working IDE release yet.

## Core direction

- **Unified typed Application Model** for modules, components, properties, events, actions, data and targets.
- **Visual Designer + AI Architect + code editing** as coordinated, but not magically interchangeable, authoring workflows.
- **C++ / Qt 6.12 / QML** for the IDE and first generated desktop GUI backend, with backend-neutral application contracts.
- **Local-first, inspectable projects** built using standard toolchains and CMake.
- **AI as an optional assistant** whose changes are reviewed and independently verified.

## Read the architecture

Start at **[Architecture](docs/architecture/README.md)**, then read the [Application Model](docs/architecture/application-model.md), [Component Contract](docs/architecture/component-contract.md), [AI workflow](docs/architecture/ai-workflows.md), [ADRs](docs/adr/README.md) and [Roadmap](docs/product/roadmap.md).

## Development principle

**Design visually. Engineer precisely. Own your code.**

This repository currently captures design decisions and requirements. The roadmap describes intended capabilities rather than completed functionality.

## Headless foundation

The repository now contains an **experimental C++20 model library**, a [draft JSON Schema](schemas/project.schema.json), a [CustomerDesk fixture](examples/customerdesk/project.aelyxora.json), and [model contract tests](tests/model_tests.cpp). These are an initial prototype, **not a complete IDE**. See [Formal Schema](docs/architecture/formal-schema.md) for limitations and build instructions.
