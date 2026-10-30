# AELYXORA Delivery Roadmap

**Current implementation status:** [verified artifacts, missing components and authoritative milestones](../architecture/PROJECT-STATUS.md).

**Product:** Assembly-first AI-driven systems development; main workspace is the interactive Architecture Map plus contextual AI Chat. The target is software close to hardware.

1. **G0 Design baseline:** resolve canonical graph and AUI contracts, supply inspectable fixtures and specified acceptance checks; no CI.
2. **G1 Hardware-aware graph:** typed components, ports, devices, buses, target ISA/ABI, resource relations and persistence. Verify a device-driver-protocol-app example.
3. **G2 First Studio screen:** own declarative UI displays an interactive architecture graph with a docked AI-chat panel (clearly marked disconnected until authorized). View contracts from map nodes.
4. **G3 Safe editing:** graph transactions, revisioned diff, approval, undo and hardware constraint validation.
5. **G4 Component workflow:** node selection, scoped AI proposal when available, native Assembly implementation, local test evidence.
6. **G5 ChatGPT authorization:** only officially supported integration, without harvesting session credentials or assuming that Plus is an API key.
7. **G6 Hardware tools:** ISA/ABI checks, register and interrupt models, DMA ownership rules, optional local target debugging.
8. **G7 Target expansion:** AArch64 and further target platforms only after on-target verification.

**Current implementation:** documentation, illustrative fixtures, and a limited Linux x86-64 Assembly JSON lexical preflight; no complete parser, Project Graph engine, IDE, AUI compiler, renderer, live AI or hardware debugging.

**Rules:** short documents, proof-oriented gates, manual local tests, no GitHub Actions until release preparation.

## Required evidence per gate

Each gate must provide a locally runnable acceptance fixture, exact command, observed pass/fail/not-run result and limitations. G1 uses a sensor/driver/protocol/application graph with invalid-port, resource-conflict and target-mismatch negative tests. G2 demonstrates map selection, contextual contract inspection, docked disconnected chat and save/reopen fidelity. G3 demonstrates rejected stale writes, rejected AI proposals without mutation and reversible graph edits. G4 compares component behavior with target ABI fixtures and keeps generated source ownership distinct from user-edited files.

**Next implementation task:** implement a native parser and semantic Project Graph validator against the existing sensor fixtures; the fixtures and candidate schemas already exist.


[Architecture Freeze Readiness and Implementation Strategy](../architecture/implementation-readiness.md) concludes global freeze is premature and orders S0 graph validation, S1 architecture workspace, S2 minimal AUI native build, S3 controlled AI workflow and S4 on-target hardware verification. **S0 lexical preflight has limited smoke evidence; full S0–S4 acceptance gates remain not-run. CI disabled.**


## S0 implementation status

The earlier Python validator and tests have been removed. S0 has **no functional graph validator**; only an experimental native Linux x86-64 JSON lexical preflight. See [Implementation Language Policy](../architecture/language-policy.md) and [S0 status](../architecture/s0-graph-implementation.md).


**Implementation restriction:** Python is prohibited in the Studio codebase, build tooling and tests. [Policy](../architecture/language-policy.md).
