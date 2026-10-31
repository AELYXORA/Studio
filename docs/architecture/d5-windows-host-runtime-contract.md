# D5 — Windows x64 UI Host Adapter, Input, DPI, IME and Accessibility

**Status: PROPOSED FIRST-HOST ADAPTER CONTRACT; not implemented, approved, observed on Windows or measured.** This document refines the general [D5 UI Resource Budget](d5-ui-resource-budget-and-publication.md), [AUI Renderer](aui-rendering-layout.md), [Platform Runtime](aui-platform-runtime-services.md), [L4 Keyed Lifecycle](d3-keyed-dynamic-view-lifecycle.md) and [Win64 ABI](d4-win64-native-component-abi.md). The first-host candidate is Windows x64 user-mode with Win32 windows and a qualified CPU rendering path; GPU is an explicit optional capability, not a hidden dependency.

**External operating-system evidence (Windows behavior, not AELYXORA implementation):**
- [Microsoft High DPI desktop development](https://learn.microsoft.com/en-us/windows/win32/hidpi/high-dpi-desktop-application-development-on-windows) describes Per-Monitor v2 DPI awareness and WM_DPICHANGED.
- [Microsoft UI Automation provider overview](https://learn.microsoft.com/en-us/windows/win32/winauto/uiauto-providersoverview) and [server-side UIA provider guide](https://learn.microsoft.com/en-us/windows/win32/winauto/uiauto-serversideprovider) describe custom control accessibility and fragment providers.
- [Microsoft WM_GETOBJECT](https://learn.microsoft.com/en-us/windows/win32/winauto/handling-the-wm-getobject-message) documents how an HWND exposes a UI Automation provider.

## WI1. Host/process boundary

A Windows UI root is owned by one apartment-affine Win32 window/event-loop owner. All HWND, input, accessibility and view-generation mutations occur only through the verified UI-owner scheduler; worker/device/AI threads cannot directly dereference UI views or call back into destroyed HWND state. Window handle identities are opaque Win64 runtime handles, never GraphNodeID or persistent AUI source IDs. On HWND recreation the UI root receives a **fresh native-window generation** even if application-level graph/source identity remains the same.

Choose a Win32 desktop process manifest, DPI awareness, minimum supported Windows version, security mitigations and target-specific rendering backend **before approval**. This document proposes CPU raster fallback as necessary for functional first-host coverage; GPU may be enabled only with a verified adapter and separately budgeted memory. Exact Win32 import ABI and COM apartment ownership are D4/D5 P0, not inferred from the presence of a Win64 call frame.

## WI2. Message dispatch and event ordering

A Win32 message is **not** immediately a trusted AUI Event<T>. The adapter must map HWND + current generation + typed message source, validate focus/pointer/keyboard/IME origin, and reserve an AUI event ingress envelope before dispatch. Every event carries full keyed ViewIdentity path, incarnation generation, source/profile/graph snapshot identity and per-view ingress sequence.

Proposed rules:
1. Translate OS message into a typed input intent with known current window generation; unknown/stale HWND or accessibility element -> AUI_EVENT_STALE.
2. Reserve within D5 per-view max 64 and root aggregate max 8192 event envelopes AND 8 MiB bytes. Failure -> AUI_EVENT_QUEUE_FULL, **no user-command dispatch**.
3. Preserve FIFO order **within a ViewIdentity** under UI-owner scheduler; no global OS-to-AUI order promise across windows, controls or worker channels.
4. Coalesce only render invalidations and pointer-move types for which a future explicitly approved coalescing policy proves no semantic loss. Do not silently coalesce activation, keyboard edit, command admission or provider result.
5. Avoid reentrant cross-domain calls, blocking device I/O and unrestricted recursion in WndProc. Use deferred owned messages and length-validated payloads.
6. On window destroy, immediately close old-generation event/task subscriptions; retain any provider-owned buffers, GPU frames and OS callbacks until their own verified teardown fences.

Exact message taxonomy, reentrancy, pointer capture, hover, keyboard repeat, drag/drop and window chrome remain D5 design P0. An OS event queue cannot be counted as if it were already a bounded AUI ingress queue; the adapter needs separate backpressure/observation metrics.

## WI3. Per-Monitor v2 DPI and layout

Candidate host is **Per-Monitor V2 DPI aware**. On DPI change, the window adapter reads the new supported DPI/scaling state, validates WM_DPICHANGED and proposed rect, and submits a **pure layout/invalidation transaction** keyed by the same live ViewIdentity generation. DPI changes never mutate graph semanticGraphDigest, TaskTickets or local StateRevision *unless* an explicitly documented UI state property actually changed.

Coordinate systems are distinct: target-independent logical layout units, device physical pixels and screen coordinates. Hit-testing must use a committed scene/geometry epoch consistent with its ViewIdentity generation; pending frame re-layout is never permission to route a click to a different keyed row occupying the same pixels. Round/scale operations need an approved deterministic policy for fractional DPI, font metrics and monitor crossings. No assumption that Windows automatically scales an entire custom-drawn UI correctly.

Resize, monitor unplug/reconnect, minimized surface and high DPI/RTL font shaping are future native tests. A visual frame missed during resize must not roll back committed state or retry a provider effect.

## WI4. Text input and IME

The text adapter must specify and implement a **Windows text services contract** (candidate TSF integration, with only explicitly qualified fallback as applicable) for input method composition, caret bounds, selection, candidate UI and focus. Native COM interface marshalling, reference counts, owner apartment and shutdown are not portable AUI values. AUI String is Unicode scalar value/UTF-8 at typed boundaries; Win32 wide text and input/composition payloads require strict conversion and cannot split surrogate pairs.

On removal or reparent of the focused keyed row:
- revoke old input target and generation first;
- end/cancel old composition through the platform adapter, without committing old text into the new row;
- apply the candidate deterministic D5 focus successor/previous/ancestor policy only after the new committed view tree exists;
- reject any delayed composition/candidate callback with the old generation;
- release COM/TSF resources after safe callback drain, not by assuming visual disappearance implies lifetime end.

IME compatibility, language layouts, dead-key/emoji composition, left-to-right/right-to-left text and screen-reader interaction remain Phase III native test obligations. Unsupported input methods must produce explicit capability diagnostics, never silently corrupt text.

## WI5. UI Automation/accessibility

For custom-rendered controls, the Windows adapter supplies an appropriate **UI Automation provider tree** rather than relying on default Win32 control providers that do not know AUI's drawn nodes. WM_GETOBJECT for the root HWND must be handled according to Windows UIA contracts; accessible fragment elements reflect the **committed logical tree**, with stable runtime identity derived from keyed ViewIdentity **and generation**. Actual UIA COM interfaces, reference counting and client callback policy are native D5-owned implementation concerns.

Each reachable control declares role, accessible name, enabled/focusable state, appropriate Invoke/Value/selection patterns and children. Duplicate/removed view keys cannot alias the same UIA runtime ID. Reordering preserves the same element identity while adjusting navigation order; removal reports invalidation and rejects stale UIA queries/actions rather than triggering a new row with the same visual index. UIA observers may outlive visible elements, so adapter-owned providers need bounded generations and lifetime accounting.

Support Windows keyboard-only navigation, high contrast, larger text, reduced motion and correct accessibility focus announcements as **acceptance requirements**, not presumed passing tests.

## WI6. Native render surface, resource quotas and failure

First-host render contract is CPU-raster functional baseline when explicitly approved, with a separately versioned GPU backend as an optional capability. Surface create/resize/destroy, color-space/alpha, scaling, frame submission/present and device loss have typed outcomes. Only **two** outstanding frame submissions per UI root is a candidate, not a measured engine capacity.

D5's proposed **160 MiB UI root heap accounting** excludes Windows kernel window handles, GPU textures, external font caches and provider/DMA allocations. Each gets an explicit adapter budget and process-level aggregate; if not measured/qualified, the host must report that its physical memory guarantee is **unverified**, not pretend to enforce an overall 160 MiB process cap. A renderer failure after a committed UI StateRevision leaves committed state intact and never reissues external commands.

## WI7. Windows host test matrix — all NOT-RUN

| Scenario | Required result |
| --- | --- |
| Win64 PE/COFF module and UI adapter import/unwind | Correct Win64 ABI and valid .pdata/.xdata where required |
| Per-Monitor V2 monitor transition and 100/125/150/200% DPI | Correct input positions, text, layout and no GraphRevision mutation |
| Monitor remove/window minimize/resize while frames queued | Generation-safe surface teardown and bounded frame owner |
| Rapid key/pointer/activation messages at root queue limits | No silent intent drop with false success, bounded counted pressure |
| Remove/reinsert row with same StableKey during queued Windows message | Old generation rejected, new component not activated |
| Reorder focused list while UIA client inspects tree | Stable element identity, updated traversal order |
| Remove focused TextField during active IME composition | No stale text into successor, safe COM/TSF teardown |
| Screen reader requests removed fragment provider | No use-after-free or remapped wrong element |
| Rendering backend fault after UI StateRevision commit | State preserved, provider operation not retried |
| Multi-window heaps + GPU/font/OS handles under load | Measured and enforced separately aggregated quotas |
| Thread/apartment shutdown while UIA callback is outstanding | No callback-after-release and bounded cleanup |
| Windows x64 with optional GPU unavailable | Explicitly tested fallback or unsupported capability |

No actual AELYXORA Windows HWND, IME, UIA, renderer, ABI probe or latency/heap measurement is claimed here.

## WI8. Remaining P0 architecture acceptance decisions

First Windows build range and manifest, OS security mitigation policy, exact TSF/COM text service mapping, Win32 message normalization, UIA fragment/control-pattern mapping, CPU raster surface API, GPU negotiation/fallback, host-wide memory/event quotas, native allocator/thread shutdown and full D4 Win64 ABI verification. Windows/NTFS **project persistence durability** remains a separate D6 filesystem qualification, not guaranteed by UI host support.
