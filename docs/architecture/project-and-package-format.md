# Project Graph and Component Package Format

**Status: proposed schema draft, not implemented.** JSON is selected for the **first inspectable interchange prototype only**; final storage encoding is not frozen. This document owns persistence, package discovery and integrity semantics. The Project Graph owns node/edge meaning; the ABI document owns native calling conventions.

## Repository layout

```text
project/
  project.auiproj.json
  views/main.auiview.json
  sources/...
  packages/ (optional vendored packages)
  .aui/ (generated caches; never canonical)
package/
  component.auipkg.json
  src/<target>/...
  tests/...
```

Only the project manifest and explicitly listed declaration files are canonical. Maps use stable node IDs, not file paths or coordinates. Views persist layout independently from architecture. Cached build evidence must not be confused with immutable test results.

## Project manifest draft

Fields: `format`, `schemaVersion`, `projectId`, `revision`, `targets`, `nodes`, `edges`, `packageDependencies`. Nodes have unique stable IDs, a kind, type reference, ports and optional target-specific hardware constraints. Edges have stable IDs, kind and explicit port endpoints. Presentation fields live in view files. A manifest never serializes native pointers or secrets.

## Component package draft

Fields: `format`, `schemaVersion`, `packageId`, `packageVersion`, `components`, `dependencies`, `targets`, `sources`, `capabilities`, `testFixtures`. Components specify exported stable type IDs, contract versions, typed ports, effects and owned source paths. Each source maps to a target triple or an explicitly shared declarative source. Platform-specific Assembly source is not assumed reusable across ISAs.

## Versions and resolution

Project schema, package schema, component contract version, AUI source grammar, native ABI and compiler/toolchain version are distinct. A dependency is resolved by package ID, an explicit version constraint and artifact content hash in a separate lockfile. No implicit network update during offline builds. Reject missing packages, incompatible required capabilities, duplicate exported component IDs and unsupported target/ABI combinations.

## Integrity, ownership and changes

Paths must be project-relative normalized paths without traversal or symlink escapes. The package manifest cannot grant runtime device privileges: permission is checked independently. Source ownership is explicit (`human`, `generated`, `vendored`). Rebuilding generated artifacts must not overwrite human changes.

Project changes use expected revision, validated candidate, atomic publication and no partial graph writes. Save and crash recovery require staged files, verification and platform-specific durability design. A JSON write or rename alone is not automatically crash-safe.

## Diagnostics and acceptance fixtures

- Duplicate stable ID, missing edge endpoint, inconsistent port type, invalid hardware resource claim, unsupported ABI and unknown required format version must fail with graph path/ID.
- Package hash mismatch and path traversal must fail before source is compiled.
- Reordering JSON keys must not alter project meaning; canonical fingerprints require a specified normalization algorithm.
- Save/reopen retains node IDs, contracts, view coordinates and revision.
- A successful compile is not verification of hardware execution.

See the machine-readable **illustrative** fixtures under `examples/architecture-sensor/`. They are **not yet parsed by AELYXORA**.

## Open

Schema stabilization, lockfile hashing canonicalization, package signing, migration syntax, recovery journal, partial package loading and workspace-level dependencies.

## Formal validation and migration contract

See [Graph Validation and Migration](graph-validation-and-migration.md) for ordered checks, diagnostic codes, dependency resolution, revision-safe saves and recovery. Illustrative [negative fixtures](../../examples/architecture-sensor/invalid-cases.json) define expected failures; no validator has executed them.
