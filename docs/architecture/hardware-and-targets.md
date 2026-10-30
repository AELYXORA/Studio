# Hardware Development Model and Target Contracts

**Status:** specification; hardware debugging/deployment is not implemented.

## Target profiles

Each build target identifies ISA (x86-64, AArch64, etc.), ISA feature requirements, operating environment (Linux, Windows, macOS, bare-metal, firmware, RTOS), ABI/calling convention, pointer size, endian, object format, linker mode and privilege context. An assembler's ability to parse an instruction is **not** proof that the program can run on that device.

## Hardware primitives

Typed entities: CPU/SoC, buses, memory map, MMIO regions, device registers, interrupt sources, DMA engines/buffers, clock/reset, firmware interfaces, transport/protocol, driver and application.

Typed contracts describe register width/endian, read/write side effects, volatility, alignment, access privilege, timing barriers, exclusive ownership, interrupt acknowledgement, DMA direction, cache coherency and allocator lifetime.

## Safety

Studio is not a driver and does not access physical hardware by default. Actual memory access, flashing, reset, debug attach or firmware deployment requires platform-specific adapters, explicit user approval and protection against the wrong target. Unsafe operations must never be executed as a result of unreviewed AI output.

Examples of hard failures: address mapping conflicts; access to a privileged register from user mode; ABI mismatch; incorrect required alignment; missing memory barrier rule; unsupported interrupt mode; exclusive DMA buffer with two owners.

## Example vertical slice

For a real or simulated sensor: declare SoC -> I2C bus -> sensor register map -> driver -> sample protocol -> telemetry app. Generate an Assembly driver interface against a mock transport first. Test register widths, transaction failure, concurrency constraints and target ABI; only after passing simulated gates should actual-device testing be considered.

## Portability matrix

Each component has **supported**, **planned**, **unsupported** and **tested** metadata per target, with links to evidence. Never collapse a simulator run into physical-device proof. Architecture-neutral contracts can be shared; assembly source is target-specific. Platform adapters are part of target support, not implied by source code.

## Typed first candidate — documented, not authorized

[D2 Hardware Resource Contract](d2-hardware-resource-contract.md) now proposes the explicit 0.2-hw-draft resourceModel field inside the **same canonical Project Graph**: target requirements and typed MMIO, IRQ, DMA, memory resource claims tied to resource-access edges, owners and targets. The [sensor proposal fixture](../../examples/architecture-sensor/hardware-resource-profile-project.auiproj.json) demonstrates all four claim shapes; its original package is not lock-resolved and no native device behavior is asserted. [29 future negative cases](../../examples/architecture-sensor/hardware-resource-negative-cases.json) specify structural/security failures, NOT-RUN. [D2↔D3 Command Boundary](d2-d3-hardware-command-boundary.md) prohibits direct AUI device access and requires live permissions beyond static graph declarations.
