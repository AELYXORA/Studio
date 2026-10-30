# ADR-0003 — Controlled AI Proposals

**Status:** proposed

## Context

AI-authored modifications may violate types, architecture, security requirements or user source ownership.

## Decision

AI only submits typed model commands or reviewable file patches. Changes pass permission checks, schema validation and context-specific compile/test gates before claims of success.

## Consequences

Adds review and transaction infrastructure but preserves developer control, auditability and rollback. AI remains optional.
