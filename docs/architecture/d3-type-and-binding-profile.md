# D3 — First-Slice Types, Core Registry, Properties and Effect Boundaries

**Status: PROPOSED design candidate. No AUI compiler, renderer, native execution, or accepted core registry exists.** This document owns L0/L1 typing and callable/property declarations. [D3 Grammar](d3-first-language-profile.md) owns source syntax. [Event Delivery](d3-event-delivery-and-command-linkage.md) owns event routing. [AUI Types and Ownership](aui-types-and-ownership.md) owns the broad future language. [D2 Export Contract Identity](d2-export-contract-identity.md) and [D6 Resolver](d6-offline-dependency-resolution.md) own external nominal export resolution.

## T1. Explicit design-time core registry

Candidate profile ID: aui.core/0.1-draft. It is a **compiler-provided, version-pinned logical registry**, not an automatically installed executable library or mutable hidden import. A source must explicitly declare import aui.core; the actual compiler/core executable digests and target ABI version are D4 obligations. Source names Unit, String, Bool, U32, Event<T> and Result<T,E> are reserved core logical exports under that import; user package exports cannot impersonate them.

L0/L1 admitted values:

| Type | Meaning | L0/L1 producer |
| --- | --- | --- |
| Unit | Single empty value, zero-field event payload; not null pointer | Event<Unit> raised by button |
| Bool | true/false | Literal/input |
| U32 | Unsigned integer in [0,4294967295] | Context-typed decimal literal/input |
| String | Valid UTF-8 Unicode scalar string; separate byte and grapheme counts | Literal/input |
| Event<T> | Immutable typed occurrence with owner and generation | Event declaration/attachment only |
| Result<T,E> | Either Success T or Failure E; no exception/implicit conversion | Command declaration return envelope |

User nominal types imported from a verified package use exact LogicalExportIdentity: packageId/exported TypeID + exportedContractDigest. A source nickname Tick may resolve to example.locked/Tick only through one unique verified import; no guess based on capitalization. Initial import syntax uses dotted package names; import mapping to slash-form public TypeID is a declared resolver table, not syntax rewriting.

For L0/L1, only Result<T,E> in a command signature and Event<T> in an event declaration are legal generic applications. No generic values, generic user components, arrays, pointers, slices, numeric floating literals or arithmetic. L0/L1 does not construct arbitrary user record values; externally provided input values may carry nominal record types and be forwarded unchanged in command dispatch.

The core registry pin format and contract digests are **still P0**. Do not treat these names as verified native layouts or assign unreviewed ABI offsets.

## T2. Candidate visual export signatures

First-slice visual property APIs:

| Core constructor or modifier | Required named args | Children | Output |
| --- | --- | --- | --- |
| VStack | spacing: U32 | 1..N child Views | View |
| HStack | spacing: U32 | 1..N child Views | View |
| Text | value: String | none | View |
| Button | title: String | none | View |
| accessibilityLabel | value: String | not applicable | View |
| Button.on | activated: Event<Unit> local ID | not applicable | View |

These are minimal syntax/type contracts, **not** final rendering or accessibility semantics. U32 spacing has *logical abstract layout unit*, not millimeters/pixels; pixel density and Length units remain D5 decisions. This profile intentionally avoids unit-bearing hardware values; a future Length type must not silently reinterpret U32.

A Button emits an activated Event<Unit> only when the target input system and enabled-state logic permit activation; the exact event ordering is in [D3 Event Delivery](d3-event-delivery-and-command-linkage.md). An accessibilityLabel is mandatory on interactive Button in this **candidate** first slice; missing label -> AUI_ACCESSIBILITY_LABEL. Text can use its rendered value for accessible text, but a developer may supply a more descriptive label.

## T3. Type checking and pure expression restrictions

- Every input, event and command parameter/result/error has an explicit nominal type; no implicit inference of a public contract.
- Property and command call arguments are **named-only** and each required parameter appears once; unknown/duplicated/missing labels -> AUI_ARG_NAME, AUI_ARG_DUPLICATE, AUI_ARG_MISSING respectively.
- An integer literal is context-typed against U32 only in this slice; values larger than 4294967295 -> AUI_NUMBER_RANGE. Source numeric tokens beyond 2^53-1 reject at lexer/profile stage. A U32 value never implicitly becomes String.
- Pure atom is a typed literal or immutable input/member read. Named local component input lookup wins in local scope; ambiguous imports -> AUI_AMBIGUOUS_IMPORT. Member access is allowed only on a resolved accessible immutable record field; unknown field -> AUI_UNRESOLVED_MEMBER. L0/L1 cannot call a converter or mutate state from a pure atom.
- Record field member reads are pure but must observe the input's existing owned immutable lifetime. Copy of a source input into command ticket is specified by exact provider binding and D2 transfer policy; no implicit cross-domain borrowed pointer.
- Event<T> payload equality is exact **resolved nominal type** (not display string equality). Button Event<Unit> cannot attach to Event<Bool>.
- Result<T,E> is never silently unwrapped by send. Its completion is delivered to its owner as a typed signal according to D2/D5; UI handler does not synchronously block waiting for it.
- A value whose type or lifetime is unsupported fails static validation before TypedHIR; no dynamic "try and see" renderer cast.

## T4. Effects and permissions

A command declaration includes an explicit effects list (or empty list) and one domain. The local AUI declaration must be a **subset of the approved graph-bound exported command effect/capability contract, and in first profile must match the exact approved declared effects to avoid under-declaration**; unknown or mismatched set -> AUI_COMMAND_CONTRACT. Domain equality is exact; ui and io-worker are candidate domain atoms. A command request is not an execution grant: actual runtime capability proof is checked immediately before dispatch. UI event handler itself has no declared raw I/O effect.

There are no direct OS/network/hardware/file operations in L0/L1. Source text saying effects(device-write) does not authorize physical device operations. No producer may treat a successful type check as a security acceptance gate.

## T5. One-way bindings deferred, not forgotten

The broad AUI language proposes bind destination <- source using converter, state and derived. L0/L1 uses only **pure read-to-property evaluation**, e.g. Text(value: title). It is NOT an observable two-way binding or mutation. A later accepted D3 profile must define source-level stable child addressing, single-writer state ownership, change/coalescing/revision propagation, pure converter lookup, type/unit validation and cycle detection before accepting a writable or dynamic binding.

## T6. Ownership and target handoff

In first profile, a view describes immutable values. A command dispatch may retain/copy/move an input according to D2's provider contract. Cross-domain transfer of a borrowed handle is forbidden; for nominal records containing owned resources, Send/Copy capability must be proven in D4 OwnershipIR and exact ABI target, not guessed from record field syntax. View graph identity is distinct from runtime instance identity. Stale completion after view replacement cannot mutate replacement state.

A string is a logical UTF-8 scalar sequence; target-native representation, allocation size, SSO, alignment and ownership are D4 and D5 questions. U32 is logically 32-bit, but register/stack ABI representation remains target dependent.

## T7. Future golden fixtures (all NOT-RUN)

- L0-01: import aui.core, VStack/Text/Button with accessible label -> parse/type candidate.
- L0-02: Text(value: 17) -> AUI_TYPE_MISMATCH, not hidden stringify.
- L0-03: VStack(spacing: 4294967296) -> AUI_NUMBER_RANGE.
- L0-04: Button without accessible label -> AUI_ACCESSIBILITY_LABEL.
- L0-05: duplicate named property or unknown modifier -> AUI_ARG_DUPLICATE / AUI_MODIFIER_UNKNOWN.
- L1-01: Button.activated Event<Unit> wired to Event<Unit> -> exact type success.
- L1-02: Event<Bool> wired to Button.activated -> AUI_EVENT_TYPE.
- L1-03: command provider export digest/domain mismatch -> AUI_COMMAND_CONTRACT.
- L1-04: cross-domain source borrow -> OWN_NOT_SEND / OWN_ASYNC_ESCAPE after type stage.
- L1-05: unknown target or unsupported component -> AUI_TARGET_UNSUPPORTED.
- L1-06: command declared but link-map missing -> AUI_COMMAND_UNLINKED, never automatic stub.
- L1-07: source-only code formatting edit -> new source hash/index, same logical graph export contract if unchanged.

**Open P0:** explicit accepted builtin/core registry identity, actual visual property contract, effect/domain registry, type import namespacing, accessible labels across targets, D3+ bindings, ownership and error propagation. This document is design-stage only.

## Proposed L2/L3 core type extensions

[L2 State](d3-state-derived-binding-contract.md) adds StateRevision and static keyed-view binding contracts without changing L0/L1 Text(value: String) constructor requirements. [L3 Task/Result](d3-task-result-lifecycle.md) proposes TaskSlot, TaskTicket and a closed TaskOutcome<T,E> with Successful, Failed, AdmissionRejected, confirmed Cancelled and ProviderUnavailable. These are logical typed surfaces, **not** existing pinned aui.core/0.1-draft exports or proved native layouts. No implicit result-to-String conversion, general generics or device capability follows from naming them. Core registry digest, ownership and target ABI remain unaccepted P0.
