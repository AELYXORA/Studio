# AELYXORA — T0 Grammar Coverage Audit and Production-to-IR Obligations

**PROPOSED / AUDIT ONLY — NOT ACCEPTED, NOT IMPLEMENTED, NOT-RUN.** Read alongside [single integrated syntax owner](aui-syntax.md), [candidate T0 kinds](aui-compiler-t0-kind-registry.md), [T0 physical contract](aui-compiler-t0-physical-contract.md) and [T1 semantic owner](aui-ast-semantic-analysis.md). The *integrated candidate grammar* section of the syntax owner is the baseline; the older introductory illustrative EBNF does not override it.

## G0. Scope and definition of completion

A syntax production is **covered** only if its grammar owner and exact text revision are pinned; every alternative has a tokenization and disambiguation path, CST representation, AST projection or explicitly CST_ONLY decision, profile/module-kind admission, deterministic diagnostic for rejection, and a named T1 consumer or T0-only use. A family-level crosswalk **does not** satisfy this. There are no implementation coverage figures today.

## G1. Component source production crosswalk (review obligations)

| Grammar production(s) | CST candidate | AST candidate | T1 obligation / unresolved nuance |
| --- | --- | --- | --- |
| sourceUnit, componentModule | SourceModule | Module | Profile and module-kind fixed by compilation request; EOF required |
| componentDecl, componentMember | ComponentDecl plus declaration child | Component | One root static View, ordered declarations, duplicate NFC symbol gate |
| importDecl, qualifiedName | ImportDecl, QualifiedName | Import, QualifiedSymbol | Ordered imports; exact lock identity not fabricated |
| inputList, inputDecl | ParameterList, NamedParameter | Parameter | Exact input logical TypeReference and scope |
| eventDecl | EventDecl | Event | Event payload type, no implicit dispatch |
| commandDecl, commandParams, commandParam | CommandDecl, ParameterList, NamedParameter | Operation, Parameter | Exact Result success/failure, effect and domain, unresolved provider no native authority |
| effectList, effectAtom, domainAtom | EffectList, EffectAtom, DomainAtom | EffectSet, Domain | Enumerated effects/allowed domain; `-` only within declared atoms |
| eventHandler, sendStmt | HandlerDecl, SendStmt | Handler, Send | Exact named payload, one allowed action, L1+ |
| stateDecl, derivedDecl, bindDecl | StateDecl, DerivedDecl, BindDecl | State, Derived, Binding | Pure dependency DAG, single binding writer, L2+ |
| stateCommit, setStmt | CommitStmt, SetStmt | Commit, Set | Atomic transaction; no partial state publication |
| taskSlotDecl, taskDecl | TaskSlotDecl, TaskDecl | TaskSlot, Task | Explicit typed slot, one await and return; L3+ |
| awaitStmt, returnStmt, submitStmt | AwaitStmt, ReturnStmt, SubmitStmt | Await, Return, Submit | Typed continuation and provider admission |
| settledHandler | SettledStmt, MatchOutcome | Settled, OutcomeMatch | Five fixed ordered arms, not generic enum match |
| successArm/failureArm/rejectArm/cancelledArm/unavailableArm | CaseArm per arm | MatchArm per arm | Exact branch meaning, binder scope, exhaustive TaskOutcome |
| rootView, staticView, childView | ViewExpr, ViewChildren | View | Static root; child restrictions depend on constructor |
| dynamicView | ForEachView | ForEach | L4 only, exact `item` binding and stable path |
| modifier, modifierName | ViewModifier, KeyModifier where applicable | ViewModifier / StableKeyExpr | Key is source identity, not runtime StableKey; validate owner and cardinality |
| namedArgs, namedArg | NamedArgList, NamedArg | NamedArgument | Exact labels, duplicates forbidden, no positional args |
| pureExpr, pureAtom, memberPath | LiteralExpr, MemberPath | Literal, MemberAccess | Pure typing, context-specific allowed variants |
| pureCall | PureCall | PureCall or EnumConstructor | Resolve by imported type/signature, not capitalization |
| enumMatchExpr, enumMatchArm | MatchEnum, CaseArm | EnumMatch, MatchArm | Pure exhaustive enum match L2+, not TaskOutcome |
| typeRef | TypeRef, TypeArgumentList | TypeRef, GenericApplication | Nested generic bounds, TypeReference semantic gate |
| viewName | ViewExpr terminal use | View | Exact constructor resolution |

CST-only tokens include punctuation, delimiters, `EOF`, grouping and trivia. Such material must remain in lossless CST/source coverage but need not become standalone AST nodes. Recovery CST/AST nodes are diagnosis-only and must block T0 success.

## G2. Contract module crosswalk (separate explicit module kind, same grammar/type definitions)

| Family | CST / AST | Obligation |
| --- | --- | --- |
| contractModule | ContractModule / ContractModule | Explicit compilation mode, no UI component body |
| record declaration and fields | RecordDecl, FieldDecl / RecordType, Field | Ordered fields, verified TypeReferences, by-value cycle rejection |
| enum declaration and variants | EnumDecl, EnumVariant / EnumType, EnumVariant | Ordered cases and optional single typed payload; export remains unverified |
| service interface declaration | ServiceDecl, CommandDecl / ServiceInterface, Operation | Exact existing nonvisual component/operation mapping; no synthetic service type |
| shared importDecl/typeRef/commandParams/effectList/domainAtom | Existing same kinds | Must reuse component-module parser/type rules; no second private syntax |
| native service implementation | No permitted grammar | Explicit rejection; cannot synthesize provider |

**BLOCKER:** Pin the complete contractModule EBNF *verbatim* from its owning section into a machine-readable production registry with line/source anchors. The crosswalk above is not proof of alternative-level coverage.

## G3. Concrete inconsistencies and closure decisions required

- **Registry overreach:** Candidate T0 token IDs 32 Plus, 33 Slash, 34 Star, 35 Question and contextual `when`, `cancel` have no accepted production in the integrated grammar. Mark `UNMAPPED_REJECT`, not valid syntax or implicit operators. Verify other prospective tokens (`in`, `as`, `item`, `value`) in their exact grammar contexts.
- **Reserved/contextual ambiguity:** `Result`, `Event`, `List`, `TaskSlot` are TypeReference symbols in some contexts, not unconditionally reserved lexical tokens. The lexer must not reject them as identifiers in unrelated admissible positions until an explicit lexical policy is approved.
- **Outcome arms:** `Successful`, `Failed`, `AdmissionRejected`, `Cancelled`, `ProviderUnavailable` are exact spelling terminals in settledHandler grammar, but the prior candidate token table did not allocate them separately. Either recognize as contextual Identifier with exact parser matching or allocate reviewed tokens. The choice must be explicit and testable.
- **Token naming confusion:** `TokenV1` token categories include keyword-like codes and literal identifiers; the parser must have a formal policy that prevents a keyword-like code from silently changing an identifier in named argument labels.
- **L0–L4 features:** It is incorrect to claim all listed AST kinds are admitted in all profiles. Every row needs minimum profile and an explicit wrong-profile diagnostic.
- **Enum constructor ambiguity:** `qualifiedName(...)` may be a pureCall or payload enum constructor; T1 resolves via exact type/export, never by initial capital letter.
- **T0↔T1 trust:** A structurally correct AST cannot mint verified public types, Graph approvals or service permission.
- **Physical node collisions:** Candidate CST/AST kind IDs and T1 tags inhabit separate typed descriptor namespaces, regardless of overlapping u16 values.

## G4. Completion matrix required before freeze

For every production alternative, store:
`productionId, grammarOwner, grammarRevision, alternativeId, terminals, contextualTokens, profileMask, moduleKind, cstKind, astKindOrCST_ONLY, t1ConsumerOrT0_ONLY, diagnostics, positiveFixture, negativeFixture, state`.

Allowed states: `MAPPED_PROPOSED`, `UNMAPPED`, `CONFLICT`, `APPROVED`, `IMPLEMENTED_TESTED`. Never move to `APPROVED` merely by adding a document, nor to `IMPLEMENTED_TESTED` without native evidence. A production ID must not be reused for different text after a grammar revision. A schema/fixture listing must be generated and reviewable independently from a source file compiler that is still unimplemented.

## G5. Mandatory negative fixture families

Unknown token, unsupported punctuation, keyword in wrong context, malformed two-character arrow, no EOF, invalid profile, missing static root, empty view children, invalid L0 handler, duplicate binding writer, state cycle, TaskOutcome arm missing/duplicate/reordered, mis-scoped `item`, invalid nested generic, wrong record/enum/service module kind, unauthorized native service implementation, wrong enum payload, duplicate case, ambiguous qualified call, AST kind lacking T1 consumer. Each test must demonstrate a deterministic reject and no successful T0/T1 receipt.

## G6. Current gate

**PARTIAL DESIGN COVERAGE ONLY.** No complete enumerated machine-readable alternatives table, semantic parser, native code, or proven exhaustive 139-tag lowering is asserted. Freeze requires grammar owner sign-off, removal/explicit handling of every UNMAPPED item, machine-readable full production registry, executable coverage checker in approved tooling, real T0→T1 test corpus, and review of source/Graph/type trust. D1–D8 remain OPEN.
