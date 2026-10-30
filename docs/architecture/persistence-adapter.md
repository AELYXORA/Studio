# Experimental Persistence Adapter

**Status:** C++23 implementation; local Boost.JSON test passed. Not crash-safe production persistence.

The adapter uses Boost.JSON 1.81+ (including `boost/json/src.hpp`) behind optional CMake flag `AELYXORA_WITH_BOOST_JSON`. Default core builds require no Boost. The C++ parser implements the currently supported subset of `schemas/project.schema.json`; it is not yet an independent standards-compliant schema validator.

## Supported

- JSON parse and deterministic serialization for Project, Targets, Modules and Components.
- Schema version and graph validation; rejection of unknown fields, invalid types and duplicate dependencies.
- Maximum project JSON input size 4 MiB and nesting depth bound.
- File load, create-only save, revision-checked overwrite, sibling staging file.

## Known limitations / blockers

**Do not use for production user data.** No process lock, no fdatasync/fsync of contents and parent directory, no durable journal or crash recovery. On Windows, replacement of an existing destination by `std::filesystem::rename` may fail. Revision checks do not eliminate races between concurrent writers. Draft parser/serializer is not yet formally cross-validated against JSON Schema 2020-12. Very large graphs may stress recursive graph validation.

Build with Boost.JSON headers available:

```sh
cmake -S . -B build -DBUILD_TESTING=ON -DAELYXORA_WITH_BOOST_JSON=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

Next: cross-platform replace protocol, same-directory unique staging, file lock, durable journal, independent JSON schema conformance and fault injection.
