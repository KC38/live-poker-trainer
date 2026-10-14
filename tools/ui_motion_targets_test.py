#!/usr/bin/env python3
"""Tests for tools/ui_motion_targets.py."""

from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import types
import unittest
from datetime import datetime, timezone
from pathlib import Path


def _load() -> types.ModuleType:
    """Load sibling module."""
    path = Path(__file__).with_name("ui_motion_targets.py")
    spec = importlib.util.spec_from_file_location("ui_motion_targets", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    # dataclasses need the module registered before exec_module.
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


mod = _load()


class UiMotionTargetsTest(unittest.TestCase):
    """Target list + pick ranking."""

    def test_targets_cover_all_classes(self) -> None:
        classes = {t.motion_class for t in mod.TARGETS}
        self.assertEqual(classes, {"multi_frame", "static_move", "dynamic"})
        self.assertGreaterEqual(len(mod.TARGETS), 6)

    def test_pick_prefers_never_walked(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            cov = Path(tmp) / "coverage.jsonl"
            walked = mod.TARGETS[0].surface
            row = {
                "at": datetime(2026, 10, 1, tzinfo=timezone.utc).isoformat(),
                "surface": walked,
                "result": "closed",
            }
            cov.write_text(json.dumps(row) + "\n", encoding="utf-8")
            picked = mod.pick_targets(coverage_path=cov, limit=3)
            self.assertTrue(picked)
            self.assertNotEqual(picked[0].surface, walked)

    def test_cli_list(self) -> None:
        code = mod.main(["list"])
        self.assertEqual(code, 0)

    def test_cli_classes(self) -> None:
        self.assertEqual(mod.main(["classes"]), 0)


if __name__ == "__main__":
    unittest.main()
