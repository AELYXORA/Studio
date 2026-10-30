# AUI Syntax and Semantics — Design Candidate

**Status: proposed language draft, not implemented or frozen.** This document refines [AUI Language](aui-language.md). The existing restricted EBNF is a smaller subset; examples here supersede its syntax illustrations **for design review**, not for an existing parser.

## 1. Lexical contract

UTF-8 source. Identifiers use Unicode XID_Start/XID_Continue, compared after NFC normalization; ASCII keywords are case-sensitive. Whitespace and // line comments are insignificant outside literals. String literals use double quotes and explicit escapes; numeric literals require type inference checked against a target-independent integer range. Semicolons terminate declarations and effect statements. A UI component may be written without trailing semicolon after its final view expression.

## 2. Proposed grammar (structural EBNF)

```ebnf
module       = { importDecl }, { typeDecl | componentDecl | serviceDecl } ;
importDecl   = "import", qualifiedName, [ "@", version ], ";" ;
componentDecl= "component", identifier, [ typeParams ], "(", [ params ], ")", "{",
               { stateDecl | derivedDecl | commandDecl | eventDecl | handlerDecl | bindingDecl | taskDecl },
               [ viewExpr ], "}" ;
serviceDecl  = "service", identifier, [ typeParams ], "(", [ params ], ")", "{",
               { stateDecl | derivedDecl | commandDecl | eventDecl | handlerDecl | bindingDecl | taskDecl }, "}" ;
params       = param, { ",", param } ;
param        = ( "input" | "output" ), identifier, ":", type, [ "=", pureExpr ] ;
stateDecl    = "state", identifier, ":", type, "=", pureExpr, ";" ;
derivedDecl  = "derived", identifier, ":", type, "=", pureExpr, ";" ;
eventDecl    = "event", identifier, ":", "Event", "<", type, ">", ";" ;
commandDecl  = "command", identifier, "(", [ namedTypes ], ")", "->", type,
               [ "effects", "(", names, ")" ], [ "on", identifier ], ";" ;
bindingDecl  = "bind", memberPath, "<-", pureExpr, [ "using", qualifiedName ], ";" ;
handlerDecl  = "on", memberPath, "(", identifier, ")", "{", { effectStmt }, "}" ;
taskDecl     = "task", identifier, "(", [ namedTypes ], ")", "->", type,
               "on", identifier, "{", { effectStmt }, "}" ;
effectStmt   = "send", qualifiedName, "(", [ arguments ], ")", ";"
             | "let", identifier, "=", "await", qualifiedName, "(", [ arguments ], ")", ";"
             | "return", pureExpr, ";" ;
viewExpr     = qualifiedName, "(", [ arguments ], ")", [ "{", { viewExpr }, "}" ],
               { ".", identifier, "(", [ arguments ], ")" } ;
type         = qualifiedName, [ "<", type, { ",", type }, ">" ] ;
```

This is a **structural draft**; exact expression precedence, quoted versions, generics constraints and names/qualifiedName token grammar remain unresolved. The syntax is not a complete parser specification.

## 3. Core semantics

- `component` returns an immutable View description. `service` is nonvisual and may not produce an implicit View.
- `state` is instance-owned. Mutations occur through authorized commands/transactions, never by writing an arbitrary field in a pure expression.
- `derived` is pure and evaluated as a typed dependency graph; synchronous cycles are rejected.
- `event` is an immutable typed occurrence, not an effect permission.
- `on` connects an event to an explicit command or typed task; event payload is immutable. An event handler cannot execute raw native hardware operations.
- `command` declares an operation boundary: typed inputs, output/result, effects, and execution affinity. Its implementation is supplied by a compatible service/Assembly component contract.
- `task` defines an asynchronous operation with cancellation and exactly one terminal result; `await` can only suspend inside an allowed async context, never inside `derived` or layout.
- `bind destination <- source` is one-way; source must be pure, type-compatible and observable. `using` names a pure explicit formatter/converter.
- Two-way editing is represented by a **separate intent event plus a committed state binding**, not a hidden cyclic assignment.
- Modifier chaining returns a new View description, with immutable arguments. Modifier order matters for layout/styling; the exact precedence and commutativity table are pending.

## 4. Example: view and event

```aui
component SensorSummary(input reading: String) {
  event inspect: Event<Unit>;
  command Inspect() -> Result<Unit, InspectError> effects(state-write) on ui;
  on inspect(payload) { send Inspect(); }
  VStack(spacing: 12) {
    Text(value: reading).accessibilityLabel("Sensor reading")
    Button(title: "Inspect").accessibilityLabel("Inspect sensor")
  }
}
```

This example still needs explicit syntax for wiring `Button.activated` to the declared `inspect` event; no automatic event dispatch is implied. It is not yet a fully executable program.

## 5. Concurrency and ownership

Tasks require an execution domain and transferable input values. `await` preserves ownership and borrow checks across suspension; unproven borrowed lifetimes fail compilation. All UI state commits are revisioned. Components cannot invoke privileged device I/O just by naming effects; authorization and target adapter capability checks remain mandatory.

## 6. Static diagnostics

| Failure | Expected category |
| --- | --- |
| unknown component, event or command | AUI_UNRESOLVED |
| implicit lossy argument conversion | AUI_TYPE_MISMATCH |
| pure `derived` sends command | AUI_ILLEGAL_EFFECT |
| `await` in layout or pure expression | AUI_AWAIT_CONTEXT |
| missing event payload type | AUI_EVENT_TYPE |
| binding to readonly destination | AUI_BIND_READONLY |
| duplicate writer | AUI_BIND_WRITER_CONFLICT |
| cyclic immediate binding | AUI_BIND_CYCLE |
| task captures invalid borrow | AUI_LIFETIME |
| task transfers non-Send handle | AUI_DOMAIN_TRANSFER |
| unsupported target capability | AUI_TARGET_UNSUPPORTED |
| duplicate dynamic view key | AUI_IDENTITY_DUPLICATE |

## 7. Syntax freeze gates

Before acceptance: finish lexer/expressions and generic constraints; define event-to-handler wiring and command implementation linkage; precise `Result` propagation and cancellation; dynamic lists/keys; modifier evaluation; source-level borrow forms; golden legal/illegal fixtures; compiler-produced diagnostics and per-target output evidence. No part of this document claims a working compiler.
