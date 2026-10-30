#!/usr/bin/env python3
"""Local AUI Project Graph validator. Bootstrap tooling, not the AUI compiler."""
from __future__ import annotations
import argparse
import copy
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SUPPORTED_SCHEMA = "0.1-draft"


class InputError(Exception):
    def __init__(self, code, detail):
        self.code, self.detail = code, detail
        super().__init__(detail)


def unique_pairs(pairs):
    out = {}
    for key, value in pairs:
        if key in out:
            raise InputError("JSON_DUPLICATE_KEY", key)
        out[key] = value
    return out


def read_json(path):
    try:
        if path.stat().st_size > 4 * 1024 * 1024:
            raise InputError("JSON_TOO_LARGE", str(path))
        return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_pairs,
                          parse_constant=lambda s: (_ for _ in ()).throw(InputError("JSON_NONFINITE", s)))
    except InputError:
        raise
    except (OSError, UnicodeError, ValueError) as e:
        raise InputError("JSON_INVALID", str(e)) from e


def check_unique(values, label):
    seen = set()
    for value in values:
        if value in seen:
            raise InputError("GRAPH_DUPLICATE_ID", f"{label}: {value}")
        seen.add(value)


def validate(project, package=None):
    if not isinstance(project, dict) or project.get("schemaVersion") != SUPPORTED_SCHEMA:
        raise InputError("SCHEMA_UNSUPPORTED_VERSION", "project schema")
    if project.get("format") != "aui.project":
        raise InputError("SCHEMA_INVALID", "project format")
    for key in ("nodes", "edges", "targets", "packageDependencies"):
        if not isinstance(project.get(key), list):
            raise InputError("SCHEMA_INVALID", f"{key} must be array")
    nodes = project["nodes"]
    if not all(isinstance(n, dict) and isinstance(n.get("id"), str) and n["id"] for n in nodes):
        raise InputError("SCHEMA_INVALID", "invalid node ID")
    check_unique((n["id"] for n in nodes), "node")
    check_unique((e.get("id") for e in project["edges"]), "edge")
    check_unique((t.get("id") for t in project["targets"]), "target")
    by_id = {n["id"]: n for n in nodes}
    targets = {t["id"] for t in project["targets"]}
    for n in nodes:
        if "target" in n and n["target"] not in targets:
            raise InputError("GRAPH_UNKNOWN_TARGET", n["id"])
        check_unique((p.get("id") for p in n.get("ports", [])), f"port of {n['id']}")
    for edge in project["edges"]:
        src, dst = edge.get("from", {}), edge.get("to", {})
        if src.get("node") not in by_id or dst.get("node") not in by_id:
            raise InputError("GRAPH_MISSING_NODE", str(edge.get("id")))
        if edge.get("kind") != "data-flow":
            continue
        source = next((p for p in by_id[src["node"]].get("ports", []) if p.get("id") == src.get("port")), None)
        dest = next((p for p in by_id[dst["node"]].get("ports", []) if p.get("id") == dst.get("port")), None)
        if not source or not dest or source.get("direction") != "out" or dest.get("direction") != "in":
            raise InputError("GRAPH_PORT_DIRECTION", str(edge["id"]))
        if source.get("type") != dest.get("type"):
            raise InputError("GRAPH_TYPE_MISMATCH", str(edge["id"]))
    if package is not None:
        if package.get("format") != "aui.component-package" or package.get("schemaVersion") != SUPPORTED_SCHEMA:
            raise InputError("SCHEMA_UNSUPPORTED_VERSION", "component package")
        exports = {x["typeId"] for x in package.get("types", [])}
        check_unique((x["typeId"] for x in package.get("types", [])), "type")
        components = {x["typeId"]: x for x in package.get("components", [])}
        check_unique((x["typeId"] for x in package.get("components", [])), "component")
        for dep in project["packageDependencies"]:
            if dep.get("packageId") != package.get("packageId") or dep.get("version") != package.get("packageVersion"):
                raise InputError("PKG_VERSION_CONFLICT", str(dep))
        for n in nodes:
            if n.get("typeRef") and n["typeRef"] not in components:
                raise InputError("PKG_MISSING_EXPORT", n["typeRef"])
            for port in n.get("ports", []):
                if "/" in port["type"] and port["type"] not in exports:
                    raise InputError("PKG_MISSING_TYPE", port["type"])
    return {"projectId": project.get("projectId"), "revision": project.get("revision"),
            "nodes": len(nodes), "edges": len(project["edges"])}


def apply_pointer(obj, pointer, value):
    if not pointer.startswith("/"):
        raise InputError("FIXTURE_INVALID", pointer)
    segments = [p.replace("~1", "/").replace("~0", "~") for p in pointer.split("/")[1:]]
    cur = obj
    for seg in segments[:-1]:
        cur = cur[int(seg)] if isinstance(cur, list) else cur[seg]
    k = segments[-1]
    cur[int(k) if isinstance(cur, list) else k] = value


def run_fixtures(project, fixtures):
    failures = []
    for case in fixtures["cases"]:
        candidate = copy.deepcopy(project)
        apply_pointer(candidate, case["mutation"]["path"], case["mutation"]["value"])
        try:
            validate(candidate)
            observed = "OK"
        except InputError as e:
            observed = e.code
        ok = observed == case["expected"]
        print(f"{'PASS' if ok else 'FAIL'} {case['id']}: expected={case['expected']} observed={observed}")
        if not ok:
            failures.append(case["id"])
    return not failures


def main(argv=None):
    parser = argparse.ArgumentParser(description="Validate AUI graph fixtures locally")
    parser.add_argument("project", type=pathlib.Path)
    parser.add_argument("--package", type=pathlib.Path)
    parser.add_argument("--fixtures", type=pathlib.Path)
    args = parser.parse_args(argv)
    try:
        project = read_json(args.project)
        package = read_json(args.package) if args.package else None
        result = validate(project, package)
        print("PASS project:", json.dumps(result, sort_keys=True))
        if args.fixtures and not run_fixtures(project, read_json(args.fixtures)):
            return 1
        return 0
    except InputError as e:
        print(f"FAIL {e.code}: {e.detail}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
