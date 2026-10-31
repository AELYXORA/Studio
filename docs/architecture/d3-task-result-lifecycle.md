# D3+ — Command Result, Task/await, Cancellation and View Lifecycle

**Status: PROPOSED L3 design, NOT accepted, implemented, ABI-linked or tested.** [D3 L0/L1 Event Delivery](d3-event-delivery-and-command-linkage.md) retains request-only send; [L2 State/Binding](d3-state-derived-binding-contract.md) owns local UI commits; [D2 Execution](d2-execution-consistency.md) owns CommandTicket/Workflow ExecutionID and cancellation races; [OwnershipIR](aui-ownership-ir.md) owns liveness/borrow safety; [D4 Binary ABI](aui-component-binary-abi.md) owns target-level atomics and provider call frames.

## T0. Profiles and authority

Candidate L3 source profile token = aui.source/l3-async/v1, selected by reviewed compilation context. L3 includes L2 capabilities and adds a **bounded** async task and completion subscription surface. L0/L1 source grammar and old fixtures remain unchanged. L1 send remains fire-and-forget *at source level*, with admission/rejection available through diagnostics; it is NOT silently reinterpreted as returning a synchronous Result.

L3 never creates an implicit graph provider or device permission. Every underlying command must match the approved exact [source-to-Graph binding](d3-event-delivery-and-command-linkage.md) and the D2/D4 target/effect contract. A Task declaration is a local AUI orchestration plan, distinct from a GraphNodeID and provider OperationID, not a privileged native function.

## T1. Bounded proposed L3 source syntax

The following is an intentional restricted extension, not the earlier broad task grammar as an automatically accepted implementation. General multi-statement async control-flow, retries, branching and joins are outside this profile.

    taskDecl         = "task", ID, "(", [ taskParams ], ")", "->",
                       "Result", "<", typeName, ",", typeName, ">",
                       "on", domainAtom, "{", awaitStmt, returnStmt, "}" ;
    taskParams       = taskParam, { ",", taskParam } ;
    taskParam        = ID, ":", typeName ;
    awaitStmt        = "let", ID, "=", "await", ID, "(", [ namedArgs ], ")", ";" ;
    returnStmt       = "return", ID, ";" ;
    submitStmt       = "submit", ID, "(", [ namedArgs ], ")", "as", ID, ";" ;
    settledHandler   = "on", "settled", ID, "(", ID, ")", "{", outcomeMatch, "}" ;
    outcomeMatch     = "match", ID, "{", successArm, failureArm,
                       rejectArm, cancelledArm, unavailableArm, "}" ;
    successArm       = "Successful", "(", ID, ")", "=>", stateCommit ;
    failureArm       = "Failed", "(", ID, ")", "=>", stateCommit ;
    rejectArm        = "AdmissionRejected", "(", ID, ")", "=>", stateCommit ;
    cancelledArm     = "Cancelled", "(", ID, ")", "=>", stateCommit ;
    unavailableArm   = "ProviderUnavailable", "(", ID, ")", "=>", stateCommit ;

An L3 ordinary UI event handler contains exactly one submitStmt **instead of** the L1 send or L2 local commit, with no implicit ordering or chained effects. The destination ID after as names a **statically declared, source-scoped task slot**, reserved in the component. No variable global registry or remote ref is created. The settled handler ID must be that same slot, not the task name or graph operation spelling. One settled handler per slot. The match operand is the handler parameter. The five arms are **mandatory exactly once** and ordered as shown for this first candidate profile; each arm has one typed binding for its variant payload and exactly one atomic L2 stateCommit. Reordering, omitting or duplicating an arm rejects AUI_OUTCOME_NONEXHAUSTIVE or AUI_OUTCOME_DUPLICATE. A payload may be unused, but cannot be used as another variant type. No branch implicitly maps failure/cancel into success. An exhaustive match is purely a result classifier, not a retry instruction.

L3 task body has exactly one awaited *approved graph command* and returns the bound Result envelope unchanged. The result local variable must have exactly the declared Result<T,E> type. The task runs in its declared domain; the command's required domain and effect/capability set are checked separately. The core L3 Task/Result type registry, keyword conflicts and parser surface require explicit approval before implementation. This small candidate intentionally avoids throwing exceptions, dynamic Task arrays, retry directives or synthetic success paths.

## T2. Source-level result and admission types

- Result<T,E>: the **provider** returned success or declared failure. Its exact logical TypeIDs are checked against locked exported command contract. It is not an exception, task completion flag, OS handle or permission.
- TaskOutcome<T,E>: proposed **closed discriminated union** with Successful(T), Failed(E), AdmissionRejected(AdmissionError), Cancelled(CancellationConfirmation), ProviderUnavailable(ProviderError). Its exact core registry type digest and serialization are P0. A timeout/cancel-request alone is **not** a Cancelled outcome.
- The settled handler receives immutable TaskOutcome<T,E> from its task-slot subscription. An explicit approved pure converter (e.g. a core outcome-to-status renderer) may produce a String; no implicit enum/String conversion, privilege expansion, or outcome erasure.
- A stale generation or duplicate terminal result is **not delivered** to a new settled handler; it produces a diagnostic to original task ownership. A source file's command result must never be silently interpreted as application-level success because task dispatch was accepted.

## T3. Request, ticket, lifecycle and backpressure

A TaskSlot identity is (ProjectID, pinned graph/source/lock snapshot, component GraphNodeID/instance, ViewIdentity and generation, source StableSymbolID of task slot). A runtime TaskTicket is a separate ephemeral generation-checked ID; its provider CommandTicket is the D2 namespace. Neither is a serialized Project Graph object or global stable path.

First L3 candidate admits **at most one active task per TaskSlot per live ViewIdentity generation**. A second submit before the prior slot becomes terminal returns AUI_TASK_SLOT_BUSY without creating another provider dispatch. Max task slots and total queued tasks are bounded by D5; current proposal does not fabricate a universal limit. D3's UI event ingress queue limit (candidate 64 per view) is **not** task queue capacity or D2 workflow mailbox capacity.

A submit follows:
1. Validate live view generation, exact compiled Task symbol/slot, named input types, Send/ownership and source digest.
2. Reserve bounded task slot and result-delivery capacity before moving any owned inputs. On failure, leave sender owner unchanged and expose a typed AdmissionRejected outcome (when the slot/generation remains live) or an explicit diagnostic; do not begin a provider operation.
3. Validate graph command link, package/ABI target, execution domain, declared effects and **fresh live** capabilities at the D2 provider admission boundary.
4. Create a TaskTicket that owns the awaited provider CommandTicket and cleanup obligations. On accepted dispatch, move/copy inputs exactly once. A task's awaited provider call MUST NOT run on UI/render/IRQ scheduler when blocking, nor use a raw UI pointer as cross-domain payload.
5. Terminal result races (success, failure, confirmed cancellation) publish exactly once under generation and ticket checks. A duplicate or late provider callback is diagnostic, not another UI StateRevision or automatic retry.
6. On valid completion, enqueue an **owned immutable TaskOutcome** to the original ViewIdentity's bounded UI completion ingress. Only the correct live generation and slot may invoke the settled handler and its L2 stateCommit. If no capacity exists, retain a bounded completed result with explicit backpressure **or fail the task slot safely**; silent drop, overwrite and unbounded result buffering are forbidden. Exact reservation protocol is a D5 P0.
7. A successful UI state transaction publishes one StateRevision. Failure or stale generation cannot partially mutate it. Cleanup uses exact ownership rules independent of UI rendering success.

An accepted Task request does not mean a physical device effect started, or that a UI commit has happened.

## T4. Cancellation and shutdown

Cancel is a **request**, not a terminal outcome. View unmount/generation replacement invalidates its completion subscription; it requests cancellation only for tasks attached to that scope. Provider tickets and device/DMA buffers remain owned until **confirmed quiescence** or a normal terminal completion. Cancellation racing with success/failure resolves via one D2 terminal publication; if operation succeeds after cancel request, final outcome is Successful, not fabricated Cancelled.

No automatic retry is allowed on ambiguous network/OS/hardware effects. A crash may leave an external effect already performed, so D6 project snapshot recovery is not runtime task replay. Timeout is a scheduling observation and may request cancellation, but does not assert the provider stopped. Shutdown must drain and destroy task/result subscriptions without callback-after-destroy; exact D4/D5 atomics and allocator lifecycle remain proof obligations.

## T5. Error/result propagation to UI State

The settled handler is not a generic event from a foreign component. It receives only the source-correlated TaskOutcome for one live slot/generation, and executes **exactly one** [L2 atomic stateCommit](d3-state-derived-binding-contract.md) from its exhaustive outcome match. Every arm writes a separate candidate state revision, never all arms. The handler may commit a pure mapped status/Result value, not invoke hardware I/O, block, await, or synchronously retry the command.

If UI binding state includes only a String status, converting TaskOutcome to String requires an **explicit reviewed pure converter** bound to the exact core registry; no hidden stringify. Failed state commit leaves the previously committed UI state authoritative; it does **not** re-run the completed provider task. A renderer error after commit does not retry effects.

## T6. Cross-profile and graph consistency

- L0: pure static view, no local state or tasks.
- L1: typed single send request, no completion callback in source.
- L2: single atomic UI-local state commit and one-way bindings, no asynchronous result subscription.
- L3: explicit bounded TaskSlot, typed submit/await/settled and one L2 completion commit; no implicit task loops or fanout.
- D2 workflow: distinct persistent definition and ephemeral ExecutionID/CommandTicket, independent from UI-local TaskTicket. Existing workflow graph may dispatch a command to the same provider, but it does not inherit the L3 UI TaskSlot or its queue.
- D4/D5: target-specific scheduler, frame layout, allocator, atomics and actual physical effects remain unimplemented.

## T7. Design acceptance scenarios — NOT-RUN

| Case | Expected |
| --- | --- |
| One approved awaited provider Result and live settled handler | At most one terminal TaskOutcome/StateRevision |
| TaskSlot already busy | AUI_TASK_SLOT_BUSY, no duplicate provider call |
| Await inside derived/layout | AUI_AWAIT_CONTEXT |
| Borrowed UI state escapes suspend | OWN_ASYNC_ESCAPE |
| Non-Send handle into worker | OWN_NOT_SEND |
| Wrong provider success/error TypeID | AUI_COMMAND_CONTRACT |
| Wrong target/effect capability | AUI_TARGET_UNSUPPORTED / CAPABILITY_DENIED |
| Missing or duplicated TaskOutcome match arm | AUI_OUTCOME_NONEXHAUSTIVE / AUI_OUTCOME_DUPLICATE |
| Cancel-request races with success | Success OR confirmed cancel once; no double terminal |
| View unmounted before completion | AUI_TASK_STALE, no replacement state update |
| UI result queue full | Bounded rejection/backpressure, never unbounded leak |
| Failure during L2 state commit | Prior StateRevision kept, no provider replay |
| Crash after external effect before result | No implicit operation replay |
| Two independent slots complete out of order | No assumed global order |
| User source modifies TaskOutcome without pure mapping | AUI_TYPE_MISMATCH |

**Remaining P0:** exact TaskOutcome and Ticket type registry digests; authorization/link-map persistence; task slot/source grammar and extension compatibility; D5 admission/results queue fairness, StateRevision/cancel atomics; ownership borrow/lifetime proofs; platform ABI and hardware-safe shutdown; native golden fixtures and observed race tests. This text is not a tested async engine.

## T8. L4 keyed task slot lifetime (PROPOSED)

[L4 Keyed Dynamic Views](d3-keyed-dynamic-view-lifecycle.md) extends TaskSlot runtime identity with the **full tagged parent item ViewIdentity path and incarnation generation**. The static TaskSlot source symbol may be identical for template clones, but their live tickets, admission capacity and owner cleanup are separate. Reorder within one parent preserves the original slot and its pending result subscriber; delete/reinsert, reparent or component TypeID replacement unmounts and revokes only the old-generation subscriber. Provider CommandTickets remain D2/D4-owned and must not be freed before quiescence. This does not enable arbitrary task fanout or unbounded dynamic tasks. D4/D5 queue/memory proof and actual result routing are still P0.


## L3 portable TaskOutcome versus provider Result — PROPOSED

[D3 Core Type Registry](d3-core-registry-value-contract.md) defines two-branch provider Result<T,E> separately from five-branch UI request TaskOutcome<T,E>; AdmissionRejected and ProviderUnavailable can arise before any provider CommandTicket exists. A cancel request alone cannot form confirmed Cancelled. [D4 ABI](d4-core-value-abi-contract.md) must verify exact native tagged union, ownership and terminal CAS; [D5](d5-ui-resource-budget-and-publication.md) proposes one active task/slot and 256 active root tasks with bounded completion reservation, not an existing measured runtime. An unmounted keyed view cannot revive an old ticket by label or item index.

## T9. Post-dispatch uncertainty, provider loss and irreversible effects — proposed closure

**Status: Phase I proposed consistency refinement, not a tested runtime state machine.** The existing five-case `TaskOutcome<T,E>` remains unchanged; introducing a sixth public branch without complete graph/source/ABI contract is forbidden. Instead the **candidate** `ProviderError` payload of `ProviderUnavailable` must distinguish at least:

1. `never-admitted`: no verified provider dispatch ticket was created and no provider effect was started. This fact requires bounded admission and dispatch proof, not a simple disconnected socket.
2. `indeterminate-after-admission`: dispatch may have reached a provider, but no trustworthy terminal provider Result or quiescence confirmation exists. This **does not** mean provider `Failure(E)`, cancellation, rollback or safe retry. External effects may already have occurred.

A third internally observed `terminal-known` case is **not** represented as `ProviderUnavailable`: once a verified provider result (or confirmed quiescence) has been safely linearized, the corresponding `Successful`, `Failed` or `Cancelled` wins. An OS communication error after such an event must not overwrite it.

Rules:

- Every dispatched ticket has one immutable owner, generation, source/graph revision, operation export identity and declared side-effect class. A lost transport or deadline does **not** release native buffers, device ownership or outstanding provider resources; keep a bounded indeterminate record until a safe quiescence/compensation decision or explicitly documented recovery boundary.
- If capacity for retaining indeterminate provider state cannot be reserved, admission **must reject before dispatch**. Once the operation might have run, lack of UI queue capacity must not fabricate `Failed(E)` or `Cancelled`, erase evidence or trigger a repeat.
- `ProviderUnavailable(indeterminate-after-admission)` can be delivered only with a typed uncertainty flag and owned cleanup/provenance; it is an observation for the original view slot, **not** a claim that the provider completed. The runtime owner of native resources remains live until a separately proven terminal/quiescent release. If original UI view disappears, record owned diagnostics and cleanup without resurrecting the view.
- `retryPolicy=never` in the current canonical package schema applies to **both** indeterminate and known outcomes. No implicit replay on reconnect, restart, timeout, snapshot recovery, stale view, or receipt refresh. An explicit future architect-reviewed compensation/idempotency contract would be necessary to do otherwise.
- The five-case TaskOutcome discriminant and provider Result two-case discriminant remain separate; neither `ProviderError` category can be converted silently to a provider `Failure(E)`.
- Actual native dispatch/terminal CAS, provider acknowledgement trust, bounded indeterminate record retention, OS/scheduler races, load shedding and D6 external-effect recovery are **OPEN D2/D4/D5/D6 proof obligations**.

[Proposed lifecycle cases](../../examples/canonical-graph/task-outcome-lifecycle-cases.json) specify ordering/uncertainty rejection scenarios, all **NOT-RUN**. This design does not claim exactly-once physical effects or safe arbitrary shutdown.
