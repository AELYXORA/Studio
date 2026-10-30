# S0 Project Graph Foundation — Implementation Baseline

**Status: source committed; execution not verified on developer host.** This is a small **Python standard-library bootstrap validator** used to ground Project Graph rules before the AUI-native toolchain exists. Python is not the chosen implementation language for the future Studio, UI or Assembly-first runtime.

## Files

- [tools/aui_graph.py](../../tools/aui_graph.py) — strict JSON reader for duplicate keys and size limits; structural graph checks; optional component export and type registry checks; negative fixture runner.
- [tests/test_aui_graph.py](../../tests/test_aui_graph.py) — manually invoked unittest tests.
- [sensor project](../../examples/architecture-sensor/project.auiproj.json), [package](../../examples/architecture-sensor/component.auipkg.json), [invalid fixtures](../../examples/architecture-sensor/invalid-cases.json) — existing test inputs.

## Local commands

From repo root with Python 3:

```sh
python tools/aui_graph.py examples/architecture-sensor/project.auiproj.json --package examples/architecture-sensor/component.auipkg.json --fixtures examples/architecture-sensor/invalid-cases.json
python -m unittest discover -s tests -v
```

Expected: positive example accepted, six negative mutations rejected with their declared codes, round-trip JSON object identity test and duplicate JSON key rejection. These are **expectations**, not an assertion that these commands ran.

## Known limitations and next implementation work

The CLI does **not** yet implement the full JSON Schema 2020-12 engine, package lockfile/digest verification, strict unknown-field rejection, package portability, stable atomic save, external-edit conflict handling, semantic hash, graph edit transactions, component capability enforcement or hardware support. Current round-trip test writes and reloads a JSON object in a disposable temporary directory; it is not a safe project save mechanism. Only a single locally provided component package can be checked.

The validation code is committed as a minimal baseline so precise behavior can be tested rather than merely specified. Do not claim G1/S0 exit criteria passed until independent local execution and missing semantic checks are implemented. No CI has been added.
