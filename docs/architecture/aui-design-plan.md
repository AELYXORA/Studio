# AUI Theoretical Design Plan

**Status: living design checklist. This is a specification program, not a release claim.**

The aim is to complete a coherent theoretical architecture before broad implementation while using small experiments to settle hard unknowns. Documentation should enable design review, source generation and tests, not become bureaucracy.

## Design work packages

| Package | Primary owner document | Exit criterion |
| --- | --- | --- |
| Product roles and complete workflows | [Studio Platform Contract](studio-platform-contract.md) | Trace each major workflow to a graph operation and visible result |
| Graph schema, typed ports and hardware | [Project Graph](project-graph.md), [Hardware Targets](hardware-and-targets.md) | Valid/invalid representative fixtures specified |
| AUI language, types and composition | [AUI Language](aui-language.md) | Grammar draft + legal/illegal programs with expected diagnostics |
| Compiler and target lowering | [AUI Compiler](aui-compiler.md) | Phases, IR, ABI, output and error artifacts specified |
| Runtime, state, tasks and rendering | [AUI Runtime](aui-runtime.md) | Event-to-frame semantics, ownership and failure model specified |
| Components and palette | [Studio Platform Contract](studio-platform-contract.md) | Each builtin family has properties, ports, events, capabilities |
| AI context, authorization and approval | [AI Engineer](ai-engineer.md) | Request manifest and reviewable proposal transaction specified |
| UX architecture map + AI chat | [Workspace](workspace.md) | End-to-end select/propose/approve scenarios |
| Security, performance and targets | [Security](extension-and-security.md), [Verification](verification-plan.md) | Failure modes, costs and target-specific evidence defined |

## Decision discipline

Use **accepted**, **proposed**, **open** and **verified** labels with explicit evidence. Invariants belong to Architecture README; precise semantics belong to their owning documents. Do not copy whole contracts into multiple files. Record significant decisions in their owning specifications, without a separate historical ADR archive. Keep unverified assumptions visible.

## Design completion criteria

1. Every graph/component concept has unambiguous type, ownership and error semantics.
2. AUI code samples have exact expected type/effect/identity semantics.
3. Every compiler stage has inputs, outputs and diagnostics.
4. Every state/event/task/binding path has deterministic execution and failure policy.
5. Hardware access is capability-gated and separated from view presentation.
6. Multi-target requirements distinguish universal contracts from ISA/ABI-specific code.
7. Each major user workflow maps to contract tests/acceptance scenarios.
8. Each unresolved fundamental choice has a focused experiment and explicit pass/fail criteria.

## Immediate next design pass

Specify a versioned canonical Project Graph sample, formal AUI grammar draft, and one complete flow: sensor IRQ -> bounded task channel -> typed state -> architecture map visualization -> AI-proposed ASM driver change -> approval and local verification. Keep user-facing map central; AUI supports it.

## Design pass: grammar, compiler IR and runtime ownership

Detailed proposals now exist for restricted [AUI grammar and static diagnostics](aui-language.md), [typed compiler IR and target lowering](aui-compiler.md), [state identity, event-to-frame ordering and bounded channels](aui-runtime.md), plus the [sensor telemetry end-to-end design fixture](sensor-vertical-slice.md).

**Still open before design freeze:** final parser grammar; precise value/memory ownership and ABI representation; serialized graph format; effect-handler syntax; UI identity for dynamic loops; hardware device choice; target-specific layout/rendering. The fixture is illustrative and cannot be advertised as an executed program.

## Types and ABI design pass

- [Types and ownership](aui-types-and-ownership.md): explicit value/resource types, borrow/transfer rules, effect capabilities and concurrency classifications.
- [Component ABI and async commands](aui-abi-and-async.md): conceptual boundary categories, terminal-state semantics and per-target conformance.

These remain **proposed**. Before freezing them, define precise binary layouts, allocator API, address-space typing, borrow escape rules and cancellation race fixtures.

## Compiler backend and component execution

[Backend and execution design](aui-backend-and-execution.md) specifies graph-based linking, static/dynamic call selection, safe binding fusion, effect barriers and runtime scheduling boundaries. **Proposed, unverified.** Pending decisions include symbol mangling, MIR instruction set and platform scheduling.

## Project and package design pass

[Project and Package Format](project-and-package-format.md) now has illustrative machine-readable sensor project, package and map-view fixtures. Next: formal schema, deterministic normalization, dependency lockfile and negative fixtures. No parser or target code exists yet for these files.


Component catalog design: [AUI Component Framework](component-framework.md) (proposed).


[AUI Syntax and Semantics](aui-syntax.md) defines the current proposed extended grammar and rules for state, events, commands, bindings, tasks and modifiers. Syntax is not frozen or implemented.


[AUI AST and Semantic Analysis](aui-ast-semantic-analysis.md) defines compiler tree nodes, scopes, type/effect checking, bindings and TypedHIR output. Proposed and not implemented.


[OwnershipIR and Compile-Time Safety](aui-ownership-ir.md) specifies CFG-based moves, borrows, async boundaries, cleanup and rejection fixtures. Proposed; not implemented.


[AUI TargetMIR and Native Code Generation](aui-targetmir-native-codegen.md) specifies ISA-aware lowering, registers, stack, ABI, optimization limits and target-specific verification. Proposed; not implemented.
