#!/usr/bin/env python3
"""Tests for tools/ui_densify_spoil_scan.py."""

from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import types
import unittest
from pathlib import Path


def _load() -> types.ModuleType:
    """Load sibling module."""
    path = Path(__file__).with_name("ui_densify_spoil_scan.py")
    spec = importlib.util.spec_from_file_location("ui_densify_spoil_scan", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


mod = _load()

_SAMPLE_DART = """
String? selectIdentifyDensifiedCoachLine(String activityId) {
  return switch (activityId) {
    // SoftPulse-quiet densify (unguided SoftPulse only after Hint) —
    // never name Call 10.
    'act-03-03-01-unguided' =>
      'Pot 20, bet 10 — tap Call 10.',
    // SoftPulse-quiet densify — clean.
    'act-04-01-01-unguided' =>
      'They bet twice — tap the matching range idea.',
    'act-01-01-03-guided-button' =>
      'Tap the dealer button — pick D chip.',
    _ => null,
  };
}
"""

_SAMPLE_CATALOG = {
    "sections": [
        {
            "units": [
                {
                    "lessons": [
                        {
                            "activities": [
                                {
                                    "id": "act-03-03-01-unguided",
                                    "choices": [
                                        {"label": "Call 10"},
                                        {"label": "Fold"},
                                    ],
                                },
                                {
                                    "id": "act-04-01-01-unguided",
                                    "choices": [
                                        {"label": "Too exact"},
                                        {"label": "Keep ranges"},
                                    ],
                                },
                                {
                                    "id": "act-01-01-03-guided-button",
                                    "choices": [{"label": "D chip"}],
                                },
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}


class UiDensifySpoilScanTest(unittest.TestCase):
    """Spoil detection against quiet densify stems."""

    def test_finds_quiet_choice_spoil(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "rex.dart"
            catalog = Path(tmp) / "catalog.json"
            source.write_text(_SAMPLE_DART, encoding="utf-8")
            catalog.write_text(json.dumps(_SAMPLE_CATALOG), encoding="utf-8")
            entries = mod.parse_densify_entries(source)
            labels = mod.load_choice_labels(catalog)
            rows = mod.find_spoils(
                entries, labels, quiet_only=True, include_guided=False
            )
            ids = [r[0] for r in rows]
            self.assertIn("act-03-03-01-unguided", ids)
            self.assertNotIn("act-04-01-01-unguided", ids)
            self.assertNotIn("act-01-01-03-guided-button", ids)

    def test_check_exits_one_on_spoil(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "rex.dart"
            catalog = Path(tmp) / "catalog.json"
            source.write_text(_SAMPLE_DART, encoding="utf-8")
            catalog.write_text(json.dumps(_SAMPLE_CATALOG), encoding="utf-8")
            code = mod.main(
                ["--source", str(source), "--catalog", str(catalog), "check"]
            )
            self.assertEqual(code, 1)

    def test_stop_labels_ignored(self) -> None:
        self.assertEqual(mod.spoil_labels("Tap fold now.", ["Fold"]), [])
        self.assertEqual(
            mod.spoil_labels("Tap Call 10.", ["Call 10"]),
            ["Call 10"],
        )

    def test_numeric_tile_labels(self) -> None:
        self.assertEqual(
            mod.spoil_labels("Pick 120bb as effective.", ["55bb", "120bb", "175bb"]),
            ["120bb"],
        )
        # Situation numbers that match tile labels are accepted (LPT-849).
        self.assertEqual(
            mod.spoil_labels(
                "You have 150bb. Villain has 60bb — tap the effective stack.",
                ["60bb", "150bb"],
            ),
            [],
        )
        self.assertEqual(
            mod.spoil_labels(
                "Two stacks face each other — pick the effective stack.",
                ["55bb", "120bb"],
            ),
            [],
        )

    def test_distinctive_label_fragments(self) -> None:
        label = "Draw — straight and flush potential"
        self.assertEqual(
            mod.spoil_labels(
                "Gutshot vs a 2x pot bet — tap straight and flush when pricing.",
                [label, "Fold — price is wrong"],
            ),
            [label],
        )
        self.assertEqual(
            mod.spoil_labels(
                "Gutshot vs a 2x pot bet — tap the matching price plan.",
                [label],
            ),
            [],
        )


if __name__ == "__main__":
    unittest.main()
