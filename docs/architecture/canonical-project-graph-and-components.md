# AELYXORA — One Canonical Project Graph and Component Model

**Status: PROPOSED UNIFIED ARCHITECTURE; not approved, implemented, or native-tested.** This is the single design direction. There are no product architecture editions, competing graphs or separately numbered feature models. Earlier experimental documents and frozen fixtures are historical evidence, not alternative architectures.

Owner schemas: [canonical graph](../../schemas/canonical-project-graph.schema.json), [canonical component package](../../schemas/canonical-component-package.schema.json), [canonical TypeReference](../../schemas/aui-type-reference.schema.json).

## C1. One semantic owner

The ONE Project Graph owns targets, exact declared package dependency requirements, referenced verified public component contracts, stable GraphNodeIDs/PortIDs/EdgeIDs, typed component ports and typed edges, workflows/states/signals/transitions, dataFlow channels and ownership policies, retired identities, and optional hardware resource claims. Architecture map, code tree, visual designer, runtime traces and AUI previews are projections of it; no sidecar graph gains independent durable authority. AUI StateRevision and runtime ExecutionID are NOT GraphRevision.

## C2. No product or architecture editions

The canonical graph contains format, projectId, revision, targets, packageDependencies, coreRegistryFingerprint, typeExportSetDigest, nodes, edges, workflows, dataFlows, retiredIdentities and optional resourceModel. Project revision is a concurrency/immutable-history counter, NOT an architecture edition. The graph's `packageDependencies` records exact package ID and requested version only; it is **not** the dependency lockfile or proof of actual package bytes. D6 binds exact resolved package-object digests, core registry identity and transitive export closure in a separately verified immutable lock/snapshot. Changing the locked bytes invalidates package/build/source-link evidence even when public graph semantics are unchanged; a lock mismatch always rejects execution rather than silently choosing a nearby package. Component package versions and native ABI compatibility identifiers are external dependency facts, not separate models. Workflows, dataFlows and tombstones remain meaning-bearing, even when their arrays are empty. Missing resourceModel means NO hardware claims, never implicit permission.

Past test files with old field encodings and digests stay immutable. They are historical examples, not competing product profiles. Import from such files requires explicit meaning-preserving conversion, validation and reviewed new immutable snapshots. Never rewrite historic hashes or silently discard unsupported fields.

## C3. One type system and component contract

TypeReference has nominal ownerPackageId/typeId/contractDigest or generic template/ordered nominal arguments/contractDigest. No displayed name, index, pointer, old TypeID string or different machine layout substitutes for a verified nominal identity. First bounded generic subset allows at most two acyclic nominal arguments. Exact record and generic exports must resolve from pinned packages.

An operation has a stable owner/component/OperationID, ordered typed inputs, success/error types, domain, effects, capabilities, retry policy and targets. A verified component public contract incorporates derived, independently checked operation contract digests and typed port exports. Graph node ports are checked mirrors, not editable independent contracts. Win64 native ABI is separate from logical public contract; provider Result and UI TaskOutcome are separate typed concepts.

**Export resolution is fail-closed.** The [canonical package schema](../../schemas/canonical-component-package.schema.json) currently describes authored `components[].commands[]` and typed ports; it does **not** store a trustworthy `operationContractDigest` field for each command. The resolver must compute and verify the logical operation/export closure from an exact offline-locked package, then verify the component's calculated public contract against `nodes[].component.contractDigest`. A workflow's `(nodeId, operationId)` is only a lookup key within that verified component export; a matching name without a verified operation, target, domain, result/error types and capabilities is NOT executable linkage. The exact canonical operation digest framing and component digest composition are **P0 OPEN**, not silently inherited from historical numbered proposals. Never accept placeholder digests as verified exports.

**Signal-to-operation closure.** For each workflow `command-success` or `command-failure` signal, resolve `(nodeId, operationId)` against the same pinned provider contract and require complete `payloadTypeRef` equality with that operation's success or failure TypeReference, respectively. A `trigger` signal's TypeReference must match the bound trigger edge payload. `control` signals have no authored payload; their allowed producers and permissions (especially cancellation confirmation) must be explicitly defined by the runtime contract and cannot be inferred from a user event or untrusted input. Publication must check the bound output edge/type and preserve error versus success outcomes. These checks are semantic requirements beyond the JSON schema.

**Authoring versus identity.** Source files and package declarations own their authored contents, but cannot independently redefine accepted graph contracts: a source/export change stages a checked Graph/source reconciliation and a new reviewed transaction. Every accepted source link binds exact GraphNodeID, OperationID when applicable, verified export identity, source bytes and dependency closure. A build may only use the reviewed immutable snapshot, not an editor buffer or a stale derived source-span index.

## C4. Workflows, dataFlows and hardware are FIRST-CLASS in the same graph

Workflow: one explicit owner, trigger edge, initial state, unique states/signals/transitions, bounded per-ExecutionID mailbox, deterministic same-state/signal transition and one terminal publication. Terminal states have no outgoing edges; unreachable states reject. Requesting cancellation is not confirmed quiescence. Dispatch refers to an exact authorized component operation, never an arbitrary function address.

DataFlow: one declared binding per actual compatible data-flow edge, stream/snapshot mode, sender/receiver domains, move/copy/borrow policy, FIFO/latest ordering, capacity, overflow and error handling. Cross-domain borrowed values require independently proven ownership, otherwise reject. No edge implies automatic network/device I/O.

Hardware: targetRequirements and MMIO/IRQ/DMA/memory resource claims refer to real owner/resource nodes, target IDs and resource-access/ownership edges. Capabilities are declarative; runtime needs a qualified target adapter and live scope. No desktop user-mode graph can grant itself kernel/bare-metal permissions. Device buffers survive UI unmount until provider completion/quiescence.

Retired IDs: tombstones prevent accidental ID reuse and incorrect binding of old completions, resource owners or source links to new graph entities.

## C5. One dependency and semantic hash DAG

Immutable source/package bytes and core registry -> verified nominal/record/generic types -> public operation contracts -> component contracts -> transitive type-export set -> validated FULL graph -> canonical semanticGraphDigest -> typed AUI source-to-Graph link -> nonrecursive review proposal and approval -> verified native artifact -> new immutable D6 snapshot.

The complete future graph projection MUST include every meaning-bearing workflow, dataFlow, hardware claim, retired ID and typed graph edge. Unknown meaning rejects. No self-hash or approval referring to its own enclosing final snapshot. The final public canonical byte/hash profile remains P0 awaiting one architect decision; do not fabricate a new golden hash until ALL field semantics are frozen. Frozen earlier SHA fixtures remain reference-only.

## C6. Fail-closed validation ordering

Strict schema -> target and offline package closure -> complete TypeReference and export identity -> node/port mirror -> topology/edge direction -> workflow signals/reachability/cancellation -> dataFlow ownership/capacity -> resource claims/target privileges -> full graph semantic projection -> AUI typed source link -> authentic architect and executable approval -> native ABI and LIVE capability. Schema validation or SHA arithmetic alone never authorizes execution.

## C7. Canonical semantic projection completeness (normative design requirement)

The canonical graph specification and its schema jointly define **one** semantic source. Historical projections with numbered compatibility domains are not independent current owners. No canonical digest is authoritative until the exact complete projection, byte encoding and golden test vectors are explicitly approved.

A validator MUST classify each authored field as exactly one of: (a) semantic and included in the projection; (b) presentation or operation metadata deliberately excluded; or (c) unknown, therefore rejected. No field may be silently omitted because an older partial projection did not contain it. Reject a graph whose schema admits an authored meaning-bearing value for which the projection has no rule.

The projection must cover, transitively and deterministically:
- target identities and execution constraints, exact declared dependency requirements, verified logical public export closure and core-registry identity (locked implementation bytes remain outside the semantic projection);
- live node identities, kinds, component exports, typed ports, target bindings and every authorized edge kind/endpoint;
- workflow trigger, owner, states, typed signals, transitions, actions, scheduling, mailbox bounds and cancellation policy;
- every dataFlow channel's bound edge, payload type determined through verified ports, domain, transfer, ordering, capacity, overflow and failure policy;
- resource target requirements and every typed MMIO/IRQ/DMA/memory claim, including ownership, address-space, authorization requirement and exclusivity;
- retired stable identities, including kind, scope and ID, even when the collection is empty.

Presentation coordinates, human labels, current selection, transient runtime state, GraphRevision counter and source-only byte changes do not change semantic meaning. Such changes may still alter persisted snapshot bytes, package/build identity or evidence freshness. A required empty semantic collection remains an encoded empty collection; optional resourceModel absence means **no resource claims** and must never be interpreted as default privileges.

Arrays representing *sets* are sorted by their unique stable IDs, and arrays with meaning-bearing order (e.g. operation arguments or generic parameters) preserve that order. Duplicate IDs, ambiguous ordering, unknown semantic extensions, unverified exports and missing cross-references reject before hashing. JSON serialization order, Unicode/number encoding, separators and hash-domain framing must be identical across all supported hosts; these are **open acceptance items**, not assumed fixed by historical hashes.

The graph's semantic digest is distinct from both its immutable storage snapshot identity and the signed approval receipt. Approval binds the validated graph digest, source and dependency closure and review scope without circularly hashing its own containing snapshot. A changed semantic projection invalidates dependent links, approvals and build evidence until regenerated and reapproved.

### Cross-contract rejection invariants

1. A dataFlow channel MUST bind one existing data-flow edge, from an exported output port to an exported input port; no two channels may claim the same edge. Reject missing, duplicated or mistyped endpoint relationships.
2. A queued stream or retained snapshot MUST NOT transfer a borrowed value. Future synchronous borrowing needs an explicit separate proven contract; merely choosing senderDomain equal to receiverDomain cannot extend a borrow's lifetime.
3. A workflow dispatch MUST resolve to an exact operation export authorized for the target and execution domain; a matching spelling of operationId is insufficient.
4. Terminal workflow states cannot initiate outgoing transitions; a cancellation request does not certify provider completion or reclaim its buffers.
5. Resource claims MUST reference a target, live owner/resource node and matching resource-access/ownership edge; no capability string grants native OS permission.
6. A retired stable identity MUST not collide with a live identity of the same kind and scope, including identities reintroduced by concurrent or imported edits.
7. The validator MUST reject any semantic change that cannot be represented by the canonical projection; it must not return the previous digest as if no change occurred.

## C9. Single canonical graph projection — field-level candidate for D2/D6 review

**Status: PROPOSED / P0 OPEN.** The following is the **only candidate projection for the current unified graph**, not a separate graph edition. Its input contract is the existing [canonical graph schema](../../schemas/canonical-project-graph.schema.json); no new authored source field is introduced. The old `AELYXORA/semantic-graph/v1` reference domain is historical only. A candidate projection is never permission to publish a trusted semanticGraphDigest until the public byte domain, package export closure, independent vectors and human acceptance are completed.

### Projection construction and ownership

Resolve all exact offline dependencies and verify their immutable package bytes **before** resolving public contracts. Compute public logical types and component operation/export identities; verify the authored `coreRegistryFingerprint`, `typeExportSetDigest` and every `node.component.contractDigest` against those results. A 64-hex string's shape is not evidence of a real exported contract. Reject unresolved public identities or unavailable core registry, even when all authored field values conform to JSON Schema.

Construct one closed object with **exactly** these top-level keys:

| Projection key | Content and rule |
| --- | --- |
| `format` | Constant `aui.semantic-graph` (not a new authored project format) |
| `projectId` | Exact input projectId; never derived from label, path or source filename |
| `coreRegistryFingerprint` | Exact verified logical core-registry identity; input placeholder must match computed closure |
| `typeExportSetDigest` | Exact verified transitive public type set identity; exclude source/package implementation bytes |
| `resolvedExports` | Sorted complete public logical **type and component** export identities used transitively by the graph; component export includes its verified operation digests |
| `targets` | All authored `{id,triple,execution}` objects, sorted by `id` |
| `packageDependencies` | All authored exact `{packageId,version}` requirements, sorted by `packageId`, then `version`; reject duplicate packageId, even for identical versions |
| `nodes` | Authored `{id,kind}`, plus `target`, `component` and `ports` **only if present**; **exclude `label`**; sort nodes by `id` and present ports by `id` |
| `edges` | Every `{id,kind,from,to}`, with each endpoint's exact `node` and optional `port`; sort by edge `id` |
| `dataFlows` | All `{id,channels}`; sort flows by `id`, channels by `edgeId` |
| `workflows` | All authored properties including triggers, typed signals, transitions/actions and all scheduler/mailbox limits; sort workflows, states, signals and transitions by their respective `id` |
| `retiredIdentities` | Every exact `{kind,scopeId,id}`, sorted lexicographically by the complete triple; always present, including `[]` |
| `resourceModel` | **Only when authored**: full `{profile,targetRequirements,claims}`; sort target requirements by `targetId`, claims by `id`; absent is distinct from present with zero claims |

No `revision`, `label`, view layout, selection, runtime state, source bytes, package-object hashes, operation tickets, approval signatures, test evidence or final snapshot digest is projected. Such data still belongs to its **separate durable/provenance layer**. The authored `format` must equal `aui.project`; the projected `format` is a distinct fixed marker. **Never copy an entire JSON object and merely delete a few familiar keys**; construct a schema-closed projection, rejecting newly introduced semantic fields until formally classified here.

### Nested field completeness (no implicit defaults)

- `nodes[].component` contains exactly `packageId,typeId,contractDigest`. Each authored `nodes[].ports[]` contains exactly `id,direction,typeRef`, where the *entire* canonical nested nominal/generic TypeReference is retained. No port or component may be independently redefined by a graph instance.
- Every dataFlow channel retains `edgeId,mode,senderDomain,receiverDomain,transfer,ordering,errorPolicy`; stream retains `capacity,overflow`, snapshot MUST omit both. `borrow` has an authored enum spelling but is **semantically forbidden** in both queued stream and retained snapshot in the current model.
- Every workflow retains exactly `id,ownerNodeId,trigger,initialState,states,transitions,signals,scheduling,maxConcurrentInstances,onLimit,mailboxCapacity,mailboxOverflow`. A state retains `id` and optional `terminal`. A transition retains `id,from,to,signal,action`; action retains its required `kind` plus exactly its permitted `nodeId,operationId` or `edgeId` references. Each signal retains `id,source` and its **source-appropriate** `payloadTypeRef,nodeId,operationId`. Absent optional keys stay absent; they never become null or implicit capabilities.
- `resourceModel.targetRequirements[]` retains `targetId,addressBits,endian,privilege,featureRegistryId,isaFeatures,adapterContractId`; `isaFeatures` is an unordered unique set sorted by UTF-8 bytes. Every claim retains `id,kind,targetId,ownerNodeId,resourceNodeId,edgeId,addressSpaceId,sharing,requiredCapabilities` and **exactly one** complete `mmio`, `irq`, `dma` or `memory` kind-specific object with all schema-required typed fields. `requiredCapabilities` is a unique sorted set. Preserve canonical hexadecimal numeric strings as typed strings; never silently coerce to floating-point JSON numbers.
- `resolvedExports[]` is a **derived** set of tuples `{kind,packageId,exportId,contractDigest}`, with `kind` exactly `type` or `component`; `exportId` is the full package-qualified exported type/component identity. Sort by `kind,packageId,exportId,contractDigest`, reject duplicate `kind+packageId+exportId`. Core types and transitive record/enum/generic dependencies must be in the verified closure; operation exports are covered transitively by the component digest, not silently omitted.

Every set-like array is sorted by its indicated identity with **bytewise lexicographic ordering**, after semantic uniqueness checks. Arrays that express meaning-bearing order (public record fields, operation arguments, generic type arguments) are **never sorted**. A set with repeated equal values is rejected, not deduplicated silently. Unicode scalar values retain their exact sequences (no display-driven normalization); reject invalid UTF-8, decoded duplicate JSON keys, noncanonical number tokens and unsupported sizes per D6. All counted bounds, target-dependent registries and project ID scope must be resolved before a current profile can be accepted.

### Change classification, provenance and invalidation

Two valid inputs with identical projected canonical bytes have identical **candidate semantic meaning**, notwithstanding revision counter, node labels or map layout. Changing any meaning-bearing field (including a tombstone, target constraint, channel limit, workflow signal, operation public type/effect or hardware privilege) MUST change the candidate projection; an inability to encode such a field is an error, not a license to reuse the old digest.

**Separate identities remain independent:** `semanticGraphDigest` covers public architecture; `packageContentDigest` covers immutable implementation/package bytes; `sourceLinkBundleDigest` binds source to graph; signed review receipts grant scoped approval; a D6 snapshot references these artifacts and has its own immutable identity. A source-byte-only change can preserve graph semantics but **must** invalidate affected package, build, approval and verification evidence. No permission or hardware access follows from digest equality alone.

### Acceptance blockers specific to this projection

1. Freeze one domain-separated digest framing and interoperable D6 canonical byte encoding for the unified model; historical `/v1` and `/v2` domains are not automatically promoted.
2. Freeze verified core/type/operation/component digest composition (C10 below), scope and registry identity, including generic/record cycles and absence/empty handling.
3. Create independently calculated **real** golden hashes from validated non-placeholder exports, with full projected bytes and an ordered set of mutation expectations. The [26 proposed change/invariance/rejection scenarios](../../examples/canonical-graph/semantic-projection-change-matrix.json) provide a **design-only matrix**, not hashes or passed tests.
4. Decide qualified first-host/target registries, semantic limits and signed review/snapshot binding; only subsequent native tests can claim verification.

## C10. Logical operation and component export closure — proposed normalized contracts

**Status: PROPOSED / P0 OPEN, subordinate to C3 and the existing [canonical package schema](../../schemas/canonical-component-package.schema.json).** The current schema does not serialize or prove per-operation hashes. The resolver computes them from verified public declarations; no extra mutable `operationDigest` authority is added to the authored package.

| Derived public projection | Exact included values | Deliberately excluded |
| --- | --- | --- |
| Nominal record type | `kind=record`, owner `packageId`, full `typeId`, **ordered** field sequence of `name` plus entire verified `typeRef` | Source path, field memory offset, target ABI layout and code bytes |
| Nominal closed enum type | `kind=enum`, owner `packageId`, full `typeId`, **ordered nonempty** `variants[]` each with exact `name` and an **optional** full verified `typeRef` when that variant has a payload; absent payload is not null/Unit | Source path, native discriminant byte width, variant ABI layout or guessed public export digest |
| Bounded generic instance | Verified nominal template identity, ordered 1–2 full verified nominal argument identities, closed logical traits and resulting public contract identity | Compiler's guessed type name, unverified layout or pointer representation |
| Operation | `packageId,componentTypeId,operationId`, **ordered** input name/full TypeReference pairs, complete `successTypeRef,failureTypeRef`, `domain,sideEffectClass,retryPolicy`, unique sorted `effects,requiredCapabilities,declaredTargets` | Implementation path, exported function address, dispatch ticket, source content digest |
| Component | `packageId,typeId`, sorted typed `ports` (id/direction/full typeRef), unique sorted `capabilities`, and sorted `{operationId,operationContractDigest}` for **all** declared commands | `sources`, `testFixtures`, build artifacts and visual labels |
| Type-export set | Exact core-registry identity plus unique, sorted verified transitive public type identities and their computed contracts | Package filesystem locators, source revision and runtime trust token |

Each projected public object is closed and independently domain-separated before calculating its logical digest. Proposed names for distinct future domains are `AELYXORA/type-contract/canonical`, `AELYXORA/operation-contract/canonical`, `AELYXORA/component-contract/canonical`, `AELYXORA/type-export-set/canonical` and `AELYXORA/semantic-graph/canonical`. **These are review candidates, not accepted hash domains or golden values.** The proposed framing is SHA-256 over ASCII domain bytes, one NUL byte, then exact canonical UTF-8 JSON of the corresponding verified projection; hash domains must not be recycled with changed meaning. All linked identities and types must be computed from locked package/core source, **not** adopted from unverified authored digest strings.

For declared target support, match command `declaredTargets` against the project's resolved target **triple**, while graph node `target` references the project's target **ID**; mixing these namespaces is invalid. Check execution domain, effects, capability requirements, target qualification and command result/error types before authorizing a workflow dispatch. The provider's `Result<Success,Failure>` is never an AUI UI-task admission `TaskOutcome`. Each publish transition must bind an actual outgoing port/edge with compatible success payload; a failure signal cannot be silently published as a success value.

The order of public digests is acyclic: verified core registry and nominal leaves -> user record/enum/generic type exports -> operation digests -> component digests -> complete type-export set -> C9 graph projection -> candidate semantic digest. An unsupported recursion, missing type, mismatched authored checksum, duplicate export or unqualified target rejects before hashing. Type exports and component operations are exact public *semantics*, not proof that machine code implements those semantics correctly. Machine layout and runtime authorizations require separate D4/D5/approval verification.

**Enum/type/service closure (new single-schema extension, still PROPOSED):** the existing [canonical authored component package](../../schemas/canonical-component-package.schema.json) now accepts **exactly one of** record `{typeId,kind=record,fields}` or enum `{typeId,kind=enum,variants}` within the **same** `types[]` identity namespace. Enum variants form a **nonempty author-ordered sequence**; each variant contains its name and an optionally present full TypeReference. Absence means a zero-payload case, not a `Unit` payload. Reordering/renaming cases or adding/removing/changing a payload **must** change the logical type contract; two type entries of the same `typeId` (including record/enum collision) reject. Duplicate NFC-normalized variant identifiers, invalid recursive value types, missing owner/digest and unverified generic payload reject before publication. Target discriminant encoding, tag size, alignment and constructor runtime are **D4**, never logical SHA inputs. This extension does not promote any enum to an accepted public type: content-bound rule definitions, deterministic digest bytes, TypeReference link closure and D1–D8 sign-off are still absent.

**Service source mapping is not a new public type category:** a nonvisual `service` interface from [AUI Syntax](aui-syntax.md) is a *candidate authoring projection onto an existing* `components[].typeId` and its `commands[]`, **not** `types[].kind=service`, not a second graph and not an implicit native provider. The component/operation digest projection remains **exactly C12**; the interface's ordered named args/result/error and declared effects/domain must match the verified authored component command. `sideEffectClass,retryPolicy,requiredCapabilities,declaredTargets,ports,capabilities,sources` not present in short AUI interface source **must be supplied/verified by the signed locked component package**; do not infer values or default an omitted privileged field. On any disagreement, fail closed. `sources` and executable provenance stay out of public logical hashes, but are mandatory separately for target support and authenticated build. A source `service` declaration creates no permission to dispatch. Existing C9 `resolvedExports.kind=component` covers the verified service component; C9 `kind=type` covers the enum, with no new export-kind family.

A source `service` candidate must map **one-to-one** to one locked owner component interface: normalized command IDs form an **exact set match**, not a permissive subset, and each matched command's complete ordered argument/Result/effect/domain contract must agree. Multiple service declarations cannot silently merge onto one component or conceal operations; explicit composition would require a separate reviewed public interface policy. Import aliases are resolved before comparing. No authored source interface is allowed to override more restrictive locked provider metadata.

**Core rule-content and TaskOutcome closure:** the single [D3 current core inventory and CR13](d3-core-registry-value-contract.md) exposes 15 explicitly UNVERIFIED entries and a machine-checkable review skeleton. Its rule IDs are **not immutable public semantic definitions**: a production `typeContractDigest` requires frozen normalized meaning (or separately authenticated immutable rule-content digests) of every referenced rule, including [TaskOutcome's three closed nested runtime control payload candidates](d3-core-registry-value-contract.md). Do not compute authoritative registry/operation/component/graph hash chains from rule names, unverified JSON shapes or historical core SHA values. The [TaskOutcome shape review schema](../../schemas/canonical-task-control-payload-candidate.schema.json) cannot prove no-dispatch/terminal/quiescence; `TaskTicket`/`TaskSlot`, `TaskOutcome`, `StateRevision`, `Event` are not automatically admissible as ordinary D2 graph dataFlow payload types solely because they have nominal TypeIDs. The current 15-type inventory's `graphPayloadEligible` flag is a **candidate check**, not an ABI or runtime capability grant.

**Open implementation-neutral questions:** exact digest byte vectors, published core registry, normalized operation IDs/namespace rules, contract-declared effect registry and target ABI bridging, stable target/resource registry IDs, and signer/dependency closure. Their absence cannot be treated as a passed design gate.


## C12. Exact derived operation/component projection keys — proposed one-model refinement

**Status: PROPOSED; no accepted digest bytes, native implementation or trust authorization.** C10 establishes the logical DAG; this section closes ambiguity between the actual [canonical authored component package schema](../../schemas/canonical-component-package.schema.json) and the derived contract objects. These are **computed projections**, not new user-editable package fields, a second source schema or a numbered architecture.

### Authored-to-derived mapping

| Authored source | Derived operation public projection | Validation |
| --- | --- | --- |
| parent `packageId`, parent `components[].typeId` | `packageId`, `componentTypeId` | Fully qualified component belongs to locked package; never take these values from a display label |
| `components[].commands[].id` | `operationId` | Unique within owning component; exact case-sensitive stable ID |
| `commands[].inputs[]` | `inputs[]` with exactly `name,typeRef` | Preserve authored input order, require distinct input names, resolve complete TypeReference |
| `commands[].successTypeRef`, `failureTypeRef` | same named fields | Verify exact type, owner and digest; no guessed `TaskOutcome` substitution |
| `commands[].domain` | `domain` | Must be registered and meet graph execution restrictions |
| `commands[].effects`, `requiredCapabilities`, `declaredTargets` | same named fields | Unique string sets in canonical lexical order; exact target triples, never graph target IDs |
| `commands[].sideEffectClass`, `retryPolicy` | same named fields | Full declared effect and nonreplay policy; `retryPolicy=never` in current schema |
| all verified operation digests on parent component | `commands[]` of exactly `id,operationContractDigest` | Sorted by operation `id`; reject missing, extra, duplicated or mismatched operations |
| parent component `ports[]`, `capabilities[]` | same named fields | `ports[]` contain exactly `id,direction,typeRef` and sort by `id`; capabilities unique/sorted |
| parent component `sources[]` | **excluded** | Source paths, implementation byte hashes and source ownership belong to locked package/build/snapshot, not logical public contract |

An **operation projection** contains exactly these thirteen keys: `exportKind` (constant `operation`), `packageId`, `componentTypeId`, `operationId`, `inputs`, `successTypeRef`, `failureTypeRef`, `effects`, `domain`, `sideEffectClass`, `retryPolicy`, `requiredCapabilities`, `declaredTargets`. (The listed field names govern the contract.) The operation digest, source SHA, component digest and ABI layout are **not** contained in their own operation projection.

A **component projection** contains exactly `exportKind` (constant `component`), `packageId`, `typeId`, `ports`, `capabilities`, `commands`; it contains no source list, `testFixtures`, package target support `status`, or its own digest. Canonical source ports and graph instance-port mirrors are separate checks. A component with no commands contains `commands: []` in the derived projection even though the authored package's optional `commands` property may be absent. This normalization is part of the **proposed** exported public meaning, not permission to rewrite the authored package.

**Important distinction:** the package-wide `targets[].status` (planned/supported/unsupported/unknown) is *qualification evidence*, not a component's public target contract. A command's `declaredTargets[]` IS a meaning-bearing public contract. Setting package status from planned to supported without evidence does not change the logical digest and does not authorize execution; only a separately qualified target/toolchain/ABI and signed executable trust check can do that.

### Nonrecursive hashing and strict diagnostics

After validating exact offline lock bytes, registry and full TypeReference closure, calculate each **derived** operation digest with the current candidate operation domain and D6 canonical byte algorithm; only then calculate the parent component digest from its sorted port/capability/operation-digest projection. Externally supplied placeholder SHA values are **assertions to be checked**, never hash inputs trusted by spelling. The type-export set includes all reachable public record/enum/nominal/generic type contracts, not only those in ports: also fields, operation inputs, results/failures, and workflow signals.

On first failure, do not publish a trusted digest. Diagnostic candidates include `CORE_REGISTRY_UNRESOLVED`, `GRAPH_EXPORT_UNRESOLVED`, `CORE_CONTRACT_DIGEST_MISMATCH`, `TYPE_EXPORT_SET_MISMATCH`, `OPERATION_CONTRACT_DIGEST_MISMATCH`, `COMPONENT_CONTRACT_DIGEST_MISMATCH`, `WORKFLOW_SIGNAL_TYPE_MISMATCH`, `GRAPH_PORT_TYPE_MISMATCH` and `CAPABILITY_DENIED`; final ordering and native production of these diagnostics remain testable P0. Never signal merely `SCHEMA_VALID` as an approval or proof of identity.

[Operation/component review scenarios](../../examples/canonical-graph/operation-export-review-cases.json) distinguish logical changes from source-only changes, verified-contract rejection and runtime authorization. Their expectations are **NOT-RUN**, and the canonical sensor package's synthetic digest strings cannot yield accepted golden hashes.

### Enum public type projection: exact proposed fields, no circular digests

Derive the logical enum contract from the existing authored `types[]` and verified exact dependency closure. The enum type projection is one **closed** object with keys `exportKind` (constant `type`), `packageId`, `typeId`, `kind` (constant `enum`), `variants`. Each `variants[]` entry has `name` and **only if authored** `typeRef` (a complete verified nominal/generic TypeReference). Preserve author order and require >=1 variant. Do not include source path, layout, explicit ordinal, current target, status or its own contract digest. Verify every referenced payload type transitively before computing the enum digest; enum payloads may not carry the enum itself by value, including through an unbounded generic/container cycle. The derived representation uses the existing **candidate** logical type digest domain, subject to final content-bound rule semantics and actual D6 byte vectors; this is not a new export hash family.

Record projection remains `exportKind,packageId,typeId,kind=record,fields` with original field order and full verified refs. Record and enum mutually exclude `fields` vs `variants`, both by shape and semantic validation. The C9 `typeExportSetDigest` includes every verified reachable enum **and its payload dependencies**; a service operation result/error TypeReference to an enum pulls that enum into the same type closure. Record/enum public shape checks are not a substitute for ABI/native variant encoding qualification.

## C13. Open design and proof gates

Fully approved typed workflow signal contract, data-flow payload/ownership and resource claim interplay; exhaustive semantic projection and deterministic byte normalization; native package export and effect registry; source/Graph signed review and D6 immutable closure; Win64 module/ABI/renderer/IME/NTFS durability; actual Phase III tests and explicit D1–D8 human acceptance. **Only one architecture; its acceptance remains OPEN.**
