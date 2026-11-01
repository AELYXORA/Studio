# AELYXORA — X01 Memory Compatibility Audit: Token/Value/Span/Ref

**Status: PROPOSED / STRUCTURAL AUDIT / NOT NATIVE-TESTED.** Owners remain [IAI-v1](aui-compiler-internal-assembly-abi.md), [T0 structures](aui-compiler-t0-physical-contract.md) and [X01 Token field proposal](aui-compiler-x01-token-field-layout.md). No alternate ABI is introduced.

## M1. Four-layer ownership contract

1. SourceUnitV1 owns an immutable source-byte snapshot. TokenV1 spans [startByte,endByte) refer only to that sourceUnit and may never borrow decoded pool bytes as original spelling.
2. TokenV1.valueRef resolves to an aligned **DecodedValueV1 descriptor (32 B)**, not the decoded payload. Its kind is determined by TokenV1.kind: Identifier->1, StringLiteral->2, IntegerLiteral->3; other kinds require flags=0/valueRef=0.
3. Descriptor `dataRef` for kind 1/2 resolves to exact immutable UTF-8 bytes of `byteLength`; kind 3 requires `dataRef=0,byteLength=0` and a checked integerValue. For kinds 1/2 require `integerValue=0`. Empty decoded String: a zero-length representation must be explicitly standardized (candidate dataRef=0 with byteLength=0); **do not dereference zero**. An empty Identifier is forbidden.
4. Span16 is a **view**, not ownership. Token/trivia collections can be either contiguous fixed-stride records with Span16 elementSize=48/32, or arrays of 8-byte Ref64 handles to records. These are different valid representations; the current T0 document calls for typed Ref64 arrays. Therefore tokenSpanRef/triviaSpanRef MUST resolve to an immutable Span16 whose `elementSize=8` and whose elements are typed Ref64 pointing to TokenV1/TriviaV1. **Never use elementSize=48 or 32 for these same collections without revising T0's owner contract.**

## M2. Validation sequence

- Validate compilation context and source capture, sourceUnitId match, original byte length, UTF-8 scalar endpoints, token kind and flag/mask reserved bits.
- Resolve `valueRef` using Ref64's 16-bit generation and arena index, u32 offset, alignment 8, committed size >=32, descriptor class DecodedValueV1 and live immutable lease.
- Check descriptor.recordBytes=32, valueKind matches lexical token, flags=0, reserved=0; validate kind-specific payload invariants and absolute resource budgets.
- For nonempty decoded bytes, ResolveRef(dataRef, byteLength, alignment 1, exact immutable byte-pool descriptor), validate scalar sequence. Identifier normalized value is NFC; String is exact decoded scalar sequence without NFC.
- Validate `tokenSpanRef` / `triviaSpanRef` to existing sealed Span16 records (align8), `elementSize=8`, immutable flag=1, byteLength multiple of 8, no overflow, and each Ref64 target of the exact expected record type.
- Validate token source intervals monotonically and partition them with trivia intervals; exactly one EOF zero-width at original source length; no overlapping or missing original bytes. Source IDs and arena references must not be mistaken for portable public identifiers.

## M3. Negative/mutation obligations — all NOT-RUN

| ID | Mutation | Expected |
| --- | --- | --- |
| MV01 | valueRef nonzero but HAS_DECODED_VALUE=0 | Reject |
| MV02 | Identifier valueRef=0 | Reject |
| MV03 | String value descriptor kind=Integer | Reject |
| MV04 | decoded descriptor recordBytes=24 or reserved!=0 | Reject |
| MV05 | decoded bytes length exceeds committed arena | Reject |
| MV06 | stale Ref64 generation | Reject |
| MV07 | zero arena index with nonzero Ref64 | Reject |
| MV08 | arena index generation exhausted and reused | Reject |
| MV09 | Span16 elementSize=48 for Ref64 array | Reject |
| MV10 | Span16 byteLength not divisible by 8 | Reject |
| MV11 | Span16 flags immutable+exclusive simultaneously | Reject |
| MV12 | token collection points to TriviaV1 descriptor | Reject |
| MV13 | token source span ends inside UTF-8 multibyte scalar | Reject |
| MV14 | two EOF tokens or EOF at wrong offset | Reject |
| MV15 | empty string descriptor attempts dereference of zero | Reject unsafe dereference (empty value may be valid) |
| MV16 | malformed token plus allocation failure after partial work | No successful T0 receipt, no leaked scratch lease |

## M4. Explicit conflicts and required decisions

**C1:** Earlier physical T0 language about 'token/trivia arrays' can be misread as contiguous records. The authoritative T0 collection format is **Span16 of Ref64** (8-byte stride) until architect review changes it; native probe must demonstrate that exact choice.

**C2:** Empty String `""` is syntactically valid, but the decoded value pool needs a zero-length convention compatible with IAI-v1's Span16 zero-base policy. Candidate `dataRef=0,byteLength=0` is safe; final approval outstanding.

**C3:** The reviewed token field policy proposes profileMask advisory bits, not authorization. Exact masks must be reconciled per token and context; a malformed mask must never bypass parser profile gates.

**C4:** Native byte vectors with nonzero Ref64 are meaningful only with fixed arena index/generation/offset fixtures and owned records. Independent GAS offset and memory-safety tests remain mandatory.

**Verdict:** physical layouts are structurally compatible **if** typed Ref64 arrays, descriptor-kind checks and empty-value convention are enforced; compatibility is not natively demonstrated. X01 and D1–D8 remain OPEN.
