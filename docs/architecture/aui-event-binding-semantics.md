# AUI Event, Command and Binding Semantics

**Status: proposed D3+ language candidate; no parser or runtime exists.** This file describes extended event/binding possibilities and its earlier examples; [D3 First Language Profile](d3-first-language-profile.md) owns exact **L0/L1 source grammar**, and [D3 Event Delivery and Command Linkage](d3-event-delivery-and-command-linkage.md) owns bounded first-profile admission, per-view FIFO, exact handler cardinality and non-reentrancy. The extended syntax here remains open; this is not a contradictory current L1 grammar.

## Declaration and view attachment grammar

The following EBNF additions are proposed. `qualifiedName`, `type`, `pureExpr`, `arguments`, `memberPath` and `identifier` follow the existing syntax draft; exact expression precedence is still open.

```ebnf
eventDecl      = "event", identifier, ":", "Event", "<", type, ">", ";" ;
commandDecl    = "command", identifier, "(", [ namedTypes ], ")", "->", type,
                 [ "effects", "(", names, ")" ], [ "on", identifier ], ";" ;
handlerDecl    = "on", identifier, "(", identifier, ")", "{", { effectStmt }, "}" ;
eventModifier  = ".", "on", "(", identifier, ":", identifier, ")" ;
bindingDecl    = "bind", memberPath, "<-", pureExpr, [ "using", qualifiedName ], ";" ;
effectStmt     = "send", identifier, "(", [ arguments ], ")", ";"
               | "return", pureExpr, ";" ;
viewExpr       = qualifiedName, "(", [ arguments ], ")",
                 [ "{", { viewExpr }, "}" ],
                 { eventModifier | ".", identifier, "(", [ arguments ], ")" } ;
```

**Design distinction:** `Button(...).on(activated: inspect)` *connects* the named component event output to the current declaration's event `inspect`; `on inspect(payload) { send Inspect(); }` handles that event and sends an operation request. There is no implicit event dispatch or direct device access. An event modifier is only legal for an event output on the target component and a compatible local declared Event payload type; normal visual modifiers are separate.

`send Inspect()` means dispatch a typed command by declaration ID; the command's declared implementation provider is resolved through the Project Graph/linked component contract, not through a hidden naming convention. A missing implementation is a link/contract error, not implicit stub generation.

## Legal design fixture

```aui
component SensorSummary(input reading: String) {
  event inspect: Event<Unit>;
  command Inspect() -> Result<Unit, InspectError> effects(state-write) on ui;
  on inspect(payload) {
    send Inspect();
  }

  VStack(spacing: 12) {
    Text(value: reading).accessibilityLabel("Sensor reading")
    Button(title: "Inspect")
      .on(activated: inspect)
      .accessibilityLabel("Inspect sensor")
  }
}
```

*Status:* grammatically illustrative under the **combined candidate subset** above. It requires imports/definitions for `String`, `Unit`, `Result`, `InspectError`, `VStack`, `Text` and `Button` and a Project Graph-provided implementation of `Inspect`; it is **not a standalone compiled or executed program**.

## Bindings and two-way input

`bind destination <- source [using Converter];` is one-way. A destination must be an owned, bindable observable property in the component scope (not an arbitrary external read-only port); `source` and converter are pure and exact-type safe. Static dependency cycles fail. A control that edits data emits `editRequested: Event<T>`; its handler sends an authorized command that commits state, after which the one-way binding refreshes the view. No implicit two-way write to `state`.

This contract deliberately leaves the exact AUI source syntax for binding a nested child property unresolved: local child identity/addressability must be specified before such examples can be called legal. Simple `Text(value: reading)` is a pure property evaluation, not a writable binding declaration.

## Event routing and delivery

Event payload is immutable, with stable type identity. Event occurrence is not itself an effect permission. An event handler cannot block the UI scheduler, invoke raw OS/device instructions, or bypass required command capability checks. For **L1 only**, event admission/order/non-reentrancy are now an explicit **proposal** in [D3 Event Delivery](d3-event-delivery-and-command-linkage.md): bounded per-view FIFO, single handler, explicit overflow and stale-generation diagnostics. D3+ multi-handler fanout, async completion, writable bindings, general ordering and cross-target runtime proof remain open.

## Diagnostic examples

| Invalid scenario | Required diagnostic |
| --- | --- |
| `Button(...).on(unknown: inspect)` | AUI_EVENT_UNRESOLVED |
| `Button(...).on(activated: missing)` | AUI_UNRESOLVED |
| Connect Event<Bool> into Event<Unit> | AUI_EVENT_TYPE |
| `on inspect(payload) { send Missing(); }` | AUI_UNRESOLVED |
| Command `Inspect` has no linked implementation | AUI_COMMAND_UNLINKED |
| `derived` directly invokes command | AUI_ILLEGAL_EFFECT |
| Binding destination is read-only | AUI_BIND_READONLY |
| Two writers without policy | AUI_BIND_WRITER_CONFLICT |
| Immediate dependency loop | AUI_BIND_CYCLE |
| Event calls privileged command without capability | AUI_TARGET_UNSUPPORTED or CAPABILITY_DENIED |

All examples are expected diagnostic outcomes for future golden fixtures; none are observed compiler results.

## Open before accepting D3

Parser precedence and full expression grammar, generic constraints, event ordering/reentrancy, explicit command linkage format, dynamic collection identity, child property addressing, error/Result propagation, cancellation, modifier argument rules and source-level ownership syntax. Do not claim that D3 is closed.

**First-slice modifier syntax:** L0/L1 uses accessibilityLabel(value: String) with a named argument, not the positional accessibilityLabel("...") illustrated above. AUI source command implementations are bound via [derived command-link schema](../../schemas/aui-command-link.schema.json); the [positive L1 fixture](../../examples/aui-language/linked-consumer-panel.aui) is not a linked executable ABI. No compiler or UI runtime exists.

## D3+ one-way binding and asynchronous result owner (PROPOSED)

The first precise extended candidate is [L2 State/Derived/Binding](d3-state-derived-binding-contract.md). It requires a statically keyed owned view target, one binding writer and a pure source; an edit event can trigger a separate **atomic UI StateRevision transaction** but never an implicit two-way write. [L3 Task/Result](d3-task-result-lifecycle.md) adds a bounded TaskSlot, request/await, and an exhaustive Successful/Failed/AdmissionRejected/Cancelled/ProviderUnavailable match; a cancel-request alone does NOT mean Cancelled and a stale generation never updates a replacement view. The earlier bindingDecl/memberPath and simple return/await examples remain **broad illustrative D3+ syntax**, not conflicting first-slice authority. Neither document asserts compiler/runtime execution.
