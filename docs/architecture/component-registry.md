# Component Registry and Property Resolution

**Status:** experimental C++23 implementation; no GUI integration or runtime evaluation.

The registry holds component type IDs, API version strings, and reusable property contracts. A component instance refers to a type by ID; `resolve` returns an explicitly stored override or the registered default. The registry rejects duplicate type registration and invalid definitions.

## Compatibility transition

Existing project JSON embeds `propertyDefinitions` in each instance. To avoid breaking those projects, the registry currently checks embedded definitions for drift against its registered type, when provided. A later **explicit schema migration** will move definitions into project or package manifests. Do not silently discard legacy declarations.

## Static binding validation

`validate_bindings` checks referenced component and property existence, matching primitive kinds, and writable targets. It **does not evaluate bindings**, track dependencies, detect cycles, implement conversion, or dispatch runtime updates. Bindings are not yet persisted into project JSON.

## Test scope

`registry_tests` covers registration conflicts, defaults, overrides, unknown references and type mismatch. Successful cross-platform execution must be verified in CI.

## Next implementation targets

Persist type registry references and binding declarations, introduce stable type/version resolution and cycle detection, then build a minimal Qt 6.12 Object Inspector backed by revisioned Project commands.
