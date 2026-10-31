# AELYXORA — Internal Assembly Compiler ABI, Arenas and Pass Lifecycle

**Status: PHASE I DESIGN CANDIDATE, NOT ACCEPTED, IMPLEMENTED, ABI-PROBED OR NATIVE-TESTED.** This document closes a missing *physical compiler implementation proposal* for the **one full production AUI Compiler**. The [T0–T8 pass contract](aui-ir-layout.md), [TypedHIR](aui-ast-semantic-analysis.md), [OwnershipIR](aui-ownership-ir.md), [Win64 TargetMIR](aui-targetmir-native-codegen.md) and [frontend FC4](aui-compiler-frontend-closure.md) retain logical ownership. This document owns ONLY the internal data layout, storage, memory lifetime, pass-call handoff and bounded compiler resource policy. It does **not** define the D4 ABI for user-created native components, a persistent serialized IR, canonical graph identities, runtime task handles or a new compiler generation. The first *compiler process* target is Windows x64 user-mode, using the Clang integrated GAS assembler candidate. User executable target remains separately qualified.

## IA0. Normative boundaries and baseline

- Internal binary layout **IAI-v1 candidate**, 64-bit little-endian, all structure bases aligned to **8 bytes**, individual 32-bit/16-bit fields naturally aligned. All `reserved` fields **MUST equal zero**, all out-of-range enum values and size/version mismatches reject. Every offset table below is exact in this candidate; do not infer D4 user ABI from it.
- The compiler is a trusted single process with private arena tables. Handles in these records are **compiler-local opaque integers**; none is an OS handle, memory address, persisted public TypeReference digest, GraphNodeID, signed approval, or capability lease.
- **No unbounded raw pointers in IR records.** Native code obtains temporary pointer-to-arena memory only after `ResolveRef` has validated index, generation, offset, requested byte count, element alignment and arena lifetime. Temporary native addresses may not be retained across a pass boundary, allocator growth or unwind.
- All authored source offsets are **64-bit half-open byte intervals** into immutable captured source. IR arena offsets are **32-bit** inside per-arena segments; do not confuse the two. Unicode scalar boundaries and exact original source bytes are validated by the source owner, not guessed from byte indices.
- Compiler-internal trust cannot be minted by setting a numeric flag. `trustState` values below are **reflections of already verified D2/D3/D6 source/Graph/release evidence**. Entering T2+ requires independently validated receipts; numeric `trustState=2` is neither sufficient nor a signature.
- All passes use one internal **Windows x64 calling convention** as documented by the external ABI; this only fixes inter-routine register handling. No current toolchain or machine-code ABI test has validated AELYXORA-specific records.

## IA1. Ref64 and Span16 — no direct IR pointers

Every persistent-in-process reference is a **`Ref64`**, which is an unsigned 64-bit word:

| Bit interval | Meaning |
| --- | --- |
| 0–31 | `byteOffset`, unsigned u32 into the **owning arena** |
| 32–47 | `arenaIndex`, unsigned u16; 0 forbidden |
| 48–63 | `arenaGeneration`, unsigned u16; 0 forbidden |

**All-zero Ref64 means absent**; `arenaIndex=0` or `generation=0` with nonzero bits is **invalid**, never a fallback. No arena may exceed the u32 byte-offset range. Validate `offset <= committedBytes`, `requestedBytes <= committedBytes-offset` with checked subtraction (not unchecked `offset+size`), alignment and live generation before returning a temporary pointer. Increment the generation when reusing an arena index, never resurrect stale generations; at u16 generation wrap, **retire that arena index permanently** for the process (or fail with an explicit generation-exhaustion error). Parent arena reuse cannot preserve child Ref64 validity by accident.

`Span16`, **16 bytes, align 8**, is a tightly specified view over immutable or exclusively borrowed arena bytes:

| Offset | Size | Field | Meaning |
| --- | --- | --- | --- |
| 0 | 8 | `baseRef` | Ref64 to first byte, or 0 only for a zero-length absent span |
| 8 | 4 | `byteLength` | u32; counted bytes, not node count |
| 12 | 2 | `elementSize` | u16; 1 for raw bytes; must match exact record stride for typed arrays |
| 14 | 2 | `flags` | u16: 1=immutable, 2=exclusive mutable; exactly one for nonempty span |

For typed arrays require `byteLength % elementSize == 0`, nonzero `elementSize`, validated alignment of the first element, and no access past committed bytes. A span never owns an arena. A span cannot be used as a persistent array of native pointers. A Ref64 may address a zero-byte record only when its consumer explicitly supports that shape; normal IR record allocations have positive size.

## IA2. Fixed headers — internal candidate byte layout

The authoritative [machine-readable candidate table](../../schemas/aui-compiler-internal-abi-layout-candidate.json) repeats each field/offset/size and admits no overlap, padding ambiguity or truncation. Do not repurpose a reserved field without an IAI-v2 decision.

### CompilationContextV1 — 128 bytes, align 8

| Offset | Size | Field | Semantics |
| --- | --- | --- | --- |
| 0 | 4 | `magic` | u32 `0x31494143` (little-endian bytes `43 41 49 31`, `CAI1`) |
| 4 | 2 | `abiMajor` | u16 = 1 |
| 6 | 2 | `abiMinor` | u16 = 0 |
| 8 | 4 | `structBytes` | u32 = 128 |
| 12 | 4 | `flags` | u32 = 0 until approved feature registry exists |
| 16 | 8 | `compilationId` | u64 compiler-local, unique per active compilation |
| 24 | 8 | `sourceSetRef` | Ref64: immutable captured source set |
| 32 | 8 | `typeEnvRef` | Ref64: immutable resolved public type table |
| 40 | 8 | `graphProofRef` | Ref64: **internal evidence handle**, 0 before verified T2 |
| 48 | 8 | `targetConfigRef` | Ref64: 0 before target qualification |
| 56 | 8 | `arenaTableRef` | Ref64: private validated arena descriptor table |
| 64 | 8 | `diagnosticSinkRef` | Ref64: bounded append-only diagnostic channel |
| 72 | 8 | `budgetRef` | Ref64: exact compiler resource budget instance |
| 80 | 8 | `passLedgerRef` | Ref64: immutable pass input/output evidence ledger |
| 88 | 8 | `policyRef` | Ref64: approved compiler policy identity and options |
| 96 | 4 | `trustState` | u32: 0=source-only, 1=linked, 2=target-qualified, **reflects proof only** |
| 100 | 4 | `lastVerifiedStage` | u32: T0..T8 index, never a substitute for pass ledger |
| 104 | 8 | `contextGeneration` | u64 to invalidate stale pass requests |
| 112 | 8 | `reserved0` | must equal zero |
| 120 | 8 | `reserved1` | must equal zero |

`CompilationContextV1` is process memory, not a stable on-disk blob. The **context header lives in a pinned private allocation** throughout one compilation; it cannot itself reside in an arena that can move on growth. The table of arenas is accessible only through a host-owned validated resolver; `arenaTableRef` is a lookup handle, not an invitation to follow untrusted pointer bytes.

### IRNodeHeaderV1 — 48 bytes, align 8

| Offset | Size | Field | Meaning |
| --- | --- | --- | --- |
| 0 | 2 | `tag` | u16 reviewed IR node tag; 0 invalid |
| 2 | 2 | `flags` | u16, 0 until explicitly reviewed |
| 4 | 2 | `schemaMajor` | u16 = 1 |
| 6 | 2 | `reserved` | zero |
| 8 | 4 | `recordBytes` | u32 = 48 for this fixed header |
| 12 | 4 | `sourceSpanIndex` | u32 compiler-local span table index; 0 sentinel when inserted |
| 16 | 8 | `nodeId` | u64 compiler-local unique node identity |
| 24 | 8 | `typeRef` | Ref64 to resolved immutable internal type descriptor, 0 only for untyped declaration nodes |
| 32 | 8 | `originRef` | Ref64 to immutable source/Graph origin metadata |
| 40 | 4 | `payloadOffset` | u32 within **the same arena** as the node header |
| 44 | 4 | `payloadBytes` | u32 exact validated node-kind payload size |

The tag's **closed payload descriptor** defines its fields and child-Ref64 list. Header validation checks that payload offset/length is inside the same immutable owner arena and that every reference has the expected stage, type and provenance; a successful size check does **not** establish semantic correctness. `payloadOffset=0,payloadBytes=0` represents a no-payload tag only if allowed. **Node tags/payload bytes still require a complete tag-by-tag table and approval** before this header is frozen.

### SourceSpanV1 — 32 bytes, align 8

| Offset | Size | Field | Meaning |
| --- | --- | --- | --- |
| 0 | 8 | `sourceUnitId` | u64 compilation-local immutable source unit |
| 8 | 8 | `startByte` | u64 inclusive original source offset |
| 16 | 8 | `endByte` | u64 exclusive original source offset |
| 24 | 4 | `parentSpanIndex` | u32; 0 means no parent |
| 28 | 4 | `flags` | u32; 0 until approved |

Require `startByte <= endByte <= sourceOriginalByteLength`, source unit exists and parser tracks actual UTF-8 source boundaries. Synthesized code has a causal source/origin record in the pass ledger even when no direct sourceSpanIndex exists.

### CFGBlockV1 — 64 bytes, align 8

| Offset | Size | Field | Meaning |
| --- | --- | --- | --- |
| 0 | 8 | `blockId` | u64 compiler-local |
| 8 | 8 | `paramSpanRef` | Ref64 to Span16 of ordered typed block-parameter Ref64s |
| 16 | 8 | `instructionSpanRef` | Ref64 to Span16 of ordered instruction Ref64s |
| 24 | 8 | `terminatorRef` | Ref64 to exactly one checked terminator node |
| 32 | 8 | `predecessorSpanRef` | Ref64 to Span16 of checked block ID u64s (derived, never source authority) |
| 40 | 8 | `originRef` | Ref64 source/Graph/pass origin |
| 48 | 4 | `flags` | u32, 0 candidate |
| 52 | 4 | `regionIndex` | u32 lifetime region table index; 0 only when none |
| 56 | 8 | `reserved` | must equal zero |

### SSAValueV1 — 64 bytes, align 8

| Offset | Size | Field | Meaning |
| --- | --- | --- | --- |
| 0 | 8 | `valueId` | u64 unique in compilation |
| 8 | 8 | `typeRef` | Ref64 fully resolved type |
| 16 | 8 | `ownerRef` | Ref64 owner descriptor or 0 for truly pure Copy |
| 24 | 8 | `originRef` | Ref64 source/pass |
| 32 | 8 | `definingBlockId` | u64 owner block |
| 40 | 8 | `definingInstructionId` | u64; 0 for block parameter |
| 48 | 4 | `ownershipKind` | u32: 1=Copy, 2=Owned, 3=SharedBorrow, 4=UniqueBorrow, 5=OpaqueAffine, 6=EffectToken |
| 52 | 4 | `regionIndex` | u32; 0 only for region-free pure value |
| 56 | 4 | `flags` | u32=0 candidate |
| 60 | 4 | `reserved` | zero |

### OwnerRecordV1 — 64 bytes, align 8

| Offset | Size | Field | Meaning |
| --- | --- | --- | --- |
| 0 | 8 | `ownerId` | u64 unique within compilation |
| 8 | 8 | `typeRef` | Ref64 exact TypeReference |
| 16 | 8 | `allocationOriginRef` | Ref64 to source/pass creation proof |
| 24 | 8 | `regionId` | u64 ownership region ID |
| 32 | 8 | `ownerGeneration` | u64, no ABA reuse |
| 40 | 8 | `capabilityEvidenceRef` | Ref64 verified internal evidence, absent for pure owners |
| 48 | 4 | `traitMask` | u32 approved Copy/Move/Drop/Send/Share traits |
| 52 | 2 | `domain` | u16: target-neutral domain enum, not OS numeric privilege |
| 54 | 2 | `flags` | u16=0 candidate |
| 56 | 8 | `reserved` | zero |

### EffectRecordV1 — 48 bytes, align 8

| Offset | Size | Field | Meaning |
| --- | --- | --- | --- |
| 0 | 8 | `effectId` | u64 linear effect token ID |
| 8 | 8 | `parentEffectId` | u64 causal predecessor, 0 for verified root |
| 16 | 8 | `originRef` | Ref64 source/operation origin |
| 24 | 4 | `lane` | u32 reviewed lane (UI, state, provider, I/O, MMIO, sync, cleanup) |
| 28 | 4 | `ordinal` | u32 pass-local occurrence sequence |
| 32 | 4 | `transition` | u32 reviewed effect transition |
| 36 | 4 | `flags` | u32=0 candidate |
| 40 | 8 | `reserved` | zero |

`OwnerRecordV1` is an **immutable identity descriptor**, not a mutable single value-state across all CFG paths. The worklist verifier keeps `Available/Moved/Dropped/MaybeInvalid` in a **separate per-block data-flow state arena**, because a single shared mutable `owner.state` would be incorrect at branches/joins. `EffectRecordV1` similarly describes the effect token identity; its reachability/consumption is a path-sensitive verifier state, not a globally mutable `used` bit.

## IA3. Pass call boundary, arena ownership and non-alias policy

The internal routine family uses the existing Windows x64 process ABI. Proposed logical call shape, **NOT an exported frozen symbol**:

```text
uint32 PassRun(CompilationContextV1* ctx, PassRequestV1* request, PassReplyV1* reply)
Win64 call: RCX=ctx, RDX=request, R8=reply; EAX=status code
```

`ctx`, `request`, `reply` are borrowed host-controlled buffers for the duration of the call; no callee retains them. Standard Win64 nonvolatile register saving, stack alignment and shadow space apply independently of this internal record layout. The pass never receives an unverified raw pointer obtained from a source-authored JSON field.

**PassRequestV1 — 64 bytes, align 8:**

| Offset | Size | Field |
| --- | --- | --- |
| 0 | 4 | `requestBytes` u32=64 |
| 4 | 2 | `abiMajor` u16=1 |
| 6 | 2 | `abiMinor` u16=0 |
| 8 | 4 | `passId` u32 T0..T8 bounded numeric registry |
| 12 | 4 | `flags` u32=0 candidate |
| 16 | 8 | `expectedContextGeneration` u64 |
| 24 | 8 | `inputArtifactRef` Ref64 |
| 32 | 8 | `inputProofRef` Ref64 (0 for initial source parse only) |
| 40 | 8 | `optionsRef` Ref64 immutable pass options |
| 48 | 8 | `diagnosticBudgetRef` Ref64 |
| 56 | 8 | `reserved` u64=0 |

**PassReplyV1 — 64 bytes, align 8:**

| Offset | Size | Field |
| --- | --- | --- |
| 0 | 4 | `replyBytes` u32=64 |
| 4 | 2 | `abiMajor` u16=1 |
| 6 | 2 | `abiMinor` u16=0 |
| 8 | 4 | `status` u32: 0=PASS, 1=REJECT, 2=RESOURCE_LIMIT, 3=INTERNAL_FAULT |
| 12 | 4 | `lastVerifiedStage` u32, must remain old stage on failure |
| 16 | 8 | `outputArtifactRef` Ref64; zero unless PASS |
| 24 | 8 | `outputProofRef` Ref64; zero unless PASS and real verifier completed |
| 32 | 8 | `diagnosticsSpanRef` Ref64 bounded diagnostics |
| 40 | 8 | `outputArenaLeaseRef` Ref64 owner lease; zero on failure |
| 48 | 8 | `inputArtifactDigestRef` Ref64 to exact immutable evidence |
| 56 | 8 | `reserved` u64=0 |

**Handoff protocol:** allocate a fresh *private mutable output arena*, check immutable input/proof and pass stage, run pass, validate outputs **in the output arena**, and only then **seal** the output arena read-only and publish its new `Ref64` plus real proof to the pass ledger. Failure discards/quarantines output arena without changing any earlier sealed arena or authoritative source/Graph state. Passes may read ancestor sealed arenas but cannot modify them. The ledger owns retained sealed output arenas; each lease is released only after all dependent passes, diagnostics and source maps are complete. A failed pass cannot return a PASS-shaped partial artifact.

The `inputArtifactDigestRef` is a **compiler-local invalidation key**, not public `contractDigest`. Hash/preimage trust and signatures remain exclusively with D2/D3/D6. IR debugging output may serialize a copy of verified local structure for inspection, **but replaying that JSON may never set `outputProofRef` or raise `trustState`**.

### Arena state machine and failure atomicity

`CREATED -> MUTABLE -> SEALED -> RETIRED`. `DISCARDED` is a terminal path for rejected/incomplete mutable output. A sealed arena's bytes and generation are immutable. Ref64s from it remain valid while the ledger holds a live lease; `RETIRE` invalidates every referring Ref64 by generation change/slot retirement. An arena cannot be sealed with unresolved child references, unverified node strides, open borrows, incomplete CFG terminators, uncommitted diagnostics or more than its reserved budget. No pass may build a cycle of arena leases that prevents retirement; the pass dependency graph is acyclic and checked at publication.

Source bytes, accepted immutable core/Graph evidence, compiler policy and pinned target metadata use separate sealed arenas. The compiler's ordinary `malloc`/OS handles do not leak into IR; temporary scratch allocations are accounted to the pass budget and cleared at finish. D5 resource limits apply to **generated application runtime**, not as an excuse to skip independent compiler process accounting.

## IA4. First complete-compiler bounded resource budget (proposed numbers)

These are explicit **first-host compiler** candidate defaults, not measured performance. The user can request a **smaller** budget; increasing hard maximums requires a new reviewed policy/profile. All counts are checked before allocating and charged **once** to the compilation-level ledger. Zero-terminating an input does not add a user byte.

| Resource | First-host maximum | Check boundary |
| --- | --- | --- |
| Captured source across all AUI files | **64 MiB** total; **16 MiB** per source unit | before file read/allocation |
| Number of source files | **4,096** | enumeration/import resolution |
| Token count | **2,000,000** | lexer |
| CST/AST/TypedHIR/feature nodes combined | **1,000,000** | node allocation |
| Total SSA values and effect-token IDs | **2,000,000** | ownership lowering |
| Total CFG blocks across compilation | **250,000** | block creation |
| Total CFG instructions across compilation | **4,000,000** | pass expansion |
| Total CFG edges across compilation | **1,000,000** | branch/phi verification |
| Max single CFG predecessor list | **16,384** | edge fan-in |
| Total source span records | **2,000,000** | lexer/parse/lowering |
| Generic depth and TypeReference nodes | **8** generic applications/path, **128** nodes/type reference | D3 exact type resolution |
| Compiler-owned arena memory | **512 MiB** per compilation including source, all live sealed stages and scratch | arena reservation; pressure fail closed |
| Single arena committed bytes | **128 MiB** | Ref64 u32 offset and budget guard |
| Per-pass scratch allocation | **64 MiB** (also charged globally) | pass entry |
| Diagnostic count | **1,000** per compilation; each message <= **4,096 UTF-8 bytes** | error reporting |
| Max pass/semantic validation steps | **100,000,000** abstract processing steps/compilation | deterministic charge at each interpreter/worklist edge |

`MiB=1,048,576` bytes. Every multiplication uses checked u64; guard `count * stride <= budget` without overflow. The global 512 MiB cap **dominates** per-category ceilings; the limits are not additive guarantees. Exhaustion is deterministic `COMPILER_RESOURCE_LIMIT`, no truncated successful HIR, no omitted diagnostic, no partial GraphLinkedIR or object. The 100M step counter is a deterministic guard in addition to real wall-clock/interruption policies; exact charged step definition must be frozen with verifier tests before accepting this policy. No guarantee is made that every source within the file-size cap can fit every other IR budget; fail-closed behavior is required.

These are **compiler process limits**, separate from D5 per-UI-root runtime queue/render/task budgets and from D4 per-call buffer/owner limits. The source-only first milestone may run with lower local ceilings, but it cannot silently redefine a full-compiler public language contract.

## IA5. Mandatory validators, stage failure and evidence

1. On each pass boundary, check context magic/version/size, bounds, Ref64 generations/leases, stage monotonicity, trust proof, requested resource budgets and source/Graph origin. Any forged `graphProofRef` only refers to a number; it must resolve to independently authenticated immutable evidence.
2. On each arena read, check reference generation/index/offset/count/alignment/expected descriptor tag/arena seal status. A `Span16` element-size mismatch, wraparound or stale generation is `IR_REF_INVALID`, not uninitialized native pointer access.
3. Check every fixed header size, alignment, reserved field and valid enum before interpreting tag payloads. Wrong version/tag/width/unknown required flag is `IR_ABI_UNSUPPORTED` or `IR_RECORD_INVALID`.
4. Run **real semantic per-stage verifiers** for the complete TypedHIR/feature/SSA ownership/layout/TargetMIR rather than approving inspection JSON. A structurally valid duplicate move or undefined SSA value remains invalid and must never seal an output arena.
5. On successful pass, ensure all diagnostics/failures empty, all required proof artifacts produced by a real validator, output arena fully sealed, dependency leases retained and ledger publication atomic. On error, reply `status!=PASS`, output/artifact proof refs zero, staged output discarded, earlier stage unchanged.
6. Compiler debug/inspection serialization (if adopted) needs its own versioned schema and explicitly no `trustState` authority. Never write native pointers, live capability leases, TaskTickets, D4 public call frames or source signer keys to a plain IR review JSON.

[Machine-readable exact layout candidate](../../schemas/aui-compiler-internal-abi-layout-candidate.json) and [physical ABI/arena rejection review cases](../../examples/aui-compiler-production/internal-abi-and-arena-review-cases.json) are **PROPOSED/NOT-RUN**. Required future native evidence: byte-accurate `offset/size/align` probes against produced Assembly memory; reference packing/unpacking tests; arena generation reuse/wrap; multi-pass failure atomicity and sealed immutability; leak/fault-injection tests; exactly-once ownership/effect proof; Win64 callee register/stack tests; full D1–D8 sign-off.

## IA6. Open decisions that cannot be hand-waved

- Exact **closed node tag list and variant payload field offsets** for all L0–L4 source constructs, all GraphLinkedIR/ReactiveIR/AsyncIR/KeyedIR/OwnershipIR/LayoutIR/TargetMIR instruction kinds. `IRNodeHeaderV1` is concrete but does not itself freeze every payload; compiler code must **not start production** on unknown tags.
- Arena indexing/lease table allocation and `Ref64` growth/wrap failure semantics require independent implementation proof. Same-address allocation and generation can never alone authorize a stale reference.
- Exact PassRun native exported symbol names are **not approved**. The proposed call convention and request/reply bytes are internal-only; D4 public AuiCallFrameV1 and D5 runtime service ABI remain separate and independently qualified.
- Compile-time trust requires approved D2/D3/D6 15-core CR14 semantics, type/operation/Graph receipts and native target ABIs; a compiler internal digest is not proof of public authority.
- Resource caps (including 100M step charge) and allocator failure precedence need deterministic fixture approval and real profiling before declaring the complete compiler shipping-ready.
- The complete compiler is all accepted L0–L4 and contract modules, not the source-only first milestone. Do not represent an IR header implementation as a finished parser, compiler or runtime.

**No native code or tests have been executed. All D1–D8 architecture acceptance gates remain OPEN.**
