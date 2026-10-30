# Product Scope and Roadmap

**Status:** planned.

## Positioning

AELYXORA Studio is a professional open-source, AI-native RAD development environment inspired by Delphi/WinDev's visual productivity, but designed around typed contracts, explicit source ownership and modern toolchains.

## Milestones (capability-gated, not date promises)

**Foundation:** core project schema, typed graph, stable IDs, serialization, validation, migrations, test fixtures.

**IDE Shell:** open/save/create projects, architecture navigation, inspector and source editor, core command/undo layer.

**Vertical Slice:** visual form, data binding and SQLite CRUD; generate and build one real desktop application on Windows and Linux.

**AI Architect:** scoped project understanding; diff-first model/source proposals, approval, verification and rollback.

**Developer Experience:** debugging, visual quality, imports, packaging, documentation and component SDK boundary.

## Not MVP

Universal language/compiler tooling, all OS targets simultaneously, component marketplace, collaborative SaaS backend, freeform code reverse engineering and guaranteed automatic optimization.

## Success definition

A developer can visually construct a small but useful standalone data-driven application, inspect and modify generated and custom source safely, build/package it reproducibly, and optionally use AI to modify it without corrupting the project.

## Architecture hardening prerequisites

Before implementing a broad component palette, prove the following in order:

1. **Core correctness:** canonical schema, revisioned commands, invalid-state prevention, migrations and crash-safe persistence.
2. **Source safety:** generator manifest, path ownership, stable interfaces and external edit conflict handling.
3. **Runtime semantics:** typed one-way/two-way bindings, cancellation, scheduling and SQLite transactions.
4. **Tooling boundaries:** capability matrix, isolated preview/build workers, logging and credentials.
5. **Evidence:** automated gate G0–G7 reporting from the [verification plan](../architecture/verification-plan.md).

A broad AI agent, plugin marketplace and multi-platform parity remain out of scope until the vertical slice passes these gates.
