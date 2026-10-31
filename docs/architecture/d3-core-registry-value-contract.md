# D3 — Core Type Registry and Portable Value Contracts

**Status: PROPOSED design contract; NOT architect-approved, implemented, ABI-linked or native-tested.** This document is the candidate logical type owner for [L0/L1](d3-type-and-binding-profile.md), [L2 State](d3-state-derived-binding-contract.md), [L3 Tasks](d3-task-result-lifecycle.md), and [L4 Keys](d3-keyed-dynamic-view-lifecycle.md). [D4 ABI Value Lowering](d4-core-value-abi-contract.md) owns physical representation; [D5 Resource Budgets](d5-ui-resource-budget-and-publication.md) owns capacity. The existing aui.core/0.1-draft is an **unapproved** first-slice core registry, not a released library. New entries below are a separately proposed extended registry profile; do not silently add them to the old L0/L1 core or modify any saved semanticGraphDigest.

## CR1. Registry identity and version rules

Candidate ID: aui.core/extended-0.2-draft (NOT a SemVer upgrade or implicitly shipped feature). Every accepted type entry must specify canonical qualified TypeID, definition kind, exact normalized public contract, field/variant order, type parameters and variance, effect/ownership traits, target support, feature gate, and a domain-separated exportedContractDigest. Generic instances must resolve using the **full** normalized type-argument identities/digests, never only readable names. A compiler must validate registry source/content digest before using TypeID or deriving LayoutIR; source syntax profile and native ABI version remain independent axes.

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

[D2/D3/D6 Core Export Digest](d2-d3-core-export-digest-contract.md) defines the proposed aui.export-contract/v2-core whitelist and SHA-256 frame; [13 type hash vectors](../../examples/aui-language/d2-d3-core-export-digest-vectors.json) give reference normalized bytes and a registry set fingerprint. Existing v1 record/component digests and source-profile compatibility are unaffected; no approved mixed v1-v2 type migration exists. Native String/List/StableKey/TaskOutcome layouts are separately specified as *proposed Win64 frames* in [D4](d4-win64-native-component-abi.md), not inferred from portable type digest values. No ABI/core runtime tests passed.
