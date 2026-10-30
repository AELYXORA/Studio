# AELYXORA AI Engineering Workflow and Tool Integration

**Status: proposed architecture; not implemented.** [AI Engineer](ai-engineer.md) defines product and provider constraints, [Project Graph](project-graph.md) defines canonical contracts, [Design-Time Engine](design-time-engine.md) owns approval and editor transactions, and [Security](extension-and-security.md) defines trust boundaries.

## Roles and authority

The human architect owns interfaces, target profiles, acceptance criteria and approvals. AI may analyze, draft, implement and suggest tests within a disclosed scope. Local build/test tools report observations, not architectural authority. No natural-language message or successful test alone grants write, network or hardware permissions.

## End-to-end task lifecycle

1. **Select:** user chooses stable node IDs/subgraph, target, task type and allowed source paths.
2. **Disclose:** Studio presents a context manifest of graph revision, contracts, source snippets/hashes, diagnostics, dependencies, token/size budget and sensitive-data exclusions.
3. **Authorize context:** user confirms transmitted content and permitted provider; requests with unavailable authorization remain drafts.
4. **Plan:** AI returns desired behavior, affected artifacts, assumptions and questions; Studio checks against locked contracts.
5. **Propose:** AI produces a structured, non-executing change set (graph patch, source patch, tests, requested tool invocations and expected effects).
6. **Validate:** offline checks verify schema, types, ABI, effects, target, ownership, scope, file hashes and required capabilities. Rejected proposals do not mutate the project.
7. **Review:** present map-level impact, source diff, new dependencies, capability changes and test plan; every out-of-scope change needs separate authorization.
8. **Apply:** human approval commits a revisioned transaction via staged files and recovery journal. A stale graph or source hash requires rebase/re-review, never silent overwrite.
9. **Verify locally:** approved tool invocation runs in a restricted helper when possible. Collect stdout/stderr, exit code, toolchain, target, artifact hash, elapsed time and precise pass/fail/not-run evidence.
10. **Report:** attach observations to the corresponding graph nodes and build artifacts. Follow-up AI changes start another proposal; never self-approve.

## Context manifest

Fields: task ID, graph revision/hash, selected node IDs and edge IDs, target triple/ABI, selected source path+hash+range, public component contracts, relevant diagnostics, declared capabilities, tool permission scope, excluded secrets and estimated disclosure size. Expanding context to related nodes requires visible approval. The context cache must be revocable and bounded; never treat provider replies as trusted instructions for tools.

## Structured proposal envelope

Fields: proposal ID, base graph revision, base source hashes, affected node IDs, intended purpose, graph patch, source patch, generated test fixtures, requested capabilities, proposed commands, predicted effects, unresolved assumptions and AI provenance. Distinguish proposed changes from applied changes and verified results. Human-owned files cannot be overwritten by generation without explicit conflict resolution.

## Tool execution policy

Read-only inspection, local compilation, local test execution, filesystem write, network, process launch, debugger attachment and physical device operations are distinct capabilities. Proposed commands are not automatically executed. Tool arguments, environment, working directory, timeout, file access and side effects are reviewed before invocation. Untrusted Assembly and generated binaries are **not sandboxed by their manifest**; execute separately under OS restrictions when available. Never execute privileged hardware operations based on AI output alone.

## Authentication and offline behavior

The preferred experience is officially authorized ChatGPT sign-in if a supported integration and entitlement are actually available. A ChatGPT Plus subscription alone does **not** guarantee access to an arbitrary third-party API. No scraping of ChatGPT sessions, cookies or browser tokens. Provider identity and credential storage are separated from project manifests. Offline users can create, inspect, edit and build projects; AI-dependent generation is unavailable unless a separately authorized provider is configured.

## Error, rollback and audit

- API/auth failures cannot affect local project availability.
- A rejected or invalid proposal leaves all project files unchanged.
- A failed apply restores the prior validated snapshot and marks the transaction failed.
- Undo restores **local project state**, not external side effects such as flashes, sent packets or filesystem changes outside the workspace.
- Every evidence record includes who approved, what changed, when a command actually ran, which target/artifact it used and what was observed.
- Logs redact secrets and allow retention limits; chat transcripts are not the authoritative project history.

## Acceptance fixtures

1. Selected-driver implementation proposal stays within approved source paths.
2. Adding an undeclared hardware capability fails validation.
3. A stale source hash produces a conflict review, not overwrite.
4. Out-of-scope graph edits are blocked.
5. Rejection leaves byte-identical canonical project files.
6. An approved patch may be applied without running proposed commands.
7. Test results with no execution are marked not-run.
8. Network/device commands require a distinct explicit authorization.
9. Disconnected AI provider does not block local design and compile.
10. AI-generated malicious tool instructions are treated as untrusted proposal content, never automatically followed.

## Open design decisions

Exact proposal patch serialization, context truncation algorithm, provider-specific OAuth/authorization support, secrets vault integration, sandbox implementation per OS, and cross-file transaction journal. No production AI integration or verified tool execution exists.
