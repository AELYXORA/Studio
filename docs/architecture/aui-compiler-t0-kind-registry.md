# AELYXORA — T0 Closed Kind Registry and Syntax-to-TypedHIR Mapping

**Status: PROPOSED / NOT APPROVED / NOT IMPLEMENTED / NOT TESTED.** This supplements [T0 physical records](aui-compiler-t0-physical-contract.md). The sole grammatical authority is [AUI Syntax](aui-syntax.md) with the referenced profile-specific D3 L0–L4 owners. No grammar, public TypeID, Canonical Graph or user-facing ABI is created here.

## K0. Registry principles

Kind fields in TokenV1/CstNodeV1/AstNodeV1 are u16, with 0 invalid. Numeric assignments below are stable **candidates** within this document, not signed or accepted contracts. Unknown kinds fail closed; old unknown high numeric values are not silently treated as Identifier. Do not classify feature admission by token kind alone: parser position, explicit profile and module kind determine legitimacy. Contextual words may tokenize as Identifier and be checked against raw spelling at the specific production; semantic identifiers resolve after Unicode 15.1 NFC. Distinguish minus punctuation from the exact `->` and `<-` longest matches.

## K1. Token registry (candidate)

| Range | Kind IDs and names |
| --- | --- |
| 1–4 | 1 Identifier, 2 IntegerLiteral, 3 StringLiteral, 4 EOF |
| 16–35 | 16 LeftParen, 17 RightParen, 18 LeftBrace, 19 RightBrace, 20 LeftAngle, 21 RightAngle, 22 Dot, 23 Comma, 24 Colon, 25 Semicolon, 26 Equals, 27 At, 28 Minus, 29 ArrowRight, 30 ArrowLeft, 31 FatArrow, 32 Plus, 33 Slash, 34 Star, 35 Question |
| 64–88 | 64 import, 65 component, 66 input, 67 output, 68 event, 69 command, 70 on, 71 effects, 72 state, 73 derived, 74 bind, 75 using, 76 task, 77 taskSlot, 78 await, 79 submit, 80 settled, 81 match, 82 matchEnum, 83 case, 84 send, 85 return, 86 let, 87 set, 88 commit |
| 89–105 | 89 record, 90 enum, 91 service, 92 true, 93 false, 94 ForEach, 95 in, 96 key, 97 value, 98 item, 99 as, 100 when, 101 cancel, 102 Result, 103 Event, 104 List, 105 TaskSlot |

**Important:** listed keyword-looking entries are an exhaustive *review candidate vocabulary*, **not a claim that each spelling is reserved or even a valid production in every profile**. The lexical implementation must use one explicit contextual-word policy; values `Result/Event/List/TaskSlot` are names resolved by grammar and type rules, not privileged types based on lexical capitalization. Unknown or unused speculative entries (e.g. `when`, `cancel`, `as`) must be marked **UNMAPPED** and removed or given an owned grammar production before acceptance, not silently admitted. Punctuation entries `+`, `/`, `*`, `?` likewise require an owned production or explicitly reject as unsupported. Do not implement the table as an unreviewed blanket keyword reservation.

Trivia kinds: 1 ASCIIWhitespace, 2 LineComment; reserve 0 invalid. Block comments are not admitted merely by a trivia kind.

## K2. CST kind registry (candidate)

| Range | Kinds |
| --- | --- |
| 256–262 | 256 SourceModule, 257 ContractModule, 258 ImportDecl, 259 QualifiedName, 260 ProfileClause, 261 VersionSuffix, 262 TypeRef |
| 272–284 | 272 ComponentDecl, 273 ServiceDecl, 274 RecordDecl, 275 EnumDecl, 276 EnumVariant, 277 FieldDecl, 278 ParameterList, 279 NamedParameter, 280 TypeArgumentList, 281 CommandDecl, 282 EventDecl, 283 HandlerDecl, 284 EffectList |
| 288–303 | 288 StateDecl, 289 DerivedDecl, 290 BindDecl, 291 TaskDecl, 292 TaskSlotDecl, 293 SubmitStmt, 294 SettledStmt, 295 AwaitStmt, 296 SendStmt, 297 ReturnStmt, 298 LetStmt, 299 SetStmt, 300 CommitStmt, 301 MatchOutcome, 302 MatchEnum, 303 CaseArm |
| 320–335 | 320 ViewExpr, 321 ViewChildren, 322 ViewModifier, 323 NamedArgList, 324 NamedArg, 325 MemberPath, 326 PureCall, 327 LiteralExpr, 328 EnumConstruct, 329 ForEachView, 330 KeyModifier, 331 ParenthesizedExpr, 332 BooleanExpr, 333 Block, 334 EffectAtom, 335 DomainAtom |
| 352–354 | 352 MissingRecovery, 353 ErrorRecovery, 354 SkippedRecovery |

CST recovery kinds **cannot** be admitted to T1 and must be distinguished from authored syntax.

## K3. AST kind registry (candidate)

| Range | Kinds |
| --- | --- |
| 512–519 | 512 Module, 513 ContractModule, 514 Import, 515 TypeRef, 516 QualifiedSymbol, 517 GenericApplication, 518 RecordType, 519 EnumType |
| 520–531 | 520 EnumVariant, 521 Component, 522 ServiceInterface, 523 Parameter, 524 Field, 525 Operation, 526 Event, 527 Handler, 528 State, 529 Derived, 530 Binding, 531 Task |
| 532–544 | 532 TaskSlot, 533 Submit, 534 Settled, 535 Await, 536 Send, 537 Return, 538 Let, 539 Set, 540 Commit, 541 OutcomeMatch, 542 EnumMatch, 543 MatchArm, 544 View |
| 545–555 | 545 ViewModifier, 546 NamedArgument, 547 MemberAccess, 548 PureCall, 549 Literal, 550 EnumConstructor, 551 ForEach, 552 StableKeyExpr, 553 EffectSet, 554 Domain, 555 ErrorRecovery |

AST ErrorRecovery is diagnostic-only and forbids a successful T0 receipt.

## K4. Required syntax → AST → T1 handoff

| Authoritative grammar family | T0 CST | T0 AST | T1 expected semantic output / validation |
| --- | --- | --- | --- |
| imports / qualified names | ImportDecl / QualifiedName | Import / QualifiedSymbol | Exact captured source and lock-dependent resolution; no implicit trust |
| component / inputs / view | ComponentDecl / NamedParameter / ViewExpr | Component / Parameter / View | Typed component, arguments, source owner and view signatures |
| event / command / on handler | EventDecl / CommandDecl / HandlerDecl | Event / Operation / Handler | Typed event routing, effects/domain, provider **unverified** |
| state / derived / bind / commit | StateDecl / DerivedDecl / BindDecl / CommitStmt | State / Derived / Binding / Commit | Pure dependencies, single writer, atomic transaction semantics |
| taskSlot / submit / await / settled | TaskSlotDecl / SubmitStmt / AwaitStmt / SettledStmt | TaskSlot / Submit / Await / Settled | Valid typed task lifecycle and five-way TaskOutcome |
| dynamic ForEach / key | ForEachView / KeyModifier | ForEach / StableKeyExpr | Valid L4 source identity; no runtime positional identity |
| record / enum / service contracts | RecordDecl / EnumDecl / ServiceDecl | RecordType / EnumType / ServiceInterface | Candidate public type/operation mapping; no generated trust |
| enum construction / matchEnum | EnumConstruct / MatchEnum / CaseArm | EnumConstructor / EnumMatch / MatchArm | Exact variant payload and exhaustive pure type checking |
| generic typeRef | TypeRef / TypeArgumentList | TypeRef / GenericApplication | Bounded nested type resolution with no fabricated digest |

This is a **family mapping**, not yet a full production-by-production enumeration of every alternative in the integrated EBNF. The required implementation closure is one row per grammar production and alternative, including each profile and explicit reject path. No coverage percentage or complete parser readiness should be claimed from this table.

## K5. Exhaustiveness protocol

Before a token registry may be approved:
1. Extract every terminal and production from the single integrated grammar and each active profile extension, recording owner and exact revision.
2. Map every terminal to a token kind or a documented contextual-Identifier rule; map every production alternative to CST and, if semantically meaningful, AST kind.
3. Mark intentional non-AST syntax (punctuation, grouping, trivia) as `CST_ONLY`, not missing.
4. For every AST kind specify exact T1 consumer or `REJECT_RECOVERY`; ensure every T1 required source shape has a producer.
5. Mark all candidate registry items with no corresponding authoritative grammar occurrence as `UNMAPPED` and reject them pending review.
6. Require a generated static cross-table validation check and golden positive/negative source fixtures. No generic default handler silently drops constructs.
7. Preserve original token/trivia byte coverage, spans, and deterministic normalization when projecting CST to AST.

**P0 unresolved:** exact normative per-production grammar parse table; token contextual/reserved-word policy; all keyword and punctuation coverage (including prospective entries above); native byte offsets, feature-specific negative cases, native T0→T1 pass and compiler sign-off.

**No compiler, lexer, parser or native test is claimed.**
