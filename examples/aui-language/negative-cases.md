# AUI D3 — Negative Golden Fixture Specifications

**Status: expected diagnostics only; not executed.** Each snippet inherits the same illustrative imported AUI.Core symbols as sensor-summary.aui. Exactly which source positions and error prioritization to report remains subject to grammar and semantic freeze.

| Case | Invalid fragment | Expected diagnostic |
| --- | --- | --- |
| unknown source event | `Button(title: "X").on(unknown: inspect)` | `AUI_EVENT_UNRESOLVED` |
| unresolved local event | `Button(title: "X").on(activated: absent)` | `AUI_UNRESOLVED` |
| incompatible payload | `event inspect: Event<Bool>;` connected to Button.activated | `AUI_EVENT_TYPE` |
| command not declared | `on inspect(payload) { send Missing(); }` | `AUI_UNRESOLVED` |
| command implementation missing | declared Inspect command without Project Graph implementation provider | `AUI_COMMAND_UNLINKED` |
| readonly binding | `bind input.reading <- state.value;` where input.reading is immutable | `AUI_BIND_READONLY` |
| duplicated writer | two bindings write same exclusive destination | `AUI_BIND_WRITER_CONFLICT` |
| immediate dependency cycle | derived a depends on b, derived b depends on a | `AUI_BIND_CYCLE` |
| illegal effect | derived value calls an effectful command | `AUI_ILLEGAL_EFFECT` |
| wrong target capability | command requires absent privileged device capability | `AUI_TARGET_UNSUPPORTED` / `CAPABILITY_DENIED` |

These are **specifications of tests to construct**, not parser fixtures validated against a compiler. Full parser-ready source examples require resolved import grammar, complete expression rules, source-level ownership and linked command implementation format.
