# AUI Types, Memory and Ownership

**Status: proposed normative contract, not implemented.** This document owns language-level type and lifetime semantics. [Component ABI](component-contract.md) owns physical calling conventions, and [Runtime](aui-runtime.md) owns scheduling.

## Type universe

- **Value types:** Bool, I8/I16/I32/I64, U8/U16/U32/U64, F32/F64, Unit, Enum, Record, fixed-size Array<T,N>, Optional<T>, Result<T,E>. Arithmetic has explicit overflow policy; signedness and integer width are never implicitly changed.
- **Dynamically sized types:** String (valid UTF-8, byte length distinct from scalar count), Bytes, Vector<T>, Map<K,V>. Their representation is deliberately not tied to any platform ABI.
- **Opaque resource types:** Handle<Resource,Capability>, Task<T>, Channel<T>, DeviceRegion, Buffer<T>. Native pointers are not interchangeable with resource handles.
- **Borrowed views:** Slice<T>, StringView and Borrow<T> exist only within an explicitly proven lifetime and address-space domain.
- **Unit-bearing values:** Duration, Frequency, Voltage, BytesCount and addresses with separate address-space types. Conversion across units is explicit.

## Effect model

Pure expressions cannot mutate state, perform I/O, block, access hardware, allocate unbounded memory, or dispatch commands. Effectful declarations must advertise capabilities from: state-write, allocation, filesystem, network, process, blocking, device-read, device-write, privileged, realtime and asynchronous. A capability is necessary but never sufficient for OS/hardware authorization.

## Ownership rules

1. Each allocated resource has exactly one owning handle or a documented shared-ownership mechanism; destroying the owner invalidates borrows.
2. Passing an owned value across a command/worker boundary moves ownership. Reuse after move is a compile-time error when proven statically; otherwise the runtime contract requires a checked handle.
3. Borrowed references cannot outlive the owner; cannot escape into stored state or asynchronous tasks without an explicit lifetime guarantee.
4. Immutable, self-contained values may be copied or transferred. Shared mutable values require an explicit synchronization/atomic policy.
5. Device mappings, DMA buffers and MMIO regions carry address space, alignment, cache coherency and privilege capabilities; UI components never receive raw physical pointers.
6. State slots are keyed by stable graph/component identity, declaration and view generation. A replacement generation invalidates old completion targets.
7. Memory allocation failure is an ordinary typed error, not an exception unwinding across Assembly ABIs.

## Concurrency classifications (draft)

Types declare `Send` (safe to transfer to another execution domain) and `Share` (safe to share across domains). Neither property is inferred solely from pointer shape. A raw device region is not automatically Send or Share. `Task<T>` requires an explicitly declared cancellation and destruction policy. UI-owned state is confined to its scheduler unless a typed message transfers an immutable value.

## Low-level ABI separation

AUI type identity is canonical and platform-neutral. ABI lowering maps values to target-specific registers, stack slots, padding and calling conventions. A type that is logically `String` is **not** assumed to be the same structure as a C++ string or system string. Public ABI surface uses fixed-width integers and opaque handles wherever practical.

## Required negative fixtures

Borrow-after-owner-free; use-after-move; mismatched address spaces; forbidden implicit narrowing; worker transfer of non-Send device handle; UI-thread blocking device call; unbounded allocation inside IRQ handler; stale view generation completion. Each fixture requires an unambiguous diagnostic class.

## Open decisions

Precise generics, escaping rules, compile-time borrow analysis strength, shared ownership policy, allocator API, pinning and async frame layout. No ownership checker or Assembly runtime is implemented or verified.


[OwnershipIR and Compile-Time Safety](aui-ownership-ir.md) specifies CFG-based moves, borrows, async boundaries, cleanup and rejection fixtures. Proposed; not implemented.

## First-slice D3 clarification

The [D3 Type and Binding Profile](d3-type-and-binding-profile.md) restricts L0/L1 to Unit/Bool/U32/String, Event<T>, Result<T,E>, and imported verified nominal record values; generic user value construction, mutating state, bind and async lifetime syntax remain D3+ proposals. L0/L1 does not permit hidden text conversions or accessing device handles. Core registry and ABI layouts are unapproved. This avoids treating broad aspirational type tables as already supported implementation.

## D3+ state/task ownership policy (PROPOSED)

[L2 State](d3-state-derived-binding-contract.md) restricts mutable state to its owning UI scheduler and accepts only owned/immutable copied message values from other domains; derived and binding sources are pure and cannot capture raw device pointers. [L3 Task/Result](d3-task-result-lifecycle.md) defines a single active TaskTicket per TaskSlot, target/domain Send checks and generation-isolated results. Cross-await borrow must satisfy [OwnershipIR](aui-ownership-ir.md) or fail OWN_ASYNC_ESCAPE; cancellation never releases in-flight DMA/OS buffers until proven safe. Logical StateRevision, GraphRevision, TaskTicket, CommandTicket and D6 snapshot/HEAD epoch remain disjoint. No native borrow checker was run.

## D3+ state/task ownership (proposed)

[L2 State](d3-state-derived-binding-contract.md) confines mutation to owning UI scheduler, rejects storage of unproven borrows and uses owned immutable messages from other domains. [L3 Task/Result](d3-task-result-lifecycle.md) distinguishes TaskSlot, TaskTicket and provider CommandTicket, requires Send/Share proof and retains physical buffers after cancellation request until confirmed quiescence. StateRevision, GraphRevision and D6 HEAD epoch remain disjoint. [OwnershipIR](aui-ownership-ir.md) must prove await lifetimes; no checker exists yet.


## Complete AUI compiler typing and ownership admission — L0–L4 and contract modules (PROPOSED)

The [one complete compiler](aui-compiler.md) cannot infer public identity from source spelling, the permissive broad type list in this document or native struct layout. For production, use the **single current [15-type D3 core candidate](d3-core-registry-value-contract.md)**, existing [D2 TypeReference identity](d2-identity-and-type-resolution.md), locked package exports and [ONE Canonical Graph](canonical-project-graph-and-components.md). Every core entry currently remains UNVERIFIED; no type resolution described below promotes it to an approved signed contract.

### Typed name resolution and admission sequence

1. **Source profile and module kind:** first select exact `component` or `contract` source unit and L0–L4 profile from immutable compilation context. Keywords and source names cannot themselves increase profile level or create public contract authority.
2. **Namespace collection:** collect all normalized NFC declaration IDs and import aliases with precise source spans before resolving definitions. Distinguish public types, values/input/state, services/commands, events, task/slot and view template IDs. Unknown or duplicate names in a namespace reject; no fallback to a different package or fuzzy name.
3. **Core/import lookup:** resolve `aui.core` and package exports by exact owner package ID, exact declared public name, arity and identity; reject two owners exposing the same unqualified name unless the source explicitly disambiguates according to the accepted import grammar. Source-only review catalogue results remain marked UNVERIFIED, prohibited from GraphLinkedIR/native codegen.
4. **TypeRef construction:** form a resolved logical nominal `{ownerPackageId,typeId,contractDigest}` or reviewed generic template + ordered nominal arguments + contractDigest. Never synthesize a production digest from an unapproved ruleId, source file path or native layout. Generic arity/constraints, bounded nesting and recursion are checked before any target layout.
5. **Assignability:** exact logical type identity by default. Contextual unsigned `INT` can be admitted only if its literal value fits the explicitly expected U32/U64 type and its profile permits the literal; no integer-to-Bool/String/F64, enum-to-String, Result-to-TaskOutcome, String-to-StableKey or unchecked value-to-handle conversion. `Unit` is not a pointer/null.
6. **Pure-expression typing:** `STR`, `INT`, Bool and immutable member paths are pure. A `pureCall` is pure **only if** its exact locked provider contract explicitly declares no I/O/state mutation/async/native privilege, bounded execution/cost and validated ownership. A source-level `service` declaration alone cannot satisfy that. `using Converter` is not an implicit privilege gateway; both input/output types and exact public pure converter export must be independently verified.
7. **Lifetime/effects:** a value can cross a worker/task boundary only with reviewed `Send`/ownership semantics, and can enter StateSlot only with an approved owned/immutable lifetime. `TaskSlot`, `TaskTicket`, `StateRevision` and native handles are not ordinary portable graph data; `Event<T>` source occurrence/provenance is not an arbitrary transferable payload.
8. **Graph-linked/native:** all public types, record/generic instances, command Result success/error, domain/effects/capabilities, source Graph origin and target/layout service ABI must verify before emission. A successful source-only HIR is **not** a public/export type approval.

### L0–L4 contexts (compiler validation matrix)

| Context | Type admissibility | Static verifier |
| --- | --- | --- |
| L0/L1 visual argument | Full imported logical String/Bool/U32 matching closed constructor signature | No positional/duplicate named args, unknown property, false implicit conversion |
| L1 event | `Event<Unit>` for Button.activated and one handler with matching owner/generation | No Event<T> arbitrary source injection or direct physical command dispatch |
| L1 command | Ordered named parameters, exact `Result<T,E>`, declared domain/effects | All types resolved before graph provider; no result=admission success conflation |
| L2 state/derived | Owned immutable or explicitly owned state-supported logical type; fully verified pure expression | Bounded initialization, no borrow escape, pure DAG/cycle/single writer |
| L2 binding and commit | Exactly one typed source expression for static keyed View property; exact mutable state target | Duplicate writers and stale state generation reject; atomic failure/rollback |
| L3 task | TaskSlot<T,E> matches Task Result<T,E>, TaskOutcome<T,E> checked via five immutable cases | Borrow across await, forged cancellation, duplicate terminal, wrong owner reject |
| L4 keyed list | List<T> where T is verified immutable nominal record and key field public exact StableKey | No float/index/mutable/borrowed key, no duplicate identity; child template scope checked |
| Contract module record | Declared ordered immutable public fields; complete verified field TypeRefs, no by-value cycle | Public type semantics/codec and namespace must be accepted before digest |
| Contract module enum | Ordered closed variants with <=1 payload each **as source candidate only** | Current canonical package schema does not yet support an enum export; **BLOCKED** |
| Contract module service | Interface of ordered typed commands/effects/domain and verified provider binding | No native implementation from interface; source export mapping to canonical component contract **BLOCKED pending D2 approval** |

### Public enum/service closure — one canonical owner, still unverified

The existing [canonical package schema](../../schemas/canonical-component-package.schema.json) has now been **additively extended in its original `types[]`** to discriminate record (`fields`) from closed enum (`variants`) by `oneOf`, without altering the record branch. The [single Canonical Project Graph C10/C12](canonical-project-graph-and-components.md) owns the proposed public enum projection, variant ordering and logical dependency closure. This is **design/schema progress**, not proof that any enum TypeReference, public contract digest or native tag representation is accepted.

A source `enum` is a closed logical sum: at least one variant, unique NFC-normalized names, zero or one fully owned and verified payload TypeReference per variant. Case order is **meaning-bearing**, and a missing `typeRef` is no payload (not `null` or `Unit`). Public enum fields are not record fields, and a native tag is never inferred as a public TypeID. Changes to variant names, order or payload meaning must invalidate the public type contract. Invalid by-value cycles and unverified payload digests reject before linked output. Target-specific tag widths, payload alignment, endianness, move/drop and native calling convention are D4 obligations requiring actual native test vectors.

A source `service` is an interface **mapped to the current component contract**, not a new `types[].kind` or new Graph. A service name resolves to exactly one verified `components[].typeId` within its locked owner package; its named commands match the parent `commands[].id`, input name/ordered types, success/failure Result refs, effects and domain. Every other authored operation field (`sideEffectClass,retryPolicy,requiredCapabilities,declaredTargets`) and parent `ports,capabilities,sources` must come from that exact locked and signed component package; the compiler MUST NOT invent missing values from abbreviated source syntax. A service source with no authenticated native provider remains a **type-checkable interface candidate**, not a runnable service. Source-to-provider mismatch, disallowed target, missing capability, undeclared effect or unapproved native ABI rejects.

The [28 public enum/service review cases](../../examples/aui-compiler-production/public-export-closure-review-cases.json) separate JSON structural admission from semantic changes and fail-closed trusted publication. All cases remain **NOT-RUN**. Exactly verified contract digests, user-enum construction/match semantics, target layout, public type-set golden bytes, and human acceptance are still P0. No new current core types are introduced; the 15-type core candidate remains UNVERIFIED.


## Enum values and nested generic resolution — full compiler, Phase I PROPOSED

**One type universe, not a new type registry.** AUI `record` and `enum` declarations are immutable public type definitions owned by the existing package `types[]`. The source `service` is a verified component interface and is **not** a `types[].kind=service`. Source parsing, semantic typing, portable value admission, target native representation, runtime construction and authorization are **distinct gates**.

### Enum definition, constructor and value invariant

1. **Definition:** an enum type has one immutable package-qualified TypeID and an **ordered, nonempty** list of unique NFC-normalized variant names. Each variant has exactly zero or one *optional* complete TypeReference payload; absent payload is **not** `Unit`, a JSON `null`, a 0-byte String, or a guessed default. Reject overlapping record fields, public type-ID collisions, missing/unsupported owner or unverified transitive payload contract.
2. **Constructor syntax candidate:** `SensorError.NoReading` is a typed zero-payload constructor expression; `SensorError.BadReading(value: reading)` is a typed one-payload constructor. The second form has **exactly one named argument `value`**; its complete TypeReference must match the variant's declared payload type, with no implicit `U32`/`F64` conversion or other overload. Zero-payload cases reject `(...)`; payload cases reject omitted `(value: ...)`. Constructor resolution chooses a unique imported *type* symbol before looking up its variant, not an ordinary member on a runtime variable; no identifier starting with a type can silently turn into a call to a service provider.
3. **Logical runtime value:** `EnumValue = (resolvedVerifiedEnumTypeRef, variantName, optional TypedValue)`, where `variantName` resolves to exactly one entry in the approved declaration sequence and `TypedValue` is an immutable owned value conforming to the variant's **exact** payload TypeReference. The absence/presence bit is semantic. A payload must never be interpreted as a native untagged pointer, a source-authored arbitrary JSON object or an unverified void blob. Type/variant/payload mismatch rejects before constructing any runtime value.
4. **Portable encoding boundary (proposal):** typed D6 serialization, *if that exact enum type and payload codec are admitted*, uses a fully verified public enum TypeReference, the **canonical authored variant name**, and an optional `payload` serialized by the **already-approved codec of the verified payload type**. No numeric enum tag/ordinal, physical ABI padding, source path, pointer, signer claim or guessed nested value is part of a portable logical carrier. Missing payload key is different from present `null`. The general record/nested generic `TypedValue` carrier is still P0; a syntactically plausible JSON value is not automatically a valid D2 graph payload.
5. **Native D4 lowering:** target-specific `EnumLayout` is a separate verified layout descriptor with concrete tag representation, variant payload offset/alignment, lifetime/destructor, move/copy/Send rules, caller/callee ABI, stack or indirect passing and error/cleanup behavior. The first shipping Win64 ABI must explicitly map logical variants to native tag numbers in **declaration order** and verify that actual machine code tests all branches. Internal tag numbers are never themselves portable public values; a public variant reorder changes logical contract even when two native binary layouts look equal.
6. **Exhaustive match syntax candidate:** `matchEnum(value: expr) { case SensorError.NoReading => fallback; case SensorError.BadReading(reading) => reading; }` is an **L2+ pure expression**. The scrutinee must have one verified enum TypeReference. Every case must name that exact enum and an existing unique variant, with exactly one binder only for payload variants. Every declared variant appears **exactly once** (no wildcard in this first candidate), and all arm expressions must have the **same exact result TypeReference**. Binders are immutable and scoped only to their arm; arms cannot dispatch, mutate StateSlot, allocate opaque TaskTickets, or gain an OS capability. Evaluate the scrutinee once; select exactly one arm, moving/borrowing the value only as allowed by ownership verification. An enum match is not the distinct five-way L3 `TaskOutcome` settled-handler match.
7. **Source identity:** `EnumName.Variant` and `EnumName.Variant(value: ...)` are resolved from the **qualified enum type symbol** plus named variant, so the parser may represent them as an identifier/member path or named-call syntax before semantic resolution. A conflicting value namespace with an identical spelling is a deterministic ambiguity error rather than a heuristic constructor guess.

### Nested TypeReference, generic instantiations and quotas

The current [TypeReference schema](../../schemas/aui-type-reference.schema.json) now allows a nested `generic` as an `arguments[]` element while preserving the same `nominal` and `generic` variants. **This does not add new core types.** All 15 existing proposed public core definitions are still UNVERIFIED.

| Constraint | Candidate required behavior |
| --- | --- |
| Type syntax | `List<Result<Measurement, SensorError>>` parses as a tree; each node is a nominal or generic TypeReference, never an untyped string |
| Exact arity | `List<T>` and `Event<T>` have one argument; `Result<T,E>`, `TaskOutcome<T,E>`, `TaskSlot<T,E>` have two where admitted; `TaskTicket` has no user-instantiable args |
| Nesting | At most **eight generic applications** on a single root→leaf path and **128 total nodes** in the resolved TypeReference tree; reject before allocation/recursion overflow |
| Cycle guard | No cycle in the public *type-contract dependency* graph for this candidate; a recursive linked List<T>/record/enum is **unsupported** until a separate approved indirection + ownership contract |
| Identity | Compute instances **inside-out** from verified template identity/meaning and complete ordered child TypeReferences; a nested instance is not identified only by pretty text or a compiler-generated display name |
| Ownership | Check template-specific `Copy/Move/Drop/Send`, element quota, finite container limits, error/result variants and graph-payload eligibility **recursively**; outer `List` does not make an inner `TaskSlot` portable |
| Trust | Unverified template/argument digest or unreviewed rule content rejects `GraphLinkedIR`, regardless of a `^[0-9a-f]{64}$` matching string |
| Namespace | Source qualified symbols are NFC-resolved; public authored TypeIDs follow D2 package identity rules, not local source alias spelling; aliases never enter public semantic digest |
| Build/runtime | Exact D4 instantiation layout, ABI/error/cleanup and target qualification required for native lowering even after language type check |

The canonical generic instance digest/graph export ID **still requires a frozen D2/C10 full structural projection and independently calculated golden vectors**; schema recursion alone is insufficient. On a specialization collision, source ambiguity or unresolved type owner, fail closed rather than reusing another package's nominal digest.

### Exact rejection diagnostics as compiler design candidates

`AUI_ENUM_UNKNOWN_VARIANT`, `AUI_ENUM_PAYLOAD_MISSING`, `AUI_ENUM_PAYLOAD_UNEXPECTED`, `AUI_ENUM_NOT_EXHAUSTIVE`, `AUI_ENUM_ARM_DUPLICATE`, `AUI_ENUM_BINDER_SCOPE`, `AUI_ENUM_ARM_TYPE_MISMATCH`, `AUI_TYPE_ARITY`, `AUI_TYPE_NESTING_LIMIT`, `AUI_TYPE_DEPENDENCY_CYCLE`, `AUI_TYPE_NOT_PORTABLE`, `AUI_UNVERIFIED_PUBLIC_CONTRACT` are candidate stable codes. Exact diagnostic stage precedence, source-byte spans and output JSON golden vectors require D3 compiler sign-off.

[Enum/nested generic review scenarios](../../examples/aui-compiler-production/enum-generic-value-cases.json) will validate these designs **when an actual compiler exists**. No tests have executed and no public enum value codec, CoreRegistry fingerprint, TypeReference hash or Win64 module ABI is approved in this pass.
