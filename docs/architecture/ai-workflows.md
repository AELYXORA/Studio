# AI Architect and Trust Boundaries

**Status:** proposed.

AI is an optional adapter. It reads scoped project context and proposes model transactions or source patches. It is not the source of truth and cannot declare its own change successful.

## Workflow

1. User describes intent, target and constraints.
2. Context builder selects relevant model nodes, source contracts and diagnostics.
3. AI returns a **proposal** with affected IDs/files, rationale and intended tests.
4. Validate schemas, ID references, type connections, permissions and change ownership.
5. Present a diff and obtain approval for impactful changes.
6. Apply transactionally, build and test.
7. Report precise outcomes and enable revert. Failed gates never become success.

## Risk controls

Project files, model responses, third-party dependencies and build logs are untrusted. Prompt injection cannot grant tool privileges. Filesystem, shell and network actions must be narrowly scoped and user-authorized. Protect secrets from context gathering; redact and minimize outbound data. Support an AI-offline mode for existing apps and ordinary source development.

## Provider independence

The platform exposes an adapter for available authorized AI providers without embedding credentials in project files. This document does not claim any provider/subscription can be used via an API without appropriate authorization and technical integration.

## Engineering evidence

Model validators and compilers report facts; AI may explain or suggest, but performance claims need measurements and security claims need applicable tests.
