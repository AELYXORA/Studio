# Formal Project Schema

**Status:** first executable contract subset. This is not the full Application Model.

- [JSON Schema 2020-12](../../schemas/project.schema.json) defines the current persisted subset: project, target, module, component, dependencies.
- [CustomerDesk fixture](../../examples/customerdesk/project.aelyxora.json) exercises the subset.
- [C++20 model](../../include/aelyxora/model.hpp) provides an independent in-memory representation and basic graph validation.
- [Model tests](../../tests/model_tests.cpp) exercise duplicate identities, invalid dependencies, cycles and optimistic revision checks.

## Important limitations

The C++ core currently does **not** parse or write JSON, validate JSON Schema, implement typed properties, bindings, persistence, migrations or generators. The schema and C++ types are complementary prototypes, not yet automatically synchronized. `rename_component` demonstrates atomic **in-memory** change only; it does not provide crash-safe transactions.

## Build

```sh
cmake -S . -B build -DBUILD_TESTING=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

No Qt dependency is required for the headless prototype. This intentionally differs from the future Qt 6.12 GUI shell.

## Next gates

Implement a real JSON loader/serializer with explicit dependency choice; cross-check against JSON Schema and golden fixtures; add real command transactions, persistence journal and schema migrations. Do not add broad designer features before these pass.
