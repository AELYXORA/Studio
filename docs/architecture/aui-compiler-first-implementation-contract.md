# AELYXORA — AUI Compiler: First Implementable Architecture Contract

**Status: PROPOSED / Phase I documentation, architect acceptance OPEN.** This is an **implementation blueprint for one bounded first compiler**, not a second language, Project Graph, runtime ABI, graph edition or authorization to write production code today. It specializes the existing [D3 L0/L1 grammar](d3-first-language-profile.md), [D3 typing](d3-type-and-binding-profile.md), [AST/TypedHIR](aui-ast-semantic-analysis.md), [compiler overview](aui-compiler.md), [Graph C9–C12](canonical-project-graph-and-components.md), [source/graph review](d3-source-snapshot-reconciliation.md), [IR/Ownership](aui-ir-layout.md) and [native target design](aui-targetmir-native-codegen.md). Where this blueprint reveals a contradiction, amend the appropriate owner; do **not** invent parallel rules.

## F0. One bounded decision and definition of "compiler"

**Proposed implementation choices for explicit architect review:**

- **Compiler implementation language:** native target-specific **Assembly**, with narrow OS ABI calls and approved Clang/LLVM assembler/linker tooling. No Python, C++, Qt, generated Node.js workflow, dynamic plugin interpreter or embedded third-party scripting runtime in the product. GNU Intel-syntax ASM/Clang may be used for the existing Linux x86-64 research scanner, but its syscall ABI is **not** the Windows host ABI.
- **First intended Studio host and first native code-generation target:** Windows x64 user mode, `x86_64-pc-windows-msvc` / COFF/PE32+. Host/target must always be explicit. Toolchain executable path, version/hash, Windows SDK/runtime loader, native calling convention, signing policy and renderer adapter need a separate **D4/D5 acceptance** before an executable can be claimed.
- **Source language:** existing strict D3 **L0/L1**, not the historical broad `aui-syntax.md` grammar. One component per module; L0 pure static Views; L1 local typed Event/command request. L2 State/Bind, L3 Task/Result, L4 dynamic keyed lists, general arithmetic, FFI and hardware statements **reject** in first slice.
- **Build order:** (A) offline source verification → (B) deterministic TypedHIR and static UI-plan emission → (C) *verified-graph* linkage → (D) native module emission/link after ABI and runtime contract approval. A and B are real compiler functionality even before a window exists. C/D **must never be implied by success of A/B**.
- **No architecture-free native shortcut:** do not emit a valid executable from a missing/placeholder type registry, synthetic graph digest or unreviewed command provider. A source-only inspector may report a *provisional typed plan*, but cannot call it verified graph-linked code.

**Companion detailed COMP-01..05 handoff:** [Compiler Front-End Closure](aui-compiler-frontend-closure.md) records the proposed Unicode 15.1.0 table inputs, bounded Assembly module ownership, source-only catalogue validation, UI/event static rules, and deterministic TypedHIR/diagnostic behavior. All decisions remain PROPOSED until human approval. 

**Source-only command result contract:** `check --source-only` performs P00–P06 and returns exit code 0 for a completely valid local source-only analysis; it does **not** publish TypedHIR or a plan file by default. Its in-memory TypedHIR is discarded on orderly completion. `emit-plan --source-only` performs the **same** checks, then serializes a successful `UNVERIFIED_SOURCE_ONLY` plan only after all passes succeed, to explicitly requested staged output; it cannot silently switch to link/build. On failure both commands produce the **separate** diagnostic report shape, nonzero status, and no successful plan. The exact report transport (stderr UTF-8 vs an explicit diagnostic output option) is still a COMP-04 review item; never mix diagnostics into a successful plan.

**Reproducibility fix:** both successful plan and captured-source failure report bind the exact **SHA-256 of the provisional catalogue bytes** in `catalog.sha256` in addition to a human-readable catalogue path. `catalog.sourceIdentity` is diagnostic provenance **only**; equal paths with different catalogue contents are different compiler inputs. This hash does not turn the catalogue into a trusted core export. The current reference [catalogue bytes](../../examples/aui-compiler-first-slice/review-type-catalog.json) have SHA-256 `8446fb67384923b0ff4baf6c90509b34a3fd711a1880526034300f66153b22b0`, calculated from its exact UTF-8 contents and cross-checked by independently validating the known StatusPanel SHA-256 with the same algorithm. The canonical output writer still needs byte-level goldens and host/toolchain pinning.

**Initial deliverable name (CLI design, not current executable):** `aelyxora-auic`. Source grammar and user language remain AUI. `check` means diagnostics, `emit-plan` means inspectable representation, `link` means verified source-to-Graph closure, and `build` means target-native output. Each phase is explicit; no command accepts and silently upgrades a weaker evidence state.

## F1. Input modes, trusted boundaries and artifacts

| Mode | Required inputs | Output contract | Forbidden claim |
| --- | --- | --- | --- |
| `check --source-only` | Immutable exact AUI bytes, explicit L0/L1 profile, **pinned review-only type catalogue** for name/type checks | Diagnostics + complete source-spanned AST/TypedHIR candidate, marked `UNVERIFIED_SOURCE_ONLY` | No trusted core digest, component provider, native ABI, rendered UI or approval |
| `emit-plan --source-only` | Successful source-only check | Deterministic **review-only** normalized static-View/command-intent description; every unresolved external TypeReference explicitly flagged | No runnable graph, simulated capability, native code or resource grant |
| `link --snapshot` | Exact immutable D6 source/package lock + single canonical Graph; **verified** current core/record/operation/component exports; target + source link; required review scope | Verified typed SourceLink/Graph origins or fail-closed diagnostics; output is still non-executable | No issuance of signer approval or automatic execution permission |
| `build --target` | Verified linked closure, approved target ABI/runtime interfaces and signed review/executable admission policy | Generated target-specific Assembly and native object/artifact, full provenance report; execution separate | No OS access or runtime safety from hash equality alone |

Only a trusted OS file handle to a root-confined immutable input snapshot may be compiled for a linked build. A direct editor buffer or arbitrary loose source file may be inspected with `--source-only` but not promoted into a linked build. Missing/invalid dependency lock, untrusted signer, unsupported privilege or absent native adapter rejects as appropriate. A package target status of `planned` is not proof of native support.

The first 15-type [core candidate](../../examples/canonical-graph/core-registry-candidate.json) has every export marked `UNVERIFIED`. A source-only checker may use a **literal, explicitly selected and labeled provisional review catalogue**, validated against the [source-only catalogue schema](../../schemas/aui-compiler-review-type-catalog.schema.json), to type-check builtins for design, but a linked/native build MUST reject it until an accepted content-bound core registry exists. No invented `contractDigest` and no borrowing historical v1/v2 SHA goldens.

## F2. Deterministic pass graph and exact stop points

| Pass | Input → output | Required check | Failure boundary |
| --- | --- | --- | --- |
| P00 Capture | Exact UTF-8 bytes → SourceUnit(id, SHA-256, bytes) | root/path/size/ownership, raw byte identity, maximum length; never normalize before computing source SHA | IO/path/size error; zero compiler artifacts |
| P01 Decode/Lex | SourceUnit → lossless token stream + source trivia | strict UTF-8, no BOM, Unicode XID+NFC, lexical JSON-style string escapes, integer grammar, reserved future constructs | invalid bytes/escape/unsupported feature; no AST |
| P02 Parse | tokens → lossless CST + structural L0/L1 AST | exact [D3 L0/L1 EBNF](d3-first-language-profile.md), one component/one final view, complete EOF, child/modifier precedence, semicolons | `AUI_SYNTAX`/`AUI_PROFILE_UNSUPPORTED`; recovery is diagnostics-only |
| P03 Imports/Symbols | AST + explicit offline registry view → resolved lexical symbols | unique imports, scoped names, core builtin ownership, NFC collision, no implicit package download, L0/L1 profile gate | `AUI_UNRESOLVED_IMPORT`/duplicate or unknown symbol |
| P04 Type/Properties | resolved AST → typed view/command declarations | full nominal references, ordered command inputs, named-only args, exact builtin signatures and pure member-path reads; no coercion | `AUI_TYPE_MISMATCH`, `AUI_ARG_*`, `AUI_NUMBER_RANGE` |
| P05 Effects/Events | typed declarations → TypedHIR intent graph | one handler/event, `Button.activated: Event<Unit>`, one typed send, declared effect/domain, no native effect on UI/render thread | `AUI_EVENT_*`, `AUI_COMMAND_CONTRACT`, inaccessible controls |
| P06 HIR Closure | P05 → immutable TypedHIR candidate + deterministic plan | no unresolved symbols, bounded size/depth, exact source origins, explicit `UNVERIFIED_SOURCE_ONLY` if any imports are provisional | no emission of successful TypedHIR after any earlier error |
| P07 Graph Link | TypedHIR + exact verified graph/export/lock/snapshot → linked TypedHIR | stable GraphNodeID/OperationID, source SHA/StableSymbolID, exact operation input/output/effects/domain/target triples, live capability requirements | `AUI_COMMAND_LINK_MISSING`, export/type/hash/approval errors |
| P08 Ownership/Lower | linked TypedHIR + target qualification → OwnershipIR → TargetMIR | owned values, no async borrow escape, exact D4 native layouts, static view semantics, target/ABI constraints | target/ownership/unsupported diagnostics; no object output |
| P09 Native Emit | target MIR → target-specific Assembly + object/link plan | deterministic safe symbol mangling, no renderer ABI guesses, relocations, PE/COFF/unwind/stack rules | no publication of partial runnable artifact |
| P10 Package/Report | complete verified result → staged immutable report/artifacts | source/lock/graph/build/ABI/tool digests, diagnostics and observed tests separated; atomic publication through D6 adapter | previous accepted output remains intact |

**Implementation staging:** first implement only P00–P06. This avoids unqualified D4/D5 runtime and signed-approval assumptions while producing a genuinely testable Assembly-based front end. Design P07–P10 now, but do not implement under unaccepted contracts. A future architect can accept each bounded slice without claiming the overall Studio is complete; the [Phase I→II policy](design-completion-gates.md) still controls permission to implement.

## F3. Lexer/parser contract that cannot be improvised by the implementer

- One source file contains **exactly one** component and zero or more explicit imports before it. Component body order: zero or more event/command/handler declarations, then exactly one view expression, then closing brace and EOF. Multiple views or declarations following the final view reject.
- Source unit and every token/CST node record `[startByte,endByte)` offsets into the **original** UTF-8 bytes, including comments/trivia. Original spelling and normalized NFC lookup identity are separate fields. Do not derive persistent graph IDs from token indices or line numbers.
- Whitespace and `//` line comments are trivia. Unterminated strings, invalid controls, Unicode bad scalar/surrogate, unknown escapes, embedded BOM, unsupported block comments and lexical count/depth overflows reject.
- Keyword recognition is case-sensitive. Future keywords (`state`, `derived`, `bind`, `task`, `await`, `service`) and recognizable attempted future constructions (e.g. `let ... await`, `ForEach`, `import x @version`) must yield `AUI_PROFILE_UNSUPPORTED` rather than generic unknown-symbol success. This does not grant permission to implement L2–L4 semantics.
- All call arguments use `name: value`; duplicate names reject. Accepted literal forms are double-quoted strings, Bool literals and nonnegative decimal integer literals in exact typed positions. No decimal/exponent/floating syntax or `F64` literals in L0/L1.
- `VStack/HStack(spacing: U32)` require one or more child views; `Text(value: String)` and `Button(title: String)` forbid children. Modifiers attach left-to-right after the completed child/constructor call. `.accessibilityLabel(value: String)` is pure; only Button may use `.on(activated: localEventID)`.
- `Event<Unit>` is allowed only as an event declaration/attachment, `Result<T,E>` only as command return signature. Every local event must have exactly one handler in L1; a handler has exactly one typed `send` statement. A declared command is only an intent until P07 establishes a provider.
- For strings, logical `String` equality compares exact Unicode scalar values, not source identifier NFC equivalence. For source identifiers, normalize using one **pinned Unicode version** and reject same-scope NFC collisions. The selected [Unicode 15.1.0 source candidate and XID/NFC table policy](aui-compiler-frontend-closure.md) is a pinned offline compiler input identity, not host-locale dependent. Human approval and exact source-file digests remain open.
- **Limits are first-implementation proposed budgets (not measured):** source 1 MiB; token count <= 131072; UTF-8 decoded identifier <= 256 bytes; string literal decoded bytes <= 1 MiB; imports <= 64; declarations <= 512; static view nodes <= 4096; AST/CST nesting <= 64; diagnostics <= 100 per source. Overflow-safe arithmetic and early failure are required; no invisible truncation. The exact values must be architect-approved and checked against D5 memory budget before implementation.
- Parsing with recovery may emit at most diagnostic CST for editors. TypedHIR, normalized plan and generated code are **never published** from a source containing any compilation error. Deterministic ordering is by pass, source start byte, diagnostic priority and code; diagnostics must not depend on pointer values, locale, host filesystem traversal or hash map order.

## F4. Minimal TypedHIR / static-plan contract for the first compiler

**TypedHIR is internal, not a public ABI, signed contract or new persistent graph.** Each node contains a compiler-local unique ID, exact `sourceSpan`, a resolved logical type reference, parent/child relation, effect/ownership summary and optional reviewed GraphOrigin. No node can claim a graph origin based on a guessed name.

First-slice accepted records:

```text
SourceUnit { path, sourceSha256, profile, originalLength }
Module { imports[], component, localSymbols[], sourceSpan }
Component { name, inputs[], events[], commands[], handlers[], rootView }
Input { name, nominalType, sourceSpan }
Event { id, payloadType=Unit, sourceSpan }
Command { id, inputs[] in source order, successType, errorType, domain, effects[], sourceSpan }
Handler { eventId, payloadLocalName, sendCommandId, namedArgumentBindings[], sourceSpan }
View { localId, kind=VStack|HStack|Text|Button, args[], childIds[] in source order, modifiers[] in source order, sourceSpan }
GraphOrigin { verifiedGraphNodeId, verifiedOperationId?, sourceLinkDigest? } // ONLY after P07
```

Pure property expressions are either a typed literal or a validated finite member path rooted in an input/handler value. No hidden evaluation of foreign methods, reads of global state, backend I/O or runtime StateSlot. The compiler must report all logical type and effect obligations before P08. View child order is semantic and must never be sorted; maps/collections that are sets (e.g. imports, effect lists) have explicit order rules. Source span and compiler-local IDs are **not** public type/graph identity.

`emit-plan --source-only` is a deterministic JSON *diagnostic artifact*, with explicit status `UNVERIFIED_SOURCE_ONLY`, source SHA, selected provisional catalogue identity, normalized root view and declaration/intent summaries. No `semanticGraphDigest`, `linked: true`, `approved: true`, native object SHA, signing claim or executable path appears. Its **proposed closed output shape** is [Source-only Plan Schema](../../schemas/aui-compiler-source-only-plan.schema.json), with a manually authored [StatusPanel expected plan](../../examples/aui-compiler-first-slice/status-panel-l0.source-only-plan.expected.json). This is not a native compiler's observed output or a durable D6 snapshot. A future architect decision must freeze exact canonical byte writing and source/catalog identity before the format becomes a compiler contract. Plan format identity is a tool artifact, not a product architecture edition.

**Proposed deterministic local identity/order policy:** number statically accepted View nodes in **preorder**, root as `v0`, then children left-to-right as `v1`, `v2` etc. These IDs are compilation-local only and never durable GraphNodeIDs. Preserve original View child order, command input order, modifier order and source span byte positions. Normalize imports as a lexically sorted unique set after semantic duplicate checking; normalize effects likewise. Named arguments stay in **source order** for mapping diagnostics, and their name-key type validation is independent of position. Literal string values in the plan are the fully decoded Unicode scalar sequence; integer U32 literal values are shortest unsigned decimal *strings* with an explicit `literal-u32` tag (not untyped JSON numbers). Lexical source byte spans always point at the raw authored ranges; never recompute them from formatted output. The exact plan schema alone does not establish cross-field referential integrity or complete typed member-path checking.

## F5. First native backend boundary (designed now, activated later)

- **Chosen first candidate:** own x86-64 Assembly backend emitting readable Win64 assembler input, then a qualified Clang/LLVM toolchain produces COFF and a signed/authorized linker flow produces PE32+ artifacts. LLVM IR may be researched separately but is **not a required alternate first backend** or a competing compiler architecture.
- The emitted static L0 View is a **typed, read-only component/view descriptor** plus exact imported runtime-UI constructor/adaptor symbols; it does not itself implement a Windows widget toolkit. A running window requires a qualified D5 renderer/event loop, text shaping/accessibility, D4 module header and ABI. Do **not** invent provisional exported symbol names as a production interface.
- L1 additionally emits a **typed command request stub**, never direct hardware call. Its target operation is resolved by verified GraphNodeID/OperationID, approved source bundle, exact exported signatures/effects/capabilities and a live scoped runtime admission check.
- The backend cannot be considered ready without exact LayoutIR and Win64 ABI for constant strings, literals, view descriptor ownership, event subscription lifetimes, result/error transfer, register/save/unwind rules and relocation names. Those are **P0 acceptance prerequisites**, not implementation details left to guess.
- Native optimization starts with none except deterministic dead-pure-fragment elimination proven not to remove accessibility or event effects. Correctness, source mapping and clear error paths precede zero-cost benchmarks.
- Do not use a generated executable as an undeclared way of promoting an `UNVERIFIED_SOURCE_ONLY` plan into approved runtime authority.

## F6. CLI/diagnostic and deterministic evidence interface (proposal)

Proposed commands (names/options require one architect decision before implementation):

```text
aelyxora-auic check --source-only --profile l0 --core-catalog <path> <file.aui>
aelyxora-auic check --source-only --profile l1 --core-catalog <path> <file.aui>
aelyxora-auic emit-plan --source-only --profile l0 --core-catalog <path> <file.aui> --out <staging-file>
aelyxora-auic link --profile l1 --snapshot <immutable-snapshot-root> --target <id> <file.aui> --out <staging>
aelyxora-auic build --profile l0 --snapshot <immutable-snapshot-root> --target <id> --out <staging>
```

`<path>` and `<file.aui>` are documentary placeholders, not shell syntax and not repository scripts. Source-only tools must never access the network, load untrusted native libraries or execute project code. A `--core-catalog` file in source-only mode is a **provisional review catalogue**, clearly reported as such; linked mode uses verified immutable package lock and approved core content, never this override.

Exit status candidate: `0` complete success for **requested mode only**, `1` user-source or project diagnostic, `2` CLI/invalid options, `3` unsupported profile/target/feature, `4` integrity/trust gate failure, `5` controlled internal/compiler resource failure. A crash or native exception is never treated as a valid diagnostic result. Source-only **failure** reports follow the [proposed closed diagnostic envelope](../../schemas/aui-compiler-source-only-diagnostics.schema.json): `code,stage,severity,sourceFile,sourceSha256,startByte,endByte,messageKey,expected,actual`. That schema is for a successfully captured (even if invalid) source; CLI failures **before** source capture require a separate transport and MUST NOT invent a source SHA or source span. Plain message text is for users; code and half-open byte span are fixture identities. `graphOrigin` is absent in source-only mode and is permitted only in a separate verified linked-report contract. Unsupported future feature is a diagnostic, not output with dropped behavior.

**Diagnostic precedence:** input path/size/UTF-8 → lexical string/number → source-profile gate → syntax → duplicate/import/symbol → type/arguments → event/handler/effect → static accessibility → exact graph+export link → target/ownership → native emitter/ABI → authenticity/approval and publication. Collect additional errors only when stage invariants permit; never infer trusted downstream state from a recovered AST.

Reproducibility needs pinned input byte hashes, Unicode rules, core catalogue, compiler revision/assembly toolchain/flags and host-independent deterministic traversal. A failure never replaces previous artifacts; write to confined staging, verify complete output and atomically publish via the future D6 adapter only when that phase exists.

## F7. Test design: precise cases, no claimed test results

Minimum named fixtures:

1. L0: [status-panel-l0.aui](../../examples/aui-language/status-panel-l0.aui) parses exactly one component, three static view nodes (VStack, Text, Button), two accessibility labels, zero commands and a typed `title: String` input; only provisional source-only type check is possible today.
2. L1: [linked-consumer-panel.aui](../../examples/aui-language/linked-consumer-panel.aui) parses one component, one `Event<Unit>`, one command `Accept(tick: Tick) -> Result<Tick,Failure>`, one handler, one Button. Its historical [link JSON](../../examples/aui-language/linked-consumer-panel.link.json) is **not** proof of a current canonical linked graph; linked mode MUST reject until a full verified locked export/link/snapshot is supplied.
3. Negative source mutations: reuse [existing D3 negative cases](../../examples/aui-language/d3-first-profile-negative-cases.json) without changing baseline bytes. Each mutation must have one unique search match or be rejected as a malformed fixture.
4. New [first compiler stage/gate cases](../../examples/aui-compiler-first-slice/acceptance-cases.json) describe lexical edge cases, deterministic traversal, source-only vs linked trust, limits and no-object-after-failure. The [additional Unicode 15.1 and diagnostics cases](../../examples/aui-compiler-first-slice/unicode-and-diagnostics-cases.json) are design-only. The [materialized invalid-spacing AUI](../../examples/aui-compiler-first-slice/status-panel-invalid-spacing.aui) and its [expected failure report](../../examples/aui-compiler-first-slice/status-panel-invalid-spacing.diagnostics.expected.json) pin a U32 range error at exact original bytes. [Fixture notes](../../examples/aui-compiler-first-slice/README.md) describe the provisional catalogue, plan schema and expected output.
5. For later native codegen, design separate Win64 object/ABI/renderer fixtures; no such check is marked PASS until an actual target test produces observed bytes, code and evidence.

**Acceptance labels:** `DESIGNED`, `NOT-RUN`, `PASS`, `FAIL`, `BLOCKED`, `UNSUPPORTED` must never be conflated. The current repository has only design fixtures, limited historical Assembly JSON delimiter preflight and separate arithmetic/structural document checks. It does **not** have an AUI compiler, full parser, renderer or linked native output.

## F8. Architect decisions and explicit implementation-ready cut line

| ID | Priority | Decision required before implementation / relevant phase |
| --- | --- | --- |
| COMP-01 | P0 | Approve first host Windows x64, Assembly-only front end, approved assembler/linker and whether P00–P06 may be treated as an explicitly bounded Phase II slice after in-scope D1–D8 review |
| COMP-02 | P0 | Freeze L0/L1 lexer edge cases, keyword/profile precedence, Unicode XID/NFC version, strict string/number semantics and exact limits |
| COMP-03 | P0 | Approve source-only provisional catalogue scope and exact `UNVERIFIED_SOURCE_ONLY` output/diagnostic envelope, refusing trusted digests |
| COMP-04 | P0 | Freeze minimal TypedHIR fields, deterministic plan ordering and AST/source-origin rules; no new Graph IDs |
| COMP-05 | P0 | Choose required static accessibility semantics, named-property type signatures and L1 event route/effect/domain constraints |
| COMP-06 | P0, linked phase | Finish exact core public semantic content/export digests and immutable D6 package locks; current 15 entries are UNVERIFIED |
| COMP-07 | P0, linked phase | Accept canonical typed source→Graph provider/operation contract resolution, source snapshot and signed reviewer trust, including target ID vs triple |
| COMP-08 | P0, native phase | Freeze D4 Win64 view/constant/command ABI and D5 renderer services, side effect boundaries, signing/build chain and native tests |
| COMP-09 | P1 | Agree diagnostic/fixture evidence format, source-only and linked negative precedence, future performance baseline and documentation for unsupported profiles |

**"Ready to implement first compiler" means:** approved COMP-01..05, a reviewed in-scope D1–D8 Phase I baseline (or *explicit* architect-approved bounded exception recorded by process owner), reproducible fixture expectations and a buildable native Assembly host/toolchain plan. **It does not require COMP-06..08 to implement only source-only P00–P06**, but those later gates **must** be accepted before claiming linked/native compiler capability. Until authorization is recorded, this is a detailed design specification, not permission or an implementation achievement.
