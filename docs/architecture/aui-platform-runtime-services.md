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
