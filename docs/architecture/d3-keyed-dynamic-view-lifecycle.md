# D3+ L4 — Keyed Dynamic Views, Reconciliation and Lifecycle

**Status: PROPOSED language/runtime contract only. NOT architect-approved, parsed, compiled, rendered or tested by AELYXORA.** This document owns the bounded **L4 dynamic-view** design extending [L0/L1](d3-first-language-profile.md), [L2 state](d3-state-derived-binding-contract.md), and [L3 tasks](d3-task-result-lifecycle.md), without changing their source accept/reject behavior. [D3↔D4↔D5 review](d3-d4-d5-lifecycle-consistency-review.md) owns cross-layer proof obligations, [D6 source reconciliation](d3-source-snapshot-reconciliation.md) owns reviewable source identities, and [D2 workflow](d2-execution-consistency.md) owns canonical Graph/CommandTicket identities. **No second Project Graph or direct native/OS capability is created by this syntax.**

## K0. Version and bounded syntax

Candidate explicit compiler source profile **aui.source/l4-keyed/v1**. It includes selected L0–L3 syntax, but does NOT make ForEach, List<T>, runtime keys or dynamic child creation legal in older profile files. This profile is still a design proposal requiring a pinned core registry, source-symbol identity and target runtime budget.

    dynamicExpr     = "ForEach", "(", "items", ":", pureExpr, ",",
                      "key", ":", itemKeyPath, ")",
                      "{", ID, "in", viewExpr, "}" ;
    itemKeyPath     = itemBindingName, ".", fieldName ;
    itemBindingName = "item" ;
    fieldName       = ID ;

The literal token item in itemKeyPath is the fixed item binding name in L4. The body must bind item too; a different name fails AUI_KEY_BINDING_MISMATCH. The body must declare the same exact item name, so the canonical example is **ForEach(items: rows, key: item.id) { item in Text(value: item.title) }**. The body is exactly one L4 View. In L4 only, stack child positions accept either original viewExpr or dynamicExpr, including nested ForEach. L0-L3 continue to reject dynamicExpr. A ForEach may be nested inside a static stack or a further keyed ForEach. Dynamic children have no implicit path to private parent/neighbor state.

Type rules: items must resolve to an immutable finite **List<T>** of nominal record T in a pinned L4 core contract. key must select exactly one public immutable field of T whose type is approved **StableKey**, not an arbitrary pure function, float, pointer, array index, StringView, transient graph address or mutable state. Item order is visual order only; the key has the same meaning regardless of position. List<T> / StableKey and exact ABI layouts are *not* supplied by the existing L0/L1 core registry.

L4 does NOT yet admit arbitrary while/for loops, side-effectful iterators, mutable collection aliases, implicit keys, cross-parent portals, animations owning new state, virtualization, unbounded off-screen caching or arbitrary tree rewrites. No default fallback to positional identity.

## K1. Two identity namespaces

1. **Source template identity** = pinned compiled SymbolID of the ForEach expression + its declared child/template component type. It is derived from an approved source-to-Graph compiler index, never from line number, position, display label or ephemeral AST index. A changed source digest invalidates an approved bundle; if template provenance/compatibility cannot be proven, it is a *replacement*, not an assumed stable edit.
2. **Runtime item identity** = (ProjectID, pinned semanticGraphDigest, owning GraphNodeID/component instance, parent ViewIdentity path, ForEach TemplateSymbolID, canonical StableKey value, resolved child component TypeID). Generation is a separate monotonically assigned **runtime incarnation**. Key bytes have a type tag and exact scalar representation (see K2); do not compare implementation-dependent hash table hashes.

**Static L2 .key(value: ID)** remains unique across its one template's lexical static children. A repeated static key inside ForEach is LEGAL because each copy is scoped beneath a **different runtime keyed item path**. Duplicate item keys within one ForEach at a single committed revision are ILLEGAL (AUI_KEY_DUPLICATE), even when child render text differs. Two distinct ForEach templates may both contain an item key "a" without collision because TemplateSymbolIDs differ. No key or ViewIdentity is equal to GraphNodeID.

A key cannot simultaneously name two live children of the **same parent list**. The first profile is strict: reject the whole candidate update before reconciliation, with original committed view/state intact. No "first wins", disambiguating by index or auto-generated suffix.

## K2. StableKey encoding and type policy

Candidate StableKey is a closed tagged scalar:
- **StableKey.String**: exact decoded Unicode scalar sequence encoded UTF-8; no implicit NFC/case folding of *values*, consistent with D6 canonical string values. Visually identical sequences are distinct unless exact scalars match. Empty key rejected.
- **StableKey.U64**: full unsigned 64-bit integer encoded **eight-byte big-endian**. This is a value tag, not a JavaScript Number; no decimal-float conversion or platform-native integer casts.
- The tag is part of equality. String "1" and U64 1 are different; user-defined structs, booleans, UUID guessing and floating values are NOT first-profile keys.

A qualified runtime key is a **length-framed tuple** of parent identity components plus type tag/key bytes. No delimiter concatenation that could collide when String contains slash, NUL or punctuation. String key size is bounded by a target-approved maximum, candidate default 256 encoded UTF-8 bytes; a larger string fails AUI_KEY_TOO_LARGE before allocation. An address or pointer is never a key. Hashes may accelerate lookup, but collisions must compare full canonical tagged key values.

Key field stability is a **runtime contract**: if id changes from old to new, it is removal of old item + insertion of new item, not a mutation of a surviving item's identity. IDs cannot be inferred from array ordering or data source row index.

## K3. Reconciliation as a single candidate transaction

For an old committed child vector and next immutable List<T>:
1. Validate entire list, element nominal types, all required StableKey fields, duplicate keys, collection size, nesting depth and total state/task/event reservations. No mutation or unmount before successful preflight. Provisional first-host budgets: at most **256 live items per ForEach**, **8 nested ForEach levels**, and at most **4096 live dynamic nodes per UI root**; actual D5 memory caps and enforcement must still be reviewed. Exceeding budget -> AUI_LIST_BUDGET.
2. Build a one-to-one map of **(template identity, parent identity, tagged StableKey, child component TypeID)**. The old/next order is NOT part of identity. Old-key and same-type matches retain the same ViewIdentity and incarnation generation, local compatible state slots, live TaskSlot ownership, focus target and subscriptions (subject to exact component/source/target compatibility).
3. A key absent from next list is removed and its view enters UNMOUNTING (K4). A new key creates a **fresh monotonically assigned generation**, never reusing an old incarnation. The same key with **different component TypeID**, template identity or parent identity is a removal plus independent insertion with fresh generation; no hidden cross-parent state transfer.
4. If a key moves position within the same parent list, preserve identity/generation/state. Layout coordinates, paint caches and focus order can change; old index must not be used for event routing.
5. Evaluate all new desired-view bindings, children, derived values, accessibility semantic tree, focus transfer and provisional resource reservations against the candidate. If any fails, abort candidate with the last committed tree and StateRevision intact; any preallocated candidates are cleaned up without externally visible effects.
6. Publish a single coherent committed tree/reconciliation revision *after* successful validation. Unmount teardown runs as an owned, bounded lifecycle follow-up: detach event routing and subscriptions first, then request scoped task cancellation, drain callbacks safely; UI state cleanup only when no current live readers and ownership obligations are proven. Actual rendering/presentation may lag the committed revision and failure must not reissue provider operations.

A state change that drives a new List<T> must use the same atomic [L2 StateRevision transaction](d3-state-derived-binding-contract.md); **no intermediate partially reconciled tree is exposed**, and no commands may be launched during pure reconciliation. As with L2, this does not create a disk/GraphRevision transaction and is not atomic with hardware or remote I/O.

## K4. View lifecycle and event-generation safety

Candidate lifecycle state machine:

    ABSENT -> MOUNTING -> MOUNTED -> UNMOUNTING -> ABSENT

- MOUNTING allocates unique generation, initializes state strictly once for that incarnation and installs subscriptions only after candidate validation; before MOUNTED, no user event or provider completion may target it.
- MOUNTED accepts events tagged with the exact (ViewIdentity, incarnation generation, source/snapshot/owner, ingress sequence). Reorder preserves generation; stale visual indices/coordinates do not redirect input.
- UNMOUNTING closes new event admission *before* releasing old callbacks, timers, focus/IME resources and view-owned task subscriptions. A queued old-generation event is marked AUI_EVENT_STALE; it is never retargeted to an inserted item with the same key.
- Removal/parent change/type replacement invalidates the old view completion target. A TaskTicket/provider CommandTicket remains with its **true D2/D4 owner** until normal terminal result or confirmed cancellation/quiescence. View teardown cannot free DMA/device/OS resources simply by invalidating a UI node.
- After teardown and owner-safe cleanup, ABSENT may later receive the identical StableKey; its **generation MUST be fresh**. A key is logical equivalence within one live revision, not a timeless right to reuse a previous UI instance.

No guarantee of exactly-once native callbacks, OS event delivery or duration is implied; D4/D5 must prove unsubscribe/drain memory ordering, post-unmount event filtering and teardown progress. Bounded teardown that cannot complete immediately retains a zombie **runtime resource owner** separate from visible ViewIdentity, with explicit outstanding-resource accounting and backpressure; it cannot keep an invisible active UI subscription or silently leak an unbounded number of owners.

## K5. Focus, accessibility, and renderer

- **Reorder:** preserve focused ViewIdentity if it remains mounted; recompute its visual index and accessibility reading order from next child vector. Keyboard hit-testing uses committed view generation, not an outdated list index; focus restoration during renderer lag must not deliver an action to a newly inserted child.
- **Remove focused item:** revoke that focus/IME target before next input dispatch. Choose next focus using a separately approved deterministic D5 policy (first surviving successor in new visual order, otherwise preceding predecessor, otherwise nearest focusable ancestor is a candidate, NOT accepted). Never send an input to a removed child merely because its former coordinates are occupied.
- **Accessibility:** stable semantic node identity derives from live ViewIdentity generation; labels and order may change without resurrecting removed nodes. Screen reader events must reject stale generation.
- **Layout/scene:** order/geometry/paint invalidation are D5 rendering concerns. Render tree/caches cannot be the canonical state/identity authority. A failed present cannot roll back a committed UI StateRevision or replay a Task/command.

## K6. D2/D4/D5 safety and ownership invariants

Dynamic views do not create persistent GraphNodeIDs or graph edges. A row component requiring a graph operation must have an explicit source-to-Graph provider mapping and approved target/effect contract, including per-instance owner scope. A copied child template does NOT implicitly clone a physical driver or privileged capability.

The L3 TaskSlot identity must include the **full parent keyed item path plus incarnation generation**, not just lexical source TaskSlot ID. Duplicate rows cannot share a TaskSlot. Reorder retains the active task's subscriber; deletion invalidates only that row's subscription and requests scoped cancellation. A callback for an old incarnation must be diagnosed AUI_TASK_STALE and must not commit UI state under a new incarnation with the same StableKey.

D4 owns physical handle/table layout, lifetime and atomics; D5 owns memory, event queue, focus/IME/accessibility, layout/paint scheduling and total task/result backpressure; D2 owns graph provider and workflow CommandTicket. These owners must not assume candidate UI keys grant command access.

## K7. Candidate diagnostics and future fixture matrix (NOT-RUN)

| Mutation / lifecycle | Primary candidate result |
| --- | --- |
| Same key twice in one next list | AUI_KEY_DUPLICATE; no partial reconciliation |
| Missing or unsupported key field type | AUI_KEY_TYPE / AUI_KEY_MISSING |
| Index/position used as key | AUI_KEY_POSITIONAL |
| String key > proposed bound | AUI_KEY_TOO_LARGE |
| Over-budget count/depth | AUI_LIST_BUDGET |
| Same-parent reorder a,b,c → c,a,b | Preserve ViewIdentity/generation/state, update visual order |
| Insert d into a,b,c | Fresh incarnation for d only |
| Remove b then reinsert later | Fresh generation for b, no restored old task/UI state |
| Change item component type for same key | Unmount old + mount new, fresh generation |
| Move key to different parent list | No implicit state transfer; fresh generation |
| Replace source template without proven StableSymbolID continuity | Fresh generation or explicit SOURCE_STALE_REVISION review |
| Old-gen event after unmount | AUI_EVENT_STALE, no new-row handler |
| Old-gen CommandTicket completion after re-add same key | AUI_TASK_STALE, no new-row StateRevision |
| Cancel requested with device operation still active | Device buffer remains with provider until quiescence |
| Renderer fails after commit | Committed state remains; no re-dispatch |
| Duplicate key rejected after candidate allocations | No visible side effects, no leaked allocations |
| Focused row moves | Preserve focus identity, update position |
| Focused row removed | Revoke focus/IME, deterministic D5 fallback pending |

## K8. Architecture freeze blockers

Approve: exact List<T> and StableKey public core registry, source grammar and typed AST, StableSymbolID persistence/provenance, strict target-specific memory budgets, nested list semantics, parent/type migration, list item cross-domain ownership, deterministic focus fallback, subscription unregister/drain, external resource owner retention, ABA-safe generation allocation, D4/D5 target atomics and actual renderer/async races. Dynamic window recreation, virtualization and platform accessibility are future extensions requiring separate proof.

**All rules above are a documentation candidate; D3, D4 and D5 stay Proposed/Open.** 
