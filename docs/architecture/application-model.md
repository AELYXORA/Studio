# Typed Application Model

**Status:** proposed contract, not implemented.

## Ownership

The model owns stable identities and declarative intent: projects, modules, component definitions and instances, typed properties, layouts, data models, events, actions, connections, dependencies and targets. Handwritten function bodies remain under source-file ownership. Derived indexes and generated files are rebuildable.

## Entities

| Entity | Identity | Contract |
| --- | --- | --- |
| Project | projectId | metadata, schemaVersion, modules, targets |
| Module | moduleId | components, sources, dependencies |
| Component definition | typeId + version | properties, events, actions, ports, capabilities |
| Instance | instanceId | type reference, values, bindings, parent |
| View | viewId | layout hierarchy, instance references |
| Type | typeId | primitive, record, enum, collection, optional |
| Action | actionId | typed request/result, errors, async semantics |
| Event | eventId | payload, ordering and delivery |
| Connection | connectionId | typed source/target, conversion and failure policy |
| Target | targetId | backend, OS, toolchain and packaging configuration |

Stable IDs are immutable references; names are mutable labels. Unresolved references produce errors, never silent deletion.

## Type system

Initial primitives: boolean, explicit-width integers, floating point, precision-aware decimal, string, bytes, date/time/timestamp, UUID and duration. Composite types include records, enums, lists, maps and optional values. Nullability, serialization and numeric conversions are explicit. C/C++ ABI representation is separately described by an adapter.

## Model lifecycle

`read → parse → validate → migrate when needed → transactional change → validate → atomic save`.

Project commands have preconditions, revision checks, error diagnostics and inverses for undo/redo. External file modifications must be detected before overwrite. Layout trees are acyclic; other cycles follow documented dependency rules.

## Example (illustrative, not yet schema-valid)

```json
{
  "schemaVersion": "0.1-draft",
  "projectId": "app.customerdesk",
  "name": "CustomerDesk",
  "targets": [{ "id": "desktop", "backend": "qt-qml" }],
  "modules": [{
    "id": "crm",
    "components": [{
      "id": "customer-list",
      "type": "ui.record-list",
      "bindings": [
        { "property": "records", "source": "customers.query.results" }
      ]
    }]
  }]
}
```

`schemaVersion` versions the serialized format, **not** this architecture document. Schema evolution requires tested migrations and compatibility policies.

## Acceptance gates

Deterministic serialization; parse/serialize roundtrip; stable IDs across renames; invalid-binding detection; explicit migrations; lossless preservation of custom modules; safe concurrent edit handling.
