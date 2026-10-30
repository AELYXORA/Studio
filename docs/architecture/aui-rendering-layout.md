# AUI Rendering and Layout Engine

**Status: proposed architecture specification; not implemented.** This document owns layout, scene building, hit testing, frame scheduling, and rendering semantics. [AUI Runtime](aui-runtime.md) owns state revisions; [Platform Services](aui-platform-runtime-services.md) owns native graphics/input backends; [Component Framework](component-framework.md) owns visual definitions.

## Pipeline and invariants

```text
Committed state snapshot -> immutable View description -> reconciliation
 -> constraint layout -> semantic tree + hit-test index
 -> retained Scene Graph -> incremental Display List
 -> CPU/GPU backend -> presented frame
```

No renderer may mutate canonical Project Graph or component state. A render failure preserves the last committed state. Scene and visual map coordinates are separate from architectural identity. Rendering is optional for headless services.

## Geometry and measurement

Geometry uses logical device-independent units with finite values and explicit conversion to physical pixels. A parent proposes min/max constraints; each child reports a size satisfying valid constraints; parent assigns final position. Define zero/infinite/unbounded proposals explicitly and reject NaN/negative sizes. Layout values are target-neutral, not raw physical DPI coordinates.

Two-pass measure/layout is the baseline contract. Layout must be deterministic for the same font metrics, constraints, locale and immutable state. Children cannot invoke arbitrary I/O during measurement. Layout primitives:
- Stack/HStack/VStack: ordered children, spacing, alignment, intrinsic dimensions and flexible distribution.
- Grid: explicit tracks, gaps, min/max policy and span collision rules.
- Overlay: common bounds, alignment, ordered stacking.
- Scroll: viewport size independent of content extent, clipping and offset bounds.
- Text: intrinsic measurement from shaping and line-breaking; async font availability invalidates the owning layout subtree explicitly.
- Architecture Map: world-space coordinates and zoom/pan transforms; dragging a visual node does not alter typed graph relationships.

## Scene and display list

Scene nodes have runtime ViewIdentity, transform, clip, opacity, stacking order, paint resources, accessibility semantic reference and geometry revision. Display-list commands are conceptually PushTransform, PushClip, DrawRect, DrawPath, DrawGlyphRun, DrawImage, DrawLayer and Pop. Their exact binary encoding is open.

Damage regions are conservative; dirty invalidation is allowed to fall back to full repaint for correctness. Resource handles are generation-checked. Changes to a glyph atlas or device scale must invalidate affected paint/layout caches. No cached drawing data becomes canonical application state.

## Text and accessibility

Unicode grapheme segmentation, bidirectional text, shaping, line breaking, cursor navigation, selection and IME composition are separate required contracts. Input may be UTF-8 but cursor offsets must not split user-visible grapheme clusters. Font metrics affect layout and are platform-dependent. Accessibility derives from the semantic component tree with roles, labels, focus order, actions and live regions; do not infer semantics from painted pixels.

## Input, focus and hit testing

Normalize keyboard, pointer, touch and composition events with time origin and source domain. Hit testing transforms pointer location into local coordinates, applies clips, checks visibility/enabled state and evaluates z order deterministically. Event routing is capture/target/bubble only if explicitly declared; pointer capture, focus transfer and gesture arbitration require separate contracts. Input handlers dispatch typed commands through runtime transactions and do not mutate render objects.

## Animation and frame scheduling

Animations are explicit transitions between committed state revisions, evaluated on a monotonic timeline. Define interruption, cancellation, reduced-motion, layout-versus-paint animation and deterministic test-clock behavior. GPU composition may accelerate transforms without requiring state updates each frame. Do not drop ordered semantic events when frames are skipped.

Coalesce invalidations into frames; respect surface visibility, vsync when available, frame deadlines and backpressure. UI thread cannot block on GPU or device I/O. Render thread ownership and fence/future lifetime are explicit.

## Backend contracts

CPU backend is a functional fallback where supported; GPU backend is capability-negotiated, not universally required. Texture upload, color spaces, alpha composition, DPI, surface loss, GPU reset and shutdown all have typed outcomes. No implicit allocation of unbounded render caches; memory budgets and eviction policy are observable. Android surface and desktop compositor lifecycles are different adapters.

## Acceptance fixtures

1. Nested VStack/HStack/Overlay produces exact bounds under fixed font metrics and constraints.
2. Grid and scroll reject invalid/NaN sizes and preserve clipping/hit testing.
3. Window resize and DPI changes recompute affected layouts without changing component identity.
4. Bidi/IME editing and grapheme-safe cursor movement preserve text correctness.
5. Hit-test chooses the topmost enabled visible target after transforms and clips.
6. Accessibility focus and labels remain correct across reconciliation.
7. Reduced motion disables nonessential motion without losing state changes.
8. Surface loss and GPU reset preserve state; fallback policy is explicit.
9. Animation cancellation and out-of-order completion never repeat effectful commands.
10. CPU/GPU output comparison uses tolerated pixel differences and separately reports timing and memory use.

## Open decisions

Final numeric layout model, font/text shaping implementation, vector-path representation, shader/color pipeline, GPU backend choices, scene diff strategy, input gesture recognizer and native accessibility bridge APIs. No platform rendering support is verified.
