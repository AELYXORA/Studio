# AELYXORA — T0 Disambiguation and Unified Grammar Closure Review

**PROPOSED / NOT ACCEPTED / NOT IMPLEMENTED.** Companion to [single AUI syntax owner](aui-syntax.md), [T0 production registry](../../schemas/aui-compiler-t0-production-registry-candidate.json) and [grammar coverage audit](aui-compiler-grammar-coverage-audit.md).

## Evidence inventory

The machine-readable candidate now inventories **57 distinct productions / 77 top-level alternatives** across component and contract source units. Shared productions (including typeRef) are referenced, not duplicated in a separate grammar. Of the alternatives, 66 have proposed structural mappings and 11 retain explicit semantic review states. These numbers describe documents, **not parser coverage, accepted semantics or native tests**.

## Deterministic candidate disambiguation

| Construct | Syntax choice | Required later semantic gate |
| --- | --- | --- |
| sourceUnit | Compiling module kind is mandatory immutable context: component vs contract; no autodetect | File contents must match selected mode |
| settledHandler | Reserved sequence `on settled` takes priority over general `on ID`; five fixed arms | Exact five distinct outcome cases in required order; TaskOutcome type and slot ownership |
| modifier | Parse `.` modifierName, never arbitrary method dispatch | Only admitted modifier names and exact named signatures; static key and event attachment restrictions |
| pureCall | Syntactically parse qualified name followed by named arguments | T1 differentiates pure function and payload enum constructor using resolved public types; unknown/unverified callable rejects |
| pureAtom | Literal and memberPath parse independently of capitalization | T1 distinguishes member read from zero-payload enum constructor under exact type resolution |
| typeRef | Generic brackets are admitted only in type context, comma separates ordered arguments | T1 validates approved template identity, arity, nesting, ownership; no shift operator inference |

**Not frozen:** These choices are drawn from the existing integrated syntax owner, not approved by human review. Parser lookahead tables, profile masks, stable diagnostics, error recovery synchronization, and all native tests remain outstanding.

## Contract source integration

The same language admits an explicitly selected `contract` module consisting of imports and one or more record, enum or service-interface declarations. New catalog entries are `contractModule`, `contractDecl`, `recordDecl`, `recordField`, `enumDecl`, `enumCase`, `serviceInterface`, `serviceCommand`. Imports, typeRef, commandParams, effects and domains reuse existing productions and semantics. An AUI service declaration is **not** an executable provider. Verified D2/D6 public exports and target authorization remain mandatory. Wrong module kind or missing source/Graph evidence must fail closed.

## Audit findings requiring correction before compiler freeze

1. Earlier registry assigned separate token names for speculative operators and unowned keywords. Their numeric codes must remain rejected until each has an authorized grammar occurrence; missing tokens such as outcome-arm spellings require an explicit contextual identifier rule.
2. The new registry is not yet an actual fully parsed EBNF AST. Its top-level `|` split does not enumerate nested optional/repetition/choice paths. Therefore **77 is not an exhaustive grammar-path count**, and optional branches must be separately covered by fixtures.
3. Source grammar entries currently store `profile=REQUIRES_CONTEXTUAL_PROFILE_GATE` or contract review, not exact L0–L4 masks. A machine-checked profile admission table is still required.
4. The current CST/AST `kind` labels are candidate names, not a validated join against the numeric kind registry. Some synthetic wrapper labels require exact reconciliation.
5. The catalog still lacks specific diagnostic IDs, approved authoritative grammar revision digest, golden fixtures and an executable consistency checker. It is incorrect to mark full T0 closure.
6. T1 consumers are proposed logical identifiers, not compiled handlers. No T0-to-T1 end-to-end output is proven.

## Next acceptance conditions

- Extract grammar into a versioned machine-readable EBNF AST with all nested alternatives and explicit source owner identity.
- Validate all token/CST/AST numeric codes and contextual spellings against syntax, with no unmapped non-reserved code.
- Require one true mapping per grammar branch and explicit profile/module-kind positive and negative fixture.
- Verify exhaustive AST → TypedHIR dispatch and semantic/type checks on native test runs, preserving original UTF-8 source spans.
- Obtain D1–D8 approvals, with independently authenticated public types/Graph linkage before T2 or native emission.

**Status remains PROPOSED.** This document makes the remaining ambiguities auditable; it does not declare them accepted or solved in executable code.
