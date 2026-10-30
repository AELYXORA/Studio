# AELYXORA Declarative UI

**Goal:** our own SwiftUI-like declarative ergonomics, not a SwiftUI/Slint/QML clone and not dependent on those runtimes.

## Planned language

Human-readable declaration files describe reusable views, typed state, layouts, styling, actions and accessibility. The syntax is **not yet specified**; no parser exists. Stable keys identity-map nodes across revisions; bindings are type-checked and cyclic graphs rejected unless explicitly delayed.

## Planned runtime

1. Parse declarations to an immutable UI AST.
2. Validate component contracts, capabilities and property types.
3. Reconcile previous/next trees by stable keys, preserving state when identity and type allow.
4. Incrementally measure and layout, then generate platform-neutral drawing commands.
5. Renderer adapters present frames and route input through validated events.
6. Design-time inspector edits AST transactions, never arbitrary generated code.

## Current code

No AUI parser, validator, renderer or runtime currently exists. See [AUI Language](aui-language.md) for the proposed syntax and type rules.

## Portability

All Assembly must have per-target calling convention documentation and an automated shared contract suite. First target: Linux x86-64 System V ABI. Later: AArch64, Windows x64, macOS, mobile targets, each gated by builds and runtime tests. The declarative language remains CPU-neutral.

## Near-term gates

- Define schema and parser for a minimal view (VStack/HStack/Text/Button).
- Specify stable identity and state transitions.
- Implement deterministic layout, diff and one renderer.
- Build the IDE's own first window from this runtime.
