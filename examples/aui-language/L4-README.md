# L4 Keyed Dynamic View — Design Fixtures

The L4 fixture is **not a compiled AUI program**. The imported example.rows package, List<Row>, exact StableKey registry, source-profile authorization, native layout and renderer are not approved or implemented. See [L4 contract](../../docs/architecture/d3-keyed-dynamic-view-lifecycle.md) and [D3↔D4↔D5 review](../../docs/architecture/d3-d4-d5-lifecycle-consistency-review.md).

- [keyed-rows-l4.aui](keyed-rows-l4.aui): conceptual typed ForEach with explicitly selected immutable record id; no index fallback, no direct OS/I/O.
- [l4-reconciliation-trace.json](l4-reconciliation-trace.json): input actions and expected ViewIdentity generations/state/surviving paths for a **small deterministic reference-model check**, not an AELYXORA runtime result.
- [l4-negative-cases.json](l4-negative-cases.json): syntax/type/ownership/reconciler/ABI/renderer rejection scenarios; native results **NOT-RUN**.

Trace path p/a is illustrative path notation for a nested tuple, **not** a normative serialization format, hash input, or slash-delimited runtime key; production identity must use length-framed tagged values.

The trace models only reconciliation identity and acceptance. It does not model actual StateRevision CAS, TaskTicket/CommandTicket ownership, native memory ordering, focus/IME, GPU fences or device quiescence. All those gates remain open.
