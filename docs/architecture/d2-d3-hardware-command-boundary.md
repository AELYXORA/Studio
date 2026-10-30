# D2 ↔ D3 — Hardware Resource and AUI Command Authority Boundary

**Status: PROPOSED, not architect-approved, implemented, linked or tested.** This document reconciles [D2 Hardware Resource Claims](d2-hardware-resource-contract.md) with [D3 L0/L1 Grammar](d3-first-language-profile.md), [D3 Event/Command Link](d3-event-delivery-and-command-linkage.md), [D2 Execution](d2-execution-consistency.md), [D4 Component ABI](aui-component-binary-abi.md) and [D6 Snapshot](d6-canonical-persistence.md). It does not create a second graph, a UI hardware API, or an implicit permission system.

## A. Non-negotiable separation of authority

**Architecture requirement**: the canonical Project Graph stores resourceModel claims attached to real resource-access graph edges, resource owners, target requirements and effect/capability contracts. It is a human-reviewed declaration of intent, never an OS token, driver handle or executed operation.

**AUI source**: L0 visual components are pure. L1 event handlers can issue only one declared typed send command after exact source-to-graph resolution. They cannot contain MMIO loads/stores, IRQ handler registration, DMA address arithmetic, driver pointers, raw interrupts, privileged syscalls, or arbitrary FFI. Future D3+ Task/await has the same approval boundary; async sugar cannot create new powers.

**Component provider**: an exported operation is separately locked to exact component TypeID, OperationID, exportedContractDigest, error/result types, target, effects and source/ABI artifact identity. The provider is the only place where target-specific D4/D5 adapters can perform the validated hardware operation, and only after live authorization.

**Runtime execution**: each request is checked against the approved graph snapshot, permitted target adapter, per-resource claims, owner node, declared operation effects, actual OS privilege and current capability token. An accepted UI click, a syntactically valid AUI command or a green Architecture Map line is not evidence of execution permission.

## B. Candidate command authorization function

A request to execute a hardware-capable command is accepted only when ALL predicates hold:

1. AUI source AST and exact source SHA-256 match a single currently approved link-map snapshot. ProjectID, GraphRevision/semanticGraphDigest, GraphNodeID, component TypeID, OperationID and logical exported contract are equal.
2. The original component provider and its source bytes match the committed package lock, selected target and D4-native ABI. No fabricated stub, old source file or unverified planned target support.
3. The graph has a resource-access edge from the provider's owning node to the claimed resource node; claim.targetId matches the node target, claim.ownerNodeId matches provider instance, and claim.edgeId resolves to that precise edge.
4. Required operation effects/capabilities are explicit, closed and consistent with the claimed resource kinds and access directions. No implicit widened effect or under-declared permission.
5. The target adapter verifies address-space interpretation, ISA/privilege, physical availability, register width, IRQ controller, DMA IOMMU and buffer lifetime. If any adapter evidence is missing, return TARGET_ADAPTER_UNRESOLVED / RESOURCE_KIND_UNSUPPORTED before invocation.
6. At dispatch time, a **fresh, scoped live capability** authorizes the exact resource/operation/domain. Check nonexpired token, generation, allowed access width and owner. Reject revocation with CAPABILITY_DENIED even if the architectural contract is unchanged.
7. A D2 bounded ticket reservation and valid input ownership transfer succeed before starting the effect. A failed admission cannot start a physical operation; terminal result/cancellation obey D2 and D4 first-terminal-wins and post-cancel buffer retention.

These are necessary rather than sufficient for guaranteed safe hardware execution: target adapter and device-specific test evidence remain mandatory.

## C. View model and architecture revisions

Changing an AUI label, button layout or map coordinates never edits a resource claim. Editing claim width/base/length/endian/IRQ line, operation effects, provider TypeID, target or required privilege is a **semantic Project Graph transaction** and invalidates earlier graph digest and all dependent build/runtime security evidence. Changing native source bytes with the same public contract keeps logical type identity but invalidates exact implementation/ABI verification. Removing a resource-access edge while it is claimed fails RESOURCE_EDGE_INVALID unless the claim is deleted or rebound in the **same approved graph transaction**.

An already running command pins the old accepted graph and resource lease. A later graph edit cannot silently steal its live DMA buffer or hardware ownership; clean shutdown/quiescence and new permission admission are required. An AUI view unmount cannot free an in-flight device lease merely because its visual instance disappears. Runtime state/generation is never serialized as a project resource claim.

## D. UI results, cancellation and diagnostics

L1 syntax has request-only send. It does not define a synchronous Result read, completion observer, retry loop, or status mutation. A provider result is typed and routed to its original owner/ticket, not automatically to a replaced ViewIdentity. D3+ must formally design result-to-view subscriptions, error visibility, stale generation handling and a single-writer state transaction before supporting interactive device status widgets.

A canceled request does not imply the hardware stopped. Confirmed cancellation requires provider quiescence; until then resource owners retain buffers/tokens. A crash must not replay a potentially non-idempotent external effect automatically.

Diagnostic precedence: AUI_SYNTAX / AUI_TYPE_MISMATCH -> AUI_COMMAND_UNLINKED / AUI_LINK_STALE -> GRAPH_CAPABILITY_UNDECLARED / RESOURCE_EDGE_INVALID -> TARGET_ADAPTER_UNRESOLVED / ABI_TARGET_MISMATCH -> CAPABILITY_DENIED / WORKFLOW_ADMISSION_REJECTED -> provider Result failure. Every error includes source span or node/claim/target IDs where relevant, but no sensitive capability value.

## E. Tests to design now (all native outcomes NOT-RUN)

- Button send for valid pure command: no hardware claim required, no direct device effect.
- Button send for hardware command with no approved graph link: AUI_COMMAND_UNLINKED.
- Wrong provider/owner/resource-access edge: RESOURCE_EDGE_INVALID, no runtime call.
- Operation requests write but only mmio.read is declared: GRAPH_CAPABILITY_UNDECLARED.
- Overlapping exclusive resource claims: RESOURCE_EXCLUSIVE_CONFLICT before graph publication.
- Runtime revoked capability token despite matching static claim: CAPABILITY_DENIED, no physical effect.
- Change only view position: identical semanticGraphDigest and no permission expansion.
- Change MMIO length/IRQ line/DMA buffer claim: new semanticGraphDigest after full lock/target validation; old evidence stale.
- Two queued event activations: D3 UI admission and D2 workflow/provider admission remain independent.
- View disappears while in-flight DMA: stale view receives no completion, but device buffer is retained until true quiescence.
- Hardware profile on pure-project schemaVersion: SCHEMA_INVALID.
- Physical target absent/unverified: TARGET_ADAPTER_UNRESOLVED, never automatic emulation.

## F. Remaining design blockers

Exact immutable source/link-map inclusion in D6 snapshot, reviewed permission-token model, native ABI for specific targets, resource-claim tombstone migration, target and feature registry, portable address-space alias rules, physical DMA ownership, full D3+ Result subscriptions and actual ABI/OS tests all remain P0. [Current cross-specification audit](cross-specification-audit-2026-10-31.md) tracks these gaps; **the draft is not an executable permission grant**.
