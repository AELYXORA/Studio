# AUI Declarative Language — Design Specification

**Status: proposed.** AUI is an independent, typed, human-readable declarative language inspired by SwiftUI composition; it is neither Swift source nor tied to a particular CPU.

## Semantic principles

1. Views are values describing desired UI, not imperative widget handles.
2. Composition, identity, state and effects are distinct concepts.
3. Names and type IDs are resolved at design/build time wherever possible.
4. Declarative descriptions have no direct side effects. Commands and effectful services are explicit.
5. One project graph owns components and contracts; AUI describes visual projections of that graph.
6. Dynamic features are opt-in and their cost is observable.

## Proposed syntax (illustrative, NOT yet standardized)

```aui
component SensorPanel(input reading: Measurement) {
    state expanded: Bool = true

    VStack(spacing: 12) {
        Text("Sensor").font(.title)
        Text(reading.value).accessibilityLabel("Sensor reading")
        Button("Details") { send ToggleDetails() }
    }
}
```

Syntax is an exploration, not accepted grammar. In particular `send`, closures, literal conversions and modifier chains require exact type/effect semantics before stabilization.

## Language model

- Modules, imported component packages, exported components and namespaces.
- Types: Bool; fixed-width signed/unsigned integers; bounded numeric and floating types; UTF-8 String; Bytes; Enum; Record; Optional; Result; Array/Collection; opaque resources/handles; constrained generics.
- Distinguish unit-bearing values (time, size, voltage, frequency, angle) to prevent accidental conversions in hardware UI.
- Components define typed inputs, outputs, local state, computed values, commands, events and slots.
- Properties have default values, mutability, ownership and validation rules.
- Layout constructors declare children, composition order and constraints.
- Explicit stable keys for dynamic collections; positional identity only within documented static conditions.
- No implicit arbitrary code execution or runtime reflection from AUI declarations.

## Effects and bindings

`state` is owned storage; `input` is received data; `derived` is a pure computed value. A view may bind to approved observable properties. Handlers dispatch typed commands rather than running unrestricted side-effecting scripts on the render thread. Two-way controls require an explicit edit/commit contract.

## Type system and diagnostics

Compile-time errors: missing component, ambiguous import, invalid property, type/unit mismatch, illegal capability, invalid binding direction and unsupported target requirement. Every diagnostic carries file, span, graph node ID where applicable, severity and a fix hint. Stable identity and update semantics are part of the language specification.

## Accessibility and portability

Semantic role, label, focus, keyboard action and accessibility value are first-class typed attributes. Visual APIs are target-capability gated; unsupported properties produce diagnostics, not silent changes. Internationalization, right-to-left layout and IME behavior require explicit contract coverage.

## Still open

Final grammar, generic constraints, string interpolation, async syntax, immutable collection representation, source maps, binary module packaging and component version resolution. Freeze syntax only after parser + type-checker fixture comparisons. See [AUI Syntax and Semantics](aui-syntax.md) for the current extended language candidate.

## Earlier restricted grammar illustration (superseded by the current syntax proposal)

This EBNF defines a **restricted design subset**. It is not yet a frozen compiler grammar. Identifiers are UTF-8 but normalization, reserved words and escaping need an explicit lexical decision.

```ebnf
module        = { importDecl }, { declaration } ;
importDecl    = "import", qualifiedName, [ "@", version ], ";" ;
declaration   = componentDecl | recordDecl | enumDecl ;
componentDecl = "component", identifier, "(", [ parameters ], ")", "{",
                { stateDecl | derivedDecl | actionDecl }, viewExpr, "}" ;
parameters    = parameter, { ",", parameter } ;
parameter     = ("input" | "output"), identifier, ":", type ;
stateDecl     = "state", identifier, ":", type, "=", literal, ";" ;
derivedDecl   = "derived", identifier, ":", type, "=", pureExpr, ";" ;
actionDecl    = "action", identifier, "(", [ parameters ], ")", "->", type, ";" ;
viewExpr      = qualifiedName, "(", [ arguments ], ")", "{", { viewExpr }, "}" ;
arguments     = argument, { ",", argument } ;
argument      = [ identifier, ":" ], pureExpr ;
type          = qualifiedName, [ "<", type, { ",", type }, ">" ] ;
pureExpr      = literal | identifier | memberPath | callPure ;
```

A trailing view expression defines a component's visual result. Nonvisual components may have no view expression; the exact declaration keyword is still open. Event handlers are deliberately excluded until the effect grammar is defined. The earlier illustrative `Button { send ... }` is **not yet valid under this subset**.

### Static semantics

- Lexical scope resolves local state/input before explicit imports. Unresolved and ambiguous names fail compilation.
- `derived` is pure, deterministic given its typed inputs, and cannot initiate device I/O or mutate state.
- `state` is instance-owned; only a typed authorized command can write it.
- Construction checks named argument compatibility, required inputs and child-slot cardinality.
- A dynamic collection needs explicit stable keys; duplicate keys within one sibling scope are rejected.
- Diagnostics must identify source span, component identity and violated contract.

### Example: canonical static view

```aui
component SensorSummary(input label: String) {
  VStack(spacing: 12) {
    Text(value: label) {}
    Button(title: "Inspect") {}
  }
}
```

The example uses only the restricted grammar; semantic availability of each builtin component remains a library-contract requirement. Empty child braces are permitted by this draft but may be eliminated in a later syntax decision.

### Acceptance cases

| Fixture | Expected outcome |
| --- | --- |
| Two typed children with unique static identities | Accept |
| Unknown component symbol | Error: unresolved component |
| `Text(value: 42)` when value requires String | Error: type mismatch |
| `derived` reads an undeclared name | Error: unresolved reference |
| `derived` invokes hardware I/O | Error: prohibited effect |
| Dynamic sibling collection with duplicate stable keys | Error: duplicate identity |

**Open:** lexical tokenization, operator precedence, generics, collections and dynamic child syntax.
