# D3 — AUI Source Profile L0/L1, Formal Syntax and Static Semantics

**Status: PROPOSED; not architect-accepted, implemented or compiler-tested.** This is a bounded first-slice profile of the broader [AUI Syntax](aui-syntax.md) and [AUI Language](aui-language.md), not a competing language. [Event Delivery](d3-event-delivery-and-command-linkage.md) owns event/command policy; [Type and Binding Rules](d3-type-and-binding-profile.md) owns type boundaries; the [ONE Canonical Project Graph](canonical-project-graph-and-components.md) owns persistent identities, while [Graph ↔ AUI](project-graph-aui-contract.md) describes source linkage and reconciliation. No native parser/compiler is being implemented during Phase I.

## L0. Deliberately bounded feature sets

- **L0 Pure View**: explicit offline imports, one component with typed immutable inputs, built-in VStack/HStack/Text/Button, named arguments, pure named visual modifiers, static children.
- **L1 Typed Intent**: L0 plus event, command, on event(payload) handler containing exactly one send call, and explicit Button.activated event attachment. A graph-bound provider is required separately before the command may be treated as LINKED.
- **Outside L0/L1**: user-defined types/services, mutable state, derived expressions, bind, task/await, loops, conditionals, dynamic collections, arbitrary expressions, implicit units conversions, native calls, generics other than Event<T> and Result<T,E>. These stay proposed D3+ features in the broad language. Unsupported feature must fail rather than be guessed.

## L1. Source bytes and lexical rules

- Strict UTF-8 without BOM. Byte spans [start,end) are zero-based, half-open positions into exact original file bytes. Preserve source trivia in lossless CST.
- Identifiers are Unicode XID_Start followed by XID_Continue, compared under NFC. Same-scope NFC collisions -> AUI_DUPLICATE_SYMBOL; preserve original spellings and byte spans.
- Active ASCII keywords are import, component, input, event, command, effects, on, send, true, false; case-sensitive. The lexer also recognizes the future-profile tokens state, derived, bind, task, await, service and the version marker @ specifically to report AUI_PROFILE_UNSUPPORTED when those constructions are attempted in L0/L1; recognition is **not permission** to use them. ui, io-worker and state-write are contextual domain/effect atoms, never automatically privileged operations.
- Whitespace outside strings and // line comments are insignificant; block comments are not supported. No comments in string literals.
- Double-quoted strings accept JSON escapes for quote, backslash, slash, newline, carriage return, tab, backspace, form feed, and four-hex-digit Unicode escapes with required surrogate pairs. Reject invalid escapes, unpaired surrogates and raw controls. String values preserve scalar sequences, without implicit display normalization.
- Unsigned decimal integers are 0 or [1-9][0-9]*. No negatives, separators, exponents, fractions or numeric units in first slice. Integer must fit exact expected type and 2^53-1 literal bound; otherwise AUI_NUMBER_RANGE. true/false are Bool.
- qualifiedName is an identifier followed by dot-separated identifiers. Import version suffixes are unsupported in first slice: exact package versions come from D6 lock. Imported source names resolve to canonical packageId/export TypeID via explicit registry, never by guessing slash/period replacement.
- Effects and execution domain names are contextual ASCII lowercase segments separated by hyphen, such as state-write and io-worker. They are not general expressions.

## L2. Complete first-slice EBNF candidate

Notation: braces mean repetition, square brackets optional, bar alternative, ID/STR/INT/effectAtom/domainAtom lexer token classes. EOF mandatory.

    module           = { importDecl }, componentDecl, EOF ;
    importDecl       = "import", qualifiedName, ";" ;
    componentDecl    = "component", ID, "(", [ inputList ], ")", "{",
                       { eventDecl | commandDecl | handlerDecl }, viewExpr, "}" ;
    inputList        = inputDecl, { ",", inputDecl } ;
    inputDecl        = "input", ID, ":", typeName ;
    eventDecl        = "event", ID, ":", "Event", "<", typeName, ">", ";" ;
    commandDecl      = "command", ID, "(", [ commandParams ], ")", "->",
                       "Result", "<", typeName, ",", typeName, ">",
                       [ "effects", "(", [ effectList ], ")" ],
                       "on", domainAtom, ";" ;
    commandParams    = commandParam, { ",", commandParam } ;
    commandParam     = ID, ":", typeName ;
    effectList       = effectAtom, { ",", effectAtom } ;
    handlerDecl      = "on", ID, "(", ID, ")", "{", "send", ID,
                       "(", [ namedArgs ], ")", ";", "}" ;
    viewExpr         = viewName, "(", [ namedArgs ], ")",
                       [ "{", viewExpr, { viewExpr }, "}" ], { modifier } ;
    modifier         = ".", ( ID | "on" ), "(", namedArgs, ")" ;
    namedArgs        = namedArg, { ",", namedArg } ;
    namedArg         = ID, ":", pureAtom ;
    pureAtom         = STR | INT | "true" | "false" | memberPath ;
    memberPath       = ID, { ".", ID } ;
    viewName         = ID ;
    typeName         = qualifiedName ;
    qualifiedName    = ID, { ".", ID } ;
    effectAtom       = ID, { "-", ID } ;
    domainAtom       = ID, { "-", ID } ;

Static restrictions beyond grammar:
1. Exactly one top-level view expression; VStack/HStack require one or more children, Text/Button require none. The four built-ins must be imported from a pinned core registry. No arbitrary unknown view call is accepted for linked output.
2. All arguments are named, no positional shorthand, and duplicate argument labels fail. Static named property signatures: VStack/HStack(spacing: U32); Text(value: String); Button(title: String); optional accessibilityLabel(value: String) visual modifier; optional Button-only .on(activated: localEventID).
3. Constructor and child expression parse before any chained modifiers, which apply left-to-right to the immediately preceding view. The reserved keyword on is intentionally legal only after dot in the recognized event-attachment modifier, not as a general declaration ID. No general expression operator precedence in this first profile. Member paths are pure property reads, never function calls.
4. L1 command declaration requires Result<Success,Error> and explicit on domain. Omitted effects(...) means empty set; no implicit effects. Handler has exactly one send; no await, return or in-handler state mutation.
5. Event attachment connects typed Button.activated Event<Unit> to a declared local Event<Unit>, not directly to a graph edge or physical operation. A handler dispatches a *declared* command. The actual graph provider is linked separately by an approved D3 link map.
6. Integer literal is only used in exact compatible numeric property context. String/Bool/U32 conversions must be explicit in later profile; Text(value: 12) is invalid.
7. Only one component per source module in first slice; duplicate imports or conflicting type names are errors. No block-level declarations after the final view expression.

## L3. Error recovery

Lexical errors block parse-stage success. Parser may recover after a semicolon or balanced brace for editor diagnostics, but cannot emit valid TypedHIR or executable output from an error-recovered tree. Future-profile keywords/constructions such as state or await and import @versions produce AUI_PROFILE_UNSUPPORTED under the first-profile gate rather than being executed. Unknown package, ambiguous imported component, invalid event source, wrong payload, missing command provider and target permissions are separately diagnosed by stage. Do not report successful linkage on a syntax-only fixture.

No source statement can fetch dependencies, execute a native command, instantiate a privileged service or change Project Graph. The file is an untrusted declaration until exact import/export resolution and human approval of relevant graph mutations.

## L4. L0 example (design only)

    import aui.core;

    component StatusPanel(input title: String) {
      VStack(spacing: 12) {
        Text(value: title).accessibilityLabel(value: "Status title")
        Button(title: "Inspect").accessibilityLabel(value: "Inspect")
      }
    }

The core library is a **candidate pinned built-in registry**, not automatically shipped or tested. This source is a positive *syntax/type* case only. Existing sensor-summary.aui is an older illustrative example using positional modifier shorthand and is NOT L0/L1 parser-ready until migrated.

## L5. Phase III future acceptance

The initial parser must record stable diagnostic code, file/source digest, start/end byte spans, normalized symbol name, expected/actual and graph origin where known. Order: encoding -> lexer -> syntax/profile -> imports/symbols -> types/argument labels -> child/modifier/event wiring -> effects/command link -> target/ownership -> TypedHIR. Golden legal and illegal fixtures live in [AUI Language Examples](../../examples/aui-language/). They are designed, not executed.

**Open P0:** pin a concrete core registry, Unicode tables/version, parser resource budgets, exact D3 event scheduling and graph command link mapping, D3+ state/bind/tasks, view identity rules, actual target rendering and ABI. No gate is accepted by this draft.

## L2/L3 versioned extension policy

The [L2 State/Derived/Bind contract](d3-state-derived-binding-contract.md) and [L3 Task/Result contract](d3-task-result-lifecycle.md) are future **versioned source profiles**, NOT extensions admitted by this strict L0/L1 grammar. They do not implicitly relax named-only arguments, strict UTF-8, source IDs, target/effect/capability checks, or Graph source authority. The [source-to-Graph bundle](d3-source-snapshot-reconciliation.md) requires an approved immutable source+lock+graph review. All future profile tests remain NOT-RUN; a token such as state or await in an L0/L1 file is still AUI_PROFILE_UNSUPPORTED.

## L2/L3 source profile separation

[L2 State/Derived/Bind](d3-state-derived-binding-contract.md) and [L3 Task/Result](d3-task-result-lifecycle.md) are **proposed versioned D3+ profiles**. They do not relax this L0/L1 grammar's strict imports/types, named arguments, semantic source/graph checking or command authority. A state/await/submit/settled token remains AUI_PROFILE_UNSUPPORTED in L0/L1. [Source snapshot](d3-source-snapshot-reconciliation.md) must pin exact source bytes/profile/core registry for later linkage. No advanced parser or runtime is implemented.

## L4 dynamic feature gate (PROPOSED)

[Keyed Dynamic Views](d3-keyed-dynamic-view-lifecycle.md) proposes an explicitly versioned aui.source/l4-keyed/v1 extension with a bounded ForEach view child, typed List<T> and immutable StableKey. It is not part of this L0/L1 grammar: ForEach/List<T>/dynamic view children are rejected as AUI_PROFILE_UNSUPPORTED in the first profile until a later L4 compilation context is explicitly selected. Indexed or implicit row identity must never be used as fallback. [L4 examples](../../examples/aui-language/L4-README.md) are design-only.

## L4 separate source profile (PROPOSED)

[Keyed Dynamic Views](d3-keyed-dynamic-view-lifecycle.md) defines aui.source/l4-keyed/v1 with ForEach, typed List<T> and tagged immutable StableKey. The L0/L1 grammar and acceptance boundary remain unchanged: dynamic views are unsupported in a first-profile source and must not be silently accepted. [L4 fixture](../../examples/aui-language/L4-README.md) is design-only, not a working compiler test.
