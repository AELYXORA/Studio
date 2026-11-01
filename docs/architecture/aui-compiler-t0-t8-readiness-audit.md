# AELYXORA — Full Compiler T0–T8 Cross-Gate Readiness Audit

**2026-11-01 • REVIEW / P0 HANDOFF • NO ARCHITECT ACCEPTANCE.** This is a cross-reference audit of the **single** production compiler, not a new architecture or permission to implement an unreviewed ABI. Owners: [one pass graph](aui-ir-layout.md), [IAI-v1](aui-compiler-internal-assembly-abi.md), [IR verifier](aui-ir-verifier-and-pass-evidence.md), [139-tag payload catalogue](aui-compiler-ir-payload-contract.md), [T0 language grammar](aui-syntax.md), [public digest pipeline](d2-d6-public-contract-digest-pipeline.md), D4 native ABI, D5 runtime and D6 release. All D1–D8 gates **OPEN**.

## A. Exact stage interface audit

| Gate | Current documentary input/output | Principal unsatisfied proof | Priority |
| --- | --- | --- | --- |
| T0 UTF-8 → CST/AST | Candidate physical records, 57-production formal grammar, numeric kind inventory, review FIRST/FOLLOW and Predict Sets | Approved token-to-parser mapping, exact profile masks, closed CST/AST kinds, native lossless parser and recovery tests | P0 |
| T1 AST → TypedHIR | Typed semantics, complete production language candidate, tag catalogue | Every grammar branch to a verified TypedHIR tag/consumer, exact public type identities or deliberately unverified source-only output, real checker | P0 |
| T2 TypedHIR → GraphLinkedIR | One Canonical Graph and D2/D3/D6 digest chain | Independently verified 15-core public exports, source+lock+Graph+signed reviewer proof and capability/operation binding | P0 critical trust gate |
| T3 GraphLinkedIR → ReactiveIR/AsyncIR/KeyedIR | L2–L4 contracts and candidate feature tags | Complete task/cancellation/uncertainty, state atomicity, stable key identity and native resource-lifetime verification | P0 |
| T4 feature IR → OwnershipIR | SSA/borrow/effect contract, physical CFG layouts | Native verifier proves dominance, move/drop, region escape, cleanup and effects over all 139 tag descriptors | P0 |
| T5 OwnershipIR → LayoutIR | Target layout and D4 candidate | Accepted exact D4 ABI, complete enum/record codecs, public operation signatures, target-qualified runtime imports | P0 |
| T6 LayoutIR → TargetMIR | Win64 TargetMIR machine/stack/relocation proposal | Machine verifier, ABI call frame, unwind and all qualified target instructions/relocations | P0 |
| T7 TargetMIR → real native artifact | Proposed assembler/linker and D6 reproducibility | Real pinned Clang/GAS + COFF/link/PE output, byte/ABI inspections, deterministic build tests | P0 |
| T8 native artifact → admitted app | Candidate signed approval, D5 runtime and target admission | Independent signature/reviewer authorization, OS capabilities, UI/IME/accessibility and fault/teardown acceptance | P0 release |

**Status distinction:** documentation of an interface does not constitute validated input/output bytes. A source-only T0/T1 plan can run with `UNVERIFIED_SOURCE_ONLY`, but must never advance to T2. The grammar checker is a **local review tool**, not a T0 pass or trusted receipt.

## B. Cross-boundary gap inventory and ownership

| ID | Concrete gap | Owning document / evidence to produce | Completion test |
| --- | --- | --- | --- |
| X01 | Contextual tokens conflict with speculative numeric token kinds | AUI syntax + T0 kind registry | Closed numeric-to-literal token mapping, contextual fixtures, all stale codes rejected |
| X02 | 57 grammar productions have no final per-branch profile/diagnostic/AST dispatch closure | Formal EBNF + T0 coverage | Every nested choice/optional/repeat branch checked against T0/T1, no undocumented fallback |
| X03 | T0 physical record offsets proposed, no machine byte-layout tests | T0 physical + IAI | GAS offset/alignment/Ref64 generation probes on actual Win64 |
| X04 | Source capture/T0 proof not intrinsically the signed D6 source/snapshot approval | D2/D3/D6, Canonical Graph | Malicious source/local hash cannot mint Graph-linked trust |
| X05 | Public TypeReference and 15 Core Registry exports UNVERIFIED | D3 core registry + public digest pipeline | Independently recomputed exact export bytes/digests/locks and signature admissions |
| X06 | T1 tags to T2 link require real resolvers, not review fixtures | TypedHIR + Graph-linked IR | Every public operation consumes authoritative exact locked evidence; unknown fails |
| X07 | T3 state, task, key and provider uncertainty require executable invariants | D3 L2–L4 + D5 | Atomic rollback, five TaskOutcome cases, cancellation/teardown and keyed reorder tests |
| X08 | 139 physical tags and nested descriptor types lack running native verifier | IR payload owner + IR verifier | 139/139 dispatch; corruption/fuzz and semantic negative cases fail closed |
| X09 | Ownership/SSA and CFG validation unimplemented | OwnershipIR + IAI | Dominance, borrow, move, double drop and cleanup graph tests |
| X10 | Full D4 logical-to-native ABI/type codec/target admissibility not approved | D4 + LayoutIR | Real Win64 ABI probes, enum layouts and checked runtime import signatures |
| X11 | T6 native assembler backend has no machine artifact verification | TargetMIR + target toolchain | Native object/relocation/unwind and PE inspection |
| X12 | D6 reproducible signed publication/recovery unverified | D6 and release | Repeated identical builds, canonical bytes, approval and crash/recovery tests |
| X13 | T8 D5 UI/event/render/task admissions missing | D5 | Executable acceptance, accessibility, capability denial, cancellation, fault teardown |
| X14 | Grammar checker design has no executable verifier and is not a replacement for compiler | Grammar checker implementation + Assembly ABI | Independent native replay of FIRST/FOLLOW/Predict and corpus; never elevates trust |

## C. Minimal ordered closure plan — no parallel architecture

**Gate A (source closure):** reconcile lexical numeric kinds, contextual keyword policy and nested EBNF coverage; assign every AST kind exact T1 consumer. Review the grammar checker API against IAI and either implement its native verifier or retain structural calculations explicitly as review-only. Deliver stable token policy, production coverage, golden positive/negative cases.

**Gate B (public trust closure):** resolve all core TypeReference/public export digests and D2/D3/D6 immutable approvals. Test tampering, stale Graph, mismatched package/target and unauthorized service. Without B, **T2–T8 are forbidden**, even if syntax is accepted.

**Gate C (physical/semantic closure):** freeze IAI and T0 offsets after native probes; implement and test real pass validators T1–T6 including 139/139 payload paths, ownership and D4 target. Qualify semantics for L2–L4, enum/record codecs, resource cleanup. Tests must exercise negative cases, not just schema shape.

**Gate D (native/release):** pin supported assembler, linker, SDK; produce real COFF/PE, validate runtime services and D5, independent signing/admission and D6 reproducibility/recovery. Only here could T8 acceptance be considered.

## D. Implementation-readiness verdict

- **Design coverage:** broad, but no formally accepted end-to-end compiler specification yet.
- **Can begin isolated engineering probes?** YES, after choosing toolchain/version and locally scoped tests: Assembly struct-layout probes, strict JSON parser experiments, bounded grammar-checker functions. Such probes cannot claim product or ABI acceptance.
- **Can implement a fully integrated trusted native compiler from present evidence without revisiting architecture?** **NO**. Core public identities, lexer/semantic closure, trusted linkage, native ownership and target ABI remain blockers.
- **Can call the compiler working, native-tested, or release-ready?** **NO**.

**Do not create another compiler generation, second Graph, Python bootstrap or CI pipeline.** Update these owners in place and track X01–X14 through independently observable evidence. All native and release acceptance tests referenced here remain **NOT-RUN**.
