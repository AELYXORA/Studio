# AELYXORA — X01 TokenV1 Fields, Ref64 Value Pool and Byte-Encoding Candidate

**PROPOSED / NOT APPROVED / NO NATIVE EXECUTION.** This refines [existing TokenV1](aui-compiler-t0-physical-contract.md) without changing its 48-byte layout or IAI-v1 Ref64. Exact layout: tokenId u64@0, sourceUnitId u64@8, startByte u64@16, endByte u64@24, kind u16@32, profileMask u16@34, flags u32@36, valueRef Ref64@40. All values little-endian.

## X01-F1. profileMask semantics

Candidate bit allocation: bit 0=L0, 1=L1, 2=L2, 3=L3, 4=L4; bits 5–15 MUST be zero. **Critical:** this is a *lexical advisory compatibility mask*, never evidence of grammatical permission. Source identifier, integer, string and punctuation/EOF candidate mask is 0x001F; L1 event/command words candidate 0x001E, L2 state/bind/commit 0x001C, L3 task/settled 0x0018, L4 ForEach 0x0010. Contextual identifiers remain 0x001F and require parser-specific admission. **Words shared among productions of different profiles need an exact reviewed, per-spelling policy.** Until reconciliation, no mask can be authoritative; the parser MUST validate the source profile independently.

## X01-F2. Token flags

Candidate flags **0** for normal authored tokens; bit 0 `HAS_DECODED_VALUE` when valueRef references a checked immutable value record. Bits 1–31 reserved and MUST be zero. No `SYNTHETIC`, `ACCEPTED`, `GRAPH_VERIFIED` or recovered-token flags: parser recovery belongs to CST and must never be smuggled into an accepted lex stream. EOF always flags=0 and valueRef=0. A token with a valueRef=0 and HAS_DECODED_VALUE set, or a nonzero valueRef with HAS_DECODED_VALUE clear, is invalid. Unreviewed flags reject.

## X01-F3. DecodedValueV1 candidate (new private record, 32 bytes align 8)

| Offset | Size | Field |
| ---: | ---: | --- |
| 0 | 4 | recordBytes u32=32 |
| 4 | 2 | valueKind u16 (1 normalized identifier UTF-8; 2 decoded String UTF-8; 3 unsigned integer u64) |
| 6 | 2 | flags u16=0 |
| 8 | 8 | dataRef Ref64 (immutable bytes for valueKind 1/2; zero for integer kind 3) |
| 16 | 4 | byteLength u32 (for kinds 1/2; 0 for kind 3) |
| 20 | 4 | reserved u32=0 |
| 24 | 8 | integerValue u64 (for kind 3; zero for kinds 1/2) |

The TokenV1.valueRef points to this **descriptor**, not directly to string bytes. Every reference must resolve via arena index/generation/offset, descriptor type, declared length, alignment and live sealed lease. Decoded String is not NFC-transformed; Identifier value is NFC normalized and source bytes still remain separately exact. Integer value is checked before this descriptor is created; signed and floating-point values are not introduced. No implicit NUL or native pointer. A lexical token may omit a decoded descriptor for punctuation/keywords/EOF only; accepted Identifier/IntegerLiteral/StringLiteral tokens **require one** descriptor in the eventual validated stream.

## X01-F4. Byte fixture convention

A complete TokenV1 byte vector is meaningful only with deterministic local tokenId, sourceUnitId, valueRef and approved profileMask. For review arithmetic, choose tokenId=1, sourceUnitId=1 and **valueRef=0, flags=0 only for no-decoded-value token kinds**, avoiding fabricated pool handles. For e.g. punctuation `(` at [0,1) with kind 16 and profileMask=31, expected 48 bytes:
`010000000000000001000000000000000000000000000000010000000000000010001f00000000000000000000000000`.
This is a **candidate byte placement vector**, not a native ABI test. Do not construct a full Identifier binary vector until a real DecodedValue/Ref64 pool fixture establishes its ownership.

## X01-F5. Mandatory gates

Approve the **exact per-token** profile mask table, reconcile source keywords vs contextual ID positions, create independent machine checks of every field offset and byte fixture, validate decoded pool generation and stale Ref64 rejection, ensure malformed UTF-8/escaped string/overflow reject before sealing, and run real Win64 GAS/Clang ABI tests. The [existing lexical golden vectors](../../examples/aui-compiler-production/x01-lexer-golden-vectors.json) remain NOT-RUN. X01 and D1–D8 remain OPEN.
