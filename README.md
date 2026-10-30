# AELYXORA Studio

**Imagine. Design. Engineer.**

AELYXORA is an experimental, open-source, **Assembly-first declarative RAD platform**. Its UI language and runtime are developed in-house, without Qt, QML, C++ or Delphi FMX as project dependencies.

**Human architects** define system structure and component contracts. **AI** primarily implements components against those contracts. The Studio verifies and integrates their behavior.

## Current baseline

- Clang integrated assembler, Linux x86-64 System V.
- Native Assembly UI tree validation with a C-compatible ABI.
- Assembly-only test runner: `sh build.sh` (requires Clang and Linux x86-64).
- No graphical window, parser, renderer or usable IDE yet.

Native Assembly is CPU-specific. Target-neutral component contracts and separately tested platform adapters provide the portability strategy.

## Documentation

- [Architecture](docs/architecture/README.md)
- [Declarative UI](docs/architecture/declarative-ui.md)
- [Assembly-first principles](docs/architecture/assembly-first.md)
- [Roadmap](docs/product/roadmap.md)
- [ADR](docs/adr/README.md)

## Development policy

No GitHub Actions or automated CI until release preparation. Tests run locally. Previous C++/Qt experiments remain available in Git history, not in the active implementation.
