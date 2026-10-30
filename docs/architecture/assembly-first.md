# Assembly-first AELYXORA

**Active direction:** build our own declarative UI language and native Assembly runtime. **No Qt, QML, FMX or C++ in the active Studio implementation.**

Human engineers own architecture, contracts and verification requirements. AI mainly implements low-level components under those contracts. LLVM/Clang is the preferred assembler toolchain, with distinct x86-64 and AArch64 implementations.

## Portability

The portable part is the component/API contract and declarative representation, **not** CPU assembly instructions. Per-target ABI, object format, linker, operating-system API and test results must be documented before declaring support.

## Current baseline

An experimental Linux x86-64 Assembly JSON lexical preflight exists at [src/bootstrap/linux-x86_64/json_preflight.S](../../src/bootstrap/linux-x86_64/json_preflight.S). It checks delimiter balance and string termination only; it does not parse JSON or validate the Project Graph. No native Studio runtime/compiler exists.

The first implementation milestone is a native Project Graph foundation. A visible native window using our own AUI AST and renderer follows after validated graph semantics. No CI runs until release preparation.

## Risks

Text input and shaping, accessibility, input methods, GPU rendering, memory safety, platform integrations and debugging are significant development efforts. Keep platform APIs isolated. Do not claim production readiness without executable end-to-end evidence.
