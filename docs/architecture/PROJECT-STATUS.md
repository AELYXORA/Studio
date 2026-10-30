# AELYXORA Studio — Current Technical Status

**As of 2026-10-30. This is the authoritative implementation-status summary.** The architecture documents describe intended behavior unless a concrete committed artifact and observed test are cited. No global architecture freeze or product release is claimed.

## Implemented in the repository

- Proposed Project Graph and component package JSON fixtures, negative mutation cases, and draft machine-readable schemas under `schemas/`.
- An experimental native **Linux x86-64** Assembly lexical preflight at [src/bootstrap/linux-x86_64/json_preflight.S](../../src/bootstrap/linux-x86_64/json_preflight.S). It reads a file using Linux syscalls and checks delimiter nesting and string termination. **It is not a valid JSON parser or graph validator** and may accept malformed JSON.
- [Bootstrap commands](../../src/bootstrap/linux-x86_64/README.md) document a limited local Clang-based smoke experiment. Those observations are not compiler/graph/runtime acceptance evidence.

## Not implemented

Strict JSON tokenizer/parser; semantic Project Graph engine; complete schema validator; package lock resolver; safe atomic persistence and revision journal; AUI parser/TypedHIR/OwnershipIR/TargetMIR implementation; Assembly code generation; native window/renderer; live AI provider integration; hardware drivers; end-to-end local test harness. Existing proposed fixture tests are **not-run by a native Project Graph validator**.

## Binding architectural decisions

1. Architecture Map + contextual AI Chat are the primary intended Studio UX. Project Graph is canonical; source/UI/AI views do not replace it.
2. Human architect approves graph/source changes; AI output alone grants no write, execution, network or device rights.
3. Core and Studio runtime are **Assembly-first**, target-native; AUI is our own declarative language. LLVM/Clang may assemble and link target-dependent code.
4. [Language Policy](language-policy.md) **prohibits Python** for project code, tests and tooling. Qt/QML/C++/FMX are not part of the active Studio implementation stack; other implementation languages require explicit approval.
5. Linux x86-64 is the **host of the existing bootstrap experiment**, not a decision to abandon Windows x64 as a proposed first Studio desktop host. The sensor fixture describes a Linux AArch64 **target**, not currently runnable hardware support.
6. No GitHub Actions or CI before release preparation; locally observed results must be distinguished from specified expected outcomes.

## One implementation order

- **S0:** strict native JSON parse -> typed graph construction -> graph/package contract checks -> diagnostics -> revisioned safe persistence; prove against positive/negative sensor fixtures.
- **S1:** native architecture map + property inspection + disconnected contextual AI panel using the validated graph.
- **S2:** minimal sound AUI grammar -> semantic analysis and ownership checks -> target code generation -> working native UI built from AUI.
- **S3:** reviewed AI proposals, tool authorization and local evidence; official provider authorization only when available.
- **S4:** selected real device/target, on-target ABI and hardware verification.

S1 and S2 may need tightly scoped joint experiments for bootstrapping native UI, but acceptance requires actual AUI-generated native code; a manually coded prototype must not be presented as AUI compiler verification.

## Documentation authority

[Architecture](README.md) owns product principles; [Project Graph](project-graph.md) owns graph semantics; [AUI Syntax](aui-syntax.md) owns proposed grammar; [OwnershipIR](aui-ownership-ir.md) owns resource flow; [Component ABI](aui-component-binary-abi.md) owns binary component contracts; [Project Format](project-and-package-format.md) owns persistence; [Platform Services](aui-platform-runtime-services.md) owns OS adapters; [AI Workflow](ai-engineering-workflow.md) owns proposal permissions; [Roadmap](../product/roadmap.md) owns milestones; [Verification Plan](verification-plan.md) owns evidence policy. Superseded examples or audits are historical evidence, not competing accepted specifications.

## Unresolved blockers

Strict schema/duplicate-key policy, canonical package hashes and lockfile, event/command AUI syntax, fixed native ABI layouts, Windows host toolchain/backend selection, transaction recovery, platform text/rendering and provider authentication. Placeholder format/package versions in JSON fixtures are **not document versions or releases**.
