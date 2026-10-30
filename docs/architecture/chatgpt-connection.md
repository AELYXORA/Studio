# ChatGPT Plus Connection — Official Integration Decision

**Status: design candidate; no AELYXORA authentication/inference integration implemented. Reviewed 2026-10-30.** This document is the authority for ChatGPT account authorization and subscription-backed inference.

## Verified provider capabilities and limits

OpenAI documents **Sign in with ChatGPT**. Eligible ChatGPT Plus/Pro accounts can authorize participating tools to use plan allowance for eligible AI requests. Identity sign-in and permission to use plan allowance are **separate scopes and consent actions**. For open-source clients, the published integration describes registration and OAuth credentials for eligible Responses API requests, without requiring an end-user API key. Access is contingent on eligibility, available programs, approved scopes, supported models and usage limits. It is not a universal API subscription or access to ChatGPT conversation history.

References (retrieved October 30, 2026):
- https://developers.openai.com/siwc/quickstart
- https://developers.openai.com/cookbook/articles/sign-in-with-chatgpt
- https://developers.openai.com/siwc/token-sharing-open-source/errors-and-recovery
- https://help.openai.com/en/articles/6950777-what-is-chatgpt-plus
- https://help.openai.com/en/articles/9039756-managing-billing-for-chatgpt-and-the-api-platform

API billing is otherwise separate from ChatGPT Plus. AELYXORA must verify eligibility as a real open-source client and supported OAuth registration/flow before promising plan-backed access. This does not authorize scraping cookies, session tokens or private endpoints.

## Proposed UX

A dedicated AI Chat panel stays adjacent to Architecture Map. Account states: Disconnected, Connecting, SignedInNoPlanPermission, ConnectedPlanEligible, PermissionRevoked, AllowanceUnavailable, ProviderError. The UI shows **Continue with ChatGPT**, connected identity/workspace, exact consent scopes, allowance-enabled state, and reconnect/disconnect actions. Never claim a specific plan or remaining allowance without a provider-confirmed response. AI-unavailable state does not block offline editing/building.

## Authorization boundary

Open external system browser for provider authorization using published client flow, validated redirect/state and PKCE or other provider-prescribed protection. Never embed password collection. Installation identity and OAuth client registration follow the officially documented flow; callback is bound to the originating session. Tokens are stored in OS credential vault, never manifests, logs or project source. Sign-out revokes/forgets local credentials; provider-side revocation must be reflected. Honor expiry, refresh, revocation, rate limits, user refusal and workspace restrictions.

The `chatgpt.tokens.use.direct` scope is an example of a separately granted permission documented in provider recovery guidance; request it only when applicable and supported. Sign-in alone must not trigger model requests. No access to existing ChatGPT conversations is assumed.

## Request/response adapter

```text
Selected Project Graph nodes + source ranges
 -> disclosed ContextManifest
 -> explicit send authorization
 -> provider adapter (official authorized path only)
 -> untrusted model output
 -> structured proposal validator
 -> graph/source diff + human approval
 -> optional authorized local tools -> evidence
```

Transport protocol and model availability are discovered, not hardcoded. Stream responses with cancellation and bounded memory. Preserve response provenance, target graph revision, provider and actual usage when reported. Do not send secrets, local environment variables, private unrelated files or whole project by default. Prompt injection from source/comments/tool logs cannot grant actions.

## Design fallback

Primary: official Sign in with ChatGPT + eligible plan usage **if integration is available for AELYXORA**. Secondary: disconnected/offline mode with manual reviewable proposal import. A separately billed API-key mode is **not an implicit fallback** and would require an explicit product decision; do not silently charge users. ChatGPT Apps SDK/MCP makes tools available inside ChatGPT, which is a distinct direction from embedding ChatGPT capabilities within the desktop Studio.

## Acceptance scenarios

1. Connect identity without inference permission -> no model call.
2. Grant eligible allowance permission -> provider-authorized request only in approved scope.
3. Revoke provider permission -> block future inference immediately on known denial; preserve local projects.
4. Rate limit / allowance exhausted -> descriptive error without silent API fallback.
5. Consent canceled, redirect spoofed, expired state or invalid callback -> reject.
6. Secrets absent from exported project, diagnostics and telemetry.
7. Selected node context preview matches transmitted payload exactly.
8. Model proposal outside graph/file scope is rejected before mutation.
9. Untrusted model instructions cannot trigger build, network or device access.
10. Offline session can inspect graph, edit and invoke explicitly approved local tools.

## Open questions before design acceptance

AELYXORA eligibility/registration, exact provider OAuth contracts for native clients, model discovery scope, response streaming contract, secrets-vault adapter on first OS, local callback/redirect approach, quota/error semantics and privacy policy. Do not call this implemented or guaranteed.
