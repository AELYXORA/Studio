# Architecture Design Completion and Review Gates

**Status: accepted process policy, design work ongoing.** AELYXORA is in **documentation-first / design-closure** mode. No further runtime, parser, compiler, renderer, UI, or AI integration source code until the relevant gate is reviewed and accepted. Existing Linux Assembly lexical preflight remains an experiment, not an implementation baseline. This policy does not prohibit explicitly requested review-only technical experiments; experiments never imply a frozen architecture.

## Responsibility and decision control

Human architect owns system requirements, graph semantics, platform targets, data disclosure decisions and acceptance. Documentation is the design deliverable. AI assistant is **architecture analyst and specification author first**, optional implementation engineer later; it may draft proposals but never own architectural authority. Design decisions are classified: Accepted (user-approved), Proposed, Open, Rejected, Verified (with observed evidence). A design contract cannot become accepted merely because a document was written.

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

No claim of design completion unless each mandatory requirement has one authoritative owning spec, at least one valid and invalid example, clearly identified capabilities and error paths, and explicit acceptance by the human architect. 'Proposed' is not accepted and 'verified' requires evidence. If a design needs implementation experiments to settle unknowns, isolate them as research and record output.

## Scope priorities

Close D7 ChatGPT role and integration now, followed by D2 graph/serialization and D3 grammar, then D4/D5 ABI/runtime and D6 build. Maintain human-friendly architecture index and avoid multiplying overlapping specs.

## Version policy

Do not assign pretend release versions to documents. Serialized schemas/packages/ABIs may have actual compatibility revisions, separately documented and frozen only when defined. No Python, no CI.


[AI Role and Human-in-the-Loop Contract](ai-role-contract.md) separates human decisions, AI proposals and deterministic local validation. Proposed for review.


[Project Graph ↔ AUI Formal Integration Contract](project-graph-aui-contract.md) defines identity, exports, typed edges, source synchronization and D2/D3 acceptance fixtures. **Proposed, not accepted or implemented.**
