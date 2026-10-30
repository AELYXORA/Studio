# ADR-0002 — Qt-first, Backend-neutral

**Status:** proposed

## Context

Building a new IDE, native GUI frameworks for every OS and a custom compiler concurrently would delay a usable product.

## Decision

Build the IDE using C++ and Qt 6.12/QML. Generate Qt/QML desktop apps first, with CMake. Keep application contracts independent of Qt concepts and backend details.

## Consequences

Accelerates end-to-end validation while leaving room for future backends. Requires clear portability constraints and careful Qt licensing/compliance review.
