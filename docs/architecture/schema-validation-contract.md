# AUI Manifest Schema and Validation Contract

**Status: proposed structural schemas and semantic rules; no AUI parser or executable validator committed.** The project and component-package JSON schemas are [project.schema.json](../../schemas/project.schema.json) and [component-package.schema.json](../../schemas/component-package.schema.json). They describe the **current illustrative JSON fixture shape**, not the final storage format.

## Two validation layers

1. **Structural JSON Schema** verifies required properties, JSON types, enum values and unknown fields. It cannot by itself prove graph references, port direction/type matching, duplicate IDs or hardware ownership.
2. **Semantic graph/package validation** resolves target IDs, exact package identities, exported type IDs, component contracts and typed ports, then checks all graph edges and execution capabilities. Unique node/edge/type identifiers and single-writer ownership are semantic invariants.

Canonical type identity is `packageId/typeName`; display labels and short type names have no type-system authority. Cross-package conversion requires an explicitly declared pure adapter. Package exports must match project declarations, not merely the names of types.

## Resolution order

Parse JSON -> validate structural schema -> validate unique identifiers -> resolve exact local package dependencies -> verify package content hashes and exported types -> resolve graph references -> enforce type/direction, target and hardware constraints -> build candidate snapshot. No partial publish on failure.

Package resolving is **offline and explicit**. A future lockfile must record package ID, exact release/content identity, hash algorithm+digest, source origin and target coverage. No network access, silent dependency upgrade or inferred trust is permitted during resolution. The **original sensor example** is not locked and its declared ASM sources are absent; its hash cannot be fabricated. A separate [locked pure reference fixture](../../examples/locked-pure-reference/README.md) now carries actual source bytes, a lock and hash vectors, but is not a native ABI-linked executable.

## Fixture review and limitations

Earlier versions of the [sensor project](../../examples/architecture-sensor/project.auiproj.json) and [package](../../examples/architecture-sensor/component.auipkg.json) were inspected with a minimal, noncommitted structural checker. Six [original negative fixture mutations](../../examples/architecture-sensor/invalid-cases.json) had expected codes under a noncommitted semantic reference checker. **Those observations applied to an earlier fixture revision; they are not current-schema results, native validator results or independent full JSON Schema evidence.** The new D2 behavior extension and [D2 negative fixtures](../../examples/architecture-sensor/d2-invalid-cases.json) have not been executed by a native validator. All D2 behavioral acceptance outcomes remain **not-run**.

## Design risks and open items

The fixtures still contain placeholder `schemaVersion: "0.1-draft"` and package/contract version `"0.1.0"`; these are example compatibility tokens, **not product or document releases**. Decide actual schema revision rules and dependency identity before freezing the format. Source paths in the package currently point to files not present, so it is deliberately not buildable.

Missing formal checks include schema size limits, JSON duplicate keys, canonical JSON/hash algorithm, identifier normalization, package graph cycles, type aliasing, source path/symlink escape, duplicate resource ownership, migration and crash-safe multi-file commit. Mark them **open**, not verified.


[Package Resolution and Reproducible Build Contract](package-resolution-build.md) defines offline locked dependency resolution, digest design, target checks and reproducibility gates. [Proposed lockfile schema](../../schemas/package-lock.schema.json). No fabricated lockfile or verified build.

## D2 behavior fixture schema boundary

The draft project schema now exposes `dataFlows` and `workflows`. The package schema exposes declared `commands`. These fields are a structural interchange **proposal**. Structural checks cannot prove the referenced edge exists, a workflow state is reachable, a provider operation is actually linked, or device access is authorized. [Graph Behavior](graph-behavior-contract.md) defines semantic requirements. Schema files may reject invalid shape before semantic validation; fixtures identify expected first diagnostic by stage.

## D2 execution and provider extension

The draft schema now includes workflow signals (trigger, command-success, command-failure, control), per-instance-fifo scheduling, maxConcurrentInstances, mailboxCapacity and explicit admission/overflow rejection. Component command exports add sideEffectClass and retryPolicy with first-profile retryPolicy 'never'. These are **structural fixture contracts only**. Matching a signal to a locked operation's success/error TypeID, proving capability authorization, bounded scheduler memory, ownership safety, terminal-state race and mult-file crash recovery all require separate semantic/runtime verification. See [D2 Execution and Consistency](d2-execution-consistency.md) and [D2 runtime scenarios](../../examples/architecture-sensor/d2-runtime-scenarios.md). Schema acceptance is not execution evidence.

## D2/D6 identity and canonical codec boundary

The optional draft project field retiredIdentities stores typed identity tombstones for collision protection; the semantic graph digest must include its canonical tuple order. Structural validation alone cannot prove a deleted ID is never reused across revisions. The [D6 canonical persistence proposal](d6-canonical-persistence.md) defines strict decoded-key duplicate rejection, integer-only semantic codec and SHA-256 domain separation. [Canonical codec vectors](../../examples/architecture-sensor/d2-canonical-vectors.json) provide design-stage bytes and hashes; full lock/index/HEAD integrity and source ownership checks are separate validators, not JSON Schema assertions. All results remain NOT-RUN by AELYXORA.
