# AUI.Core — Standard Library Contract — Draft

**Status: proposed, no implementation.** This document specifies the minimal coherent standard library, not every palette widget. It is subordinate to [Component Framework](component-framework.md), [AUI Language](aui-language.md), [Types and Ownership](aui-types-and-ownership.md) and [Runtime](aui-runtime.md). Examples are semantic pseudocode, **not** valid under the current restricted EBNF.

## Common component contract

Every definition declares canonical type ID `aui.core/<Name>`, semantic version, category, target support, typed inputs, outputs, events, commands, child slots, execution domain, effects, lifetime, accessibility semantics and error codes. Stable IDs come from Project Graph, not displayed labels. A type may be compile-time-only and require no runtime allocation.

## Visual baseline

| Type | Required inputs / properties | Events and slots | Execution |
| --- | --- | --- | --- |
| VStack | spacing: Length >= 0, alignment: CrossAlignment, padding: Insets | children: View[0..N] | pure layout |
| HStack | spacing, alignment, padding | children: View[0..N] | pure layout |
| Text | value: String, style: TextStyle, maxLines: Optional<U32> | no children; semantic text value | layout + text renderer |
| Button | title: String, enabled: Bool=true, accessibilityLabel: String | activated: Event<Unit>; no children in the current draft | input -> typed command |
| Toggle | value: Bool, enabled: Bool=true, label: String | editRequested: Event<Bool>; no children | intent, then authorized state update |
| TextField | value: String, placeholder: String, enabled: Bool=true | editRequested: Event<String>, commitRequested: Event<String> | IME/text capability gated |
| ArchitectureNode | nodeId: GraphNodeID, selected: Bool, status: DiagnosticStatus | selected: Event<GraphNodeID> | Studio-only map adapter |
| TypedPort | nodeId, portId, direction, portType | connectRequested: Event<PortRef> | Studio-only map adapter |

`Length` must carry units; exact units and text shaping/focus behavior are open design decisions. An accessible interactive control requires semantic label, role, keyboard/pointer action and a disabled-state contract. `Button` event does not itself authorize hardware effects.

## Nonvisual baseline

| Type | Contract | Execution / error |
| --- | --- | --- |
| State<T> | owner, initial: T, revision, read(); update(Command<T>) | single-writer or explicitly synchronized transaction |
| Derived<T> | compute: Pure(Inputs)->T; dependency IDs | pure DAG evaluation; cycle error |
| Binding<S,D> | source, destination, exact type or explicit pure conversion, policy | one-way update, coherent revision; no implicit side effects |
| Event<T> | immutable payload T, origin, sequence domain, generation | no runtime object required for static emission |
| Command<I,O,E> | input I, result Result<O,E>, required effects, affinity | validated execution and typed terminal outcome |
| Task<T> | schedule(domain), requestCancel(), result: Result<T,TaskError> | one terminal outcome; cancellation not physical abort |
| Channel<T,N> | capacity N>0, overflow policy, send/receive | bounded FIFO within channel; Send required across domains |
| Timer | interval: Duration>0, clock kind, policy | emitted tick; platform clock availability |
| Log | level, category, value, provenance | effectful; bounded ingestion policy |

Typed command handlers and stream events require explicit affinity. Static `Derived` and `Binding` may be compiled away. Dynamic channel capacity is an explicit opt-in variant, not an unbounded default.

## Semantic walkthrough

```text
Sensor Driver -> Channel<Measurement,32>(drop-oldest)
 -> Task<Measurement>(io-worker)
 -> State<Measurement> (UI revision transaction)
 -> Binding<State<Measurement>, Text.value>(one-way, explicit formatter)
 -> Text(value: ...)
Button.activated -> Command<InspectRequest,InspectResult,InspectError>
```

The formatter is a pure typed conversion; the UI cannot access sensor MMIO directly. Late task completion is ignored for a replaced view generation while its resource owner still handles cleanup.

## Lifecycle and cost requirements

Visual definitions are static descriptions, not necessarily heap widget objects. Runtime state allocation is tied to stable instance identity. `Task`, `Channel`, `Timer` and OS-backed input consume resources explicitly. Cost reports record allocations, dynamic dispatch, queue operations, memory, binary size and latency compared with hand-written Assembly under equivalent behavior.

## Required verification scenarios

1. Static VStack/Text produces no effectful commands.
2. Button activation emits one typed event per accepted gesture; disabled button does not activate.
3. Toggle edit intent cannot silently write unauthorized state.
4. TextField respects target IME availability and preserves accessible focus.
5. Derived cycle without explicit delay is rejected.
6. Two writers to a single-writer State are rejected.
7. Channel capacity is never exceeded; overflow policy is measurable.
8. Task cancellation/completion race produces exactly one terminal result.
9. Worker-to-UI transfer rejects non-Send payload types.
10. Map port connection validates graph contracts and target capabilities before publication.
11. Unsupported text renderer or hardware feature reports unsupported, not passed.
12. Pure static chains permit direct native lowering without required heap registry.

## Open before acceptance

Exact Length/TextStyle types, command-handler AUI syntax, generic constraint grammar, event gesture normalization, Timer monotonic clock details, accessibility adapter API, widget-specific implementation status and canonical binary descriptors. This is a **design contract**, not a feature list marked as available.
