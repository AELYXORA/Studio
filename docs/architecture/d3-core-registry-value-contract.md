# D3 — Core Type Registry and Portable Value Contracts

**Status: PROPOSED design contract; NOT architect-approved, implemented, ABI-linked or native-tested.** The current **single unified graph** uses [Canonical Project Graph C9/C10](canonical-project-graph-and-components.md) for public export identity; legacy numbered core-registry profiles and their hashes below are historical design evidence, not separate current architectures. This document is the candidate logical type owner for [L0/L1](d3-type-and-binding-profile.md), [L2 State](d3-state-derived-binding-contract.md), [L3 Tasks](d3-task-result-lifecycle.md), and [L4 Keys](d3-keyed-dynamic-view-lifecycle.md). [D4 ABI Value Lowering](d4-core-value-abi-contract.md) owns physical representation; [D5 Resource Budgets](d5-ui-resource-budget-and-publication.md) owns capacity. The existing aui.core/0.1-draft is an **unapproved** first-slice core registry, not a released library. New entries below are a separately proposed extended registry profile; do not silently add them to the old L0/L1 core or modify any saved semanticGraphDigest.

## CR1. Registry identity and version rules

**Historical 13-entry exploration:** `aui.core/extended-0.2-draft` (not a released ID or active unified registry). The **current single 15-entry candidate** is `aui.core/canonical-candidate` under CR11; no verified fingerprint exists. Every accepted type entry must specify canonical qualified TypeID, definition kind, exact normalized public contract, field/variant order, type parameters and variance, effect/ownership traits, target support, feature gate, and a domain-separated exportedContractDigest. Generic instances must resolve using the **full** normalized type-argument identities/digests, never only readable names. A compiler must validate registry source/content digest before using TypeID or deriving LayoutIR; source syntax profile and native ABI version remain independent axes.

The intended logical TypeIDs below are candidates. No current D2/D6 export fixture implicitly incorporates them. A name-only lookup, a pinned digest string without verified registry bytes, or a target-specific layout is insufficient for type resolution.

## CR2. Closed logical scalar and container definitions

| Logical type | Contract | Admission profile |
| --- | --- | --- |
| Unit | Exactly one zero-payload value; never null pointer | L0/L1 |
| Bool | Exactly two logical values false/true; no truthy integer coercion | L0/L1 |
| U32 | Unsigned 32-bit integer, range 0..2^32-1 | L0/L1 |
| U64 | Unsigned 64-bit integer, range 0..2^64-1 | L4 key carrier; no JS floating-number coercion |
| String | Immutable Unicode scalar sequence, encoded as strict UTF-8 at portable byte boundaries; not NUL-terminated by contract | L0/L1 |
| List<T> | Finite immutable ordered sequence of one **exact nominal** element type T, with immutable length and indexed pure reads under an owned lifetime | L4 only |
| StableKey | Tagged closed union StringKey(String) / U64Key(U64), with full value equality including tag | L4 only |
| Result<T,E> | Closed Sum Success(T) / Failure(E); a **provider semantic result**, not request admission state or an exception | L0/L1 command signature; L3 task return |
| Event<T> | Typed immutable occurrence value with origin and generation; does not itself own a native subscription | L1 |
| StateRevision | Monotonic nonnegative logical UI-owner revision, scoped to one owning component/generation, not GraphRevision or HEAD epoch | L2 |
| TaskOutcome<T,E> | Closed five-way union: Successful(T), Failed(E), AdmissionRejected(AdmissionError), Cancelled(CancellationConfirmation), ProviderUnavailable(ProviderError) | L3 |
| TaskSlot<T,E> | Source-declared slot contract bound to one live ViewIdentity/generation; max one active request per slot in current candidate | L3 |
| TaskTicket | Runtime owned opaque request identity with generation and owner, not stable serialized user data | L3/D4 |

No implicit String/StableKey conversion, numeric widening, raw pointer reinterpretation, Result-to-TaskOutcome cast, TaskTicket serialization, or Float-based U64 conversion is admitted. These entries do not authorize general List mutation, reflection, user generic syntax or binary FFI.

## CR3. String, StableKey and List invariants

String equality for runtime key values compares exact Unicode scalar sequences, not visual graphemes or NFC/casefold normalization. This differs intentionally from source **identifier** NFC normalization. Strict valid UTF-8 storage is mandatory for external byte transfers; an embedded U+0000 is a value character and never a terminator. Internal String storage can be target-optimized only while preserving exact values and logical ownership. String byte length, scalar count and grapheme count are distinct; no substring may split a Unicode scalar at a byte boundary.

StableKey.StringKey payload has UTF-8 byte length in 1..256 (candidate D5 limit); StableKey.U64Key is exact full-range 64-bit. Equal keys require identical variant tag and identical value. The candidate **portable key encoding** is tag 0x01 + 4-byte unsigned big-endian UTF-8 byte length + exact bytes for StringKey, or tag 0x02 + 8-byte unsigned big-endian integer for U64Key. The runtime identity path is an ordered length-framed sequence of such components plus typed owner/template identities; it must not concatenate readable strings with slash separators. Portable key bytes are for canonical equality/identity interchange, **not a memory struct or native calling convention**. Reject overlength/invalid UTF-8, malformed tag, mismatched length and noncanonical encodings.

List<T> is an immutable value/owned shared snapshot, NOT a borrowed pointer to an asynchronously mutable data source. Elements are in authored sequence for presentation; StableKey is a separate immutable named field of each nominal record type. A list update is a new immutable revision; a UI reconciliation may not read a mix of two list revisions. The fixed first L4 candidate is at most 256 elements in one ForEach. List capacity/byte budget is independently checked before constructing or retaining the next snapshot. Nested dynamic lists need total-tree and depth budgets from D5.

A record field marked immutable for stable identity must remain unchanged within that record incarnation. Changing its key is removal plus insertion under [L4](d3-keyed-dynamic-view-lifecycle.md), never a mutation that carries old UI TaskTickets into a new key.

## CR4. Result versus TaskOutcome — discriminants and terminal semantics

A *provider* result has two branches only: Success(T) or Failure(E). Provider failure E cannot be encoded as a successful T merely because a UI task was admitted. A *UI request* may fail before a provider ticket exists; AdmissionRejected and ProviderUnavailable are **not** provider terminal Result values. A confirmed Cancelled requires completion/quiescence evidence, not just a requested cancellation. Successful and Failed represent actual accepted provider outcomes.

There must be exactly one terminal **TaskOutcome** per accepted TaskSlot request when a live delivery subscription exists, or explicit owned cleanup if the view was unmounted. Exactly-once physical external effects are NOT promised. A bounded delivery failure must retain a safe owned result or diagnose a rejected admission; it cannot fabricate Successful or leak buffers.

A TaskOutcome variant carries one exact nominal payload; no hidden conversion to String. Pattern matching is exhaustive, one distinct arm for each of five variants per current L3 syntax. TaskOutcome's closed logical variant order is **Successful, Failed, AdmissionRejected, Cancelled, ProviderUnavailable**; ABI discriminant numeric mapping remains D4.

CancellationConfirmation cannot be generated from deadline expiry or a cancel request alone. ProviderError and AdmissionError must be declared exact closed error registries with stable categories; OS integers and secrets are supplementary evidence and not portable type identity.

## CR5. Ownership, traits and error surface

- Unit/Bool/U32/U64/StateRevision: Copy + Send as **logical immutable values**; this does not by itself define a CPU register/struct layout. StateRevision's owner/generation context must still be verified on every write.
- String: owned immutable reference-counted/arena/inline representation may vary; cross-domain Send only when an exact immutable-owned transfer is proved. A borrowed StringView is **not** automatically Send or storable in State.
- List<T>: Send only if T's owned representation is Send and the list retains a safe immutable owner across the transfer. Copy is **not** automatically a cheap pointer copy; precise retain/release contract required.
- StableKey: immutable owned StringKey or scalar U64Key, with no raw borrowed owner or native handle.
- Result/TaskOutcome: Send only if every reachable payload/variant is Send and ownership transfer of the selected variant is proven. Cancelled and failure outcomes have the same cleanup obligations as Success.
- TaskTicket and native handles: opaque non-Copy runtime resources, no serialization, no use after generation close. Borrowing one across await/thread boundary without a pinned lease fails OWN_ASYNC_ESCAPE / OWN_NOT_SEND.
- Unknown or unapproved trait proof => reject, never assume Send/Copy by name.

## CR6. Candidate stable diagnostic categories

CORE_REGISTRY_UNRESOLVED, CORE_CONTRACT_DIGEST_MISMATCH, TYPE_GENERIC_ARG_MISMATCH, TYPE_TRAIT_UNPROVEN, AUI_KEY_TYPE, AUI_KEY_TOO_LARGE, AUI_KEY_DUPLICATE, AUI_TYPE_MISMATCH, AUI_OUTCOME_NONEXHAUSTIVE, OWN_NOT_SEND, OWN_ASYNC_ESCAPE, AUI_STATE_STALE, AUI_TASK_STALE. Runtime queue/admission/target diagnostics remain owned by D5/D2.

## CR7. Approval blockers

A fully typed exported core-registry schema with public contract digest vectors, exact referenced primitive registry, fully specified generic instantiation and recursive/variance policy, logical error registries, immutable owned List and String value semantics, compiled AST key-field selection, and a confirmed migration plan from aui.core/0.1-draft. D4 then separately specifies native binary layouts and ABI gates. Until approved and native-tested, this is a **logical design candidate**, not a released stdlib.

## CR8. Proposed domain-separated public core contract digests

[D2/D3/D6 Core Export Digest](d2-d3-core-export-digest-contract.md) describes a **historical** aui.export-contract/v2-core candidate whitelist/SHA-256 frame; [13 historical type hash vectors](../../examples/aui-language/d2-d3-core-export-digest-vectors.json) give reference normalized bytes and a set fingerprint which **must not** be copied onto the current 15-entry registry. C10/CR11 will require one reviewed new full logical encoding before any current fingerprint is trusted. Existing v1 record/component digests and source-profile compatibility are unaffected; no approved mixed v1-v2 type migration exists. Native String/List/StableKey/TaskOutcome layouts are separately specified as *proposed Win64 frames* in [D4](d4-win64-native-component-abi.md), not inferred from portable type digest values. No ABI/core runtime tests passed.

## CR9. Logical Result versus native Win64 tagged envelope

[Proposed Win64 Outcome Descriptor](d4-win64-module-and-result-descriptors.md) defines one 80-byte native *container* reused under an exact expected logical type identity: two provider Result cases and five distinct UI TaskOutcome cases. The same tag number without its verified expected TypeID is not sufficient to decode a payload. Failure before provider admission never manufactures a Result<T,E>. The native container is a D4 candidate, not part of the D3 exported-contract digest or an approved cross-platform value representation.

## CR10. Bounded G1 instances and no implicit v1/v2 mixing

[Generic Instantiation Identity](d2-d3-generic-instantiation-identity.md) historically proposed a separate type identity domain binding template digest + ordered resolved nominal argument/digest pairs. The current unified canonical TypeReference keeps that tuple principle but cannot import its historical hash domains unreviewed. The same List<T> **template digest is not** List<String> instantiated digest, and Result<U32,String> differs from Result<String,U32>. [v1/v2 policy](d2-d6-core-profile-compatibility.md) deliberately blocks List<Row> with v1 user record until explicitly reviewed type-reference schema/migration. [G1 vectors](../../examples/aui-language/d2-generic-instantiation-vectors.json) are design arithmetic only. Native target layout and D4 signature/loader proof still required.


## CR11. Reconciled current core inventory for one canonical graph — PROPOSED / P0 OPEN

The [15-entry current review inventory](../../examples/canonical-graph/core-registry-candidate.json) and its [structural schema](../../schemas/canonical-core-registry-candidate.schema.json) are the **only active inventory candidate** for the unified graph, **not** a separately numbered architecture or released registry. The previous [13-entry exploratory inventory](../../examples/aui-language/d3-core-registry-proposal.json), its fixed reference hashes and existing frozen snapshots remain unchanged as historical evidence. The new candidate registry ID `aui.core/canonical-candidate` is merely a named unresolved dependency; it is NOT a verified `coreRegistryFingerprint` and cannot be used to execute the unified sensor fixture.

### Closed names and admission boundaries

| Category | Types | Admission and portable obligation |
| --- | --- | --- |
| Logical scalars | `Unit`, `Bool`, `U32`, `U64` | Exact value-domain/trait semantics per CR2–CR5; no native layout is implied |
| Sensor data | `Bytes`, `F64` | Both appear in the canonical sensor records but were **absent** from the previous 13-entry inventory. `Bytes` denotes an owned immutable octet sequence. `F64` is IEEE-754 binary64 only as a **proposed logical type**; NaN payload/equality, signed zero, infinity, rounding and portable non-JSON encoding remain P0 and therefore its export digest cannot be trusted |
| UI values | `String`, `StableKey`, `StateRevision` | Exact Unicode scalar/key representation and UI-owner generation; no implicit string-key coercion or GraphRevision equality |
| Public generic templates | `Event<T>`, `List<T>`, `Result<T,E>`, `TaskOutcome<T,E>` | Exact template arity 1/1/2/2; bounded acyclic **nominal** arguments; conditional ownership traits; no implicit nested generics or trait inference |
| Runtime-only names | `TaskSlot<T,E>`, `TaskTicket` | Opaque/affine runtime resources. Their presence in an AUI declaration does **not** make them serializable public package port/record/operation payload types. Never create a portable `TypeReference` that lets an opaque native ticket escape to D2 dataFlow or D6 snapshot |

**Syntactic feature gate is separate from type availability.** `D2-graph` for `Bytes`/`F64` permits explicit graph/package type references once verified; it does not grant AUI F64 literals, arithmetic, an FFI layout or hardware access. L0/L1, L2, L3 and L4 gates restrict AUI source grammar independently. A target may qualify a type only after its target-specific native layout, ownership and effects are approved; an unsupported platform fails closed.

The five branches of `TaskOutcome<T,E>` still refer to unresolved exact logical error/control contracts: `AdmissionError`, `ProviderError`, and `CancellationConfirmation`. These must be explicitly declared/qualified and pinned before the TaskOutcome public contract is frozen. A merely named branch or a provider Result with matching payload size is insufficient. CancellationConfirmation MUST correspond to quiescence, not mere cancellation request. **Do not expand the current inventory with unreviewed invented error types to make a hash appear complete.**

### Exact export dependency obligations

1. Pin exact authenticated registry **bytes and semantic definitions**, then check all 15 unique TypeIDs, declared kind, arity, gate, ordered variants and traits against the owning CR2–CR5 rules and [Canonical C10](canonical-project-graph-and-components.md). A `semanticSummary` in the candidate JSON is explanatory prose, **not canonical digest input**. Before hashing, freeze complete structured public logical contracts or bind immutable normative semantics by independently verified content identity; otherwise `CORE_REGISTRY_UNRESOLVED`.
2. Compute verified primitive/core-template public export digests **only after** their closed semantics are fixed. Compute the registry fingerprint over the sorted set of exact verified `{typeId,contractDigest}` pairs plus the registry's immutable identity, not over filenames, review prose, a UI screenshot or a project-authored fingerprint string.
3. Resolve user-defined record fields in authored order, using full verified TypeReference identities. Reject unknown owners, stale referred digests, duplicate field names, unsupported self/mutual recursion and invalid generic reference templates. The schema currently admits nominal/generic references syntactically but does **not** prove their definition or non-recursion.
4. The canonical TypeReference generic representation admits 1–2 **nominal** arguments. Only explicitly admitted templates `Event`, `List`, `Result`, `TaskOutcome` may appear at the portable type boundary, and only if the source/target gate permits them. `TaskSlot` and `TaskTicket` are not transferable D2 payloads. `List<Row>` requires an accepted closed nominal `Row` export and separately proven owned List support; a generic template hash does not prove an instantiated value layout.
5. Compute operation contracts from their owning package/component and exact public types, then component contracts, type-export set and graph identity in that order. A published `coreRegistryFingerprint` or `typeExportSetDigest` must equal the **independently computed** value from locked inputs. Any synthetic 64-hex placeholder must reject as unverified.
6. The graph may be **design-viewed** while registry semantics are incomplete, but must not yield a trusted semanticGraphDigest, authorized executable module, signed approval or hardware action.

### Required negative coverage and remaining decisions

Reject an imported sensor package if either `Bytes` or `F64` is missing from the exact pinned verified registry; reject if a core type's semantic definition differs while its purported contractDigest stays unchanged; reject use of `TaskTicket` in persisted records or cross-domain dataFlow; reject unqualified `TaskOutcome` with missing closed error types, incorrect generic arity, nested/disallowed generics, and failed Send/ownership proof. All these are future tests, **NOT-RUN**.

**P0 remains:** complete mathematical `F64` value/codec policy; exact `Bytes` ownership/resource limits; closed error/control variant definitions; canonical core logical contract encoding and independently computed registry/export hash vectors; target ABI and source-language profile admission; explicit architect D2/D3/D4/D6 review. No historical 13-entry digest is silently reused for the new 15-entry candidate.
