# Project Graph Validation, Dependency Resolution and Migration

**Status: proposed contract; not implemented.** Applies to the illustrative JSON manifests under `examples/architecture-sensor`. This document refines [Project and Package Format](project-and-package-format.md). It does not make JSON the final persistent representation.

## D2 behavioral graph validation (design proposal)

Follow the single-owner [Graph Behavior Contract](graph-behavior-contract.md). The graph validation pipeline must also validate:
- **Taxonomy:** canonical edge kinds (including `hosts` as physical topology, distinct from `containment`) and legal endpoint classes. Unknown kind: `GRAPH_EDGE_KIND_UNKNOWN`.
- **Data flow:** binding EdgeID references an existing data-flow edge; no duplicate active binding; strict type/units, exclusive writer, sender/receiver execution domain, transfer ownership, stream capacity and overflow policy; reject cross-domain borrows.
- **Workflow:** owner and trigger references, initial/terminal states, reachable transitions, no ambiguous duplicate (from,signal), exact action target and export, publish edge/source consistency, required capabilities and execution domains.
- **Deletion:** a transaction that deletes an edge but leaves a workflow or binding pointing to it rejects with `GRAPH_REFERENCED_EDGE`; a coordinated valid update may remove both.
- **No implicit execution:** validation can accept a structural flow graph without granting hardware operations, scheduling guarantees, or provider implementation; only a linked and authorized native implementation can execute.

**Deterministic error precedence** (proposal): UTF-8/JSON parse -> structural schema -> unique IDs -> references -> typed endpoint/direction -> flow policies -> workflow rules -> target/capabilities -> transactional publication. For a single fixture with multiple errors, report primary error according to this sequence, then secondary errors sorted by code and stable ID. An invalid capacity zero is structurally rejected as `SCHEMA_INVALID` by the draft schema; `FLOW_CAPACITY_INVALID` is an additional possible semantic diagnostic only for an object entering the semantic layer without the schema gate.

## Validation stages (ordered)

1. **Decode:** strict UTF-8 JSON; reject duplicate object keys, truncated data, invalid numbers, excessive nesting/size and unsupported format/schema versions. Never execute package content while parsing.
2. **Shape:** verify required fields, types, nonempty identifiers, integer nonnegative project revision, permitted enum values, and unknown required features. Preserve optional extension keys only under explicitly namespaced fields.
3. **Identity:** unique project node IDs and edge IDs; unique target IDs, component type IDs and port IDs per component. IDs are stable under layout changes and cannot be reassigned to a different identity.
4. **References:** verify target references, package/type references, edge endpoints, and endpoint port existence. Every data-flow edge needs an output source and input destination with exactly matching canonical type identity. A display label is never a type identity.
5. **Graph semantics:** detect illegal containment/first-profile hosts cycles, unknown edge kinds, duplicate exclusive resource claims, unsupported execution-domain transitions and synchronous dependency cycles without an explicit delay/buffer edge; resolve data-flow bindings and workflow state-machine references before declaring a candidate semantically valid.
6. **Hardware/target:** validate target triple, ABI compatibility, execution privilege, address-space/range constraints, IRQ/MMIO/DMA capability and required platform adapters. Unknown hardware support is an explicit unsupported/unknown status rather than assumed success.
7. **Package resolution:** locate exact package IDs and versions from a lockfile or explicit local vendor directory; check hash, required dependencies and target coverage before accepting the build graph.
8. **Publication:** stage a candidate revision; validate all layers; atomically replace the canonical snapshot only if the expected prior revision matches. On failure the old revision remains authoritative.

Diagnostic fields: code, severity, JSON pointer or source span, graph node/edge ID, expected, observed and explanation. Diagnostics are deterministic on the same graph and target profile.

## D2 nominal identity and D6 canonicalization checks (design proposal)

[D2 Identity and Type Resolution](d2-identity-and-type-resolution.md) requires stable namespace-qualified identities; a logical TypeID resolves through an **exact locked package content digest and exported contract identity**, never a display name alone. Decode/export names in illustrative fixtures are declarations, not proof of callable native code. Duplicated/retired IDs, missing provider linkage, target or contract drift fail at their respective semantic or build stage.

[D6 Canonical Persistence](d6-canonical-persistence.md) owns strict UTF-8 parsing, decoded duplicate-key rejection, canonical semantic projection and content digest, source-hash CAS, crash-consistent HEAD-slot selection and immutable source snapshot recovery. These are D6 design proposals. Diagnostic ordering: parse/encoding -> structural schema -> duplicate/retired identities -> locked package/export resolution -> typed edges/workflow -> permission/target -> snapshot validation and publication. A stale source hash must produce SOURCE_STALE_REVISION, not force a silent graph rebase. A torn or unverifiable snapshot must be rejected, never executed.

## Version and dependency rules

Version namespaces are separate: project schema, package schema, component API, compiler grammar, native ABI and target profile. For the draft, dependency versions are exact SemVer-style strings. Resolve each dependency to a local artifact and verify a SHA-256 content digest recorded in an explicit lockfile **before** compilation. Offline mode must not silently fetch or upgrade packages. Missing hash, conflict, incompatible ABI or unsupported target is a deterministic error.

The canonical digest procedure is still open; do not claim byte-identical reproducibility from ordinary JSON formatting. A migration never upgrades dependencies implicitly.

**D2/D6 cross-gate review:** [Baseline contradiction and decision register](d2-d6-baseline-review.md) records the resolved-by-documentation logical-export-vs-package-digest conflict, the draft operationId HEAD/index linkage, and remaining unapproved persistence recovery policies. D2 does not claim platform crash safety merely because graph CAS passes in memory.

## D2 command / instance consistency boundary

[D2 Execution and Consistency](d2-execution-consistency.md) proposes expectedRevision + expectedSemanticDigest CAS, staged immutable graph snapshots, separate ViewRevision and pinning of old validated graph/package revisions for running instances. Graph publication is **not** atomic with external device/network effects. A proposed cancel request is **not** immediate physical cancellation. D6 still must define the exact bytes, durable operationId journal, fsync protocol and crash recovery algorithm; do not treat the D2 model as a completed durable storage design.

## Migration and crash consistency

A schema migration is a named `(fromVersion,toVersion)` transformation: copy the original, validate source schema, migrate into a new candidate, validate target schema, retain stable IDs, produce a readable diff and require approval for semantic changes. Unknown required fields block migration; no lossy silent conversion. Migrations must be idempotent or reject already-upgraded inputs.

A durable save requires writing a staged snapshot, flushing data and directory metadata as supported by the OS, replacing the canonical entry atomically where guaranteed, and maintaining a recoverable previous revision. Recovery selects the latest **fully validated** revision. Multi-file transactions need a journal or immutable manifest-pointer protocol; simple file rename alone does not commit several files atomically.

## Rejection fixture matrix

| Case | Code | Behavior |
| --- | --- | --- |
| Duplicate node ID | GRAPH_DUPLICATE_ID | Reject |
| Data-flow refers to missing node | GRAPH_MISSING_NODE | Reject |
| Output port to output port | GRAPH_PORT_DIRECTION | Reject |
| RawSample output to Measurement input | GRAPH_TYPE_MISMATCH | Reject |
| Reference to undeclared target | GRAPH_UNKNOWN_TARGET | Reject |
| Duplicate ownership of exclusive MMIO region | HARDWARE_RESOURCE_CONFLICT | Reject |
| Package version missing from local lock | PACKAGE_UNRESOLVED | Reject |
| Path traverses above package root | PACKAGE_PATH_ESCAPE | Reject |
| Stale expected revision | PROJECT_STALE_REVISION | Reject without mutation |
| Unsupported required schema | SCHEMA_UNSUPPORTED_VERSION | Reject |

## Acceptance conditions

A valid sensor example parses into stable graph identity, checks port directions and types, and retains positions across save/reload without changing architecture. Each invalid fixture is rejected with its expected code. A failed migration cannot damage the previously committed project.

**Known limitations:** the existing sensor package declares Assembly source paths that are not present; it is a **design fixture**, not a buildable package. No parser, schema validator, lockfile resolver, migration engine or durable save implementation exists.

**Deterministic negative D6 scenarios:** [Canonical vectors](../../examples/architecture-sensor/d2-canonical-vectors.json) propose exact byte/encoding rejection; [Recovery scenarios](../../examples/architecture-sensor/d6-recovery-scenarios.md) cover torn records, stale writers, and crash points. No native parser, journal or crash injection has run these scenarios.

**D6 source and recovery details:** [Package Integrity](d6-package-integrity.md) requires validated portable path inventory before computing lock digests. [Filesystem Adapters](d6-filesystem-adapters.md) keeps crash-durable publication conditional on the actual host/filesystem. [Integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json) are reference bytes, not runtime verification. Missing declared sources block a locked build; no implicit stubs or offline network retrieval.
