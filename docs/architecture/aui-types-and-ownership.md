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

### Public enum/service gap — one canonical owner, no fallback

The current [canonical package schema](../../schemas/canonical-component-package.schema.json) permits `types[].kind` with **`const: "record"`** and contains `components[].commands`; it does **not** define a standalone public `enum` type kind or an independently exported `service` type/interface mapping. The [AUI contract-module grammar candidate](aui-syntax.md) can describe those source forms, but a compiler **MUST reject trusted export, Graph link and native build** until the existing canonical **package/TypeReference/operation owner** specifies the meaning-preserving mapping and immutable public semantic projection for enum variants and service interfaces. Do not create a parallel service graph, a second TypeID domain or a hidden compiler-only hash. An unapproved record-only schema must not be extended locally by simply ignoring `enum` fields.

**Unresolved before production compiler acceptance:** exact approved enum public codec/tag identity and native ABI; service interface-to-component/operation mapping and capability registry; type parameter nesting/cycles; pinned `pureCall` signatures and bounded resource proof; nominal record field type/ownership completeness; and independently calculated golden digests. The 15 core registry remains unverified, and no native type checker is operational.
