#!/usr/bin/env python3
"""Tests for tools/ui_densify_caller_scan.py."""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import types
import unittest
from pathlib import Path


def _load() -> types.ModuleType:
    """Load sibling module."""
    path = Path(__file__).with_name("ui_densify_caller_scan.py")
    spec = importlib.util.spec_from_file_location("ui_densify_caller_scan", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


mod = _load()


class DensifyCallerScanTest(unittest.TestCase):
    """Caller-count port + gap detection."""

    def test_parse_digit_and_word_callers(self) -> None:
        self.assertEqual(mod.parse_caller_count("UTG opens · 2 callers"), 2)
        self.assertEqual(mod.parse_caller_count("Three callers · wet board"), 3)
        self.assertEqual(mod.parse_caller_count("Checked to you · 4-way"), 3)

    def test_parse_word_four_way(self) -> None:
        self.assertEqual(mod.parse_caller_count("Four-way · bet into you"), 3)
        self.assertEqual(
            mod.parse_caller_count("Four-way limp · checked to you"),
            3,
        )

    def test_parse_behind_and_called_by(self) -> None:
        self.assertEqual(mod.parse_caller_count("Checked to you · two behind"), 2)
        self.assertEqual(mod.parse_caller_count("Two players behind"), 2)
        self.assertEqual(mod.parse_caller_count("Called by two"), 2)

    def test_parse_bare_multiway_and_sticky(self) -> None:
        self.assertEqual(mod.parse_caller_count("Multiway · deep stacks"), 2)
        self.assertEqual(mod.parse_caller_count("Raise · reraise multiway"), 2)
        self.assertEqual(
            mod.parse_caller_count("Sticky caller · checked to you"),
            1,
        )

    def test_explicit_count_beats_soft_fallback(self) -> None:
        """N callers / N-way win; sticky seat is not a caller count."""
        self.assertEqual(
            mod.parse_caller_count("Three callers · multiway"),
            3,
        )
        self.assertEqual(
            mod.parse_caller_count("Checked to you · 4-way sticky caller"),
            3,
        )
        self.assertEqual(
            mod.parse_caller_count("Called by three · multiway"),
            3,
        )
        self.assertEqual(mod.parse_caller_count("sticky callers"), 1)
        self.assertIsNone(
            mod.parse_caller_count("Same sticky seat · brick river"),
        )
        self.assertIsNone(mod.parse_caller_count(""))

    def test_parse_named_bb_mp(self) -> None:
        self.assertEqual(mod.parse_caller_count("BTN open · BB + MP call"), 2)
        self.assertEqual(
            set(mod.parse_named_caller_positions("BTN open · BB + MP call")),
            {"BB", "MP"},
        )

    def test_check_flags_unparsed_multiway(self) -> None:
        sample = """
          villainLine: 'Invented multiway · mystery callers',
          villainLine: 'Three callers · wet board',
        """
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "table.dart"
            path.write_text(sample, encoding="utf-8")
            # Bare "multiway" now parses to 2 — use uncounted "callers behind".
            path.write_text(
                "villainLine: 'Extra callers behind',\n"
                "villainLine: 'Three callers · wet board',\n",
                encoding="utf-8",
            )
            self.assertEqual(
                mod.main(["--source", str(path), "check"]),
                1,
            )
            path.write_text(
                "villainLine: 'Three callers · wet board',\n"
                "villainLine: 'Four-way · bet into you',\n",
                encoding="utf-8",
            )
            self.assertEqual(
                mod.main(["--source", str(path), "check"]),
                0,
            )

    def test_repo_check_clean_after_four_way_fix(self) -> None:
        self.assertEqual(mod.main(["check"]), 0)


if __name__ == "__main__":
    unittest.main()
