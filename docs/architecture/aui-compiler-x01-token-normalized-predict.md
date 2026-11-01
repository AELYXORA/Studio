# AELYXORA — X01 Token-Normalized Predict Review

**Status: REVIEW CALCULATION, NOT NATIVE OR APPROVED.** The [computed report](../../examples/aui-compiler-production/x01-token-normalized-predict-review.json) remaps the 57-production [EBNF candidate](../../schemas/aui-compiler-ebnf-ast-candidate.json) using the [candidate lexer numeric/token table](../../schemas/aui-compiler-t0-token-binding-candidate.json). Contextual identifier literals become `ID:spelling`, and general ID becomes `ID:*`; these overlap for prediction unless an exact-spelling parser guard is explicitly proven.

The review finds **three overlapping decision sites**, the same as in the literal-terminal analysis: `sourceUnit` on numeric token 64 (import); `componentMember` on numeric token 70 (on); `pureExpr` on generic identifier. No additional optional/repeat conflicts were found in this review model. This does **not** establish LL(1) parser correctness, because ordinary ID use versus fixed-keyword positions, lexical mode, contextual spelling and complete fixture coverage are not native-verified.

| Conflict | Candidate decision | Acceptance gate |
| --- | --- | --- |
| sourceUnit/import | Select explicit immutable module kind | Both root modes with identical import prefix |
| componentMember/on | Guard second token for fixed keyword settled=80, otherwise legal event ID | Malformed settled handler rejects without fallback |
| pureExpr/ID | Consume bounded qualified-name prefix; next token `(` selects syntactic call | Member/call and enum meaning disambiguated by actual T1 types |

**X01 remains OPEN.** To close it: fix and approve complete lexer keyword/identifier classification, reconcile every token ID, run replayable token-normalized analysis and **native** tokenizer fixtures, and verify all L0–L4 source contexts, UTF-8 source spans, punctuation and unsupported tokens. A report JSON is local review evidence only and cannot mint a T0 successful pass or trusted Graph linkage.
