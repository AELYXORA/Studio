# AUI Event, Command and Binding Semantics

**Status: proposed D3 language candidate; no parser or runtime exists.** This is the precise *design candidate* for event wiring and state update rules. [AUI Syntax](aui-syntax.md) remains the language syntax authority; this file defines its event/binding subset. No claim of a completed or frozen overall grammar.

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

Event payload is immutable, with stable type identity. Event occurrence is not itself an effect permission. An event handler cannot block the UI scheduler, invoke raw OS/device instructions, or bypass required command capability checks. Multiple handlers, ordering, queue/backpressure, reentrancy and cancellation policy remain open and must be explicitly decided for D3 acceptance.

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
