"""Tests that agent_tap reads the log for the simulator it was asked to drive."""

from __future__ import annotations

import importlib.util
import tempfile
import types
import unittest
from pathlib import Path


def _load_agent_tap() -> types.ModuleType:
    """Load tools/agent_tap.py without installing it as a package."""
    path = Path(__file__).with_name("agent_tap.py")
    spec = importlib.util.spec_from_file_location("agent_tap", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


agent_tap = _load_agent_tap()


class AgentTapLogTest(unittest.TestCase):
    """Log selection defaults to the iPhone 13 mini session."""

    def test_default_log_follows_active_pointer(self) -> None:
        args = agent_tap.build_parser().parse_args(["tap", "--text", "Continue"])
        self.assertIsNone(args.log)
        self.assertEqual(
            agent_tap.DEFAULT_LOG,
            Path("/tmp/flutter-iphone-13-mini.active.log"),
        )
        self.assertEqual(
            agent_tap.PRIMARY_LOG,
            Path("/tmp/flutter-live-poker-trainer.run.log"),
        )

    def test_log_flag_overrides_default(self) -> None:
        worktree = Path("/tmp/flutter-LPT-12.log")
        args = agent_tap.build_parser().parse_args(
            ["tap", "--log", str(worktree), "--text", "Fold"]
        )
        self.assertEqual(args.log, worktree)

    def test_resolve_log_prefers_explicit_path(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            worktree = Path(tmp) / "flutter-LPT-12.log"
            worktree.write_text("vm\n", encoding="utf-8")
            self.assertEqual(agent_tap.resolve_log(worktree), worktree)

    def test_vm_base_uses_the_log_it_is_given(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            default_log = Path(tmp) / "mini.log"
            other_log = Path(tmp) / "worktree.log"
            default_log.write_text(
                "A Dart VM Service on iPhone 13 mini is available at: "
                "http://127.0.0.1:1111/miniToken/\n",
                encoding="utf-8",
            )
            other_log.write_text(
                "A Dart VM Service on iPhone 13 mini is available at: "
                "http://127.0.0.1:2222/workToken/\n",
                encoding="utf-8",
            )
            self.assertEqual(agent_tap.vm_base(default_log), ("1111", "miniToken"))
            self.assertEqual(agent_tap.vm_base(other_log), ("2222", "workToken"))

    def test_vm_base_prefers_the_newest_uri(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            log = Path(tmp) / "relaunch.log"
            log.write_text(
                "at: http://127.0.0.1:1111/old=/\n"
                "Launching lib/main.dart ...\n"
                "at: http://127.0.0.1:2222/new=/\n",
                encoding="utf-8",
            )
            self.assertEqual(agent_tap.vm_base(log), ("2222", "new="))


class AgentTapTreeTest(unittest.TestCase):
    """The tree printout names tap state and glow per label."""

    def test_format_tree(self) -> None:
        text = agent_tap.format_tree(
            {
                "screen": "LessonRunnerScreen",
                "size": [375, 812],
                "gold": ["A♠"],
                "entries": [
                    {"label": "A♠", "rect": [10, 20, 40, 60], "tap": None, "glow": "gold"},
                    {
                        "label": "HINT",
                        "rect": [0, 700, 80, 44],
                        "tap": "disabled",
                        "glow": None,
                        "key": "lesson-hint",
                    },
                ],
            }
        )
        self.assertIn("screen: LessonRunnerScreen", text)
        self.assertIn("gold SoftPulse: A♠", text)
        self.assertIn("'A♠' [gold]", text)
        self.assertIn("'HINT' [disabled key=lesson-hint]", text)


class AgentTapWaitGoldTest(unittest.TestCase):
    """wait-gold polls tree until SoftPulse appears."""

    def test_gold_ready_matches_needle(self) -> None:
        tree = {"gold": ["BLINDS", "You"]}
        self.assertTrue(agent_tap.gold_ready(tree))
        self.assertTrue(agent_tap.gold_ready(tree, "blind"))
        self.assertFalse(agent_tap.gold_ready(tree, "Fold"))
        self.assertFalse(agent_tap.gold_ready({"gold": []}))

    def test_wait_gold_returns_when_ready(self) -> None:
        states = [{"gold": []}, {"gold": ["BTN"]}]
        tree = agent_tap.wait_gold(
            timeout=2.0,
            poll=0.01,
            tree_fn=lambda: states.pop(0) if states else {"gold": ["BTN"]},
        )
        self.assertEqual(tree["gold"], ["BTN"])

    def test_wait_gold_times_out(self) -> None:
        with self.assertRaises(SystemExit) as ctx:
            agent_tap.wait_gold(
                timeout=0.05,
                poll=0.01,
                text="Fold",
                tree_fn=lambda: {"gold": ["BTN"]},
            )
        self.assertIn("no gold SoftPulse", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
