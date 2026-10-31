# AELYXORA — T0 Source Capture, Tokens, CST and AST Physical Contract

**Status: PROPOSED / NOT ACCEPTED / NOT IMPLEMENTED / NOT NATIVE-TESTED.** This is the T0 physical representation candidate for the ONE production AUI compiler. It refines [AUI Syntax](aui-syntax.md), [COMP frontend](aui-compiler-frontend-closure.md), [IAI-v1 internal ABI](aui-compiler-internal-assembly-abi.md) and [T1–T6 IR verifier](aui-ir-verifier-and-pass-evidence.md). The language grammar and feature-profile owners remain authoritative. Nothing in this document authorizes T2 Graph linkage or native code emission.

## T0.1 Immutable source capture

Capture exact source file bytes through the host boundary into an immutable source arena. Reject oversize inputs, invalid UTF-8, BOM, embedded NUL, invalid Unicode scalars and unauthorized path/identity changes before token publication. Compute the source identity on **original bytes**, before NFC transformation. The source unit has a compiler-local ID, original byte length, byte digest, captured file identity/metadata (diagnostic only until verified D6 trust), and a Ref64 to immutable byte storage. No implicit NUL terminator. Source spans use the already-defined 32-byte SourceSpanV1 with u64 half-open original byte offsets. Each source span must match UTF-8 scalar boundaries, except parser-generated zero-length insertion spans explicitly marked as synthetic; the underlying source bytes are never changed.

SourceSize and allocation ceilings come from the active, reviewed IAI-v1 budget policy. The initial L0/L1 1 MiB source cap and 64 MiB context cap are *first-slice proposals*, not automatically the final production L0–L4 limits.

## T0.2 Physical records (64-bit little-endian IAI-v1 candidate)

All struct bases aligned to 8 bytes, reserved fields zero. Ref64 is the existing 32-bit offset + 16-bit arena index + 16-bit generation, not a native pointer. The following **new T0-only records** do not alter IRNodeHeaderV1 nor the 139 T1–T6 tags.

| Record | Bytes | Ordered field@offset: width |
| --- | ---: | --- |
| SourceUnitV1 | 64 | sourceUnitId@0:u64, sourceBytesRef@8:Ref64, sourceByteLength@16:u64, sourceDigestRef@24:Ref64, tokenSpanRef@32:Ref64, triviaSpanRef@40:Ref64, rootCstRef@48:Ref64, flags@56:u32, reserved@60:u32 |
| TokenV1 | 48 | tokenId@0:u64, sourceUnitId@8:u64, startByte@16:u64, endByte@24:u64, kind@32:u16, profileMask@34:u16, flags@36:u32, valueRef@40:Ref64 |
| TriviaV1 | 32 | sourceUnitId@0:u64, startByte@8:u64, endByte@16:u64, kind@24:u16, flags@26:u16, reserved@28:u32 |
| CstNodeV1 | 64 | nodeId@0:u64, sourceUnitId@8:u64, startByte@16:u64, endByte@24:u64, childSpanRef@32:Ref64, tokenSpanRef@40:Ref64, kind@48:u16, flags@50:u16, childCount@52:u32, reserved@56:u64 |
| AstNodeV1 | 64 | nodeId@0:u64, sourceUnitId@8:u64, startByte@16:u64, endByte@24:u64, childSpanRef@32:Ref64, cstOriginRef@40:Ref64, kind@48:u16, flags@50:u16, childCount@52:u32, reserved@56:u64 |

These exact offsets are **new candidate decisions requiring architect sign-off and GAS offset probes**, not an already-approved on-disk ABI. All token/trivia and child arrays use a Ref64 to Span16 with immutable array of 8-byte typed Ref64 elements; do not interpret a raw byte-length as element count. Original token spans and source spelling remain authoritative, normalized identifier values are separately stored in an immutable value pool.

## T0.3 Closed lexical classes and normalization

Token categories: identifier, integer literal, quoted string, punctuation/operator, keyword, EOF and invalid lexical item (diagnostics only). Each named punctuation/keyword/kind needs a closed numeric code in a future registry: **numeric codes are not assigned by this prose**. Lexing is deterministic against pinned Unicode 15.1.0 XID and NFC tables as proposed in COMP-02, not OS locale. Identifiers are validated scalars, compare by NFC normalized identifier content; raw source spelling remains unchanged. Strings preserve decoded scalar content and escape meaning, without NFC. Numeric tokens follow decimal strictness and range gates of the selected language/profile owner. BOM, invalid scalar, disallowed whitespace, invalid escape and malformed numeric forms reject as specified in COMP-02. Maintain exact token-to-trivia coverage; no invisible token dropping.

T0 scanner precedence: invalid UTF-8 outranks profile diagnostics; longest relevant punctuation recognized by the reviewed grammar; comments and strings consume their contents without treating embedded keywords as constructs; keyword classification is contextual where the approved grammar requires it. A feature absent from a selected L0–L4 profile must reject, never auto-upgrade the profile. Do not assume the L0/L1 lexical subset is sufficient for L2–L4.

## T0.4 CST and AST ownership

The CST is lossless: ordered tokens and trivia can reproduce the source byte sequence **exactly**. Every non-EOF original byte belongs to exactly one token/trivia coverage interval (including comments and whitespace), with no gaps, overlaps or synthetic bytes. Nodes have bounded ordered child references and preserve parent/child source containment; synthesized recovery nodes are flagged and cannot be accepted for T1 success. The AST is a deterministic semantic projection, with direct immutable origin back to the CST and precise original source span. It may omit trivia structurally but may not erase source diagnostics, tokens needed for semantic checks or profile constraints. A syntax error may construct recovery CST/AST for IDE diagnostics, but **must never** issue a successful T0 pass receipt or permit T1.

Closed T0 descriptor classes are SourceUnit, Token, Trivia, CSTNode, ASTNode, decodedTokenValue, TokenRefArray, TriviaRefArray, NodeRefArray and SourceDigest; every Ref64 is checked against the declared descriptor class, current arena generation and lease. Token/CST/AST IDs are compiler-local, not Canonical Graph IDs, public TypeIDs or native pointers. Arrays and DAG traversal are bounded by IAI-v1 resource policy. CST parent/child links must be cycle-free; AST node linkage must be cycle-free; a shared interned token value is allowed.

## T0.5 Scanner/parser pipeline and failure handling

1. Win64 host captures immutable bytes and records original source identity.
2. Validate source bound and Unicode decoding; cache pinned table version/digest in compiler input identity.
3. Scan complete lexical stream and trivia, including one EOF token at [sourceLength,sourceLength].
4. Validate ordered non-overlapping source coverage, token kinds, normalized identifier identity and selected language profile.
5. Parse to lossless CST using the *single* approved grammar for the selected profile and module kind; record deterministic recovery diagnostics.
6. Project AST with checked CST origins; validate AST invariants and profile-specific construct legality.
7. If lexical/parse/semantic-preflight diagnostics exist, output bounded diagnostic report only, with no success receipt or TypedHIR. Otherwise seal immutable token/CST/AST arenas, record a compiler-local T0 receipt, and permit T1 to consume the verified AST.
8. On allocation, resource, cancellation or validation failure: release provisional arena leases and return zero output/proof refs, preserving immutable captured input and previously committed results.

Parser ambiguity, operator precedence, generic-angle punctuation and contextual keywords must be resolved by the definitive AUI syntax owner. A T0 physical design cannot silently settle language semantics.

## T0.6 Acceptance scenarios — all NOT-RUN

- Valid ASCII and multibyte UTF-8: perfect byte-wise reconstruction from token + trivia intervals.
- CRLF preservation (two bytes, one display line), LF, tabs, comments at EOF.
- Malformed UTF-8, BOM, overlong sequences, surrogate, embedded NUL and invalid Unicode whitespace reject before success.
- NFC-equivalent identifier spellings resolve identically while original byte spans remain distinct.
- Quoted strings containing comment markers and keywords do not activate tokens.
- Decimal leading zero/overflow/escape/surrogate-pair boundary tests.
- L0–L4 feature admission tests; no implicit profile escalation.
- Truncated/misaligned records; wrong token kind; invalid Ref64 generation/descriptor; child-span count mismatch; overlapping CST spans.
- Cycle detection for malicious CST/AST references; missing EOF; token/trivia coverage gaps; out-of-order token spans.
- Invalid syntax recovery produces IDE diagnostics but no successful pass receipt.
- Failure injection at each arena allocation/seal/publication boundary leaves no leaked leases and no partial T1 admission.
- Native Windows x64 GAS/Clang integrated assembler byte-offset probes, deterministic repeated runs and memory bounds.

## T0.7 P0 decisions

1. Approve closed numeric token, CST and AST kind registries; enumerate *all* grammar constructions, not only first-slice tokens.
2. Confirm full-production source/token/arena budgets distinct from first L0/L1 candidate.
3. Resolve AUI precedence, contextual grammar, recovery synchronization and L2–L4 syntax details with owning language documents.
4. Add machine-readable T0 record schema and byte-placement reference vectors with independent arithmetic checks.
5. Produce real Windows x64 Assembly offset/arena/parser tests and demonstrate source-to-TypedHIR handoff.
6. Finish authenticated public type/Graph contracts and human D1–D8 sign-off before T2/native output.

**Evidence status:** no native compiler, parser, T0 binary test, verified public digest or executable result is claimed.
