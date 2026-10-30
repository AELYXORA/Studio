# Typed Component Properties

**Status:** experimental C++23 implementation, not yet integrated into the persisted Application Model.

The headless `aelyxora_properties` module defines Boolean, signed 64-bit Integer, double Real and UTF-8 Text property values. Component definitions declare property names, kinds, defaults and mutability. Property instances store overrides; missing overrides use defaults at resolution time (resolution API is not yet implemented).

## Implemented checks

- Declaration uniqueness and nonempty names
- Type agreement for defaults and overrides
- Finite floating-point values
- Unknown property rejection
- Read-only protection
- Candidate-copy mutation, so invalid edits cannot partially modify an instance

## Missing before RAD integration

Typed property instances are not yet stored in `Project` or its JSON Schema; this is a standalone proof of contract. Enum, null, decimal, object, list, resource references, cross-property constraints, event bindings, dynamic expressions, revision-based edits and QML reflection are future work. The change API does **not** currently update a project revision.

## Verification

`properties_tests` is registered with CTest. Claims of cross-platform success require actual CI evidence.
