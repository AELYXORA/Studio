# AELYXORA — Complete production compiler design acceptance

**PROPOSED — NOT ACCEPTED — ALL NOT-RUN.** The shipping product is the full [AUI compiler](../../docs/architecture/aui-compiler.md), not an L0/L1-only check command or a JSON-plan generator. The native compiler must compile every approved AUI source profile L0–L4 plus accepted public contract modules, verify one Canonical Project Graph and all public types/operations/sources, and produce real target-native modules with full ABI/runtime/link evidence.

## Design inputs

- [Production acceptance matrix](complete-compiler-acceptance.json): **66** proposed cases, all NOT-RUN; includes grammar, types, State/Bind, TaskOutcome, keyed Views, canonical Graph linking, OwnershipIR, real Win64 machine object/ABI/runtime, optimizer and deterministic signed-admission boundaries.
- [Public contract module fixture](sensor-contract.aui): one candidate AUI contract-only source with record Measurement, enum SensorError and service SensorReader. It is **not** a valid native provider, CoreRegistry fingerprint or authorization for hardware effects. The proposed source grammar and export encoding remain open until explicitly approved.
- [Existing L0/L1 frontend examples](../aui-compiler-first-slice/README.md): the separately designed incremental frontend milestone; its checks and plans do **not** prove full production compiler readiness.
- [L2 state/bind](../aui-language/feedback-panel-l2.aui), [L3 async/settled](../aui-language/review-panel-l3.aui) (now explicitly declares taskSlot), [L4 keyed ForEach](../aui-language/keyed-rows-l4.aui): historical design-only complete source examples, not native compiler output.

## Integrated grammar and export requirements

The existing [AUI Syntax owner](../../docs/architecture/aui-syntax.md) now contains the candidate unified L0-L4 grammar and contract-module syntax. The [36 integrated grammar review cases](integrated-grammar-cases.json) cover source profiles, task slots, bindings, keyed views, module kind, and public enum/service export refusal. All are NOT-RUN design expectations, not parser tests.

The canonical package schema currently supports record type exports only; enum export and service mapping to fully specified component commands need separate architecture approval. The [full AUI type rules](../../docs/architecture/aui-types-and-ownership.md) must be verified before native linking.

## Enum and service export closure (same canonical model)

The original [canonical package schema](../../schemas/canonical-component-package.schema.json) now has a **proposed** strict `enum/variants` alternative to existing `record/fields` entries. The [zero-payload SensorError enum entry](sensor-error-enum-entry.proposed.json) contains no fabricated public hash. The [28 public export scenarios](public-export-closure-review-cases.json) distinguish schema admission, semantic mutation and mandatory rejection when public type identities, provider effects, capabilities, source/target qualifications or signed package review are missing. All 28 remain NOT-RUN.

A `service` interface is **not** a new TypeID or native implementation: it must resolve to the exact reviewed existing `components[].commands`, and the signed package must supply all missing required command/component metadata. Adding an enum branch makes authoring syntax *representable*, but does **not** approve a portable enum codec, TypeReference hash or Win64 layout.

## Correct release gate

A complete AUI compiler release requires: one human-accepted full grammar/profile and core semantic registry; real locked canonical Graph/TypeReference/OperationID source links; fully verified ReactiveIR/AsyncIR/KeyedIR/OwnershipIR/TargetMIR; a qualified target-native COFF/PE backend and D5 runtime/UI service table; runnable end-to-end examples and negative/hostile-input tests; identical pinned clean-build bytes and actual signed module admission. Every item needs observed evidence. Native codegen for one L0 View alone is insufficient.

**Implementation order versus final definition:** engineering can be staged into a front-end, typed linker, reactive/async/keyed transforms, ownership and backend, but the **architecture of the entire compiler is specified and reviewed as one product** before Phase II. [Architecture Design Gates](../../docs/architecture/design-completion-gates.md) remain OPEN and this folder does not authorize product source implementation.
