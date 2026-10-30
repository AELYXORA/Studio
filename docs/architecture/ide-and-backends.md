# IDE and Backends

**Status:** proposed.

## IDE

C++ and Qt 6.12/QML host project explorer, visual designer, object inspector, architecture view, data/logic editors, code editor, diagnostics and build console. Workspaces are configurable rather than four permanently fixed panes.

The UI sends typed commands to headless application services; the core owns validation, undo/redo semantics, project persistence and derived dependency graphs.

## Generator boundary

Input: validated model snapshot and target configuration.

Output: manifest listing files, hashes, ownership, diagnostics, toolchain requirements and generator identity. Only generated-owned paths may be replaced. User-owned code is integrated by explicit typed interfaces, not by regex rewriting.

## First end-to-end target

Generate a standalone Qt 6.12/QML desktop program with CMake and SQLite. Target Windows and Linux first; macOS, Android/iOS, headless/server and low-level targets follow validated platform adapters and toolchain availability. Portability of model metadata is not a promise that every implementation is portable.

## Code tooling

Use existing LSP, compiler, debugger and CMake ecosystems, not a new assembler or compiler. Code-to-model synchronization is restricted to explicitly supported declarations and annotations; unknown code remains intact.

## Build reproducibility

Document toolchains, CMake presets, locked dependencies, environment requirements and packaging rules. Generated applications may require runtime libraries but not AELYXORA Studio itself.
