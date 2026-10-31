# AUI AST and Semantic Analysis

**Status: proposed design contract, not implemented.** This document owns source-tree shape, symbol resolution, type/effect analysis and TypedHIR output. [AUI Syntax](aui-syntax.md) owns surface grammar, [IR/Layout](aui-ir-layout.md) owns ownership lowering, and [Component Framework](component-framework.md) owns component definitions.

## Compiler boundary

Source UTF-8 -> lexer tokens -> lossless Concrete Syntax Tree (CST) -> structural AST -> name/type/effect/identity analysis -> TypedHIR -> OwnershipIR -> TargetMIR. CST retains comments and user formatting for editor diffs; AST removes trivia but keeps stable source spans. No code is executed during semantic analysis.

## Structural AST

- Module(imports, declarations, span)
- TypeDecl(record/enum), ComponentDecl, ServiceDecl, TypeParameters, ParameterDecl
- Property/StateDecl, DerivedDecl, EventDecl, CommandDecl, HandlerDecl, BindingDecl, TaskDecl
- ViewCall(callee, arguments, children, modifiers, stableKey)
- Expressions: Literal, Name, Member, PureCall, TypedConstruct, Unary, Binary (operators pending syntax freeze)
- Statements: SendCommand, AwaitCall, Return, ImmutableLet
- TypeRef(name, typeArguments), SourceSpan(file,startByte,endByte), GraphOrigin(projectNodeId optional)

Every declaration has a compilation-scoped AST ID, source span and identifier. Persistent Project Graph IDs are never derived from line numbers or unstable AST positions.

## Symbols and scope

Namespaces distinguish types, values, components, commands and events; ambiguous lookup is an error. Import resolution is explicit, deterministic and package-version pinned. Shadowing rules: local parameters/state may not silently shadow component ports; explicit qualified names disambiguate imported symbols. Unicode identifiers are compared under the language's NFC rules; duplicate normalized names fail. No implicit network imports.

## Typing and effects

Inference is local and bidirectional; exported public ports, state and command results require explicit types. Numeric literals receive context types only if exactly representable. There are no implicit narrowing, unit conversion, ownership conversion or stringification operations. Generics are constrained and monomorphized only when legal.

Pure expressions admit read-only inputs and pure functions. Calling a command, awaiting work, reading device I/O or blocking in a derived expression/layout is a compile-time effect error. Effects and target capabilities are checked separately: declaring an I/O effect does not authorize physical access. Commands resolve against typed contracts and required execution domains.

## Bindings, children and identity

Binding checker verifies resolved endpoints, read/write direction, type/units, unique writer policy, owner and scheduler domain, observable dependency tracking and synchronous cycle detection. Explicit asynchronous/delay boundaries may break cycles but require queue policy. Child slots enforce type/cardinality; static view keys are scope-unique. Dynamic keys require a later-defined collection syntax and stable identity semantics. Modifiers are type checked and order preserved.

## TypedHIR contract

TypedHIR nodes carry: resolved type ID, symbol ID, effect set, ownership category, source span, graph origin, target capability requirements and immutable dependency identities. TypedHIR must be semantically valid, but does not prescribe machine register layout or public binary ABI. Unresolved errors prevent lowering. Diagnostic ordering must be deterministic.

## Phase ordering and failure

1. Parse and recover syntax errors into diagnostics, without inventing semantically valid nodes.
2. Resolve imports, packages, declarations and stable type identities.
3. Resolve member/call/child-slot names; infer/check types and units.
4. Check effect permissions and command/task execution domain.
5. Build binding DAG, validate single writers and identity constraints.
6. Validate explicit ownership/transfer constraints at this level; hand off control-flow borrow proof to OwnershipIR.
7. Verify target capability requirements; emit TypedHIR only if hard errors absent.

Diagnostic envelope: stable error code, severity, span, graph ID if known, expected/actual, note and suggested correction. Editor-friendly recovery must not generate runnable output when errors remain.

## Acceptance fixtures

| Case | Expected |
| --- | --- |
| Text with String input and valid modifier | Typed ViewCall |
| Missing imported component | AUI_UNRESOLVED |
| NFC-normalized duplicate declaration | AUI_DUPLICATE_SYMBOL |
| U64 literal overflow | AUI_TYPE_MISMATCH |
| Readonly binding destination | AUI_BIND_READONLY |
| Two writers to one owned State | AUI_BIND_WRITER_CONFLICT |
| Pure derived expression dispatching Command | AUI_ILLEGAL_EFFECT |
| Task awaited from layout expression | AUI_AWAIT_CONTEXT |
| Unknown named child slot | AUI_CHILD_SLOT |
| Wrong target capability | AUI_TARGET_UNSUPPORTED |
| Borrow escaping across task suspension | OwnershipIR rejection, with original AST span |

## Design caveats

The source grammar still lacks fully defined event wiring, generic constraint syntax, operators and dynamic collections; AST variants for these are **provisional**. Finalize exact syntax and golden fixture outputs before declaring grammar or semantic analyzer stable. No parser, type checker or AST producer is running.


## Event attachment lowering (design candidate)

`ViewCall(...).on(activated: inspect)` lowers to an explicit `EventConnection(sourceViewIdentity, sourceEventSymbol, destinationEventSymbol, sourceSpan)` node. The semantic checker resolves `activated` in the view component's declared event outputs and `inspect` in the current component's event namespace; payload types must agree exactly. The `on inspect(payload) { send Inspect(); }` handler lowers separately to `EventHandler(eventSymbol, payloadBinder, CommandDispatch(Inspect))`. Neither node confers hardware permission. The command's implementation is linked through the Project Graph contract; an absent provider yields `AUI_COMMAND_UNLINKED`. See [Event and Binding Semantics](aui-event-binding-semantics.md). This contract remains proposed and unimplemented.

## L0/L1 AST/HIR subset (new design candidate)

[D3 First Language Profile](d3-first-language-profile.md) restricts initial AST to ImportDecl, ComponentDecl, InputDecl, EventDecl, CommandDecl, HandlerDecl, ViewCall, NamedArgument, ModifierCall, Literal/MemberPath and one SendCommand node. The source span is byte-exact and NFC-normalized symbol lookup preserves original text in CST. Handler EventConnection and GraphCommandLink nodes resolve only after [D3 Event Delivery](d3-event-delivery-and-command-linkage.md) verifies exact derived link-map identities. AUI TypedHIR never authorizes effects by itself. Existing broader AST/task/binding variants in this file remain D3+ unaccepted designs. [L0/L1 future test vectors](../../examples/aui-language/d3-first-profile-negative-cases.json) must be matched by real compiler output in Phase III.

## D3+ AST/HIR extension proposal

[L2 grammar](d3-state-derived-binding-contract.md) adds StateDecl, DerivedDecl, BindingDecl with statically keyed ViewPropertyRef, PureCall, CommitBlock and SetStmt. [L3 grammar](d3-task-result-lifecycle.md) adds TaskDecl, TaskSlot, SubmitStmt, AwaitStmt, ReturnResult, SettledHandler, exhaustive OutcomeMatch and typed arm payload bindings. They lower only after exact [source-to-Graph snapshot approval](d3-source-snapshot-reconciliation.md). Proposed TypedHIR carries StateSymbolID, ViewIdentity and generation, ownership/lifetime region, task slot and provider CommandTicket relation, nominal TaskOutcome variant and bounded effects. Source-span IDs never become persistent graph node IDs. No compiler, HIR verifier or native lowering was implemented in Phase I.

## D3+ AST/HIR extended candidate

[L2](d3-state-derived-binding-contract.md) adds StateDecl, DerivedDecl, static ViewPropertyRef, BindingDecl, CommitBlock and SetStmt. [L3](d3-task-result-lifecycle.md) adds TaskDecl, TaskSlot, SubmitStmt, AwaitStmt, SettledHandler and exhaustive typed OutcomeMatch. [Source reconciliation](d3-source-snapshot-reconciliation.md) must verify exact source profiles/hashes and graph bindings before emitting linked TypedHIR. No compiler or OwnershipIR verification is claimed.

## L4 source scope and TypedHIR candidate

[L4 Dynamic View Contract](d3-keyed-dynamic-view-lifecycle.md) adds a typed ForEach AST with List<T>, one immutable StableKey field, a lexical item scope and a stable TemplateSymbolID, lowered to a tagged keyed-child template in TypedHIR. Child positions and source spans are not persistent or runtime identity. The [source-link bundle schema](../../schemas/aui-source-link-bundle.schema.json) requires L4 templateSymbols for L4 sources, but semantic verification against the pinned core registry and approved source remains mandatory. A duplicate live sibling key fails AUI_KEY_DUPLICATE before reconciliation; runtime native outcomes are NOT-RUN.
