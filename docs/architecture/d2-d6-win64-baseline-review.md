# D2/D3/D4/D5/D6 — Core Digest, Win64 ABI and First UI Host Baseline Review

**Status: PROPOSED/OPEN, no human approval, native build, Windows test, ABI acceptance, signed module admission or durable filesystem proof.** This is a bounded cross-owner design review. It is not a second owner of exportedContractDigest or machine ABI: refer to [Core Export Digest](d2-d3-core-export-digest-contract.md), [D4 Win64 Component ABI](d4-win64-native-component-abi.md), [D5 Windows Host](d5-windows-host-runtime-contract.md), [D3 Core Registry](d3-core-registry-value-contract.md) and [D6 Canonical Persistence](d6-canonical-persistence.md).

## G1. Confirmed consistency decisions in candidate text

1. Existing aui.export-contract/v1 type/component digest framing and the locked pure reference do not change when a new core-type registry is proposed.
2. New **aui.export-contract/v2-core** is explicitly separately domain-separated, not mixed into first-slice v1 without an accepted compatibility contract.
3. Public logical type digest excludes source file SHA and native struct offsets; implementation/package/target and approval identities independently pin bytes and capabilities.
4. Full U64 StableKey byte framing can be verified independently of native 64-bit machine struct layout; Unicode value sequences are not casefolded/NFC-normalized.
5. Win64 entrypoints use standard Windows x64 calling convention and PE/COFF/unwind metadata, not Linux SysV/ELF simply because x86-64 CPU instructions match.
6. The new proposed **64/48/64-byte** Win64 frame/span/context is an AELYXORA design choice, not Microsoft struct layout or released ABI.
7. Result<T,E> means provider result; UI TaskOutcome<T,E> can express admission failure *before* a provider ticket is allocated, never fabricated provider terminal status.
8. A revoked capability, stale generation, unknown ABI or incorrect layout stops before native invocation. No exception unwinds across the Assembly component boundary as an assumed safe operation.
9. D5 Windows host UI messages/TSF/UIA targets are keyed and generation-scoped; an old removed row cannot receive a new row's input, even if visible coordinates match.
10. UI StateRevision/desired tree commits separately from frame presentation and from D6 project persistence; paint failure does not replay commands or roll back committed UI state.

## G2. Explicit P0/P1 unresolved blockers

| ID | Priority | Missing exact architectural item | Required human decision / future proof |
| --- | --- | --- | --- |
| B-01 | P0 | Accepted source profile and complete core logical type registry/exact exportedContractDigests | Approve normalized public type schema + source registry trust/migration |
| B-02 | P0 | Generic specialization List<T>, Result<T,E>, TaskOutcome<T,E> and recursive type dependency identity | Freeze generic instantiation profile and transitive invalidation |
| B-03 | P0 | Mixed-profile v1 user type referring to v2 core type | Approve explicit compatibility gate, conversion and durable migration |
| B-04 | P0 | Approved module-header, operation table identity, signature/publisher trust and ABI feature negotiation | Define native ModuleHeaderV1, symbolic OperationID mapping and verified admission |
| B-05 | P0 | Win64 frame/span/context offsets adopted and independently verified by assembler/host | Approve candidate, produce COFF golden artifacts and ABI conformance harness |
| B-06 | P0 | Native Result/TaskOutcome tagged payload layouts and transport/error status mapping | Exact layout/offset/variant values, ownership & destructors |
| B-07 | P0 | Pointer provenance, memory aliasing, ownerHandle generation and typed allocator API | Prove before dereference, no ABA, no after-release callbacks |
| B-08 | P0 | Win64 nonleaf prolog, stack-probe, preserved GPR/XMM, .pdata/.xdata and unwinding | Build and inspect PE/COFF native probes, OS fault isolation |
| B-09 | P0 | D5 first-host OS window/backend/IME/UIA and per-process memory quotas | Specify target Windows range, Win32/TSF/UIA implementation and observed pressure |
| B-10 | P0 | UI-to-provider cancellation/TaskTicket/unmount race and DMA owner quiescence | Native terminal CAS, callback drain, fault/race tests |
| B-11 | P0 | D6 exact source/Graph/lock/type-registry snapshot inclusion and authentic approval receipt | New immutable snapshot fixture, verified review signatures and invalidation |
| B-12 | P0 | Windows/NTFS power-loss durable commit and recovery | Select filesystem proof assumptions and execute failure injection after Phase II |
| B-13 | P1 | L4 key/list global limits and D5 160 MiB candidate memory envelope | Choose accepted limits based on measured workloads; include GPU/OS/provider quotas |
| B-14 | P1 | Windows locale/IME, DPI scaling, UIA fragment identity and focus fallback | Native accessibility, keyboard, composition and monitor tests |
| B-15 | P1 | Reproducible source/toolchain evidence, compiler-core registry bytes and layout algorithm | Reproducible COFF build, digests, tool versions, no unverified compiler fallback |

All items remain **OPEN**: the presence of accurate offsets and cryptographic reference arithmetic is not architect acceptance.

## G3. Exact design evidence and its limits

- [13 core exported-contract digests and set fingerprint](../../examples/aui-language/d2-d3-core-export-digest-vectors.json): independent SHA-256 reference computation, including known-answer SHA256(abc) check and a second independent Python hashlib check for the Bool vector. This checks **arithmetic for design-only ASCII projections**, not general Unicode canonical JSON or native D6.
- [Win64 layout vectors](../../examples/abi/win64-native-layout-v1.json): three structs, exact offsets, alignments and 20 positive/negative design cases. Their field offsets were checked by independent **basic arithmetic**, not compiled C ABI static_assert or Windows disassembly.
- [Windows host contract](d5-windows-host-runtime-contract.md): Win32 message, PMv2 DPI, IME/TSF and UI Automation candidate and acceptance matrix. No Windows executable, HWND, UIA provider or measured renderer exists.
- Existing pure-reference v1 package, semanticGraphDigest, snapshotDigest, HEAD checksum remain **unchanged by this pass**.

## G4. Recommended next design closure before implementation

1. Approve exact logical type/error/generic contract registry and v1/v2 compatibility decision.
2. Approve/complete D4 module-header/operation-index mapping and exact native transport status/error type layouts, then target-level allocator and handle provenance.
3. Qualify one Windows x64 host and source/ABI/graphics/IME/UIA contracts, freeze testable limits and D6 filesystem capabilities.
4. Update D1–D8 gate matrix with an explicit human record (accepted/rejected/bounded deferred), baseline SHA and independent review evidence.
5. Only then Phase II implementation; Phase III native Win64, Unicode/canonical, security, race, memory/IME/accessibility and crash tests; Phase IV fixes and re-verification.

**No phase boundary moved and no Studio product source changed by this documentation effort.**
