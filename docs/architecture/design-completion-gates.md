# Architecture Design Completion and Review Gates

**Status: accepted documentation-first process; design baseline still open.** The architect requires **complete, detailed design before implementation, then implementation, then execution of tests and measurement, then correction/re-verification**. No further product parser, compiler, runtime, renderer, UI or AI source implementation before the complete **in-scope D1–D8 baseline** is reviewed and explicitly accepted. The existing Linux Assembly lexical preflight is historical research, not accepted implementation evidence. Any review-only technical experiment needs explicit, bounded authorization and must never be described as a passed gate.

## Repository workflow — direct main only

**Architect instruction:** Make all AELYXORA documentation and future authorized implementation changes directly in the existing `main` branch. **Do not create feature branches or pull requests.** This applies to documentation, design closure, implementation, corrections and tests. Respect any actual repository protection rule; if direct `main` writing is unavailable, report the restriction rather than creating a branch as a workaround. Do not alter pre-existing unrelated branches. This workflow rule does not by itself approve any design or code change.

## Responsibility and decision control

Human architect owns system requirements, graph semantics, platform targets, data disclosure decisions and acceptance. Documentation is the design deliverable. AI assistant is **architecture analyst and specification author first**, optional implementation engineer later; it may draft proposals but never own architectural authority. Design decisions are classified: Accepted (user-approved), Proposed, Open, Rejected, Verified (with observed evidence). A design contract cannot become accepted merely because a document was written.

## Mandatory sequential phase protocol

1. **I — Documentation & architectural closure.** Define the purpose, formal model, complete component/ABI/AI/UX contracts, constraints, behavior, error paths, trust boundaries, positive/negative design fixtures, and expected verification procedures. Resolve cross-document contradictions. The architect signs off on the baseline of all in-scope D1–D8 gates; status is otherwise Proposed/Open. No implementation work is started from an unapproved partial baseline.
2. **II — Implementation.** Only after the above baseline is accepted, build ordered native vertical slices (planned S0 through S4). Treat the accepted specs as the contract. Any material architecture deviation is written into the owning document and re-approved before code is based on it.
3. **III — Tests and measurements.** Execute the already-designed acceptance procedures against actual artifacts/targets. Record pass/fail/not-run/unsupported honestly, plus toolchain, host, target, input/output digests, commands and diagnostics.
4. **IV — Corrections and regression verification.** Fix defects under the same contract and re-run affected tests; if a requirement itself was wrong, explicitly reopen its owning design gate before implementing the changed contract. No unobserved green claims.

Documenting test plans and expected results belongs to Phase I; **running tests and accepting observed behavior** belongs to Phase III. A research prototype may answer an isolated feasibility question during Phase I only if clearly labeled, explicitly scoped and excluded from implementation-status claims.

[Specification Completion Matrix](specification-completion-matrix.md) lists concrete requirements, owners, unresolved conflicts and required design fixtures. [Architecture-to-Execution Contract](architecture-to-execution-contract.md) describes the intended architecture/workflow/data-flow/AI/native trace. They support the owning documents; neither overrides accepted semantics.

## Required gates

| Gate | Required decisions | Acceptance proof |
| --- | --- | --- |
| D1 Product/UX | Main Architecture Map+AI Chat flows; inspector, graph editing, offline; error/recovery states | End-to-end narrative for create/open/edit/propose/approve/save/reopen; keyboard/accessibility |
| D2 Canonical Graph | Node/edge identities, type registry, schema version, external dependencies, revision/transactions, immutable evidence | Complete valid/invalid data fixtures and deterministic expected diagnostics |
| D3 AUI Language | Complete lexical grammar/precedence, event-to-command wiring, generics/collections, bindings and error model | Golden valid/invalid source programs with exact semantics |
| D4 AUI Compiler | AST and TypedHIR shape, OwnershipIR CFG, TargetMIR lowering, data representation and target ABI interfaces | Trace single source program through every IR stage, including rejection examples |
| D5 Runtime/UI | State/lifecycle/event/cancel, ownership, layout, text, accessibility, renderer, window and platform service contracts | One consistent event-to-frame scenario and platform capability matrix |
| D6 Build/Persistence | Canonical file format, digest/lock semantics, source ownership, crash recovery, repeatability, diagnostics | Deterministic serialization vectors, journal failure matrix, target build inputs |
| D7 AI/ChatGPT | AI responsibilities, consent, provider eligibility, scopes, contextual disclosure, proposals, tool execution safety and offline operation | Connection state machine, threat model, approval flows, denial/revocation scenarios |
| D8 Integration/Review | All component contracts linked; no competing authorities, missing references, contradictions or unbounded open P0 decisions | Closure matrix, cross-document link check and signed-off architecture baseline |

## Closure rule

No claim of design completion unless each mandatory in-scope requirement has one authoritative owning spec, at least one valid and invalid example, clearly identified capabilities and error paths, a future executable test specification, and explicit acceptance by the human architect. 'Proposed' is not accepted and 'verified' requires evidence. If a design needs implementation experiments to settle unknowns, isolate them as research and record output.

## Scope priorities

Close D1 product doctrine and the in-scope vertical example first; then D2 graph/workflow/data-flow semantics and D6 persistence primitives needed by the graph; D3 AUI grammar, D4 compiler/ABI, D5 runtime/renderer, and D7 AI authorization and proposal governance. D8 reconciles all dependencies and records explicit architect acceptance. This is a **documentation order**, not permission to implement a passed partial gate while other in-scope P0 contracts remain open. Keep one owning spec per topic and avoid duplicate normative documents.

## Version policy

Do not assign pretend release versions to documents. Serialized schemas/packages/ABIs may have actual compatibility revisions, separately documented and frozen only when defined. No Python, no CI.


[AI Role and Human-in-the-Loop Contract](ai-role-contract.md) separates human decisions, AI proposals and deterministic local validation. Proposed for review.


[Project Graph ↔ AUI Formal Integration Contract](project-graph-aui-contract.md) defines identity, exports, typed edges, source synchronization and D2/D3 acceptance fixtures. **Proposed, not accepted or implemented.**


[D3 Event and Binding Semantics](aui-event-binding-semantics.md) is proposed, with AST/AUI.Core references and fixture expectations. D3 is not yet accepted or implemented.
