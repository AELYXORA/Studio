# Quality and Release Gates

**Status:** planned, not implemented.

| Gate | Minimum proof |
| --- | --- |
| Model | Schema validation, deterministic roundtrip and migrations |
| Components | Contract tests, invalid bindings and lifecycle tests |
| Designer | UI layout serialization and design/runtime parity checks |
| Generation | Stable file hashes and generated/user code separation |
| AI edits | Transaction validation, permission checks, diff and rollback |
| Builds | Clean CMake configure/build on supported target toolchains |
| Runtime | Desktop CRUD smoke test with SQLite persistence and errors |
| Security | Import boundaries, path traversal, secret handling, dependency inspection |
| Packaging | Standalone install/uninstall and runtime licensing review |
| Documentation | Reproducible quickstart, supported-platform matrix, known limitations |

Quality reporting uses **not run / pass / fail / not applicable (with rationale)** and never treats an unimplemented test as a pass. Performance is measured on named machines; no unverified throughput promises.

The initial end-to-end acceptance scenario creates a customer CRUD desktop app through the designer, builds it, saves/reloads real records, edits a custom handler without loss, runs tests and produces a distributable application.
