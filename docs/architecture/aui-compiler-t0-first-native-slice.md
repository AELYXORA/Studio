# T0 native ASCII lexical slice — observed execution (2026-11-01)

**Scope:** first limited *real executable token scanner*, **not** the production `LexerScan` and not T0 acceptance.

Sources: [GAS scanner](../../tests/native/x01_lexer_ascii_slice.S), [GAS test](../../tests/native/x01_lexer_ascii_slice_test.S); candidate [numeric token grammar](../../schemas/aui-compiler-t0-token-binding-candidate.json) and [golden vectors](../../examples/aui-compiler-production/x01-lexer-golden-vectors.json).

Local Clang 17.0.0 execution on Linux x86-64, tested after correcting an invalid 64-bit immediate:
```sh
clang -no-pie tests/native/x01_lexer_ascii_slice.S tests/native/x01_lexer_ascii_slice_test.S -o lx_test
./lx_test
# observed: exit 0
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_lexer_ascii_slice.S -o lx.obj
file lx.obj
# observed: x86-64 COFF object file
```

SHA256 of local source file: `11205c43a880486a5196995d1f31a89a14b7e9116e548d5d7858e2c3d0d8ee9e`; COFF object SHA256: `74b44d9a8a9b77e688166694a1afa931b6f12a193757dee165898c796b48244f`. Local build was performed from the authored source subsequently committed. Not a reproducible Windows toolchain verification.

Win64 function `x01_lexer_ascii_slice(bytes,length,output,capacity)` emits test-only 16-byte `{u32 kind,u32 startByte,u32 endByte,u32 reserved}` records and EOF or returns -1. Handles ASCII A-Z/a-z identifiers (digits inside), spaces, exact `import`/kind64, `on`/70, `settled`/80, `.`/22 and `;`/25. EAX=record count. For now it uses a caller-supplied bounded output buffer with no publication, and rejects unsupported source bytes. A failure can leave partial output bytes in the caller buffer; caller **must discard them**.

The 14-exit-branch executable harness checks token counts, selected kinds and selected offsets against the candidate `LX001` and `LX002` vector examples. **It does not yet compare every field or trivia partition**, so neither golden vector is fully accepted. The scanner skips spaces rather than emitting TriviaV1, does not implement strict UTF-8 validation or Unicode XID/NFC, does not produce TokenV1 48-byte records, does not preserve source set/arena ownership, does not handle strings/escapes/integers/comments/arrows or lexical diagnostics. This deliberately narrow primitive is not callable as the full T0 compiler stage.

**Next:** integrate `x01_utf8_strict` with atomic failure/complete-output publication; implement exact numeric token table, complete source partition tokens+trivia, TokenV1 and TriviaV1 into owned Arena Manager; run full LX001–LX... fixtures with negative input and Win64 execution. X01 and D1–D8 OPEN.
