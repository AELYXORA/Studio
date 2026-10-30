# D2 — Sensor Runtime and Transaction Acceptance Scenarios

**Status: designed scenarios only. NO AELYXORA runtime, workflow engine, graph validator, or transaction journal has executed these tests. All observed results: NOT-RUN.** Requirements: [Graph Behavior](../../docs/architecture/graph-behavior-contract.md) and [D2 Execution/Consistency](../../docs/architecture/d2-execution-consistency.md). The illustrative [project manifest](project.auiproj.json) and [component package](component.auipkg.json) are not buildable and do not prove real device support. This file is a future test specification, not implementation evidence.

## Common fixture and instrumentation

- ProjectID: example.sensor-telemetry; WorkflowID: sample-to-measurement; data-flow e3 stream, capacity 32, reject overflow; e4 latest snapshot.
- Decode command is a *pure* example operation exported by example.sensor/decoder, with RawSample input, Measurement success, DecodeError failure. Declared sideEffectClass none, retryPolicy never. Target Linux AArch64 is PLANNED, not tested.
- The workflow has maxConcurrentInstances 32, per-instance-fifo scheduling, mailboxCapacity 8 and reject-and-report admission/overflow.
- Future harness must control fake provider completions/cancellation without accessing physical hardware. Hardware-specific behavior is separately gated by verified target adapters.
- Trace record: test ID, input manifest digest, tool/ABI/target identity, graph revision, ExecutionID, instance generation, ingressSequence, transition IDs, command ticket, authorization, state-before/after, owner transfers, output/result and exact diagnostics.
- For concurrency tests use a **controlled deterministic scheduler** that records input acceptance and completion order. Random scheduling may supplement but must not replace targeted interleaving cases.

## R01 — Two independent executions

Given two accepted RawSample triggers S1 and S2, allocate ExecutionIDs A and B. Advance A from waiting to decoding while B also enters decoding. Deliver success B then success A. Expected: both finish done, each with one terminal publication; output values correspond to their own inputs; no assumed global order between B/A; neither input is mistaken for another instance.

## R02 — FIFO and non-reentrant transition processing

For one ExecutionID enqueue two valid signals while the first handler is in progress. Expected: ingressSequence reflects accepted order; no nested transition processing. If a signal has no transition for the current state, record unhandled rather than fabricate a transition. Future test must compare sequence and transition ID exactly.

## R03 — Bounded admission and mailbox overflow

Hold 32 execution instances active, then submit a 33rd trigger. Expected: WORKFLOW_ADMISSION_REJECTED, no 33rd instance and no unbounded retained payload. Saturate the mailbox of an active instance with eight accepted signals, submit a ninth; expected WORKFLOW_MAILBOX_FULL, no hidden overwrite, no unexpected ownership transfer. Distinguish these failures from e3 stream queue-full outcomes.

## R04 — Command authorization and provider lookup

Offer a valid command but no live granted capability for an effectful variant. Expected: CAPABILITY_DENIED before provider execution, with no external effect. Change operationId to a non-exported value; the **design validator** rejects WORKFLOW_PROVIDER_UNRESOLVED before binary generation. Changes to package exports must invalidate graph/package digests.

## R05 — Cancel before command reservation

Deliver cancel to waiting instance before sample-arrived is accepted for that instance. Expected: terminal cancelled once; no Decode ticket; later sample/decoded signal is rejected as late-after-terminal, and no measurement is published.

## R06 — Cancel in-flight; cancellation confirmation wins

From decoding, request cancel. Expected immediate state cancelling (nonterminal); live command buffers retained. Deliver provider cancel-confirmed. Expected terminal cancelled exactly once, resources released after confirmed quiescence, no measurement output. Duplicate cancel-confirmed only produces WORKFLOW_TERMINAL_ALREADY_PUBLISHED.

## R07 — Cancel in-flight; success wins

From decoding request cancel, then provider returns decoded before cancellation confirmation. Expected cancelling -> done, e4 receives actual Measurement, one terminal publication. A later cancel-confirmed is diagnostic only, not a second terminal or resource release.

## R08 — Cancel in-flight; failure wins

From decoding request cancel, then provider returns decode-error. Expected cancelling -> failed, no e4 success publication. Future cleanup must not free a driver-owned buffer before provider quiescence.

## R09 — Stale generation and duplicate completion

Start instance generation G1, dispose its consumer, create successor generation G2, then deliver a G1 completion. Expected WORKFLOW_COMPLETION_STALE; G2 state not mutated; resource cleanup remains with G1 provider ticket. Deliver the same G1 result twice, and verify at most one ownership release.

## R10 — Move rejection and copy failure

Attempt move enqueue into full bounded channel; expected FLOW_BACKPRESSURE, original producer still owns payload. Attempt cross-domain borrow; design checker rejects FLOW_CROSS_DOMAIN_BORROW. Simulate allocation failure while copying; original remains unchanged and temporary receiver allocation is not leaked.

## R11 — Revision compare-and-swap

Begin candidate against revision N and semantic digest HN. Commit a separate semantic edit to revision N+1. Apply stale candidate with expected N/HN; expected PROJECT_STALE_REVISION and no candidate bytes published. Undo is a new checked transaction, not an uncontrolled file overwrite.

## R12 — View-only changes

Move a node on the Architecture Map, changing only ViewRevision. Expected semantic GraphRevision N and semantic digest HN unchanged; build input hashes unchanged. Reload the view and preserve positions without rewriting source or graph semantics.

## R13 — Crash during project/source multi-file save

For every future D6 durable journal step, inject process termination before/after persistence barriers and during publication. Recover either a completely validated revision N or a completely validated N+1, never a mix; source ownership and package hashes must agree. The exact crash points are BLOCKED pending D6 journal state-machine specification; this is not an executable fixture yet.

## R14 — Live instance under newer architecture

Instance A holds validated graph snapshot N and active Decode ticket. Commit new graph revision N+1 changing e3 capacity, with no permission escalation for A. Expected A finishes under N with old contracts, new instances use N+1, old snapshot is held until A cleanup. No retroactive provider swap.

## R15 — Physical effect is not undone by model revision

In a future authorized mock-device adapter, simulate an irreversible send. Revert the Project Graph revision. Expected project graph returns to an approved earlier state; sent/physical action is not pretended to be undone. Do not retry an ambiguous external outcome automatically.

## R16 — Crash and restart without implicit replay

Terminate process with in-flight command ticket and simulate an unknown external effect result. Reopen persisted project definitions. Expected no automatic restoration/re-execution of the in-memory workflow or external command, unless a separate, explicit future durable-workflow feature is designed and authorized. UI must label prior execution outcome unknown.

## R17 — Structural and semantic negative fixture precedence

Execute [D2 invalid cases](d2-invalid-cases.json) after implementing the strict parser and graph validator; verify exact first diagnostics, e.g. SCHEMA_INVALID for capacity=0 before any runtime allocation, WORKFLOW_SIGNAL_UNDECLARED for a missing signal, WORKFLOW_NONDETERMINISTIC for duplicate (state,signal), and WORKFLOW_SIGNAL_TYPE for mismatched command payload. This fixture set itself is *not* evidence of a run.

## R18 — Documentation/implementation boundary

Attempt to load the sensor package on an actual hardware target while its Assembly source files are absent. Expected build-level missing-source/provider failure, not fake hardware success. Pure design-time graph inspection may still be possible with an explicit unlinked/unsupported status.

## Future test result schema

Every scenario starts with outcome NOT-RUN and requires: testId, expected, observed, host, target, execution command, toolchain version/digest, input digest, output digest, signal/transition trace, memory ownership evidence, timing measurements where relevant, limitations and exact failure diagnostic. A failed test produces a Phase IV correction record linked to its requirement and rerun. No CI is introduced before release preparation.
