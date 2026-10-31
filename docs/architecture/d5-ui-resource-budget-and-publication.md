# D5 — UI Resource Budgets, Event Fairness and Atomic View Publication

**Status: PROPOSED first-host capacity policy and runtime protocol; not architect-approved, implemented, instrumented or tested.** [L4 Keyed Dynamic Views](d3-keyed-dynamic-view-lifecycle.md) owns identity/reconciliation; [L2 State](d3-state-derived-binding-contract.md) owns atomic StateRevision; [L3 Task](d3-task-result-lifecycle.md) owns task semantics; [D4 Value ABI](d4-core-value-abi-contract.md) owns native ownership and lifetime; [Renderer](aui-rendering-layout.md) and [Platform Services](aui-platform-runtime-services.md) own OS presentation. This D5 budget is a **candidate** accounting model, not evidence that AELYXORA achieves it on Windows/Linux.

## B0. Scope and global budget

The accounting domain is **one live UI root**, with a parent-level UI process manager enforcing separately negotiated process/target totals. Every reservation has an owner, byte count, count limit, generation, cleanup release rule and explicit resource category. A root cannot spawn unlimited children, run callbacks or retain invisible owners outside accounting.

Candidate first-host guardrails:

| Resource | Per-unit cap | Aggregate per UI root |
| --- | --- | --- |
| Dynamic ForEach | 256 live items; max 8 nested keyed levels | 4,096 live dynamic nodes |
| UI event ingress | 64 pending events per live ViewIdentity | 8,192 pending event envelopes AND 8 MiB total retained bytes |
| Active TaskSlots/Tickets | 1 active request per live TaskSlot | 256 active requests |
| Completed outcomes waiting for UI | 1 pending per TaskSlot | 256 queued outcome envelopes AND 8 MiB retained bytes |
| Detached/tearing-down UI owners | Must be counted even when invisible | 512 entries AND 16 MiB of UI cleanup metadata (external owned device bytes accounted by D2/D4 adapter quotas) |
| Concurrent render submissions | target capability-gated | at most 2 outstanding frame submissions |
| One L2 local StateCommit | at most 16 set operations | one in-flight candidate publication per UI root owner |
| String StableKey | 1..256 UTF-8 bytes | also subject to total view/tree budgets |

These **count and byte limits apply simultaneously**. For example, a large event payload may hit the 8 MiB limit before 8,192 envelopes are reached; reaching per-view 64 does not allow bypassing global cap. Allocated capacity and bytes are charged **before** copying/moving payloads and remain charged until actual cleanup, not merely until removed from visual tree. All counters use overflow-checked non-wrapping arithmetic; failed reservation leaves original input owner unchanged.

### First-host memory envelope: illustrative allocation, not measured RAM use

A candidate root heap budget is 160 MiB, split into non-interchangeable sub-pools:
- committed view tree, keyed identity and structure: 32 MiB;
- next-tree candidate/reconciliation scratch: 32 MiB;
- UI State/Derived/Bindings: 16 MiB;
- input event envelopes and owned payloads: 8 MiB;
- completed task outcome envelopes/owned payloads: 8 MiB;
- scene/layout/paint CPU metadata: 32 MiB;
- detached owner/callback/teardown metadata: 16 MiB;
- runtime accounting and fixed headroom: 16 MiB.

Sum: **160 MiB**. These are candidate reservation ceilings, NOT benchmark results or average/peak observed memory. Native OS windows, GPU allocations, retained provider/DMA payloads, graphics backend and external package caches need **separate explicit adapter/target quotas**; they are not invisibly covered by this root budget. If the chosen first host cannot enforce both process/root budgets and external resource quotas, mark the target unsupported rather than claim the budget is verified. Multiple roots must use a separate process-wide sum/check, not each independently assume the whole system memory.

## B1. Queue ordering, fairness and nonblocking admission

D3 L1 ingress accepts FIFO per ViewIdentity. D5 adds a proposed deterministic work scheduler: per scheduling turn, process at most 8 admitted events from one ViewIdentity, then rotate to the next ready identity in ascending opaque scheduler registration order. A view whose generation is retired becomes ineligible; its stale events are rejected/cleaned without invoking handlers. No **global delivery order** or deadline guarantee is promised across views. Large inputs cannot block the UI owner on worker/network/device I/O.

An event admission succeeds only when both the per-view envelope count and the aggregate count+bytes reservation succeed. Failure returns AUI_EVENT_QUEUE_FULL with no command dispatch. Renderer frame coalescing may merge visual invalidations but **never** silently drop a typed user intent and mark it handled.

L3 TaskSlot admission reserves an active ticket slot plus sufficient bounded result-delivery/teardown ownership **before** consuming inputs or launching a provider. If the requested result cannot fit the declared bounded outcome envelope/profile, fail admission (AUI_RESULT_BUDGET) rather than promise to buffer an arbitrary unknown-size result. While waiting for final provider outcome, its reserved completion budget cannot be borrowed by other tasks in a way that makes terminal publication impossible. A provider result may remain owned by an adapter until a safe subscriber/cleanup path exists. A cancelled/unmounted UI never frees an active provider buffer without confirmed quiescence.

No blanket fairness or O(1) claim follows from queue length caps; actual scheduler throughput, alloc size and responsiveness require Phase III observations.

## B2. Two-phase UI publication and failure atomicity

A candidate UI update uses these stages, owned by one UI scheduler and scoped to a single root:
1. **Read and preflight**: pin currently committed StateRevision and source/Graph snapshot; validate complete next List<T> keys, paths, view types, event bindings, provider permissions (for future dispatch), max nesting/depth/count and all requested allocations. Unknown source/template or duplicate key fails without tearing down the last committed tree.
2. **Reserve**: atomically reserve the full upper bound for new state, derived values, child identity table, event/subscription descriptors and scene invalidation metadata. If insufficient, return AUI_UI_BUDGET and free any provisional allocations without changing committed state or starting external operations.
3. **Compute**: evaluate pure derived DAG/one-way bindings using one pre-commit StateRevision, reconcile by complete tagged keyed identity, construct new accessible/focus semantic tree, and validate cross-owner references. No OS events/IO/render presents/provider calls are made while building the candidate.
4. **Commit**: compare expected StateRevision and live root generation, then publish **one coherent pointer/epoch** to the new immutable state+desired tree+event-routing metadata. Failure leaves previous committed bundle authoritative (AUI_STATE_STALE or AUI_EVENT_STALE). Native memory-ordering and epoch reclamation need D4 proof.
5. **Close old routes**: old event subscriptions and focus/IME targets become stale immediately at commit; cancel scoped tasks via nonterminal requests, but retain adapter-owned work. Old render readers and callbacks retain counted old-state ownership until fences/readers quiesce. Do not expose half-old/half-new event route maps.
6. **Present**: layout/scene/GPU presentation is a later effect-free-from-provider stage. Failure may retain the last safely presented frame while committed StateRevision remains new; report RENDER_PRESENT_FAILED and retry repaint according to a bounded policy. Never roll back a committed state and rerun network/hardware commands.

The state commit is not atomic with D2 workflow model CAS, persistent D6 snapshots or external device effects. This is **atomic visibility of one UI root**, not distributed transaction or guaranteed pixel-perfect frame timing.

## B3. Focus, IME and accessibility after keyed list edits

Every focus/accessibility target is (full keyed ViewIdentity path, incarnation generation, semantic action ID); visual indices and screen coordinates are never authority. Same-parent reorder keeps focus if the same target remains focusable and mounted; traversal order updates to next visual list. Removal invalidates the old target *before* subsequent OS input dispatch. Proposed deterministic fallback when focused child is removed:
1. next focusable surviving sibling in the **new committed** visual order at the removed child's former slot;
2. else previous focusable surviving sibling;
3. else nearest still-live focusable ancestor;
4. else no focus.

This is a **candidate policy**, not accessibility UX approval. Focusability must include enabled/visible/accessibility semantics; same-visual-position new child is not the old target. Active IME composition on a removed target must be cancelled/closed by the platform service without committing text into another row. Screen-reader focus/announcement references likewise validate generation; platform-specific readers may have their own queued events and cancellation outcomes. D5 must prove these on the selected OS; do not silently promise cross-platform equivalence.

## B4. Resource accounting, teardown and failure precedence

Remove/reinsert does not regrant an old TaskTicket or reclaim provider DMA ownership. A detached UI owner remains charged until callback/fence/task cleanup is complete. If detached-owner cap is approached, fail admission for new view owners or apply an explicitly approved safe shutdown protocol; do not discard outstanding pointers to satisfy a counter. Capacity counters cannot be reset by changing view labels, regenerating source indices or replacing the root generation.

Suggested first-failing diagnostic order:
1. invalid source/Graph/TypeID or unapproved core profile;
2. invalid List/StableKey, duplicate keys, unknown template identity;
3. aggregate/per-scope count, byte, and cleanup reservation failure;
4. pure State/Derived/Binding and accessibility/focus resolution;
5. StateRevision/root generation CAS;
6. OS frame scheduling/presentation;
7. later provider completion/cancellation and actual resource teardown.

A UI source runtime may return AUI_UI_BUDGET, AUI_LIST_BUDGET, AUI_EVENT_QUEUE_FULL, AUI_TASK_SLOT_BUSY, AUI_RESULT_BUDGET, AUI_STATE_STALE, AUI_EVENT_STALE, AUI_TASK_STALE and RENDER_PRESENT_FAILED, all with source/owner identity and counters but no secret capability token.

## B5. Future Phase III acceptance matrix — NOT-RUN

- Per-view 65th event while pending 64; global 8193rd event or 8 MiB byte overflow -> rejected, no hidden dispatch.
- 257th child, 4097th dynamic node, ninth nested keyed list -> AUI_LIST_BUDGET, no partial unmount.
- 257th active task, 257th pending completion, byte oversized task result -> admission/backpressure without leak or external duplicate effect.
- Commit with valid new state but failed scene allocation -> preflight abort, previous StateRevision retained.
- Renderer failure **after** committed state -> new StateRevision retained, no provider retry.
- Remove focused row during IME input -> old generation does not receive edit, new item never receives stale text.
- Two concurrent commits with same StateRevision -> at most one visible publication.
- Unmount during callback -> no callback-after-free, provider resource retained until completion/quiescence.
- Multiple roots and external GPU/device quotas -> aggregate checked, no hidden overcommit.
- Real Windows x64 and Linux x86-64 benchmarks for latency, queue throughput, peak heap, GPU/OS bytes and accessibility behavior, each labeled pass/fail/not-run.

## B6. Blocking decisions

Memory envelope compatibility with real product workloads, exact byte accounting and high-water marks, OS window/GPU/provider quota integration, max per-root/process count, task result maximum payload, scheduler fairness and starvation proof, focus/IME/readers across platforms, StateRevision atomic memory ordering, cleanup progress and fault-injection methodology. **No D5 gate is accepted by this proposal**.

## B7. Windows first-host adapter scope — PROPOSED

[D5 Windows UI Host](d5-windows-host-runtime-contract.md) extends the generic root budget to Win32 message ingress, Per-Monitor V2 DPI changes, IME/TSF composition and UI Automation fragment lifetimes. Generation-tagged input and keyed focus survive same-parent reorder, reject stale unmounted rows and cannot roll back a committed UI StateRevision because drawing fails. Windows kernel/GPU/font/COM memory and provider buffers are **external quotas**, not invisibly counted in the candidate 160 MiB UI-root heap. The host needs native Windows tests, accessibility checks, ABI layout proof and explicit adapter ownership before it can be called supported.
