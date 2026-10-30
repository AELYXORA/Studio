# S0 Project Graph Foundation — Current Status

**Status: design only; no executable validator.**

The prior Python bootstrap validator and tests were removed at the user's request. Python is prohibited by [Implementation Language Policy](language-policy.md). There is currently no functioning Project Graph validator, parser or transactional save implementation in the repository.

S0 remains the next implementation milestone: native file parsing, graph IDs/ports/type validation, diagnostics, persistence and local fixture testing using approved target-specific Assembly and native platform interfaces.

Illustrative JSON project/package manifests, negative fixtures, JSON Schemas and technical contracts remain. They are not proof of a working validation tool. No Python commands should be used. No CI.


**Local Assembly experiment:** a Linux x86-64 file/string/delimiter preflight was assembled and exercised in the local working environment; it is not a complete JSON parser, graph validator, or Windows executable. Until checked into the repository, it does not constitute a committed S0 baseline.
