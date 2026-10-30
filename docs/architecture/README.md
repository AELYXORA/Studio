# AELYXORA Studio — Architecture

**Product invariant:** the primary UI is one interactive **Architecture Project Map + contextual AI Chat** for designing and implementing **software close to hardware**. A form designer, file explorer and code editor are subordinate views.

## Experience

- **Center: live architecture graph.** Modules, components, interfaces, devices and runtime services are typed nodes; dependencies, data/control flows and resource ownership are typed edges. Mind-map ergonomics, UML-level precision. Zoom, groups, navigation and selection are map affordances, not architecture truth.
- **Side: AI chat.** Chat is dockable and grounded in the user's explicitly selected node or subgraph. The UI shows exactly which contracts, code and diagnostics would be sent. AI proposes a change set; an architectural/source diff and verification precede human approval.
- **Details on demand.** Component contracts, Assembly source, registers, test evidence, declarative UI and debugging views open from map nodes. No disconnected secondary source of truth.
- **Human architect / AI implementer.** Human owns boundaries, semantics and approval; AI predominantly writes and tests components, not silently restructures the graph.

## Hardware-aware project graph

Each node can carry target triples, ISA extensions, ABI/calling convention, execution context (user/kernel/firmware), hardware capabilities, memory ownership/alignment, resource ranges, thread/interrupt constraints, and supported toolchains. Explicit graph kinds include **CPU/SoC, device, bus, driver, firmware interface, protocol, runtime service, component and external dependency**. Typed edges may express **calls, events/interrupts, data flow, MMIO/I/O access, DMA ownership, protocol and dependency**.

Hardware constraints are **optional typed capabilities**, not clutter on every node. Hard gating matters: an unsafe or unsupported IRQ/MMIO/DMA operation must not be inferred from an attractive diagram. Require target-specific tests; on-device debug and physical access are later capabilities.

## System boundaries

```text
     Interactive Architecture Map  |  Contextual AI Chat
                         |
          Typed Project Graph + Contracts
                         |
      Human-reviewed transactions and AI proposals
                         |
       Assembly components + device/OS adapters
                         |
       LLVM/Clang toolchain + local verification
                         |
               Supported hardware targets
```

- **Studio technology:** own declarative UI framework and Assembly-first core. No Qt/QML/C++/FMX runtime in the intended Studio stack.
- **Portability:** graph and ABI contracts are target-neutral; native Assembly is ISA-specific and OS/ABI-specific.
- **AI:** officially supported authorization only. ChatGPT Plus is not automatically a general API credential. AI access is unimplemented. Local project work never requires an AI login.
- **Safety:** select context → propose → validate → inspect graph/source diffs → approve → apply → locally test. No untrusted hardware operations in IDE process; builds/probes are isolated where supported.
- **Evidence:** every status distinguishes supported/unsupported and passed/failed/not tested, per target. No CI until release preparation.

## Minimal product milestone

A native AELYXORA window containing **architecture map plus contextual AI chat area**; load a hardware-aware project graph, select a component, inspect its contracts, create an approved change, and see local build/test evidence. Chat can be a clearly marked non-connected UI placeholder until official authorization is available.

**Reality:** currently there is only an x86-64 Linux Assembly UI-tree validator. The map, renderer, chat, graph schema and hardware integrations do not yet run.

## Documentation policy

This document is the **canonical architectural source**. [Roadmap](../product/roadmap.md) defines a small set of proof-oriented gates. Technical contracts are supporting references; don't generate parallel strategy documents that contradict this one. Review consequential design shifts through ADRs only.

References: [Declarative UI](declarative-ui.md), [Assembly ABI](assembly-first.md), [Component contracts](component-contract.md), [State and bindings](bindings-and-runtime.md), [Security](extension-and-security.md).
