# AUI Compiler and Assembly Toolchain — Design Specification

**Status: proposed design; not implemented, architect-approved or compiler-tested.** The concrete first implementation candidate is [AUI Compiler: First Implementable Architecture Contract](aui-compiler-first-implementation-contract.md): strict D3 L0/L1, native Assembly front end, proposed Windows x64 host, bounded source-only P00–P06 → separately verified graph linkage → separately admitted Win64 native backend. This document describes the **future generalized compiler**, not a competing initial pipeline or authorization to compile from unverified public exports. The [single canonical Project Graph](canonical-project-graph-and-components.md) continues to own architectural meaning.

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

## First implementation specialization (proposed)

The selected first milestone is a **real native Assembly lexer/parser/type-checking frontend** with deterministic inspectable TypedHIR, not a synthetic `llvm` prototype and not a full executable Studio. P00–P06 of [the first compiler contract](aui-compiler-first-implementation-contract.md) have explicit input/output/failure gates. The existing Linux delimiter preflight is unrelated research, not a working AUI lexer or parser.

**Native backend candidate (later P08–P10):** per-target x86-64 Assembly text + qualified COFF/PE toolchain, with target ABI and UI runtime contracts approved first. LLVM IR remains research-optional; it is not the first backend, a requirement of the first source-only compiler or a replacement for hand-authored native Assembly components. `status-panel-l0.aui` can be checked now in a future source-only tool against the [explicit provisional catalog](../../examples/aui-compiler-first-slice/review-type-catalog.json), but no actual compiled output exists and no runtime module may be linked from an unverified catalogue.

**Compiler acceptance remains separate from runtime acceptance:** source-only success is not verified graph linkage; verified graph linkage is not a signed executable; signed module identity is not live OS permission. Phase II implementation needs the [Design Gate](design-completion-gates.md) decision and [COMP-01–09 review checklist](aui-compiler-first-implementation-contract.md).

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
