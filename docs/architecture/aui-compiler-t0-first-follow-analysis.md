# AELYXORA — T0 Grammar FIRST/FOLLOW Analysis (review execution)

**Status: PROPOSED / STRUCTURAL ANALYSIS EXECUTED IN REVIEW ENVIRONMENT / NOT A NATIVE ASSEMBLY TEST / NOT APPROVED.**

[Machine-readable analysis](../../examples/aui-compiler-production/t0-grammar-static-analysis-candidate.json) derives from the [57-production EBNF AST](../../schemas/aui-compiler-ebnf-ast-candidate.json). An in-memory fixed-point calculation in the review environment completed nullable/FIRST convergence in **5 iterations**, FOLLOW propagation in **3**. It found **no nullable named productions and no left-recursive production** under the extracted grammar. The explicit choice-node FIRST/FIRST scan found **three overlaps**; this is not an exhaustive LL(1) proof and the analyzer itself is not yet a committed, independently replayable program.

| Production | Overlap | Required resolution |
| --- | --- | --- |
| sourceUnit | `import` | Explicit immutable component/contract mode determines root production; do not infer from imports |
| componentMember | `on` | Distinguish `on settled ...` from `on identifier(...)` using exact contextual lookahead |
| pureExpr | `ID` | Distinguish member path and named pure call from lookahead, then resolve enum constructor/callable using typed T1 evidence |

Some FIRST/FOLLOW results concern contextual literals that the tokenizer may emit as an identifier. These require a *lexer-to-parser terminal translation contract* before parser generation. The scan did not audit all optional/repeat decision sets and is not a proof that every parser branch has a deterministic one-token lookahead. Absence of left recursion is not absence of ambiguity, and successful document analysis does not establish native compiler correctness.

## P0 follow-up

1. Commit a reproducible verifier implementation using allowed project build tooling (no Python in project) with an input identity checksum and strict rejection rules.
2. Add exhaustive optional/repeat predict-set checks and lookahead decision tables, including contextual keyword handling.
3. Add profile-specific grammar admission, diagnostic golden fixtures and CST/AST/T1 coverage validation.
4. Establish native Win64 Assembly test evidence and obtain explicit D1–D8 human acceptance.

No T0 parser, Graph-linked build or executable is claimed.
