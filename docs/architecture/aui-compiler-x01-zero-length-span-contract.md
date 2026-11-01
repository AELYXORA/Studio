# AELYXORA — X01 Zero-Length Values and Typed Span ABI Decision Candidate

**Status: PROPOSED / NOT ACCEPTED / NATIVE TESTS NOT-RUN.** Refines [IAI-v1 Span16](aui-compiler-internal-assembly-abi.md), [T0 physical contract](aui-compiler-t0-physical-contract.md), [TokenV1 value layout](aui-compiler-x01-token-field-layout.md), and [memory audit](aui-compiler-x01-memory-compatibility-audit.md). No second ABI.

## Z1. Empty decoded String

For an authored empty string `""`, TokenV1.kind=3 and `HAS_DECODED_VALUE=1`, so TokenV1.valueRef **must be nonzero** and resolve to a 32-byte DecodedValueV1 descriptor. The descriptor has `recordBytes=32,valueKind=2,flags=0,dataRef=0,byteLength=0,reserved=0,integerValue=0`. Its source token covers two quote bytes; its decoded contents have length zero. **No dereference of the absent dataRef**. An empty Identifier remains invalid. For a nonempty decoded String, `dataRef!=0` and byteLength positive. All source spans retain original byte identity, including source escapes.

## Z2. Empty and nonempty Span16

IAI-v1 explicitly allows `baseRef=0` for a zero-length absent span and requires exactly one of flags 1 or 2 for *nonempty* spans. Therefore the candidate canonical **empty immutable typed collection** is `Span16{baseRef=0,byteLength=0,elementSize=8,flags=0}`. This is a proposed narrow empty-span canonicalization, not a change to the established nonempty flags rule. Do not dereference baseRef=0. Alternative zero-length encodings must be rejected after this policy is approved; prior to approval all such vectors are review-only.

For nonempty TokenV1/TriviaV1 collections, `Span16{baseRef=valid Ref64,byteLength=N*8,elementSize=8,flags=1}`; each 8-byte element is one typed Ref64 pointing to a sealed 48-byte TokenV1 or 32-byte TriviaV1 respectively, with matching descriptor identity and live arena generation. The span is a view and owns neither references nor arenas. `elementSize=48` for the Ref64 list is invalid even though TokenV1 itself is 48 bytes. Every allocation/count/stride and pointer resolution uses checked arithmetic.

## Z3. Native layout arithmetic candidates

The [byte vectors](../../examples/aui-compiler-production/x01-zero-length-span-byte-vectors.json) encode the candidate empty DecodedValueV1 descriptor, empty Span16, and one nonempty Span16 with a fixed synthetic Ref64. A synthetic reference checks field **encoding only**; it does not establish that an arena has been allocated, sealed or leased. The target Win64 GAS test must allocate real arenas and resolve the references, including generation rollover and stale reference mutation.

## Z4. Evidence gates

- Exact field widths/offsets, 32/16-byte sizes and 8-byte alignment independently probed on Win64.
- Both empty String and empty typed collection accepted without touching address zero; mismatched valueKind, forbidden nonzero empty payload fields or invalid flags reject.
- Nonempty Span16 resolves every typed Ref64 and checks seal, lease, generation, bounds, alignment and record descriptor.
- Mutation tests reject stale generation, span-count overflow, inconsistent elementSize, wrong typed target and premature release.
- Lexer golden fixtures and D1–D8 acceptance remain OPEN. An arithmetic byte vector is not an execution result.
