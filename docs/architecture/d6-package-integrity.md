# D6 — Package Content Identity, Portable Paths and Locked Exports

**Status: Proposed, not architect-accepted, implemented, or verified by AELYXORA.** Owner of the candidate package file-set digest. [Package Resolution](package-resolution-build.md) owns dependency selection; [D6 Canonical Persistence](d6-canonical-persistence.md) owns snapshots; [D2 Identity](d2-identity-and-type-resolution.md) owns type identity.

## K1. Package boundary

First-profile package = one valid canonical manifest at virtual path component.auipkg.json and exactly the Assembly or other explicitly approved source files referenced by its components[].sources[].path declarations. No ambient directory contents, generated caches or timestamps. A declared path may be shared by components if the same exact bytes are used and target/ownership checks allow sharing; one inventory entry per path.

The manifest testFixtures field is currently untyped. Packages with nonempty fixture lists or other resources that require including additional files are **unsupported for an actual locked build until their inventory semantics are specified**. The current sensor example is deliberately UNBUILDABLE because its declared ASM sources are absent; do not invent a lock digest.

## K2. First-profile portable path rules

Paths are project/package-relative UTF-8 with only ASCII segments matching [A-Za-z0-9_.-]+, separated by forward slash. Reject empty, dot or dot-dot segments; absolute/drive/UNC forms, backslash/colon/control bytes, percent-encoded traversal and symlink/junction/reparse escapes. Reject collisions after ASCII lowercase mapping, even on a case-sensitive host. Reject prefix conflicts such as a file named src and another declared path src/a.S. Use safe handle-relative operations and re-check containment when reading, avoiding time-of-check/time-of-use swaps. A future Unicode path profile requires explicit normalization/collision contracts. Sort paths by exact byte order, never filesystem enumeration order.

## K3. Canonical manifest bytes

Strictly parse and schema-validate the package manifest. Canonicalize JSON objects by UTF-8 key order, with the D6 integer and Unicode rules and no whitespace. Package manifest arrays remain **order-preserving** in this digest profile, even when some reorderings are semantically equivalent; this is intentionally distinct from semantic Project Graph normalization. Reject unsupported extension fields; no self-referential packageDigest entry. Represent manifest in the file-set inventory at the fixed name component.auipkg.json with its exact canonical JSON UTF-8 bytes. All other source files are exact raw bytes, including whitespace and line endings.

## K4. Exact digest frame

Initial bytes: ASCII domain AELYXORA/package-files/v1 followed by NUL (one byte 00).

For each inventory item in ascending path UTF-8 byte order, append:

    BE64(length(path UTF8 bytes)) || path UTF8 bytes ||
    BE64(length(file bytes)) || SHA256(file bytes)

BE64 = exactly eight unsigned big-endian bytes; SHA256(file bytes) = exactly 32 **binary bytes**, not hexadecimal ASCII. No newline, path count, separator or terminator after entries. Final packageContentDigest is lowercase SHA-256 hex of the entire domain + frames. Check configured size bounds before allocation or serialization.

This proves integrity relative to a trusted expected digest, NOT publisher authenticity. A lock or package manifest never grants I/O execution privileges.

## K5. Lock resolution and TypeID separation

Candidate lock schema: [package lock](../../schemas/package-lock.schema.json). Required package identity is packageId, exact packageVersion, contentDigest and validated relative sourceRoot. Toolchain identity and environment are separate.

1. Require an exact selected lock entry for every package dependency. No implicit fetch, upgrade or guessed version.
2. Validate the package manifest, listed source paths, symlink/reparse containment and absence of unexpected executable build input.
3. Check each declared source exists, is within sourceRoot, and matches any declared target and source ownership constraints. Exact manifest + source file-set is hashed under K4.
4. Compare calculated digest to lock before code generation; mismatch -> PKG_DIGEST_MISMATCH.
5. Resolve exported TypeID and OperationID via package content identity and exported contract digest. Export contract field-level digest is a separate D2/D4 P0 item; do not claim it from a version label or from a native pointer.
6. Check dependency closure, duplicate exports, target/ABI compatibility, capabilities and actual platform support. Target status planned does not establish executable support.
7. Freeze the input set; no project or lock mutation during a build.

sourceRoot is a *locator* and not part of package content digest. For an empty relative root, the lock may use the special sourceRoot value '.' (only as a root locator, never as a file inventory path); its containment must still be verified. Relocation may retain content identity after safe path validation. Human-owned source changes require approval. An unchanged semantic contract may keep the same public contract digest after a formatting-only source edit, while its package digest changes.

## K6. Acceptance cases (all future tests NOT-RUN)

| ID | Fixture | Expected outcome |
| --- | --- | --- |
| PK-01 | Reorder manifest object keys only | Identical package digest |
| PK-02 | Reorder a manifest array | Different first-profile package digest |
| PK-03 | Change one source byte | Different digest, old lock rejected |
| PK-04 | Remove a declared source | PKG_MISSING |
| PK-05 | Build includes unlisted source | PKG_UNDECLARED_SOURCE |
| PK-06 | Paths src/A.S and src/a.s | PKG_PATH_COLLISION |
| PK-07 | Traversal, absolute, symlink/reparse escape | PKG_PATH_ESCAPE |
| PK-08 | Duplicate locked TypeID/operation | PKG_DUPLICATE_EXPORT |
| PK-09 | Content disagrees with lock | PKG_DIGEST_MISMATCH |
| PK-10 | Build on merely planned target | PKG_TARGET_UNSUPPORTED |
| PK-11 | Nonempty untyped fixture inventory | PKG_INVENTORY_UNSUPPORTED |
| PK-12 | AI rewrites human-owned source without approval | SOURCE_OWNERSHIP_DENIED |

[Package and snapshot codec vectors](../../examples/architecture-sensor/d6-integrity-vectors.json) specify exact candidate hash bytes. They are not passed native tests.

**Open P0:** export contract canonical digest, typed resource/fixture manifest, source ownership and path safety across platforms, publisher authenticity, dependency namespace conflicts and independent vector approval. No implementation is implied.

**Logical export resolution:** see [Export Contract Identity](d2-export-contract-identity.md). The verified packageContentDigest is immutable source provenance; logical exportedContractDigest is a distinct semantic hash. Source-only edits invalidate the package lock/build while preserving the graph's logical type identity if every public contract remains byte-equivalent under the candidate projection. No automatic execution trust carries over.

**Durable package-object store:** [D6 Canonical Persistence](d6-canonical-persistence.md) proposes an immutable project-local objects/packages/<packageContentDigest>/ namespace. For the durable-save profile, the committed snapshot index lists every reachable locked packageId/contentDigest, and the store retains verified manifest + declared source bytes until no committed or pinned snapshot references them. A lockfile alone is insufficient to prove recoverability after a package checkout is deleted. Actual platform implementation remains unverified.

**Locked reference and dependency closure:** [Exact Offline Resolver](d6-offline-dependency-resolution.md) requires explicit transitive dependencies and a verified exact lock export registry. [Locked Pure Reference](../../examples/locked-pure-reference/README.md) illustrates manifest+source bytes in a content-addressed object, a first-slice lock and HEAD; all native tests are NOT-RUN.
