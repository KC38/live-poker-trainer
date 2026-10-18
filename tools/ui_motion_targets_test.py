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

    def test_pick_counts_coverage_aliases(self) -> None:
        """Sibling lesson/runner surfaces count as a walk for the motion id."""
        with tempfile.TemporaryDirectory() as tmp:
            cov = Path(tmp) / "coverage.jsonl"
            # Canonical live id logged — retired pre-split alias still credited.
            row = {
                "at": datetime(2026, 10, 15, tzinfo=timezone.utc).isoformat(),
                "surface": "lesson-01-02-02-01-best-five",
                "result": "closed",
                "ticket": "LPT-835",
            }
            cov.write_text(json.dumps(row) + "\n", encoding="utf-8")
            picked = mod.pick_targets(coverage_path=cov, limit=10)
            surfaces = [t.surface for t in picked]
            self.assertNotIn(
                "lesson-01-02-02-01-best-five",
                surfaces[:3],
                "live-id walk should demote best-five below never-walked picks",
            )
            walked_at = mod.last_walk_for_surface(
                mod.last_walk_by_surface(mod.load_coverage(cov)),
                "lesson-01-02-02-01-best-five",
            )
            self.assertIsNotNone(walked_at)
            # Retired pre-split coverage surface still credits the live target.
            retired = {
                "at": datetime(2026, 10, 14, tzinfo=timezone.utc).isoformat(),
                "surface": "lesson-01-01-03-blinds-and-button",
                "result": "closed",
            }
            cov.write_text(
                json.dumps(row) + "\n" + json.dumps(retired) + "\n",
                encoding="utf-8",
            )
            blinds_at = mod.last_walk_for_surface(
                mod.last_walk_by_surface(mod.load_coverage(cov)),
                "lesson-01-01-03-02-small-and-big-blind",
            )
            self.assertIsNotNone(blinds_at)

    def test_openlesson_seeds_exist_in_catalog(self) -> None:
        """Every openlesson seed must resolve in assets/course/v2/catalog.json."""
        missing = mod.missing_openlesson_seeds()
        self.assertEqual(
            missing,
            [],
            f"stale motion-target openlesson seeds: {missing}",
        )
        self.assertEqual(mod.main(["check-seeds"]), 0)
        by_id = {t.id: t for t in mod.TARGETS}
        self.assertEqual(
            by_id["multi-press-best-five"].surface,
            "lesson-01-02-02-01-best-five",
        )
        self.assertEqual(
            by_id["deal-blinds-button"].surface,
            "lesson-01-01-03-02-small-and-big-blind",
        )

    def test_lead_ok_credits_motion_without_surface(self) -> None:
        """Densify surface + lead OK list demotes those motion ids in pick."""
        self.assertTrue(
            mod.lead_credits_motion(
                "coach-transition / SoftPulse-breathe / lesson-result / "
                "deal-your-two OK on walk",
                "coach-transition",
            )
        )
        self.assertTrue(
            mod.lead_credits_motion(
                "coach-transition / SoftPulse-breathe OK on walk",
                "softpulse-breathe",
            )
        )
        self.assertTrue(
            mod.lead_credits_motion(
                "discovery: suits multi-press SoftPulse OK; hearts-0 SoftPulse "
                "gate OK",
                "multi-press-suits",
            )
        )
        self.assertTrue(
            mod.lead_credits_motion(
                "deal-blinds SB→BB SoftPulse OK on small-and-big-blind",
                "deal-blinds-button",
            )
        )
        self.assertTrue(
            mod.lead_credits_motion(
                "deal blinds SoftPulse OK on walk",
                "deal-blinds-button",
            )
        )
        self.assertTrue(
            mod.lead_credits_motion(
                "your two cards deal SoftPulse OK on walk",
                "deal-your-two-cards",
            )
        )
        # LPT-1027 wrote "pot-stacks OK" without the "and".
        self.assertTrue(
            mod.lead_credits_motion(
                "section-end SoftPulse breathe pot-stacks OK on walk",
                "pot-and-stacks",
            )
        )
        self.assertTrue(
            mod.lead_credits_motion(
                "pot - stacks OK on walk",
                "pot-and-stacks",
            )
        )
        self.assertTrue(
            mod.lead_credits_motion(
                "discovery: suits multi-press SoftPulse OK; hearts-0 SoftPulse "
                "gate OK",
                "hearts-breathe",
            )
        )
        self.assertFalse(
            mod.lead_credits_motion(
                "motion pick remaining: hearts-breathe, lesson-result-ceremony, "
                "section-end-ceremony",
                "hearts-breathe",
            )
        )
        self.assertTrue(
            mod.lead_credits_motion(
                "motion pick remaining: coach-transition OK on barrel; "
                "hearts-breathe / lesson-result still under-walked",
                "coach-transition",
            )
        )
        self.assertFalse(
            mod.lead_credits_motion(
                "motion pick remaining: coach-transition OK on barrel; "
                "hearts-breathe / lesson-result still under-walked",
                "hearts-breathe",
            )
        )
        with tempfile.TemporaryDirectory() as tmp:
            cov = Path(tmp) / "coverage.jsonl"
            row = {
                "at": datetime(2026, 10, 16, tzinfo=timezone.utc).isoformat(),
                "surface": "lesson-01-01-01-your-two-cards",
                "result": "closed",
                "ticket": "LPT-1026",
                "leads": [
                    "coach-transition / softpulse-breathe OK on walk",
                    "motion pick remaining: hearts-breathe, "
                    "lesson-result-ceremony, section-end-ceremony",
                ],
            }
            cov.write_text(json.dumps(row) + "\n", encoding="utf-8")
            picked = mod.pick_targets(coverage_path=cov, limit=5)
            ids = [t.id for t in picked]
            self.assertNotIn("coach-transition", ids[:3])
            self.assertNotIn("softpulse-breathe", ids[:3])
            self.assertIn("hearts-breathe", ids)

    def test_cli_list(self) -> None:
        code = mod.main(["list"])
        self.assertEqual(code, 0)

    def test_cli_classes(self) -> None:
        self.assertEqual(mod.main(["classes"]), 0)


if __name__ == "__main__":
    unittest.main()
