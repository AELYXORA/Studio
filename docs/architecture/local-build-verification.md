# AUI Local Build System and Verification Architecture

**Status: proposed design; no executable build system or AUI compiler exists.** This document defines the local build coordinator. [Package Resolution](package-resolution-build.md) owns package integrity; [Compiler](aui-compiler.md) owns language and codegen; [Verification Plan](verification-plan.md) owns test gates. No CI.

## Build invocation and trust boundary

A local user-initiated build captures an immutable project revision and authorized target profile. `resolve`, `validate`, `build`, `test` and `report` are conceptually separate actions. Parsing manifests, previewing a dependency plan, or AI suggesting a command never authorizes execution. Network downloads, native tests, debugger attachment and physical device flashing need separate explicit permission.

## Build DAG

```text
project snapshot + lock + target profile
   -> structural/semantic validation
   -> verify packages and toolchain
   -> parse AUI -> TypedHIR -> OwnershipIR
   -> TargetMIR -> per-target assembly/object
   -> link native artifact -> optional local tests
   -> evidence report
```

Nodes have stable logical IDs, typed input/output artifacts, declared dependencies, capabilities and target. A node executes only once predecessors succeeded and immutable input hashes match. Circular build dependencies are errors; runtime task/event loops do not imply build cycles.

## Execution rules

The coordinator launches verified local tools with explicit executable path, hashed tool identity when available, argument vector (never implicit shell interpolation), working directory, environment allowlist, timeout, output directory and resource limits. Untrusted generated code executes only under appropriate OS isolation, not inside the editor process. All intermediates go to staging, and an atomic publication protocol replaces build outputs only after successful verification.

An `ASM source -> object` task is distinct from an `AUI source -> object` task. ABI, ISA feature set, sysroot, SDK and linker flags are part of each node's target identity. No compiler pass may silently assume system services outside the selected target profile.

## Cache and incremental invalidation

Cache key covers normalized relevant source content, canonical dependency hashes, compiler/assembler/linker executable identity, flags, target triple, ABI, sysroot, runtime contracts and code generation configuration. Presentation-only map movement does not invalidate semantic code output. Any unknown, non-hermetic or untracked dependency disables cache reuse for affected nodes. Cached outputs require integrity verification; an old pass result is not evidence for a new artifact.

## Failure, cancellation and recovery

Cancellation is cooperative at coordinator boundaries and forcibly bounded for child processes where supported. Kill descendants, release process handles, and discard uncommitted staging outputs; preserve previous known-good artifacts. Crash recovery scans staging transaction state, validates digests and either finalizes a fully complete publication or rolls back. Tests with external device effects are never silently retried.

## Local verification model

Every fixture has fixture ID, scope, target, expected result, command provenance, observed result (`pass` / `fail` / `not-run`), artifact hashes, measured duration and captured diagnostics. **Designed fixture ≠ executed test.** Compilation success cannot prove runtime safety, ABI conformance, accessibility or performance.

Test layers: manifest/schema checks; package and lock integrity; parser and type diagnostics; ownership/lifetime rejection; ABI call fixtures; native link/smoke; window/input/text/layout; event/async/device behavior; security/capability gates; cross-target reproducibility and performance against equivalent native baselines. Tests may be skipped only with an explicit reason and `not-run` status.

## Evidence envelope

```text
BuildEvidence {
  sessionId, projectRevision, semanticGraphDigest,
  target, toolchainDigests, environmentFingerprint,
  taskDAG, taskOutcomes, diagnostics,
  outputs: [{path, digest, publishStatus}],
  tests: [{fixtureId, expected, observed, duration, artifactDigest}],
  overallStatus, limitations
}
```

A report is append-only per build session; it references immutable input/output content identities. Machine details and logs must redact user secrets and absolute personal paths when exported. Evidence may be compared between sessions but is never silently promoted to a passing status.

## Acceptance scenarios

1. Same frozen inputs produce equivalent build task keys; changed compiler flags invalidate target tasks.
2. Modifying one independent module rebuilds only affected downstream nodes.
3. Moving a map node without semantic change does not rebuild binary artifacts.
4. Missing package digest or unsupported ABI stops before compile.
5. No native test executable runs without explicit authorization.
6. A cancelled linker preserves the previously published known-good artifact.
7. A stale or corrupt cache artifact is rejected and rebuilt.
8. Local tests record pass/fail/not-run accurately; absent execution remains not-run.
9. A report identifies exact source, target, tools and artifact for every observed result.
10. No GitHub Actions or automated CI is introduced.

## Open decisions

Coordinator implementation language, hermetic sandbox per OS, build DAG serialization, lockfile hash test vectors, process isolation, platform linker selection, evidence schema and cache eviction budgets. Resolve with local implementation experiments before accepting the build system.
