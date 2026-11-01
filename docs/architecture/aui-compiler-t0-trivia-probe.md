# T0 native ASCII trivia probe — 2026-11-01

**Observed:** Linux x86-64 executable returned exit code 0 after 18 assertions; both Assembly source files cross-assembled to Windows x64 COFF using Clang 17 integrated assembler. **No Windows execution.**

Sources: [candidate trivia scanner](../../tests/native/x01_trivia_ascii.S) and [Assembly harness](../../tests/native/x01_trivia_ascii_test.S).

Commands:
```sh
clang -no-pie tests/native/x01_trivia_ascii.S tests/native/x01_trivia_ascii_test.S -o trivia_test
./trivia_test  # exit 0
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_trivia_ascii.S -o trivia.obj
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_trivia_ascii_test.S -o trivia_test.obj
# both objects: x86-64 COFF
```

The scanner is a **test-only separate bounded Win64 function** `x01_trivia_ascii(bytes,length,out,capacity)`, returning count or -1. It emits 16-byte temporary records for ASCII whitespace (kind 1) and `//` comments (kind 2); comments stop *before* CR or LF. Tested vectors include exact trivia from LX001 (`[6,7)`) and LX002 (`[2,3)`), as well as CRLF separation, separate whitespace runs and explicit unsupported slash/string rejection. The first local assertion run returned exit 14 because the harness erroneously combined two whitespace runs separated by a `b` character; corrected test expectation to two runs and then passed 18 assertions. The code is not a full lexer.

**Not accepted:** the standalone scanner skips ordinary ASCII bytes rather than tokenizing them; quotes/non-ASCII deliberately reject, so it cannot handle strings or Unicode yet. It does not serialize TriviaV1 32-byte records or TokenV1 48-byte records, guarantee complete token+trivia partition, perform strict UTF-8 validation, implement lexical diagnostics or transactional output, or have protected Arena Manager ownership. The existing token slice remains separate, and full golden vectors LX001–LX013 are **NOT-RUN**. Do not use the two scanners independently to mint T0 PASS. X01 / T0 and D1–D8 remain OPEN.

Next: merge token and trivia logic into a **single** bounded scan with transactional publication, then implement exact TokenV1/TriviaV1 physical layout and strict UTF-8 preflight.
