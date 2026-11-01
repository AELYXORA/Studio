# X01 Win64 Assembly COFF probe — actual local cross-build evidence

**2026-11-01. Local native toolchain assembly executed on Linux x86-64, emitting Windows x64 COFF. Windows machine-code execution NOT-RUN. ABI verification and X01 sign-off NOT-RUN.** Source: [tests/native/x01_abi_probe.S](../../tests/native/x01_abi_probe.S).

Command executed: `clang --target=x86_64-pc-windows-msvc -c tests/native/x01_abi_probe.S -o x01_abi_probe.obj`.

Observed toolchain: Clang 17.0.0 (Swift LLVM packaging) from `/usr/local/swift/usr/bin/clang`. Linux x86-64 host. `file` identified output as x86-64 COFF; `objdump` identified PE-x86-64 format and `.rdata` as **0x60 (96) bytes**. Native assembly `.if/.error` asserted static layouts TokenV1=48, DecodedValueV1=32, Span16=16 bytes; the build succeeded. Symbol inspection: `x01_token_fixture` at `.rdata+0x00`, `x01_empty_decoded_string` at `+0x30`, `x01_empty_span` at `+0x50`, with end at `+0x60`. The simple `x01_validate_ref_shape` Win64-callable function compiled into `.text`.

Observed object SHA-256 in this local run: `0adc41c447ac1455924385ad4939bf1e40f5a7a685ae5b1765e5eed047ae7a5c`. This hash identifies the locally built object **from the current source at time of execution**, not a D6 authenticated release or reproducibility claim.

The compiled Ref64 check rejects nonzero references with arena index 0 or generation 0, and permits the all-zero absent reference. It **does not** validate arena existence, bounds, leases, alignments, stale generations, memory safety, Ref64 descriptor types, or entire compiler. No Windows runtime test was executed, nor exact full field-offset C/Assembly probes or dynamic arena tests. Do not use this result to close X01 or elevate T0.

To replay locally from repo root: `clang --target=x86_64-pc-windows-msvc -c tests/native/x01_abi_probe.S -o x01_abi_probe.obj`. Inspect with `file`, `objdump -h`, `objdump -s -j .rdata`, and `objdump -t`. No CI, Python, Qt, or product compiler changes.
