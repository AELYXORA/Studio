# AI Engineer and Chat Integration

**Status:** product and security contract; no provider integration implemented.

## 1. Interaction model

The AI Chat is a persistent, dockable peer of the Architecture Map. User selects node(s), target and operation scope. The chat displays a **context manifest** before sending: exact selected node IDs, related contracts, relevant source paths, diagnostics, source hashes, target and tool permissions. Adding dependencies to context must be visible; secrets never enter context by default.

Human architect specifies what a component should do and constraints; AI primarily creates implementation artifacts (Assembly modules, documentation and tests) or proposes explicit architecture edits. AI does **not** own acceptance criteria or make unapproved graph changes.

## 2. Supported task shapes

- Explain selected component, connections and target constraints.
- Implement or refine a component against locked interfaces.
- Generate local tests, fixtures and ABI conformance checks.
- Diagnose local compiler/test output (only user-approved data).
- Propose refactor with a map-level impact preview and source diff.

A chat message alone is not a write authorization. Free-form suggestions become structured change proposals with scoped operations and file patches.

## 3. Change lifecycle

```text
select context -> display disclosure -> user prompt
-> model proposes patch + structured graph operations
-> parse/validate -> preview graph diff + source diff
-> human approval -> apply to staged candidate
-> verify locally -> publish new revision / rollback
```

The proposal records project base revision, target list, model/provider identity when available, selected scope, affected files/nodes, claimed checks and actual verification evidence. Stale base revisions require rebase/review. Generated source never overwrites manually modified files without conflict resolution. Every external command, build and device operation is separately permission-gated.

## 4. ChatGPT account access

**Authoritative integration design:** [ChatGPT Plus Connection](chatgpt-connection.md). OpenAI now documents eligible official Sign in with ChatGPT plan-usage flows for participating open-source clients. Whether AELYXORA qualifies and can use this flow remains unverified. Identity and inference allowance require distinct consent; neither grants access to existing ChatGPT conversations.


Desired UX: **sign in with ChatGPT**, ideally using an eligible paid subscription and without user-managed API keys. This requires an officially offered integration with appropriate entitlements and approval. A ChatGPT Plus subscription is not a reusable general API credential. Do not build around session cookie extraction, private endpoint access, password collection, or pretending that login guarantees model access.

**Fallback:** offline architecture editing and manual Assembly work must function with AI disconnected. An optional alternative provider mechanism is a separate product decision, not silently introduced. Do not promise the account-based connector until access is proven by a real end-to-end authorization test.

## 5. Security and privacy

No automatic upload of complete repositories, source secrets, proprietary dumps or logs. Context disclosure and redaction precede send; retain local chat history only by explicit project policy. Tool output is untrusted data, never instructions. AI cannot execute privileged code, attach to devices or flash firmware solely based on generated text. Human must approve any hardware operation, and the Studio must show exact target/device and potential impact.

## 6. Acceptance gates

- Selecting a node limits context to the declared selection and visible dependencies.
- A proposal can be rejected without modifying any project file.
- Invalid graph modifications report precise contract violations.
- A stale revision cannot silently overwrite a newer human edit.
- Build/test statuses distinguish not-run, failed and passed.
- Offline IDE still opens and edits the architecture project.
- Authentication failures never leak tokens or degrade local access.
