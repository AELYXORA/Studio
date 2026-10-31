# D3/D4/D5 — Core Type and UI Runtime Contract Audit

**Status: documentation consistency review, PROPOSED / OPEN. Not an architect acceptance, compiler test, ABI layout verification, GPU/IME test or performance benchmark.** Owners: [D3 Core Types](d3-core-registry-value-contract.md), [D4 Native Value ABI](d4-core-value-abi-contract.md) and [D5 UI Budget/Publication](d5-ui-resource-budget-and-publication.md). Existing older [Core Library](aui-core-library.md), [Binary ABI](aui-component-binary-abi.md), [Runtime](aui-runtime.md) and [L4](d3-keyed-dynamic-view-lifecycle.md) are reconciled through explicit pointers rather than silently overwritten.

## X1. Scope and source artifacts

- [Proposed registry structural schema](../../schemas/aui-core-registry-proposal.schema.json) plus [13-entry typed inventory](../../examples/aui-language/d3-core-registry-proposal.json). The inventory intentionally has **no exportedContractDigest**: there is no approved complete normalized core type contract yet. It must not be added to trusted D2 package locks or treated as an accepted core registry.
- [9 positive and 8 negative portable StableKey vectors](../../examples/aui-language/d3-core-value-vectors.json). These are independently calculated D3 portable frames, not native D4 layouts.
- [D5 memory, queue and admission boundary vectors](../../examples/aui-language/d5-budget-reference-vectors.json): candidate 160 MiB root allocation and 16 model arithmetic cases, not observed allocator/frame/OS measurements.
- The previously committed L0–L4, D2/D6 reference files and semanticGraphDigest remain **unchanged**. No executable source or user-owned project graph has been edited by these proposed contracts.

## X2. Cross-owner discrepancies and disposition

| ID | Priority | Conflict/ambiguity before this pass | Candidate resolution | Blocking verification |
| --- | --- | --- | --- | --- |
| CV-01 | P0 | Broad core library used Length spacing, L0/L1 specified U32; ambiguous which compiler must accept | Keep L0/L1 first-profile **U32 spacing**; future target-independent Length is a separate type/version gate, no implicit conversion | Pin exact target-independent geometry unit/Length core export |
| CV-02 | P0 | Public types could be conflated with native offsets, especially String, List and union layout | [D3 registry](d3-core-registry-value-contract.md) owns logical types; [D4](d4-core-value-abi-contract.md) requires separate target/ABI layout proof | Native struct, calling convention, allocator and unwind goldens |
| CV-03 | P0 | StableKey.String and StableKey.U64 were described verbally but had no exact portable byte identity | Tagged length-framed UTF-8 StringKey / big-endian full U64Key encoding and distinct visual-NFC scalar semantics; [vectors](../../examples/aui-language/d3-core-value-vectors.json) | Pin published codec version, independently validate bytes on native code |
| CV-04 | P0 | Result<T,E> and TaskOutcome<T,E> were not clearly separated at provider admission boundary | Result has two provider branches; TaskOutcome has five request outcomes; rejected admission before provider dispatch MUST NOT produce a fabricated provider terminal ticket | Native result discriminants, error payloads and terminal CAS |
| CV-05 | P0 | Copy/Send capability often inferred from type name or machine pointer | D3 logical immutable traits are conditional; D4/OwnershipIR must prove actual owned representations across domain/await | Native borrow, Send/Share, retain/release and no-use-after-free |
| CV-06 | P0 | L2 StateRevision might be mistaken for Project Graph revision/HEAD epoch | StateRevision scoped to one UI owner/generation; GraphRevision and D6 HEAD remain independent durable identity domains | Atomic compare-and-swap, overflow and generation/ABA proofs |
| CV-07 | P0 | "64 events per view" could allow aggregate explosion on 4096 dynamic nodes | [D5](d5-ui-resource-budget-and-publication.md) adds per-root **both** 8192 envelope and 8 MiB ingress cap; reserves byte/count before payload move | Real memory pressure, fairness and bounded root/process accounting |
| CV-08 | P0 | Active task limit one per slot but no aggregate bound/result reservation | D5 proposes 256 root active tasks and 256 completed outcome reservations/8 MiB, with pre-admission reservation and no silent drop | End-to-end D4/D5 admission and terminal callback race tests |
| CV-09 | P0 | UI StateRevision and renderer frame were sometimes described as one atomic effect | Atomic UI state+desired tree visibility occurs before independent fallible presentation; a failed present does not rollback state or replay external effects | Native root CAS/epoch, GPU fence, renderer recovery |
| CV-10 | P1 | Dynamic keyed focus and IME target after removal lacked a deterministic candidate | D5 specifies same-ID preservation on reorder, generation revocation on remove and successor/predecessor/ancestor focus fallback | Accessibility/IME/native event tests; candidate not UX approved |
| CV-11 | P0 | Disappearing UI element might cause premature device/DMA buffer disposal | D3 L4 revokes subscriber; D4 retains provider ownership until terminal completion/quiescence; D5 counts detached owner metadata | Native callback drain, device adapter cleanup, ABA proof |
| CV-12 | P0 | Windows first-host design could be "validated" using current Linux Assembly example | D4 explicitly segregates Win64 PE/COFF ABI from SysV ELF fixture, both NOT-RUN | Selected first host/ABI target, real native build evidence |

These are **documentary resolutions** of meanings. Approval and implementation gates remain open.

## X3. Fixed negative-input precedence

Strict source/registry identity -> verified D6 type package/approved core registry -> valid value and ownership -> typed list/key reconciliation -> count AND byte admission -> UI StateRevision transaction -> scene/presentation -> provider terminal/lifetime cleanup. No unsuccessful earlier stage can be disguised as a later success. One source/graph compiled symbol cannot authorize physical I/O; one core type name cannot authorize native binary casts.

## X4. Architecture sign-off checklist

1. Explicit architect choice of first host (Windows x64 currently candidate), supported source profile matrix and pinned core registry **bytes plus exact type contract digests**.
2. Native D4 ABI layout and ownership descriptors for all 13 candidate types, including cancellation/error variants; independently generated offset/calling-convention fixtures.
3. D5 total root/process/GPU/OS/provider quotas, accepted default capacity and memory budget based on on-host observed resource footprint, not arithmetic examples alone.
4. D4/D5 StateRevision, TaskTicket/CommandTicket, keyed reincarnation/ABA, callback drain and render-publication atomicity proof.
5. Text/IME/focus/accessibility and cross-platform fallback policy, including language/keyboard/screen reader behavior and lost surface.
6. D6 approved source/Graph package-lock/snapshot and human review/permission evidence; current JSON proposal registry is not evidence of approval.
7. Phase III test harness with exact toolchain versions, artifacts/observations, negative diagnostics and fault injection **after** Phase II implementation; Phase IV correction/reverification after failures.

**All D3, D4 and D5 status fields remain Proposed/Open; no user/architect signature or native test exists.**
