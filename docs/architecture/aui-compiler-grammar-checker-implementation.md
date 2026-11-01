# AELYXORA — Reproducible T0 Grammar Checker Implementation Contract

**Status: PROPOSED DESIGN / NOT APPROVED / NOT IMPLEMENTED / NO NATIVE RUN.** This specifies one deterministic **verification utility** for the existing [formal EBNF AST](../../schemas/aui-compiler-ebnf-ast-candidate.json), not a second parser, second language, or replacement for the native AUI compiler. It obeys the [accepted implementation language policy](language-policy.md): Assembly-first, no Python or unapproved bootstrap languages, no CI.

## GC0. Inputs, outputs, ownership

Input A: immutable captured bytes of `schemas/aui-compiler-ebnf-ast-candidate.json`; Input B: immutable, explicitly versioned token classification catalogue; Input C: T0 production-to-CST/AST/T1 registry; Input D: explicit selected component/contract mode and L0–L4 profile policy. All bytes and schema revisions must be recorded. No unknown fields may silently alter interpretation. Deterministic analysis output is structured report data (JSON is an untrusted display/report format), with original file digest and sorted diagnostics. A report cannot mint D2/C9 public trust or a successful T0/T1 compiler receipt.

Planned local CLI (not implemented): `aui-grammar-check --grammar <path> --registry <path> --tokens <path> --report <path>`. Explicit named inputs only; reject duplicate switches, missing values, extra arguments, unapproved paths, oversized files, malformed UTF-8/JSON, unsupported version and inconsistent grammar identity. Atomic output publication and stable diagnostics follow D6/local-build owners.

## GC1. Exact structural verifier

- Parse bounded JSON under an approved native input parser contract (a syntactic delimiter-only preflight is insufficient).
- Require unique production IDs/names, known operators and exactly one valid operator-specific node shape.
- `sequence` and `choice` require nonempty ordered `items`; `optional` and `repeat` require exactly one `item`; `literal` requires an exact nonempty string; `symbol` requires a nonempty bound name.
- Require exactly the known external symbols `EOF`, `ID`, `INT`, `STR` unless the lexer authority explicitly changes; closed symbol resolution, no unresolved names.
- Reject duplicate object keys and integer overflow; no implicit default op, aliases, or silently ignored required metadata.
- Verify root `sourceUnit`, component/contract reachability and a valid EOF end for both module modes. Check unreachable productions and invalid nullable repeats.

## GC2. Fixed-point semantics

Let `nullable(literal)=false`, `nullable(external)=false`, `nullable(optional/repeat)=true`; `nullable(sequence)=all(nullable(children))`, `nullable(choice)=any(nullable(children))`. `FIRST(sequence)` unions consecutive children until first nonnullable; `FIRST(choice)` unions alternatives; `FIRST(optional/repeat)=FIRST(child)`. Propagate production definitions to monotone fixed point using finite bitsets indexed by reviewed token classes.

`FOLLOW(sourceUnit)` includes end marker; propagate from right to left in sequence, with enclosing FOLLOW passed into nullable suffixes and repetition FOLLOW union child FIRST. For each `choice`, compute predict branch = FIRST(branch) union FOLLOW(choice) if nullable. For `optional/repeat`, compare FIRST(enter) with FOLLOW(node) as the exit set. Reject nullable repeated body even if a worklist algorithm terminates. All worklist iterations are resource-bounded; reaching a cap without convergence returns `GC_NONCONVERGENT`, never a fabricated success.

Left-recursion detection follows left-corner production edges, traversing nullable prefixes. Cycles produce `GC_LEFT_RECURSION`; graph cycles not in left-corner position are allowed under normal grammar recursion constraints.

## GC3. Terminal normalization: critical trust boundary

The current review computations operate on **literal strings**; that is not an executable lexer token table. Convert each literal to exactly one of: a fixed token kind, a context-checked Identifier spelling, or an explicit unsupported terminal. `Result/Event/List/TaskSlot` must remain type identities resolved in type context; `view/item/value/activated` and the five TaskOutcome names have precise contextual use. Reject unsupported arithmetic/operator candidates. Each rule records language-profile availability and source provenance. If two literals collapse to one lexer kind, predict sets **must be recomputed after normalization**, and explicit contextual predicates must be checked before declaring a conflict resolved.

## GC4. Bounded parser decision evidence

For `sourceUnit`, moduleKind from immutable compilation input is the discriminator, not first-token guessing. For `componentMember`, the sequence `on settled` has a designated guarded branch; malformed settled source must not backtrack into ordinary `on ID` behavior. For `pureExpr`, consume a bounded qualified-name prefix and inspect the following `(` to distinguish a syntactic call from member access, while type meaning remains T1-owned. Record lookahead consumption and evidence, and reject all additional unreviewed conflicts. A token-level ambiguity is not necessarily an ambiguous language; where a decision needs more than one token, document and prove its bounded strategy.

## GC5. Completion gates and acceptance corpus

The existing structural AST, flat production registry and T0 kind registry must be joined on exact identifiers, with every production alternative assigned profile+module mode, CST kind, AST kind or CST_ONLY, T1 consumer or T0_ONLY, and stable diagnostics. Unknown/unmapped/semantic-review states block **approval**, not mere report generation. Cases include duplicate names/IDs, unknown operators, missing external symbols, unbound symbol, epsilon repetition, left recursion (direct/indirect), FIRST/FIRST, nullable FOLLOW overlap, contextual-token collapse, wrong module mode, wrong language profile and source-origin mismatch.

Every test must declare input delta, expected diagnostic category and whether a full success is allowed. These are **NOT-RUN** until the checker executable is available and replayed independently.

## GC6. Assembly implementation modules (future, not code in this change)

`host_win64` (bounded path/byte I/O); `json_strict` (complete JSON parser and duplicate-key rules); `grammar_decode` (validated nested nodes); `terminal_map` (lexer policy); `nullable_first_follow` (finite bitset/worklist); `left_corner` (recursion graph); `predict_check` (all nested alternatives); `coverage_check` (CST/AST/T1/profile diagnostics); `report_writer` (deterministic bounded reporting). Modules use IAI-v1 checked arena references internally; host OS calls never execute from user-authored grammar instructions.

**Release no-go:** no native executable or independent verifier exists yet; current reported FIRST/FOLLOW and Predict Sets are review-environment calculations, not approved tool evidence. Human D1–D8 gates remain open.
