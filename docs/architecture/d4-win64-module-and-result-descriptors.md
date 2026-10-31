# D4 Win64 — Module Verification, Operation Entries and Tagged Result Descriptors

**Status: ADDITIONAL PROPOSED LAYOUT; not a released ABI or native test.** This document closes a *design-shape gap* left in [D4 Win64 CallFrame V1](d4-win64-native-component-abi.md), without claiming complete native ownership/lifetime safety. A component is not invoked until its executable image and operation table have been verified and an exact approved [D2 logical contract](d2-export-contract-identity.md) is matched. Host/source signatures, publisher trust, PE loader mitigation, and actual COFF/unwind are separate P0.

## M1. One verified in-process module, not an arbitrary DLL API

- Host loads only explicitly reviewed, byte-hashed, target-qualified PE32+/COFF images; a file hash and a JSON approvalStatus string alone do not prove trusted authorization.
- The module's **public** TypeID/OperationID is independent of its native table ordinal. The ordinal changes whenever module ordering changes; graph/source links use exact TypeIDs and exportedContractDigest, never an ordinal as a persistent identity.
- A runtime operation dispatch key is (verified module generation, operationIndex, exact logical OperationID digest, approved operation contract digest, target and ABI layout ID). Any mismatch -> reject before invoking a function pointer.
- No user-defined PE import, OS syscall or hardware effect is silently approved by the module header. Live capability leases are checked on every effectful operation.

## M2. Exact proposed descriptors — native little-endian Win64, alignment 8

**AuiModuleHeaderV1**, 80 bytes:

| Offset | Size | Name | Requirement |
| --- | --- | --- | --- |
| 0 | 4 | magic | 0x314d5541, LE bytes 41 55 4d 31 (AUM1) |
| 4 | 2 | major | 1 |
| 6 | 2 | minor | 0 |
| 8 | 4 | headerSize | 80 |
| 12 | 4 | operationCount | bounded count |
| 16 | 32 | logicalContractSetDigest | full SHA-256 of approved logical module operation/type contract set (exact canonical aggregation format **P0**) |
| 48 | 32 | targetLayoutDigest | full SHA-256 of approved target ABI/layout contract set (exact canonical aggregation format **P0**) |

The operation table follows the 80-byte module header in verified immutable **module descriptor data**. This is an intended layout, not permission to trust a pointer found in unverified image bytes. operationCount * 80 is overflow-checked, table within validated read-only signed/hashed image region. An independent trusted loader supplies the external **complete PE artifact hash**, publisher identity, approval receipt and target. The module header cannot embed an ordinary SHA of its own whole image without an explicit nonrecursive hash-exclusion contract; **none is assumed**.

**AuiOperationEntryV1**, 80 bytes, one per entry:

| Offset | Size | Name | Requirement |
| --- | --- | --- | --- |
| 0 | 32 | operationIdDigest | SHA-256 of exact approved domain-separated fully qualified logical OperationID bytes (algorithm details must be accepted) |
| 32 | 32 | operationContractDigest | full approved logical operation contract digest (normalization/aggregation **P0**) |
| 64 | 4 | entryRva | RVA of a validated executable PE section entrypoint, not a physical address or graph ID |
| 68 | 4 | flags | approved operation capabilities and call-kind bits; 0 first draft |
| 72 | 8 | reserved | zero |

Unknown, duplicate or ambiguous OperationIDs and missing verified contract digests reject. Runtime checks module function table bounds, valid executable section/RVA and CFG/security-policy requirements before resolving entryRva to an actual function pointer. No user-provided pointer is accepted.

**AuiValueRefV1**, 64 bytes, describes ONE owned/immutable value carried across an approved boundary:

| Offset | Size | Name |
| --- | --- | --- |
| 0 | 32 | logicalTypeContractDigest | exact full 32-byte resolved logical value TypeID contract |
| 32 | 8 | ownerHandle | opaque allocation owner table handle |
| 40 | 8 | ownerGeneration | validated generation |
| 48 | 8 | byteOffset | within approved owner |
| 56 | 8 | byteLength | checked against owner capacity |

AuiValueRefV1 does not define arbitrary native field layout, generic substitution, String/List element strides, borrow or address-space promotion. Those are separate **approved** logical TypeID and target LayoutIR obligations. Owner lifetime must survive async suspension and terminal delivery; call-scoped borrows may not populate this structure for a retained asynchronous result.

**AuiTaggedOutcomeV1**, 80 bytes, alignment 8:

| Offset | Size | Name |
| --- | --- | --- |
| 0 | 4 | envelopeSize | 80 |
| 4 | 4 | discriminant | exact case tag |
| 8 | 64 | payload | AuiValueRefV1 |
| 72 | 8 | reserved | zero |

Two distinct **contextual meanings** are permitted for the same envelope layout, never automatic type casts:
- Provider Result<T,E> selects tags 0=Success(T), 1=Failure(E).
- UI TaskOutcome<T,E> selects tags 0=Successful(T), 1=Failed(E), 2=AdmissionRejected(AdmissionError), 3=Cancelled(CancellationConfirmation), 4=ProviderUnavailable(ProviderError).
- The **expected envelope kind** is selected from an exact approved type contract/OperationID and validated before interpreting any tag. Tag 1 does not mean the same payload type across unrelated generic instances without checking the matching logical type contract digest.
- AdmissionRejected/ProviderUnavailable may exist before a provider ticket. They are **not** provider Result and must never be written as an accepted provider terminal outcome. Cancellation requires confirmed quiescence.

This compact envelope is a proposal for a *native transport of externally owned typed bytes*, not a by-value C union of all possible generic payloads. Payload alignment/stride/retain-drop and target ABI layout identity for its contents are **still P0**.

## M3. Transport status and failure before native entry

Candidate EAX U32 transport status codes:
- 0 = ABI_TRANSPORT_RESULT_READY: a checked synchronous output envelope is available; this is **not equivalent to provider success**.
- 1 = ABI_TRANSPORT_PENDING: accepted async operation owns an admitted TaskTicket and result reservation.
- 2 = ABI_TRANSPORT_ADMISSION_REJECTED: no provider operation was started; caller retains input ownership.
- 3 = ABI_TRANSPORT_BAD_DESCRIPTOR: a frame/owner/target/ABI check failed; native invocation may not occur.
- 4 = ABI_TRANSPORT_PERMISSION_DENIED: missing or revoked live scoped capability; no provider effect started.
- 5 = ABI_TRANSPORT_RESOURCE_EXHAUSTED: bounded reservation failed before ownership transfer.
- Other codes are forbidden in the first proposed profile.

A function that accepted an operation must NOT use transport code 2 to recharacterize a provider-level Failure(E). Typed provider outcomes are carried through verified AuiTaggedOutcomeV1, not encoded solely in EAX. Invalid pointers must be rejected by *host preflight* before native invocation; if a caller is itself untrusted/corrupted and a pointer faults, the host may need to isolate/terminate the module, never claim safe recovery by returning status 3.

## M4. Cross-owner safety and future target tests

Verify exact Windows calling convention, nonvolatile registers/XMM, .pdata/.xdata, no foreign exception unwind, module and operation table immutability while loaded, RVA bounds and native CFG policy. ABI status/Result separation, owner handles, aliased output, stale generation, cancellation/terminal race and teardown must pass actual native Win64 tests. Source, registry and target-digest aggregation algorithms need an accepted nonrecursive canonical rule before any published module header can be called trusted.

[Supplemental layout fixtures](../../examples/abi/win64-module-and-outcome-v1.json) provide offset arithmetic and negative case design only. [Cross-gate review](d2-d6-win64-baseline-review.md) retains B-04/B-06 OPEN for trust and executable evidence.

**No implementation, COFF artifact, linker output, signed binary or live Win64 call is produced by this proposal.**
