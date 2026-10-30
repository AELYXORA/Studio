# Typed Component Properties

**Status:** C++23 model + transaction + optional JSON adapter implementation committed; full CI result not independently verified.

## Implemented integration

- `Component` owns `property_definitions` and typed `properties` overrides.
- Types: Boolean, signed 64-bit Integer, finite double Real and UTF-8 Text.
- Model validation rejects duplicate declarations, mismatched defaults, undeclared overrides and invalid real values.
- `SetComponentProperty` participates in revision-checked, candidate-copy project transactions.
- Unknown and read-only properties reject edits; failed commands do not publish a new model revision.
- Optional Boost.JSON adapter reads/writes `propertyDefinitions` and `properties`; the formal JSON Schema includes those fields.
- CTest covers property mutation and persisted roundtrip cases.

## JSON representation (draft)

```json
{
  "id": "submit",
  "type": "ui.button",
  "propertyDefinitions": [
    {"name": "title", "kind": "text", "default": "Submit", "writable": true},
    {"name": "enabled", "kind": "boolean", "default": true}
  ],
  "properties": {"title": "Save"}
}
```

Overrides do not need to repeat the type: the declaration determines type checking. Absence of an override means use the default.

## Known gaps

- Project schema and C++ parser are not yet independently checked for complete JSON Schema semantic equivalence; `kind/default` agreement is enforced by C++ but not by JSON Schema conditional logic.
- No polymorphic component registry: definitions are currently stored with each component instance.
- No property-level revision, nested data models, design-time editors, ranges, enum, null or structured values.
- No data binding engine, QML visual inspector, computed expressions or runtime component system.
- Persistence durability and Windows replacement remain experimental; do not use for irreplaceable projects.

## Next design step

Move reusable component definitions to a registry referenced by stable type/version, introduce property resolution and typed binding validation, and prove end-to-end save/reopen of one visual component before broadening the palette.
