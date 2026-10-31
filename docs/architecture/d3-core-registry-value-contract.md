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
| Bytes | Immutable owned octet sequence with proposed first portable interchange cap of 1 MiB; exact lowercase typed hex carrier (CR12) | D2 graph/package reference, not automatic AUI literals |
| F64 | Proposed **finite-only** IEEE-754 binary64 bit carrier; accepted signed zero/subnormals and rejected NaN/infinity (CR12) | D2 graph/package reference, arithmetic not available in L0/L1 |
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
| Sensor data | `Bytes`, `F64` | Both appear in the canonical sensor records but were **absent** from the previous 13-entry inventory. `Bytes` denotes an owned immutable octet sequence. `F64` has a precise **unapproved CR12 candidate**: bit-exact finite-only IEEE-754, signed zero preserved, NaN/infinity rejected and typed nonnumeric JSON bit notation; target arithmetic/rounding/ABI and architect acceptance remain P0, so its export digest cannot be trusted |
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

**P0 remains:** acceptance and on-target proof of the precise **CR12 proposed** finite-only F64 and bounded Bytes portable codecs; closed portable error/control export definitions; canonical structured core logical contract encoding and independently computed registry/export hash vectors; target ABI, ownership and source-language profile admission; explicit architect D2/D3/D4/D6 review. No historical 13-entry digest is silently reused for the new 15-entry candidate.

## CR12. Portable core values and task-control semantics — bounded single-model candidate

**Status: PROPOSED, pending architect approval and native evidence.** This section proposes the precise portable *value* layer for the existing 15-entry [current core inventory](../../examples/canonical-graph/core-registry-candidate.json), not a new architecture edition, native ABI, second type registry or trusted public hash profile. Type/operation identities remain owned by [Canonical Graph C9/C10/C12](canonical-project-graph-and-components.md). A value serializer may run only after the expected verified `TypeReference`, target and ownership have been resolved. **Value encodings must never be confused with public type-export hashes or JSON project manifests.**

### CR12.1 Bytes: immutable owned octets

- Logical domain: a **finite sequence of bytes** with octet values `0x00..0xff`, length `0..1,048,576` bytes in this *proposed first portable interchange profile*. Empty `Bytes` is valid and distinct from a null/missing value. Larger data must be conveyed by separately bounded chunked flows or a reviewed extended policy, never by an implicit unbounded allocation. The 1 MiB cap is a **candidate semantic profile limit**, not a measured runtime capability.
- Portable typed-JSON encoding, only when the exact expected type is `aui.core/Bytes`: one JSON **string** `"0x"` followed by exactly two lowercase ASCII hexadecimal digits per byte, with no spaces or byte separators. Thus `"0x"` is empty; `"0x00ff"` is the two-byte value 00 FF. No alternate base64, uppercase, odd-length, whitespace, numeric array or implicit Unicode decoding is accepted within this candidate.
- Decode rejects malformed prefix/hex, odd digits, oversize input and exhausted quota **before** allocation or copying. The decoder must size-check using overflow-safe arithmetic, then reserve exact owned capacity. Native pointer/length representations, allocator choice, deallocation and shared-immutable ownership remain D4/D5 obligations.
- Portable byte value equality is length plus exact octets. Copy keeps sender ownership and requires a safe owned duplicate or proven immutable shared retain; move transfers ownership **only after** successful admission, with sender retaining ownership on rejection. Borrow is not storable, not a permitted queued/snapshot dataFlow transfer and cannot outlive the current synchronous validated scope.
- `Bytes` does **not** mean a text `String`, file path, network packet or native `void*`. The portable typed string encoding is a serialization of bytes, **not** permission to use string operations on the native payload.

### CR12.2 F64: finite IEEE-754 binary64 carrier

- The initial portable logical value domain is **all finite IEEE-754 binary64 bit patterns**, including positive/negative zero, finite normals and positive/negative subnormals. Exponent bits `0x7ff` (positive/negative infinity and all quiet/signaling NaNs) **reject** with `CORE_F64_NONFINITE_UNSUPPORTED`. This deliberately avoids an unapproved NaN-payload, signaling, ordering or portable arithmetic policy in the first bounded profile.
- Only for an expected verified `aui.core/F64` typed value, portable JSON uses a **single lowercase string** `"0x"` + exactly **16 lowercase hexadecimal digits** of the unsigned **64-bit IEEE-754 bit pattern, most significant nibble first**. For example positive zero is `"0x0000000000000000"`, negative zero `"0x8000000000000000"`, and positive 1.0 is `"0x3ff0000000000000"`. The hex string is a bit-value notation independent of host memory endianness. Decimal JSON numbers, `"NaN"`, `"Infinity"`, exponent-text spellings, uppercase or shorter hex strings are rejected.
- The decoder validates shape, exponent and finiteness before interpreting or materializing a native float. It preserves **all accepted 64 raw bits** through portable decode/encode, including the sign of zero and subnormal payload. No canonicalization of `-0` to `+0`, flush-to-zero, rounding or approximate decimal conversion may occur silently. A later native target must prove these guarantees before claiming portable F64 support.
- There are **two explicitly different comparisons**: `bitIdentity` compares all 64 bits (so `+0` and `-0` are different bit identities), while an optional numerically typed `equal` compares finite numeric values (so `+0` equals `-0`). Neither is a general Graph/TypeReference identity or an implicit source-language equality operator. No total ordering, approximate equality, arithmetic, hardware rounding-mode guarantee, or nonfinite transport is introduced by this proposed carrier.
- In the sensor's `Measurement` record, the separate `valid: Bool` remains part of the public record; it does **not** turn a NaN or infinity into an accepted F64. An unavailable/failed measurement is communicated through the explicit error/result path or the record's own approved semantics, never by inventing a NaN sentinel.

These choices remove ambiguity in **candidate portable value encoding**, but public core-export digests remain blocked until the **structured logical contracts** for all 15 entries and their dependency closure are approved, not merely because sample encoded values are deterministic. Source AUI floating literals/arithmetic are still gated out of initial L0/L1. The D6 canonical JSON writer remains responsible for escaping string tokens; these typed values do not change the D6 rule forbidding JSON floating-number tokens in semantic digest input.

### CR12.3 Scalar/string/sum/opaque invariants across all 15 types

| Logical type | Exact relevant portable rule / scope |
| --- | --- |
| `Unit` | One no-payload logical inhabitant; never a null native pointer, Graph omission or untrusted marker of completion |
| `Bool` | Exactly `false` and `true` in typed JSON; numeric 0/1 and string booleans reject |
| `U32` | Exact unsigned 0..4294967295; typed JSON decimal integer when within D6 safe range, no fraction/exponent/leading zeros |
| `U64` | Exact unsigned 0..18446744073709551615; typed JSON canonical unsigned decimal **string**, with `"0"` as minimum and no leading zeroes (except zero), sign, exponent, whitespace or floating-point coercion |
| `String` | Immutable Unicode scalar sequence, strict UTF-8 interchange, preserves exact scalar values and embedded U+0000; no NFC/case folding performed on values |
| `StableKey` | Tag + exact `String` or `U64` value; retains the separate CR3 binary key framing, no implicit conversion of numeric/text keys |
| `StateRevision` | Monotonic per UI-owner/generation; not a general U64 key, global GraphRevision or persistent snapshot epoch |
| `Event<T>` | Typed payload with exact verified origin/generation; an event is not native subscription/callback authority |
| `List<T>` | Immutable ordered elements of one verified nominal type, owned snapshot and D5 list budget; no hidden alias to mutable backend memory |
| `Result<T,E>` | Exactly two provider semantic branches `Success(T)` / `Failure(E)`; no pre-admission failure or UI task metadata inserted |
| `TaskOutcome<T,E>` | Exactly five UI request outcome branches per CR4, with explicit provenance and no conflation with provider `Result` |
| `TaskSlot<T,E>` | Opaque affine UI-owner request slot, invalidated by owner/generation retirement; never portable/persisted graph payload |
| `TaskTicket` | Opaque runtime-owned pending operation handle, no portable serialization or cross-owner copy/borrow escape |

The table expresses logical invariants **only**. Apart from the precise proposed `Bytes` and `F64` wire carriers and the bounded U32/U64/Bool rules above, it does not introduce an arbitrary universal JSON encoding for every complex UI/runtime object. Such an encoding needs a distinct explicit type-directed contract and may be forbidden (notably opaque handles).

### CR12.4 Closed outcome categories versus public type exports

`AdmissionRejected`, `ProviderUnavailable` and `Cancelled` are UI-request outcomes, not substitute provider `Result` branches. The following **candidate internal category sets** explain deterministic routing without silently inventing three new verified portable core TypeIDs:

- **AdmissionError category**: `invalid-arguments`, `capacity-exceeded`, `stale-view`, `capability-denied`, `unsupported-target`. Admission rejection can occur *before* any provider ticket is created; it must not be recorded as a provider failure result. When stale view prevents delivery, the runtime retains proof/cleanup rather than invoking the retired view.
- **ProviderError category**: `provider-unavailable`, `link-unresolved`, `abi-unverified`, `transport-failure`. These indicate failure to admit or maintain a verified provider path; a provider's declared `Failure(E)` after successful operation admission is **not** converted to this runtime category.
- **CancellationConfirmation** is not a boolean user payload. Its minimum internal proof tuple binds `TaskTicket`, exact owner and generation, and a provider-quiescence result. Only trusted runtime/provider transition to a confirmed terminal state can construct it. A cancel request, deadline, view unmount or UI close by itself provides no such proof; native resources remain owned until actual completion/quiescence.

These names are **provisional internal diagnostics/control contracts**, not a completed TypeReference export. The full portable/public payload types, discriminants, exact ownership, callback origin, error fields, trust model and D4 ABI still require explicit architect decision before `TaskOutcome<T,E>` may receive a trusted exported-contract digest. A missing/error category MUST fail closed rather than be mapped silently to `Successful` or `Cancelled`.

### CR12.5 Candidate vectors, limits and explicit rejection

[Portable core value reference cases](../../examples/canonical-graph/core-value-boundary-cases.json) cover exact `Bytes`/`F64` bit shapes, all-zero and maximum integer bounds, nonfinite rejects, signed zero and opaque/TaskOutcome admission failures. **These are documentary expected outcomes; no AELYXORA parser, native runtime or released core export hash has executed them.**

Acceptance still requires a standards-complete strict JSON decoder and exact type-directed codec, deterministic cross-host vectors for all admitted values, per-target ownership/ABI qualification, proof of reserved memory budgets and bounded error behavior, plus the missing structured core error exports and human D2/D3/D4/D6 sign-off. **CR12 is a precise proposal, not a frozen released type system.**


## CR13. Closed TaskOutcome control payloads and public contract readiness — one-model proposal

**Status: PROPOSED / review-only.** This refines the five existing `TaskOutcome<T,E>` branches without adding `AdmissionError`, `ProviderError` or `CancellationConfirmation` as independently importable core TypeIDs. Their nested **logical payload definitions** belong to the same `TaskOutcome` template's public semantic contract. [T9](d3-task-result-lifecycle.md) continues to own runtime transitions, while [C10/C12](canonical-project-graph-and-components.md) owns graph/export identity. Opaque native tickets and trusted proof artifacts remain runtime resources, never public payload bytes.

### CR13.1 Complete candidate discriminants and ordered branches

The `TaskOutcome<T,E>` logical template has exactly two invariant, fully resolved nominal type parameters, ordered `T,E`. Its closed case order is **Successful(T), Failed(E), AdmissionRejected(AdmissionError), Cancelled(CancellationConfirmation), ProviderUnavailable(ProviderError)**. Case spellings and their payload contracts are semantic, not labels or native ABI tag numbers. An accepted provider `Result<T,E>` has **only** `Success(T)` and `Failure(E)`; it does not have the TaskOutcome UI admission cases.

For *candidate logical values only*, the three nested payload definitions are:

| Nested payload | Public logical fields | Allowed values and rule |
| --- | --- | --- |
| `AdmissionError` | `code` | Closed enum: `invalid-arguments`, `capacity-exceeded`, `stale-view`, `capability-denied`, `unsupported-target`. Requires definitive proof that provider dispatch never occurred. |
| `ProviderError` | `phase`, `code` | `phase` is `never-admitted` or `indeterminate-after-admission`. `code` is `provider-unavailable`, `link-unresolved`, `abi-unverified`, `transport-failure`. The admissible (phase,code) matrix below is mandatory. |
| `CancellationConfirmation` | `state` | Constant `confirmed-quiescent`. Only a trusted terminal provider/runtime proof can construct this state; the public value is **not** itself evidence that a raw native handle is safe to free. |

**Pair matrix for ProviderError:** `never-admitted` permits any of the four codes **only with positive no-dispatch proof**. `indeterminate-after-admission` permits only `provider-unavailable` and `transport-failure` when dispatch may have occurred but terminal/quiescence is unknown. `link-unresolved` and `abi-unverified` belong to pre-admission validation; if discovered only after dispatch, report a distinct internal integrity incident and retain uncertainty/ownership rather than misrepresenting a normal failure. An implementation may not map `indeterminate-after-admission` to `AdmissionRejected` or `Cancelled`.

**Closed-object rule:** the candidate value representations have only the fields listed above, with no `message`, OS error number, raw pointers, secret tokens, `TaskTicket`, arbitrary metadata, user-controlled proof or untyped `details` property. Human-readable diagnostics and source spans belong to a separate redacted evidence channel, not to these portable semantic values.

**Provenance and constructor rule:** `AdmissionRejected` needs an internally authenticated no-dispatch decision; `ProviderUnavailable(never-admitted)` likewise requires no-dispatch proof; `ProviderUnavailable(indeterminate-after-admission)` may settle the *original UI slot once* but does not settle native provider ownership; `Cancelled` requires trusted provider terminal/quiescence confirmation for that exact owner/ticket/generation and cannot be constructed by calling `TaskOutcome.Cancelled` from user AUI source. An already settled UI slot cannot be settled again by late completion; that completion remains an owned cleanup/audit event.

**Typed source exposure is deliberately restricted:** AUI may exhaustively *match* a received TaskOutcome and inspect its closed, explicitly permitted `code`/`phase`/`state` fields through a future accepted grammar, but may not construct or forge these three runtime-control payloads, persist an opaque request ticket or call a native cancellation-confirmation constructor. The initial L0/L1 source subset still does not admit arbitrary TaskOutcome values.

### CR13.2 One registry, two separate admissibility checks

The [current 15-entry inventory](../../examples/canonical-graph/core-registry-candidate.json) now carries an explicit `semanticModel` **candidate** per type. Its `category`, ordered `typeParameters`, ordered `variants`, `portableCarrier` and `ownershipClass` are machine-inspectable design inputs. The companion [inventory schema](../../schemas/canonical-core-registry-candidate.schema.json) validates their shape, not whether an implementation is safe.

1. **Logical definition consistency:** match the `semanticModel` against this owning CR2–CR13 contract, enforce exact type ID/arity/variant order, generic argument closure, ownership traits and the current language gate. An unsupported/opaque value must be rejected as a portable Graph/D6 payload regardless of its syntactically valid TypeReference.
2. **Hash and execution readiness:** canonical semantic identity is computed only after *all* referenced core/nested error definitions and their immutable rule semantics are approved and authenticated. A JSON object's `semanticModel` and `semanticSummary` are **not** an independently trustworthy public registry; changing them without a reviewed semantic contract cannot produce a valid `coreRegistryFingerprint`. All 15 entries remain `exportStatus: "UNVERIFIED"` pending sign-off, signed source closure, independent canonical vectors and native target layout/ownership evidence. **No automatic digest promotion** from historical core vectors or from syntax-only schema checks.

The one current runtime/source type boundary MUST reject `TaskTicket` and `TaskSlot<T,E>` as public graph dataFlow types, record fields or command return payloads. `Event<T>` is a source-facing event value with required origin/generation proofs, not a raw transport capability. `TaskOutcome<T,E>` itself can be a typed UI local result only where the L3 contract admits it; it is not an unqualified D2 hardware stream type.


### CR13.4 Candidate logical projection skeleton — not a digest preimage yet

For auditing changes to the **single** current inventory, an implementation-neutral *candidate comparison skeleton* of each entry contains exactly `typeId,kind,typeArity,featureGate,logicalTraits,semanticModel`. Sort the unique `logicalTraits` and `semanticModel.ruleIds` sets by canonical UTF-8 bytes. Retain the exact ordered `semanticModel.typeParameters` and `semanticModel.variants`, and the semantic `category,portableCarrier,ownershipClass,graphPayloadEligible` flags. Compare entries by exact `typeId`, and sort the whole registry by that identity. This derives no new authored source model.

**Explicitly exclude from the skeleton:** `semanticSummary` (human text), `unresolvedObligations` (review ledger), `semanticsOwner` (source navigation), `nativeLayoutStatus` (machine evidence) and `exportStatus` (review status). However, **exclude does not mean trusted**: `exportStatus=UNVERIFIED` is a mandatory *admission blocker*. A release writer MUST reject hashing if any contract remains unapproved, even if the skeleton bytes are identical between two source files.

**Critical missing input:** a `ruleId` is currently only a document reference, not an immutable, versioned definition of its *meaning*. This skeleton is **NOT yet a complete public type-contract digest preimage**. Public type hashing requires each referred rule's normalized complete semantic definition and separately authenticated immutable content identity, plus frozen error/control payload contracts. Hashing only human rule names would permit their normative meaning to change without invalidating the type hash. Until that design is approved, a programmer or AI MUST NOT invent `contractDigest` or `coreRegistryFingerprint` from this candidate.

[Core definition mutation review cases](../../examples/canonical-graph/core-definition-review-cases.json) classify which changes preserve this *review skeleton*, modify its fields, or must be rejected before any public export resolution. The cases are design-only, **NOT-RUN**, and do not stand in for approved cryptographic vectors or qualified native ABI.

### CR13.3 Design-only verification and still-open questions

The [TaskOutcome control negative/positive matrix](../../examples/canonical-graph/task-control-payload-cases.json) defines strict accepted/rejected **logical shape** expectations, including invalid phase-code combinations, attempts to forge cancellation, open objects, unknown enums and false no-dispatch proof. It never treats a syntactically well-formed value as *runtime proven*; values labeled `shape-accept` still require authenticated origin at runtime.

**P0 OPEN:** exact finalized structured type/export byte projection (including semantic meaning of each rule and type accessibility), verified core registry content identity and public digests, full TaskOutcome outcome transport and ABI discriminants, constructor authorization/non-forgeability, retained indeterminate provider state and disposal policy, AUI L3 source match grammar, D4 ownership, D5 bounds and D6 evidence retention. No golden hash, core fingerprint, native acceptance or architect sign-off is claimed.
