#!/usr/bin/env python3
"""Tests for tools/ui_softpulse_caption_scan.py."""

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
    path = Path(__file__).with_name("ui_softpulse_caption_scan.py")
    spec = importlib.util.spec_from_file_location("ui_softpulse_caption_scan", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


mod = _load()

_SAMPLE_CAPTIONS = """
String authoredSoftPulseExplainCaption(String target) {
  const captions = <String, String>{
    'PASSIVE': 'Never raise',
    'CROWD': 'Spew multiway',
  };
  return captions[target] ?? '';
}
"""

_SAMPLE_VISUAL = """
CoachDialogueVisual resolveCoachDialogueVisual(CourseActivity activity) {
  switch (activity.id) {
    case 'act-03-08-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.passiveCrowd,
      );
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
                            "id": "lesson-passive-and-crowds",
                            "activities": [
                                {
                                    "id": "act-03-08-01-explain",
                                    "renderer": "coach_dialogue",
                                    "teachSpec": {
                                        "cues": [
                                            {
                                                "press": 1,
                                                "target": "PASSIVE",
                                                "kind": "soft_pulse",
                                            },
                                            {
                                                "press": 2,
                                                "target": "MISSING PARENT",
                                                "kind": "soft_pulse",
                                            },
                                        ]
                                    },
                                },
                                {
                                    "id": "act-03-08-01-03-explain-passive",
                                    "renderer": "coach_dialogue",
                                    "teachSpec": {
                                        "cues": [
                                            {
                                                "press": 1,
                                                "target": "PASSIVE",
                                                "kind": "soft_pulse",
                                            },
                                            {
                                                "press": 2,
                                                "target": "CONTINUE",
                                                "kind": "soft_pulse",
                                            },
                                        ]
                                    },
                                },
                                {
                                    "id": "act-03-08-01-guided",
                                    "renderer": "select_identify",
                                    "teachSpec": {
                                        "cues": [
                                            {
                                                "press": 1,
                                                "target": "fold",
                                                "kind": "soft_pulse",
                                            }
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


class SoftPulseCaptionScanTest(unittest.TestCase):
    """Unit tests for caption-gap discovery."""

    def test_parse_caption_keys(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "captions.dart"
            path.write_text(_SAMPLE_CAPTIONS, encoding="utf-8")
            self.assertEqual(
                mod.parse_caption_keys(path),
                {"PASSIVE", "CROWD"},
            )

    def test_parse_dedicated_visual_ids(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "visual.dart"
            path.write_text(_SAMPLE_VISUAL, encoding="utf-8")
            self.assertEqual(
                mod.parse_dedicated_visual_ids(path),
                {
                    "act-03-08-01-explain",
                    "act-01-06-01-explain-run",
                },
            )

    def test_find_caption_gaps_skips_dedicated_and_densify(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            caption = root / "captions.dart"
            visual = root / "visual.dart"
            catalog = root / "catalog.json"
            caption.write_text(_SAMPLE_CAPTIONS, encoding="utf-8")
            visual.write_text(_SAMPLE_VISUAL, encoding="utf-8")
            catalog.write_text(json.dumps(_SAMPLE_CATALOG), encoding="utf-8")
            gaps = mod.find_caption_gaps(
                catalog=catalog,
                caption_source=caption,
                visual_source=visual,
            )
            self.assertEqual(len(gaps), 1)
            self.assertEqual(gaps[0]["id"], "act-03-08-01-03-explain-passive")
            self.assertEqual(gaps[0]["missing"], ["CONTINUE"])
            self.assertEqual(gaps[0]["slug"], "lesson-passive-and-crowds")

    def test_check_exits_nonzero_on_gaps(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            caption = root / "captions.dart"
            visual = root / "visual.dart"
            catalog = root / "catalog.json"
            caption.write_text(_SAMPLE_CAPTIONS, encoding="utf-8")
            visual.write_text(_SAMPLE_VISUAL, encoding="utf-8")
            catalog.write_text(json.dumps(_SAMPLE_CATALOG), encoding="utf-8")
            code = mod.main(
                [
                    "check",
                    "--catalog",
                    str(catalog),
                    "--caption-source",
                    str(caption),
                    "--visual-source",
                    str(visual),
                ]
            )
            self.assertEqual(code, 1)

    def test_repo_parsers_find_live_sources(self) -> None:
        keys = mod.parse_caption_keys(mod.DEFAULT_CAPTION_SOURCE)
        dedicated = mod.parse_dedicated_visual_ids(mod.DEFAULT_VISUAL_SOURCE)
        self.assertIn("PASSIVE", keys)
        self.assertIn("CONTINUE", keys)
        self.assertIn("act-01-06-01-explain-run", dedicated)
        self.assertGreater(len(keys), 50)
        self.assertGreater(len(dedicated), 20)


if __name__ == "__main__":
    unittest.main()
