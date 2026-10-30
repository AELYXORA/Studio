# AUI Package Resolution and Reproducible Build Contract

**Status: proposed; no resolver or reproducible native build implemented.** [Project Format](project-and-package-format.md) owns persistence; [Schema Validation](schema-validation-contract.md) owns structural checks; [TargetMIR](aui-targetmir-native-codegen.md) owns target-specific code generation.

## Identity and trust

A package has a declared packageId and release identifier, but **content identity is a cryptographic digest**, not the release label. Dependency resolution is strictly offline unless the user separately authorizes retrieval; no implicit fetching, floating revisions or auto-upgrades during a build. Names and display labels never establish integrity or publisher identity. SHA-256 provides integrity against a recorded digest, not authenticity: package signing/trust roots remain open.

## Lockfile format

Proposed `aui.lock.json` has: `format: "aui.lock"`, `lockFormat` compatibility token, `projectId`, `resolved` entries and `toolchain`. Each resolved entry records exact `packageId`, `packageVersion`, `contentDigest` algorithm/value, repository-relative `sourceRoot`, declared `dependencies`, and `targets`. Toolchain identity records compiler, assembler, linker, runtime and target ABI identifiers; a real build must include executable tool hashes and configuration.

**No lockfile is created for the existing sensor fixture** because its declared Assembly sources do not exist. A made-up digest would misrepresent reproducibility.

## Package digest procedure (design proposal)

**Detailed owner:** [D6 Package Integrity](d6-package-integrity.md) freezes a *candidate* domain-separated BE64 length-framed manifest+source file-set, portable ASCII path restrictions, and source ownership rules. The [integrity vectors](../../examples/architecture-sensor/d6-integrity-vectors.json) specify expected hashes. Earlier generic descriptions in this file are summaries, not alternative algorithms. All native tests remain NOT-RUN.


Produce a logical file-set digest rather than hash ambient directory bytes: enumerate manifest-listed files, normalize relative UTF-8 paths with '/' separators, reject absolute/traversal/symlink escapes and case-fold collisions on relevant filesystems, sort by UTF-8 bytes, then frame each entry with unambiguous length-prefixed path, byte count and SHA-256 file digest; hash the framed stream using SHA-256 and an explicit domain separator. Include manifest bytes with a prescribed canonical JSON serialization (still to be frozen). Generated caches, timestamps and workspace-only view positions never enter package content identity unless explicitly declared as package inputs.

No digest algorithm is finalized until reference test vectors and independent implementations agree. A manifest hash cannot certify files absent from the package.

## Resolver algorithm

1. Validate project and package JSON structure and reject unknown required schema features.
2. Read the committed lockfile; require one matching exact selected identity for every dependency, unless design-time unlock/re-resolution is separately requested.
3. Verify each sourceRoot remains inside allowed project/vendor roots, independently of symlink resolution.
4. Hash every locked package's declared files; compare digest; reject missing paths, duplicate entries and modified bytes.
5. Resolve dependency graph: reject missing packages, conflicting version/content identities, undeclared cycles and duplicate exported type IDs.
6. Validate target triple, ABI, ISA features, platform service needs, execution domain and component capability contracts.
7. Produce a frozen input manifest for code generation and tests; never silently rewrite project/lock during compilation.

## Reproducible build record

Build identity binds project semantic graph digest, exact source/package digests, toolchain executable digests, sysroot/SDK and platform-library identity, compiler/linker flags, target triple, ISA feature set, ABI contract, environment allowlist and declared nondeterminism. Separate **reproducible inputs** from **reproducible output bytes**: outputs require experimentally identical bytes on isolated repeat builds, with timestamps/build IDs/path embeddings normalized or documented. Signing and packaging may be nondeterministic and must be measured separately.

## Failure diagnostics

`PKG_LOCK_MISSING`, `PKG_MISSING`, `PKG_DIGEST_MISMATCH`, `PKG_PATH_ESCAPE`, `PKG_VERSION_CONFLICT`, `PKG_DEP_CYCLE`, `PKG_DUPLICATE_EXPORT`, `PKG_TARGET_UNSUPPORTED`, `BUILD_TOOLCHAIN_MISMATCH`, `BUILD_NONREPRODUCIBLE`. Diagnostics must include precise package/path/target identities without exposing secrets.

## Verification gates

- Mutate one declared source byte: hash mismatch before compile.
- Reorder directory entries: identical digest; rename a declared file: changed digest.
- Reject path traversal and symlink escapes, unknown target and ABI mismatch.
- Reject transitive dependency conflict and duplicate exported types.
- Build twice from identical frozen inputs on a validated target; compare artifacts and isolate nondeterministic sections.
- Verify cancellation never publishes partially built artifacts; retain prior known-good state.

## Open

Canonical JSON serialization, exact framed digest test vectors, dependency version conflict strategy, executable tool hashes and sysroot capture, package signing, deterministic linker configuration and release-policy compatibility. All remain design-stage until independent local validation.


## Canonical package identity (cross-gate proposal)

[D2 Identity](d2-identity-and-type-resolution.md) treats nominal TypeID spelling as only a first-stage lookup; resolved equality requires the exact locked package digest and exported contract digest. [D6 Canonical Persistence](d6-canonical-persistence.md) proposes SHA-256 framing for a sorted declared file-set and canonical package manifest. These are not accepted algorithms until full test vectors and independent implementations agree. A text release version cannot substitute for a verified package digest or source inventory; the sensor sample's missing Assembly files therefore prohibit a real locked/native build.
**Export contract and byte provenance separation:** [D2 Export Contract Identity](d2-export-contract-identity.md) defines logical exportedContractDigest, while this file's lock/resolver verifies exact packageContentDigest before build. The current [lock schema](../../schemas/package-lock.schema.json) is a draft and now describes an explicit export digest registry; independently compute the export digests from verified package declarations, never trust lock claims alone. No source-only formatting change should invalidate semantic graph meaning, but it still invalidates affected artifact tests.

**Durable snapshot dependency:** [D6 Canonical Persistence](d6-canonical-persistence.md) now proposes immutable packageObjects retained by committed snapshots. For a recoverable locked native build, verify that the current project's lock export registry equals the index's reachable packageObjects and that each object store directory contains the exact manifest and sources. External package absence must not be silently repaired by fetching the network, and a lock alone is not proof that original source bytes can be recovered.
