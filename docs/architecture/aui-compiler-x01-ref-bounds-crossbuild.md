# X01 second Win64 COFF cross-build: bounded Ref64 probe

**2026-11-01. Observed cross-compilation; NOT a Windows runtime test.** [Source](../../tests/native/x01_ref_bounds_probe.S) exports `x01_ref_check_candidate` under Windows x64 register argument convention: RCX=Ref64, EDX=expected arena index, R8D=current generation, R9D=committed byte length; EAX=1 if the nonzero reference's index and generation match nonzero expected values and offset is less than committed bytes, otherwise 0. No dependencies or OS calls.

**Local evidence:** using `clang --target=x86_64-pc-windows-msvc -c tests/native/x01_ref_bounds_probe.S -o x01_ref_bounds_probe.obj` on Linux, compilation succeeded and `file` recognized x86-64 COFF. `llvm-objdump -d` displayed the expected comparisons and returns. Observed SHA-256: `365abbf024db6b7a15fff7dd0710660fb4ec3fc057d3e5b630222c0ae5ee421f`. The local build used the exact algorithm encoded in the committed Assembly source.

**Limitations:** no Windows execution (Wine unavailable in the working environment), no dynamic arena table, no lease, immutable seal, allocation or lifetime checks, no requested-byte range (only offset<committed), no alignment/descriptor validation, no u16 generation rollover logic, no exception/corruption runtime tests. In particular **EAX=1 means only a candidate synthetic bounds check passed**, not that the reference is safe to dereference. No T0/Graph trust can be inferred.

**Next evidence gate:** construct native assembly-owned arena table and test `requestedBytes <= committedBytes-offset` via checked subtraction, alignment and type, generation invalidation and lease state, run from Win64 test harness, then integrate with lexer without ever advancing T0 on partial success. X01 OPEN, all D1–D8 acceptance gates OPEN.
