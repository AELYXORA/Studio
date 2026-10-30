# ADR-0007 — Native Assembly-first UI Platform

**Status:** accepted architectural direction; implementation is experimental.

## Context

Third-party UI runtimes and the C++ prototype constrain our goal of an Assembly-first, human-architected, AI-component-built RAD Studio.

## Decision

Develop our own declarative UI language, AST, runtime and platform renderer adapters. Primary implementation is native Assembly with LLVM/Clang assembler. Do not depend on Qt/QML, Slint runtime, Delphi FMX or C++ for Studio. Use platform SDKs and stable C ABI boundaries when needed. Maintain shared behavior tests across each architecture.

## Consequences

Significant increase in scope: font shaping, text editing, accessibility, input, performance, debugging, windows, packaging and security become our responsibility. Prior prototypes are retained only in Git history. The first native validator is not evidence of a functioning UI engine.
