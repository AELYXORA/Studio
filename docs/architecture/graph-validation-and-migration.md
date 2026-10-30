# Project Graph Validation, Dependency Resolution and Migration

**Status: proposed contract; not implemented.** Applies to the illustrative JSON manifests under `examples/architecture-sensor`. This document refines [Project and Package Format](project-and-package-format.md). It does not make JSON the final persistent representation.

## D2 behavioral graph validation (design proposal)

Follow the single-owner [Graph Behavior Contract](graph-behavior-contract.md). The graph validation pipeline must also validate:
- **Taxonomy:** canonical edge kinds (including `hosts` as physical topology, distinct from `containment`) and legal endpoint classes. Unknown kind: `GRAPH_EDGE_KIND_UNKNOWN`.
- **Data flow:** binding EdgeID references an existing data-flow edge; no duplicate active binding; strict type/units, exclusive writer, sender/receiver execution domain, transfer ownership, stream capacity and overflow policy; reject cross-domain borrows.
- **Workflow:** owner and trigger references, initial/terminal states, reachable transitions, no ambiguous duplicate (from,signal), exact action target and export, publish edge/source consistency, required capabilities and execution domains.
- **Deletion:** a transaction that deletes an edge but leaves a workflow or binding pointing to it rejects with `GRAPH_REFERENCED_EDGE`; a coordinated valid update may remove both.
- **No implicit execution:** validation can accept a structural flow graph without granting hardware operations, scheduling guarantees, or provider implementation; only a linked and authorized native implementation can execute.

**Deterministic error precedence** (proposal): UTF-8/JSON parse -> structural schema -> unique/retired IDs -> exact offline lock and package/export resolution -> graph node/port references -> typed endpoint/direction -> data-flow policies -> workflow rules -> target/capabilities -> snapshot publication. For a single fixture with multiple errors, report primary error according to this sequence, then secondary errors sorted by code and stable ID. An invalid capacity zero is structurally rejected as `SCHEMA_INVALID` by the draft schema; `FLOW_CAPACITY_INVALID` is an additional possible semantic diagnostic only for an object entering the semantic layer without the schema gate.

## Validation stages (ordered, first-slice candidate)

1. **Decode:** strict UTF-8 JSON and supported schema versions; reject duplicate decoded keys, invalid Unicode/number tokens and resource budget violations.
2. **Shape:** structurally validate project/package/lock/index fields, types and unknown required extensions.
3. **Identity:** reject live/retired ID collisions and duplicates in their defined scopes before attempting package/type linkage.
4. **Offline locked package resolution:** validate the exact package dependency closure, immutable source objects, content digests and recomputed public type/component export digests. No ambient vendor directory or implicit version selection is an authoritative locked project. [D6 Resolver](d6-offline-dependency-resolution.md) owns deterministic dependency diagnostics.
5. **Graph references and nominal types:** resolve target/node/port endpoints and workflow command/signal exports against the validated registry; reject missing/wrong-direction or incompatible resolved types.
6. **Graph behavior:** enforce edge kinds and topology cycles, data-flow ownership/queue policy, exclusive writers, workflow state transitions, provider bindings, cancellation and budgets. In the first profile, queued stream/snapshot channels cannot borrow from a synchronous call.
7. **Target/capability review:** verify representable OS/ISA/resource constraints and declared effects independently from runtime permissions. Unsupported hardware/target constraints remain unresolved rather than implicitly granted.
8. **Semantic projection:** construct [D2/D6 exact semantic graph](d2-d6-semantic-projection.md) only after all upstream checks, then compute the domain-separated semanticGraphDigest.
9. **Publication/recovery:** validate the complete D6 immutable source/lock/package object inventory, HEAD/index equality and expected revision/source CAS, then publish only with the selected filesystem's explicit durability capability. An unverified adapter cannot claim crash-safe success.

This replaces the earlier contradictory order that attempted to validate unresolved TypeIDs in graph references before verifying package exports. The architecture can report safe diagnostics earlier, but an authoritative semantic digest requires the complete successful pipeline. 

Diagnostic fields: code, severity, JSON pointer or source span, graph node/edge ID, expected, observed and explanation. Diagnostics are deterministic on the same graph and target profile.

## D2 nominal identity and D6 canonicalization checks (design proposal)

[D2 Identity and Type Resolution](d2-identity-and-type-resolution.md) requires stable namespace-qualified identities; a logical TypeID resolves through an exported **logical contract digest** after verification of exact locked package content bytes; package byte identity itself remains an independent build/snapshot input, never a display name alone. Decode/export names in illustrative fixtures are declarations, not proof of callable native code. Duplicated/retired IDs, missing provider linkage, target or contract drift fail at their respective semantic or build stage.

[D6 Canonical Persistence](d6-canonical-persistence.md) owns strict UTF-8 parsing, decoded duplicate-key rejection, canonical semantic projection and content digest, source-hash CAS, crash-consistent HEAD-slot selection and immutable source snapshot recovery. These are D6 design proposals. Diagnostic ordering: parse/encoding -> structural schema -> duplicate/retired identities -> locked package/export resolution -> typed edges/workflow -> permission/target -> snapshot validation and publication. A stale source hash must produce SOURCE_STALE_REVISION, not force a silent graph rebase. A torn or unverifiable snapshot must be rejected, never executed.

## Version and dependency rules

Version namespaces are separate: project schema, package schema, component API, compiler grammar, native ABI and target profile. For the first slice, dependency versions are **exact opaque strings**; no automatic SemVer range comparison, selection, or upgrade is allowed. Resolve each dependency to a local artifact and verify a SHA-256 content digest recorded in an explicit lockfile **before** compilation. Offline mode must not silently fetch or upgrade packages. Missing hash, conflict, incompatible ABI or unsupported target is a deterministic error.

The canonical digest has a detailed **proposed** algorithm in [D6 Canonical Persistence](d6-canonical-persistence.md); it is not architect-approved or natively tested. Do not claim byte-identical reproducibility from ordinary JSON formatting. A migration never upgrades dependencies implicitly.

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
| Required package has no lock entry | PKG_LOCK_MISSING | Reject |
| Package inventory path traverses outside package root | PKG_PATH_ESCAPE | Reject |
| Stale expected revision | PROJECT_STALE_REVISION | Reject without mutation |
| Unsupported required schema | SCHEMA_UNSUPPORTED_VERSION | Reject |

## Acceptance conditions

A valid sensor example parses into stable graph identity, checks port directions and types, and retains positions across save/reload without changing architecture. Each invalid fixture is rejected with its expected code. A failed migration cannot damage the previously committed project.

**Known limitations:** the existing sensor package declares Assembly source paths that are not present; it is a **design fixture**, not a buildable package. No parser, schema validator, lockfile resolver, migration engine or durable save implementation exists.

**Deterministic negative D6 scenarios:** [Canonical vectors](../../examples/architecture-sensor/d2-canonical-vectors.json) propose exact byte/encoding rejection; [Recovery scenarios](../../examples/architecture-sensor/d6-recovery-scenarios.md) cover torn records, stale writers, and crash points. No native parser, journal or crash injection has run these scenarios.

**D6 source and recovery details:** [Package Integrity](d6-package-integrity.md) requires validated portable path inventory before computing lock digests. [Filesystem Adapters](d6-filesystem-adapters.md) keeps crash-durable publication conditional on the actual host/filesystem. [Integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json) are reference bytes, not runtime verification. Missing declared sources block a locked build; no implicit stubs or offline network retrieval.

**D2/D6 canonical validation boundary:** [Semantic Projection](d2-d6-semantic-projection.md) must be produced only after exact [offline dependency resolution](d6-offline-dependency-resolution.md). The [locked pure fixture](../../examples/locked-pure-reference/README.md) includes known-good reference bytes and [future negative cases](../../examples/locked-pure-reference/negative-cases.json). An invalid lock, missing source, divergent public export or unknown provider prevents an authoritative graph digest even if the JSON shape is valid.

**Diagnostic-code reconciliation (audit):** The older shorthand PACKAGE_UNRESOLVED and PACKAGE_PATH_ESCAPE have been replaced in this first-slice table with the precise [D6 Resolver](d6-offline-dependency-resolution.md) and [Package Integrity](d6-package-integrity.md) codes PKG_LOCK_MISSING and PKG_PATH_ESCAPE. A wrong-version **existing** lock entry instead yields PKG_VERSION_CONFLICT. Preserve source stage and provenance path when reporting these errors; do not unify distinct causes under an ambiguous legacy PACKAGE_* category.
