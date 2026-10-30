# Project Graph and Component Package Format

**Status: proposed schema draft, not implemented.** JSON is selected for the **current inspectable interchange fixtures**; final storage encoding is not frozen. This document owns persistence, package discovery and integrity semantics. The Project Graph owns node/edge meaning; the ABI document owns native calling conventions.

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

## D2 workflow and data-flow fixture extension (proposed)

The first illustrative project JSON now has optional project-owned `dataFlows` and `workflows` collections alongside canonical `nodes` and `edges`. These are **semantic members of the Project Graph**, not separate independently editable files. A DataFlow lists policy bindings by existing EdgeID; a Workflow has ID, ownerNodeId, trigger, initial state, states and transitions referring to the same graph. The owner of exact behavior is [Graph Behavior](graph-behavior-contract.md).

- `dataFlows[].channels[].edgeId` must reference an existing `data-flow` edge, not replicate endpoint data. For an active data-flow edge, exactly one authoritative binding exists in the first profile.
- `workflows[].trigger.edgeId` is a `data-arrival` reference to a bound data-flow edge in the draft machine-readable profile. Later event triggers require typed exported event/command contracts, not an arbitrary name.
- `workflows[].transitions[].action` names a graph-bound operation or existing transport edge. The graph does not execute it by itself.
- `component.auipkg.json` can expose a proposed `commands` list with input types, result/error TypeIDs, effects and domain. The example decoder declares `Decode`, but its Assembly source is still absent, so it remains **unbuildable**.
- All semantic changes to workflows, transitions, channel modes, capacities and transfer policies require a graph revision; view-only moves are stored separately.

The structural [Project JSON Schema](../../schemas/project.schema.json) and [Package Schema](../../schemas/component-package.schema.json) describe this *draft fixture encoding* only. They do **not** validate reference resolution, workflow reachability, actual command linking, capability safety, transaction durability, or executable code. The project file's format identifier and placeholder version do not constitute a stable external file-format release.

## Component package draft

Fields: `format`, `schemaVersion`, `packageId`, `packageVersion`, `components`, `dependencies`, `targets`, `sources`, `capabilities`, `testFixtures`. Components specify exported stable type IDs, contract versions, typed ports, effects and owned source paths. Each source maps to a target triple or an explicitly shared declarative source. Platform-specific Assembly source is not assumed reusable across ISAs.

## D2 execution and model transaction semantics

[D2 Execution and Consistency](d2-execution-consistency.md) specifies the in-memory instance ordering, command-ticket scope and approved project CAS at the **semantic** level. Project persistence must bind expectedRevision, expectedSemanticDigest, operationId, source hashes, staged complete outputs, durable commit and recovery. View-only layout changes use a separate ViewRevision and cannot invalidate the semantic graph hash. Exact journal states and canonical fingerprint vectors remain a D6 P0 blocker. No transactional promise includes physical hardware effects or unsent/late external commands.

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


[Manifest Schema and Validation Contract](schema-validation-contract.md) documents the proposed JSON schemas, semantic rules, observed fixture checks and unresolved lockfile requirements. Structural schemas: [project](../../schemas/project.schema.json), [component package](../../schemas/component-package.schema.json).
