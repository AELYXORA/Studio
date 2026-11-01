# 2026-11-01 — X01 consolidation and T0 native UTF-8 start

## Actual implementation and execution

1. [x01_with_typed_ref.S](../../tests/native/x01_with_typed_ref.S) unifies capacity precheck (before indexed entry read), embedded gate acquire, index/generation/state/type/size/alignment checks, trusted synchronous callback and release. [Eight-assertion harness](../../tests/native/x01_with_typed_ref_test.S).
2. [x01_utf8_strict.S](../../tests/native/x01_utf8_strict.S) is the **first real T0 source-validation primitive**, not yet LexerScan. [Ten-assertion harness](../../tests/native/x01_utf8_strict_test.S).

Locally verified with Clang 17.0.0, Linux x86-64:
```sh
clang -no-pie gate.S typed_borrow.S typed_borrow_test.S -o typed_borrow_test
./typed_borrow_test
# observed exit 0
clang --target=x86_64-pc-windows-msvc -c typed_borrow.S -o typed_borrow.obj
# observed x86-64 COFF object

clang -no-pie utf8.S utf8_test.S -o utf8_test
./utf8_test
# observed exit 0
clang --target=x86_64-pc-windows-msvc -c utf8.S -o utf8.obj
# observed x86-64 COFF object
```

The typed wrapper's initial assembly attempt failed on a 16/32-bit operand mismatch; the source was corrected, then tests and COFF build succeeded. Test assertions: valid callback, truncated table, wrong descriptor kind, stale generation, retire gate, callback count, gate integrity (eight failure exits). UTF-8 tests accept ASCII, 2-, 3-, 4-byte valid sequences and reject overlong, UTF-16 surrogate, incomplete sequence, initial BOM, embedded NUL and >U+10FFFF (ten failure exits).

## Architecture consolidation and non-claims

**Only one _candidate_ integrated typed borrow path is proposed for new tests**: `x01_with_typed_ref`. Legacy `x01_resolve_table`, `x01_with_bound_ref`, unprotected preflight and gate-before-lookup experiment remain historical test sources and must not be used by a production compiler. They have deliberately not been deleted, so old evidence remains reproducible.

**No production Arena Manager yet:** trusted pinned table pointer and byte count are still external inputs; allocator-owned table lifetime, serialized publish/retire, non-forgeable callback/capability, callback unwind and error/status ABI, pointer escape, Windows native execution, generation wrap, guard pages and native synchronization gates remain unresolved. Neither successful command establishes T0 proof.

**Not a full lexer:** UTF-8 primitive validates scalar encoding only; it does not implement Unicode 15.1 XID_Start/XID_Continue, NFC, tokenization, literals, trivia, diagnostics, `TokenV1`, `SourceUnitV1`, `LexerScan`, CST/AST or any stage from T1 to T8.

## Next exact engineering tasks

1. Implement a host-owned table allocation and controlled slot mutation API, not a global unowned table pointer.
2. Define and run a status-returning callback ABI, including normal and fault cleanup, and a Win64 runnable PE test.
3. Connect strict UTF-8 validator to a *bounded* LexerScan scanner; compare exact numeric token kinds, original byte offsets and trivia against existing golden vectors LX001+.
4. Keep X01 and all D1–D8 OPEN until independently verified acceptance; do not expand scope to unnecessary memory frameworks.

**Post-test correction:** the first UTF-8 source used `lea` before `jc` to detect an address overflow; `lea` does not update carry. Replaced with `mov r9,rcx; add r9,rdx; jc .bad` in commit `eb8ce3d`; repeated native tests (exit 0) and Win64 COFF cross-assembly after this correction. The caller is still responsible for presenting an accessible input buffer of the declared length.
