# AI Role and Human-in-the-Loop Engineering Contract

**Status: proposed for human review; no AI implementation.** This defines the AI's responsibilities inside AELYXORA Studio independently from provider transport. See [ChatGPT Connection](chatgpt-connection.md) for official account access and [AI Engineering Workflow](ai-engineering-workflow.md) for proposals and tool permissions.

## Role split

| Decision/action | Human architect | AI engineer | Studio deterministic subsystem |
| --- | --- | --- | --- |
| Define purpose, hardware target, safety and acceptance criteria | Owns and approves | Elicits, analyzes, documents | Validates form/constraints |
| Define graph architecture, public ports, contract and resource ownership | Owns changes | Suggests alternatives and risk assessment | Validates typed graph invariants |
| Select implementation approach | Approves | Evaluates Assembly algorithms and trade-offs | Enforces platform/toolchain requirements |
| Produce source, test proposals and design explanations | Reviews, approves | Drafts | Parses and stages diffs |
| Run compiler/test/debug/device operations | Explicitly authorizes scope and effects | May request tools; no inherent execution rights | Runs only authorized local actions and records evidence |
| Accept release, security posture and hardware safety | Decides | Identifies residual risks | Presents observed evidence and blockers |

## Interaction modes

- **Discuss:** answer and architecture critique without writing artifacts.
- **Specify:** generate component contracts, dependency maps, fixture cases and test-plan proposals; show source of assumptions.
- **Implement (future):** draft code inside approved file/target scope, without automatically committing.
- **Investigate (future):** analyze local diagnostics and propose focused tool actions, explicitly authorized before execution.
- **Review:** inspect diff and verification evidence, report contract violations and alternatives.

Modes are user-visible and do not imply a different model identity or secret permissions. Chat may discuss architecture globally but context shared to provider is bounded to selected graph scope and user-approved dependencies.

## Required prompt context

Task purpose, selected node IDs and current graph revision, target triple and ABI, owned component contract, related dependency edges, source ownership, allowed files, permission budget, specific failure/output evidence and acceptance criteria. Studio shows the exact disclosure bundle before sending. Missing hardware details and speculative facts must be flagged, never silently invented.

## Structured AI output

A proposal contains: objective, assumptions, target, base revision, impacted nodes/files, candidate graph/source changes, tests, required capabilities, risks, rollback conditions and unresolved decisions. Each suggested step is typed as explanation, proposed change, requested local tool, or evidence report; free-form text cannot masquerade as an authorized action.

## Failure behaviors

Ambiguous hardware spec -> questions or bounded alternatives. Missing provider allowance -> preserve unsent draft, no silent paid API fallback. Conflict with human modifications -> three-way review. Unsafe device command -> block until explicit authority and target confirmation. Unsupported AUI language feature -> classify as planned, do not generate fictitious runnable syntax. Unobserved test -> not-run. Missing security proof -> cannot claim verified.

## Design acceptance scenarios

1. User selects driver and requests architecture explanation with no source write.
2. User requests implementation; model proposes Assembly and tests but graph remains unchanged pending approval.
3. Model tries to add a new memory-mapped device capability; request requires separate reviewed architecture change.
4. A prompt embedded in source instructs AI to run a privileged command; tool gateway rejects it.
5. Reconnect account does not resend previously withheld project source automatically.
6. No AI connection: user can inspect, modify and save the entire graph using native deterministic tools.
7. Stale proposal revision produces re-review rather than automatic application.
8. Test evidence remains tied to artifact hash, toolchain and actual run.

## Open before acceptance

Exact structured proposal schema, context pruning algorithm, session retention policy, human confirmation ergonomics, error recovery, remote privacy behavior, token-vault storage, and official provider availability for the app.
