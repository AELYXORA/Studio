# Assembly Component Contract

**Status:** architecture specification; only the UI tree validator ABI has an implementation.

Every component is identified by a stable type ID and interface version. A contract declares typed inputs/outputs, property defaults, events, errors, lifetime, ownership, alignment, threading, privileges and supported target triples. Implementation is native Assembly for a target CPU/OS ABI. Portability is verified by equivalent behavior, not by pretending that x86-64 and AArch64 share instruction syntax.

## ABI requirements

- Fixed-width integer types and explicit byte layouts. Define endian and alignment requirements.
- Never expose internal allocator ownership implicitly. Every buffer identifies allocator/deallocator and lifetime.
- Never unwind an exception across an ABI boundary.
- Fail through stable error codes plus optional diagnostic records.
- Separate platform imports/syscalls in replaceable adapters, not portable component logic.
- Declare supported CPU features, OS API versions, and object format.

## AI generation contract

Human architect approves interfaces and acceptance tests. AI produces Assembly implementations, tests and build recipes, as proposed changes. Passing one assembler run does not establish correctness. Unsupported target implementations must report unsupported, never silently substitute another ABI.

## First contract

See `include/aelyxora/ui.h`: `ax_ui_validate` with a 16-byte node descriptor and x86-64 System V implementation. This is an ABI probe, not a complete component runtime.
