# D3+ — State, Derived and One-Way Binding Contract

**Status: PROPOSED design candidate, not architect-approved, implemented or tested.** This document owns the L2 extended AUI semantics for local reactive state, computed values and declarative one-way bindings. [L0/L1 grammar](d3-first-language-profile.md) remains unchanged and rejects state/derived/bind/commit with AUI_PROFILE_UNSUPPORTED. [Runtime](aui-runtime.md), [OwnershipIR](aui-ownership-ir.md) and [D3+ Task/Result](d3-task-result-lifecycle.md) own scheduling, borrow proof and asynchronous completion respectively.

## S0. Extension and authority

Candidate compiler source profile ID: aui.source/l2-state/v1. It is selected through a versioned, reviewed compilation context, **not** an unrecognized flag inside a 0.1-draft Project Graph. L2 extends the AUI language, not the project's canonical architecture. Local StateRevision is distinct from GraphRevision, semanticGraphDigest and D6 HEAD epoch. L2 cannot grant network, OS, MMIO or DMA permissions. Live resource access is governed by [D2/D3 Hardware Authority](d2-d3-hardware-command-boundary.md).

## S1. Bounded proposed syntax, L2 only

    stateDecl        = "state", ID, ":", typeName, "=", pureExpr, ";" ;
    derivedDecl      = "derived", ID, ":", typeName, "=", pureExpr, ";" ;
    bindingDecl      = "bind", boundTarget, "<-", pureExpr,
                       [ "using", qualifiedName ], ";" ;
    boundTarget      = "view", ".", viewKey, ".", propertyName ;
    stateCommit      = "commit", "{", setStmt, { setStmt }, "}" ;
    setStmt          = "set", ID, "=", pureExpr, ";" ;
    pureExpr         = pureAtom | pureCall ;
    pureCall         = qualifiedName, "(", [ namedArgs ], ")" ;
    viewKey          = ID ;
    propertyName     = ID ;

L2 event handlers accept exactly one L1 send OR one stateCommit, with no implicit ordering between external effects and local changes. Result completion handlers may contain a stateCommit as separately defined in [D3+ Task/Result](d3-task-result-lifecycle.md). Future combined send+commit transaction requires an explicitly versioned effect ordering profile.

A child view targeted by a binding carries a static, source-stable key via .key(value: StableID). The StableID is a lexer ID, not a mutable string/value. Such keys are unique throughout the owning component's static view tree and scoped to its component instance. A view key is not a GraphNodeID, TypeID, source line or persistent project ID. The L2 property lookup form view.keyName.propertyName refers only to an explicitly bindable property of this own static child; cross-component private state is never addressable.

The L2-specific Text core catalog may allow Text().key(value: statusLabel) with its value supplied by one binding. This does not make Text(value: ...) optional in L0/L1, which retains its mandatory named argument contract. No arbitrary pure function or dynamic child collection is admitted by this fragment.

## S2. State identity, lifetime, and initialization

Conceptual runtime slot identity: (ProjectID, pinned semanticGraphDigest, component GraphNodeID/instance, ViewIdentity, generation, source StableSymbolID, resolved StateTypeID). Its storage bytes and handles are **not** serialized as Project Graph semantics or D6 project snapshot. State may persist between compatible re-renders of the **same** view generation; unmount/remount allocates a new generation and cannot inherit stale task result handlers.

State initialization is pure, deterministic, typed and bounded. The owner component alone may write, on the UI state scheduler. A worker completion arrives via a typed, owned/copy message, never by a worker writing a UI pointer. Resource-bearing values must pass [OwnershipIR](aui-ownership-ir.md); an unproven Borrow/StringView/native handle cannot be stored or cross an await. Destroying a view requests cancellation of scoped tasks but does not prematurely free device buffers.

Automatic disk persistence of local UI state does not exist. User-data persistence requires a separate explicit D5/D6 data-store contract, not an architecture snapshot mutation.

## S3. Derived dependency graph and purity

Derived declarations form a typed deterministic DAG of dependencies on immutable inputs, owned state and other derived values. Resolve all symbols to source declaration IDs; a declaration order is not a semantics-dependent evaluation order. A pure converter/function must be pinned to an exact verified contract with bounded execution/memory and no I/O/async/hardware effects. An unchecked native symbol cannot acquire pure status by a name.

Reject cycles (AUI_BIND_CYCLE), unresolved source (AUI_BIND_SOURCE_UNKNOWN), illegal effect (AUI_ILLEGAL_EFFECT), asynchronous pure evaluation (AUI_AWAIT_CONTEXT). No implicit numeric widening, units conversion or String coercion. Pure expressions read one consistent StateRevision, never a mix of old/new state.

## S4. One-way bindings and single writers

A bind has exactly one statically keyed owned view target and one pure, type-compatible observable source. A converter (using name) is allowed only if explicitly verified pure and correct for source/destination TypeIDs and units. A binding never writes back to the source state slot.

One binding writer per (ViewIdentity, key, property). Constructor literal/default expression **plus** a binding to the same target is a writer conflict; a catalog may mark a property as optional in L2 specifically when bind supplies it. No hidden priority rule. Unknown target/key, read-only/remote property, duplicate keys or type mismatch -> AUI_BIND_TARGET_UNKNOWN, AUI_BIND_READONLY, AUI_IDENTITY_DUPLICATE, AUI_BIND_WRITER_CONFLICT or AUI_TYPE_MISMATCH. An input edit emits a typed intent; a separately authorized command/commit may then update the state. No implicit two-way synchronization or reactive side-effect loop.

## S5. Atomic UI StateRevision transaction

1. Verify source ViewIdentity generation, owning component and expected StateRevision. Old-generation completion cannot write.
2. Resolve every state name and RHS against the **same pre-commit** revision; commit assignments are simultaneous, never declaration-order cascades.
3. Reject duplicate set to one slot (AUI_STATE_DUPLICATE_WRITE), untyped/borrowed writes, forbidden effects and unsupported large commits. The provisional first-host limit is 16 set operations per commit, otherwise AUI_STATE_BUDGET.
4. Build candidate state, recompute dirty derived DAG nodes in deterministic topological order, then their owned bound view values; check types, cycle/alias/ownership and resource budgets **before** publication.
5. Atomically publish one new UI StateRevision for this component using a UI-scheduler compare-and-swap. A failed candidate leaves all previous slots unchanged. Two conflicting commits: one may succeed, the other reports AUI_STATE_STALE; no implicit retry of external commands.
6. Publish coherent view invalidation to D5 renderer. A subsequent drawing/GPU failure does NOT undo an already committed state revision or replay the command. Drop abandoned owned candidates exactly once after lifetime proof.

A UI state commit is **not** atomic with D2 workflow state, device/network effects or D6 project snapshots. It cannot modify graph topology, capabilities or target claims.

## S6. Interface to D2 workflows and asynchronous results

The D2 CommandTicket/ExecutionID and the UI ViewIdentity/generation/StateRevision are different namespaces. An L2 completion may update state only after D3+ exact ticket-to-view correlation and live generation/revision check; this is defined by [Task/Result](d3-task-result-lifecycle.md). A worker cannot keep an unbounded borrow of UI state. Commit invalidation never itself dispatches a command.

Dynamic lists, keyed child recycling, task launch-on-state-change and multiwriter propagation are *not* silently included. They require separate grammar, identity, scheduling and cycle contracts.

## S7. Future acceptance cases (NOT-RUN)

| Case | Expected |
| --- | --- |
| Pure L2 State String + Derived identity + bound keyed Text | Candidate typed, no effects |
| Same source in L0/L1 | AUI_PROFILE_UNSUPPORTED |
| Two binds or constructor literal and bind to same property | AUI_BIND_WRITER_CONFLICT |
| Unknown key or readonly destination | AUI_BIND_TARGET_UNKNOWN / AUI_BIND_READONLY |
| Derived self-reference or cross cycle | AUI_BIND_CYCLE |
| Derived sends command or awaits | AUI_ILLEGAL_EFFECT / AUI_AWAIT_CONTEXT |
| One commit assigns same state slot twice | AUI_STATE_DUPLICATE_WRITE |
| Wrong commit type/units | AUI_TYPE_MISMATCH, no partial publication |
| Two commits with same expected revision | Exactly one succeeds, other AUI_STATE_STALE |
| Old view generation returns after unmount | AUI_EVENT_STALE, no state change |
| Pure layout movement | StateRevision and semanticGraphDigest unchanged |

**Open P0:** architect selection of L2 scope/grammar, core property signatures and pure function digest registry, exact stable-key/ViewIdentity rules, bounded renderer/allocator proof, transaction CAS memory ordering, deallocation and independent positive/negative native tests. This document alone does not close D3.
