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

## Proposed typed IR boundaries

The compiler must not directly turn drawing syntax into unstructured platform calls. A proposed in-memory module contains:

```text
ModuleIR
  targetIndependentTypes: TypeTable
  componentDefs: ComponentDef[]
  viewDefs: ViewDef[]
  stateSlots: StateSlot[]
  bindings: BindingEdge[]
  commands: CommandSignature[]
  capabilities: CapabilityRequirement[]
  sourceMap: SourceSpanToGraphID[]
```

Each `ComponentDef` identifies a stable type ID, semantic version, typed ports, instance identity policy, effects and ownership contracts. Each `ViewDef` declares static tree shape and dynamic collection boundaries. Each `BindingEdge` declares source, destination, conversion and scheduling semantics.

### Lowering obligations

1. All references, types, units, capabilities and effect domains validated before backend emission.
2. Pure computed expressions can be specialized; observable state remains independently addressable.
3. No hidden blocking OS or device call from render/update operations.
4. Runtime metadata emitted only when needed for dynamic bindings, debugging, accessibility or inspection.
5. Target-specific code layout, linkage, calling convention and relocation selected by target profile.
6. Generated artifacts include build identity and diagnostics linking native offsets to source and graph nodes.

### Compatibility and binary versioning

Source grammar version, graph serialization schema, IR format, component API version and runtime ABI version are **separate version domains**. Serialized IR is optional; if introduced it requires an explicit header, compatibility gate and rejection of unknown incompatible required features. An internal IR struct is not a stable ABI by default.

### Compiler acceptance matrix

- AUI view with `Text` and `Button` produces a typed graph before lowering.
- Illegal effect in `derived` fails in semantic analysis, not after linking.
- Unsupported CPU extension or execution privilege produces a target diagnostic.
- Same canonical Project Graph contracts may be lowered for x86-64 and AArch64, with different native Assembly.
- Debug source locations and architecture node references survive to generated-object diagnostics.
