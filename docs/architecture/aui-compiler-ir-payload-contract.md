# AELYXORA — Full IR Tag and Payload Contract (IAI-v1)

**Status: PROPOSED DESIGN / NOT APPROVED / NO COMPILER OR NATIVE ABI TEST.** This is the physical tag/payload owner for the [single T0–T8 compiler](aui-ir-layout.md). It refines the [internal Assembly IAI-v1 ABI](aui-compiler-internal-assembly-abi.md) and does not alter the [public D4 native component ABI](d4-win64-native-component-abi.md), [TypedHIR](aui-ast-semantic-analysis.md), [OwnershipIR](aui-ownership-ir.md), [TargetMIR](aui-targetmir-native-codegen.md) or Canonical Graph.

## IT0. Complete candidate tag coverage

The [machine-readable candidate catalogue](../../schemas/aui-compiler-ir-payload-layout-candidate.json) assigns **139 unique 16-bit tag IDs** across T1 TypedHIR (36), T2 GraphLinkedIR (7), T3 ReactiveIR (7), T3 AsyncIR (12), T3 KeyedIR (8), T4 OwnershipIR (38), T5 LayoutIR (8) and T6 TargetMIR (23). T0 source/lexer/CST and T7/T8 object/release are not IR instruction stages: their byte records and immutable evidence have different owners and still need exact conformance. Tag 0, unknown tags, duplicate IDs, wrong profile and wrong stage **reject**, never fall back to a generic handler. Numeric codes remain **unapproved candidates**, not public TypeIDs.

The catalogue provides 16 exact 8-byte-aligned physical templates: `Declaration64`, `View64`, `Expression48`, `Enum64`, `Generic64`, `Link64`, `Reactive64`, `Async80`, `Keyed64`, `OwnershipInstruction64`, `OwnershipTerminator64`, `Layout64`, `MachineInstruction64`, `MachineTerminator48`, `Origin48`, `OwnerCheck48`. Every tag binds exactly one template and carries `requiredNonzeroFields`, `mustZeroFields`, `semanticInvariants` and, where applicable, operand/result counts. All per-tag semantics must pass an actual verifier; shape and raw nonzero bytes prove nothing.

## IT1. Header and payload: byte-level invariants

[IRNodeHeaderV1](aui-compiler-internal-assembly-abi.md) is **48 bytes**: tag u16 at 0, schemaMajor u16 at 4, recordBytes u32 at 8 (=48), nodeId u64 at 16, typeRef Ref64 at 24, originRef Ref64 at 32, payloadOffset u32 at 40, payloadBytes u32 at 44. The tag-specific payload uses the exact catalogue template length and 8-byte alignment. `payloadOffset` is an **absolute arena-local byte offset**, not an offset from the header. Header and payload live in the **same** owning arena after successful sealing; they need not be contiguous.

Validate the Ref64 arena index/generation/lease, checked `offset <= committedBytes` and `size <= committedBytes-offset`, node/header version and alignment, and payload tag/template size **before** following any child references. The 16 templates use only `u16,u32,u64,Ref64` fields; no source-authored OS pointers, persisted native handles, D4 `AuiSpanV1` or runtime `TaskTicket` may be inserted. All reserved fields must be bitwise zero.

Every payload collection field points via **Ref64 → Span16 → typed array**. For this first candidate, list elements are exact **8-byte Ref64s** to separately type-checked immutable descriptors. Validate `Span16.elementSize=8`, `byteLength%8=0`, correct source order, both levels of arena bounds/generation, and the expected child descriptor kind. An empty Span16 is not equivalent to a missing required Ref64. No raw pointer or hidden terminator is an array length. All source byte spans remain 64-bit original UTF-8 coordinates and must not be confused with 32-bit arena offsets.

## IT2. Exact semantic obligations beyond structure

**TypedHIR:** declaration symbols, source owners, pure expressions and typed Views retain exact original spans and ordered arguments/children. `EnumConstruct` has one declared variant with zero/one exact payload and no match arms; `EnumMatch` requires all declared cases and exhaustiveness proof but no constructor payload. `ResolvedGenericType` preserves ordered arguments and separates identity-only `@inst` from verified public contract, which is **absent in source-only T1**.

**GraphLinkedIR:** all `Link64`/verified origin tags require immutable, independently authenticated source, package-lock, type-export and C9 Graph receipts. A nonzero Ref64 or a serialized status flag is *not* authentication. T2 cannot proceed while any mandatory public core/type contract is UNVERIFIED.

**ReactiveIR:** a pure dependency graph, a single value-binding writer, and a two-way atomic commit: publish only on success, preserve old state on failure. **AsyncIR:** TaskSlot, owner/generation and admission are explicit; five-way TaskOutcome controls UI settlement, while an indeterminate provider retains actual native resources until verified quiescence. **KeyedIR:** full ancestor StableKey path, incarnation generation and atomic reconciliation; never positional identity.

**OwnershipIR:** all instruction/terminator tag operand/result counts and actual SSA dominance, borrow/move/drop, live exits and linear effect-token transitions must be checked by the T4 worklist. A candidate `OwnerCheck48` proof field is not itself a verifier result. **LayoutIR/TargetMIR:** exact D4 target type/variant layout, ISA/register/stack/unwind/import and effect/ownership preservation; a `MachineCall` requires a qualified import, and a matching numeric tag is not machine-code correctness.

## IT3. Required verification and handoff

1. Reject untrusted or stale IAI-v1 arena handles, wrong tag stage/profile/size, malformed payload offsets and unknown descriptors **before** dereference.
2. Resolve every typed child reference and Span16; validate the catalogue's per-tag required/must-zero fields, array count, ownership and causal source/Graph origin.
3. Execute the **real** T1 type verifier, T2 D2/C9 source/Graph/authenticity verifier, T3 feature verifiers, T4 dominance/ownership/effect fixed point, T5 D4 layout proof and T6 TargetMIR/Win64 ABI verifier. Reject any missing proof; do not infer it from source text or diagnostic JSON.
4. Only after full stage validation, seal and publish an output arena with an immutable pass receipt. On failure discard the output, leave prior stages untouched and return zero output proof/artifact/lease refs.
5. Revalidate after every IR optimization; each source-to-IR-to-machine lowering retains provenance and resource obligations. A UI `ProviderUnavailable` does not imply provider ticket cleanup.

[Sixteen byte-placement template vectors](../../examples/aui-compiler-production/ir-payload-template-byte-vectors.json) and [tag/payload review cases](../../examples/aui-compiler-production/ir-tag-payload-review-cases.json) are strictly **design-only**; [internal arena review cases](../../examples/aui-compiler-production/internal-abi-and-arena-review-cases.json) and [full IR semantic review cases](../../examples/aui-compiler-production/full-ir-pass-review-cases.json) remain separate. Passing a byte-layout test is not passing a semantic verifier or compiling a Windows executable.

**P0:** approve each tag's meaning and descriptor class, exact typed Span16 elements and admissible budgets, physical T0 token/CST memory, real GAS offset probes, full 139-tag visitor/lowering coverage, qualified D4/D5 target services, authenticated 15-core source/Graph contracts and human D1–D8 sign-off. No native compiler implementation or test is claimed.
