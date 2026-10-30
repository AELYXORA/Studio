"""Local-only tests: python -m unittest discover -s tests -v (no CI)."""
import copy
import json
import pathlib
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from aui_graph import InputError, apply_pointer, read_json, validate  # noqa: E402

EXAMPLE = ROOT / "examples" / "architecture-sensor"


class GraphTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.project = read_json(EXAMPLE / "project.auiproj.json")
        cls.package = read_json(EXAMPLE / "component.auipkg.json")

    def test_positive_project(self):
        result = validate(self.project, self.package)
        self.assertEqual((result["nodes"], result["edges"]), (6, 4))

    def test_negative_fixtures(self):
        fixtures = read_json(EXAMPLE / "invalid-cases.json")
        for case in fixtures["cases"]:
            with self.subTest(case=case["id"]):
                candidate = copy.deepcopy(self.project)
                apply_pointer(candidate, case["mutation"]["path"], case["mutation"]["value"])
                with self.assertRaises(InputError) as err:
                    validate(candidate)
                self.assertEqual(err.exception.code, case["expected"])

    def test_round_trip_keeps_identity(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = pathlib.Path(tmp) / "project.json"
            path.write_text(json.dumps(self.project, ensure_ascii=False, indent=2), encoding="utf-8")
            loaded = read_json(path)
            self.assertEqual(loaded, self.project)
            self.assertEqual(validate(loaded)["nodes"], 6)

    def test_duplicate_json_keys_are_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = pathlib.Path(tmp) / "duplicate.json"
            path.write_text('{"a": 1, "a": 2}', encoding="utf-8")
            with self.assertRaises(InputError) as err:
                read_json(path)
            self.assertEqual(err.exception.code, "JSON_DUPLICATE_KEY")

    def test_unknown_package_type(self):
        candidate = copy.deepcopy(self.project)
        candidate["nodes"][3]["ports"][0]["type"] = "example.sensor/Missing"
        with self.assertRaises(InputError) as err:
            validate(candidate, self.package)
        self.assertEqual(err.exception.code, "GRAPH_TYPE_MISMATCH")


if __name__ == "__main__":
    unittest.main()
