# ADR-0007 — Native Assembly-first UI Platform

**Status:** accepted architectural direction; implementation is experimental.

## Context

Third-party UI runtimes do not meet the Assembly-first goals of this human-architected, AI-component-built Studio.

## Decision

Develop our own declarative UI language, AST, runtime and platform renderer adapters. Primary implementation is native Assembly with LLVM/Clang assembler. Do not depend on Qt/QML, Slint runtime, Delphi FMX or C++ for Studio. Use platform SDKs and stable C ABI boundaries when needed. Maintain shared behavior tests across each architecture.

## Consequences

Significant increase in scope: font shaping, text editing, accessibility, input, performance, debugging, windows, packaging and security become our responsibility. The active tree contains specifications and examples only; no functioning native UI engine exists.
