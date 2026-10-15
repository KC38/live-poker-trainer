#!/usr/bin/env python3
"""Tests for tools/ui_densify_card_scan.py."""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import types
import unittest
from pathlib import Path


def _load() -> types.ModuleType:
    """Load sibling module."""
    path = Path(__file__).with_name("ui_densify_card_scan.py")
    spec = importlib.util.spec_from_file_location("ui_densify_card_scan", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


mod = _load()

_SAMPLE = """
String? selectIdentifyDensifiedCoachLine(String activityId) {
  return switch (activityId) {
    'act-03-02-01-unguided' =>
      'Board Qc 7d 2s. You hold 5h 4h multiway. Class — tap the matching label.',
    'act-01-01-03-guided-button' => 'Tap the dealer button on the table.',
    _ => null,
  };
}

String other() => 'Board As As';
"""

_LAYOUT_WIRED = """
  final densifiedSelect = selectIdentifyDensifiedCoachLine(activity.id);
  if (densifiedSelect != null) {
    return alignLessonActionCopy(
      activity,
      densifiedSelect,
      generation: bindGeneration,
    );
  }
"""

_LAYOUT_RAW = """
  final densifiedSelect = selectIdentifyDensifiedCoachLine(activity.id);
  if (densifiedSelect != null) return densifiedSelect;
"""


class UiDensifyCardScanTest(unittest.TestCase):
    """Parser + card token detection + align wiring check."""

    def test_parse_and_list_card_stems(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "rex_coach_line.dart"
            path.write_text(_SAMPLE, encoding="utf-8")
            stems = mod.parse_densify_stems(path)
            self.assertIn("act-03-02-01-unguided", stems)
            self.assertIn("act-01-01-03-guided-button", stems)
            rows = mod.stems_with_cards(stems)
            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0][0], "act-03-02-01-unguided")
            self.assertEqual(rows[0][1], ["qc", "7d", "2s", "5h", "4h"])

    def test_check_ok_when_align_wired(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "rex_coach_line.dart"
            layout = Path(tmp) / "lesson_screen_layout.dart"
            source.write_text(_SAMPLE, encoding="utf-8")
            layout.write_text(_LAYOUT_WIRED, encoding="utf-8")
            code = mod.main(
                ["--source", str(source), "--layout", str(layout), "check"]
            )
            self.assertEqual(code, 0)

    def test_check_fails_when_raw_return(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "rex_coach_line.dart"
            layout = Path(tmp) / "lesson_screen_layout.dart"
            source.write_text(_SAMPLE, encoding="utf-8")
            layout.write_text(_LAYOUT_RAW, encoding="utf-8")
            code = mod.main(
                ["--source", str(source), "--layout", str(layout), "check"]
            )
            self.assertEqual(code, 1)

    def test_cli_list(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "rex_coach_line.dart"
            layout = Path(tmp) / "lesson_screen_layout.dart"
            source.write_text(_SAMPLE, encoding="utf-8")
            layout.write_text(_LAYOUT_WIRED, encoding="utf-8")
            self.assertEqual(
                mod.main(
                    ["--source", str(source), "--layout", str(layout), "list"]
                ),
                0,
            )

    def test_ignores_english_as_without_deal_context(self) -> None:
        self.assertEqual(mod.card_tokens("Nit is best treated as — tap."), [])
        self.assertEqual(
            mod.card_tokens("Board As 7d 2c. You hold 3h."),
            ["as", "7d", "2c", "3h"],
        )


if __name__ == "__main__":
    unittest.main()
