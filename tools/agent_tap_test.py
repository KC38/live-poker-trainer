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

    def test_default_log_is_the_mini_session(self) -> None:
        args = agent_tap.build_parser().parse_args(["tap", "--text", "Continue"])
        self.assertEqual(args.log, agent_tap.DEFAULT_LOG)
        self.assertEqual(
            agent_tap.DEFAULT_LOG,
            Path("/tmp/flutter-live-poker-trainer.run.log"),
        )

    def test_log_flag_overrides_default(self) -> None:
        worktree = Path("/tmp/flutter-LPT-12.log")
        args = agent_tap.build_parser().parse_args(
            ["tap", "--log", str(worktree), "--text", "Fold"]
        )
        self.assertEqual(args.log, worktree)

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


if __name__ == "__main__":
    unittest.main()
