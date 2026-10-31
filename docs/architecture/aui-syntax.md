# AUI Syntax and Semantics — Design Candidate

**Status: proposed broad D3 language draft, not implemented or frozen.** The narrowed [D3 First Language Profile L0/L1](d3-first-language-profile.md) is the **specific first-slice grammar authority**, including exact lexing, limited expressions and named-only modifiers; the extended grammar below is a **later D3+ proposal**, not an alternate rule for L0/L1. [AUI Language](aui-language.md) describes principles and retains illustrative earlier syntax. No parser exists.

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
    Button(title: "Inspect").on(activated: inspect).accessibilityLabel("Inspect sensor")
  }
}
```

Event attachment `.on(activated: inspect)` is proposed in [Event and Binding Semantics](aui-event-binding-semantics.md). Imported definitions and a linked command implementation are still required; no executable compiler exists.

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

## L0/L1 candidate precedence over this extended syntax

The [first-slice source profile](d3-first-language-profile.md) deliberately excludes service/state/derived/bind/task/await and positional modifier calls while D3+ design remains open. [First-slice type rules](d3-type-and-binding-profile.md) and [event/link semantics](d3-event-delivery-and-command-linkage.md) define exact candidate core signatures, Event<Unit>, Result<T,E>, UI admission and graph binding. The [linked AUI fixture](../../examples/aui-language/linked-consumer-panel.aui) and [link map](../../examples/aui-language/linked-consumer-panel.link.json) are **design-only**. The example in section 4 is *illustrative broad grammar*, not L0/L1 parser-ready because it uses positional accessibilityLabel syntax and unresolved provider contracts. Do not claim D3 language acceptance or compiler tests.

## D3+ L2/L3 compatibility boundary (PROPOSED, not accepted)

The older generic state/derived/bind/task/await grammar above is an **illustrative superseded sketch** wherever it conflicts with the specific proposed [L2 State/Derived/Bind grammar](d3-state-derived-binding-contract.md) and [L3 Task/Result grammar](d3-task-result-lifecycle.md). In particular, the new proposed L2 binding target is an explicitly statically keyed view child, not an arbitrary memberPath; UI state writes are an atomic commit block, never direct effectful expressions. L3 introduces an explicit TaskSlot submit and exhaustive terminal TaskOutcome match, not a bare await in a UI handler. L0/L1 syntax remains unchanged and rejects all these D3+ additions as AUI_PROFILE_UNSUPPORTED. The [source snapshot contract](d3-source-snapshot-reconciliation.md) requires an approved immutable binding, never a name-only match.

## D3+ L2/L3 compatibility (PROPOSED)

The older generic state/derived/bind/task/await grammar above is **illustrative** wherever it conflicts with [L2 State/Derived/Bind](d3-state-derived-binding-contract.md) and [L3 Task/Result](d3-task-result-lifecycle.md). L2 binding uses a statically keyed view property and atomic commit, never an arbitrary memberPath write. L3 requires explicit bounded TaskSlot submit, one await and exhaustive TaskOutcome matching; a bare await in a UI handler remains invalid. L0/L1 continues to reject these new features. [Source/snapshot approval](d3-source-snapshot-reconciliation.md) is required for actual graph linkage.


## Complete production AUI grammar integration — review candidate, not frozen

The **product goal** is a [complete native AUI compiler](aui-compiler.md), not a permanently L0/L1-only checker. The current broad EBNF in section 2 is illustrative and does **not** override the already precise [L0/L1 owner](d3-first-language-profile.md) or the explicit [L2](d3-state-derived-binding-contract.md), [L3](d3-task-result-lifecycle.md) and [L4](d3-keyed-dynamic-view-lifecycle.md) extensions. This section defines how the **shipping** language grammar must be composed before it can be called full-compiler-ready.

### Language/profile admissibility matrix (explicit compilation context, no auto-escalation)

| Construct / expression | L0 | L1 | L2 | L3 | L4 |
| --- | --- | --- | --- | --- | --- |
| imports, one component, named inputs, static Views and visual labels | Yes | Yes | Yes | Yes | Yes |
| Event<Unit>, command intent, local send and Button.activated | Reject | Yes | Yes | Yes | Yes |
| state, derived, bind, static source-key, atomic commit | Reject | Reject | Yes | Yes | Yes |
| task/await, taskSlot, submit, settled/TaskOutcome five-way match | Reject | Reject | Reject | Yes | Yes |
| List<Row>, StableKey, dynamic ForEach and nested item path | Reject | Reject | Reject | Reject | Yes |
| record/enum/service source definitions and pure call declarations | Review required | Review required | Review required | Review required | **P0: source-form/profile scope to approve** |
| arbitrary pointer/FFI, OS calls, implicit conversions, dynamic arbitrary loops | Reject | Reject | Reject | Reject | Reject unless explicitly approved separate extension |

An invocation selects **one** allowed language profile and its verified public type/core and component package closure. A parser recognizes future constructs to produce \`AUI_PROFILE_UNSUPPORTED\`; it never upgrades L0 to L4 based on the text. Inclusion of L0–L3 features in L4 preserves their original exact semantics, unless a specific source contract explicitly adds a new L4 rule.

### Core integrated parse principles

1. **Lexer/token identity:** strict UTF-8 and pinned Unicode 15.1 XID/NFC identifiers (the selected version remains PROPOSED), raw byte spans, unnormalized string scalar values, single token identity for \`->\`, \`<-\`, \`=>\` and \`.\`, and contextual \`on io-worker\` domain atoms distinct from subtraction. Tokenization must never reinterpret ambiguous syntax based on a later target ABI.
2. **Source declarations:** imports precede declarations, duplicate imports and duplicate same-namespace normalized source names reject; component View must remain the final body expression. The reviewed L0/L1 first subset requires exactly one component per file. For full shipping AUI, decide whether separately exported Record/Enum/Service declarations live in **interface-only compilation units** or appear before one component; do not accept both through undocumented parser fallback. All exported TypeIDs are resolved to locked package public contracts, never inferred from source spelling alone.
3. **L2 syntax:** incorporate precisely the [L2 S1](d3-state-derived-binding-contract.md) \`state/derived/bind/commit/set\` productions, the explicit static \`.key(value: ID)\` modifier, and the now specified *bound Text empty-initializer* rule. \`bind view.keyName.property <- pureExpr;\` creates one typed writer, never an arbitrary mutable reference.
4. **L3 syntax:** incorporate [L3 T1](d3-task-result-lifecycle.md) including **explicit \`taskSlot ID: TaskSlot<T,E>;\`** declaration, task/await/return, one submit and typed five-branch settled match. The source ID after \`as\` resolves to an already declared slot, not an implicitly created native handle. \`TaskSlot\` is nonportable. Missing slot, duplicate match branch, untrusted cancellation construction or wrong Result/TaskOutcome generic pair are errors.
5. **L4 syntax:** incorporate precisely [L4 K0](d3-keyed-dynamic-view-lifecycle.md) \`ForEach(items: pureExpr, key: item.field) { item in viewExpr }\` in child-View positions. The binding named \`item\` and the key expression must resolve under the template scope; no global item variable, implicit numeric index or positional fallback is permitted. L4 nested ForEach is a recursive *template* grammar with bounded nesting and a verified \`List<T>\`/StableKey requirement.
6. **Generic types:** accept only explicitly approved named core templates with correct arity and verified nominal arguments; user-defined generic functions, nested arbitrary generics, recursive TypeRefs and unchecked monomorphization cannot be imported merely because extended EBNF parses their angle brackets. The [one core registry](d3-core-registry-value-contract.md) and verified Graph lock own identity.
7. **Pure-expression scope:** \`pureAtom\` (literal or immutable member path) and explicitly approved \`pureCall\` are the only automatically admitted bounded pure expressions in the L2–L4 candidates. Operators, general arithmetic, user-service expressions, overloading and numeric units in the older broad grammar are **NOT FORMALLY SPECIFIED**: they must either be fully defined in this source owner and typed/effect checked, or explicitly absent from the selected shipping contract. No silent default arithmetic or no-op effect.
8. **Services/records/enums:** the product language direction includes these, but the currently broad illustrative EBNF does not define complete public field order, default/variant payload, scoped visibility, generic constraints, version/exports or service implementation boundary. A **production shipping decision** must freeze exact grammar, visibility, type/export contract encoding and source-unit rules before the compiler can claim this part of AUI. A \`service\` declaration may describe a verified provider **interface**, never grant native effectful implementation authority solely from its source block.
9. **Parser recovery:** preserve original CST with error-marked nodes for editing, but never emit successful TypedHIR/GraphLinkedIR/native output from recovered syntax. All profile branches, extension tokens and expression boundaries require unique error diagnostics with source byte spans.

### AUI grammar completeness gate (NO-GO for production until CLOSED)

A **single composed EBNF/grammar source** must enumerate every declared production, ordered token precedence, Unicode policy, profile admission, modifier/child grammar, pure expression form, record/enum/service surface, name scopes, generics and supported target capabilities. It must have deterministic positive and negative golden **complete source files** for all declared features and selected profiles, including L2 state/bind, L3 task/settled/ownership and L4 nested keyed Views. Per-feature snippets are helpful but not enough to certify the whole parser.

**Status:** This is a **composition contract and decision checklist**, not falsely named a complete accepted grammar. The current L0/L1 EBNF and L2–L4 fragments are substantial, but **record/enum/service**, pure-call operation semantics and several cross-profile bindings still need a single frozen parser baseline and human approval. The [compiler's full-product gates](aui-compiler.md) explicitly reject release without it.
