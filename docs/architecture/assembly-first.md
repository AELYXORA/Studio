# Assembly-first, human-architected AELYXORA Studio

**Status:** product direction; architecture transition proposed, not implemented.

## Core operating model

- The **human is the architect**: owns application boundaries, contracts, data flows, nonfunctional requirements, decisions and acceptance criteria.
- The **AI is primarily a component implementer**: creates, adapts, documents and tests individual components under human-approved contracts. It may suggest architecture changes but cannot silently enact them.
- **AELYXORA Studio is the verifier and integrator**: validates component interfaces, source ownership, dependencies, ABI behavior, builds and target-specific tests.

## Portable Assembly strategy

No single CPU assembly instruction language runs unchanged across x86-64 and AArch64. We must separate *portable behavior and component interfaces* from *instruction-set-specific implementations*.

**Preferred toolchain:** LLVM/Clang integrated assembler and LLD where supported, with target triples and a capability matrix. Source forms:
1. Typed component contracts independent of instruction sets and OS.
2. Human-readable LLVM IR when genuinely valuable for a portable, low-level implementation. LLVM IR is not native assembly and has its own version/compatibility constraints.
3. Target-specific Assembly implementations (initial candidates x86-64 and AArch64), produced or assisted by AI and verified against shared conformance tests.
4. Small OS/ABI adaptation layers for calling conventions, object formats, syscalls, allocators, threading, exceptions and platform APIs.

Assembly-first is a **preference for implementation**, not a ban on C++, Qt/QML or platform libraries. Initial C++23 model and binding code remains a reference oracle during architecture evaluation. We should not rewrite it until an ASM proof demonstrates correctness, diagnostics, portability and maintainability.

## Portable component interface

Each component must define: stable ID/version, typed inputs and outputs, error semantics, ownership/lifetime, alignment, allocation policy, thread safety, allowed capabilities, supported targets and test fixtures. A C-compatible ABI may be used as an integration boundary; ABI details differ by OS and architecture.

## Build/test contract

Per target, verify: assembler availability; object format (ELF, COFF, Mach-O); relocation model; platform calling convention; link/runtime dependencies; deterministic behavioral tests; debugger symbols and basic safety properties. A component is **unsupported** on a target until tested there, regardless of whether Clang accepts its source.

## Architectural decisions requiring experiments

- Whether LLVM IR is authored directly, generated from structured component operations, or used only as an intermediate output.
- Which operations justify native ASM versus generated LLVM IR versus a small C++/Qt bridge.
- How generated components interact with Qt/QML and native OS controls without binding the whole model to Qt.
- The size and stability of the shared component ABI across Windows, Linux, macOS, Android and iOS.

## First engineering experiment

Specify a small versioned component (typed input, output, error and allocation contract); implement it in x86-64 and AArch64 Assembly through Clang; build/run it in native test harnesses and compare against the C++23 reference implementation. Do not declare Assembly portability proven until target-specific tests pass.
