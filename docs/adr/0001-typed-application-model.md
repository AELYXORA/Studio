# ADR-0001 — Typed Application Model

**Status:** proposed

## Context

Visual RAD, AI generation and manual programming need durable shared contracts. Direct AST synchronization across arbitrary source languages is impractical and lossy.

## Decision

Adopt a typed, versioned project model as authority for declarative application structure. Keep handwritten source under its own authority and integrate with explicit interfaces. Store canonical metadata in reviewable text files with stable IDs.

## Consequences

Requires schemas, validators, migration tooling and ownership-aware code generation. Enables deterministic verification and tooling-independent project understanding. Arbitrary source code will not always have visual round-trip support.
