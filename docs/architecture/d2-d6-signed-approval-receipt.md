# D2/D4/D6 — Signed Architecture and Executable Approval Receipt Protocol

**Status: PROPOSED SECURITY / SERIALIZATION CONTRACT, not an accepted signing system, valid real signature, deployed trust store, approved module, or runtime authorization.** [Source-to-Graph bundle](d3-source-snapshot-reconciliation.md), [D6 canonical JSON](d6-canonical-persistence.md), [typed TypeReference v2](d2-d6-typeref-v2-resolution.md), [Win64 module trust](d4-win64-module-trust-and-admission.md) and [reproducible build](d6-win64-reproducible-build-contract.md) retain their scope. The [receipt envelope schema](../../schemas/aui-signed-approval-receipt.schema.json) checks syntax **only**, not signer identity/permission.

## AR1. Threat, roles and two independent approvals

A string named approved, JSON Schema success, verified digest or Windows Authenticode success are **not** architecture approval. Production candidate requires:

1. **Architecture approval**, signed by an explicitly authorized architecture-reviewer over a preapproval proposal containing exact ProjectID, GraphRevision, semanticGraphDigest, source-link bundle digest (which in turn pins source bytes and profile), lock digest, core registry/export set, target ABI/layout ID, effects and capability scope.
2. **Executable approval**, signed by separately scoped release-approver binding the **same approved proposal** plus exact signed PE full-file SHA-256, build input digest and operation contract set digest, after a deterministic build and signing step. A release signature cannot authorize a different project/Graph/source or widen the architecture receipt's effects/capabilities.

The first candidate cryptographic algorithm is Ed25519 with externally pinned key identities, **not** an arbitrary user-supplied public key in the same receipt. The trust registry maps signerKeyId -> exact public key bytes, role, project/target scope, minimum acceptable approvalEpoch, revocation state and key rotation policy. No key, role or signature is created or verified by this documentation pass. Offline revocation and key custody still P0; if required freshness cannot be proved, deny production execution.

## AR2. Hash-acyclic proposal -> receipts -> D6 snapshot

[Proposal structural schema](../../schemas/aui-review-proposal.schema.json) defines a strict canonical object with format aui.review-proposal, profile 1-draft, projectId, graphRevision, semanticGraphDigest, lockDigest, sourceLinkBundleDigest, typedLinkDigest, coreRegistryFingerprint, typeExportSetDigest, targetTriple, abiLayoutDigest, capabilities, effects and sourceRevision. Sort capabilities/effects bytewise and reject duplicates. The object has **no approval receipt field, no signature, no output artifact digest and no final snapshotDigest**.

    proposalDigest = SHA256(
      ASCII("AELYXORA/approval-proposal/v1") + 0x00 +
      D6P1CanonicalUTF8(validatedProposal)
    )

The [envelope schema](../../schemas/aui-signed-approval-receipt.schema.json) defines exactly format, envelopeVersion, payload and signature; payload has profile aui.approval-payload/v1-draft, explicit reviewKind (architecture or executable), decision=approve, proposalDigest, sourceLinkBundleDigest, ProjectID/GraphRevision/semanticGraphDigest/lockDigest/coreRegistryFingerprint/targetTriple/abiLayoutDigest/capabilities, signerKeyId, signerRole, approvalEpoch, notBefore, expiresAt, 16-byte nonce encoded as 32 lowercase hex.

Executable payload **also requires** signedPeSha256, buildInputDigest and operationContractSetDigest and must have release-approver role. Architecture payload MUST omit all three and require architecture-reviewer role. Payload repeats proposal fields deliberately; a semantic verifier MUST compare them all with the pinned proposal, including sort/order of capabilities and exact effective set. Both approvals bind the **same proposalDigest** and cannot widen the proposed effects or capabilities. Actual runtime capability checks are still independent.

Cryptographic sign input, candidate exactly:

    Ed25519Message = ASCII("AELYXORA/signed-approval/v1") + 0x00 +
                     D6P1CanonicalUTF8(validatedPayload)

The detached signature is Ed25519 over the **exact message bytes**, not over a pre-hashed JSON string or an ad hoc variant of the source SHA; public key must be obtained from the trusted role/epoch store, not from untrusted payload. Signature is Base64 encoding of exactly 64 bytes, checked for canonical alphabet/padding. Receipt bytes are stored as an immutable artifact in the subsequent D6 snapshot index. Its file SHA belongs in D6 source index, not in signed payload.

**No circular dependency:** exact AUI source + lock + Graph + typed export/proposal manifest -> proposalDigest -> architecture approval -> build recipe -> unsigned PE -> signed PE -> executable approval -> new D6 immutable index/snapshot digest -> published HEAD. The approval payload does **not** bind the final enclosing snapshotDigest, its own receipt digest, or later HEAD epoch. A final D6 recovery verifier rechecks receipt + proposal + source-index closure under one pinned snapshot before restoring executable trust.

## AR3. Validation and replay protection

1. Strict UTF-8 JSON parse, schema validation, D6 P1 canonicalization, key collision detection and bounded input sizes before signature work. No unknown fields or "signatureAlgorithm" supplied by attacker: envelope signature.algorithm must be the supported Ed25519 token.
2. Independently compute proposalDigest from immutable candidate proposal, verify sourceLinkBundleDigest against exact source registry/AUI bytes and Graph/lock/core/type exports. Recompute all typed references and target/effect scope. **Unapproved typed Graph/schema still blocks execution** even if SHA and signature mathematically match.
3. Verify exact project/target/role/key scope, signer public key from separately secured trusted registry, key validity/rotation/epoch, signature over exact canonical payload and time window. notBefore <= current verified time <= expiresAt; no inferred local clock correctness or indefinite offline approval.
4. Check revocation, signer key compromise and approvalEpoch monotonic anti-replay policy; retain durable authorized epoch/revocation registry outside ordinary user-editable project files. A receipt replayed after graph/source/target update fails even with a valid historic signature.
5. Architecture and executable approvals MUST each independently match the proposalDigest. Executable scope <= architecture capabilities and exact module OperationID/effect/target; no expansion from a signed runtime image.
6. OS Authenticode + publisher allowlist + exact signed PE SHA + safe loader/import closure are **additional** D4 controls. Only after all pass may live capability lease and provider admission be attempted.
7. On key revocation, changed source/lock, expired approval, or incompatible ABI, stop new operation admission; in-flight work retains true native/provider owner until terminal completion or confirmed quiescence. D6 HEAD validity does not imply ongoing operation permission.

Signatures from different signers are not assumed interchangeable; same person/key holding both roles requires an explicit accepted separation-of-duties policy. Candidate default: distinct signing keys/roles. Time claims are security-sensitive: no wall-clock rollback grants permission.

## AR4. Failure precedence and future negative golden cases

| Input | Primary rejection |
| --- | --- |
| No proposal or wrong computed digest | APPROVAL_PROPOSAL_MISMATCH |
| Correct payload structure, no signature / wrong signature bytes | APPROVAL_SIGNATURE_INVALID |
| Signer key supplied only inside untrusted receipt | APPROVAL_KEY_UNTRUSTED |
| Valid signature but no assigned project/reviewer role | APPROVAL_ROLE_UNAUTHORIZED |
| Architecture payload includes signed PE fields | SCHEMA_INVALID |
| Executable payload omits signedPeSha256 | SCHEMA_INVALID |
| Signed image changes after executable approval | MODULE_ARTIFACT_MISMATCH |
| Source-link bundle/Graph/lock changed | AUI_APPROVAL_STALE |
| Receipt replay after epoch/revocation update | APPROVAL_REPLAYED / APPROVAL_REVOKED |
| Expiry or unsupported offline revocation freshness | APPROVAL_EXPIRED / MODULE_REVOCATION_UNVERIFIED |
| Ed25519 signature on noncanonical alternate message | APPROVAL_SIGNATURE_INVALID |
| Executable approval attempts capabilities not in architecture | CAPABILITY_DENIED |
| Receipt refers to its own final enclosing snapshot digest | APPROVAL_HASH_CYCLE |
| Both signatures valid, native Win64 layout unverified | ABI_LAYOUT_UNVERIFIED |
| Both signatures valid, current live capability revoked | CAPABILITY_DENIED |

[Unsigned reference proposal and negative cases](../../examples/architecture-approval/) provide **shape and hashing** designs only. They do not contain a keypair, private key, valid signature, trust store, approved user/architect decision or executable claim.

## AR5. Remaining P0

Key custody/rotation/revocation semantics, secure signer eligibility and durable epoch registry, approval grant and signing UX, exact sourced signed module trust and ABI layout linkage, full D6 snapshot/index nonrecursive recovery evidence, CPU/OS clock trust, canonical Unicode/JSON signature interoperability and native runtime integration. **Do not classify D1–D8 as Accepted from this draft.**
