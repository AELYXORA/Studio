# D2-D6 Typed Project Graph v2 Cross-Contract Review

**HISTORICAL EXPLORATORY DESIGN — SUPERSEDED AS ACTIVE ARCHITECTURE.** The single current design is [ONE Canonical Project Graph and Component Model](canonical-project-graph-and-components.md). Numbered experimental formats, schemas and test hashes below remain in the repository only as immutable research/provenance references. They are NOT alternative product architectures, not implementation gates and not accepted release formats. Do not develop new features by creating another numbered graph model.

**Status: PROPOSED / OPEN.** Design review only; no native Studio compiler, Win64 ABI, signature, test runner or architect acceptance.

The [typed graph contract](d2-d6-project-graph-v2-typed-contract.md) separates logical type, operation, component, type-export-set and semantic graph digests. [Reference vectors](../../examples/typed-graph-v2/typed-component-contract-vectors.json) contain five reference hashes independently verified with Python hashlib. [35 designed negative cases](../../examples/typed-graph-v2/typed-graph-negative-cases.json) have not run in Studio.

## Twelve explicit boundaries

1. Legacy v1 graph/schema/hash remains unchanged; no silent migration to v2.
2. Operation public digest includes ordered arguments, full typed result/error, effects and capabilities.
3. Component public digest includes independently verified operation digests, not its own hash.
4. Node ports must mirror verified public component ports exactly.
5. Data-edge endpoints must have out/in direction and identical complete TypeReference.
6. Type-export-set digest covers transitive core, record and generic dependencies.
7. Visual labels and source revision are excluded from semantic meaning.
8. This strict typed slice rejects nonempty workflows/dataFlows and resourceModel rather than losing v1 semantics.
9. AUI source link must pin exact GraphNodeID, OperationID and operationContractDigest.
10. Graph hash and module signature are not runtime authorization; signed reviews and live capabilities remain separate.
11. Provider Result and UI TaskOutcome remain distinct; stale keyed-view generations cannot receive old outcomes.
12. The same logical type identity cannot substitute for verified Win64 native layout, buffer ownership or module trust.

## Open architecture gates

The full typed v2 project graph (workflows, data flows, hardware and tombstones), typed component/package authoring manifest, verified link/source approval, exact compiler and runtime type layout, verified signed module, Win64 GUI and durable D6 snapshot remain P0. D1-D8 require explicit architect approval before Phase II implementation. No native test or verified signed approval exists.
