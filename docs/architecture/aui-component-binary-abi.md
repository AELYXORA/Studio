# AUI Component Binary ABI

**Status: proposed; not implemented or verified.** Defines component metadata, memory ownership, call frames, asynchronous results, and cross-target compatibility.

The portable AUI contract is distinct from CPU calling conventions. Each module declares target triple, ABI revision, required capabilities, and its exported operations. Native pointers are never serialized in project files.
