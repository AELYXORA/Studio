# Project Graph v2 — Typed Reference Slice

**PROPOSED / NOT-RUN.** This directory holds design references for the separately versioned typed component/port/data-edge extension to the one canonical Project Graph.

[Graph source](typed-graph-project.auiproj.json) contains RowProvider and RowViewer nodes joined by one exact List<Row> typed port edge. [Reference digest vectors](typed-component-contract-vectors.json) provide SHA-256 over the operation, two component public contracts, the type export set, and new typed semantic graph projection. Those hashes were computed by an independent reference function and independently checked with Python hashlib.

[35 negative test designs](typed-graph-negative-cases.json) are future diagnostic/race cases. They have not been run in AELYXORA. No compiler, verified package lock, trusted native module, active storage backend, source approval, PE/COFF build, Windows renderer or OS ABI test exists for this example.

The bounded v2 slice requires empty workflows and dataFlows and forbids hardware resourceModel; it never silently drops legacy v1 meaning. Source revision and display-only label do not enter semanticGraphDigest. Existing v1 hashes and pure reference fixtures are unchanged.

[Full typed graph contract](../../docs/architecture/d2-d6-project-graph-v2-typed-contract.md).
