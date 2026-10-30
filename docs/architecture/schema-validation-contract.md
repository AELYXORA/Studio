# AUI Manifest Schema and Validation Contract

**Status: proposed structural schemas and semantic rules; no AUI parser or executable validator committed.** The project and component-package JSON schemas are [project.schema.json](../../schemas/project.schema.json) and [component-package.schema.json](../../schemas/component-package.schema.json). They describe the **current illustrative JSON fixture shape**, not the final storage format.

## Two validation layers

1. **Structural JSON Schema** verifies required properties, JSON types, enum values and unknown fields. It cannot by itself prove graph references, port direction/type matching, duplicate IDs or hardware ownership.
2. **Semantic graph/package validation** resolves target IDs, exact package identities, exported type IDs, component contracts and typed ports, then checks all graph edges and execution capabilities. Unique node/edge/type identifiers and single-writer ownership are semantic invariants.

Canonical type identity is `packageId/typeName`; display labels and short type names have no type-system authority. Cross-package conversion requires an explicitly declared pure adapter. Package exports must match project declarations, not merely the names of types.

## Resolution order

Parse JSON -> validate structural schema -> validate unique identifiers -> resolve exact local package dependencies -> verify package content hashes and exported types -> resolve graph references -> enforce type/direction, target and hardware constraints -> build candidate snapshot. No partial publish on failure.

Package resolving is **offline and explicit**. A future lockfile must record package ID, exact release/content identity, hash algorithm+digest, source origin and target coverage. No network access, silent dependency upgrade or inferred trust is permitted during resolution. The current example is **not locked**; a trustworthy package hash cannot be fabricated from absent source files.

## Fixture review and limitations

The [sensor project](../../examples/architecture-sensor/project.auiproj.json) and [package](../../examples/architecture-sensor/component.auipkg.json) were inspected against a minimal local structural checker that enforces the subset of JSON Schema keywords these files use. Both passed. The six [negative fixture mutations](../../examples/architecture-sensor/invalid-cases.json) were checked using a local, noncommitted semantic reference checker and returned their expected codes: duplicate ID, missing node, wrong port direction, type mismatch, unknown target and unsupported schema. **These checks were not executed by AUI or an independent full JSON Schema validator.**

## Design risks and open items

The fixtures still contain placeholder `schemaVersion: "0.1-draft"` and package/contract version `"0.1.0"`; these are example compatibility tokens, **not product or document releases**. Decide actual schema revision rules and dependency identity before freezing the format. Source paths in the package currently point to files not present, so it is deliberately not buildable.

Missing formal checks include schema size limits, JSON duplicate keys, canonical JSON/hash algorithm, identifier normalization, package graph cycles, type aliasing, source path/symlink escape, duplicate resource ownership, migration and crash-safe multi-file commit. Mark them **open**, not verified.
