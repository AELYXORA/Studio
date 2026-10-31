# D3 — First-Slice Language Review and Remaining Decision Register

**Status: OPEN / PROPOSED. No architect sign-off, no compiler, no native runtime tests.** This is a finite review register for the first AUI slice. It does not replace the normative candidate owners: [Source Grammar L0/L1](d3-first-language-profile.md), [Type/Core Profile](d3-type-and-binding-profile.md), [Event/Command Linkage](d3-event-delivery-and-command-linkage.md) or the broader [AUI Syntax](aui-syntax.md).

## R1. Agreed directional invariants versus unapproved design choices

Directional invariant already present in the project: architecture-first; one canonical Project Graph; AUI is a declarative projection, not a parallel system architecture; human reviews graph/source effects; primarily target-native Assembly, no Qt/QML/C++/Python substitution. D3 grammar and core APIs are **proposals**, not user-approved implementation decisions.

L0/L1 is chosen as a small **candidate** for the first vertical slice:
- L0: statically composed pure Text/VStack/HStack/Button views over immutable typed inputs.
- L1: exactly one typed handler per local Event, bounded non-reentrant FIFO delivery and one command send, with explicit graph/provider link.
- D3+ remains open for mutable State, Derived, Bind, Task, await, dynamic keyed children, layouts with units, full generic/type/ownership syntax, Result completion in UI, internationalization, accessibility implementations and hardware controls.

Only an accepted scope decision can make L0/L1 the shipping baseline. Do not label broad unimplemented D3+ features deprecated or impossible; they are deferred.

## R2. Specific contradictions reconciled at documentation level

| ID | Earlier ambiguity | Current first-slice proposal | Remaining validation |
| --- | --- | --- | --- |
| D3-R01 | Multiple illustrative source grammars and positional modifier calls | [L0/L1](d3-first-language-profile.md) requires named-only arguments, while broad [Syntax](aui-syntax.md) stays D3+ proposal | Architect accepts grammar scope |
| D3-R02 | Source declarations could imply executable command providers | Explicit approved [Command Link Map](../../schemas/aui-command-link.schema.json); syntax/type success != GRAPH_LINKED or ABI_LINKED | Link-map approval/revision procedure and D4 proof |
| D3-R03 | Missing event queue ordering, handler cardinality and overflow | [Event Contract](d3-event-delivery-and-command-linkage.md) proposes per-ViewIdentity FIFO, capacity 64, one handler, no recursive invocation | D5 resource budget and platform fairness |
| D3-R04 | Unscoped general types/generics/units in restricted prototype | [Core Profile](d3-type-and-binding-profile.md) allows Unit/Bool/U32/String, Event<T>, Result<T,E> and imported immutable records | Exact core type digests and future type system |
| D3-R05 | GUI demo's source symbol might be confused with GraphNodeID | [Linked L1 Fixture](../../examples/aui-language/linked-consumer-panel.aui) binds a source command separately to example.locked/consumer through proposed link map | Source must enter a future approved immutable snapshot |
| D3-R06 | Event arrival could be treated as permission/physical execution | UI Event admission, command request, D2 ticket admission and live capability check are separate stages | D5 physical runtime tests and security threat model |
| D3-R07 | Existing sensor-summary.aui called positive though unresolved imports and legacy shorthand remain | Keep it explicitly *legacy illustrative*, add [L0](../../examples/aui-language/status-panel-l0.aui), [L1](../../examples/aui-language/linked-consumer-panel.aui) grammar candidates | Native parser/semantic checker not built |
| D3-R08 | Static accessibility was only descriptive | L0/L1 proposes an explicit Button accessibilityLabel(value: String) static requirement | D5 real keyboard, focus and screen-reader behavior |

These are **documentation corrections**, not accepted design gates or observed compiler behavior.

## R3. P0 decision inventory

| Decision ID | Needed decision | Candidate | Status |
| --- | --- | --- | --- |
| D3-P01 | Pin core registry and source import policy | aui.core/0.1-draft explicit import, package lock for user exports | PROPOSED |
| D3-P02 | Freeze Unicode normalization and reserved keyword version | UTF-8, XID/NFC identifiers, exact byte spans | PROPOSED |
| D3-P03 | First language feature scope and extension evolution | L0 pure views, L1 typed single-send intents, D3+ additive versioned profile | PROPOSED |
| D3-P04 | Fully reviewed visual constructor/property/slot contracts | Four core visual constructors; named-only modifier signatures | PROPOSED |
| D3-P05 | Stable static/dynamic view identity and component lifecycle | Static scoped instance identity; dynamic lists deferred until full key syntax | OPEN |
| D3-P06 | Bounded event queue capacity, fairness, stale view generations | Per-view FIFO 64, overflow diagnostics; no global order | PROPOSED |
| D3-P07 | Typed command link authority, snapshot persistence and approval | Derived link map, exact type/effect/target/export digests | PROPOSED |
| D3-P08 | Result/error reporting from command to view | L1 request-only, completion observer deferred with explicit design | OPEN |
| D3-P09 | Full State/Derived/Bind source semantics and cycle/ownership policy | Read-only pure view in L0/L1; D3+ grammar still required | OPEN |
| D3-P10 | Task/await, error propagation, Send/Share, cancellation and UI state commit | D3+ contract linked to D2/D4/D5, no silent L1 support | OPEN |
| D3-P11 | Accessibility, Unicode text, localization, RTL, IME and actual presentation | Static accessibility requirements now; native D5 proof later | OPEN |
| D3-P12 | Dynamic collections, stable keys and child addressing | Explicit key declarations in later version, no positional persistence | OPEN |
| D3-P13 | First-host native compiler/renderer/library ABI | Separate D4/D5 platform design, currently no executable source provider | OPEN |
| D3-P14 | Full byte-accurate golden fixtures and diagnostic stage precedence | Two positive fixtures + 28 independent negative mutations | PROPOSED |
| D3-P15 | Hard resource budgets and adversarial parser input limits | Bound tokens, nesting, string bytes, imports and events per target | OPEN |

## R4. Readiness levels of current examples

- [status-panel-l0.aui](../../examples/aui-language/status-panel-l0.aui): L0 parse/type **expected positive** assuming the proposed aui.core registry, NOT-RUN by compiler.
- [linked-consumer-panel.aui](../../examples/aui-language/linked-consumer-panel.aui): L1 parse/type **expected positive**, explicit [link-map proposal](../../examples/aui-language/linked-consumer-panel.link.json) refers to the verified reference package's graph/export digests. It is **NOT a committed part** of that reference immutable project snapshot and is not ready for runtime/ABI linkage.
- [sensor-summary.aui](../../examples/aui-language/sensor-summary.aui): legacy broader illustrative syntax; unresolved symbols and positional accessibility modifiers; not a legal L0/L1 golden fixture until migrated.
- [28 negative L0/L1 cases](../../examples/aui-language/d3-first-profile-negative-cases.json): expected diagnostic categories and stage only. Source byte spans, static compiler commands and observed results remain NOT-RUN.

## R5. Future acceptance and stop conditions

For Phase I D3 acceptance, require explicit reviewed scope selection, unambiguous imports and core profile, legal/error fixtures with byte spans, type/result/effect/ownership rules, full graph-to-AUI round-trip examples, named/typed event and command linkage, UI accessibility representation, and D3+ plan for every excluded capability necessary to build a professional RAD product. No design gate closes by committing more text alone.

Phase II builds the accepted compiler/parser/runtime in authorized order; Phase III runs the fixtures on actual target/host and captures toolchain/semantic digest/diagnostics; Phase IV corrects and re-verifies. A syntactically accepted document is not a source build; a source build is not a validated renderer; and a renderer is not proof of physical hardware effect safety.

**Recommended next documentation pass:** fully specify D3+ state/derived/bind and Result UI completion without scope creep, plus a versioned core export catalog and exact source-to-Graph reconciliation protocol. Continue D1–D8 design-first until the architect explicitly signs off.

## D3 boundary for typed hardware requests — proposed

[D2 Hardware Resource Contract](d2-hardware-resource-contract.md) and [D2↔D3 Hardware Command Boundary](d2-d3-hardware-command-boundary.md) forbid L0/L1 AUI source from issuing direct MMIO/IRQ/DMA or bypassing GraphNodeID/resource-access/OperationID linking. One verified source-to-graph command link, authorized component provider, target adapter and live resource capability are required. AUI send is an intent, not a physical operation. This resolves **textual authority ambiguity**, not D3 P0 for State/Derived/Bind/Task/await/Result UI updates, D4 ABI, or D5 hardware proof.

## R6. D3+ formal documentation candidate — NOT accepted

[L2 State/Derived/Bind](d3-state-derived-binding-contract.md), [L3 Task/await/Result](d3-task-result-lifecycle.md) and [D3 source/graph immutable snapshot reconciliation](d3-source-snapshot-reconciliation.md) now give concrete **proposed** definitions for D3-P08/P09/P10/P05/P07; earlier broad syntax is explicitly illustrative when conflicting. [L2 fixture](../../examples/aui-language/feedback-panel-l2.aui), [L3 fixture](../../examples/aui-language/review-panel-l3.aui) and [24 source/review plus 7 runtime design scenarios](../../examples/aui-language/d3plus-negative-cases.json) are NOT-RUN by AELYXORA. A new draft [source-link bundle schema](../../schemas/aui-source-link-bundle.schema.json) does not provide signed approval or native ABI linkage. The P0 statuses remain OPEN pending full core type registry, dynamic view identity, D5 queue proof, native TaskOutcome layout, runtime cancellation/cleanup, source approval and architect sign-off.
