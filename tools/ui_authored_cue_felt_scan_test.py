#!/usr/bin/env python3
"""Tests for tools/ui_authored_cue_felt_scan.py."""

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
    path = Path(__file__).with_name("ui_authored_cue_felt_scan.py")
    spec = importlib.util.spec_from_file_location("ui_authored_cue_felt_scan", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


mod = _load()

_SAMPLE_FELT = """
({List<String> heroCodes, List<String> boardCodes})
authoredCueExplainFeltCodes(CourseActivity activity) {
  final id = activity.id;
  if (id == 'act-06-13-01-02-explain-nit' ||
      id == 'act-06-13-01-03-explain-lag') {
    return (
      heroCodes: const ['Jh', 'Td'],
      boardCodes: const ['Qc', 'Ts', '3h', '2d', '7c'],
    );
  }
  return (
    heroCodes: const ['Ah', 'Kd'],
    boardCodes: const ['Qs', '7c', '2d'],
  );
}
"""

_SAMPLE_VISUAL = """
CoachDialogueVisual resolveCoachDialogueVisual(CourseActivity activity) {
  switch (activity.id) {
    case 'act-01-06-01-explain-run':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.toyHandRun,
      );
  }

  if (authoredSoftPulseTargets(activity) != null) {
    return const CoachDialogueVisual(kind: CoachDialogueVisualKind.authoredCues);
  }
  return const CoachDialogueVisual(kind: CoachDialogueVisualKind.none);
}
"""

_SAMPLE_CATALOG = {
    "sections": [
        {
            "units": [
                {
                    "lessons": [
                        {
                            "id": "lesson-06-11-03-02-tag-checkraise",
                            "activities": [
                                {
                                    "id": "act-06-11-03-02-explain-checkraise",
                                    "renderer": "coach_dialogue",
                                    "accessibilityText": (
                                        "When a TAG check-raises, believe it. "
                                        "Second pair folds."
                                    ),
                                    "teachSpec": {
                                        "cues": [
                                            {
                                                "press": 1,
                                                "target": "TAG CHECK-RAISE",
                                                "kind": "soft_pulse",
                                            },
                                            {
                                                "press": 2,
                                                "target": "CAREFUL",
                                                "kind": "soft_pulse",
                                            },
                                        ]
                                    },
                                },
                                {
                                    "id": "act-06-13-01-03-explain-lag",
                                    "renderer": "coach_dialogue",
                                    "accessibilityText": (
                                        "Same cards versus a LAG barrel. "
                                        "Their range is wide, so second pair calls."
                                    ),
                                    "teachSpec": {
                                        "cues": [
                                            {
                                                "press": 1,
                                                "target": "LAG BARREL",
                                                "kind": "soft_pulse",
                                            },
                                            {
                                                "press": 2,
                                                "target": "CALL",
                                                "kind": "soft_pulse",
                                            },
                                        ]
                                    },
                                },
                            ],
                        }
                    ]
                }
            ]
        }
    ]
}


class AuthoredCueFeltScanTest(unittest.TestCase):
    """Unit tests for felt / coach honesty discovery."""

    def test_pair_class_on_known_boards(self) -> None:
        self.assertIsNone(
            mod.hero_board_pair_class(["Ah", "Kd"], ["Qs", "7c", "2d"])
        )
        self.assertEqual(
            mod.hero_board_pair_class(
                ["Jh", "Td"],
                ["Qc", "Ts", "3h", "2d", "7c"],
            ),
            "second pair",
        )
        self.assertEqual(
            mod.hero_board_pair_class(["Qh", "2d"], ["Qs", "7c", "2d"]),
            "top pair",
        )

    def test_parse_felt_codes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "felt.dart"
            path.write_text(_SAMPLE_FELT, encoding="utf-8")
            mapping = mod.parse_felt_codes(path)
            self.assertEqual(mapping[""][0], ("Ah", "Kd"))
            self.assertEqual(
                mapping["act-06-13-01-03-explain-lag"][0],
                ("Jh", "Td"),
            )

    def test_find_mismatches_skips_honest_override(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            felt = root / "felt.dart"
            visual = root / "visual.dart"
            catalog = root / "catalog.json"
            felt.write_text(_SAMPLE_FELT, encoding="utf-8")
            visual.write_text(_SAMPLE_VISUAL, encoding="utf-8")
            catalog.write_text(json.dumps(_SAMPLE_CATALOG), encoding="utf-8")
            gaps = mod.find_felt_mismatches(
                catalog=catalog,
                felt_source=felt,
                visual_source=visual,
            )
            self.assertEqual(len(gaps), 1)
            self.assertEqual(
                gaps[0]["id"],
                "act-06-11-03-02-explain-checkraise",
            )
            self.assertEqual(gaps[0]["claim"], "second pair")
            self.assertEqual(gaps[0]["actual"], "no board pair")

    def test_repo_live_scan_runs(self) -> None:
        gaps = mod.find_felt_mismatches(
            catalog=mod.DEFAULT_CATALOG,
            felt_source=mod.DEFAULT_FELT_SOURCE,
            visual_source=mod.DEFAULT_VISUAL_SOURCE,
        )
        ids = {str(g["id"]) for g in gaps}
        self.assertIn("act-06-11-03-02-explain-checkraise", ids)
        self.assertNotIn("act-06-13-01-03-explain-lag", ids)


if __name__ == "__main__":
    unittest.main()
