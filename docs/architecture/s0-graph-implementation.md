# S0 Project Graph Foundation — Current Status

**Status: experimental native lexical preflight committed; no executable Project Graph validator.**

The prior Python bootstrap validator and tests were removed at the user's request. Python is prohibited by [Implementation Language Policy](language-policy.md). There is currently no functioning Project Graph validator, complete JSON parser or transactional save implementation. The repository does include a small Linux x86-64 Assembly lexical preflight that checks string termination and delimiter nesting, but not JSON grammar or graph semantics.

S0 remains the next implementation milestone: complete native JSON parsing, graph IDs/ports/type validation, diagnostics, persistence and local fixture testing using approved target-specific Assembly and native platform interfaces.

Illustrative JSON project/package manifests, negative fixtures, JSON Schemas and technical contracts remain. They are not proof of a working validation tool. No Python commands should be used. No CI.


**Local Assembly experiment:** a Linux x86-64 file/string/delimiter preflight was assembled and exercised in the local working environment; it is not a complete JSON parser, graph validator, or Windows executable. The source is now committed at [src/bootstrap/linux-x86_64/json_preflight.S](../../src/bootstrap/linux-x86_64/json_preflight.S). This is a limited preflight, not a working S0 validator.
