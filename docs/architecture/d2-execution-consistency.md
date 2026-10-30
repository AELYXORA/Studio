# D2 — Execution, Concurrency, Ownership and Consistency Contract

**Status: Proposed for human review; not accepted, implemented, or runtime-tested.** This is the D2 owner for workflow execution ordering, command dispatch, resource-transfer policy and transaction boundaries. [Graph Behavior](graph-behavior-contract.md) owns workflow/data-flow definitions; [Project Graph](project-graph.md) owns identities; [AUI Runtime](aui-runtime.md) and [Binary ABI](aui-component-binary-abi.md) own implementation and memory layout; [Project Format](project-and-package-format.md) and [Validation](graph-validation-and-migration.md) own on-disk durability. No text here certifies correctness or platform support.

## E0. Bounded first execution profile

The initial execution profile is **one process**, in-memory, bounded, with explicit native component providers. Active ExecutionIDs, queues and command tickets do NOT survive process termination. Project *definitions* persist separately. There is no durable exactly-once messaging, automatic crash replay, global event order, hard real-time guarantee or guaranteed physical-device cancellation. Such features require new reviewed contracts, not implicit promises.

Every executable workflow declares a concurrency admission policy and every active data-flow edge has a bounded typed transport policy. The graph itself never grants filesystem, network, process or hardware execution authority. Unsupported execution requirements are rejected rather than silently emulated.

## E1. Event identity, ordering and deterministic transitions

A logical signal envelope contains ProjectID, semanticGraphDigest, WorkflowID, workflowDefinitionRevision, ExecutionID, instanceGeneration, SignalID, canonical payload TypeID, origin node/edge, per-producer sequence when supplied, per-instance ingressSequence and payload ownership descriptor. This is a logical contract, NOT a binary struct.

- **Per-instance FIFO:** the first runtime profile serializes transition evaluation and state commits per ExecutionID. It assigns a monotonically increasing ingressSequence only when a bounded instance mailbox accepts a signal. No global order across executions, threads, channels or process crashes is promised.
- **No recursive transition processing:** follow-up signals enter the mailbox, not nested handler dispatch. A given state and SignalID may identify at most one transition. A second such transition is WORKFLOW_NONDETERMINISTIC; guards and priority are outside the first slice.
- **No silent duplicate suppression:** repeated external events are distinct unless their producer has an explicit idempotency policy. A late, unknown or already-terminal signal is reported as such; it cannot re-run a command.
- **Bounded admission:** workflow scheduling is per-instance-fifo, maxConcurrentInstances >= 1, onLimit = reject-and-report, mailboxCapacity >= 1 and mailboxOverflow = reject-and-report. Limit failure gives WORKFLOW_ADMISSION_REJECTED or WORKFLOW_MAILBOX_FULL with no unbounded allocation.
- A data channel may accept an item that a downstream workflow later rejects; channel acceptance is not workflow acceptance. The producer must see observable rejection and backpressure counters. Capacity values must be checked against target resource budgets at build/runtime.

## E2. Typed signals and exact command provider linkage

A workflow explicitly declares signals with stable IDs and sources:
- trigger: carries the exact receiver-port TypeID of the bound triggering data-flow edge;
- command-success: bound to a specific GraphNodeID + exported operation, payload equals declared success result TypeID;
- command-failure: same provider/operation, payload equals its error TypeID;
- control: only runtime-owned cancel and cancel-confirmed in the initial candidate; no arbitrary user text can impersonate these system signals.

Unknown signal -> WORKFLOW_SIGNAL_UNDECLARED, wrong payload -> WORKFLOW_SIGNAL_TYPE, unresolved command/export -> WORKFLOW_PROVIDER_UNRESOLVED. Exact export identity is resolved through the locked package and target contract, not a filename or display name. The operation's ABI representation remains D4.

Each accepted dispatch creates one logical CommandTicket referencing ExecutionID, transition ID, operation export, graph revision/digest, instance generation, owned input, declared effects, target domain, capability proof reference, unique ticketId and outcome. A ticket is not an implicit replay or network deduplication key.

**Dispatch transition protocol:**
1. Validate the input signal and exact command contract.
2. Check actual, current permission for all effects, separately from architecture-change approval. A revoked token blocks execution; failure is CAPABILITY_DENIED.
3. Reserve task capacity, result/error delivery and safe ownership of inputs. If reservation fails, no ownership transfer; report RESOURCE_BUSY or OUT_OF_MEMORY.
4. Commit the next workflow state and its task reservation atomically **within this runtime process**, not to disk.
5. Schedule the provider after commit. Failed submission produces one typed command-failure outcome; it cannot be advertised as completed work.
6. When provider returns, validate ticket, result TypeID, instance generation and graph snapshot; publish only one matching signal. Duplicate/late results are diagnostics and never a second state mutation.

A transition to the decoding state means **dispatch accepted**, not **device operation physically complete**. External I/O, remote effects and hardware actions are NOT atomic with this local state update. No automatic retry for ambiguous external effects; operation contracts must state none/local-reversible/external-nonreversible and idempotency/retry policy. The first profile defaults to no automatic retry.

## E3. Cancellation race and terminal outcome

Cancellation is a **request flag**, not a terminal result. The first sensor workflow must be modeled as:

- waiting + sample-arrived -> decoding, dispatch Decode;
- waiting + cancel -> cancelled (only before a command ticket exists);
- decoding + cancel -> cancelling, issue request-cancel against active ticket; do NOT release its buffers or publish terminal cancelled;
- decoding + decoded -> done, publish the valid measurement;
- decoding + decode-error -> failed, without publishing a fake measurement;
- cancelling + cancel-confirmed -> cancelled (only on confirmed provider quiescence);
- cancelling + decoded -> done, because successful completion may win despite a cancellation request;
- cancelling + decode-error -> failed; no fake success.

Every ExecutionID has one **terminal publication linearization point**: atomic check of nonterminal state and current instance generation followed by one final commit. Competing terminal completions are diagnostic only (WORKFLOW_TERMINAL_ALREADY_PUBLISHED). Stale generation is WORKFLOW_COMPLETION_STALE. This is a logical invariant; exact atomics and memory ordering must be proven in D4/D5 on each target.

A provider may still own buffers after a user-visible deadline or cancellation request. The resource-owning ticket must live until proven device quiescence or safe ownership handoff. A deadline-exceeded result does not prove the device stopped. Process restart cannot silently replay an unfinished external command.

## E4. Resource ownership and bounded channels

A logical transferable value has canonical TypeID, owner, lifetime/generation and target execution domain. Native handles are never serialized into project files.

| Mode | Accepted delivery | Rejected delivery |
| --- | --- | --- |
| copy | Receiver owns newly allocated copy, producer retains original | Temporary allocations cleaned; producer unchanged |
| move | Ownership transferred **only upon** accepted queue/command reservation | Producer keeps original, no double-release |
| borrow | Bounded synchronous same-domain call only; never queued, awaited or passed across workers | FLOW_CROSS_DOMAIN_BORROW if attempted |
| device/DMA | Separate opaque platform capability and active operation lease | Buffer cannot be reclaimed before physical completion/acknowledged stop |

For drop-oldest, release evicted owned payload exactly once and report the loss; drop-newest must not leak the rejected payload. For reject, retain sender ownership and report FLOW_BACKPRESSURE. Blocking overflow is illegal on UI/IRQ/nonblocking domains. Cross-domain copies require a verified safe representation or explicit serialization, not a raw pointer. UI ViewIdentity or render thread does not own driver/DMA memory.

Resource budget includes bounded mailbox slots, channel descriptors, payload maximums, task tickets, provider in-flight buffers and allocation overhead. Unknown unbounded payload size or buffer growth is an explicit unsupported condition, not a guessed constant.

## E5. Model CAS, publication and coexistence with running instances

An architecture change is a staged **candidate** with ProjectID, expectedRevision, expectedSemanticDigest, operationId, affected graph/source IDs, declared capability changes and exact proposed patches.

1. Start from immutable revision N and locked exports. Validate *all* topology, workflow/data-flow references, typed operations, source ownership and capability changes as one candidate.
2. Compare expectedRevision and expectedSemanticDigest to the current published snapshot. Mismatch -> PROJECT_STALE_REVISION, no mutation. Detect duplicate operationId according to the versioned D6 journal contract.
3. Calculate a candidate semantic digest (byte-level canonicalization belongs to D6). View-only pan/zoom and selection use independent ViewRevision; they do not increment semantic GraphRevision or invalidate native build hashes.
4. Stage project and source changes together. Publish revision N+1 only after D6 durable commit succeeds. A partial multi-file save must **never** be presented as a valid architecture revision. This requires a D6 crash journal or manifest-pointer protocol, not just renaming one file.
5. Undo/redo is another revision-checked graph transaction; it cannot undo network packets, physical hardware commands or other external effects.

Existing running workflow instances retain their old **validated graph/package snapshot** and capability constraints until safe cleanup. New project revision applies only to newly created instances. Old snapshots cannot be released while live provider tickets refer to them. A change requiring new capabilities does not retroactively authorize old instances.

**Atomicity boundary:** graph-file publication is a D6 durable transaction; workflow state transitions are in-memory, instance-local transactions; OS/remote/hardware effects are separate external operations. These three cannot be called one ACID transaction. UI rendering failures after state commit must not rerun already dispatched commands.

## E6. Error and diagnostic cases

| Condition | Expected outcome |
| --- | --- |
| Same state and signal has two outgoing transitions | WORKFLOW_NONDETERMINISTIC (design) |
| Referenced signal missing | WORKFLOW_SIGNAL_UNDECLARED (design) |
| Command result signal has mismatched type | WORKFLOW_SIGNAL_TYPE (design) |
| Zero mailbox/instance bound | SCHEMA_INVALID (design/structural) |
| Execution admission limit hit | WORKFLOW_ADMISSION_REJECTED (runtime) |
| Mailbox full | WORKFLOW_MAILBOX_FULL (runtime) |
| Capability unavailable or revoked at dispatch | CAPABILITY_DENIED (runtime, no effect) |
| Queue move rejected for capacity | FLOW_BACKPRESSURE (runtime, sender retains ownership) |
| Late completion from replaced generation | WORKFLOW_COMPLETION_STALE (runtime) |
| Second terminal outcome after winning one | WORKFLOW_TERMINAL_ALREADY_PUBLISHED (runtime) |
| Stale candidate graph revision/digest | PROJECT_STALE_REVISION (model transaction) |
| Delete graph edge referenced by workflow/channel | GRAPH_REFERENCED_EDGE (model transaction) |

Diagnostics include target, graph/workflow/execution identity, event/ticket origin, actual and expected contract and artifact digest, without secrets.

## E7. Required acceptance fixtures for later Phase III (currently NOT-RUN)

1. Per-instance FIFO with two independent instances; no global order assumption.
2. Duplicate (state,signal) transition rejected before code generation.
3. Concurrency/mailbox limits enforce bounded admission and report losses.
4. Command provider missing, wrong signal TypeID and revoked effect denied without execution.
5. Cancel while waiting yields cancelled with zero dispatched commands.
6. Cancel while running enters cancelling; successful result versus cancellation confirmation races yield **one truthful terminal outcome**.
7. Late/duplicate completion cannot update successor generation or release ownership twice.
8. Cross-domain borrowed value rejected; rejected moved value remains with sender.
9. Queue-full and drop-oldest never exceed memory budget and account for every owned payload.
10. Architecture candidate with stale revision changes no bytes; a view-only edit retains semantic digest.
11. Crash between staged files and canonical revision publication recovers wholly N or wholly N+1, never mixed revision.
12. Changing graph during a running command leaves that command pinned to old validated snapshot.
13. Project undo does not reverse already executed external effects.
14. Restart after crash never silently replays external effects.

**Unresolved P0 dependencies:** exact signal export format and operation provider schema; runtime scheduler/admission and atomics; ABI buffer layouts and platform allocator; resource budgets per target; D6 canonical digest and durable journal; target isolation and permission token semantics. The design is proposed but does not close D2 or D4/D5/D6 by itself.


## E8 — Canonical identity and durable boundary (cross-gate proposal)

[D2 Identity](d2-identity-and-type-resolution.md) separates GraphRevision, TypeID, SourceSpan, ExecutionID and ViewRevision. [D6 Canonical Persistence](d6-canonical-persistence.md) proposes immutable snapshots and two validated HEAD slots. A valid in-memory CAS is **not** evidence that a multi-file save survived power loss. Running commands pin an old validated graph/lock, but their transient tickets are **not persisted or replayed** by the D6 snapshot protocol. On reopen, the newest verified committed graph definition may be loaded; the fate of an external operation that was in-flight before crash stays **unknown**, requiring explicit user/operator reconciliation.