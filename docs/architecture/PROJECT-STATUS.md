# AELYXORA Studio — Current Technical Status

**As of 2026-10-31. This is the authoritative implementation-status summary.** The architecture documents describe intended behavior unless a concrete committed artifact and observed test are cited. No global architecture freeze or product release is claimed.

## D3 language design pass (documentation only)

[D3 First Language Profile](d3-first-language-profile.md), [D3 Type/Binding Profile](d3-type-and-binding-profile.md), [D3 Event Delivery](d3-event-delivery-and-command-linkage.md) and [D3 Review](d3-language-review.md) now provide proposed minimal source grammar, typed UI intent, an explicit graph command-link schema, L0/L1 example files and future negative diagnostics. Existing older AUI source is still illustrative. **No AUI compiler, semantic analyzer, native ABI provider, renderer, linked runtime or observed tests have been added.** D3 remains Proposed/Open; full State/Derived/Bind/Task/await and other D3+ features still require design completion.

## D2 documentation update (design-only)

Proposed workflow/data-flow and D2 execution/consistency contracts, expanded JSON Schemas, typed command/signal fixtures, staged cancellation example and future sensor runtime acceptance scenarios now exist. No native parser, semantic validator, canonical serializer, cryptographic snapshot publisher, transaction journal, workflow engine, command dispatcher, channel runtime, or ABI implementation was added. These changes do not change the implementation-readiness status or mark tests passed. Their proposed semantics require architect acceptance, cross-contract closure and implementation before Phase III tests.

**Cross-contract design review:** [D2/D6 Baseline Review](d2-d6-baseline-review.md) and [Export Contract Identity](d2-export-contract-identity.md) document unresolved and corrected specification issues. A committed JSON schema or SHA test vector does not make a binary, parser, snapshot adapter or external platform work.

## Implemented in the repository

- Proposed Project Graph and component package JSON fixtures, negative mutation cases, and draft machine-readable schemas under `schemas/`.
- An experimental native **Linux x86-64** Assembly lexical preflight at [src/bootstrap/linux-x86_64/json_preflight.S](../../src/bootstrap/linux-x86_64/json_preflight.S). It reads a file using Linux syscalls and checks delimiter nesting and string termination. **It is not a valid JSON parser or graph validator** and may accept malformed JSON.
- [Bootstrap commands](../../src/bootstrap/linux-x86_64/README.md) document a limited local Clang-based smoke experiment. Those observations are not compiler/graph/runtime acceptance evidence.

## Not implemented

Strict JSON tokenizer/parser; semantic Project Graph engine; complete schema validator; package lock resolver; safe atomic persistence and revision journal; AUI parser/TypedHIR/OwnershipIR/TargetMIR implementation; Assembly code generation; native window/renderer; live AI provider integration; hardware drivers; end-to-end local test harness. Existing proposed fixture tests are **not-run by a native Project Graph validator**.

## Binding architectural decisions

**Current process:** documentation-first; major implementation resumes only after [Design Completion Gates](design-completion-gates.md). The existing Linux Assembly preflight is an exploratory artifact, not a completed design gate.

**ChatGPT Plus:** OpenAI documents official Sign in with ChatGPT plan usage for eligible participating/open-source clients. AELYXORA-specific eligibility and authorization are unverified; see [ChatGPT Connection](chatgpt-connection.md).


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

**Additional design-only references:** [D2 identity/type resolution](d2-identity-and-type-resolution.md), [D6 canonical persistence](d6-canonical-persistence.md), [four expected canonical hash vectors](../../examples/architecture-sensor/d2-canonical-vectors.json), [HEAD/index schema drafts](../../schemas/project-head.schema.json), and [30 future crash recovery scenarios](../../examples/architecture-sensor/d6-recovery-scenarios.md). No production durability or executable codec evidence is claimed.

**D6 new proposed documentation:** [Package Integrity](d6-package-integrity.md), [Filesystem Adapter Capability Matrix](d6-filesystem-adapters.md) and [codec-only package/snapshot/HEAD integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json). No AELYXORA package resolver, native checksum verifier, Windows/Linux durable save adapter or executable test was created.

**New D2/D6 design fixture:** [Locked Pure Reference](../../examples/locked-pure-reference/README.md) demonstrates concrete source-byte/package-lock/graph/export/snapshot linkages. [Canonical Projection](d2-d6-semantic-projection.md), [Offline Resolver](d6-offline-dependency-resolution.md) and [Negative Cases](../../examples/locked-pure-reference/negative-cases.json) are documentation-only and remain unexecuted by AELYXORA.

**2026-10-31 repository documentation audit:** [Cross-Specification Audit](cross-specification-audit-2026-10-31.md) reconciles ten document-level conflicts and records fourteen remaining architectural risks. No Studio parser, component ABI, runtime, native test, release, or CI implementation is implied by these repairs. Exact source and evidence limitations remain unchanged.

## D2 hardware profile documentation update — 2026-10-31

[Hardware Resource Contract](d2-hardware-resource-contract.md) specifies a **proposed** version-gated resourceModel for targets and MMIO/IRQ/DMA/memory; [D2↔D3 Boundary](d2-d3-hardware-command-boundary.md) requires verified provider, approved graph/resource edge and live capability for effects. The [sensor hardware fixture](../../examples/architecture-sensor/hardware-resource-profile-project.auiproj.json) is not package-lock/ABI-linked or executable. Nine of nine intentionally invalid structural variants were rejected by a small independent checker; twenty semantic/target cases remain NOT-RUN. No native Studio code has been added or hardware access authorized. D1–D8 not accepted.
