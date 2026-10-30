# ADR-0004 — Source Ownership and Safe Regeneration

**Status:** proposed

## Context

Visual-model changes and user-written code coexist. Blind regeneration can erase modifications, while reverse-engineering arbitrary code into the visual model is unreliable.

## Decision

Separate canonical model files, generated artifacts and user-owned source. Every generation declares a reviewable manifest with content hashes and explicit file owners. Changed generated files cause conflicts rather than overwrites. User extension points use stable interfaces. Reverse synchronization is limited to supported parsed constructs.

## Consequences

Requires a generation journal, manifests, explicit source boundaries and conflict UI. Preserves manual programming and makes generator behavior explainable.
