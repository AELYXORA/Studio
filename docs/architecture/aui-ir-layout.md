# AUI IR and Layout

Status: proposed. TypedHIR -> OwnershipIR -> TargetMIR. Target-dependent data layout and ABI lowering require explicit tests.

## Representation contract

AUI types are target-neutral identities. TypedHIR records resolved types, effects, source spans and project graph IDs. OwnershipIR records moves, borrows, lifetimes and cleanup paths. TargetMIR lowers to concrete registers, stack slots, native data layout, calling convention and target ISA. Internal IR structs are not binary-compatible APIs.

Represent primitives as fixed-width Bool/integers/floats and aggregate Record/Array/Optional/Result; resource types have Owned, Borrow and capability-bearing Handle forms. String is UTF-8 with explicit byte length, never an assumed C++ or OS object layout. Device address spaces are separate from normal pointers.

## Data layout algorithm

The target profile supplies primitive size/alignment, pointer model, endianness and ABI rules. For record fields in order: offset = alignUp(current end, field alignment). Final size = alignUp(last field end, aggregate alignment). Array stride = alignUp(element size, alignment); multiplication overflow must fail compilation. Internal optional/result niche optimizations need proof; exported representations require explicit tags or ABI-defined layout. Padding is not initialized data.

Example with U32 alignment 4 and U64 alignment 8: record {count:U32, timestamp:U64} has offsets 0,8; size 16 and alignment 8.

## Ownership verifier

Values are uninitialized, available, moved or maybe-invalid. All control-flow predecessors must prove available before use. Move invalidates source; mutable borrow is exclusive; shared borrow excludes mutation. Dropping an owner with live borrows, retaining a borrow past its region or using an invalid generation is rejected. An async suspension cannot preserve a borrow without an explicitly proven stable lifetime. Non-Send resources cannot cross scheduler domains. Unsafe FFI and MMIO are explicit effect/capability boundaries, not implicit pointer casts.

## Target lowering evidence

Each exported component emits an ABI report with parameter classification, register/stack placement, alignment, ownership/allocator rules, error status, supported execution domains and ISA requirements. x86-64 and AArch64 need separate reports and conformance fixtures; target acceptance is never inferred solely from successful assembly.

## Rejection fixtures

Use-after-move, overlapping exclusive borrow, use after owner drop, borrow escaping into an unbounded Task, uninitialized merge path, array-size overflow, invalid address-space cast, non-Send transfer, incompatible public layout and wrong ISA must produce stable diagnostic categories.

Open: allocator ABI, full region inference, public descriptor representation, pinning, atomic memory model and exact foreign calling conventions.


## Full compiler internal Assembly ABI — exact candidate, not user D4 ABI

The [internal compiler Assembly ABI](aui-compiler-internal-assembly-abi.md) now proposes byte-exact `CompilationContextV1`, `IRNodeHeaderV1`, `SourceSpanV1`, `CFGBlockV1`, `SSAValueV1`, `OwnerRecordV1`, `EffectRecordV1`, `Span16`, `PassRequestV1` and `PassReplyV1` structures for the one T0–T8 pipeline, along with generational `Ref64` arena handles, input-immutable/output-seal pass protocol and bounded compiler process resources. The [machine-readable 10-structure layout](../../schemas/aui-compiler-internal-abi-layout-candidate.json) contains 99 exact fields and 19 proposed resource ceilings; [five Ref64 and five record byte vectors](../../examples/aui-compiler-production/internal-abi-layout-byte-vectors.json) are arithmetic references; [54 proposed rejection/acceptance cases](../../examples/aui-compiler-production/internal-abi-and-arena-review-cases.json) are NOT-RUN.

These fixed *internal* layouts must **not** be substituted for D4's public native component frames or D5 service ABI. A compiler-local `trustState` cannot confer source/Graph approval; real D2/D6 evidence is required. **P0:** every node-tag's individual payload layout, exact native offset probes, fully approved pass budgets, future Win64 target runtime signatures and human D1–D8 approval still remain open.

## Full T1–T6 IR tag/payload catalogue — 2026-11-01 candidate

The [physical tag/payload owner](aui-compiler-ir-payload-contract.md) now inventories **139 explicit T1–T6 IR codes** with exact 16 shared physical payload templates, **138 fixed fields**, per-tag required/forbidden/semantic checks, **85 typed Ref64 pointees**, and a matching [strict review schema](../../schemas/aui-compiler-ir-payload-catalog.schema.json). A candidate tag is never a public TypeID or native handle. [16 exact byte placements](../../examples/aui-compiler-production/ir-payload-template-byte-vectors.json) and [77 NOT-RUN review scenarios](../../examples/aui-compiler-production/ir-tag-payload-review-cases.json) cover wrong tag/range, wrong size, stale/wrong-kind Ref64, Graph proof forgery, state/task/keyed lifetime, SSA/effect and machine faults.

This refines the **same** IAI-v1 48-byte IRNodeHeader and original T0–T8 pass graph; it does not add a competing representation, freeze a released ABI, or remove any semantic verifier. The T0 lexer/CST native byte layout and every candidate tag/payload approval and native Assembly probe remain P0. No trusted output can be produced while D2/D3/C9 source/type contracts are UNVERIFIED.

## IR0. Full compiler logical pass contract — one production pipeline, design candidate

**Status: PROPOSED / NOT ACCEPTED / NOT IMPLEMENTED / ALL IR/ABI TESTS NOT-RUN.** This section is the *cross-pass integration owner* of the one [full production AUI compiler](aui-compiler.md). The [source TypedHIR owner](aui-ast-semantic-analysis.md) remains authoritative for front-end semantic nodes, [OwnershipIR](aui-ownership-ir.md) for borrow/move/cleanup proofs, [TargetMIR](aui-targetmir-native-codegen.md) for machine operations and Win64 backend, [D2/D3/D6 hash pipeline](d2-d6-public-contract-digest-pipeline.md) for public identity, and [D4 Win64](d4-win64-native-component-abi.md)/[D5 runtime services](aui-platform-runtime-services.md) for actual native ABI and runtime. Nothing here creates a second language, Canonical Graph, type registry, executable ABI, universal IR wire format or compiler branch.

**A source-only plan is not a production compiler IR or an authorization certificate.** All IDs below are *logical compiler-local IDs*. Their exact Assembly struct offsets, allocator/arena representation, machine calling convention and persistent debug format are **not yet accepted**. A future native compiler must have its own in-process representation and may emit optional bounded inspection JSON according to a separately reviewed versioned schema; the JSON review envelope below is **never trusted input** for native emission.

### IR0.1. Stage graph, consumed evidence and pass authority

| Gate | Input and proof required | Output and mandatory verifier | No-go condition |
| --- | --- | --- | --- |
| T0 — parsed source | Captured strict UTF-8 AUI and selected module kind/L0–L4 profile | CST/AST with original exact byte spans, syntax recovery errors; reject unknown syntax | Syntax, profile, malformed Unicode or unresolved input bounds |
| T1 — typed source | T0 + exact resolved public TypeReference/semantic rule content or explicitly UNVERIFIED source-only catalogue | **TypedHIR** immutable typed declaration/use graph; type/effect/value/exhaustiveness/namespace verifier | Missing type, invalid effects, enum cases, generics, binding writer, profile |
| T2 — source-to-Graph link | T1 + D2/C9 source/Graph/operation/public digest/package lock + signed review/target/capability proof | **GraphLinkedIR** same typed meaning plus exact immutable link evidence for every public operation/module | ANY unapproved 15-core export, unresolved dependency, fake digest or altered source |
| T3 — feature semantic lowering | T2 + reviewed D3 L2/L3/L4 rules, qualified D5 abstract service interface | **ReactiveIR / AsyncIR / KeyedIR** with deterministic transaction/task/reconciliation graphs and full owner/generation obligations; each separately verified | Partial state commit, unbounded async, positional keyed ID, missing provider uncertainty proof |
| T4 — owned control flow | T3 + typed complete effects, D3 traits and per-call ownership/effect summary | **OwnershipIR** block-parameter CFG with explicit value/resource transfers, branches, cleanup and error/suspend paths; strict fixed-point ownership verifier | Missing live owner, double drop/move, borrow escape, capability or memory effect reordering |
| T5 — qualified layout | T4 + exact target triple, D4 public/private ABI, allocator/OS runtime imports and complete type definitions | **LayoutIR** checked target size/alignment/tag/field offsets, call frame classification and drop/retain/cross-domain semantics | Unknown native type layout, overflow, non-qualified service or ABI |
| T6 — machine program | T5 + pinned target ISA and exact qualified runtime import symbol table | **TargetMIR** typed machine CFG, explicit effect barriers, register/stack/relocation/unwind constraints; MIR validator before assembly | Unsupported opcode/ISA, ABI/stack violation, illegal alias/ordering or import |
| T7 — actual native artifact | Verified T6 + pinned assembler/linker/SDK and immutable build inputs | Real Assembly → COFF → PE, native binary/ABI/object inspection, source maps and D6 reproducibility report | Assembler/link/runtime/negative conformance failure |
| T8 — independently admitted app | Verified T7 + separately signed source/Graph/publisher approval and live OS capability | Approved load/run, D5 UI/event/state/task/keyed runtime acceptance, fault and teardown evidence | Unapproved signature/target/capability, unexpected import, stale generation or missing tests |

**Source-only exception:** T0–T1 may run in an explicit `UNVERIFIED_SOURCE_ONLY` inspection context and emit a diagnostic/plan; T2–T8 MUST NOT accept that unverified result as a replacement for trusted public exports. T3 is only a logical pass after verified T2. No optimization, debug flag, UI preview or local hash is a substitute for a missing gate.

### IR0.2. Closed common logical identity, type, origin and trust records

Every IR module has exactly one immutable `CompilationContext`: `{compilationId,sourceSetDigest,selectedProfile,moduleKind,sourceRevisions,coreRegistryFingerprint,packageLockDigest,graphSnapshotDigest,targetTriple?,abiRevision?,runtimeServiceSetDigest?,trustLevel}`. Individual optional target fields are **absent** until qualified; a self-authored string that resembles a fingerprint is not an accepted context. Required identities are verified with the [single public digest DAG](d2-d6-public-contract-digest-pipeline.md). `trustLevel` is compiler-internal `UNVERIFIED_SOURCE_ONLY | VERIFIED_GRAPH_LINKED | QUALIFIED_TARGET` and can **only be promoted after independently checked proofs**, never by deserializing its text.

Each compiler-local instruction/value/owner/basic-block ID is unique within one compilation and is **not a public TypeID, StableKey, TaskTicket, StateRevision, GraphNodeID or source-position-derived persistent name**. Provide a provenance tuple for every user-originating operation: source module content identity, exact `[startByte,endByte)` range, static AUI declaration symbol, optional verified public `TypeReference`, optional authenticated C9 Graph origin. Compiler-inserted cleanup/barrier ops have a **derived origin** pointing back to the causing source/service node and pass name. Unknown/unreconciled origin must fail a public link or native diagnostic/source-map verifier.

Full logical `TypeReference` values are exact, immutable and content-verified; inner generic argument order and public variant identity are preserved. No `typeName` or locally produced 64-hex placeholder substitutes for TypeReference. In internal IR every instruction result is accompanied by a complete type, ownership class (`copy | owned | sharedBorrow | uniqueBorrow | opaqueAffine`), region/owner and proven effects. A `Result<T,E>` and `TaskOutcome<T,E>` are different types; enum constructor/match nodes remain distinct from native numeric tags.

### IR0.3. TypedHIR node closure (single tag registry candidate)

For all shipping L0–L4 source profiles and contract modules, reject an unknown, duplicate, wrong-profile or untyped tag. Every node has `nodeId,tag,sourceOrigin,semanticType?,effectSummary,children/refs` and tag-specific fields. **The table is the logical minimum**, not permission to omit existing D3 validators.

| Tag family | Required semantic data and invariants |
| --- | --- |
| `Module`, `Import`, `RecordDecl`, `EnumDecl`, `ServiceDecl` | Exact selected module kind, ordered public fields/variants/operations; canonical package/TypeID; imported names, generics and locked public export identity. Contract module declares **interfaces only**, not native bodies |
| `ComponentDecl`, `InputDecl`, `ViewConstruct`, `ViewModifier` | One root View, ordered named properties/children/modifiers, exact constructor/effect/type signatures, unique source-stable static keys and accessibility contracts |
| `LocalEvent`, `Handler`, `CommandIntent` | Correct Event<T> owner and target, request-only event semantics, complete typed ordered command arguments/Result/effects/domain and exact provider-link evidence after T2 |
| `StateDecl`, `DerivedDecl`, `Binding`, `Commit` | Owner/generation, verified pure dependencies and one binding writer, checked state revision/atomic rollback and exact view property |
| `TaskSlotDecl`, `TaskDecl`, `Await`, `Submit`, `SettledMatch` | Explicit TaskSlot<T,E>, one typed request/ticket, bounded cross-domain transfer, exactly five TaskOutcome arms and no forged control result |
| `KeyedForEach` | Immutable List<T> with verified StableKey record field, full parent key path/template/generation; one child template, no positional key |
| `EnumConstruct`, `EnumMatch`, `ResolvedGenericType` | Exact enum variant + 0/1 payload and exhaustive pure branch proof; exact nested template arity/depth/traits and independent identity/semantic digest |
| `Literal`, `MemberRead`, `PureCall` | Complete exact expected type and bounded pure/borrow/effect proof; no runtime service may impersonate a pure function |

**No implicit lowering:** a tag missing a verified lowering for the active target is an explicit `IR_UNSUPPORTED_TAG` error. A compiler pass must track which source node IDs were consumed and exactly which output nodes/source maps cover each; an unknown tag cannot disappear through a generic visitor default.

### IR0.4. Feature semantics before ownership: exact service boundaries

- **ReactiveIR:** immutable declaration ID → initialized owned `StateSlot`; derived read-DAG is acyclic and pure; a bound View property has exactly one writer. A `Commit` is a candidate transaction containing typed writes/read revision, with two exits `Committed(newRevision)` and `Rejected(originalRevision)`; only the first publishes state/view invalidation. **No Partial Commit node**.
- **AsyncIR:** `TaskSlot` is UI owner+generation-scoped, single active provider ticket. `Submit` validates capacity/capabilities, then either never-admitted with a proved no-dispatch result, or admitted with the exact opaque runtime ticket owned by provider. `Await` splits continuation state; cancellation confirmation requires authenticated quiescence; `ProviderUnavailable(indeterminate-after-admission)` may settle UI once while the **provider still retains native resources**. Terminal UI status != terminal provider cleanup proof.
- **KeyedIR:** source template identity plus full ancestor StableKey path and per-incarnation generation; deterministic keyed reconcile makes a **candidate** create/update/delete diff. Missing/duplicate key, stale generation, conflict, allocation failure or D5 resource budget violation aborts publication. Reorder preserves identity; delete+reinsert creates a new incarnation. Async provider resources may outlive detached UI owners until safe quiescence.
- **Graph command:** only a verified GraphLinkedIR `OperationID` can lower to an abstract D5 provider import. A source `service` name without full locked package fields and target ABI never becomes an OS call, a memory pointer or a trusted capability.

### IR0.5. Versioning, verification and invalidation

1. Every pass consumes exactly one *accepted-in-context* prior version; it records pass ID/contract revision, input source and IR fingerprints, authoritative TypeReference and Graph lock identities, effect/lifetime summary, and deterministic diagnostic/source spans. The fingerprints are **compiler-local invalidation keys**, not C9 public contractDigests or release signatures.
2. If a lower pass changes node count, CFG, dataflow, variant dispatch or ownership, it must run its verifier **after** transformation. An optimization must prove equivalence under type, value, effect ordering, cleanup, ownership and target ABI. A verifier failure invalidates the output instead of silently repairing invalid public trust by fallback.
3. Cached output invalidates on semantic rules/source changes, Graph revision **plus** semantic/lock identity, public contract digests, compiler/pass version, target ABI, runtime service table, D6 byte writer or optimization flags as applicable. An old cache entry can never be relabeled `VERIFIED` by changing a manifest field.
4. All bounded limits (source/IR nodes, CFG edges, task state cases, values, live resource budget, recursion, diagnostics) are checked with overflow-safe arithmetic before allocations. **Exact numerical IR budget ceilings, per-target allocator/arena offsets and a stable IR inspection schema are still P0** — the front-end L0/L1 resource limits are not silently assumed sufficient for L4/native codegen.
5. Emit only bounded, explicitly labeled **review fixtures**, with no private secrets, credentials or native capability handles. Do not serialize actual `TaskTicket`, borrow pointer, `StateRevision` mutable owner, native handle or signer key as if they were portable public JSON.

**The acceptance owner is [the 66 full compiler cases](../../examples/aui-compiler-production/complete-compiler-acceptance.json), supplemented by the [IR-specific design/negative vectors](../../examples/aui-compiler-production/full-ir-pass-review-cases.json).** All remain `NOT-RUN`. Passing the new review fixtures alone does not prove D4 native codegen, runtime, signed source or completed architecture review.
