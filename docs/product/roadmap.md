# AELYXORA — Evidence-based Roadmap

**Goal:** architecture-map-centric AI-driven Assembly-first RAD Studio. Human architect defines the graph; AI implements components under explicit contracts.

1. **G0 — Native baseline:** local Assembly build and test of the current validator; record actual results, with no GitHub Actions.
2. **G1 — Project graph:** stable node IDs, typed ports, connections and validation; serialize/restore a small architecture project.
3. **G2 — Map first window:** our own declarative UI renders and allows selecting/editing nodes and typed links. This, not a form designer, is the first usable Studio screen.
4. **G3 — Architecture transactions:** safe graph edits, revisions, undo and visible graph diffs.
5. **G4 — Component engineering:** AI receives selected node/subgraph, contracts and constraints; proposes Assembly files/tests; human reviews and approves; local build reports evidence.
6. **G5 — ChatGPT access:** evaluate supported Sign in with ChatGPT participation and eligible plan permission flow; no unsupported credential reuse or subscription-as-API assumption. Keep core usable without it.
7. **G6 — Declarative component UI:** detailed view/editor for components, layout, state and behavior, accessed from architecture map.
8. **G7 — Multi-target validation:** separate ABI and execution tests for every advertised CPU/OS target.

**Not yet implemented:** graphical Studio, map, project graph persistence, auth, AI component generation, renderer, cross-target runtime.

**Working rule:** only specify a gate when its outcome can be demonstrated. Short docs, working examples, manual tests. No CI until release preparation.
