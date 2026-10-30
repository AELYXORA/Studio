# AUI Compiler and Assembly Toolchain — Design Specification

**Status: proposed.** Compiler architecture is independent from specific source-language grammar and ISA.

## Pipeline

```text
AUI source + Project Graph contracts
  -> lexer/parser -> lossless syntax tree -> typed semantic AST
  -> target-independent UI/Component IR
  -> validation and effect/capability analysis
  -> optimization and specialization
  -> target module generation (LLVM IR and/or native Assembly)
  -> Clang/LLVM assembler + linker -> executable/artifacts
```

LLVM IR is a potential intermediate; **it is not portable machine Assembly**. Avoid promising a single handwritten ASM file usable across architectures. Select lowerings per target triple, OS ABI and feature set.

## Stable compiler contracts

- Separate syntactic source positions from semantic stable graph IDs.
- Deterministic module resolution; explicit import/version compatibility; no implicit network dependency.
- Validated type/effect/ownership rules before native lowering.
- UI tree static structure and binding graph can be specialized when known.
- Retain debuggable source maps from generated Assembly/object code to AUI component, graph node and source file.
- Emit readable diagnostics, target support matrix and generated-source ownership manifest.
- Incremental compilation may cache based on semantic content hashes; must not reuse artifacts across incompatible target/ABI/toolchain configurations.

## Target layer

Each target profile specifies CPU, ISA extensions, environment, endianness, pointer width, object format, calling convention, data layout, linker and runtime capabilities. Generated code respects stack alignment, callee-saved registers, unwind/debug policy, TLS and executable memory rules. Kernel/bare-metal and user-mode targets are separate profiles.

## Zero-cost objective

Eliminate avoidable dynamic allocation, boxing and dispatch on static paths. For generic components specialize only when bounded code size permits. Document tradeoff between specialization, startup size and incremental build performance. Compare the generated native implementation to a hand-written baseline under equivalent contracts. Safety checks necessary to enforce contracts are not automatically removable.

## Open decisions

Whether to implement a complete standalone compiler in Assembly immediately or bootstrap a minimal source parser/IR builder in Assembly; whether LLVM IR is authored/generated or Clang assembles native target-specific sources; long-term compiler backend ownership; ABI stable versioning; library packaging and cross-module inlining.
