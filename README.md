# AELYXORA Studio

**Imagine. Design. Engineer.**

**AI-driven, architecture-map-centric RAD environment.** The principal workspace is a live **Project Architecture Map** inspired by mind maps and UML. Humans determine architecture; AI primarily implements and tests components. Forms, code and UI layouts are detail views of the architecture, not the product's organizing center.

## Product workflow

1. Model components, typed ports, relationships, data and responsibilities on the map.
2. Select a component or architectural subgraph and ask AI to implement it within approved contracts.
3. Review proposed changes on the map and in source diffs; accept changes explicitly.
4. Verify affected contracts and builds locally; inspect implementation and runtime behavior through the map.

**Technology direction:** own declarative UI language and Assembly-first core, LLVM/Clang assembler, target-specific platform adapters. No Qt/QML/C++/FMX in the target implementation.

**AI access goal:** user-initiated Sign in with ChatGPT and eligible ChatGPT plan usage, only through an officially supported integration and permission flow. No password/session-token scraping and no assumption that a Plus subscription provides general API access. No required API key in the intended user experience.

## Current state

Only an experimental x86-64 Linux Assembly UI-node validator exists, with a local Assembly test runner (`sh build.sh`). No architecture-map editor, graphical Studio, AI integration, renderer or release yet.

## Working documentation

- [Architecture and product invariants](docs/architecture/README.md)
- [Execution roadmap](docs/product/roadmap.md)
- [Declarative UI contract](docs/architecture/declarative-ui.md)
- [Assembly / platform contracts](docs/architecture/assembly-first.md)
- [Decision records](docs/adr/README.md)

**Documentation rule:** one source of truth for product intent, short acceptance-based roadmap, ADRs only for consequential decisions. Prefer runnable contracts and examples over speculative paperwork.

**Development policy:** no GitHub Actions / CI until release preparation; manual local checks only. Earlier C++/Qt experiments remain in Git history.
