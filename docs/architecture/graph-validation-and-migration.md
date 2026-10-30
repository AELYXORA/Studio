# Project Graph Validation, Dependency Resolution and Migration

**Status: proposed contract; not implemented.** Applies to the illustrative JSON manifests under `examples/architecture-sensor`. This document refines [Project and Package Format](project-and-package-format.md). It does not make JSON the final persistent representation.

## Validation stages (ordered)

1. **Decode:** strict UTF-8 JSON; reject duplicate object keys, truncated data, invalid numbers, excessive nesting/size and unsupported format/schema versions. Never execute package content while parsing.
2. **Shape:** verify required fields, types, nonempty identifiers, integer nonnegative project revision, permitted enum values, and unknown required features. Preserve optional extension keys only under explicitly namespaced fields.
3. **Identity:** unique project node IDs and edge IDs; unique target IDs, component type IDs and port IDs per component. IDs are stable under layout changes and cannot be reassigned to a different identity.
4. **References:** verify target references, package/type references, edge endpoints, and endpoint port existence. Every data-flow edge needs an output source and input destination with exactly matching canonical type identity. A display label is never a type identity.
5. **Graph semantics:** detect illegal containment cycles, duplicate exclusive resource claims, unsupported execution-domain transitions and synchronous dependency cycles without an explicit delay/buffer edge.
6. **Hardware/target:** validate target triple, ABI compatibility, execution privilege, address-space/range constraints, IRQ/MMIO/DMA capability and required platform adapters. Unknown hardware support is an explicit unsupported/unknown status rather than assumed success.
7. **Package resolution:** locate exact package IDs and versions from a lockfile or explicit local vendor directory; check hash, required dependencies and target coverage before accepting the build graph.
8. **Publication:** stage a candidate revision; validate all layers; atomically replace the canonical snapshot only if the expected prior revision matches. On failure the old revision remains authoritative.

Diagnostic fields: code, severity, JSON pointer or source span, graph node/edge ID, expected, observed and explanation. Diagnostics are deterministic on the same graph and target profile.

## Version and dependency rules

Version namespaces are separate: project schema, package schema, component API, compiler grammar, native ABI and target profile. For the draft, dependency versions are exact SemVer-style strings. Resolve each dependency to a local artifact and verify a SHA-256 content digest recorded in an explicit lockfile **before** compilation. Offline mode must not silently fetch or upgrade packages. Missing hash, conflict, incompatible ABI or unsupported target is a deterministic error.

The canonical digest procedure is still open; do not claim byte-identical reproducibility from ordinary JSON formatting. A migration never upgrades dependencies implicitly.

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
