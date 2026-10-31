# AELYXORA Studio — Architecture, Implementation and Verification Roadmap

**Current phase: architecture documentation (PROPOSED).** One product, one [Canonical Project Graph](../architecture/canonical-project-graph-and-components.md). No numbered product/architecture editions. Actual status: [PROJECT-STATUS](../architecture/PROJECT-STATUS.md). Human acceptance is required before Phase II.

## Phase I — finish a single coherent architecture

**D1 — Studio product and workspace:** interactive architecture map, context-aware AI review, visual AUI, source and diagnostics projections, human approval and no hidden graph.

**D2 — semantic Project Graph:** exact component/port/operation and type-export contracts; topology and typed edges; complete workflows/signals/transitions and deterministic runtime bounds; typed dataFlows; hardware MMIO/IRQ/DMA/memory claims, target constraints, retired stable IDs; source-of-truth projection and canonical hash.

**D3 — declarative AUI and compiler contract:** typed source, State/Derived/Bind, Task/Result, keyed collection identity and generation, typed source-to-Graph linking, complete diagnostics, no direct OS/device privilege.

**D4 — native component ABI and ownership:** exact Win64 and other qualified target-specific conventions, layout descriptors, allocator/retain/drop, ownership/borrow/Send, cancellation/terminal race, module trust and live capabilities.

**D5 — UI host/runtime:** bounded event/task queues and memory accounting, atomic desired-tree publication, renderer, Windows input/DPI/IME/accessibility, safe teardown and recovery.

**D6 — persistence, package and approval:** verified offline package/type closure, deterministic and authentic build inputs, signed architect/release review, immutable source/Graph snapshot and platform-qualified crash durability.

**D7/D8 — complete architecture verification:** unified cross-document consistency, threat and failure tests plan, explicitly recorded architect decisions and exact evidence/known blockers. No automatic acceptance based on documentation.

Required Phase I review fixture: one *single* typed project containing an operationally meaningful workflow, bounded channel, hardware claims where relevant, and a typed component package. [Synthetic sensor example](../../examples/canonical-graph/README.md) is a first illustration; its SHA-shaped strings are **not** real contract evidence.

## Phase II — implementation after approval

Implement native canonical graph parser/validator; type and component export resolver; workflow/data-flow engine; AUI front end/runtime, platform adapters, signed approval, Win64 ABI and D6 persistence. Keep Assembly-first core; no Qt/QML/C++ application runtime. No experimental implementation in place of an unapproved normative decision.

## Phase III — verify on actual targets

Run independent canonical hash/Unicode and negative graph semantic fixtures, ABI layout/prolog/unwind checks, allocator and callback lifetime races, bound/FIFO/admission and task cancellation tests, Win32 DPI/IME/UIA/renderer and device restrictions, signed publisher/approval trust tests, deterministic PE/PDB rebuilds, NTFS crash/fault injection and measured performance. Record toolchain, target, artifact digests, pass/fail/not-run.

## Phase IV — defects, hardening and release

Fix failures, repeat security/ABI tests and reproduce release artifacts; release only after explicit gates pass. No GitHub Actions/CI until release preparation.

**Next concrete Phase I decision:** approve the one full meaning-bearing Graph and Component Package schema and the corresponding complete canonical semantic projection; reconcile typed workflow signals/data-flow transfer and resource/ownership constraints; then attach authentic source/Graph review without inventing another versioned architecture.
