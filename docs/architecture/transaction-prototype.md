# C++23 Transaction Prototype

**Status:** experimental in-memory implementation. Disk durability and full model command coverage are not implemented.

`include/aelyxora/transaction.hpp` introduces a typed `std::variant` command envelope and `std::expected` result.

## Guarantees in this prototype

- Commands operate on a detached candidate snapshot.
- A revision mismatch rejects a transaction without changing the original.
- Every intermediate command state is validated.
- On success, a batch commits once and increments revision once.
- Rename operations update dependency references.
- Failures produce structured diagnostics.

## Limitations

This implementation is not a filesystem transaction, undo/redo manager, or command journal. It does not read JSON. It only supports component renames and project name changes. It cannot yet synchronize with external editors or AI proposals. The original `rename_component` helper remains for legacy tests.

See [Transactions and Persistence](transactions-and-persistence.md) for the full intended design.

## Verification

```sh
cmake -S . -B build -DBUILD_TESTING=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

A GitHub Actions workflow runs this build on Windows and Linux. Passing status must be confirmed in CI; code presence is not proof of test success.
