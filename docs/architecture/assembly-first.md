# Assembly-first AELYXORA

**Active direction:** build our own declarative UI language and native Assembly runtime. **No Qt, QML, FMX or C++ in the active Studio implementation.**

Human engineers own architecture, contracts and verification requirements. AI mainly implements low-level components under those contracts. LLVM/Clang is the preferred assembler toolchain, with distinct x86-64 and AArch64 implementations.

## Portability

The portable part is the component/API contract and declarative representation, **not** CPU assembly instructions. Per-target ABI, object format, linker, operating-system API and test results must be documented before declaring support.

## Current baseline

`include/aelyxora/ui.h` defines the 16-byte ABI node descriptor. `src/ui/validate_x86_64_sysv.S` validates a restricted tree. `tests/ui_abi_x86_64_sysv.S` exercises it. Run `sh build.sh` locally on Linux x86-64 with Clang.

The first real milestone is a visible native window using our own UI AST and renderer. No CI runs until release preparation.

## Risks

Text input and shaping, accessibility, input methods, GPU rendering, memory safety, platform integrations and debugging are significant development efforts. Keep platform APIs isolated. Do not claim production readiness from the validator prototype.
