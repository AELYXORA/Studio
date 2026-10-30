# Architecture Design Closure — Canonical Sensor Slice

**Status: proposed integration contract, no runnable implementation.** This document closes the type-identity ambiguity in the sensor example at design level and defines one traceable end-to-end scenario. It does not certify the compiler or hardware.

## Canonical type identity

A port's `type` is a canonical exported type ID (`packageId/typeName`), not a short display name. Each package exports `types` with unique IDs and a structural description. Type references resolve through the exact selected package; no implicit cross-package equivalence. A port connection is valid when canonical type IDs agree, or when an explicitly declared pure conversion adapter is present. ABI representation and address-space compatibility remain separate checks.

For the sensor fixture, `example.sensor/RawSample` is bytes plus acquisition metadata and `example.sensor/Measurement` is a validated value plus status. The driver emits RawSample, decoder consumes RawSample and emits Measurement, application consumes Measurement. Hardware bus ownership and IRQ details require actual target profiles; they are not inferred from the drawing.

## End-to-end design trace

1. Project Graph locates ARM64 target, I2C device, driver, decoder and app by stable IDs.
2. Package resolver resolves type definitions and component port contracts. No unresolved IDs, duplicate writers or mismatched edge direction may pass.
3. User selects driver and requests AI implementation with declared source scope and approved context.
4. AI returns proposed ASM source and tests without project writes.
5. Graph/source diff undergoes type/effect/ownership/target validation, then explicit human approval.
6. Compiler analyzes AUI syntax to AST and TypedHIR, then OwnershipIR and TargetMIR.
7. Target-specific backend lowers to AArch64 code and platform ABI; status remains **not run** until actual build and tests.
8. At runtime, a device completion passes through an explicit bounded channel and typed worker into observable state and a one-way UI binding. Physical execution remains unverified.

## Contract boundaries

Project Graph is the authoritative identity/architecture layer. Package export metadata owns type definitions. AUI.Syntax owns source grammar. TypedHIR performs name/type/effect checks. OwnershipIR proves resource transfer where possible. TargetMIR emits target-dependent calls. Device adapters enforce capability authorization. Rendering is a presentation of committed state; map position never affects behavior.

## Design verification

Accept the sensor fixture only if each port resolves to a unique package type ID and every data-flow edge has compatible direction/type. Reject unknown type IDs, duplicate exports, accidental short names and unsupported target capability. A semantic graph hash must not change when only map positions change. This is a specified expectation, not an observed test result.

## Open before design freeze

Formal serialization schema, package lock/hash procedure, complete AUI event wiring syntax, source/graph reconciliation, actual ABI descriptors, physical device profile and first runnable platform. None is claimed implemented.
