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

An invocation selects **one** allowed language profile and its verified public type/core and component package closure. A parser recognizes future constructs to produce `AUI_PROFILE_UNSUPPORTED`; it never upgrades L0 to L4 based on the text. Inclusion of L0–L3 features in L4 preserves their original exact semantics, unless a specific source contract explicitly adds a new L4 rule.

### Core integrated parse principles

1. **Lexer/token identity:** strict UTF-8 and pinned Unicode 15.1 XID/NFC identifiers (the selected version remains PROPOSED), raw byte spans, unnormalized string scalar values, single token identity for `->`, `<-`, `=>` and `.`, and contextual `on io-worker` domain atoms distinct from subtraction. Tokenization must never reinterpret ambiguous syntax based on a later target ABI.
2. **Source declarations:** imports precede declarations, duplicate imports and duplicate same-namespace normalized source names reject; component View must remain the final body expression. The reviewed L0/L1 first subset requires exactly one component per file. For full shipping AUI, decide whether separately exported Record/Enum/Service declarations live in **interface-only compilation units** or appear before one component; do not accept both through undocumented parser fallback. All exported TypeIDs are resolved to locked package public contracts, never inferred from source spelling alone.
3. **L2 syntax:** incorporate precisely the [L2 S1](d3-state-derived-binding-contract.md) `state/derived/bind/commit/set` productions, the explicit static `.key(value: ID)` modifier, and the now specified *bound Text empty-initializer* rule. `bind view.keyName.property <- pureExpr;` creates one typed writer, never an arbitrary mutable reference.
4. **L3 syntax:** incorporate [L3 T1](d3-task-result-lifecycle.md) including **explicit `taskSlot ID: TaskSlot<T,E>;`** declaration, task/await/return, one submit and typed five-branch settled match. The source ID after `as` resolves to an already declared slot, not an implicitly created native handle. `TaskSlot` is nonportable. Missing slot, duplicate match branch, untrusted cancellation construction or wrong Result/TaskOutcome generic pair are errors.
5. **L4 syntax:** incorporate precisely [L4 K0](d3-keyed-dynamic-view-lifecycle.md) `ForEach(items: pureExpr, key: item.field) { item in viewExpr }` in child-View positions. The binding named `item` and the key expression must resolve under the template scope; no global item variable, implicit numeric index or positional fallback is permitted. L4 nested ForEach is a recursive *template* grammar with bounded nesting and a verified `List<T>`/StableKey requirement.
6. **Generic types:** accept only explicitly approved named core templates with correct arity and verified nominal arguments; user-defined generic functions, nested arbitrary generics, recursive TypeRefs and unchecked monomorphization cannot be imported merely because extended EBNF parses their angle brackets. The [one core registry](d3-core-registry-value-contract.md) and verified Graph lock own identity.
7. **Pure-expression scope:** `pureAtom` (literal or immutable member path) and explicitly approved `pureCall` are the only automatically admitted bounded pure expressions in the L2–L4 candidates. Operators, general arithmetic, user-service expressions, overloading and numeric units in the older broad grammar are **NOT FORMALLY SPECIFIED**: they must either be fully defined in this source owner and typed/effect checked, or explicitly absent from the selected shipping contract. No silent default arithmetic or no-op effect.
8. **Services/records/enums:** the product language direction includes these, but the currently broad illustrative EBNF does not define complete public field order, default/variant payload, scoped visibility, generic constraints, version/exports or service implementation boundary. A **production shipping decision** must freeze exact grammar, visibility, type/export contract encoding and source-unit rules before the compiler can claim this part of AUI. A `service` declaration may describe a verified provider **interface**, never grant native effectful implementation authority solely from its source block.
9. **Parser recovery:** preserve original CST with error-marked nodes for editing, but never emit successful TypedHIR/GraphLinkedIR/native output from recovered syntax. All profile branches, extension tokens and expression boundaries require unique error diagnostics with source byte spans.

### AUI grammar completeness gate (NO-GO for production until CLOSED)

A **single composed EBNF/grammar source** must enumerate every declared production, ordered token precedence, Unicode policy, profile admission, modifier/child grammar, pure expression form, record/enum/service surface, name scopes, generics and supported target capabilities. It must have deterministic positive and negative golden **complete source files** for all declared features and selected profiles, including L2 state/bind, L3 task/settled/ownership and L4 nested keyed Views. Per-feature snippets are helpful but not enough to certify the whole parser.

**Status:** This is a **composition contract and decision checklist**, not falsely named a complete accepted grammar. The current L0/L1 EBNF and L2–L4 fragments are substantial, but **record/enum/service**, pure-call operation semantics and several cross-profile bindings still need a single frozen parser baseline and human approval. The [compiler's full-product gates](aui-compiler.md) explicitly reject release without it.


## Native-service and nominal-contract source units — explicit shipping grammar candidate

The production compiler must understand separately authored **interface-only AUI source units** for public record/enum/service contracts, while preserving the strict one-View-component-per-file L0/L1 source grammar. This resolves the earlier broad grammar ambiguity without creating a second language or Project Graph. The **single** source-language grammar has two explicitly selected *module kinds* through the immutable compilation context:

- `component` source unit: the existing imports + **one** component with the admitted L0–L4 profile and exactly one terminal root view.
- `contract` source unit: imports + **one or more** public nominal record, enum or nonvisual service interface declarations, **no View and no executable native service body**. It is compiled to candidate type/operation/component public contracts and linked under verified D2/D6 package-review rules. It is never an executable application by itself.

**Exact structural EBNF candidate** (this is *not* a user-approved freeze):

```ebnf
contractModule = { importDecl }, contractDecl, { contractDecl }, EOF ;
contractDecl   = recordDecl | enumDecl | serviceInterface ;
recordDecl     = "record", ID, "{", recordField, { recordField }, "}" ;
recordField    = ID, ":", typeRef, ";" ;
enumDecl       = "enum", ID, "{", enumCase, { enumCase }, "}" ;
enumCase       = ID, [ "(", typeRef, ")" ], ";" ;
serviceInterface
               = "service", ID, "{", serviceCommand, { serviceCommand }, "}" ;
serviceCommand = "command", ID, "(", [ commandParams ], ")",
                 "->", "Result", "<", typeRef, ",", typeRef, ">",
                 [ "effects", "(", [ effectList ], ")" ],
                 "on", domainAtom, ";" ;
typeRef        = qualifiedName, [ "<", typeRef, { ",", typeRef }, ">" ] ;
```

**Semantics and admission:**

1. Each exported `record`, `enum` or `service` receives a fully-qualified public owner-package/type/service ID derived from a verified D6 package namespace. Duplicates, NFC collisions, zero-field records if not expressly admitted by a reviewed contract, empty enums, duplicate variant names and ambiguous imports reject. Record fields and enum variants are **author-order semantic**; no alphabetical reordering changes their public meaning silently.
2. A `record` is an immutable **value** definition, not a native pointer, OS file struct or mutable class. Each field has exactly one verified publicly admissible TypeReference. Recursion by-value rejects until an explicit bounded-indirection/ownership contract exists. Exact D4 target layout is derived separately and does not replace logical type identity.
3. An `enum` is a closed discriminated union of zero- or one-payload variants in this shipping candidate; a payload type must be verified nominal/approved generic and have an explicitly owned move/copy/drop policy. The **tag encoding, payload layout and portable value codec** are separate reviewed D3/D4 obligations; no compiler may invent native union sizes. Constructor/pattern-match syntax for *user-defined* enum variants is **NOT YET APPROVED** and must be closed before claiming arbitrary enum use in UI expressions.
4. A `service` defines a nonvisual **interface** only: exact ordered named command arguments, two-branch Result<T,E>, effects/domain/capabilities from a verified owning public contract and no native body. A service implementation can be an independently authored/verified Assembly package bound by the ONE Canonical Graph and D4 module table; the AUI interface declaration alone is **not a dispatch implementation or permission**. The exact service provider mapping must be signed/reviewed before GraphLinkedIR or native codegen.
5. Within `typeRef`, accept only verified templates of admitted arity and ownership, including 1-argument List<Event> forms only where source/type gates permit, and 2-argument Result/TaskOutcome/TaskSlot where the owning D3 profile permits. Generic nesting, cycles, ownership/Send and package bounds are checked by the same core/export resolver, not by loose surface grammar.
6. If an AUI file is compiled in `component` mode, top-level `record/enum/service` forms reject as wrong module kind; if in `contract` mode, `component`, `state`, `task`, `ForEach`, native machine instructions and arbitrary imperative bodies reject. This is a **compilation-unit distinction**, not a new product architecture/version.
7. The source→export compilation mode has **no native execution output** by itself. Output is a strict proposed *authored public contract candidate*, validated against [Canonical Graph C10/C12](canonical-project-graph-and-components.md) and only considered a trusted public export once exact structured type/operation semantic definitions and D6 lock/signature closure have been independently reviewed. Human typed source cannot supply its own trustworthy digest.

**Example contract source (design only):**

```aui
import aui.core;

record Measurement {
  value: F64;
  valid: Bool;
}

enum SensorError {
  NoReading;
  DeviceUnavailable;
}

service SensorReader {
  command Read() -> Result<Measurement, SensorError>
    effects(device-read) on io-worker;
}
```

**Unfinished exact decisions:** where native public effect/capability atoms are declared (source service effect text cannot impersonate a registered capability); whether user-defined enum construction/pattern matching and generic composition are in shipping D3; the exact `contract` CLI mode and namespace/package provenance; complete binary/portable payload codecs and ABI layout; verified compiler source-plan schemas and golden bytes. Until these receive architect approval, this is a **concrete candidate** rather than a frozen shipping grammar. The full [AUI compiler](aui-compiler.md) requires these decisions to be closed before its product release.


## Integrated candidate grammar: exact L0–L4 composition for one production parser

**Status: PROPOSED COMPLETE *structural* grammar / NOT an accepted language standard.** This consolidates the already selected D3 L0/L1, L2 state, L3 task and L4 keyed source forms **inside the existing AUI Syntax owner**, to prevent five independently implemented parsers. It deliberately does **not** pretend to solve verified core exports, all pure-call semantics, enum construction, full type ABI, OS runtime or signer admission. When a more detailed rule conflicts, reconcile the owning D3 section before acceptance; do not privately implement whichever one is convenient.

### Lexical tokens and disambiguation

- Strict UTF-8, no BOM, source byte spans, pinned Unicode XID/NFC lookup for identifiers, **not** for general String values. Keep NFC collisions visible with original source spans. ASCII punctuation; longest-match tokenization of \`->\`, \`<-\`, \`=>\`; otherwise \`-\`, \`<\`, \`>\`, \`=\`, \`.\` are single tokens. A \`-\` is legal only between name segments in a declared \`domainAtom\`/\`effectAtom\`; do **not** add unary/binary subtraction by accident.
- Keyword set (case-sensitive): \`import component input event command effects on send state derived bind commit set task taskSlot let await return submit as settled match ForEach items key in record enum service true false\`. The source contexts for \`Successful Failed AdmissionRejected Cancelled ProviderUnavailable\` are **reserved pattern tags** only in L3 settled-match arms; \`Result Event List StableKey TaskOutcome TaskSlot\` are recognized *type names* validated through exact core exports, not arbitrary implicit values.
- The tokens \`view\` in \`bind view.key.property\`, \`item\` in \`key: item.field\`, \`value\`/\`activated\` in property labels and \`io-worker\` in declared domains are contextual names, not globally variable declarations. \`ForEach\` is a reserved View constructor in L4; no user package may shadow it in that compilation context. No semicolon after final root View; no comma between child Views.
- Comments are \`//\` to LF/EOF only. First shipping candidate deliberately excludes block comments, raw/interpolated/multiline strings, generic operator expressions, floating source literals, named default parameters, positional calls, dynamic import versions and unrestricted macros. Unknown constructs reject instead of being accepted and dropped during lowering.

### Unified grammar candidate — component source unit

Notation: \`{...}\` zero-or-more; \`[...]\` optional; \`|\` alternative; \`EOF\` mandatory. This is parser grammar; the semantic profile and exact type/ownership rules below narrow what parses successfully.

\`\`\`ebnf
sourceUnit       = componentModule | contractModule ;
componentModule  = { importDecl }, componentDecl, EOF ;
componentDecl    = "component", ID, "(", [ inputList ], ")", "{",
                   { componentMember }, rootView, "}" ;
componentMember  = eventDecl | commandDecl | eventHandler
                 | stateDecl | derivedDecl | bindDecl
                 | taskSlotDecl | taskDecl | settledHandler ;
inputList        = inputDecl, { ",", inputDecl } ;
inputDecl        = "input", ID, ":", typeRef ;
importDecl       = "import", qualifiedName, ";" ;

eventDecl        = "event", ID, ":", "Event", "<", typeRef, ">", ";" ;
commandDecl      = "command", ID, "(", [ commandParams ], ")", "->",
                   "Result", "<", typeRef, ",", typeRef, ">",
                   [ "effects", "(", [ effectList ], ")" ],
                   "on", domainAtom, ";" ;
commandParams    = commandParam, { ",", commandParam } ;
commandParam     = ID, ":", typeRef ;
effectList       = effectAtom, { ",", effectAtom } ;

stateDecl        = "state", ID, ":", typeRef, "=", pureExpr, ";" ;
derivedDecl      = "derived", ID, ":", typeRef, "=", pureExpr, ";" ;
bindDecl         = "bind", "view", ".", ID, ".", ID, "<-", pureExpr,
                   [ "using", qualifiedName ], ";" ;

eventHandler     = "on", ID, "(", ID, ")", "{",
                   ( sendStmt | stateCommit | submitStmt ), "}" ;
sendStmt         = "send", ID, "(", [ namedArgs ], ")", ";" ;
stateCommit      = "commit", "{", setStmt, { setStmt }, "}" ;
setStmt          = "set", ID, "=", pureExpr, ";" ;

taskSlotDecl     = "taskSlot", ID, ":", "TaskSlot", "<",
                   typeRef, ",", typeRef, ">", ";" ;
taskDecl         = "task", ID, "(", [ commandParams ], ")", "->",
                   "Result", "<", typeRef, ",", typeRef, ">",
                   "on", domainAtom, "{", awaitStmt, returnStmt, "}" ;
awaitStmt        = "let", ID, "=", "await", ID, "(",
                   [ namedArgs ], ")", ";" ;
returnStmt       = "return", ID, ";" ;
submitStmt       = "submit", ID, "(", [ namedArgs ], ")",
                   "as", ID, ";" ;
settledHandler   = "on", "settled", ID, "(", ID, ")", "{",
                   "match", ID, "{",
                     successArm, failureArm, rejectArm,
                     cancelledArm, unavailableArm,
                   "}", "}" ;
successArm       = "Successful", "(", ID, ")", "=>", stateCommit ;
failureArm       = "Failed", "(", ID, ")", "=>", stateCommit ;
rejectArm        = "AdmissionRejected", "(", ID, ")", "=>", stateCommit ;
cancelledArm     = "Cancelled", "(", ID, ")", "=>", stateCommit ;
unavailableArm   = "ProviderUnavailable", "(", ID, ")", "=>", stateCommit ;

rootView         = staticView ;
staticView       = viewName, "(", [ namedArgs ], ")",
                   [ "{", childView, { childView }, "}" ],
                   { modifier } ;
childView        = staticView | dynamicView ;
dynamicView      = "ForEach", "(", "items", ":", pureExpr,
                   ",", "key", ":", "item", ".", ID, ")",
                   "{", "item", "in", childView, "}" ;

modifier         = ".", modifierName, "(", namedArg,
                   { ",", namedArg }, ")" ;
modifierName     = ID | "on" ;
namedArgs        = namedArg, { ",", namedArg } ;
namedArg         = ID, ":", pureExpr ;
pureExpr         = pureAtom | pureCall ;
pureCall         = qualifiedName, "(", [ namedArgs ], ")" ;
pureAtom         = STR | INT | "true" | "false" | memberPath ;
memberPath       = ID, { ".", ID } ;

viewName         = ID ;
typeRef          = qualifiedName, [ "<", typeRef,
                   { ",", typeRef }, ">" ] ;
qualifiedName    = ID, { ".", ID } ;
effectAtom       = ID, { "-", ID } ;
domainAtom       = ID, { "-", ID } ;
\`\`\`

**Mandatory refinement of the grammar above:**
1. **Root must be a static View**, not a raw ForEach; L4 dynamic Views occur only in static stack children or another ForEach template child. To expose a dynamic root, wrap it in a static stack. A \`ForEach\` has exactly one template \`childView\` and \`item\` as its bound variable for this candidate, not arbitrary expression statements.
2. **No empty / invalid children:** \`VStack/HStack\` require \`{ childView+ }\`; \`Text/Button\` reject any child block. The parser admits the structural forms but the closed visual constructor contract validates them. \`Text()\` only when L2+ static \`.key(value: ID)\` and one matching bind writer; otherwise require exactly \`Text(value: String)\`.
3. **No accidental general calls:** \`pureCall\` is permitted only in L2+ contexts where an **exact verified pure function**, complete named signature, bound execution/memory cost and no OS/IO/async effects have been resolved. In L0/L1 named arguments are only literals/member paths; a syntactic pureCall there produces \`AUI_PROFILE_UNSUPPORTED\`. \`pureCall\` cannot be used to fake a provider command.
4. **Scope and restrictions:** componentMembers may appear in any authored declaration order before root View, but all same-scope normalized names/keywords must pass namespace checks. Events/commands/handlers are L1+, state/derived/bind/commit are L2+, taskSlot/task/submit/settled are L3+, dynamicView is L4 only. \`task\` always owns exactly one \`await\` and one \`return\`. L2 handlers contain exactly one send **or** one commit; L3 handlers contain exactly one send **or** commit **or** submit; no implicit multi-action sequence.
5. **Declaration references are two-phase:** collect declarations first, then resolve state/derived DAG, event handlers, task/slot/output links and View static keys independent of authored member order. Never make meaning depend on a source declaration preceding its use, but duplicate symbols and unknown names reject. \`on settled\` has a distinct keyword lookahead from \`on ID\` event handler.
6. **Generics are parsed structurally but accepted semantically only for verified core/export templates** with exact arity, admitted nesting and owner/transport policy. \`List<Row>\`, \`Result<T,E>\`, \`Event<Unit>\`, \`TaskSlot<T,E>\` have specific context rules; arbitrary recursive/higher-kinded generics remain unsupported. \`TaskSlot\` is non-portable, not graph payload.
7. **Initializer and string semantics:** \`state\` init and \`derived\` pureExpr are validated for exact type, deterministic purity and bounded evaluation. \`bind view.key.prop\` has precisely one writer; a \`Text(value: ...)\` and \`bind\` to its value conflict. Textual \`String\` scalar equality is exact, identifiers resolve under pinned NFC. No general numerical operators are implied by \`pureExpr\`.
8. **Property/modifier semantic checking:** an unknown modifier, mismatched argument, duplicate \`key\`, repeated \`on(activated:...)\`, missing Button accessibilityLabel, illegal View-specific modifier or unrecognized bind target rejects. \`.key(value: ID)\` is a source-symbol identifier, not an arbitrary String, runtime StableKey, native address or GraphNodeID. It is allowed only from L2+.
9. **No undefined whitespace rules:** braces, comma, semicolon, dots, angle brackets and the three multi-character operators are exact; line endings only affect original byte spans. No implicit semicolon insertion or accepted trailing comma unless a **separate** explicit source rule is frozen.
10. **Contract module imports and types:** the interface-only module grammar remains [the same existing contractModule owner above](#native-service-and-nominal-contract-source-units--explicit-shipping-grammar-candidate); its \`commandParams\`, \`effectList\`, \`domainAtom\`, \`typeRef\` and \`importDecl\` are the identical productions defined here, **not invented local alternatives**. Contract-mode source cannot contain a component, event handler, task implementation or native service body. Module kind is explicit immutable compilation input, not automatic token-based selection in a trusted build.

### Known grammar/semantic issues that remain genuine blockers

- **Keyword-versus-ID lexical contract:** \`state\`, \`on\`, \`set\`, \`item\`, \`value\`, \`true\` and \`false\` have contextual positions. The accepted parser contract must pin which reserved keywords can be used as named argument/property labels. This grammar **proposes** contextual labels, but does not authorize unchecked shadowing of declaration names. Freeze the lexical classifier and error precedence with complete tokenization fixtures.
- **Pure call/overload and bound conversion:** no approved pure function registry, overloaded resolution policy, constant evaluation budget or \`using Converter\` operation identity is yet fully frozen for L2+. An opaque external service implementation must not be silently accepted as pure.
- **L4 view keys** use \`StableKey\` values for runtime items but L2 static \`.key\` uses a source ID. These are different types and must be independently validated. Keyed nested child fragments, handler capture ownership and full current item parent-path runtime resource/expiry still require D4/D5 testing.
- **Native public enum/service availability:** the current [canonical component package schema](../../schemas/canonical-component-package.schema.json) defines public \`types\` as **record** entries and components/commands, not a complete source-authored enum/service export model. An AUI \`enum SensorError\` or \`service SensorReader\` can be parsed as a design candidate, but **cannot produce a trusted public TypeReference or native-linked service** until that **existing canonical owner/schema** is extended and independently accepted; do not create a sidecar "service graph".
- **Full shipping grammar closure:** exact source file identity, imported package namespace mapping, complete record/enum variant constructors and pattern match usage, generic type syntactic restrictions, diagnostic code table and compiler-value/ABI mapping remain separate explicit D3/D4/D6 sign-off items. Claiming that an EBNF alone makes a full compiler ready is incorrect.

### Acceptance for the combined parser (design-only, not-run)

The [production grammar review cases](../../examples/aui-compiler-production/integrated-grammar-cases.json) enumerate complete source profiles, module-kind/profile errors, L3 slot/Outcome matching, L2 bind initialization, L4 keyed template boundaries, effect/pure call gate and exact record/enum/service export blockers. The full [production compiler criteria](../../examples/aui-compiler-production/complete-compiler-acceptance.json) additionally require actual target-native machine code, Graph link, runtime and reproducible signed release. Neither suite is currently executed; no AUI parser exists in the repository.
