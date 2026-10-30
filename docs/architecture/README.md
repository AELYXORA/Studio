# AELYXORA Architecture

**Direction:** own Assembly-first declarative RAD environment. **Status:** experimental architecture and minimal native validator. No working graphical IDE.

## Non-negotiable foundations

1. **Human-led architecture:** human architect owns types, layout semantics, component boundaries, decisions, security and acceptance criteria.
2. **AI as component engineer:** proposes and implements code under reviewable contracts; does not silently redesign the system.
3. **Our own declarative language and UI runtime:** no Qt/QML, C++ or FMX dependency in the Studio implementation.
4. **Portable contract, target-specific code:** LLVM/Clang integrated assembler; x86-64 and AArch64 need separate ISA and OS ABI implementations.
5. **Deterministic core:** validated typed state, immutable declarative trees, revisioned edits, generator ownership and repeatable tests.
6. **Replaceable platform boundary:** window system, GPU, text, accessibility and input implemented through explicitly scoped OS adapters.
7. **Local-first, auditable changes:** reproducible artifacts, source control, no implicit cloud execution.

## Planned layering

```text
   Studio (own declarative UI, editor, preview, visual RAD)
                       |
     Declarative UI AST + typed Application Model
                       |
       Assembly core: state, diff, layout, events
                       |
          Platform ABI + renderer adapters
             /                  \
          x86-64               AArch64
```

There is **no universal native Assembly syntax** for all CPUs; consistent semantics live in contracts and shared tests. LLVM IR is an optional compiler intermediate, not a substitute for human-readable portable declarations.

## Executable baseline

`src/ui/validate_x86_64_sysv.S` validates a small UI node array using the x86-64 System V calling convention; `tests/ui_abi_x86_64_sysv.S` exercises it from Assembly. Run `sh build.sh` on Linux x86-64 with Clang. There is no renderer, declarative parser, live state system, app generator or IDE yet.

## Primary specifications

- [Declarative UI model](declarative-ui.md)
- [Assembly contracts, targets and AI role](assembly-first.md)
- [Component contract](component-contract.md)
- [Application Model](application-model.md)
- [Bindings and runtime](bindings-and-runtime.md)
- [Source ownership](source-ownership.md)
- [Security boundaries](extension-and-security.md)
- [Verification](verification-plan.md)
- [Roadmap](../product/roadmap.md)
- [ADRs](../adr/README.md)

No Architecture version number: version only persisted formats, component APIs and public ABIs.
