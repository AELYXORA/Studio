# Canonical Project Graph — unified sensor example

**PROPOSAL ONLY. NOT a validated or executable project.** This illustrates the ONE AELYXORA semantic graph; it does not define product/architecture editions.

- [sensor-project.auiproj.json](sensor-project.auiproj.json): seven nodes, six edges, one complete typed state machine with cancellation, one dataFlow, retired IDs and four hardware claims (DMA, IRQ, MMIO and memory) inside the SAME Project Graph.
- [sensor-package.auipkg.json](sensor-package.auipkg.json): typed component port/command and record representation, including exact shape of one TypeReference system.

**Every 64-character hex digest inserted during this conversion is deliberately SYNTHETIC PLACEHOLDER DATA, not a computed public contract digest, approved core registry, signed operation, or package lock.** The example's hardware target is NOT certified or executable, and the package source has no qualified native ABI. Semantic verification must reject unproven type/operation/target exports and reject unapproved physical access.

The historical sensor example was read without editing. We converted its meaning-bearing workflows, dataFlow policies, resource claims and edges into one design-only graph without omitting them.

Authoritative design direction: [One Canonical Project Graph and Component Model](../../docs/architecture/canonical-project-graph-and-components.md). The JSON schemas check shape, not signer permissions, actual hardware, runtime scheduling or ABI. D1–D8 still await human approval.

[32 proposed rejection scenarios](negative-cases.json) cover type mismatches, workflow transitions, dataFlow ownership/backpressure, hardware claims, retired identity reuse and approval; they are test designs, not executed outcomes.
