# D2 — Versioned Hardware Resource Claims and Target Safety Profile

**Status: PROPOSED for explicit human review. NOT accepted, implemented, ABI-linked, hardware-tested, or a grant of device access.** This document owns the candidate typed resource declarations and their semantics under [Project Graph](project-graph.md). [Hardware and Targets](hardware-and-targets.md) owns the product-level hardware model; [Graph Behavior](graph-behavior-contract.md) owns topology and edges; [Semantic Projection](d2-d6-semantic-projection.md) owns portable graph hashes; [D2 Execution](d2-execution-consistency.md) owns active operations; [D4 Component ABI](aui-component-binary-abi.md) owns actual pointers, registers, barriers, DMA leases and kernel calls. The [D2↔D3 Authority Boundary](d2-d3-hardware-command-boundary.md) owns UI use.

## H0. Model extension policy: ONE Project Graph, no hidden hardware sidecar

A hardware-resource profile is a versioned extension **inside the canonical project manifest**; it is not a second editable device graph. Its edges refer to the same stable GraphNodeIDs and EdgeIDs as the map and data-flow/workflow views.

- Existing pure and illustrative documents with schemaVersion 0.1-draft MUST NOT acquire resource defaults or a new digest because this profile exists.
- Hardware-resource projects use schemaVersion 0.2-hw-draft and a required top-level resourceModel object with profile aui.hardware-resources/v1. The [Project JSON Schema](../../schemas/project.schema.json) validates the discriminated shape. Resources are forbidden at other schemaVersion values. Unsupported version tokens reject semantically; strings other than approved profiles are NOT implicit backward compatibility.
- In a 0.2-hw-draft project, resourceModel is a **meaning-bearing graph field**. There must be no implicit mutable hardware inventory imported from IDE scans. All changes require reviewed graph CAS and invalidate semantic digest.
- The existing D2/D6 pure 0.1-draft projection and its reference hashes remain unchanged. A 0.2-hw-draft semantic projection includes resourceModel with its **exact normalized fields** under the new schemaVersion; never hash a hardware project's fields using the old pure projection. [Section H6](#h6-canonical-projection-and-compatibility) defines sorting.

The first hardware target supports **declarations and static validation only**; there is no actual target adapter or device-access grant. Bare metal, kernel and virtualized physical address interpretation require separate D4/D5 platform contracts.

## H1. Target requirements and meaning

resourceModel.targetRequirements is an array, exactly one entry for each target that has hardware claims. Each entry:

| Field | Meaning |
| --- | --- |
| targetId | Existing target ID; same identity as project.targets[].id |
| addressBits | 32 or 64; representable target address width, not host pointer width |
| endian | little or big; expected target byte order, not automatic byte swapping |
| privilege | user / kernel / bare-metal; requested execution privilege |
| featureRegistryId | Explicit pinned target feature namespace/revision; unrecognized features reject |
| isaFeatures | Sorted unique case-sensitive feature IDs, proven by target adapter/ISA registry |
| adapterContractId | Exact target adapter interface identity, independently verified before ABI_LINKED/execution |

The target triple and project.targets[].execution MUST agree with the declared target requirements after target-profile resolution. A plain execution string is not evidence of permission. Unsupported privilege, wrong ISA or unknown adapter returns TARGET_PRIVILEGE_UNSUPPORTED, TARGET_ISA_UNSUPPORTED or TARGET_ADAPTER_UNRESOLVED; it does not choose a more powerful fallback.

A project with several targets has independently validated requirements and claims for each target. A target absent from targetRequirements cannot have hardware claims. Target feature registries, adapter binaries and device manifests are exact, separately locked D4/D6/target-profile inputs; this draft does **not** assert they currently exist.

## H2. Resource claims: identities and topology

resourceModel.claims is a set of immutable, case-sensitive ResourceClaimIDs, unique within ProjectID. A claim has:

- id: stable claim identity; kind: mmio, irq, dma, or memory.
- targetId: exact target; ownerNodeId: the component/driver instance requesting resource use; resourceNodeId: device/bus/memory-capable topology node; edgeId: existing canonical **resource-access** edge from ownerNodeId to resourceNodeId.
- addressSpaceId: explicitly named address-space/controller namespace **local to the target**. Two spaces with different IDs cannot be silently assumed physically independent; adapter identity/resolution must be explicit.
- sharing: exclusive or shared-read; requiredCapabilities: a sorted unique subset of the declared capability registry, e.g. mmio.read, mmio.write, irq.handle, dma.submit, memory.map, memory.read, memory.write.
- Exactly one nested kind-specific object matching kind; other kind-specific keys forbidden structurally.

All owner/resource nodes and the referenced edge must exist and be on a validated target. Resource-access edge does not authorize execution by itself. A linked provider operation requires its **own** matching exported effect and capability contract, graph target and live runtime permission. Duplicate IDs, missing owner, non-resource edge, wrong target or unchecked topology -> GRAPH_DUPLICATE_ID, RESOURCE_OWNER_UNKNOWN, RESOURCE_EDGE_INVALID, RESOURCE_TARGET_MISMATCH or GRAPH_PROFILE_UNSUPPORTED as appropriate.

An exclusive claim has one owner for the overlapping physical resource/IRQ/DMA channel in a given resolved namespace; conflicting owners reject RESOURCE_EXCLUSIVE_CONFLICT. shared-read is allowed **only** for read-only MMIO or read-only memory when the target adapter independently proves safe sharing. It is not a shortcut to share DMA, interrupt acknowledge or writable registers. A resourceKind not supported by the target adapter -> RESOURCE_KIND_UNSUPPORTED.

ResourceClaimID is separate from GraphNodeID, exported TypeID, address, pointer and device handle. Retiring a claim must record non-reuse across revisions. The draft retiredIdentities schema **now admits resource-claim tombstones** with scopeId=project. The graph semantic validator must reject reuse of any retired claim ID and preserve tombstones across valid migration/import; the full history-retention, merge and compaction guarantees are still a D2/D6 blocker. This is proposed schema shape, not an implemented migration engine.

## H3. Kind-specific semantics

**MMIO**: base and length are nonzero/normalized 0x lowercase hex integer strings (zero base legal), interpreted using **arbitrary-precision unsigned arithmetic** during validation. 0x0 is canonical zero; leading zeros and uppercase digits reject. End = base + length, exclusive. Require length > 0, end <= 2^addressBits, base/alignmentBytes compatible and registerWidthBits in 8,16,32,64 with aligned access widths. Endianness is explicit and checked against adapter semantics, never assumed from target. access is read/write/read-write and ordering is device or strong; these are *requirements*, not emitted CPU instructions. A provider's actual MMIO width, barriers and atomicity belong to D4/D5.

**IRQ**: controllerNodeId references a real compatible controller node, line is normalized hex nonnegative integer string, trigger is edge-rising / edge-falling / level-high / level-low, ackPolicy is explicit or controller-auto. Exact line namespace is (targetId, controllerNodeId, addressSpaceId, line). An IRQ claim is exclusive in this first profile. Handler affinity, masking, controller re-arm and acknowledgement order require a verified target adapter; the presence of a claim cannot execute an IRQ handler.

**DMA**: engineNodeId is a compatible hardware node, channelId is a target-local stable ID, bufferClaimId references a same-target **memory** claim owned by an authorized component; direction is to-device/from-device/bidirectional, coherency coherent/explicit-sync, alignmentBytes is power-of-two (listed schema values), maxBytes is nonzero normalized hex and maxInFlight is a bounded positive integer. The exact DMA/streaming address model, IOMMU translation, bounce buffers, cache fences and cancellation quiescence are target-dependent. No dangling buffer, automatic borrow, CPU pointer-as-device address or cancellation-means-done is allowed. Unknown coherence rules reject DMA_COHERENCY_UNSUPPORTED rather than silently using an unsafe default.

**Memory region**: base/length are normalized nonzero-length hex range in explicit addressSpaceId, regionType ram/device/reserved, access read/write/read-write/execute. Reserved regions cannot be claimed for executable or mutable runtime operations merely by declaration. Exec permission is not implied by read or write; W+X policy needs approved target-specific rules. Overlapping physical regions on the same resolved target/address-space pair reject unless the adapter proves identical intentional readonly sharing and ownership; distinct address spaces need alias proof before being treated disjoint.

D2 does not serialize live MMIO mappings, IRQ handler pointers, device capabilities, DMA physical buffer addresses, OS handles or permission tokens in project files. Only *typed requirements* live in the graph. Actual resource leases and generation IDs belong to D4/D5 runtime.

## H4. Validation stages, deterministic precedence

For a graph using the new profile:
1. Strict parse and resourceModel JSON shape. Wrong profile, missing required kind object, invalid hex/unknown key -> SCHEMA_INVALID or SCHEMA_UNSUPPORTED_VERSION.
2. Stable IDs and non-reuse; targetRequirements and claims are ordered sets by ID, reject duplicates and retired reuse.
3. Verify exact D6 package lock and component exported contracts before resolving any owner operation/effects.
4. Resolve target IDs, ISA/privilege/adapter and resource access endpoint/edge; no inference from topology label, source path, AI suggestion or map location.
5. Check numeric range overflow/alignment, IRQ controller/trigger, DMA buffer owner and memory region compatibility, sharing/exclusive overlaps and required effects/capabilities. Reject missing proofs, report precise claim+target+edge.
6. Compute complete canonical hardware semantic projection. Only after successful pre-publication checks may a reviewed graph revision be committed. **A claimed resource never turns into a capability token.**
7. ABI_LINKED and EXECUTION_VERIFIED are *separate later stages* requiring actual target adapter, physical access privileges, on-device tests and operator authorization.

Primary error precedence is earliest failing stage; diagnostic details include claimId, nodeId, targetId, addressSpaceId, edgeId, required and actual permissions and compatible target evidence. Don't mask unsupported capability behind successful JSON parsing.

## H5. Failure codes and future acceptance design

| Condition | Candidate diagnostic |
| --- | --- |
| Missing/wrong-kind canonical resource-access edge | RESOURCE_EDGE_INVALID |
| Unknown claim owner / device / target | RESOURCE_OWNER_UNKNOWN / RESOURCE_TARGET_MISMATCH |
| Same claim ID twice or reuse | GRAPH_DUPLICATE_ID / IDENTITY_REUSE_REJECTED |
| Invalid or overflowed MMIO/memory range | RESOURCE_RANGE_INVALID |
| Incorrect required alignment or register width | RESOURCE_ALIGNMENT_INVALID / RESOURCE_WIDTH_INVALID |
| Colliding exclusive MMIO/memory regions | RESOURCE_EXCLUSIVE_CONFLICT |
| Unsafe shared-read on DMA, IRQ, writable MMIO | RESOURCE_SHARING_UNSAFE |
| IRQ reused without explicit sharing protocol | RESOURCE_IRQ_CONFLICT |
| DMA buffer absent, wrong kind or owner | DMA_BUFFER_CLAIM_INVALID |
| Missing target feature/privilege/adapter | TARGET_ISA_UNSUPPORTED / TARGET_PRIVILEGE_UNSUPPORTED / TARGET_ADAPTER_UNRESOLVED |
| Declared effect or capability absent from provider | GRAPH_CAPABILITY_UNDECLARED |
| Runtime permission token absent/revoked | CAPABILITY_DENIED — runtime, not graph schema |
| No live OS/hardware adapter | TARGET_ADAPTER_UNRESOLVED — cannot declare executable support |

The [Hardware Design Fixture](../../examples/architecture-sensor/hardware-resource-profile-project.auiproj.json) illustrates shape and references but is **not fully lock-resolved** because the sensor package Assembly files are absent. [Negative Design Cases](../../examples/architecture-sensor/hardware-resource-negative-cases.json) are future diagnostics only, NOT-RUN by AELYXORA.

## H6. Canonical projection and compatibility

The 0.1-draft pure projection remains EXACTLY as documented and byte-for-byte unchanged.

For 0.2-hw-draft, the [Semantic Projection](d2-d6-semantic-projection.md) extends the SAME top-level projection with:
- schemaVersion = 0.2-hw-draft;
- one **required** resourceModel field equal to the strictly validated object, with profile and both arrays;
- targetRequirements sorted by targetId, with isaFeatures sorted case-sensitive ASCII (duplicates rejected);
- claims sorted by id, requiredCapabilities sorted bytewise unique;
- all claim objects contain exactly the schema-declared base fields plus exactly their one kind-specific object, with their full field set including base/length, widths/alignment, access/ordering, IRQ/DMA semantics, exact target and graph references;
- all other existing first-profile fields and their normalization rules unchanged.

Canonicalize keys by the same D6 P1 UTF-8 key sort and strings without case normalization; normalize hex spelling **by rejecting noncanonical input**, never silently rewriting values. Hash with the existing domain AELYXORA/semantic-graph/v1 plus zero byte plus canonical JSON. The differing schemaVersion and required resourceModel make hardware and pure graph digests distinct. No resource claim, target feature, address/length or capability can be omitted from the hardware semantic digest.

**No authoritative semanticGraphDigest is available for an unresolved hardware package, target adapter, or forbidden resource.** Prototype docs may calculate illustrative candidate canonical bytes, explicitly tagged as NOT VALIDATED. Never promote a raw JSON hash to a validated semantic graph digest.

## H7. Architecture review blockers

1. Define and pin actual target feature registry, address-space alias resolution and target adapter contracts per supported OS/board.
2. Verify the newly added resource-claim tombstone kind end to end; define migrate/delete/rename and import safety; preserve graph history and exact IDs.
3. Prove native ABI register widths, memory ordering, IRQ acknowledgement, DMA fences/buffer ownership and quiescence/cancel.
4. Pin hardware-specific capability/effect grammar, actual user/kernel/bare-metal privilege isolation, device simulator versus real hardware evidence.
5. Independent standards-compliant JSON schema/semantic fixture tests and exact canonical hardware digest vectors; Phase III fault injection and target verification.

**These are explicit design blockers; adding the draft schema and examples does NOT close O-01, D2, D4, D5 or D6 or authorize hardware actions.**
