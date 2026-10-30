# Extensibility, Runtime and Security Boundaries

**Status:** proposed; not implemented.

## Separation of execution environments

- **IDE process:** trusted presentation and project orchestration.
- **Core services:** model validation, graph operations, safe file access; no plugin/UI dependency.
- **Design-time preview host:** separate process with constrained filesystem/network capabilities where supported.
- **Build/test workers:** disposable processes with scoped workspaces, timeouts and resource limits.
- **Generated application:** separate runtime and security boundary with its own permission/packaging policy.

A manifest identifies components and requested capabilities; a manifest alone does **not** sandbox native code. Native third-party plugins are treated as executable code with user consent and OS-level isolation when feasible. Do not load unknown native modules directly into the IDE process by default.

## Extension contract

Components supply type ID, semantic API version, supported project schema range, supported target backends, design-time metadata, runtime adapter, capabilities, dependencies and tests. Validate dependency graph and version constraints before loading. Unknown extension metadata is preserved when safe, but execution is blocked until compatible.

## Supply chain

Pin build tools and third-party dependencies where practicable; record provenance, signatures/checksums and licenses; inspect generated-project dependencies separately. Generated binaries should have an SBOM and a documented reproducibility envelope.

## Secrets and privacy

Credential references resolve via OS secret stores or environment-specific injectors; project exports must never include plaintext secrets. AI context collection uses opt-in scopes and redaction. Logs redact credentials and personally identifying data when feasible.

## Import and prompt injection

Treat projects, examples, external packages, model output and compiler messages as untrusted. Parsing never executes embedded instructions. AI proposals cannot self-approve tool access, shell commands or network requests.

## Target capabilities

Backend capabilities are declared explicitly (e.g. `ui.table`, `storage.sqlite`, `device.camera`, `network.http`). Generator rejects unsupported *required* capabilities; optional capabilities must specify an intentional fallback approved in the model. Never silently degrade security or data durability.
