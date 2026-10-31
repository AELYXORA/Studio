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
