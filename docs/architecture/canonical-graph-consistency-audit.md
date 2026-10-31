# Canonical Project Graph — One-Architecture Consistency Audit

**Status: PROPOSED design review. No architect approval, executable compiler, signed module, real device access or native test.** Owner: [One Canonical Project Graph](canonical-project-graph-and-components.md). Schemas: [Graph](../../schemas/canonical-project-graph.schema.json), [Component Package](../../schemas/canonical-component-package.schema.json), [TypeReference](../../schemas/aui-type-reference.schema.json).

## Decision

ONE Project Graph is the product's sole semantic architecture. There is no feature-based numbered graph family. Historical experimental documents and frozen SHA fixtures are retained as provenance only and cannot override the unified contract. A project revision counts edits, not product architecture editions.

## Cross-owner verification matrix

| Area | Unified requirement | Blocking proof |
| --- | --- | --- |
| Typed component | Exact package owner, operation contract and typed port mirrors | Verified public export closure, native binding |
| Generic type | Full owner, template, ordered argument contracts and digest | Acyclic generic resolver, canonical bytes |
| Graph topology | Stable node/edge IDs and exact type/direction constraints | Full semantic validation |
| Workflow | Explicit states, typed signals, reachability, deterministic transition and terminal-once | Real scheduler, cancellation race tests |
| DataFlow | Bind existing data edges, enforce copy/move/borrow and capacity policies | Runtime queue, Send/ownership proof |
| Hardware | Claims attached to real resource/owner nodes and edge IDs with target requirements | Qualified target adapter and live permission |
| Retired identities | Preserve no-reuse of stable IDs | Persistent tombstone closure |
| Graph revision | One CAS update to architecture, independent of runtime state | D6 immutable transaction and recovery |
| AUI | Typed source-to-Graph links, generation-safe events and result delivery | Compiler and D5 native runtime |
| Native ABI | Full logical type contract separate from target machine layout | Win64 PE/COFF, allocator and module verification |
| Signed review | Architecture approval distinct from executable approval and live scoped capability | Real reviewer keys, signatures and anti-replay |
| Security/persistence | No signed graph/source/receipt or device effect can be implied by schema success | Native tests, FS crash injection and human signoff |

## Proposed unified sensor reference

[One unified sensor project](../../examples/canonical-graph/sensor-project.auiproj.json) and [its illustrative typed component package](../../examples/canonical-graph/sensor-package.auipkg.json) preserve seven graph nodes, six edges, a full cancellation workflow, two dataFlow channels and DMA/IRQ/MMIO/memory declarations. Its placeholder 64-hex strings are NOT actual type/export/package SHA-256 hashes. No target adapter is qualified and no device is accessed.

A standalone **partial structural/cross-reference check** found no missing required fields, unexpected keys, mismatched constants/enums, missing workflow state/signal references or missing dataFlow edge references in this example. The checker did not implement complete JSON Schema Draft 2020-12, package exports, byte hashing, OS ABI or hardware permission validation. These remain NOT-RUN.

## Risks of retaining prior experimental documents

Historic filenames still contain obsolete exploratory labels and hash domains; deleting or silently rewriting them would damage traceability and old known-answer fixtures. Instead their architecture documents are headed HISTORICAL / SUPERSEDED. The active README and architecture navigation point only to the one unified model. Any importer must interpret historic source formats as unsupported inputs until a meaning-preserving translator with explicit reviews exists.

## Next Phase I closure, no implementation yet

1. Freeze one exhaustive canonical graph semantic projection containing workflows, channels, topology, resources, retired identities and typed exports; establish one stable public hashing input and true golden vectors.
2. Approve the canonical package export and operation digest closure; resolve typed workflow signals, generic/record owner identity, effects and target capabilities.
3. Define typed AUI link and signed review receipt against the unified graph, without self-referential snapshot digests.
4. Qualify Win64 native ABI, build/signing trust, D5 UI input/renderer/IME, D6 Windows durable filesystem and runtime ownership through later real tests.
5. Record explicit architect accept/reject/defer for all D1–D8; only then proceed to implementation.

**No architecture gate is accepted by this audit.**

[35 negative-case designs](../../examples/canonical-graph/negative-cases.json) enumerate expected validation, lifecycle, capability and persistence errors. They are NOT-RUN and diagnostic identifiers are proposals, not registered native engine output.

## Canonical projection ownership reconciliation — 2026-10-31

The [canonical graph owner](canonical-project-graph-and-components.md) now enumerates complete projection coverage, semantic-vs-presentation classification, deterministic ordering requirements and seven cross-contract rejection invariants. The older [Project Graph](project-graph.md) and [historical partial D2/D6 projection](d2-d6-semantic-projection.md) no longer claim competing current ownership. This is a **documentation authority correction**, not a final byte encoding, accepted hash domain, schema conformance, executable validator or test result. Canonical projection encoding and positive/negative golden vectors remain P0 OPEN.


## Focused D1–D8 documentation re-audit — 2026-10-31

**Scope and method:** compared the live canonical graph/package/TypeReference schemas, the unified sensor project/package, the active graph behavior and source-link contracts, and selected D1, D3, D4, D5, D6, D7 and verification/process documents. This is a focused cross-contract review, **not** a new whole-repository link count or an exhaustive formal proof. The earlier broad link counts remain historical and were not remeasured here.

### Confirmed documentation defects corrected in main

| Finding | Severity | Observed contradiction | Resolution in owning file |
| --- | --- | --- | --- |
| R-01 | P0 | Old Project Graph / behavior / hash-projection / persistence texts claimed competing semantic ownership alongside ONE graph | Restrained their scope: [one graph](canonical-project-graph-and-components.md) defines current semantics; former projections and their numbered hash domains are historical candidates |
| R-02 | P0 | [Graph↔AUI](project-graph-aui-contract.md) described TypeID without the complete current TypeReference digest and delegated identity authority to the older Project Graph | Require verified TypeReference with exact contractDigest, and bind source linking to the canonical owner |
| R-03 | P0 | [Source ownership](source-ownership.md) called view definitions “canonical” without saying that presentation/source ownership cannot redefine architecture | Separated authored source/presentation from graph authority and required reviewed reconciliation |
| R-04 | P1 | [Canonical sensor project](../../examples/canonical-graph/sensor-project.auiproj.json) referenced an `example.sensor/app` instance missing from [its package](../../examples/canonical-graph/sensor-package.auipkg.json) | Added the missing typed app export and planned source declaration. Source files and public digest verification still absent |
| R-05 | P1 | Expected error identifiers in [negative cases](../../examples/canonical-graph/negative-cases.json) disagreed with [graph behavior contract](graph-behavior-contract.md) for unresolved dispatch/edge, cross-domain borrow and structurally invalid snapshot | Aligned these expectations and added same-domain queued borrow, result-type mismatch and unverified-export rejections; now 35 **NOT-RUN** proposals |
| R-06 | P0 | Canonical operation dispatch was described as “verified” without acknowledging that the current package schema has no stored per-command digest nor an accepted digest projection | [Canonical owner](canonical-project-graph-and-components.md) now requires deriving and verifying exact operation/component exports and rejecting unproven public hashes; framing remains explicitly P0 OPEN |
| R-07 | P1 | First AUI profile, platform contract and Architecture-to-Execution summary continued to point at exploratory graph/syntax texts as current owners | Redirected authority to the single graph and bounded first AUI grammar, preserving former files as supporting research |
| R-08 | P0 | [Canonical Graph](canonical-project-graph-and-components.md) called declared project dependencies “dependency locks”, while its schema stores only packageId/version; D6 separately locks exact immutable package bytes | Explicitly separated graph requirements from D6 lockfile/object digests and rejected execution on lock mismatch |

### Targeted fixture inspection (design-only)

- A limited independent recursive check of relevant JSON Schema constructs against the [unified sensor graph](../../examples/canonical-graph/sensor-project.auiproj.json) and [package](../../examples/canonical-graph/sensor-package.auipkg.json) reported **0 shape errors**. The check supports `$ref`, `oneOf`, `anyOf`, `allOf`, `if/then/else`, `not`, required properties, constraints and ordinary recursion, but is **not** a standards-complete JSON Schema Draft 2020-12 validator.
- A separate static cross-reference inspection reported **0 missing component exports, 0 port-mirror mismatches, 0 incompatible endpoint/binding references, and 0 unresolved example workflow dispatch lookups**. Seven nodes, six edges, one workflow and two flow channels were inspected.
- These findings do **not** turn the example into a valid locked build: synthetic 64-hex placeholders, unmaterialized ASM sources, missing real package locks, unavailable qualified target adapter and unverified operation/export signatures remain **hard blockers**. No Studio engine, on-host ABI, compiler or security/runtime test ran.

### Remaining design gaps requiring decisions, not wording cleanup

| Gate | Priority | Exact unresolved boundary | Required closure evidence before D1–D8 acceptance |
| --- | --- | --- | --- |
| D2/D6 | P0 | Complete field-by-field semantic projection, normalized bytes, hash domain, order/absence handling and golden hashes are not frozen as ONE current graph profile | Approved single projection with meaningful-change/no-change tables, independent byte vectors and reject-on-unknown rules |
| D2/D3 | P0 | Verified core registry, recursive type export closure, exact operation/component digest composition and Graph/Source operation linkage are not proven | One approved type/export algorithm, target/domain/effect checks and end-to-end positive/negative source→graph vectors |
| D2/D4/D5 | P0 | Execution ownership, provider cancellation/quiescence, caller buffers, terminal-once atomics and device transfer safety lack machine-level verification | Accepted logical invariant + target-specific ABI contract + future race/fault tests |
| D2/D5 | P0 | Hardware target feature registry, qualified OS/bare-metal adapters and true privilege boundaries are not accepted | Target-qualified declaration/authorization matrix; explicit rejection when unavailable |
| D3/D5 | P0 | Full State/Derived/Bind/Task/Result/keyed view, event fairness, focus/IME/accessibility and bounded publication are proposed but unaccepted | Exact grammar/type/runtime semantics with sources, negative fixtures, budget and lifecycle acceptance matrices |
| D4/D6 | P0 | Native component layout, ABI, unsigned-vs-signed artifact chain, reviewer/key trust and replay/revocation policies remain design proposals | Verified receipt-to-module binding and documented key custody/approval policy; native proof in later phase |
| D6 | P0 | Safe package path inventory, snapshot crash atomicity, historical tombstone continuity and operation-ID replay retention are unproven | Approved durable state/HEAD/retention protocol and later filesystem fault injection |
| D7 | P0 | Official ChatGPT subscription-backed integration eligibility, auth scopes and real connected-app flow are not demonstrated | Actual provider eligibility/registration plus consent and failure-mode contract; no implicit Plus→API entitlement |
| D1/D8 | P1 | Human usability acceptance and explicit architect sign-off of the complete design baseline are absent | Single reviewed D1–D8 record, bounded exclusions and one consistent first-host/target trace |

**No new architecture edition, new branch, product code or CI is introduced by this audit.** Earlier frozen reference bytes remain unchanged. Every acceptance gate remains **OPEN** until explicitly signed off; a passed documentation checker is never native verification.
