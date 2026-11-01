# AELYXORA — Native Grammar Checker Assembly API and ABI Handoff

**Status: PROPOSED / NOT APPROVED / NOT IMPLEMENTED / NOT ABI-PROBED.** This document refines [grammar checker implementation](aui-compiler-grammar-checker-implementation.md) using the **same** [IAI-v1 internal compiler ABI](aui-compiler-internal-assembly-abi.md). It is a separate local verification mode within the compiler toolchain, not a public API, new IR version, second AUI parser, or trusted source/Graph approval mechanism.

## GA0. Fixed call convention and failure discipline

All internal procedures use Windows x64 ABI: integer/pointer arguments in RCX/RDX/R8/R9, caller shadow space 32 bytes, 16-byte stack alignment at call sites, preserved nonvolatile registers and documented volatile clobbers. A raw pointer may point only to a **pinned host-controlled call buffer for that synchronous invocation**. Cross-stage objects live in checked arenas and are addressed by existing Ref64, not arbitrary pointers. No pointers retained after return, allocation movement or lease release. No OS calls from grammar algorithms; the only OS boundary is host_win64.

Reuse exactly the existing `CompilationContextV1` (128 bytes), `PassRequestV1` (64 bytes), `PassReplyV1` (64 bytes), `Span16` (16 bytes) and `Ref64` bit packing. No new values are assigned to existing passId, trustState, pass statuses or proof fields. **GrammarChecker is a local analysis command, not T0's successful PASS receipt.** It must not call PassRun with a made-up passId or return any pass proof.

## GA1. Host-facing synchronous entrypoint (candidate)

```text
u32 GrammarCheckRun(
    CompilationContextV1* ctx,  // RCX borrowed pinned
    GrammarCheckRequestV1* req, // RDX borrowed pinned
    GrammarCheckReplyV1* out   // R8 borrowed pinned
)
```

The two new records are checker-private candidates, not serialized files:

**GrammarCheckRequestV1 — 96 bytes, align 8**

| Offset | Width | Field | Constraint |
| ---: | ---: | --- | --- |
| 0 | 4 | requestBytes | must be 96 |
| 4 | 2 | abiMajor | 1 |
| 6 | 2 | abiMinor | 0 |
| 8 | 8 | expectedContextGeneration | equal current context |
| 16 | 8 | grammarBytesRef | Ref64 immutable raw JSON bytes |
| 24 | 8 | registryBytesRef | Ref64 immutable production registry |
| 32 | 8 | tokenPolicyBytesRef | Ref64 immutable token policy |
| 40 | 8 | profilePolicyBytesRef | Ref64 immutable profile table |
| 48 | 8 | grammarDigestRef | Ref64 internal exact-input digest evidence |
| 56 | 8 | optionsRef | Ref64 bounded checker options |
| 64 | 8 | budgetRef | Ref64 checked cost budget |
| 72 | 8 | diagnosticSinkRef | Ref64 append-only bounded sink |
| 80 | 8 | reserved0 | zero |
| 88 | 8 | reserved1 | zero |

**GrammarCheckReplyV1 — 80 bytes, align 8**

| Offset | Width | Field | Constraint |
| ---: | ---: | --- | --- |
| 0 | 4 | replyBytes | 80 |
| 4 | 2 | abiMajor | 1 |
| 6 | 2 | abiMinor | 0 |
| 8 | 4 | status | 0 REVIEW_REPORT, 1 REJECT, 2 RESOURCE_LIMIT, 3 INTERNAL_FAULT (checker-private semantics, never PassReply PASS) |
| 12 | 4 | flags | zero until reviewed |
| 16 | 8 | reportRef | Ref64 sealed **local** report on REVIEW_REPORT only |
| 24 | 8 | diagnosticSpanRef | Ref64 bounded diagnostics |
| 32 | 8 | reportLeaseRef | Ref64 lease only on REVIEW_REPORT |
| 40 | 8 | inputDigestRef | Ref64 verified local input identity |
| 48 | 8 | decisionCount | u64 |
| 56 | 8 | conflictCount | u64 |
| 64 | 8 | reserved0 | zero |
| 72 | 8 | reserved1 | zero |

**Important status distinction:** REVIEW_REPORT means a complete deterministic analysis was produced, **not** that grammar is accepted or conflict-free. The report itself carries the counts and unresolved acceptance gates. On REJECT/RESOURCE_LIMIT/INTERNAL_FAULT all output report refs, leases and counters zero; diagnostics may remain available.

## GA2. Private procedure table (symbol candidates, not exported ABI)

| Procedure | Arguments (logical) | Result / obligations |
| --- | --- | --- |
| `GcValidateCall(ctx,req,out)` | pinned three pointers | validate exact header, context generation, reserved words, legal input Ref64; status |
| `GcReadStrictJson(ctx,inputRef,kind,outTreeRef)` | current context, immutable byte ref, declared grammar/registry/policy kind, out Ref64 slot | checked parse; reject duplicate object keys, unknown shape/version, invalid UTF-8, overbudget; no borrowed pointers escape |
| `GcDecodeGrammar(ctx,treeRef,outGrammarRef)` | checked JSON tree | unique IDs/names, closed operators, external symbols, valid root, bounded graph |
| `GcJoinPolicies(ctx,grammarRef,registryRef,tokenRef,profileRef,outJoinRef)` | checked typed refs | strict closed join; unknown token kind/production/AST handler and stale grammar owner reject |
| `GcComputeNullableFirst(ctx,grammarRef,joinRef,outSetsRef)` | sealed inputs | monotone finite bitsets; recorded deterministic iteration/step budget |
| `GcComputeFollow(ctx,grammarRef,setsRef,outFollowRef)` | checked sets | root EOF marker, right-to-left propagation, fixed-point bounded |
| `GcCheckLeftCorner(ctx,grammarRef,setsRef,outCycleRef)` | nullable and grammar | detect direct and indirect left recursion; cycle evidence |
| `GcCheckPredictions(ctx,grammarRef,setsRef,followRef,outDecisionRef)` | normalized terminal classes | all choice, optional, repeat, nullable repeat; unresolved conflict list |
| `GcCheckCoverage(ctx,grammarRef,joinRef,outCoverageRef)` | exact variant mapping | module/profile/CST/AST/T1/diagnostics completeness |
| `GcSealLocalReport(ctx,allRefs,outReportRef,outLeaseRef)` | independently checked local results | bounded deterministic report, immutable sealed arena; no pass proof |
| `GcDiscardScratch(ctx,leaseRef)` | owned provisional scratch lease | zeroize policy-sensitive scratch if applicable; release once and invalidate generation |

All procedures must use a closed error-code registry; no pointer return is successful until ResolveRef validates generation, size, alignment, arena seal/lease and descriptor. No fixed call symbol here represents a real native-exported implementation.

## GA3. Memory lifecycle and ownership

1. Host captures four immutable input snapshots and binds their exact input identities in the context; no source-authored JSON supplies a pointer or a trustworthy digest.
2. Validate host call structs **before** accessing any Ref64. Validate each input's descriptor, immutable arena seal, byte extent, active generation and budget.
3. Allocate fresh checker scratch arena; parse all inputs into private checked objects. No input arena mutation. A malformed JSON or policy fails before analysis.
4. Create dense indexes for production IDs, terminal classes and node IDs with checked counts. Fixed-point sets are dense **bitsets**; every product `nodes×terminalWords` checks u64 overflow and IAI-v1 budget.
5. Each loop iteration charges a deterministic bounded step counter, detects no-progress and detects convergence; cannot exceed approved iteration bound. A rejected grammar may still generate a full REVIEW_REPORT with **diagnostic conflicts** if structural decoding succeeded; fatal malformed inputs return REJECT.
6. Verify cross-coverage, compose sorted diagnostics, seal exactly one local report arena and lease. Do not copy any local grammar-check status to CompilationContext.trustState, lastVerifiedStage, PassReplyV1.outputProofRef or a Graph approval.
7. On any fatal failure discard scratch and provisional report, preserve earlier sealed arenas, return status and zero successful report refs. All paths release leases once; no cycle of arena dependencies. The host writes report bytes atomically only after complete report sealing.

## GA4. Deterministic arithmetic and bitset ABI requirements

Terminal classes are assigned dense compiler-local indexes by reviewed stable ordering, not arbitrary JSON object iteration. Represent FIRST and FOLLOW as `u64[]` bitsets with `wordCount=ceil(classCount/64)`, checked integer division and allocation. If unused high bits of last word are nonzero, reject. `OR` is bitwise union; `INTERSECT` proves prediction collisions. Nullable is one byte per production/node or a validated bitset, never an uninitialized bool. Provenance for a conflict records production ID, nested node path, decision arm indexes and exact normalized terminal classes, with deterministic sort by production ID, node path and arm index.

Do not assume one-token predictions when contextual spellings collapse to ID. `on settled` uses reviewed guard; qualified-name `pureExpr` uses one lookahead token **after a bounded qualified prefix**. Every unreviewed conflict becomes an unresolved analysis issue, never an automatically blessed deterministic parse.

## GA5. Native acceptance criteria — all NOT-RUN

- Byte-layout probes for 96/80-byte records, field offsets, reserved zeros, 8-byte alignment; Win64 register and stack-frame behavior.
- Invalid context generation, stale Ref64, wrong descriptor, malformed input, duplicate JSON keys, unknown grammar op, missing EOF and very large nested arrays reject without memory violation.
- Baseline 57 production grammar gives deterministic report and candidate conflicts, with no public proof/trust-state mutation.
- Grammar perturbations: direct/indirect left recursion, nullable-repeat, FIRST/FIRST, nullable FOLLOW, contextual token collision and wrong module/profile policy.
- Allocation failures at every stage, step-budget exhaustion, cancellation/unwind, output seal failure and publish failure leave no owned leak and no partial report.
- At least two consecutive same-input native executions produce byte-for-byte identical report content under the same pinned toolchain.
- Independent reviewer compares native results with reference candidate fixtures; **reference fixtures are not self-certifying evidence**.

## GA6. Open architectural sign-off

Review exact checker status enum, internal procedure signatures and new records before implementation. Authorize actual token/profile policy inputs, strict JSON parser, deterministic ordering and budgets. Native toolchain paths and hashes must be recorded; no Python, C++/Qt bootstrap or CI. D1–D8 gates remain OPEN.
