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
        # Q and 2 both pair; the highest paired rank wins (top, not bottom).
        self.assertEqual(
            mod.hero_board_pair_class(["Qh", "2d"], ["Qs", "7c", "2d"]),
            "top pair",
        )
        self.assertEqual(
            mod.hero_board_pair_class(["2h", "3d"], ["Qs", "7c", "2d"]),
            "third pair",
        )
        self.assertEqual(
            mod.hero_board_pair_class(["7h", "3d"], ["Qc", "Ts", "7h", "2c"]),
            "third pair",
        )
        self.assertEqual(
            mod.hero_board_pair_class(["2h", "3d"], ["Qc", "Ts", "7h", "2c"]),
            "bottom pair",
        )
        self.assertEqual(
            mod.hero_board_pair_class(
                ["2h", "3d"],
                ["Qc", "Ts", "7h", "4d", "2c"],
            ),
            "bottom pair",
        )
        # Past the four labels, clamp instead of indexing off the tuple.
        self.assertEqual(
            mod.hero_board_pair_class(
                ["5h", "3d"],
                ["Ac", "Kd", "Qh", "Js", "9c", "5d"],
            ),
            "bottom pair",
        )
        self.assertIsNone(mod.hero_board_pair_class(["Ah", "Kd"], []))
        self.assertIsNone(
            mod.hero_board_pair_class(["xx", "yy"], ["Qs", "7c", "2d"])
        )
        self.assertEqual(
            mod.board_pair_ranks(["2c", "As", "2d", "Kd"]),
            ["A", "K", "2"],
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

    def test_repo_pair_class_overrides_stay_honest(self) -> None:
        mapping = mod.parse_felt_codes(mod.DEFAULT_FELT_SOURCE)
        expected = {
            "act-06-13-01-03-explain-lag": "second pair",
            "act-06-11-03-02-explain-checkraise": "second pair",
            "act-07-07-01-02-explain-tag": "top pair",
            "act-06-07-01-02-explain-trash": "third pair",
        }
        for activity_id, claim in expected.items():
            hero, board = mapping[activity_id]
            self.assertEqual(
                mod.hero_board_pair_class(hero, board),
                claim,
                activity_id,
            )
        gaps = mod.find_felt_mismatches(
            catalog=mod.DEFAULT_CATALOG,
            felt_source=mod.DEFAULT_FELT_SOURCE,
            visual_source=mod.DEFAULT_VISUAL_SOURCE,
        )
        ids = {str(g["id"]) for g in gaps}
        self.assertTrue(expected.keys().isdisjoint(ids))

    def test_parse_felt_codes_falls_back_and_skips_orphan_ifs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "felt.dart"
            path.write_text("void unrelated() {}\n", encoding="utf-8")
            mapping = mod.parse_felt_codes(path)
            self.assertEqual(mapping[""], (("Ah", "Kd"), ("Qs", "7c", "2d")))

            path.write_text(
                """
authoredCueExplainFeltCodes(CourseActivity activity) {
  return (
    heroCodes: const [],
    boardCodes: const ['Qs', '7c', '2d'],
  );
  if (id == 'act-orphan') {
    final skipped = 1;
  }
}
""",
                encoding="utf-8",
            )
            mapping = mod.parse_felt_codes(path)
            self.assertNotIn("act-orphan", mapping)
            self.assertEqual(mapping[""][0], ("Ah", "Kd"))
            self.assertEqual(mapping[""][1], ("Qs", "7c", "2d"))

    def test_skips_dedicated_visuals_and_non_dialogue(self) -> None:
        catalog = {
            "sections": [
                {
                    "units": [
                        {
                            "lessons": [
                                {
                                    "id": "lesson-warmup",
                                    "activities": [
                                        {
                                            "id": "act-01-06-01-explain-run",
                                            "accessibilityText": "Second pair folds.",
                                            "teachSpec": {
                                                "cues": [
                                                    {
                                                        "press": 1,
                                                        "target": "RUN",
                                                        "kind": "soft_pulse",
                                                    },
                                                    {
                                                        "press": 2,
                                                        "target": "EXPLAIN",
                                                        "kind": "soft_pulse",
                                                    },
                                                ]
                                            },
                                        },
                                        {
                                            "id": "act-identify-second",
                                            "renderer": "identify",
                                            "accessibilityText": "Second pair.",
                                            "teachSpec": {
                                                "cues": [
                                                    {
                                                        "press": 1,
                                                        "target": "PAIR",
                                                        "kind": "soft_pulse",
                                                    },
                                                    {
                                                        "press": 2,
                                                        "target": "EXPLAIN",
                                                        "kind": "soft_pulse",
                                                    },
                                                ]
                                            },
                                        },
                                        {
                                            "id": "act-feedback-claim",
                                            "okFeedback": "Call with top pair.",
                                            "teachSpec": {
                                                "cues": [
                                                    {
                                                        "press": 1,
                                                        "target": "CALL",
                                                        "kind": "soft_pulse",
                                                    },
                                                    {
                                                        "press": 2,
                                                        "target": "WHY",
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
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            felt = root / "felt.dart"
            visual = root / "visual.dart"
            catalog_path = root / "catalog.json"
            felt.write_text(_SAMPLE_FELT, encoding="utf-8")
            visual.write_text(_SAMPLE_VISUAL, encoding="utf-8")
            catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
            gaps = mod.find_felt_mismatches(
                catalog=catalog_path,
                felt_source=felt,
                visual_source=visual,
            )
            ids = [g["id"] for g in gaps]
            self.assertNotIn("act-01-06-01-explain-run", ids)
            self.assertNotIn("act-identify-second", ids)
            self.assertEqual(ids, ["act-feedback-claim"])
            self.assertEqual(gaps[0]["claim"], "top pair")
            self.assertEqual(gaps[0]["slug"], "lesson-warmup")

    def test_draft_ticket_strips_numeric_prefix_and_caps_title(self) -> None:
        numeric = mod.draft_ticket(
            {
                "id": "act-06-11-03-02-explain-checkraise",
                "slug": "lesson-06-11-03-02-tag-checkraise",
                "claim": "second pair",
                "actual": "no board pair",
                "hero": ["Ah", "Kd"],
                "board": ["Qs", "7c", "2d"],
            }
        )
        self.assertTrue(numeric["title"].startswith("tag checkraise "))
        long_slug = "lesson-" + "-".join(["word"] * 25)
        capped = mod.draft_ticket(
            {
                "id": "act-long",
                "slug": long_slug,
                "claim": "second pair",
                "actual": "no board pair",
                "hero": ["Ah", "Kd"],
                "board": ["Qs", "7c", "2d"],
            }
        )
        self.assertEqual(
            capped["title"],
            "AuthoredCue felt honesty: second pair vs no board pair (act-long)",
        )
        self.assertLessEqual(len(capped["title"]), 120)


if __name__ == "__main__":
    unittest.main()
