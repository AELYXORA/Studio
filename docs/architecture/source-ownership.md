# Source Ownership and Round-trip Editing

**Status:** proposed normative contract; not implemented.

## Core rule

The canonical Application Model owns declarative intent; user source owns function implementations and custom code. Generated artifacts are outputs, never authoritative model input. Full arbitrary-code-to-visual round trips are explicitly **not supported**.

## Ownership classes

| Class | Typical paths | Write authority |
| --- | --- | --- |
| Model | `project.aelyxora.json`, model modules | transactional model service |
| Generated | `generated/**` | generator only, after comparison |
| User | `src/**`, `custom/**` | user/editor/approved AI patch |
| Tool cache | `.aelyxora/cache/**` | disposable services |
| Vendor/external | lockfiles, dependencies | tool-specific validated workflow |

The owner of each output path is recorded in a generation manifest. Never infer ownership solely from file extensions. A generated-owned file modified by a user is **conflicted**, not silently overwritten.

## Generation plan contract

Every generator run produces a dry-run plan before commit:

- input model revision and content hash
- generator identity, version and backend capability snapshot
- sorted output paths, owner, content hashes and expected previous hashes
- proposed create/replace/delete operations
- source references and diagnostics

Paths must be normalized relative paths under the project root; reject traversal, symlink escapes, case-fold collisions on case-insensitive targets and duplicate outputs.

## Update algorithm

1. Capture immutable model snapshot and current manifest.
2. Compute desired outputs in staging; never mutate the workspace during planning.
3. Validate target/backend capabilities and expected file hashes.
4. Preserve user-owned paths unconditionally unless an explicit approved source patch targets them.
5. If previous generated content differs from manifest hash, report conflict and stop replacement of that file.
6. Review diff; write via temporary files and atomic replacement where supported.
7. Persist updated manifest last after verifying outputs; journal recovery handles interruptions.

No regex surgery on arbitrary user code. Extension points are stable generated interfaces, separate files and declarative hooks. An IDE crash between file writes must be detectable and recoverable.

## Code-to-model reflection

Limited importers may recognize explicitly supported, syntactically parsed declarations with stable mapping metadata. Unknown manual code remains code-only. Structural ambiguity yields a diagnostic rather than speculative model updates.

## Required tests

Hand-modified generated file detection; delete/rename safety; concurrent IDE/external edit; invalid paths; interrupted generation; deterministic output order; custom-code survival across regenerations; hash mismatch rollback.
