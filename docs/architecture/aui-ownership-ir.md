# AUI OwnershipIR and Compile-Time Safety

**Status: proposed, not implemented.** This is the semantic authority for ownership-flow verification. [Types and Ownership](aui-types-and-ownership.md) owns user-visible types; [AST and Semantic Analysis](aui-ast-semantic-analysis.md) produces typed input; [IR and Layout](aui-ir-layout.md) owns target lowering.

## Execution model

OwnershipIR is a typed control-flow graph (CFG), with basic blocks, explicit terminators, and typed value/resource IDs. Each block has predecessors/successors; exceptional error returns and cancellation cleanup are explicit edges. Input: valid TypedHIR with effect and component identities. Output: verified ownership program, or deterministic diagnostics; no native lowering with hard errors.

## Core instructions (logical, not ASM)

- `init slot,value`, `read value`, `move source -> dest`, `copy value -> dest`.
- `borrow.shared owner -> token`, `borrow.unique owner -> token`, `end_borrow token`.
- `drop owner`, `region.enter/leave`, `call target(args,effects)`, `suspend ticket`, `resume ticket`.
- `send domain,ownedValue`, `receive channel -> ownedValue`, `return value`, `branch`, `switch`.
- External/unsafe calls carry declared input/output ownership and may not invalidate unmentioned state.

## Data-flow analysis

Track resource lattice `uninitialized | available | moved | maybe-invalid` at every CFG entry/exit. At joins, a value is safely usable only if available along **all** incoming paths. A move consumes the old binding; explicit clone requires a valid copy contract. Drops are inserted only where ownership is unambiguous. Loop analysis iterates to fixed point; termination and bounded compiler resource limits need implementation policy.

Borrow analysis tracks owner region, immutable/mutable exclusivity, and uses of aliases. A unique borrow disallows another live borrow or owner mutation; shared borrows disallow owner mutation but may coexist. Non-lexical last-use shortening is a proposed optimization, never an excuse to ignore escaped aliases.

## Async, scheduler and resource transfers

An `await` creates a suspension boundary. Any live borrow crossing it requires proof the owner is retained, stable in memory and attached to the async frame; otherwise reject. Transferring across domains requires `Send`; sharing mutable memory requires a synchronization/atomic contract. A UI-owned handle cannot be sent to worker merely because the pointer width matches.

Cancellation and error paths run a verified cleanup graph. Exactly one terminal Task result is published; ownership of device/DMA buffers remains with the actual operation owner until confirmed safe to release. Generation IDs prevent stale completion from updating a replacement component.

## Native and hardware boundaries

Unsafe Assembly may be called only through a declared ABI contract identifying input/output ownership, alignment, effects, address space, privilege, concurrency and error behavior. This analysis cannot prove arbitrary opaque ASM safe. MMIO and DMA use capability types; neither permits implicit pointer casts to ordinary UI memory. Volatile and memory-order constraints remain target-specific barriers in TargetMIR.

## Diagnostics and mandatory fixtures

| Fixture | Required finding |
| --- | --- |
| Move a handle then read original | OWN_USE_AFTER_MOVE |
| Drop owner while shared borrow live | OWN_DROP_BORROWED |
| Overlap unique and shared borrow | OWN_BORROW_CONFLICT |
| Merge branch with moved value on one path | OWN_MAYBE_INVALID |
| Borrow captures into unbounded task | OWN_ASYNC_ESCAPE |
| Transfer non-Send handle to worker | OWN_NOT_SEND |
| Share mutable buffer without synchronization | OWN_NOT_SHARE |
| Error path forgets an owned buffer | OWN_RESOURCE_LEAK |
| DMA released before device completion | OWN_DEVICE_LIFETIME |
| Unsafe call with undeclared memory effects | OWN_UNSAFE_CONTRACT |

A valid reference fixture moves an owned sample buffer into a bounded worker channel; after decoding, the worker releases it on both success and error paths. Tests must inspect errors and generated cleanup paths, not merely compile success.

## Acceptance gate

A design review must establish deterministic transfer functions, join semantics, region/alias representation, async-frame lifetime proof, loop convergence, resource cleanup and stable diagnostic spans. Only then implement a validator and compare golden fixtures. No claim of borrow-checker enforcement exists today.

## D3+ task cancellation and state lifetime proposal

[L3 Task/Result](d3-task-result-lifecycle.md) proposes at-most-one active TaskTicket per source TaskSlot and an exhaustive typed terminal TaskOutcome; [L2 State](d3-state-derived-binding-contract.md) proposes UI-only StateRevision commits. A borrow that survives an await requires explicit proved ownership/pinning as defined in OwnershipIR; without that proof reject OWN_ASYNC_ESCAPE. A canceled UI view invalidates its result subscription, not the provider's DMA/resource lifetime; the provider must finish or confirm quiescence before its buffers are freed. Bounded admission and completion results must be proved by D4/D5. No native safety property is already verified.

## D3+ async and state lifetime (PROPOSED)

[L3 Task/Result](d3-task-result-lifecycle.md) proposes at most one active TaskTicket per source TaskSlot; [L2 State](d3-state-derived-binding-contract.md) confines atomic state commits to UI owner/generation. Any borrow crossing await must prove retained stable owner under this OwnershipIR, otherwise OWN_ASYNC_ESCAPE. View unmount invalidates its completion subscription but never releases in-flight DMA/resource buffer before provider quiescence. Target atomics, cancellation and cleanup proof are unimplemented.

## L4 dynamic-view ownership gates (PROPOSED)

[L4 Keyed Reconciliation](d3-keyed-dynamic-view-lifecycle.md) must not create a borrowed UI alias from a list item that escapes a valid owner region, Task await or scheduler boundary. A repeated source template owns separate runtime incarnations and result subscriptions per full keyed parent path. Removing/replacing a row marks its generation stale but leaves provider-owned DMA/OS resources attached to their actual D4 owner until safe completion. [D3/D4/D5 review](d3-d4-d5-lifecycle-consistency-review.md) lists mandatory target-native teardown and allocation-failure fixtures; no OwnershipIR implementation is claimed.

## D3 core traits and D5 bounded ownership — PROPOSED

[D3 Core Registry](d3-core-registry-value-contract.md) distinguishes logical immutable Copy from target-specific owned Send proof. List<T> is Send only if element type and its retained immutable owner are safe; String/StableKey/TaskOutcome retain selected payload lifetime, not raw StringView/OS pointers. [D4 Value ABI](d4-core-value-abi-contract.md) requires actual retain/release, callback drain, overflow-safe frame and generation ABA proof. [D5 root budget](d5-ui-resource-budget-and-publication.md) charges all retained events, results and detached owner metadata before transfer; it cannot free driver/DMA buffers merely on UI unmount. No native ownership verifier exists yet.


## OI0. Full production OwnershipIR verifier closure — typed block-argument CFG

**Status: PROPOSED / NOT IMPLEMENTED / NOT TESTED.** This is the *authoritative owner of OwnershipIR proof semantics* for the [full T0–T8 compiler pass model](aui-ir-layout.md). Lowering starts **after verified GraphLinkedIR and feature ReactiveIR/AsyncIR/KeyedIR**, never from an UNVERIFIED source-only plan or directly from JSON. The forthcoming [review CFG schema](../../schemas/aui-compiler-ownership-cfg-candidate.schema.json) is a design-only inspection contract and **not a portable runtime representation or trusted native input**.

### OI1. Closed block, value and resource model

A function contains `functionId`, one entry block, exact immutable typed signature/owner/effect/capability summary, a finite map of blocks and provenance. Each block contains exactly `blockId`, ordered typed `params[]` (SSA phi via **edge arguments**, not untyped implicit phi instructions), `instructions[]`, exactly one `terminator`, and predecessor/successor sets derived **from** terminator targets. The CFG has no fallthrough, duplicate block IDs or undefined targets. Block/SSA/resource IDs are **compiler-local**, never public TypeIDs, Graph IDs, TaskTickets or native addresses.

A value is defined exactly once by an entry/block parameter or instruction result, used only where its definition **dominates** the use (edge arguments from the source block considered at the predecessor exit). A value carries an exact resolved full TypeReference, class `copy | owned | sharedBorrow | uniqueBorrow | opaqueAffine`, an owner/region token and origin. The types of every destination block parameter and its incoming arguments match **exactly** including ownership/effect lane; no implicit copy/retain/cast at joins. A physical stack slot, runtime allocation and numeric target enum tag do not exist at this stage.

The linear resource state for every owner is **`Uninit | Available | Moved | Dropped | MaybeInvalid`**, accompanied by a region generation and current borrow set. A path may **return an owned resource** to its caller, **move to a verified callee/provider**, or **drop exactly once**. Any reachable exit where a resource remains live and owned without a declared ownership-return contract is a leak. `MaybeInvalid` is never usable; a join is `Available` only if every incoming path supplies a compatible available owner and proved borrow state. A `copy` instruction requires the exact approved D3 `Copy` trait or a separately explicit owned clone with its own failure/cleanup path. No pointer-shaped value is implicitly copyable.

### OI2. Logical instruction and terminator families (closed candidate)

| Logical instruction | Input → output ownership/effect obligations |
| --- | --- |
| `const, construct_record, construct_enum, read_member, pure_call` | Exact verified type, field/variant/payload, purity and owned result; enum construction transfers/copies payload only by approved trait |
| `owner_init, retain, clone, move, drop` | Explicitly create, retain, copy, transfer or end one owner; failed allocation/retain/clone has explicit error edge and existing owners stay valid |
| `borrow_shared, borrow_unique, end_borrow` | Borrow-token exclusivity and region/alias proof; no owner mutation/drop while any borrow live; unique borrow excludes all other borrows |
| `state_candidate, state_commit` | State and derived graph reads are pure; commit is a single atomic abstract D5 operation with success and failure successor states, no partial publish |
| `provider_admit, provider_dispatch, task_suspend, task_resume` | Exact Graph OperationID/target/effects/capability; admission no-dispatch vs admitted effect token; opaque provider ticket retained through uncertain result |
| `event_enqueue, keyed_reconcile` | UI owner/generation identity, bounded queues and candidate keyed transaction; no positional identity or early publication |
| `domain_send, domain_receive` | Verified D3 `Send` + owned transfer or separately approved synchronization; copied pointer or borrowed UI view cannot change domain |
| `unsafe_abi_call, volatile_access, atomic_op, barrier` | Only D4/D5-qualified import/address-space/ordered memory effects; explicit pre/post ownership and effect summary |
| `check, no_op_pure` | Target-neutral verified guard/pure computation, without hidden side effects |

**No unknown instruction tag** can be ignored during CFG transformation. The table is an allowed logical family, not an implicit right to generate such operations: a specific operation needs a complete typed input/output/effect/lifetime and target service signature.

Terminators are a closed semantic family: `goto(target,args)`, `cond(test,trueTarget,trueArgs,falseTarget,falseArgs)`, `switch(scrutinee,completeCases,defaultPolicy)`, `return(values)`, `fail(error,cleanup)`, and `suspend(ticket,resumeTarget,cancelTarget,errorTarget,frameOwners)`. `switch` over enum/Result/TaskOutcome **must** prove complete case coverage; `defaultPolicy=reject` for a verified closed variant set prevents a hidden wildcard arm. All abnormal exits, cancellation and admission failures are actual CFG successors/exit paths, not text descriptions. A terminal provider result and a detached UI result are **separate lifetime events**.

### OI3. Strict effect-token ordering

Impure instructions consume and produce a **typed linear effect token** for their lane (candidate lanes: `ui-event`, `state-commit`, `provider-admission`, `external-io`, `volatile-mmio`, `synchronization`, `lifetime-cleanup`). A token is an **intra-IR ordering dependency**, never a public value or native runtime handle. An effectful instruction without exact declared input+output token is invalid. Where two lanes share a causal dependency (e.g. UI event → provider admission or provider completion → UI commit), require an explicit verified join/barrier edge, not concurrent optimistic reorder. The token for a fork is passed by a terminator to one **executed path**, never duplicated for two simultaneous consumers; branch block arguments preserve lane type. Call completion/error/uncertain-outcome edges transfer the relevant effect dependency explicitly.

Pure instructions may be reordered **only** when dominance, no alias conflict and value/ownership semantics allow; `drop`, `retain`, `state_commit`, `provider_dispatch`, `event_enqueue`, `barrier`, `atomic_op` and `volatile_access` have observable semantics and cannot be treated as dead pure code. `unsafe_abi_call` has **exact** declared memory read/write, synchronization and capability effects. An unknown external import's memory footprint makes the call unsupported instead of silently assuming pure behavior.

### OI4. Worklist verifier: exact candidate algorithm and failure classes

1. Parse closed CFG record and reject unknown tags/extra fields, duplicate function/block/SSA/owner IDs, missing entry, undeclared target, invalid terminator, extra fallthrough or wrong number of edge arguments.
2. Build successor/predecessor maps exclusively from terminators. Check all reachable blocks, detect unreachable blocks and reject unknown/unverifiable dead owned resources; compute dominators including the entry; validate every SSA use/definition and every block-param type.
3. Initialize entry param ownership/borrow/effect states. Propagate each instruction's explicit transfer function in authored order. Track owner state, current region/alias set, outstanding effect tokens, source provenance and domain. On CFG join compute the **safe meet** of incoming states. `Available ⊓ Moved = MaybeInvalid`; no use/drop/move of `MaybeInvalid`. On conflicting borrow sets or owner generations reject. Use a finite worklist until stable, with separately approved resource/iteration budget; **budget exhaustion is an error**, not a partially proven success.
4. Verify borrow scope and memory aliasing: at most one unique borrow, no concurrent shared/unique overlap, no drop/move of borrowed owner, all borrows ended or immutably proved stable before escaping region. An `await` with live borrow is rejected by default; the only possible exception is a separately reviewed **pinned+retained async owner** proof with explicit frame ownership, D4 layout and cancellation cleanup; absent exact evidence => `OWN_ASYNC_ESCAPE`.
5. Check all `call`, `provider_dispatch`, `domain_send` and `unsafe_abi_call` against verified ABI/Graph operation ownership/effect/Send/target contracts and actual domain or capability. A non-Send value cannot cross domains. An opaque `TaskTicket`, provider handle, StateRevision owner token or borrowed StringView cannot be converted to Graph dataFlow merely by using a same-width argument.
6. Check **every reachable exit** (return, error, cancellation, provider-unavailable, stale UI owner, allocation failure) for exactly-once owned drop/transfer, verified effect publication, and no dangling borrows. In L3 post-dispatch uncertainty, allow UI settlement but **do not release** provider ticket/DMA/native resources until an authenticated terminal/quiescence path. For L4 stale generation, detach its UI subscription but preserve real in-flight provider owner.
7. Verify side-effect scheduling and lane join order; no state/render publication before success, no duplicate command dispatch, no duplicate TaskOutcome UI terminal, no forbidden MMIO/volatile/atomic reordering. Only after all conditions pass produce a compiler-local `OwnershipProof` bound to the exact CFG/version/input semantic/Graph/target identities.

The verifier is a pure deterministic compiler computation: it must neither call a native provider nor execute a command while proving ownership. Diagnostic source spans originate from captured source; inserted cleanup errors cite their nearest complete verified source owner and pass ID. Multiple errors use a fixed stage/ID/span precedence and bounded count. Never attempt a partial CFG proof after an unresolved public trust gate.

### OI5. Proof handoff and error matrix

A proof is **not just a boolean**. Its logical contents include `proofRevision,verifiedInputDigest,typedFunctionSignature,blockCount,cfgEdgeCount,liveOwnerSummary,effectLaneSummary,allExitsClosed,sourceGraphOrigin,verifierVersion` and a compiler-local identity. It can be invalidated by any modified block/edge/semantic type, D3 ownership/trait rule, D2/C9 operation, ABI, effect summary or verifier implementation. An arbitrary JSON field `allExitsClosed:true` is *not* sufficient proof; native backend must call the real verifier on its own actual in-memory CFG before accepting T4.

| Must reject | Error class |
| --- | --- |
| Undefined SSA value, duplicated result, missing predecessor/block argument, use outside dominance | `IR_SSA_INVALID` |
| Invalid edge owner, type, region, generation or incompatible join state | `OWN_JOIN_CONFLICT` / `OWN_MAYBE_INVALID` |
| Owner moved twice, used after move, dropped twice or escapes without transfer | `OWN_USE_AFTER_MOVE`, `OWN_DOUBLE_DROP`, `OWN_RESOURCE_LEAK` |
| Shared/unique overlap, owner drop while borrowed, borrow escaping await | `OWN_BORROW_CONFLICT`, `OWN_DROP_BORROWED`, `OWN_ASYNC_ESCAPE` |
| Non-Send cross-domain handoff, unknown unsafe import/privilege | `OWN_NOT_SEND`, `OWN_UNSAFE_CONTRACT` |
| Lifetime across uncertain provider result or stale keyed generation released too early | `OWN_DEVICE_LIFETIME`, `OWN_STALE_OWNER` |
| Effect token dropped, replayed, duplicated, reordered or aliased | `IR_EFFECT_ORDER` |
| Incomplete closed switch or forged runtime outcome | `IR_SWITCH_NOT_EXHAUSTIVE`, `IR_OUTCOME_FORGED` |

[Review CFG structural schema](../../schemas/aui-compiler-ownership-cfg-candidate.schema.json) and [full IR negative cases](../../examples/aui-compiler-production/full-ir-pass-review-cases.json) are **design-only, all NOT-RUN**. Actual native CFG/worklist/async lifetime/resource evidence, exact implementation budgets and D4/D5 qualified service contracts are still OPEN.
