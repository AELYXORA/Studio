# D2/D6 Architecture Baseline Review — Decision and Contradiction Register

**Review state: OPEN — design candidate only, not architect-approved.**
**Repository policy:** edit main directly; no branches or PRs. **Project phase:** Documentation (D1–D8). Neither D2 nor D6 is implemented or verified.

This register captures actual cross-document contract conflicts and tracks what was changed, what remains unresolved, and what explicit human decisions are needed. It does not replace any owning specification. Source of truth for individual rules is the named document. It is intentionally **finite**: once every blocking design decision has an accepted disposition and every required design fixture is complete, D2/D6 documentation can be frozen for the chosen first slice.

## BR1 — System boundary and baseline invariants

1. Architecture Map, Workflow Map and Data Flow Map are projections of ONE canonical, typed Project Graph.
2. Human architect approves semantic changes and authorized effects. AI is a proposal-producing implementation engineer and may never infer runtime permission.
3. D2 defines **what a component/workflow/data-flow/target means**. D6 defines **which exact declarative and source bytes make up a project snapshot**. D3 defines declarative AUI source, D4 ABI, D5 runtime implementation. Boundary-crossing contracts need explicit typed IDs and target proof, not diagram position.
4. Persistence of project definitions is distinct from in-memory ExecutionID/CommandTicket. A crash cannot be rolled back across an external hardware/network effect.
5. A *logical export contract* is distinct from the exact *package implementation*. Same contract can have new ASM source bytes: semanticGraphDigest must stay the same, while packageContentDigest/snapshotDigest/build evidence change.
6. Two-slot HEAD publication is a **candidate**, not a proof of power-loss durability on Windows/NTFS or Linux local filesystem. Unverified adapters must not claim successful durable commit.
7. All fixtures and native tests remain NOT-RUN; external reference SHA-256 computation is evidence for **test-vector arithmetic only**, not acceptance by AELYXORA.

## BR2 — Closed-by-edit documentation discrepancies (still need architect approval)

| ID | Conflict or gap found | Proposed reconciliation already written | Owning documents |
| --- | --- | --- | --- |
| R-01 | Old ResolvedType equality included lockedPackageContentDigest while source-only formatting was promised not to change semanticGraphDigest | Separate LogicalExportIdentity (public contract digest) and ResolvedImplementationIdentity (package/source/ABI bytes) | [Export Contract](d2-export-contract-identity.md), [D2 Identity](d2-identity-and-type-resolution.md), [Canonical Persistence](d6-canonical-persistence.md) |
| R-02 | Canonical example used resolvedPackages while semantic projection now speaks about logical exports | Use resolvedExports for semantic projection; implementation package lock resides separately | [Canonical vectors](../../examples/architecture-sensor/d2-canonical-vectors.json) |
| R-03 | No portable exported contract digest algorithm or byte fixture | Proposed normalized type/component projection and domain-separated hash; codec-only export vectors | [Export Contract](d2-export-contract-identity.md), [Export vectors](../../examples/architecture-sensor/d2-export-contract-vectors.json) |
| R-04 | OperationId could be named in CAS but not correlated with recovered snapshot/HEAD | Candidate operationId present in both HEAD and snapshot index; must match. Genesis uses null | [HEAD schema](../../schemas/project-head.schema.json), [Index schema](../../schemas/project-snapshot-index.schema.json), [D6](d6-canonical-persistence.md) |
| R-05 | Package lock listed version/source but no per-export logical contract digest registry | Draft lock resolved-entry exports list records kind, TypeID and logical contract digest; validator recomputes from verified package | [Package-lock schema](../../schemas/package-lock.schema.json), [Package Resolution](package-resolution-build.md) |
| R-06 | Incomplete schema described retired ID digest and per-file ownership as optional | Draft snapshot index now requires retiredIdentityDigest, operationId and file ownership entries; actual values still need semantic checking | [Index schema](../../schemas/project-snapshot-index.schema.json) |
| R-07 | Reference hash vectors had no explicit independent audit of all framing inputs | Package, snapshot and HEAD hashes cross-checked against independent SHA-256 arithmetic. This is a calculation check, not a runtime test | [Integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json), [Export vectors](../../examples/architecture-sensor/d2-export-contract-vectors.json) |
| R-08 | Same terms 'tested/linked/exported' could collapse design-only declarations into executable support | Separate structural fixture validation, nominal export resolution, source/ABI linkage, build and on-target test evidence | [D2 Identity](d2-identity-and-type-resolution.md), [Graph ↔ AUI](project-graph-aui-contract.md) |

These rows document corrections in the proposal. **Do not mark them Accepted solely because source documents now agree.**

## BR3 — Blocking first-slice architectural decisions (P0)

| ID | Decision the architect must accept / reject | Candidate recommendation | Consequence if unresolved |
| --- | --- | --- | --- |
| P0-01 | Persistent-ID grammar and retired-ID scope | Case-sensitive ASCII IDs, explicit tombstones by kind/scope, no reused IDs | Graph migration and identity reconciliation cannot freeze |
| P0-02 | Nominal TypeID and export contract digest | Use domain-separated logical export digest separate from package implementation bytes | Graph and package cache invalidation remain contradictory |
| P0-03 | Core primitive registry and type recursion | Pin core type IDs/revision, support only nonrecursive record types initially | Transitive logical export digests are not fully defined |
| P0-04 | Complete semanticGraph projection | Explicit type/target/capability whitelist, sorted only semantic unordered arrays; exclude display labels and implementation-byte hashes | Different engines can compute different graph hashes |
| P0-05 | Package manifest/source inventory and extra resources | Manifest + explicit source files only; reject untyped extra fixture/resource inventory for locked builds | Package digest portability not assured for richer packages |
| P0-06 | Package lock export registry and dependency-version conflict | Exact digest-verified package files; one version per packageId for first slice; sorted unique export identities | 'ResolvedType' may select ambiguous or stale bytes |
| P0-07 | HEAD/index operationId and duplicate save reconciliation | HEAD and index bind the same last commit operationId; genesis null | A crash after commit but before acknowledgement can trigger duplicate publication |
| P0-08 | Durable idempotency history across more than last two HEAD slots | Choose bounded persistent operation ledger or explicitly unsupported historical replay; do not promise unlimited idempotency | OperationId replay semantics currently incomplete |
| P0-09 | Exact on-disk schema and HEAD/index canonical bytes | Formalize required fields, checksum frame, snapshot manifest/lock inventory, immutable packageObjects, source/view revisions and retention rules | A crash-safe snapshot cannot be declared design-complete |
| P0-10 | First host/FS durable publication profile | Candidate: Windows x64 Studio with qualified local NTFS; Linux x86-64 separate bootstrap adapter. **Actual durability unverified** | Atomic/durable save strategy not anchored to one real host |
| P0-11 | Reparse/symlink/TOCTOU, case collisions and writer lease | Handle-relative safe path access + sourceRoot containment; reject unsafe storage classes | Package and snapshot path escape risks |
| P0-12 | Recovery degradation and retention | Two HEAD slots, retain prior verified snapshots, never silently roll back corruption; stop on two invalid slots | Ambiguous data-loss and garbage collection behavior |
| P0-13 | D2 workflow and provider contract | Typed signals, bounded mailbox, no automatic replay, cancellation request != completed operation | D2 -> D5 semantics can diverge |
| P0-14 | Source ↔ Graph ↔ AUI and ABI handoff | Typed import/export reconciliation without implicit source overwrite; native register/stack layout remains D4-owned | AI-generated code cannot have deterministic acceptance contract |
| P0-15 | User-visible source of security/release truth | Actual target/toolchain/artifact verification, not contract or AI assertion | Semantic equality can be mistaken for runtime safety |

**Recommended host decision is a candidate, not an inferred or granted architect sign-off.**

## BR4 — Hard review blockers not resolved by more prose alone

**Gaps still requiring specification decisions and concrete examples:**
- Complete field-by-field semantic graph projection for real sensor graph (not just tiny shape-only vectors) with nominal type dependencies, capability sets, hardware resource maps, and target exactness.
- Core type registry version, field/enum/generic layout/recursion; target-compatible export projection and ABI bridge. D3/D4 ownership of those rules must be explicit.
- A first [locked pure reference fixture](../../examples/locked-pure-reference/README.md) now contains real declared ASM source bytes, a matching lock, exported-contract digests, a package object, and a genesis snapshot/index/HEAD. It is documentation-only: no verified D4 ABI, native parser or target evidence. A fully executable sensor/hardware fixture is still missing, for design-time byte/hash conformance. Current sensor package declares absent ASM files and cannot be locked or executed.
- JSON parser canonical unicode escape policy, numeric bounds and maximum input/entity limits per first host, with false/negative vectors; package extra resources/fixtures handling.
- Exact source ownership, atomic workspace writer lease, operationId persistence beyond two HEAD slots, duplicate operation replay policy.
- HEAD crash/recovery proofs per selected platform filesystem, including directory durability on Linux and NTFS replacement/write-through on Windows. This is Phase III runtime evidence and cannot be accepted as already run during documentation.
- Explicit approval of remaining D2 edge kinds, workflow first-profile restrictions, runtime capability and error contracts; avoid silently expanding scope.
- Signed/unsigned package trust model, offline dependency provenance and threat-model decision before release.

## BR5 — Sequential phase gates and acceptance rubric

**Phase I — DOCUMENTATION (current)**

- Every P0 decision has recorded Accepted/Rejected/explicitly bounded Deferred outcome **with rationale**; critical unresolved choices block design freeze.
- Each owner file contains normative *candidate* grammar/algorithm, authority boundaries, positive and negative test vectors, stable diagnostics, target assumptions and exact future acceptance procedure.
- Full sensor design trace includes immutable graph + exact locked package + exported contracts + workflow/data flow + declared AUI/ASM boundaries + staged snapshot + AI proposal permission/checks.
- A final cross-document review finds no contradictory required behavior; architect explicitly signs off accepted baseline commit. Without sign-off statuses remain Proposed/Open.

**Phase II — IMPLEMENTATION** of accepted native first-host slices only, followed by **Phase III — observed testing** and **Phase IV — correction/reverification**. Existing exploratory Linux lexical preflight and this package of documents do not count as completed Phase II/III.

## BR6 — Proposed review record (currently unapproved)

    Scope: D2 Project Graph + D6 persistence and package resolution
    Candidate baseline: current main, reviewed at explicit commit SHA before sign-off
    Status: Proposed / Open
    Accepted decisions: NONE recorded in this register
    Reviewed vectors: semantic shape, logical export, package bytes, snapshot index, HEAD
    Unresolved: BR3 P0-01 .. P0-15 (some candidate policies documented)
    Authoritative approval: requires explicit human architect decision
    Native Studio validation: NOT-RUN
    Windows/Linux durability: UNVERIFIED
    Follow-on: close remaining specs in owners; perform D2/D6 review again;
               then proceed to comprehensive D3/D4/D5/D7/D8 documentation
               before any new product implementation

This review must never be presented as a D2/D6 approval or a production guarantee.

## BR7 — Additional recoverability consistency finding (proposed)

**R-09:** A lock digest and package content digest are not a durable copy of package source bytes. The candidate snapshot index now lists packageObjects (exact packageId/contentDigest), retained in a verified immutable object store; any package object referenced by committed HEAD ancestry or a pinned runtime execution is protected from garbage collection. An index with packageObjects=[] is valid only for a codec-only or genuinely no-dependency project, not for the sensor package. This fixes a **documentation-level recoverability gap**, but actual store/publishing, garbage collection and OS durability remain P0 and Phase III proof obligations.

## BR8 — First fully byte-linked documentation fixture

[Locked Pure Reference](../../examples/locked-pure-reference/README.md) records a complete *documentary byte linkage* of two record types, two components, source inputs, graph and workflow, exact package source objects, package lock logical export digests, snapshot index and HEAD. [Canonical Semantic Projection](d2-d6-semantic-projection.md) specifies exact first-slice fields; [Offline Resolver](d6-offline-dependency-resolution.md) defines exact package closure. [Negative cases](../../examples/locked-pure-reference/negative-cases.json) are design-only. This reduces the previous missing-source/lock reference gap **without** proving ASM component ABI or implementation. D2/D6 remain PROPOSED / OPEN and require human sign-off.
