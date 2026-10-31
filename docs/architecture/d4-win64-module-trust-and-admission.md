# D4/D6 — Win64 Module Authenticity and Execution Admission Policy

**Status: PROPOSED SECURITY GATE, not implemented, approved, signed, deployed or security-tested.** This document owns the *candidate sequence of trust decisions* before a [Win64 module](d4-win64-module-and-result-descriptors.md) may be loaded and a [native call frame](d4-win64-native-component-abi.md) dispatched. [D3 source/snapshot](d3-source-snapshot-reconciliation.md) owns AUI source/Graph review. [D6 package integrity](d6-package-integrity.md) owns package bytes. **Hash match, certificate signature and authorization are three different proofs.**

## MT1. Two independently required kinds of signature/approval

A production candidate module is admitted only if **both** trust layers succeed:
- **Artifact authenticity:** OS-supported signature verification on the actual candidate PE image, using Windows Authenticode policy via WinVerifyTrust or WinVerifyTrustEx under a configured verification action; a successful trust-provider result must additionally match an explicit allowlisted publisher identity / key policy. OS default trust alone is not the project's architecture approval.
- **AELYXORA authorization:** an independently authenticated review receipt pins exact module/source/build identities, project/Graph and command export digests, target ABI, allowed effects/capabilities, reviewer identity/scope, approval epoch, expiry/revocation policy. A textual approved flag or an unsigned JSON object cannot satisfy this layer.

For Windows, Microsoft documents that **WinVerifyTrust(WINTRUST_ACTION_GENERIC_VERIFY_V2)** can invoke the Authenticode policy provider. The call must return **exact success (0)** under the chosen trust action; do not use generic HRESULT SUCCEEDED/FAILED macros for this return. The Windows trust provider's verdict alone is not a proof of approval by AELYXORA. The exact certificate-chain, revocation and timestamp policies need independent review, particularly when offline. Authoritative OS reference: https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-winverifytrust

## MT2. Full candidate admission sequence (fail closed)

1. Acquire an immutable, bounded candidate image from exact D6 package lock, approved source/toolchain build manifest and expected output artifact; refuse symlink/reparse/alternate data stream or path substitutions outside approved content-addressed store. Reject unlisted PE imports and dependent DLLs not covered by a separately verified import policy.
2. Compute a SHA-256 of **every exact file byte** of the candidate unsigned/signed PE *as applicable to its stage*. This is source/build provenance, not the same as Authenticode's image-signature digest calculation. Do not substitute a normalized PE section hash for a complete raw-file hash. Compare against the expected digest in independently trusted review inputs.
3. Verify OS Authenticode on the **same pinned candidate** under approved Windows trust action; check allowed certificate/publisher identity or pinned key, chain policy, intended code-signing usage, signature validity, applicable timestamp/expiry policy, and revocation freshness. Unavailable revocation evidence under a production policy requiring freshness => **reject or explicit offline non-executable**; do not silently succeed.
4. Verify a separate architect-authorized receipt covering exact project Graph/lock/source/ABI/core registry/toolchain/artifact identity and scoped operations; check signature, reviewer eligibility, revocation and expected operation/effect/target. If the receipt does not bind *this exact image*, reject even if Authenticode is valid.
5. To prevent TOCTOU, load only the same verified immutable bytes via a controlled/staged loading mechanism with no writable replacement window, untrusted DLL search path or unverified transient imports. Actual Windows loader/mapping semantics and signed-file immutability **require** native proof; a Windows path plus a hash string is not a safe handle.
6. Validate PE architecture/sections, relocations/imports, CFG/DEP/ASLR policy, module header bytes, table bounds, operation ID and contract digests, exact Win64 ABI layout ID, exported function RVA and calling convention before storing a generation-scoped live moduleHandle.
7. At **each operation invocation**, independently verify live graph/resource/capability lease, execution domain, view/task generations, bounded buffers and admission budgets. Module trust alone **never** grants network, filesystem, hardware or elevated OS capabilities.
8. On revocation/update/unload, stop *new* module and operation admission. Existing accepted work retains true provider ownership until terminal completion or confirmed quiescence, with no use-after-unload and no transfer of old callbacks to a new module generation.

## MT3. Trust identities, non-recursive hashes and signing

Require the proposed trust record to bind separate names: logical exportedContractDigest, verified core-registry set fingerprint, source file hashes, exact D6 package digest, toolchain/build-inputs digest, unsigned PE artifact SHA, **signed** PE full-file SHA, publisher identity, target ABI layout ID and reviewer authorization receipt digest. These are **different identity domains**, not alternate spellings of one SHA.

An Authenticode signing/timestamp step can change PE bytes; consequently an unsigned artifact's raw SHA must not be compared to the signed artifact's raw SHA as if equality were expected. Reproducibility is tested on a frozen *unsigned* artifact (and any deterministic debug symbols); signed output is separately verified against its approved signed-file digest and signing provenance. Do not put a naive hash of the entire signed image inside its own image header and assume a self-consistent fixed point. Detached receipt and manifest references must follow an explicit nonrecursive DAG.

Any other embedded signature, hash, or metadata must use approved domain and byte coverage rules; avoid circular source/Graph/snapshot/approval references by recording the approval **outside** the content it signs, and staging it into a new D6 index with a well-defined ordering.

## MT4. Offline, local-development and threat model

No fallback from untrusted/unsigned or expired production module to *elevated* dev mode. First proposed production rule: **unsigned module => reject execution**; in Phase II research/development, an isolated local harness may run test binaries only when explicitly authorized with separate scope, visible unsafe designation, nonproduction capabilities, and no access to user/project secrets. This is not normal AELYXORA product mode, and no design file grants permission to run arbitrary code.

Threats to test: forged approvalStatus, self-signed unrelated certificate, compromised otherwise-valid publisher, replaced PE between hash and LoadLibrary, malicious import/DLL search path, stale approval after graph update, unsigned module copied into trusted folder, replayed approval, revoked certificate offline, UI key reused, and signed image with a mismatching native contract table.

## MT5. Proposed diagnostics (future native security tests NOT-RUN)

- MODULE_ARTIFACT_MISMATCH: complete file bytes do not match pinned signed artifact identity.
- MODULE_SIGNATURE_UNTRUSTED: Authenticode policy or configured publisher check fails.
- MODULE_REVOCATION_UNVERIFIED: required freshness unavailable.
- MODULE_APPROVAL_UNVERIFIED / MODULE_APPROVAL_STALE: authorization absent, forged, revoked or mismatched exact context.
- MODULE_IMPORT_UNAPPROVED: dependent DLL/import/PE security contract not authorized.
- MODULE_LOAD_RACE: pinned candidate cannot be loaded without a substitution race proof.
- ABI_HEADER_INVALID / ABI_TARGET_MISMATCH: after trust checks, native module is incompatible.
- CAPABILITY_DENIED: runtime permission is absent despite trusted module.

**P0 remaining:** exact receipt/writer trust schema, key management, offline revocation and timestamp policies, pinned publisher constraints, Windows loader and DLL search proof, OS-supported signature integration, actual native module signature checks and fault injection. All previous ABI layout vectors are *design-only*, not proof of this admission policy.