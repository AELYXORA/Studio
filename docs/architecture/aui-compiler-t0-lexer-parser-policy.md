# AELYXORA — T0 Lexer-to-Parser Contract and Deterministic Dispatch

**Status: PROPOSED / NOT APPROVED / NOT IMPLEMENTED / NO NATIVE TEST.** Subordinate to [one AUI Syntax owner](aui-syntax.md), [T0 kind registry](aui-compiler-t0-kind-registry.md), [physical T0 ABI](aui-compiler-t0-physical-contract.md) and [Predict Sets review](aui-compiler-t0-predict-set-review.md). No new language, graph or public ABI is introduced.

## LP0. Lexical authority

Capture exact strict UTF-8 and original byte spans; normalize **identifier identity** using pinned Unicode 15.1 NFC only when resolving names. The token stream must not mutate original spelling or normalize String values. The lexer recognizes longest-match multi-character `->`, `<-`, `=>` before single-character punctuation. The minus token is legal only as a separator in a parsed effect/domain atom; it is not general arithmetic. Comments are line-only `//`; no block comments, interpolation or unowned operators.

The lexer assigns either a **fixed structural keyword** or an Identifier with original text, following a closed classification table reconciled against the existing syntax owner. A keyword-like registry name does NOT establish syntactic admission. `Result`, `Event`, `List`, `StableKey`, `TaskOutcome`, `TaskSlot` are type-name spellings resolved in a type position, not globally hardcoded types. `view`, `item`, `value`, `activated` and the five TaskOutcome names `Successful`, `Failed`, `AdmissionRejected`, `Cancelled`, `ProviderUnavailable` require exact **parser-context spelling matches**; they must not be reserved across all identifier positions without revising the syntax owner. `settled` is syntactically privileged only immediately following `on` in an L3+ settledHandler production; otherwise it cannot silently enable a handler or feature.

The candidate kind table currently contains speculative entries (`Plus`, `Slash`, `Star`, `Question`, `when`, `cancel`). These are **UNMAPPED_REJECT**, not accepted operators or keywords. Explicit table reconciliation remains a P0 gate.

## LP1. Parser entry and lookahead decisions

1. The compilation request supplies explicit immutable `moduleKind=component|contract` and `profile=L0|L1|L2|L3|L4`. Parse imports through the shared production, then dispatch to the selected module-specific root. Never infer module kind from the first declaration or automatically upgrade a profile.
2. At `componentMember`, after `on`, use a bounded 2-token decision (`on` plus next token spelling) to recognize the L3 `settledHandler` prefix; otherwise use `eventHandler` if a legal identifier follows. If the source uses `on settled` but fails the settled grammar, **reject**, do not reinterpret it as an ordinary event handler.
3. For `pureExpr`, consume a syntactically valid qualified-name prefix segment-by-segment under the grammar nesting budget; if next token is `(`, parse `pureCall`, otherwise parse `memberPath`. The lookahead is one token **after the bounded qualified prefix**, not a universal fixed two-token lookahead from expression start. T1 resolves pure function versus payload enum constructor, or field read versus zero-payload enum constructor, using verified types.
4. In typeRef position, `<` opens generic arguments only after a complete qualified type name. No shift or comparison operators are invented. An unbalanced or invalid type argument list rejects.
5. Parse `matchEnum` by its exact keyword in L2+ expression context; L3 `match` TaskOutcome is a separate syntax path with five exact tags.
6. Follow EBNF optional/repeat Predict Sets for entry/exit, with a progress check that forbids a repeat iteration consuming zero tokens. A deterministic parser is proposed as bounded recursive descent, with reviewed explicit conflict dispatch rather than silent precedence.

## LP2. Feature admission and error semantics

Profile checking is a **semantic admission layer** on top of syntax: L0 static views only, L1 events/commands, L2 state/derived/bind/commit, L3 task/slot/await/submit/settled, L4 dynamic ForEach. Wrong-profile but recognized constructs produce `AUI_PROFILE_UNSUPPORTED` rather than being silently consumed. Contract module disallows executable service bodies and component-root views; component module disallows top-level record/enum/service declarations.

The parser must consume full input through EOF, preserve byte-accurate CST, retain trivia, preserve all authored arguments and detect duplicate labels. Syntax recovery is diagnostics-only: after recovery, a successful T0 receipt or T1 handoff is forbidden. Return deterministic stable categories and original byte spans, respect bounded diagnostics, and treat budget exhaustion as an error, never as partial compilation.

## LP3. Required fixtures (NOT-RUN)

| Case | Expected |
| --- | --- |
| `import aui.core; component ...` with component mode | Component root parses; link remains untrusted |
| Same imports with contract mode but component declaration | Wrong module kind reject |
| `on settled slot(x) { match ... }` in L3 | Settled handler path |
| `on settled(...)` malformed | Reject; no fallback to ordinary eventHandler |
| `owner.value` versus `owner.compute(value: x)` | Member path versus call, with T1 semantic resolution |
| `Result<Row, Error>` in type position | Nested type parser, exact T1 template gate |
| `a - b` in pure expression | Reject unsupported arithmetic |
| `effects(device-read)` or `on io-worker` | Accept structural atom segmentation; effect/domain semantic admission separate |
| String containing `on settled` or `//` | No special tokens inside string |
| L0 `taskSlot`, L1 `state`, L3 `ForEach` | Profile rejection |
| Trailing token after valid root | Reject before sealing |
| EOF after incomplete punctuation/quote, wrong Unicode, overbudget | Controlled diagnostic; zero successful output refs |

## LP4. Go/no-go

Before a parser architecture is accepted: reconcile numerical tokens against precise literal/contextual spelling, create lookahead decision tables and executable replayable verifier, calculate FIRST/FOLLOW after terminal normalization, exercise all EBNF nested choice/optional/repeat branches, freeze stable diagnostics, and demonstrate native Win64 GAS/LLVM parser tests. No document is permission to move UNVERIFIED_SOURCE_ONLY into GraphLinkedIR or generate a trusted executable. Human D1–D8 acceptance remains OPEN.
