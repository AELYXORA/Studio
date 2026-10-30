# Component Contract

**Status:** proposed.

A component is a reusable typed unit, potentially visual or headless. Every component declares a stable type ID, API version and capability set.

- **Properties:** type, default, mutability, constraints and design-time editor metadata.
- **Actions:** typed arguments/results, failure model, cancellation and sync/async semantics.
- **Events:** typed payload, delivery order and threading guarantees.
- **Ports / bindings:** direction, data type, transformation and backpressure policy when streaming.
- **Lifecycle:** create, initialize, mount (visual only), activate, suspend, dispose.
- **State:** transient/persisted fields, ownership and migration.
- **Capabilities:** explicitly requested file/network/device/process access.
- **Tests and docs:** contract examples, expected errors, test fixtures.
- **Native bindings:** separately defined ABI and ownership when wrapping C/C++/Rust/ASM.

Initial categories are UI (window, container, text, input, table, dialog), Data (record, repository, SQLite), Logic (action, validation, transformation), Integration (HTTP, files, exports) and Native (external library or process).

Design-time metadata cannot change runtime semantics. Cross-thread data ownership must be explicit. Plugins are untrusted; a manifest is not a sandbox. Component versioning is separate from product and architecture naming.
