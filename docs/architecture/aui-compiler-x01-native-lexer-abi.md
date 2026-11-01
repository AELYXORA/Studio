# AELYXORA — X01 Native Lexer ABI and Golden Byte Contract

**Status: DESIGN CANDIDATE / NOT ACCEPTED / NOT IMPLEMENTED / NOT NATIVE-TESTED.** The existing [T0 physical contract](aui-compiler-t0-physical-contract.md) owns TokenV1 (48 bytes), TriviaV1 (32 bytes), SourceUnitV1 (64 bytes), and SourceSpanV1 comes from [IAI-v1](aui-compiler-internal-assembly-abi.md). Do not create alternate layouts. [Numeric token candidate](../../schemas/aui-compiler-t0-token-binding-candidate.json) is authoritative only as a proposed join, subordinate to [the language syntax owner](aui-syntax.md).

## LX1. Bounded native call

Proposed `u32 LexerScan(CompilationContextV1* ctx, PassRequestV1* req, PassReplyV1* out)` under the **existing** Win64 ABI/IAI-v1 pass shape; `passId` is T0 only after the reviewed numeric pass registry is approved. This is NOT a working symbol. RCX/RDX/R8 refer to host-pinned call records, not user source pointers. Inputs: immutable captured original source unit and approved Unicode/token policy. Outputs on success: immutable token/trivia arrays and source span indexes in a sealed T0-private arena; **this partial lexer success alone cannot produce a successful T0 proof** because CST/AST and parser checks remain pending. Therefore a standalone lexer validation command must return a checker-local report, not `PassReply.PASS` or `outputProofRef`.

## LX2. Exact token and trivia physical requirements

`TokenV1`: tokenId u64@0, sourceUnitId u64@8, startByte u64@16, endByte u64@24, kind u16@32, profileMask u16@34, flags u32@36, valueRef Ref64@40. The candidate numeric kind determines an exact terminal spelling or a valid identifier/literal class; `profileMask` is **not** evidence that the parser approved the construct. The lexer does not invent a type, Graph ID or capability. The byte interval points into original input (not normalized decoded storage). `valueRef` is zero when no decoded value is required; when present it must resolve to a checked immutable typed pool value. Canonical token IDs are compiler-local and not required to equal byte offsets.

`TriviaV1`: sourceUnitId u64@0, startByte u64@8, endByte u64@16, kind u16@24, flags u16@26, reserved u32@28=0. Trivia kind 1 is ASCII whitespace, 2 is // line comment. Original bytes of whitespace and comments are not rewritten. A comment consumes the `//` delimiter and contents through *before* LF; LF belongs to whitespace trivia. Tokens plus trivia partition all source bytes exactly once. EOF is exactly one zero-width token at `[n,n)`; no trailing implicit NUL.

## LX3. Classification and rejection precedence

1. Check context, source byte length, immutable arena lease and complete strict UTF-8 (including BOM, NUL, overlong forms and surrogate rejection) before publication; raw source identity is computed before identifier normalization.
2. Longest-match `->`, `<-`, `=>`; ASCII punctuation from approved numeric table. For slash, only exact `//` line-comment opening is admitted, never division or block comments.
3. ASCII keywords are case-sensitive according to the one syntax owner. `settled` uses candidate fixed token 80, but **only its parser context** admits `on settled` in L3+. `Result/Event/TaskSlot`, fixed outcome arm names, `view/item/items/value` are exact-spelling Identifier(1) contexts. Never globally reserve an unreviewed keyword.
4. ID uses pinned Unicode 15.1 XID_Start/XID_Continue, NFC only for symbol identity; original source byte offsets and raw spelling remain unchanged. Strings decode escapes with no NFC; decimal integers use the reviewed strict range and grammar.
5. Unterminated strings, invalid Unicode escape/surrogate, disallowed whitespace, unowned operators and resource overflow reject deterministically. Syntax-profile diagnostics may follow lexing but malformed UTF-8 takes priority.
6. Failure returns no successful token publication/lease. Error diagnostics preserve exact original byte intervals; no partial valid stream masquerades as success.

## LX4. Golden-vector contract

[Candidate golden vectors](../../examples/aui-compiler-production/x01-lexer-golden-vectors.json) provide **literal UTF-8 source bytes as hex**, expected token kind and half-open byte offsets, trivia offsets, and expected rejection class. These are **review fixtures, NOT-RUN**. A native run must compare every kind, start/end, raw byte partition, EOF and rejection, then separately compare TokenV1 and TriviaV1 exact binary struct layout, Ref64 resolution and arena sealing. Pointer/ref IDs, pool allocation location, profileMask and flags remain unapproved until frozen; therefore the current fixtures deliberately do **not** forge full 48-byte struct serialization.

## LX5. Native acceptance gates

Golden UTF-8/Unicode/CRLF/comment coverage, lexical numeric kinds, contextual keywords, longest-match arrows, invalid bytes, negative overflow and memory faults; ABI record sizes/alignments; generation-safe Ref64, checked span strides, deterministic output and zero output on failure. Tests MUST run against real Windows x64 Assembly binary built using approved GAS/Clang, with pinned toolchain/hash and independent fixture inspection. Human approval and D1–D8 remain OPEN. X01 is not closed by this document.
