# AELYXORA — X01 Lexer Kind Reconciliation, First Concrete Closure Artifact

**Status: PROPOSED / PARTIAL / NO NATIVE TEST OR APPROVAL.** This works within the [one language grammar](aui-syntax.md) and [existing T0 candidate numeric kinds](aui-compiler-t0-kind-registry.md), without introducing a new token namespace. Its [machine-readable table](../../schemas/aui-compiler-t0-token-binding-candidate.json) enumerates the **60 distinct literal terminals** currently present in the [formal EBNF AST](../../schemas/aui-compiler-ebnf-ast-candidate.json), and maps them to proposed token IDs or contextual-Identifier matches. The four external lexical symbols ID/INT/STR/EOF are mapped separately. These are **literal inventories, not complete lexical tests**.

## X01.1 Candidate dispatch

- Punctuation recognizes exact single tokens and the longest-match `->`, `<-`, `=>`. The slash starts a `//` comment only under the source lexer rule and never enables division.
- Fixed keywords receive proposed numbered IDs only in grammar-approved contexts. Any fixed-keyword policy must be checked for collisions with identifiers allowed as named argument labels.
- Contextual entries `Result`, `Event`, `TaskSlot`, the five TaskOutcome arm names, `view`, `item`, `items`, `value` use `Identifier=1` with exact spelling checks in owning productions. This does **not** change their eventual T1 nominal type resolution.
- Numeric codes for `+`, `/`, `*`, `?`, `when`, `cancel` and unsupported or globally reserved interpretations of `Result/Event/List/TaskSlot` are candidate **UNMAPPED_REJECT_OR_RECLASSIFY**, not language features.
- `@ version` exists only in an older illustrative grammar; unsupported in integrated component/contract source.
- `output` is also absent from the integrated grammar (which uses only `input` on component parameters). Do not enable it based on older examples.

## X01.2 Remaining explicit conflicts before closure

1. **Candidate policy selected, not approved:** `settled` is fixed numeric keyword ID 80 (as in the integrated syntax keyword list). Its *syntactic use* is context-gated to `on settled` at L3+; malformed `on settled` never falls back to an ordinary event handler. Numeric class versus parser-context admission are distinct. Native token tests and normalized Predict Sets are still required.
2. `key`, `in`, `as`, `items` and `ForEach` require exact scoped keyword policy for L4, particularly named argument labels; grammar literal presence does not imply global reservation.
3. Unused numeric codes must be **retired or explicitly reserved, not interpreted**; unknown values and unsupported spelling reject. The current `unownedCandidateCodes` list is a review queue, not proof of exhaustive unused-token detection.
4. Every literal-to-token join must be validated against the actual token encoder and per-profile parser tests. None exist yet.
5. Exact keyword-vs-identifier behavior must be reconciled with Unicode/NFC collision policy and stable diagnostic IDs.

## X01.3 Next acceptance evidence

A standalone approved native lexer must emit a token stream whose codes match this table for every literal and contextual use, reject all unsupported codes, preserve exact original byte spans, and demonstrate expected L0–L4 rejection or acceptance in golden fixtures. An independently replayable checker must verify the EBNF literal coverage after token normalization.

**X01 remains OPEN**; this artifact advances the concrete mapping but neither asserts approval nor changes the architecture or D1–D8 gates.

## X01.4 Focused review fixtures (all NOT-RUN)

[16 lexical/context fixtures](../../examples/aui-compiler-production/x01-lexer-context-fixtures.json) cover `on settled`, L0–L4 admission, contextual type/field names, operator rejection and string boundaries. They are fragment scenarios, not full-module successful compiler evidence. The table now makes `settled` fixed keyword 80, while five TaskOutcome arm labels and `Result/Event/TaskSlot` remain Identifier 1 exact-context matches. **X01 stays OPEN** until an independent native lexer verifies this policy and terminal-normalized Predict Sets.
