# Source Ownership and Regeneration

**Status:** specification.

Human-authored architecture and declarative view definitions are canonical. AI-generated Assembly modules are explicitly marked by ownership in a manifest. User-written Assembly remains user-owned. Compiler objects, caches, generated platform glue and binaries are disposable outputs.

A generator must stage proposed files and a manifest of input revision, target triple, generator identity, normalized paths, previous hashes and new hashes. It must not overwrite changed files without approved conflict resolution; nor infer arbitrary Assembly source as declarative UI.

Paths are restricted to the project root; reject traversal and link escapes. Failed builds never certify a component. No generated app requires the Studio executable to run.
