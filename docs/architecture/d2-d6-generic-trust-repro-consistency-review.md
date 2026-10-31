# D2–D6 — Generic Types, Win64 Trust and Reproducible Build Consistency Pass

**Status: design-only reconciliation, PROPOSED/OPEN, no architect acceptance, native build, signature verification, Windows runtime test, or ABI conformance.** Scope: [G1 specialization](d2-d3-generic-instantiation-identity.md), [v1/v2 compatibility](d2-d6-core-profile-compatibility.md), [Win64 trust/admission](d4-win64-module-trust-and-admission.md), [deterministic build](d6-win64-reproducible-build-contract.md), plus existing [Win64 ABI](d4-win64-native-component-abi.md), [module descriptors](d4-win64-module-and-result-descriptors.md), [D6 resolver](d6-offline-dependency-resolution.md) and [D3 source snapshot](d3-source-snapshot-reconciliation.md).

## R1. Cross-owner decisions and ambiguity resolution (still proposed)

| ID | Severity | Previously unresolved contradiction/gap | Proposed design resolution |
| --- | --- | --- | --- |
| XG-01 | P0 | Generic template public digest could be mistaken for instantiated List/Result/TaskOutcome | Exact typed G1 instance projection + **independent domain** + ordered argument TypeIDs and full digests; never alias template digest |
| XG-02 | P0 | L4 source List<Row> uses a user record but existing G1 core argument policy lacks approved mixed type profile | Bounded G1 permits only non-generic approved core args; user-record/nested types stay **explicitly unsupported**, no false executable example |
| XG-03 | P0 | Existing v1 user/component exports vs v2-core type fingerprints | Distinct v1 legacy and v2-core profiles; **no** ambient migration, mixed profile blocked before new immutable approved snapshot |
| XG-04 | P0 | Type name or equal machine size might be used as compatibility | Full nominal owner, digest, source profile, instantiation and native ABI proof required; no pointer cast or name alias |
| XG-05 | P0 | Valid PE Authenticode signature could be treated as source/Graph authorization | OS signature, pinned publisher and **independent signed architect approval** required, followed by live scoped capability checks |
| XG-06 | P0 | SHA-256 of file content is not proof of publisher authenticity | Separate complete raw artifact byte SHA and Authenticode verification; each is necessary, neither sufficient alone |
| XG-07 | P0 | Verified file replaced before LoadLibrary / malicious dependent DLL | Immutable verified bytes, controlled loader/search/approved imports, TOCTOU and PE bounds proof, abort if unprovable |
| XG-08 | P0 | Unsigned vs signed PE hashes differ; reproducibility could be tested on wrong stage | Compare **unsigned** deterministic PE/PDB across independent clean builds, then separately sign/verify raw signed-file SHA |
| XG-09 | P0 | Build inputs from ambient environment/tool versions without content identity | Exact executable SHA, source lock, flags, target features, virtual root and env whitelist; unknown inputs reject |
| XG-10 | P0 | Embedded whole-file artifact hash could create self-referential signed hash cycle | Nonrecursive DAG: source/recipe → unsigned artifact → signature/signed artifact → detached approval → new D6 snapshot |
| XG-11 | P0 | Trust accepted once at DLL load used to justify future arbitrary effects | Runtime checks exact operation/graph generation, capability lease, domain, allocator bounds and task ownership each invocation |
| XG-12 | P1 | Duplicate heading R7 in D3 source/snapshot reconciliation | Renumber second R7 as R8, preserving the underlying design text and no semantic authorization changes |

These are **documentation-level** resolutions; all trust/ABI/native correctness gates remain open.

## R2. Portable/metadata evidence

- [G1 JSON schema](../../schemas/aui-generic-instantiation.schema.json) plus [5 positive digest cases and 9 negative expectations](../../examples/aui-language/d2-generic-instantiation-vectors.json): deterministic small reference algorithm, NOT an AELYXORA compiler. The positive vectors distinguish argument ordering, template vs instance and Result vs TaskOutcome.
- [Build inputs schema](../../schemas/aui-win64-build-inputs.schema.json) plus [16 failure cases](../../examples/abi/win64-build-negative-cases.json): design-only toolchain/provenance scenarios, no executed Win64 build.
- [Win64 module and outcome ABI fixture](../../examples/abi/win64-module-and-outcome-v1.json) remains structural arithmetic, not a signed PE or native module load.
- Authenticode external behavior is grounded in Microsoft's [WinVerifyTrust documentation](https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-winverifytrust); deterministic PE semantics in [PE/COFF addendum](https://github.com/dotnet/runtime/blob/main/docs/design/specs/PE-COFF.md). These external descriptions are NOT evidence about AELYXORA executables.
- Existing public v1 export vectors, pure reference Graph digest and D6 immutable snapshot remain deliberately unchanged.

## R3. Gates requiring explicit human decision (all OPEN)

**D2/D3:** approved full core/user generic type reference schema, nominal ownership, v2 user records, arbitrary nested generic and recursion variance, signed source-to-Graph approval, versioned project migration and preservation of prior immutable snapshots.

**D4:** actual module loader/security architecture and publisher allowlist, WinVerifyTrust/revocation/offline rules, signed review receipt verification, exact full-artifact hash/loader TOCTOU safety, native Win64 abi call frames and generic tagged union/allocator, PE/COFF unwind/CFG/ASLR.

**D5:** real Windows process/UI host, task cancellation and buffer ownership, per-root/process memory admission, UIA/IME/DPI and actual renderer/focus input behavior.

**D6:** exact build-input manifest and trust model with tool binary digests, deterministic PE/PDB evidence, byte-identical clean-room rebuilds, signature and approval DAG, qualified Windows/NTFS atomic persistence and failure injection.

**D8:** one explicit review record per blocked area referencing exact accepted source commit. No new gate is marked Accepted by this file.

## R4. Recommended next bounded design closure

1. Finish exact **versioned typed TypeReference** schema for full user records, generic references and import/graph resolution; then close source-to-Graph immutable snapshot evidence.
2. Define the nonrecursive signed review receipt schema, publisher/key rotation/revocation and verified module operation-table contract-set digest.
3. Pin one actual toolchain/Win64 feature/OS version and supported target filesystem; define executable future goldens and test harness for Phase III.
4. One complete end-to-end architecture trace: AUI source → typed generic instance → graph command → native Win64 ABI admission → TaskOutcome → UI StateRevision, with separate error paths at every stage, before seeking D1–D8 architect acceptance.

**No application code, CI, branch or PR was created by this documentation pass.**
