# Source Ownership and Regeneration

**Status:** specification.

The [ONE Canonical Project Graph](canonical-project-graph-and-components.md) is the sole authority for durable architecture identities, typed public contracts, workflows, dataFlows, targets and hardware claims. Human-authored AUI/declarative view source is authoritative **only for its own reviewed presentation and source declarations**; it cannot grant architectural meaning, replace a Graph transaction or silently redefine an exported contract. AI-generated Assembly modules are explicitly marked by ownership in a manifest. User-written Assembly remains user-owned. Compiler objects, caches, generated platform glue and binaries are disposable outputs.

A source edit affecting a public export produces a proposed Graph/source reconciliation. No generated output becomes a new source of truth; an accepted transaction binds the exact source/package hashes, graph revision, locked type/operation exports and human review. Derived source-span indexes and visual layout are disposable, and must never be used as persistent identities.

A generator must stage proposed files and a manifest of input revision, target triple, generator identity, normalized paths, previous hashes and new hashes. It must not overwrite changed files without approved conflict resolution; nor infer arbitrary Assembly source as declarative UI.

Paths are restricted to the project root; reject traversal and link escapes. Failed builds never certify a component. No generated app requires the Studio executable to run.
