# AUI Platform Abstraction and Native Runtime Services

**Status: proposed specification; nothing implemented or verified.** This document owns the boundary between AUI runtime and OS/device services. [AUI Runtime](aui-runtime.md) owns state/events; [TargetMIR](aui-targetmir-native-codegen.md) owns machine lowering; [Hardware and Targets](hardware-and-targets.md) owns hardware constraints.

## 1. Boundary architecture

```text
AUI components / Project Graph
       -> portable typed Runtime Services
       -> capability-gated Platform Service Interface
       -> per-OS/per-target Assembly adapter + system APIs
       -> kernel/compositor/device
```

Platform adapters are **not UI component definitions**. Their handles and native messages never become canonical Project Graph identity. Each service reports supported/unsupported/unknown and separately passed/failed/not-run per target.

## 2. Service contracts

- **Window:** create/close, surface size, DPI, fullscreen, visibility, focus, lifecycle; failures report OS diagnostics. Window ownership and destruction on correct thread are mandatory.
- **Input:** keyboard/scancode and text input are distinct; pointer, touch, wheel, drag, focus, clipboard and IME report typed events. Untrusted text must not become executable instructions. Key-repeat and event timestamps have defined origins.
- **Graphics:** renderer capabilities (CPU raster/GPU backend, format, color space, presentation), begin/submit/present with explicit synchronization and surface-loss recovery. No GPU availability assumed.
- **Text:** font discovery/loading, shaping, Unicode bidi, grapheme navigation, cursor, selection and accessibility semantics; raw glyph drawing alone is insufficient for editable UI.
- **Accessibility:** semantic tree, roles, labels, focus, actions, notifications and platform screen-reader bridge. Unsupported capability is explicit.
- **Memory:** reserve/commit/release and allocator handles with quotas, page alignment and executable-memory permissions. Never assume RWX pages.
- **Concurrency:** thread creation, scheduling/domain affinity, atomic/thread primitives, synchronization, bounded channels and shutdown. IRQ context is not a portable user-mode thread.
- **Clock/timer:** monotonic deadline, wall-clock time, timer resolution/cancellation, suspend/resume semantics; no claimed hard realtime without target evidence.
- **Filesystem:** normalized paths, capabilities, atomic-file replacement when supported, flush/durability and sandbox limits. Project commit uses multi-file protocol, not one rename.
- **Network/process:** explicitly gated sockets, DNS/TLS through declared providers, process spawning, environment, diagnostics and permission checks.
- **Devices:** enumerate/open/mapped memory/interrupt/DMA operations only via target-specific capability providers; user-mode adapters cannot silently escalate privileges.
- **Diagnostics:** structured errors, tracing, performance counters and backend identity; instrumentation is optional where zero-cost builds require it.

## 3. Handle and error discipline

Every platform resource is an opaque typed handle with owner, generation, execution domain and close contract. No raw OS handle is serialized into a project. API outcomes use stable AUI error categories plus optional native OS code; no OS exception crosses an Assembly component ABI.

Destroying a window cancels its input subscriptions, invalidates view generation and drains associated frame submissions. In-flight I/O and DMA retain their true owner until safe completion. No callback-after-destroy.

## 4. Event loop and rendering

OS event pump -> normalized event envelope -> AUI command dispatch -> committed state revision -> layout/scene invalidation -> renderer submission. Render/UI thread affinity is explicit. No synchronous blocking device I/O in input handlers. Presentation may lag state revision; failed present does not repeat commands.

Input event coalescing is allowed only for events where semantics permit it (e.g. pointer motion), never for key/text composition or ordered commands without a policy.

## 5. Capability negotiation

ServiceDescriptor includes: service ID, contract revision, target triple/environment, supported operations, required permission, execution domain and limits (e.g. max textures, timer granularity). Required capability failure blocks load/operation with an actionable diagnostic; optional capability fallback must be explicitly specified and testable.

There is no universal implicit dependency on desktop windows: headless applications, daemons and firmware targets select only the runtime services they need.

## 6. Target adapter expectations

| Platform | Native integration and constraints |
| --- | --- |
| Windows x64 | Win32 windows/messages, graphics backend selection, IME/accessibility, Win64 ABI, COFF/unwind |
| Linux x86-64 / ARM64 | Wayland or X11 adapter choice, compositor protocol, EGL/Vulkan or CPU fallback, ELF, font/input APIs |
| macOS ARM64 | AppKit/CoreGraphics/Metal and accessibility through OS ABI adapters, Mach-O and Apple platform requirements |
| Android ARM64 | Android lifecycle, surfaces/input/IME/accessibility, NDK/JNI or platform bridge as needed, sandbox and AArch64 ABI |
| Bare metal / RTOS | no presumed window/desktop services; board-specific framebuffer, input, memory, clock and hardware authority |

These are **integration targets**, not supported platforms today. Native OS APIs may require non-Assembly bridges at externally imposed interfaces; they are isolated adapters, not a Qt/C++ UI dependency.

## 7. Verification matrix

1. Create/resize/close a window; enforce thread affinity and no callback after destruction.
2. Route keyboard, UTF-8/IME composition and pointer/touch without information loss.
3. Render and recover from surface loss with committed state preserved.
4. Exercise focus, keyboard and accessibility role/label/action semantics.
5. Fail deterministic allocation quota and executable-memory permission checks.
6. Cancel timer/task during suspend/resume and destroy without use-after-free.
7. Reject prohibited filesystem/device/network operations before OS access.
8. Validate atomic save/recovery under process interruption on each filesystem target.
9. Headless target links without window/renderer dependencies.
10. Collect code size, allocations, event latency and frame scheduling overhead against comparable native implementations.

## 8. Open design decisions

First GUI OS/backend, precise platform service ABI and dispatch table layout, font shaping library/implementation, rendering backend strategy, memory allocator ABI, scheduler/event-loop policies, JNI/Objective-C integration and per-target security sandbox policy. No CI until release preparation.

## L4 generation-checked platform input and accessibility (PROPOSED)

[L4 Keyed Lifecycle](d3-keyed-dynamic-view-lifecycle.md) requires OS focus, keyboard, pointer, IME and accessibility event targets to use live ViewIdentity plus generation, not a reusable visual index. Removal/replace closes old subscriptions and focus targets before subsequent event routing; a GPU frame may lag the committed view revision without granting an old node a new owner's action. Native callback unsubscribe/drain, view-owned OS handle generation checks and resource owner retention must be proven per platform. [D3/D4/D5 review](d3-d4-d5-lifecycle-consistency-review.md) specifies test obligations; no platform is yet verified.

## Candidate D5 root and OS adapter quota boundary — PROPOSED

[D5 UI Resource Budget](d5-ui-resource-budget-and-publication.md) proposes a 160 MiB per-root accounting envelope and separate simultaneous limits for view event count/bytes, task/result admissions, scene metadata and detached owner cleanup. This budget explicitly **excludes native GPU/OS/device/DMA bytes**, which require independently bounded platform adapter quotas plus a process-level multi-root ceiling. [D4 Value ABI](d4-core-value-abi-contract.md) requires exact native layout and ownership proof, not inferred ABI from portable core bytes. [D3/D4/D5 core review](d3-d4-d5-core-contract-review.md) tracks unverified target capabilities. No Windows or Linux resource/latency measurement exists.


## Compiler-required runtime service import closure — full AUI L0–L4 (PROPOSED, not ABI)

The [full production AUI compiler](aui-compiler.md) may emit native code only against a **closed, reviewed, target-qualified runtime service table**. The following is the *minimum logical service inventory* needed to support the complete shipping L0–L4 language; it does **not** invent Windows function names, native struct offsets, COM vtables, ABI calling conventions or executable authority. For Win64, [D4](d4-win64-native-component-abi.md), [D5 Windows](d5-windows-host-runtime-contract.md) and [module descriptors](d4-win64-module-and-result-descriptors.md) must freeze every exact native import symbol/signature, data layout, ownership and failure result before the compiler claims native support.

| Required logical service | Compiler emission | Target/runtime obligation |
| --- | --- | --- |
| Static View construction/update/destroy | L0 immutable View template and ordered native descriptors | Verified renderer owner/generation, bounded strings, safe detach and source accessibility metadata |
| Event attachment + local typed dispatch | L1 Event<Unit>, Button activated route and command request intent | UI-thread ingress, per-ViewIdentity FIFO/backpressure, no reentrant handler, no implicit provider permission |
| State allocation/read and atomic commit | L2 typed StateSlot/StateRevision, initialized property and commit transaction | Owner/generation CAS, rollback on error, typed changes and atomic render invalidation |
| Derived dependency + bound property update | L2 checked pure DAG and single binding writer | No effectful callbacks, ordered recomputation, missing/changed key error and bounded resource budget |
| Provider admission and typed operation dispatch | L1/L3 verified OperationID, source/Graph/target/capability closure | Live permission, exact result/error ABI, safe ownership transfer and observable admission rejection |
| TaskSlot reserve/submit/settled/cancel | L3 source-declared TaskSlot<T,E> and AsyncIR transition machine | Single active ticket, bounded queue, trusted terminal CAS/quiescence, late completion/unknown-effect cleanup |
| Keyed list snapshot and reconciliation | L4 List<T>/StableKey, source template and full parent-key path | Duplicate/stale keys, generation-scoped create/reorder/remove, no positional fallback, bounded retained owners |
| Renderer layout/text/accessibility/IME | L0–L4 view metadata, labels, input and focus origins | Qualified Win32/CPU raster, DPI/IME/UI Automation, native error codes, budgeted text/font and surface handles |
| Module validation/trust/loader | Exact GraphLinkedIR module dependencies and target/layout ABI identity | Signed/approved read-only operation/module tables, import whitelist, live capability and generation-specific execution |
| Runtime teardown and error reporting | Explicit OwnershipIR cleanup, dropped state, cancelled/stale result | Safe unmount and provider resource retention until quiescence; bounded diagnostic redaction and no native pointer escape |

**Mandatory binding fields for every eventually approved service:** target ABI version, exact exported symbol or ordinal within an immutable module descriptor, complete typed inputs/outputs/errors, owner/lifetime/retain/drop rules, execution domain and reentrancy, effect/capability checks, cancellation and cleanup obligations, resource quota, source and Graph origins and negative ABI test vectors. A compiler may not assume a service merely exists because an illustrated `Text()` or `taskSlot` source fragment compiles.

**Missing native import contract => target unsupported / link error**, not a fallback JSON interpreter, silent no-op or direct unchecked OS call. This remains a **Phase I design checklist**; no runtime service has been implemented, ABI-checked or approved through this document.
