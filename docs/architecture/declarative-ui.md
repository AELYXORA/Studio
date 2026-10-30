# AELYXORA Declarative UI (Assembly-first)

**Status:** experimental tree/ABI validator, not yet a visual renderer.

## Intended model

Human architects declare reusable views and state flow. AI implements components under type, accessibility, layout and lifecycle contracts. Like SwiftUI, the target UI is described declaratively rather than by imperative widget construction. No claim of SwiftUI source-language compatibility.

Proposed layers:
- **Declarative UI AST:** stable node keys, containers, properties, events and reactive state.
- **Assembly UI Core:** validation, diff/reconciliation, layout and dispatch in portable ABI-constrained modules.
- **Render adapters:** OS GPU, text, input, accessibility and window backends. Platform adaptation is not portable assembly.
- **Design-time tools:** previews, inspector, diagnostics, hot reload and AI-authored component proposals.

## First executable experiment

`include/aelyxora/ui.h` defines a packed-by-layout (16-byte, naturally aligned) C ABI for four node kinds: VStack, HStack, Text, Button. `ax_ui_validate` verifies count bounds, first/root, recognized kinds, keys, parent order and leaf parent restrictions. The x86-64 Linux implementation is written in Clang-compatible GAS assembly with the System V calling convention. The C++23 equivalent is a portability/reference fallback for other platforms. Both share the same tests.

**This is not yet a UI toolkit.** It does not display pixels, implement layout, parse a DSL, handle state, process events, perform reconciliation or generate components.

## ABI and portability

Native assembler is ISA/ABI-specific. Do not compile the Linux System V implementation for Windows x64, macOS or ARM64; those need separate tested implementations or the portable reference implementation. No direct syscalls inside the core. All strings, memory ownership and API evolution must be specified before extending the ABI.

## Next steps

1. Introduce an actual declarative source format and parser with roundtrip/golden tests.
2. Add immutable tree and stable-key diff operations; validate correctness against a reference implementation.
3. Add measure/layout contracts, then a minimal rendering backend and event dispatch.
4. Produce an AArch64 Assembly implementation and test with the same fixtures.
5. Connect the UI model to component registry and controlled AI proposals, not arbitrary unvalidated code.
