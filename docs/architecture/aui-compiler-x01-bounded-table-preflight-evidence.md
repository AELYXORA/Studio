# X01 bounded-table typed Ref64 preflight — 2026-11-01

**Observed local execution:** Linux x86-64 exit code 0 from five-assertion Assembly test. **Observed cross-build:** Clang/LLVM integrated assembler produced Windows x64 COFF for the validator. This is not a Windows execution or production memory-safety proof.

Sources: [validator](../../tests/native/x01_validate_bound_request.S), [test harness](../../tests/native/x01_validate_bound_request_test.S). Local commands:
```sh
clang -no-pie tests/native/x01_validate_bound_request.S tests/native/x01_validate_bound_request_test.S -o x01_request_test
./x01_request_test # exit 0
clang --target=x86_64-pc-windows-msvc -c tests/native/x01_validate_bound_request.S -o validator.obj
file validator.obj # x86-64 COFF
```

New candidate request extends the prior layout: Ref64 @0, trusted pinned table pointer @8, requestedBytes u32 @16, alignment u32 @20, expectedKind u32 @24, tableBytes u32 @28. Table prefix 8 bytes and 40-byte entries. The validator verifies `tableBytes >= 48`; `count <= floor((tableBytes-8)/40)` BEFORE indexing; index <= count, index and generation match; state SEALED, exact expectedKind, positive size, power-of-two alignment <=4096, checked extent, aligned nonzero base, ownerLease nonzero and OPEN gate state. Five deterministic test cases: valid request, truncated table, wrong kind, retiring gate and stale generation, each indicated by a separate failure exit.

**CRITICAL:** the caller-provided tableBytes is trusted metadata, not proof of the allocation's actual length. The table must remain pinned and immutable during this preflight. The gate state check is a snapshot and can race with retirement: no pointer is returned here; do NOT use this as permission to dereference later. Existing `x01_with_bound_ref` has NOT yet been switched to consume this extended request. The 40-byte entry, request extension, and numeric kind are experimental, not accepted IAI-v1 production ABI. No Windows runtime, allocation ownership, typed T0 token binding, callback unwind safety or full concurrency proof. X01/D1–D8 remain OPEN.
