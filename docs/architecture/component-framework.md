# AUI Visual and Nonvisual Component Framework

**Status: proposed technical specification, not implemented.** [Studio Platform Contract](studio-platform-contract.md) owns user workflows and palette scope; [Types and Ownership](aui-types-and-ownership.md) governs memory; [AUI Runtime](aui-runtime.md) governs scheduling.

## Component identity

A ComponentDefinition has stable type ID, contract version, visual/nonvisual category, properties, ports, commands, events, child slots, target capabilities, affinity/effects, ownership, validation, accessibility and source ownership. A ComponentInstance is a stable Project Graph node. A PaletteEntry references a definition; runtime ViewIdentity is a distinct reconciled path. Moving a map node never changes its behavior.

## Properties and binding

Each property defines Type, units, default/required, mutability, owner, validation, notifications, and execution domain. Updates are validated graph/state transactions. Inputs, state, computed values, user-edit intentions and outputs are distinct. Binding is typed and one-way by default; two-way interaction requires an explicit edit/commit pair. Disallow implicit lossy conversions, conflicting writers and synchronous feedback without a delay boundary.

## Events, commands and tasks

Events carry immutable typed payload, origin and sequence domain; they do not grant permission. Commands declare effects/capabilities, typed result/error, scheduler domain, deadline and cancellation. Task/Worker/Channel components declare bounded queues, transfer ownership, terminal outcome and generation validation. UI callbacks cannot block on I/O, and IRQ handlers cannot render or allocate unbounded memory.

## Lifecycle and composition

Declared -> validated -> instantiated -> active -> suspended (optional) -> deactivated -> disposed. State survives reconciliation only when component type and stable identity are compatible. Disposed instances reject stale completions; ongoing device resources must be safely drained. Composite components have typed child slots and cardinality rules; invalid child placement is a compiler error.

## Visual palette families

Surface: Window, Surface, Dialog, Popover. Layout: VStack, HStack, Grid, Stack, ScrollView, SplitPane, Tabs, Group. Content: Text, RichText, Image, Icon, Canvas. Input: Button, Toggle, Checkbox, Radio, TextField, TextArea, NumericField, Slider, Select. Data/navigation: List, Tree, Table, Menu, Toolbar, Progress, Status. Studio map: ArchitectureNode, TypedPort, Connector, GroupOverlay, MiniMap, DiagnosticOverlay.

Each family needs a separately versioned metadata contract, keyboard/focus/accessibility semantics, localization, intrinsic size and rendering requirements. Support is declared per target; a missing renderer cannot silently pretend compatibility.

## Nonvisual palette families

State, Observable, Derived, Binding, Command, EventSource, EventBus, Timer, Task, Worker, Scheduler, CancellationToken, Channel, Queue, Buffer, Atomic, Mutex, Stream, Serializer, File, Storage, Query, NetworkClient, Socket, ProtocolCodec, Log, Trace, Metric, TargetProfile, Device, Bus, RegisterMap, MMIORegion, InterruptSource, DMABuffer, DriverInterface, SimulatorAdapter, Toolchain, BuildTarget and TestRun.

These are candidate API definitions, not proof that every family needs a runtime instance: pure/static components may be compiled away.

## Layout, rendering and design-time

Parent proposes constraints; child computes intrinsic/min/max size; parent positions. Define clipping, z-order, DPI, transforms, scroll, hit-testing and RTL. Layout must remain free of device effects. Renderer consumes immutable scene data; accessibility derives from semantic structure, not pixels.

Palette selection -> create graph instance -> inspector edits typed properties -> connect typed ports -> validate capability and layout -> review transaction -> persist revision. Design-time does not grant physical hardware permissions. Undo/redo is revision-aware.

## Zero-cost and verification

Statically known pure calls/bindings may lower directly or inline; no mandatory heap registry. Dynamic components explicitly pay for dispatch and capability checks. Measure allocations, code size, latency and throughput against equivalent native Assembly.

Negative fixtures: duplicate writer, wrong-port type/direction, illegal child slot, non-Send worker transfer, stale callback, missing accessibility role/label for interactive control, unsupported device capability, unbounded queue and unsafe IRQ action.

**Open:** exact event handler grammar, layout unit system, accessibility adapter signatures, platform widget support matrix and per-widget property/event schemas. All remain unverified.
