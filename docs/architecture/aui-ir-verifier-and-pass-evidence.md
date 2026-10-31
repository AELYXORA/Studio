# AELYXORA — T1–T6 IR Verifier and Pass Evidence Contract (candidate)

**Status: PROPOSED / NOT ACCEPTED / NOT IMPLEMENTED / NOT NATIVE-TESTED.** This document supplements the [single IR pass owner](aui-ir-layout.md), the [139-tag physical catalogue](aui-compiler-ir-payload-contract.md), and [IAI-v1 internal ABI](aui-compiler-internal-assembly-abi.md). It does **not** authorize Graph linking, generate public digests, define a second IR, or change D4/D5 ABI. Human D1–D8 gates remain OPEN.

## V0. Goals and trust boundary

Each pass must take an immutable, sealed and context-valid input, validate its entire reachable IR and stage-specific semantics, then publish a newly sealed output plus an **internal** pass receipt only if validation succeeds. The verifier must **never** accept caller-provided status bits, inspection JSON, self-asserted proof Ref64s, arbitrary native addresses, or synthetic source/Graph hashes as trusted evidence. T2 and later require separately authenticated D2/D3/D6/C9 inputs; the current 15 unverified public core contracts block admission.

A verifier is total over bounded inputs: it returns PASS or a stable diagnostic category under budget; it cannot crash, hang, partially publish, ignore an unknown tag or produce ambiguous success.

## V1. Exact validation order (fail closed)

1. **Admission:** verify CompilationContextV1 magic, ABI major/minor support, request/response record size, compilation/context generation, requested pass T1–T6, predecessor stage, input arena lease/seal, immutable source snapshot identity, budget, options, and dependency ledger. Reject untrusted external proof upfront.
2. **Memory envelope:** validate Ref64 nonzero policy, arena index/generation/lease, same-arena payload placement, checked subtraction bounds, 8-byte alignment, IRNodeHeaderV1 schema/recordBytes/flags/reserved and exactly one tag in the 139-tag catalogue.
3. **Physical payload:** verify the tag's exact template length, offsets/field widths, required/forbidden/reserved fields. Every collection is Ref64 -> Span16 -> typed 8-byte references; enforce elementSize=8, length divisibility, pointer-free layout, element alignment and arena ownership. Detect cycles where acyclic descriptor graphs are required.
4. **Descriptor closure:** recursively resolve every typed pointer kind in its declared stage, enforce source owner, typeRef and originRef rules, unique nodeId and closed instruction/terminator membership. Reachability must be explicit; no dangling or orphan executable nodes.
5. **Stage semantics:** apply the required T1/T2/T3/T4/T5/T6 verifier family in V2. An unused/unhandled tag is a fatal coverage failure, not a noop.
6. **Cross-pass preservation:** compare predecessor-to-output source coverage, type/effect/ownership obligations, operation identity, graph receipts and target assumptions; no optimization may discard an observable effect or cleanup.
7. **Commit:** revalidate whole output under the same budget, freeze arena, attach internal evidence to append-only pass ledger and atomically publish output lease. Any failure discards provisional arena and zeroes returned output/proof/artifact refs; previous stage remains unchanged.

Never trust a self-referential proof field. Validation derives its own facts from verified inputs. Diagnostic serialization is an observation, not an authorization source.

## V2. Stage-specific proofs

| Stage | Required checks before PASS |
| --- | --- |
| T1 TypedHIR | Exact original UTF-8 source coverage; resolved symbols and declared public types; expression/operator and call argument compatibility; enum payload/exhaustive match; generic depth/arity/traits; pure/effect restrictions; original sourceSpan and deterministic diagnostics. |
| T2 GraphLinkedIR | Authenticated source, package lock, type export, operation and canonical C9 Graph chain with matching target and effect/capability bounds; every logical link derives from an independently validated receipt. Source-only or UNVERIFIED core contracts reject. |
| T3 ReactiveIR | Acyclic pure derived dependencies; deterministic scheduling; initialized state; exactly one binding writer; all-or-nothing commit and old revision preserved on rejection. |
| T3 AsyncIR | TaskSlot owner/generation and admission budget; exactly one UI settlement; provider ticket remains held through indeterminate admitted outcomes until independently verified quiescence; valid suspend/resume/cancel continuations. |
| T3 KeyedIR | Unique scoped full-ancestor StableKey paths, incarnation generation, deterministic reorder/reconcile, bounded candidate allocation, atomic publication and detach/provider lifecycle. |
| T4 OwnershipIR | CFG block/terminator closure, block-argument type/arity, SSA definition dominance, region/borrow/move/drop fixed point, finite worklist convergence, exactly-once cleanup on every exit, effect-token linearity and sound uncertainty propagation. |
| T5 LayoutIR | Exact target type layout, aggregate alignment/overflow, public variant tag/field layout, ABI-visible no-niche assumptions unless proven; traceability of ownership and effect lanes to D4 services. |
| T6 TargetMIR | Qualified ISA/register classes, frame/stack/spill sizes, calling convention, imports, relocations, prologue/epilogue and unwind rules, instruction operand/result classes; effect ordering and source/Graph/ownership obligations preserved. |

All stage semantic verifiers operate on **actual IR**, not JSON review examples. T7/T8 object/signature/admission checks remain separately governed; passing T6 never establishes executable authorization.

## V3. Visitation, closure and termination

The compiler implementation must generate or exhaustively check a dispatch table from the reviewed catalogue, with one explicitly defined handler for **each of 139 tags**. A per-tag row must declare: stage; input payload template; permitted Ref64 descriptor kinds; optional/required nullability; child reference cardinality; syntactic invariants; semantic verifier entry; lowering consumer(s); relevant rejection fixtures.

At startup, compare compiled table cardinality, sorted ID set, template IDs and schema revision to the sealed catalogue identity. On mismatch, return `IR_CATALOG_MISMATCH` and prohibit compilation. `default` for unknown tags must reject. No general-purpose visitor may quietly skip an unknown mandatory child.

Traversal uses a bounded iterative worklist and visited set keyed by (arena index, generation, byte offset, expected descriptor kind). Object identity is not inferred from raw offset alone. Cycles are valid only in explicitly declared CFG edges; descriptor DAGs require acyclicity. Use checked counters for nodes, edges, depth, bytes, iterations and diagnostics under the IAI-v1 resource ceilings. Budget exhaustion is a rejection, never partial success.

T4 fixed-point analysis runs a finite monotone lattice per block and effect lane. Verify monotonic state joins, bound worklist iterations by an approved resource policy, and report unresolved or nonconverging analysis as failure; never assume a proof because an iteration cap was reached.

## V4. Preservation and diagnostics

Each pass receipt binds compiler/pass version, approved catalogue and semantic-rule identity, exact predecessor and output arena identities, source snapshot, verified source/Graph dependencies (if any), target config (if applicable), options, budget policy, verifier checks and successful output seal. Receipts are **internal invalidation evidence**, never public signatures or substitute approval.

Every rejection has: stage, stable category, deterministic primary original source span when available, IR nodeId only as nonauthoritative context, and bounded causal information. If malformed memory makes a source span unsafe, use a safe no-span diagnostic. Scrub native pointers, live tickets and sensitive capabilities.

Suggested stable categories: `IR_CONTEXT_INVALID`, `IR_REF_INVALID`, `IR_RECORD_INVALID`, `IR_ABI_UNSUPPORTED`, `IR_CATALOG_MISMATCH`, `IR_DESCRIPTOR_KIND`, `IR_CYCLE_INVALID`, `IR_TYPE_INVALID`, `IR_GRAPH_UNTRUSTED`, `IR_REACTIVE_INVALID`, `IR_ASYNC_INVALID`, `IR_KEY_INVALID`, `IR_SSA_INVALID`, `IR_OWNERSHIP_INVALID`, `IR_EFFECT_INVALID`, `IR_LAYOUT_INVALID`, `IR_TARGET_INVALID`, `IR_BUDGET_EXCEEDED`, `IR_PASS_PRESERVATION_FAILED`. These names are proposed and require reconciliation with the existing diagnostic registry.

## V5. Mandatory acceptance evidence (NOT-RUN)

1. Generated exhaustive 139/139 tag dispatch coverage and negative unknown/unhandled tag cases.
2. Native Assembly layout and offset tests for all 16 templates and 48-byte header.
3. Ref64 fuzz/property tests: null policies, cross-arena, wrong generation, index exhaustion/wrap, out-of-bounds and stale lease.
4. Span16 tests: empty-vs-missing, wrong stride, arithmetic overflow, invalid descriptor kind, cyclic descriptor chain and malformed source indices.
5. T1 type/enum/generic negative and positive cases with exact diagnostics.
6. T2 forged/expired/changed source, package, lock and canonical Graph evidence rejection.
7. T3 reactive transaction, cancellation/quiescence and stable-key remount/race cases.
8. T4 branch/loop/phi dominance, borrow conflict, effect token duplication and cleanup-on-all-exits tests.
9. T5/T6 ABI layout, machine operand, relocation, unwind and qualified runtime import tests.
10. Failure injection immediately before sealing and publication: no output/proof/artifact refs, no mutated input, no leaked arena lease; rerun deterministic.
11. Optimization pass equivalence cases and cache invalidation from semantic rule/target/source/Graph changes.
12. Explicit on-target Win64 evidence; never mark review fixtures as native PASS.

## V6. P0 decisions and cross-owner blockers

- Approve catalogue numerical tags, descriptor kind vocabulary and 139 per-tag visitor/lowering obligations.
- Decide and document T0 token/CST byte layout in its own owner; do not graft T0 tags onto this T1–T6 table.
- Reconcile diagnostics with canonical diagnostic registry; choose algorithmic verification policy for cyclic CFG and finite convergence.
- Approve IAI-v1 memory budgets and actual Win64 GAS offset probes.
- Validate all 15 public core type contracts and the D2/D3/D6/C9 authenticated link chain before granting T2 authority.
- Qualify D4 component ABI, D5 renderer/service imports, native target and acceptance evidence.
- Obtain explicit human D1–D8 architecture sign-off; nothing here is independently accepted.

**No code, executable, native test, signed link or approval is asserted by this document.**
