# ADR-0006 — Assembly-first components

**Status:** proposed

Human architects own application structure and interface contracts. AI primarily implements components. LLVM/Clang is the preferred multi-target toolchain. Native Assembly is architecture-specific, so component behavior is portable through typed contracts, verified implementations and ABI adapters, not through a single shared instruction syntax. LLVM IR is an optional low-level intermediate representation, distinct from CPU assembly.

Existing C++23 implementations stay as reference behavior until verified Assembly replacements run on x86-64 and AArch64. Qt 6.12/QML remains available for the IDE interface. Acceptance requires ABI documentation, tests, build evidence and cross-target equivalence.
