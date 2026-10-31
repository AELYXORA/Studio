# D3+ — L2/L3 Documentation Fixtures

These files exercise the **proposed** advanced syntax and never assert compiler, ABI, runtime or target success.

- [L2 FeedbackPanel](feedback-panel-l2.aui): state, one pure derived value, a keyed Text one-way binding and a single atomic local commit.
- [L3 ReviewPanel](review-panel-l3.aui): pinned proposed provider contract, Task with one await, bounded TaskSlot submit and **exhaustive TaskOutcome match**. The visible status distinguishes Successful, Failed, AdmissionRejected, Cancelled only after confirmation, and ProviderUnavailable.
- [Negative scenarios](d3plus-negative-cases.json): future static/link/ownership/runtime diagnostics. None has been run by an AELYXORA compiler.
- [L2 contract](../../docs/architecture/d3-state-derived-binding-contract.md), [L3 contract](../../docs/architecture/d3-task-result-lifecycle.md) and [source-to-Graph boundary](../../docs/architecture/d3-source-snapshot-reconciliation.md).

**Known missing prerequisites:** source profile selection and core library digests, L2 optional bound Text property and static key signatures, UI StateRevision engine, exact imported Tick/Failure registry, approved source-to-Graph command link and immutable snapshot inclusion, D2 provider ABI, TaskOutcome runtime, target permissions, actual on-target tests. The ReviewPanel fixture is NOT part of the locked pure reference's committed immutable snapshot. Neither fixture is executable or L0/L1-legal.

A good source grammar fixture is not permission to mutate an architecture graph, launch an operation, or access hardware.
