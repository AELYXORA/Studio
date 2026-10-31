# AUI Compiler and Assembly Toolchain — Design Specification

**Status: PROPOSED COMPLETE PRODUCT COMPILER ARCHITECTURE; NOT ACCEPTED, IMPLEMENTED OR VERIFIED.** This document owns the **end-to-end AUI production compiler**. A full compiler does not end at checking L0/L1, producing TypedHIR or emitting a source-only plan: it must compile the reviewed shipping AUI language to verified target-native modules with correct linking, diagnostics, ownership, runtime integration, and reproducible build evidence. [L0/L1 first-implementation contract](aui-compiler-first-implementation-contract.md), [front-end closure](aui-compiler-frontend-closure.md) and [assembly implementation backlog](aui-compiler-implementation-backlog.md) are **engineering milestones inside this one product compiler**, never an alternate final product, a separate language, or proof that Studio can produce native applications. The [single Canonical Project Graph](canonical-project-graph-and-components.md) remains the authority for project semantics. This compiler specification makes unfinished dependencies explicit rather than claiming their acceptance.


## PC0. Definition of the complete AUI compiler (one product)

**Goal:** take one immutable, reviewed and locked AUI project + its ONE Canonical Project Graph, verified component/type packages, target/runtime/ABI declarations and compiler/toolchain identity; either **reject with stable diagnostics without changing prior trusted outputs**, or produce an **actual correctly linked, target-native application/module** and complete reproducible provenance, ready for *separate* signed admission and execution.

The compiled result is **not** an interpreter, a JSON UI plan, generated source that still requires manual implementation, a design preview or a frontend-only tokenizer. A full native backend must output actual machine-code objects, complete imports/exports, relocation/unwind/debug metadata, type/operation/graph source mappings, runtime service linkage, executable/module packages and the signed-review/admission evidence required by project policy. A static preview and compiler analysis are useful subsystems but not fulfillment of this goal.

**Planned shipping language scope:** the reviewed, integrated AUI capabilities defined by D3 **L0 (static View), L1 (event/command intent), L2 (state/derived/atomic commit/binding), L3 (async task/TaskOutcome and controlled cancellation), L4 (keyed dynamic Lists/Views)**, plus the nominal type/package/component/service declarations and pure type-directed expressions needed to make those profiles usable in real Studio applications. The [broader syntax draft](aui-syntax.md) is *not yet an accepted complete parser grammar*: general arithmetic, extra user generics, arbitrary service bodies, new control-flow, hardware access, process/network/filesystem effects and unit-bearing types must be either **specified with exact syntax/semantics and proof** before being admitted or **explicitly rejected as out-of-scope**, never silently accepted by illustrations. “Complete” means **all features in the approved shipping language work end-to-end**, not an unbounded promise to implement every speculative idea.

**First target versus full compiler:** Win64 x86-64 user mode is the first **candidate fully qualified target**. This choice is **not** a source-language restriction. The compiler architecture is target-neutral through OwnershipIR; each additional Windows/Linux/macOS/Android/iOS or embedded target needs its own explicitly approved ABI, object format, runtime adapters, signing policy, platform service capabilities and target-native conformance. An unsupported requested target always fails closed; never claim cross-platform executable support from a target-neutral TypedHIR alone.

The *compiler implementation* is Assembly-first. A qualified assembler/linker such as Clang/LLVM/lld may assemble/link target-specific generated Assembly but is **not** an AUI interpreter or a hidden alternative source compiler. LLVM IR is optional research, not a mandated second backend. No Qt/QML/C++/Python/Node.js product implementation is substituted for the selected Assembly system. Exact syntax of generated assembly and external toolchain hashes must be pinned per accepted target.

## PC1. Single authoritative compiler dependency and owner map

| Contract | Authoritative owner | Compiler obligation |
| --- | --- | --- |
| L0/L1 source grammar | [D3 first language profile](d3-first-language-profile.md) | Strict UTF-8, pinned Unicode XID/NFC, CST with byte spans, source-only profile rejection |
| Complete integrated source grammar | [AUI syntax](aui-syntax.md), with accepted extension fragments owned by [L2](d3-state-derived-binding-contract.md), [L3](d3-task-result-lifecycle.md) and [L4](d3-keyed-dynamic-view-lifecycle.md) | Freeze one non-conflicting composed grammar, token precedence, namespace/profile compatibility, nominal types and expression grammar; until then complete grammar gate OPEN |
| Types and semantics | [AUI types/ownership](aui-types-and-ownership.md), [D3 core registry](d3-core-registry-value-contract.md), [AST/TypedHIR](aui-ast-semantic-analysis.md) | Verified exact public types, generics, fields, effects, ownership and no opaque handle escapes |
| Canonical project/operation identity | [ONE Canonical Graph](canonical-project-graph-and-components.md) and [source reconciliation](d3-source-snapshot-reconciliation.md) | Full verified TypeReference/OperationID/GraphNodeID closure and signed immutable source mapping; no synthetic 64-hex digests |
| Async, state, keying | [L2](d3-state-derived-binding-contract.md), [L3](d3-task-result-lifecycle.md), [L4](d3-keyed-dynamic-view-lifecycle.md), [D2 execution](d2-execution-consistency.md) | Lower exact transaction/result/key/retention semantics and preserve required ordering |
| Target-independent lowering | [OwnershipIR](aui-ownership-ir.md), [IR/Layout](aui-ir-layout.md) | Valid ownership/move/borrow/drop, typed value lifetime, error/cleanup and target-neutral CFG |
| Native codegen and ABI | [TargetMIR](aui-targetmir-native-codegen.md), [D4 Win64 ABI](d4-win64-native-component-abi.md), [D4 module admission](d4-win64-module-trust-and-admission.md) | Instruction selection, concrete layout, COFF imports/exports, stack/unwind/debug, validated module format |
| Runtime/UI | [D5 Windows host](d5-windows-host-runtime-contract.md), [D5 resource budgets](d5-ui-resource-budget-and-publication.md), [AUI runtime](aui-runtime.md) | Validated explicit renderer/state/event/task/flow adapters; compiler cannot invent missing runtime entrypoints |
| Build/reproducibility | [D6 Win64 build](d6-win64-reproducible-build-contract.md), [D6 persistence](d6-canonical-persistence.md), [package resolver](d6-offline-dependency-resolution.md) | Pinned complete build inputs, deterministic artifact generation, immutable staging, output manifest and failure rollback |

**Authority rule:** this document owns *composition, compiler stage interface and completion criteria*; it does not redefine graph fields, D3 source syntax, type meaning, D4 binary layout or D6 canonical bytes. When an owner is incomplete, the corresponding compiler stage is **BLOCKED** pending that owner's reviewed change.

## PC2. Production pass architecture, inputs, outputs and trust

```text
Immutable snapshot / package lock / source / Graph / target
  -> Capture + integrity + offline resolve
  -> UTF-8 lexer -> lossless CST -> profile-aware complete AST
  -> declarations + import/symbol/type closure + generics
  -> type / effect / ownership / capability analysis
  -> TypedHIR (source origins, exact public types and effects)
  -> L2 state/binding dependency + atomic transaction lowering
  -> L3 async task/result/cancel/uncertainty state lowering
  -> L4 keyed dynamic-template/reconciliation lowering
  -> Canonical source/Graph/operation/resource link validation
  -> OwnershipIR / explicit move-borrow-drop-error edges
  -> optimized target-neutral Control/DataFlow IR
  -> target-qualified LayoutIR -> TargetMIR
  -> target assembly emission + object assembly
  -> link signed-review-qualified runtime/platform services
  -> inspect PE/COFF symbols, relocations, unwind and import policy
  -> deterministic manifest + immutable staged publication
  -> separately signed artifact approval -> trusted loading/runtime
```

| Stage | Mandatory compiled representation / proof | Stop condition and authority |
| --- | --- | --- |
| C00 Input | Immutable source bytes, exact SHA, target and D6 package-lock/snapshot identities, compiler/toolchain environment, selected language profile | Missing lock/verified bytes reject; loose editor files only produce expressly UNVERIFIED source-only analyses |
| C01 Parse | Token stream, lossless CST, profile-aware AST; every token retains original byte offsets and exact spelling | Invalid UTF-8, invalid escape, unknown admitted grammar, unsupported profile or parser bounds reject |
| C02 Resolve | Symbol tables, import-closure graph, normalized identifiers and source stable symbol origin proofs | Ambiguous/unknown symbol, package cycle, stale TypeReference or source hash reject |
| C03 Analyze | Complete typed/effect/capability HIR, nominal/generic instances, owned data/property/command constraints | Missing exported definitions, illegal effect or privilege, unsupported target/value layout reject |
| C04 Reactive | L2 state slots, derived DAG, single-writer bindings, atomic commit and failure/rollback semantics | Illegal cycle, unbound target, duplicate writer or stale state revision reject |
| C05 Async | L3 TaskSlot scope, command result, exact five-way TaskOutcome, transition graph, cancellation/late-completion ownership | Unclosed error type, unknown result, unproved quiescence or borrow across task await reject |
| C06 Dynamic | L4 ForEach template identity, verified List<T>/StableKey semantics, nested key path/reconcile boundaries | Non-StableKey, missing/duplicate key policy, invalid ownership or unbounded resource growth reject |
| C07 Link | Verified GraphSourceLink + exact component/OperationID/type sets, target/domain/effect/permission requirements | Any mismatch, untrusted signing/lock, synthetic digest or unauthorized native effect rejects before codegen |
| C08 Ownership/IR | Fully typed, dominator-valid CFG/SSA-or-block-arguments, explicit ownership moves and cleanup, effect ordering constraints | Unsafe borrow, use after move, missing cleanup, unavailable target service rejects |
| C09 Optimize | Proven meaning-preserving transformed IR with unchanged source/effect/control obligations | Unproven transformation rejects or falls back to unoptimized *verified* IR (never changes semantics) |
| C10 Target | Target ABI-qualified LayoutIR/TargetMIR, calling convention, stack, relocations and runtime imports | Unsupported target/ABI, unrepresentable layout, missing unwind/debug or renderer adapter rejects |
| C11 Emit/Link | Assembly, machine COFF/other accepted target object, deterministic link inputs and real native binary/module | Assembler/linker errors, undefined/duplicate symbols, wrong imports/section flags, ABI mismatch reject |
| C12 Publish | Source/Graph/type/tool/runtime dependency identities, object/executable hashes, mapping and verification manifest; separate signed admission | Incomplete evidence/signature or failed artifact verification never publishes a trusted executable |

**Stage typing:** `SourceAnalyzed` ≠ `GraphLinked` ≠ `TargetLowered` ≠ `ObjectBuilt` ≠ `ArtifactVerified` ≠ `SignedAndAdmitted`. Distinct immutable stage receipts require *proof of all predecessor gates*; one mode must not promote an earlier stage by adding a boolean to a JSON plan. The C00–C12 labels are **compiler passes**, not alternate project architectures or replacements for the narrower previously named P00–P10 milestones. A partial L0/L1 source-only compiler is a development subsystem, never the production product.

## PC3. Full language semantics and closure required before coding the finished compiler

The production compiler must **accept or reject each feature deterministically in every selected profile**, without silently dropping syntax or implementing a source-only approximation:

| Capability | Front-end and semantics | Required IR / backend consequence |
| --- | --- | --- |
| L0 | Named-arg static Text/Button/VStack/HStack, imported pure typed values, labels and modifiers | Constant/static View descriptors, strings, accessibility metadata and renderer symbols |
| L1 | Event<Unit> owner/generation, local Event, exactly typed command intent, no implicit privileged dispatch | Explicit event wiring, event queue contract, typed operation request/result failure paths |
| L2 | State/Derived/Bind, statically keyed binding targets, side-effect-free pure calls, one atomic commit | Stable StateSlot identifiers, verified reactive dependency DAG, error-safe transaction, invalidation and renderer updates |
| L3 | Exactly typed task, await/return, task slot and settled handler, five-case TaskOutcome and trust provenance | Nonblocking task state machine, captured/moved values, quiescence/cancellation, post-dispatch uncertainty, late completion cleanup |
| L4 | Immutable List<T>, nominal record fields, StableKey, nested ForEach template/parent path | Generated keyed view templates, bounds, duplicate key errors and reconciliation/lifecycle callbacks |
| Types, records, services | Nominal public record/enum definitions and closed type/generic signatures as **explicitly accepted** in the shipping profile | Exact public type export digests, param layouts, user-defined service symbol dispatch and safety validation. Their present broad source syntax is still incomplete; not release-ready |
| Targets/runtime | Declared target triple, capability/effects/operation domain, owned native adapters | Correct target ISA/ABI, import table, stack/unwind, OS UI/runtime dispatch and restricted hardware access |

**Critical currently unresolved *language* blockers** (must be closed at D3 owners before declaring full compiler source syntax frozen): L2 `Text().key(...)` and binding/property initialization interactions; L3 task slot **declaration syntax** and typed identity; L3 match binder scopes and payload types/cancel provenance; L4 `ForEach` nested grammar and List/StableKey public exports; coherent structural syntax for user records/enums/services; pure expression operators/calls and explicit effect/overload rules; complete namespace/import/profile coexistence. An illustrative extended syntax is not enough to implement a production parser.

### Complete source-type value and generic resolution update — current design pass

[One D3 source/type owner](aui-types-and-ownership.md) now proposes full enum zero/one-payload constructors, immutable typed logical values, pure exhaustive L2+ `matchEnum(value: ...)` and bounded nested generic TypeReference resolution. The [AUI combined syntax](aui-syntax.md) admits these forms within the **existing** L2–L4 language, not a second source language. [Compiler HIR](aui-ast-semantic-analysis.md) explicitly requires `EnumConstruct`, `EnumMatch` and `ResolvedGenericType` semantic nodes with exhaustive ownership/effect verification; [Win64 TargetMIR](aui-targetmir-native-codegen.md) separately requires an accepted physical variant-tag/payload layout and nested-generic ABI.

The same [canonical TypeReference schema](../../schemas/aui-type-reference.schema.json) now structurally permits generic arguments that are themselves generic. [D3 CR11/CR12](d3-core-registry-value-contract.md) constrains this to an unapproved 8-application depth/128-node tree with exact template arity, recursive traits and no unreviewed type-definition cycles. [D2 I9](d2-identity-and-type-resolution.md) proposes a separate identity-only generated `@inst` public exportId; [Canonical C10](canonical-project-graph-and-components.md) retains the **different** public semantic contractDigest. Both are still proposed and cannot be forged by source spelling.

[36 enum/generic design cases](../../examples/aui-compiler-production/enum-generic-value-cases.json) with three materialized negative AUI sources, [three enum digest arithmetic vectors](../../examples/aui-compiler-production/enum-logical-digest-reference-vectors.json) and [two generic identity vectors](../../examples/aui-compiler-production/generic-export-identity-reference-vectors.json) are available for future acceptance. All compiler cases remain NOT-RUN; verified core rule contents, signed source/Graph exports, portable enum carrier, native enum ABI and D1–D8 approval remain OPEN.

## PC4. Contract for IR, linking and lowering between modules

1. **CST and AST** contain token boundaries and recovery information. Recovered nodes are diagnostic-only. No error-containing AST may become a successful TypedHIR.
2. **TypedHIR** contains explicit resolved public TypeReferences (including generic instantiation identity), owner/symbol origin, effect/capability sets, source span, immutable declarations, view template relationships and typed binding/event/task edges. Compiler-local integer IDs are never Graph IDs.
3. **ReactiveIR** contains finite dependency vertices, update trigger, evaluation order, transaction candidate/commit/rollback edges, key-scope and old/new generation IDs. Cycles and multiple writers reject unless a separately reviewed delay/feedback contract allows them.
4. **AsyncIR** contains state-machine block labels, task slot owner/generation, caller/provider ticket distinction, result discriminant, cancellation/quiescence proof prerequisites, owned buffers and terminal/late-completion edges. No automatic retry for indeterminate physical effects.
5. **OwnershipIR** describes explicit move/borrow/copy/retain/release, ownership regions, all exceptional cleanup and cross-domain transfer. A source-level logical `Send` trait does not prove native DMA/OS memory safety.
6. **GraphLinkedIR** contains **verified** GraphNodeID, TypeReference/OperationID/source digest, package-lock/snapshot identity, target triple and exactly reviewed signer scope. Names or files alone cannot construct it. Source-only plan MUST NOT contain GraphLinkedIR.
7. **TargetMIR** contains basic blocks, typed virtual registers, liveness, calling convention/ABI mapping, target-specific memory alignment, imported/exported symbols, relocation kinds, unwind/debug origins and denied OS capability requests. Generated code cannot access unapproved OS services by inventing imported symbols.
8. Each representation is **private compiler IR** until its serialization and compatibility is explicitly accepted. In-process immutable arena handles are not stable on-disk/public ABI identities. If incremental caches serialize IR, they must bind compiler version, source/lock/core/graph, profile, target, ABI and optimization mode; cache corruption/ambiguity causes safe rebuild, not trusted execution.

Every stage has a declared verifier: SSA use-before-def/dominance where applicable, branch and variant exhaustiveness, no unresolved type, ownership/drop closure, legal effect reordering, bounded allocation, exact external symbol contracts, stable source/Graph provenance and reproducible artifacts. Lowering must be **verified after** each risk-sensitive rewrite, not merely before the first pass.

## PC5. Optimizer, codegen, linker and debugging as part of compiler correctness

- **Optimization baseline:** O0 semantics-first, no implicit optimizer required to achieve functional completeness; later O1+ only through declared pass DAG and before/after IR invariants. Eligible transformations include pure constant folding, dead pure-view branch elimination, static binding specialization and bounded inlining/monomorphization *when* source/ownership/effect provenance remains unchanged. Preserve MMIO/volatile, atomics, event FIFO, UI transactions, task terminal ordering, resource/drop timing, cancellation, errors and signal/command observable effects. If optimizer proof is absent, reject transform; do not claim zero-cost performance from documents.
- **Win64 machine backend:** select instructions/registers, spill and stack layout, canonical Win64 shadow/home space, callee-save preservation, 16-byte stack call alignment, unwind `.pdata/.xdata`, safe constant relocations, imports/exports, section permissions (W^X), CFG policy and proper PE/COFF. The D4 native ABI owner sets exact module/call descriptor bytes. Microsoft x64 calling convention is reference input, not proof AELYXORA implements it.
- **Object/link stage:** use qualified native assembler/linker with explicit target triple, input object order, fixed target/runtime libraries and import whitelist, deterministic image/PDB paths and failure diagnostics; inspect actual linked object/binary symbol + relocation + unwind tables. The compiler has to produce *actual machine-code objects* even for a pure L0 View; a JSON descriptor alone is insufficient.
- **Source-level debug experience:** preserve byte-precise source spans from original files, stable symbol/Graph origin mappings and typed diagnostic notes through target lowering and object debug info. Generated optimization must not point user diagnostics at nonexistent source regions. No dump or debug trace may leak private source, signed credentials or native memory pointers without policy.
- **Incremental build:** pure content-addressed dependency DAG of source imports, type exports, graph semantic revision, checked lock, target/runtime ABI, compiler/Unicode/toolchain, options and relevant runtime services; invalidation is conservative, caches read-only until verified, no ambient network. Deterministic clean build is the baseline; optimization/incremental performance does not override correctness.
- **Target platform matrix:** distinguish `compiler-host supported`, `cross-assembly supported`, `link supported`, `runtime qualified`, `signed-admission qualified`, `hardware capabilities approved`. Do not imply all these from one successful emitted assembly file.

## PC6. Complete user/developer-facing compiler contract

Commands are **candidate subcommands of one compiler** (not separate products). `check` parses/types without publishing; `emit-ir` emits one explicitly labeled diagnostics/debug IR only after its producing stage succeeds; `build` takes exact immutable source/Graph/lock/target and attempts a verified native build; `verify` checks an existing staged artifact against locked manifest and target/ABI contract. `run`/deploy is a **separate runtime/admission action**, not implicitly performed by build. Full build must not accept `--source-only` catalogue in place of authenticated verified exports.

Stable diagnostics include stage, code, original source byte span, profile, expected/actual type, resolved symbol and Graph origin if **verified**; machine-readable JSON and human-friendly output remain separate. CLI/IO errors before reading any source carry no fictitious source SHA. Compiler failures cannot leave a usable, partially linked binary in the authorized release output path. Error codes, exit status, maximal diagnostic count, source maps and non-UTF8 path policies require exact freeze before shipped implementation.

The Studio designer/AI may propose source edits or request compilation; neither can override graph review, typed contracts, capability restrictions, native toolchain authenticity or signing. Generated Assembly is a derivative artifact, not a replacement authority for authored declarations and the canonical Project Graph.

## PC7. Production-complete acceptance gates (one testable definition)

**A compiler is not complete when it can parse L0, produce TypedHIR, emit a COFF object, show a window, or compile one sample.** The following gates **all** must pass for the declared shipping profiles/target(s):

1. **LANGUAGE:** one approved composed grammar/profiles, Unicode/lexical tests, full nominal and generic public type resolution, valid and invalid L0–L4 plus shipping record/service fixtures, stable diagnostics, no undeclared syntax accepted.
2. **SEMANTICS:** effect, ownership, permission, reactive cycles/atomic updates, async/cancel race handling, keyed dynamic identity and resource budget checks enforced by IR verifiers.
3. **LINK:** independent verified public type/operation/component/Graph closure, offline immutable package/source lock and exact signed-review scope; failures block codegen.
4. **MACHINE:** actual Win64 (then each added declared target) machine object/executable with independently inspected imports/exports, stack, unwind, relocations, ABI call/return, runtime service linkage and source maps.
5. **END-TO-END:** authorized native application actually runs L0 static UI, L1 command/event, L2 state/bind, L3 async terminal/uncertain results and L4 stable keyed lists on qualified platform, with accessibility and rendering verification, not screenshots alone.
6. **DETERMINISM/SECURITY:** repeated clean builds on pinned inputs yield identical unsigned output, failures atomically preserve trusted outputs, no unauthorized effect or dependency download, memory/hostile-input/fuzz/privilege tests pass with observed evidence.
7. **RELEASE:** exact manifest, compilation/source/Graph/core/toolchain/target/runtime identities, genuine tests and signature/admission policy, human architect approval. Zero imaginary `PASS` statuses.

A target unsupported for any required shipping feature must be explicitly reported **unsupported**, not silently substituted with a source-only plan or runtime interpreter. Feature subsets may exist as interim development checkpoints but cannot be labeled a *full AUI compiler*.

## PC8. Real unresolved completion blockers (keep OPEN until proven)

**D3/source:** one accepted composed grammar for L0–L4; structural record/enum/service signatures and explicit import/version profile; task-slot declaration syntax and static task binder; precise allowed pure-call/constant/units operators; exhaustive generic/ownership type rules; closed L2/L3/L4 built-in APIs and per-profile test corpus.

**D2/D6:** exact core 15-type immutable semantic contents/digests (currently all UNVERIFIED), complete record/generic/operation/component exports, canonical Graph/semantic hash and signed source-review receipt, locked package/target/ABI resolution, independently calculated goldens.

**D4/compiler:** exact serialized/private intermediate record contracts or documented non-persistent compiler ABI, SSA/ownership verifiers, ABI descriptor/renderer entrypoint names, Win64 machine prolog/epilog/unwind/relocation/symbol naming, emitted object inspection, debug maps, crash-safe build output and compiler exception/failure boundaries.

**D5/runtime:** real approved visual constructors, layout, input/accessibility/IME and state binder, event queue/backpressure, async ticket/cancellation/uncertainty/cleanup, keyed reconciliation, per-resource limits, actual renderer service set.

**D6/build/release:** assembler/linker/SDK exact qualified paths and hashes, Unicode 15.1 table hashes, deterministic linker/PDB policy, real build inputs and output manifests, independent native conformance and signed artifact admission.

**Process:** all D1–D8 relevant architecture sign-off and observed evidence are OPEN. Documentation can define *testable candidate behavior* without mislabeling a system production-ready. Use [Specification Completion Matrix](specification-completion-matrix.md) and [Design Gates](design-completion-gates.md) for human acceptance, then implement incrementally against this **one complete end-state**.


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
