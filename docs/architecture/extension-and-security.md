# Extension, Runtime and Security Boundaries

**Status:** architectural requirements.

The declarative parser and model validator must not execute source content. Assembly components are native executable code and must not be treated as sandboxed merely because they have manifests. Untrusted component previews and builds run in isolated helper processes with restricted OS permissions and explicit workspace boundaries where available.

Separate Studio UI, Assembly component runtime, build tooling, and OS renderer adapters. Each component declares filesystem, network, device and process permissions. Keep secrets outside exported project definitions and AI context by default.

Verify source hashes, dependencies, platform libraries, licenses and assembler/linker settings. The Studio must never claim portable execution solely because the LLVM assembler accepted a source file.

Accessibility, text shaping, IME and input handling are first-class platform requirements, not optional rendering decorations.
