# D3 ↔ D4 ↔ D5 — Keyed View Lifecycle Consistency Review

**Status: PROPOSED cross-owner review and documented corrections, not acceptance, code, platform proof or runtime test.** The [L4 keyed-view contract](d3-keyed-dynamic-view-lifecycle.md) is the candidate owner of *logical view identity* and reconciliation. [L2 State](d3-state-derived-binding-contract.md) owns StateRevision atomicity; [L3 Task/Result](d3-task-result-lifecycle.md) owns source TaskSlot and outcome dispatch. [OwnershipIR](aui-ownership-ir.md), [Component Binary ABI](aui-component-binary-abi.md) and [ABI/Async](aui-abi-and-async.md) own native safety. [AUI Runtime](aui-runtime.md), [Rendering/Layout](aui-rendering-layout.md) and [Platform Services](aui-platform-runtime-services.md) own target execution, native event and presentation.

## C0. Findings and proposed cross-layer resolutions

| ID | Priority | Previously ambiguous interface | Proposed resolution | What still needs physical proof |
| --- | --- | --- | --- | --- |
| LC-01 | P0 | L2 static key "unique across component tree" appears incompatible with repeated template children of a dynamic list | Static L2 keys unique **in the source template**; dynamic runtime key = full parent path + ForEach source TemplateSymbolID + tagged item StableKey + child component TypeID; same static key can be repeated under different item paths | Compiler must generate unique resolved symbol scope and detect duplicate live keyed items |
| LC-02 | P0 | Array index or renderer scene position could accidentally become ViewIdentity | **Never** derive identity from position/index/coordinate; reorder keeps the same ViewIdentity and incarnation generation | Native reconcilers and hit-testing use committed ID+generation, not index |
| LC-03 | P0 | L2 state identity includes graph digest, type and generation; hot-source edits might silently retain incompatible state | Retain state only across compatible re-renders of same pinned snapshot/generation; changing graph/contract/source without reviewed compatible migration causes replacement | Type/layout migration validator and resource-safe teardown |
| LC-04 | P0 | L3 TaskSlot is source-scoped and could accidentally be shared by repeated row templates | Runtime TaskSlot key includes full per-item ViewIdentity path and incarnation generation, lexical TaskSlot symbol ID and pinned source/graph/target | D4 ticket table and outcome routing must be ABA-safe |
| LC-05 | P0 | D4 TaskTicket lifecycle and L3 TaskOutcome differ (AdmissionRejected may happen before provider ticket exists) | AdmissionRejected/ProviderUnavailable are **source request outcomes**; they do NOT fabricate a provider terminal CommandTicket. Successful/Failed/confirmed Cancelled come from actual accepted terminal provider or task semantics | Native exact task/result discriminants, terminal CAS and ownership cleanup |
| LC-06 | P0 | View unmount vs active DMA/task ownership | Unmount invalidates **UI subscription** and requests scoped cancellation; provider/device retains its owned buffers until normal completion or confirmed quiescence. Do not make view destructor an unconditional provider drop | D4 unsub/drain atomics, callback release, DMA cancellation verification |
| LC-07 | P0 | Renderer could incorrectly treat presentation failure as rollback/command retry | State + reconciled view publish atomically in UI domain; rendering is later presentation. A failed frame preserves committed StateRevision and never reissues external effect | D5 frame queue, tearing, paint/display-list failure injection |
| LC-08 | P0 | Duplicate next-list keys and resource allocation could partially unmount old tree | Validate all keys/types/budgets and prepare new allocations before publishing; on error retain prior committed tree/state and clean candidates exactly once | D5 atomic reconcile publication, fail-injection, allocator proof |
| LC-09 | P1 | Focus/IME/accessibility routes might follow visual array index | Focus/accessibility target is (ViewIdentity, generation); reorder updates traversal order without changing target. Removal revokes old input subscription before next event dispatch | Platform accessibility/focus semantics, IME composition, event pump |
| LC-10 | P1 | L3 fixed one active task per slot vs unlimited dynamic rows/slots | Keyed lists must have global and per-parent budgets. First proposed caps: 256 per list, 8 nested lists, 4096 live dynamic nodes/UI root. Candidate D3 UI event queue 64/view is **not** a global bound; D5 must compute aggregate event/task/result memory | D5 target-specific capacity accounting and fairness under load |
| LC-11 | P0 | L4 list key types/pinning vs D2 export identity and D6 source hashes | List<T>, StableKey and source template IDs require exact core/export digests and a reviewed source/Graph immutable snapshot; no runtime key may invent graph resources or permissions | Compiler/core type system, approved provenance and source bundle snapshots |
| LC-12 | P0 | Different domains may race to apply UI completion and unmount | Route through one UI owner scheduler with generation check + compare-and-swap before commit; an old completion produces AUI_TASK_STALE, never new-generation mutation | Native memory ordering, cancellation races, queued completion drain |

The review resolves **documentation ambiguity only**. Every D4/D5 physical gate remains unverified.

## C1. Source/runtime/D2/ABI boundary matrix

| Datum | D3 owner | D2/D6 relation | D4/D5 runtime handling |
| --- | --- | --- | --- |
| Stable ForEach TemplateSymbolID | Reviewed compiler source index | exact source SHA + bundle approval, not GraphNodeID | compiled template descriptor |
| Item StableKey | Typed data value, no position fallback | not a Project Graph ID; not in semanticGraphDigest | tagged immutable value, full equality |
| ViewIdentity path and incarnation | D3 L4 reconciliation | ephemeral runtime; source/graph snapshot pinned | opaque generation-checked handle, no ABA reuse |
| StateSlot / StateRevision | D3 L2 owning UI component | not GraphRevision / D6 HEAD | UI-owned atomic state transaction |
| TaskSlot / TaskTicket | D3 L3 per live keyed view | provider CommandTicket is a distinct D2 identity | D4 task table, pinned frame, cancel flag, owned result |
| CommandTicket / ExecutionID | Source contract only | D2 workflow/provider and graph | D4 ABI implementation must preserve owner & terminal CAS |
| Render scene node / focus handle | D3 logical view only | no architectural authority | D5 generation-tagged paint/focus/hit-test snapshot |
| Device/DMA capability lease | no direct UI authority | explicit reviewed D2 resource claim | D4/D5 physical owner retains until quiescence |

Do not serialize any ephemeral ViewIdentity/StateRevision/TaskTicket as a project source file identity; do not use an AUI key to address physical I/O without an approved provider.

## C2. Candidate lifecycle protocol across owners

1. D3 produces a typed next **desired View tree** with explicit ForEach key values and validated list budgets, no effects.
2. D5 reconciler validates all key uniqueness, nominal child types, new state/derived bindings, data ownership, accessibility targets and resource reservations. On hard error, abort with old tree/state intact.
3. D3 L2 UI scheduler commits one StateRevision plus coherent desired/reconciled view revision. Retained keyed children preserve incarnation. Changed key, different parent or TypeID unmount old and mount fresh generation.
4. D5 publishes generation-tagged scene, focus and event subscription metadata; presentation is asynchronous and not part of external effect transaction.
5. On removal, D5 closes old-generation UI event admission, invalidates focus/IME/accessibility and detaches completion subscriptions; D4 retains any in-flight provider task ownership. Cancellation request is nonterminal.
6. D4 publishes at most one terminal result per accepted task/ticket; D5/D3 delivers it to the original live subscriber only if all owner/source/graph/slot/generation checks pass. Stale results cleaned up safely and diagnosed, not redirected.
7. D5 may retain old render resources until GPU frame fence/reader quiescence; allocator and native callback handles are released exactly once. Persistent resource owner accounting must be bounded and observable.
8. A renderer failure or resize may invalidate scene/layout caches; it must not roll back UI StateRevision, modify Project Graph, resurrect retired view generation or dispatch a provider command.

## C3. Cross-owner test matrix for later Phase III — all NOT-RUN

| Scenario | Required observation |
| --- | --- |
| a,b,c reordered to c,a,b while b TaskTicket active | b retains ViewIdentity/TaskSlot, result reaches b once, visual order updated |
| b removed while its provider owns DMA buffer | b subscription closed, no UI update, provider buffer kept until confirmed quiescence |
| b reinserted same key after removal | b has fresh incarnation; old b completion rejected as AUI_TASK_STALE |
| same key repeated in next vector | candidate fails AUI_KEY_DUPLICATE with zero visible partial commit |
| change row child component TypeID | old resource cleanup, new StateSlot, no stale alias |
| move key between parent lists | new identity, no implicit state/TaskTicket transfer |
| error after candidate state allocation | no leaked state/OS handle; old tree remains |
| 256+ items/9th nested list/4096+ nodes | explicit AUI_LIST_BUDGET; no unbounded growth |
| concurrent queued input and unmount | only original valid generation can process; no callback-after-destroy |
| focus moved by reorder | same focused identity, updated accessibility traversal order |
| focused item removed during IME composition | IME target invalidated; deterministic focus fallback, no input misroute |
| request rejected before D2 ticket allocation | typed AdmissionRejected; no fabricated terminal provider ticket |
| cancel success race | one terminal task/provider outcome, no double resource release |
| render-present failure after state commit | committed StateRevision unchanged; no external command replay |
| source bundle checksum changed with same graph hash | approval stale; rerun linkage/approval, no silent privilege increase |

## C4. Explicit remaining sign-off blockers

- D3: L4 syntax grammar and exact List<T>/StableKey registry, source TemplateSymbolID continuity, keyed component ownership, migration policy, error spans.
- D4: handle representation, generation monotonicity/ABA proof, native callback unsubscribe/drain, owner/borrow transfer, task terminal CAS, DMA quiescence and allocator lifecycle.
- D5: actual event/focus/IME/accessibility/glyph/scene internals, global queue memory budgets, reconcile/fence atomics, deterministic focus fallback, fairness and renderer fault behavior.
- D2/D6: graph/provider/claim approval, exact source/ABI snapshot inclusion, trust receipt and durability on qualified filesystem.
- Evidence: architecture acceptance for each gate **before** implementation, then target-native tests/races/benchmark observations in Phase III.

The L4 contract plus this review are **design candidates, not a declaration of D3/D4/D5 completion**.

## C5. Logical core, ABI layouts and UI resource admission — PROPOSED

[D3 logical registry](d3-core-registry-value-contract.md), [D4 native ABI](d4-core-value-abi-contract.md) and [D5 UI resource budget](d5-ui-resource-budget-and-publication.md) refine the lifecycle contracts above. A portable StableKey byte frame cannot be reinterpreted as a native tagged union; provider Result<T,E> and UI TaskOutcome<T,E> have distinct terminal/admission semantics. A per-view event cap is insufficient for thousands of dynamic views, so D5 adds aggregate count AND byte accounting. [Core review](d3-d4-d5-core-contract-review.md) records 12 unresolved cross-owner issues. All observed native layout, cleanup, renderer and performance tests remain NOT-RUN.
