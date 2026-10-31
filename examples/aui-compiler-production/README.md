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

## Enum values, exhaustive match and nested generics

[Enum and generic value review cases](enum-generic-value-cases.json) now contain **36 NOT-RUN** designed outcomes. The source inputs include [a payload-bearing enum contract](sensor-contract-payload.aui), [L2 pure exhaustive enum matching](sensor-status-enum-match-l2.aui) and [nested generic TypeReference syntax](nested-generic-type-l2.aui). Three exact negative AUI sources exercise [nonexhaustive match](sensor-status-enum-nonexhaustive-l2.aui), [missing case payload binder](sensor-status-enum-missing-binder-l2.aui), and [wrong List<T> arity](nested-generic-wrong-arity-l2.aui); their expected diagnostics are designs, NOT native compiler observations.

There are also [three enum logical candidate hash vectors](enum-logical-digest-reference-vectors.json) and [two proposed generic export identity vectors](generic-export-identity-reference-vectors.json). Both use D6-style canonical UTF-8 and distinct domains; both sets were arithmetic-crosschecked using Python/OpenSSL. **None is a verified public contractDigest or trusted C9 Graph export.** The enum is only a value-type candidate, and the generic export namespace/contract meaning requires D2/D3/D6 architect approval.

## Full production compiler IR and native backend review — 2026-10-31

[One T0–T8 pass architecture](../../docs/architecture/aui-ir-layout.md) now covers fully typed AST → verified GraphLinkedIR → reactive/async/keyed lowering → OwnershipIR and CFG verifier → LayoutIR → qualified Win64 TargetMIR → real Assembly/COFF/PE → independent source/build admission. [OwnershipIR](../../docs/architecture/aui-ownership-ir.md) specifies block arguments, move/borrow/drop/async resource proof and observable effect ordering. [TargetMIR](../../docs/architecture/aui-targetmir-native-codegen.md) specifies target register/frame/stack, import/reloc/unwind and COFF/PE verification. [72 proposed full IR review cases](full-ir-pass-review-cases.json) remain all NOT-RUN; these are separate from the 66 total product acceptance cases. The strictly structural [Ownership CFG schema](../../schemas/aui-compiler-ownership-cfg-candidate.schema.json) has [branch](ownership-cfg-branch-review.json) and [move-to-return](ownership-cfg-move-review.json) examples; [Win64 MIR schema](../../schemas/aui-compiler-targetmir-candidate.schema.json) has a [constant-return example](win64-targetmir-constant-review.json). Additional schema-valid but semantically invalid samples: [undefined SSA](ownership-cfg-undefined-value.invalid.json), [double move](ownership-cfg-double-move.invalid.json) and [unqualified Win64 call](win64-targetmir-unqualified-call.invalid.json). **No compiled ownership proof, real target ABI or runnable COFF/PE exists.**

## Exact internal Assembly compiler records — review-only candidate

[Internal Assembly ABI IAI-v1](../../docs/architecture/aui-compiler-internal-assembly-abi.md) proposes 10 fixed compiler structures, 19 checked budget limits, generation-validated Ref64 offset handles, sealed arena pass publication, and context/PassRequest/PassReply layouts. [Machine-readable exact offsets](../../schemas/aui-compiler-internal-abi-layout-candidate.json) include 99 physical fields; [five Ref64 + five record byte examples](internal-abi-layout-byte-vectors.json) are mathematical packing vectors; [54 targeted ABI/arena/budget scenarios](internal-abi-and-arena-review-cases.json) remain NOT-RUN. This is not a public ABI or executable runtime; actual GAS assembly offsets, exact variant payload records, owned arena table and D1–D8 acceptance remain P0.

## Full 139-tag IR payload physical and typed-reference review

The [IAI-v1 full tag/payload owner](../../docs/architecture/aui-compiler-ir-payload-contract.md) now records **139 candidate T1–T6 IR node/operation IDs** and **16 exact shared payload byte templates**, plus 138 physical fields and 85 typed Ref64 targets. The [one catalog JSON](../../schemas/aui-compiler-ir-payload-layout-candidate.json) specifies per-tag required fields, zero fields, operand/result count bounds, semantic constraints and stage ranges; its [structural schema](../../schemas/aui-compiler-ir-payload-catalog.schema.json) does not itself prove SSA/ownership/Graph trust. [16 candidate little-endian payload byte vectors](ir-payload-template-byte-vectors.json) and [77 coverage scenarios](ir-tag-payload-review-cases.json) remain NOT-RUN as actual compiler or native ABI tests. No new user ABI was introduced.

## Correct release gate

A complete AUI compiler release requires: one human-accepted full grammar/profile and core semantic registry; real locked canonical Graph/TypeReference/OperationID source links; fully verified ReactiveIR/AsyncIR/KeyedIR/OwnershipIR/TargetMIR; a qualified target-native COFF/PE backend and D5 runtime/UI service table; runnable end-to-end examples and negative/hostile-input tests; identical pinned clean-build bytes and actual signed module admission. Every item needs observed evidence. Native codegen for one L0 View alone is insufficient.

**Implementation order versus final definition:** engineering can be staged into a front-end, typed linker, reactive/async/keyed transforms, ownership and backend, but the **architecture of the entire compiler is specified and reviewed as one product** before Phase II. [Architecture Design Gates](../../docs/architecture/design-completion-gates.md) remain OPEN and this folder does not authorize product source implementation.
