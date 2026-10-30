# Implementation Language Policy

**Status: accepted project restriction.**

Python is prohibited in AELYXORA Studio repository implementation, tooling, tests, scripts, build steps and code generators. Do not add .py files, Python dependencies or invocations of python, pip, pytest or similar commands. Historical references to a removed Python bootstrap may remain only as explicit records that it was removed; no documentation may describe it as the current implementation.

AELYXORA's core uses target-specific Assembly, the proposed native AUI compiler/runtime and thin necessary OS interfaces. LLVM/Clang toolchain integration is permitted for assembly and linking. Any additional implementation language or tooling must be explicitly approved before introduction; no implicit bootstrap exceptions.

Project manifests, JSON Schemas and design test fixtures remain technology-neutral inputs, not Python implementations. Manual local testing only. CI remains disabled.

**Current state:** the earlier Python graph validator and unittest source files have been deleted. S0 has no executable validator and must be implemented using approved native tooling.
