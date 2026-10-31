# D6/D4 — Deterministic Win64 Native Build Inputs and Reproducibility Evidence

**Status: PROPOSED design baseline, not a configured build system, real build or qualified Win64 toolchain.** [D6 Offline Resolver](d6-offline-dependency-resolution.md) owns exact locked package resolution; [D6 Package Integrity](d6-package-integrity.md) owns source file-set digest; [D4 Win64 ABI](d4-win64-native-component-abi.md) owns emitted ABI/layout; [Module Trust](d4-win64-module-trust-and-admission.md) owns signed-artifact authorization. The design **does not** create GitHub Actions/CI, branches, or any Studio implementation code.

## RB1. Determinism and boundaries

A native **unsigned PE32+/COFF binary** is reproducible only if independent rebuilds using **identical fully pinned inputs** yield exactly identical output bytes. A nonzero signed-file hash change after certificate signing or timestamping does NOT necessarily disprove reproducibility of the *unsigned* compiler/linker stage; signing is a separately recorded and authorized step. Conversely, a matching unsigned binary digest is not publisher trust or permission to execute. COFF TimeDateStamp and PDB GUID/path behavior need explicit deterministic handling; do not compare displayed build dates as a substitute for byte equality.

Microsoft describes a deterministic PE/COFF file as one whose content depends only on documented inputs rather than ambient environment; its COFF TimeDateStamp may be hash-derived rather than calendar time. This is toolchain-specific behavior and must be verified on the exact selected assembler/linker. References: https://github.com/dotnet/runtime/blob/main/docs/design/specs/PE-COFF.md and https://learn.microsoft.com/en-us/dotnet/fundamentals/runtime-libraries/system-reflection-portableexecutable-debugdirectoryentrytype

## RB2. Exact build input closure

One [proposed build input schema](../../schemas/aui-win64-build-inputs.schema.json) describes a **source-controlled, deterministic** manifest of complete build inputs, with no output hash to avoid self-reference:

- source Graph/source revision, exact D6 snapshotDigest and package lock digest; **no unresolved planned target**;
- target triple x86_64-pc-windows-msvc, Windows user-mode ABI/layout version ID and exact **pinned target layout contract digest**;
- exact approved core logical registry fingerprint and generic type instance digest list (no template-as-instance substitution);
- each input **path + SHA-256 of exact original bytes + category** (AUI source, Assembly, header, resource, generated deterministic intermediate, link script) with canonical portable path rules, sorted unique paths and no unlisted executable input;
- exact tool executable file SHA-256 and version string (assembler, linker, resource compiler, optional converter) plus flags/order, target CPU feature profile, build mode, reproducible error handling;
- explicit env whitelist (locale/timezone, source date epoch only where toolchain supports it, PATH only by exact tool location not ambient fallback), input working virtual root, deterministic ordering/normalization policy for PDB and COFF;
- dependency closure: all imported DLL identities must have an independent approved import policy; do not silently download or execute tools during a build;
- intended artifact class unsigned Win64 module and declared result/output file paths (not expected hashes in the hashed input manifest).

Canonical bytes follow D6 P1. The buildInputDigest is SHA256(ASCII(AELYXORA/win64-build-inputs/v1) || 0x00 || canonical manifest UTF-8 bytes). The digest is a **build recipe identity**, not a signed review token, exportedContractDigest, semanticGraphDigest or compiler ABI identity.

## RB3. Two-stage evidence and signing DAG (no circular hashes)

1. Compute and approve an exact source/Graph/lock/registry/ABI input manifest. Digest it as RB2; freeze tool executables and tool arguments.
2. Run deterministic build **in an isolated and explicitly controlled build environment**; record SHA-256 of the *unsigned* PE and any PDB/resource outputs separately. A first local build gives a *candidate* expected output, not reproducibility proof.
3. Rebuild with a **separate clean workspace/environment** using the same pinned input manifest; compare complete unsigned output file bytes, debug symbols and deterministic generated intermediates. A mismatch fails BUILD_NONDETERMINISTIC with a first differing byte/section and input provenance evidence. Do not assume same-tool rerun in one dirty directory proves independence.
4. Sign the reproducible unsigned PE via approved publisher credentials; record exact signed file bytes/hash plus code-signing certificate chain identity, timestamp proof and policy. The signed output is allowed to differ from unsigned input. A production signed-artifact approval receipt binds the **exact signed-file SHA** and approved source/build/Graph.
5. Verify **WinVerifyTrust/AuthentiCode**, publisher allowlist, independent graph/source authorization and **same immutable file** during module loading; all failures deny execution. Signed trust does not replace ABI layouts or D5 runtime capabilities.
6. If any source byte, tool binary, flags, core registry, ABI layout, package lock or OS-target profile changes, the input digest changes; invalidate earlier build/sig/test evidence. An unchanged logical exportedContractDigest does not exempt source-only rebuilds.

D6 project snapshot HEAD publication is **not** the same transaction as signing and releasing an executable image. Each artifact retains its own exact identity and approval. Build time and random seeds must be either forbidden as output influences or documented deterministic inputs; do not claim a flag named reproducible proves bitwise output.

## RB4. Source provenance and toolchain requirements

First-host assembler/linker are **candidates**, not implicitly chosen. NASM, a PE/COFF-capable linker, Windows-compatible unwind/debug generator, deterministic resource compiler and any SDK input must be pinned by **actual file contents** and exact command lines. The user-established product implementation is Assembly-first; a host/build tool may itself be third-party, but this does not authorize adding C++/Qt/Python as Studio product code.

Absolute paths, usernames, temp directory IDs, random GUIDs, local timestamps, locale-dependent sorting, network package managers, nondeterministic archive member order, linker incremental state and PDB debug paths are **controlled variables**. Normalize them only where the selected tool documents safe equivalent behavior; otherwise reject the toolchain for reproducible profile. Do not blindly rewrite signed binaries or change PE headers post-signature.

## RB5. Failure taxonomy and future acceptance vectors (NOT-RUN)

| Scenario | Expected |
| --- | --- |
| Same pinned manifest, two clean builds produce byte-identical unsigned PE/PDB | Candidate reproducibility PASS **only after observed independent native evidence** |
| Same exported contract, change one ASM whitespace byte | Source and build-input digest change, new build required |
| Change tool executable contents, even if version string same | Build-input digest changes |
| Change argument order, CPU target feature or ABI layout ID | Build-input digest changes |
| Ambient current time leaks into output, no declared deterministic policy | BUILD_NONDETERMINISTIC |
| Lockfile omits required package/source, build fetches at runtime | PKG_LOCK_MISSING / BUILD_UNDECLARED_INPUT |
| Signed vs unsigned raw file SHA differ | Expected and separately recorded; not an error by itself |
| Authenticode valid but source/Graph approval invalid | MODULE_APPROVAL_UNVERIFIED |
| Same signed file hash but altered module effect/graph requirements | MODULE_APPROVAL_STALE, not automatic grant |
| COFF unwind/Win64 calling convention invalid despite matching build outputs | ABI_LAYOUT_UNVERIFIED; reproducibility is not correctness |
| Source file order/path collision changes artifact selection | BUILD_INPUT_COLLISION |
| Artifact bytes replaced between verification and load | MODULE_LOAD_RACE; deny |

See [future build-input negative cases](../../examples/abi/win64-build-negative-cases.json). They document expected behavior and have **not** run in an actual AELYXORA toolchain.

## RB6. P0 before architecture freeze

Approved first-host assembler/linker, exact toolchain versions and binary digests, project/module build manifest integration, D6 canonical Unicode/path edge cases, target ABI and native layout ID, deterministic PDB and PE behavior, independent rebuild procedure, signing and approval receipt identity, OS module load safety and observed Win64 build/test evidence. **No implementation, CI, benchmark or release is authorized by this document.**