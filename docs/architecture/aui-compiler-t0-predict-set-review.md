# AELYXORA — Nested EBNF Predict-Set Review

**Status: REVIEW CALCULATION / NOT APPROVED / NOT A NATIVE COMPILER TEST.**

[Machine-readable report](../../examples/aui-compiler-production/t0-predict-set-review.json) computes LL(1)-style entry/exit prediction for the [formal candidate EBNF](../../schemas/aui-compiler-ebnf-ast-candidate.json), including **8 choice**, **18 optional**, and **21 repeat** decision sites. It found **three FIRST/FIRST overlaps**, with **no additional optional/repeat enter-vs-exit overlaps** under the current literal-terminal model.

| Site | Overlap | Proposed parser policy |
| --- | --- | --- |
| `sourceUnit` | `import` | Select immutable module kind before parsing; use corresponding start rule |
| `componentMember` | `on` | Look ahead for contextual `settled` to distinguish settledHandler from eventHandler |
| `pureExpr` | lexical ID | Parse qualified path and examine subsequent `(`; defer callable-vs-enum resolution to typed semantics |

These are **predict-set overlaps, not demonstrated ambiguous strings**. The choice site count and absence of extra overlaps do not prove full LL(1) compatibility because the model treats string literals as terminals without the final lexer/contextual keyword translation. FIRST/FOLLOW for nested nodes is conditional on the owning production FOLLOW, and the extraction has not been re-run by an independent committed checker.

## Mandatory follow-up

1. Fix the token translation table, especially identifier/contextual keywords and exact longest-match punctuation, without granting unused tokens.
2. Document lookahead paths and parser error synchronization by grammar production, including profile L0–L4 and component/contract modes.
3. Create an approved implementation-compatible deterministic parser table, or explicitly choose bounded recursive-descent with reviewed lookahead.
4. Commit a reproducible checker in approved project tooling; run differential/golden tests and native Assembly tests before marking results VERIFIED.
5. Ensure no T0 parse outcome can mint D2/D3/C9 trust or authorize T2.

The three existing overlaps remain **open sign-off items**, even where a candidate resolution exists. D1–D8 remain OPEN.
