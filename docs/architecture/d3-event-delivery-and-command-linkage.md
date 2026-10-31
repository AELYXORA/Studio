# D3 — Typed Event Delivery, UI Command Dispatch and Graph Linkage

**Status: PROPOSED. Not accepted, compiled, rendered or runtime-tested.** This is the L1 event/command execution policy for [D3 First Language Profile](d3-first-language-profile.md) and [D3 Type Rules](d3-type-and-binding-profile.md). [D2 Execution](d2-execution-consistency.md) owns the project workflow admission/cancellation policy, [Graph ↔ AUI](project-graph-aui-contract.md) owns identities and review, and [D4 ABI](aui-component-binary-abi.md) owns physical provider calls.

## E1. Source event and handler semantics

The declaration event inspect: Event<Unit>; creates a **local typed destination signal**, not an external graph event, permission or runtime subscription. Button(...).on(activated: inspect) attaches its activated Event<Unit> output to that destination. A matching on inspect(payload) { send Inspect(...); } handler routes an accepted local event to a *command request*.

The L1 profile deliberately supports:
1. Exactly one handler definition for a given declared local event. Duplicate -> AUI_EVENT_HANDLER_DUPLICATE. A locally declared event with no handler is allowed only if explicitly used as forwarded visual output in a later profile; in L1 unused/handlerless event -> AUI_EVENT_UNHANDLED.
2. Exactly one event attachment from a given view event output. Attaching two different handlers to the same Button.activated -> AUI_EVENT_CONNECTION_DUPLICATE; no implicit fanout.
3. Multiple distinct Buttons MAY forward occurrences to one declared event, each with its distinct scoped static view identity; each occurrence is processed once at most after admission. For L1 there are no dynamic list identities.
4. Source event payload type and receiving declared Event type must be **the same resolved nominal TypeID**, not merely the same human label. AUI_EVENT_TYPE on mismatch.
5. Immutable handler payload local name is only readable within the handler; its lifetime ends when a command request has copied/owned input. No captured raw native pointer escapes.
6. The sole L1 handler statement is a typed command send; multiple commands in one handler or arbitrary statements are deferred until an explicit ordered/atomic-effect model exists.

## E2. Delivery/admission and ordering

L1 UI events are accepted into a **bounded per-view-instance UI event ingress queue**. In the candidate first runtime, capacity is exactly 64 events per ViewIdentity (policy-specific limit to be checked against D5 target memory budget); overflow -> AUI_EVENT_QUEUE_FULL with a count and event provenance. Do not silently drop a user activation and claim it completed. UI event ordering is FIFO **within one ViewIdentity**, assigned an ingressSequence after acceptance. No promise of global ordering across views or threads.

An accepted event runs one L1 handler transaction at a time per ViewIdentity. Handlers are non-reentrant: event processing triggered by a handler is queued, not executed recursively. A handler is side-effect-free except for enqueuing a validated command request; it does not wait synchronously for the command completion, access native device memory, or mutate architectural project data.

If a ViewIdentity is unmounted/replaced before a queued event is processed, the old generation's event is **rejected as stale**; never deliver to a new view generation. The owning command ticket may continue cleanup after a view is closed; a new view cannot inherit its result. A UI renderer fault does not trigger re-execution of a committed command request.

**Delivery guarantee:** at-most-once invocation of the handler **per accepted event in one running process**, with observable rejection or stale status. No durable replay, crash exactly-once, hardware cancellation or unbounded queue is promised.

## E3. Provider and export link (no naming magic)

An L1 command declaration is a *source interface*. It is not executable code. A separate **approved source-to-graph command link map** must bind a source qualified symbol (e.g. ConsumerPanel.Accept) to:
- exact ProjectID, semanticGraphDigest and GraphNodeID;
- exact exported component TypeID, OperationID and logical exportedContractDigest from the verified package registry;
- exact target triple/domain, declared effect/capability set and source file SHA-256;
- expected parameter order, input/result/error nominal TypeIDs with the resolved export registry;
- approved graph/lock/source revisions. A changed source digest or graph semantic revision makes the derived link map stale and requires reconciliation, never silent retargeting.

The proposed [D3 Link Map schema](../../schemas/aui-command-link.schema.json) checks JSON structure; the actual semantic resolver must verify every field against the immutable project/lock and D3 source AST. The link map is a **derived, reviewable index** and not a second project-graph authority; only a separately approved graph/source transaction can change canonical bindings.

Do NOT assume AUI component ConsumerPanel is identical to GraphNodeID consumer or to exported component type example.locked/consumer. Their relationship is an explicit declaration-to-instance binding. No source file path, UI label or symbol spelling gives implicit graph ownership.

## E4. Dispatch protocol and terminal results

When a Button activation is accepted:
1. Validate ViewIdentity generation, event attachment and local typed payload.
2. Queue the single handler invocation in FIFO. If full -> AUI_EVENT_QUEUE_FULL and no command issued.
3. Evaluate its pure named argument reads (no side effects). Resolve L1 command declaration by ID and exact link map bound to validated graph/package snapshot.
4. Verify provider interface input/result/error TypeIDs, declared effects and domain. Missing link -> AUI_COMMAND_UNLINKED; contract drift -> AUI_COMMAND_CONTRACT; a stale source or graph revision -> AUI_LINK_STALE.
5. Submit a typed **request** to D2's bounded command-ticket/admission service. Check live capabilities at dispatch. Command admission failure remains an explicit result (e.g. WORKFLOW_ADMISSION_REJECTED, CAPABILITY_DENIED), never advertised as successful work.
6. Provider completion/result is delivered to its original owning execution/generation, respecting D2's single terminal publication and cancellation rules. L1 source syntax **does not include** a completion handler; later D3+ must explicitly specify observable completion binding before interactive state changes based on results are supported.

Important cross-layer distinction: the L1 UI event queue is not the D2 workflow mailbox and does not inherit its capacity. An accepted UI event does not mean a D2 command ticket or an external effect was accepted; accounting and diagnostics distinguish each stage.

A command return type Result<T,E> has no implicit exception propagation. A handler issuing send cannot inspect a return value synchronously. Failure and cancellation must not be converted into a fabricated success UI state.

## E5. First-slice readiness matrix

| Stage | Meaning | What may be claimed |
| --- | --- | --- |
| PARSED | Strict AUI grammar accepted | Syntax only |
| TYPED | Imported names, named arguments, Event/Result/effect type contracts checked | Declarative well-typed source only |
| GRAPH_LINKED | Exact source/GraphNodeID/OperationID/export digest matched and immutable approved link snapshot | Command contract reference is resolved, not executable |
| ABI_LINKED | Physical provider symbol ABI, required runtime adapter and executable source verified | Potentially callable compiled binding |
| EXECUTION_VERIFIED | On-host/on-target authorized tests passed with artifact digest | Observed behavior within specified test limits |

The [Locked Pure Reference](../../examples/locked-pure-reference/README.md) is **NOT ABI_LINKED**, even though it has real ASM source bytes. The D3 linked source fixture also remains a design candidate until a compiler/parser and D4 ABI implementation exist.

## E6. Diagnostic cases (future tests NOT-RUN)

| Situation | Expected code |
| --- | --- |
| Button emits activated but destination event is undeclared | AUI_UNRESOLVED |
| Attachment uses event output name other than activated | AUI_EVENT_UNRESOLVED |
| Event<Bool> connects to Button Event<Unit> | AUI_EVENT_TYPE |
| Two handlers for one declared local event | AUI_EVENT_HANDLER_DUPLICATE |
| Two attachments on the same Button.activated | AUI_EVENT_CONNECTION_DUPLICATE |
| Locally declared event without any receiving handler | AUI_EVENT_UNHANDLED |
| Handler sends a command that was not declared | AUI_UNRESOLVED |
| Source command lacks approved graph link | AUI_COMMAND_UNLINKED |
| Provider domain/Result signature differs from source declaration | AUI_COMMAND_CONTRACT |
| Link source hash or project graph digest is stale | AUI_LINK_STALE |
| Event queue full or replaced generation | AUI_EVENT_QUEUE_FULL / AUI_EVENT_STALE |
| Runtime capability revoked before send | CAPABILITY_DENIED with no external operation |
| UI handler attempts to send twice without explicit supported effect ordering | AUI_PROFILE_UNSUPPORTED |

## E7. Open decisions / acceptance prerequisites

A final D3 gate needs: approved stable ViewIdentity generation contract, event queue budget and scheduler fairness, exact link-map approval lifecycle, target capability tokens, error visibility and accessible focus/input behavior, state/Result propagation in later D3 profile, AST/OwnershipIR proof and verified future native tests. L1 rules deliberately avoid claiming full application interaction, dynamic UI, or an implemented command runtime.

No code generation or UI execution is authorized by this document alone.

## E8. Hardware authority is never inferred from AUI commands

[D2 Hardware Resource Contract](d2-hardware-resource-contract.md) models typed MMIO, IRQ, DMA and memory claims in a versioned hardware project profile; [D2↔D3 Command Boundary](d2-d3-hardware-command-boundary.md) specifies how a future command request must match exact graph owner, resource-access edge, claim, component OperationID, target adapter, declared effects and **live capability** before any hardware provider can run. L0/L1 source contains no direct device operations; a successful button event or source-to-graph link map does not grant permission. A view replacement cannot release in-flight DMA ownership. All targets and ABI checks remain NOT-RUN.

## L3 completion boundary (PROPOSED)

L1 send stays request-only. [L3 Task/Result](d3-task-result-lifecycle.md) adds a separate bounded TaskSlot submit, one underlying provider await and an exhaustive outcome match. UI event admission, D2 command ticket terminal outcome and UI StateRevision commit remain different stages with independent queues and potential rejection. [L2 State](d3-state-derived-binding-contract.md) commits only one selected outcome arm without hardware effects. [Source snapshot](d3-source-snapshot-reconciliation.md) must receive real approval before any GRAPH_LINKED claim. Native tests NOT-RUN.
