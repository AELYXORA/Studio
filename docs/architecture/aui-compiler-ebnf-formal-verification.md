# AELYXORA — Formal EBNF Tree and T0 Grammar Verification Gate

**PROPOSED / NOT APPROVED / NOT IMPLEMENTED / NOT NATIVE-TESTED.**

The [machine-readable grammar tree](../../schemas/aui-compiler-ebnf-ast-candidate.json) is an explicit structural extraction from the active component and contract EBNF under [the single AUI Syntax owner](aui-syntax.md). It contains 57 named productions with recursive `sequence`, `choice`, `optional`, `repeat`, `literal`, and `symbol` operators. The only external lexical symbols detected are `EOF`, `ID`, `INT`, and `STR`; punctuation and keyword spellings are literal terminals. It is not a parser implementation or a claim of unambiguous grammar.

## Exact structural contract

- `sequence.items`: concatenated in source order; empty sequences, if ever introduced, require an explicit epsilon contract.
- `choice.items`: one alternative; first-match resolution is **not** assumed and requires a separate precedence/lookahead proof.
- `optional.item`: zero or one occurrence.
- `repeat.item`: zero or more occurrences; nullable repeats MUST be rejected by grammar verifier to prevent non-progress loops.
- `literal.value`: exact ASCII spelling; a contextual keyword can still be represented as an ID token with context-dependent spelling match.
- `symbol.name`: resolves to exactly one production or an approved lexer terminal. Unknown symbols reject.

## Required machine verification

1. Verify unique production IDs and names, valid operator shape, bounded AST node count and references closed over the production table plus exactly reviewed lexer symbols.
2. Calculate nullability and FIRST/FOLLOW sets to a fixed point with bounded iteration. Detect nullable repetitions and left recursion (including indirect through nullable prefixes).
3. Report FIRST/FIRST and FIRST/FOLLOW intersections as **parse decision review items**; reject unsafe parser generation unless lookahead, precedence or context rules are explicitly proven.
4. Verify each component and contract root reaches EOF, that incorrect module kind fails, and that no token or syntax tree branch can be silently skipped.
5. Reconcile every literal/contextual word with candidate numeric token kinds and source-context policies; reject unmapped speculative punctuation.
6. Link each grammar branch to exact CST/AST kind and T1 verifier, profile L0–L4 gate, deterministic error code and source fixture. Family-level mappings alone are insufficient.
7. Re-extract the EBNF tree after any owning grammar edit and compare structural identity; never treat a stale generated JSON as grammar authority.

## Discovery and correction

During this extraction, the older flat registry was found to have appended the separate `serviceInterface` production to `enumCase` because the grammar used a line break before `=`. The flat entry has been repaired; this is a **documentary consistency correction**, not native verification.

## Current blockers

Complete machine-checked parser lookahead decisions, precise lexical-context policy, profile masks and stable diagnostics, numeric kind reconciliation, test generator, verified core/public type contracts and actual assembler parser remain **OPEN**. The full EBNF tree closes only *structural representation*, not semantic or executable language completeness. D1–D8 remain OPEN.
