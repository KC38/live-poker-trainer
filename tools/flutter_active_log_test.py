"""Tests for the mini active flutter log pointer."""

from __future__ import annotations

import importlib.util
import os
import tempfile
import types
import unittest
from pathlib import Path
from unittest import mock


def _load() -> types.ModuleType:
    """Load tools/flutter_active_log.py."""
    path = Path(__file__).with_name("flutter_active_log.py")
    spec = importlib.util.spec_from_file_location("flutter_active_log", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


active = _load()


class FlutterActiveLogTest(unittest.TestCase):
    """set_active + resolve prefer the live worktree log."""

    def test_set_and_resolve(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp) / "home"
            home.mkdir()
            log = Path(tmp) / "flutter-LPT-12.log"
            log.write_text("vm\n", encoding="utf-8")
            link = Path(tmp) / "active.log"
            state = home / ".live-poker-trainer" / "flutter-mini-active.logpath"
            with mock.patch.object(active, "ACTIVE_LINK", link), mock.patch.object(
                active, "STATE_PATH", state
            ), mock.patch.object(active, "PRIMARY_LOG", Path(tmp) / "primary.log"):
                self.assertEqual(active.set_active(log), log.resolve())
                self.assertTrue(link.is_symlink())
                self.assertEqual(link.resolve(), log.resolve())
                self.assertEqual(active.resolve(), log.resolve())

    def test_resolve_falls_back_to_primary(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            primary = Path(tmp) / "primary.log"
            primary.write_text("primary\n", encoding="utf-8")
            missing_link = Path(tmp) / "missing-active.log"
            state = Path(tmp) / "no-state"
            with mock.patch.object(active, "ACTIVE_LINK", missing_link), mock.patch.object(
                active, "STATE_PATH", state
            ), mock.patch.object(active, "PRIMARY_LOG", primary), mock.patch.dict(
                os.environ, {}, clear=False
            ):
                os.environ.pop("FLUTTER_RUN_LOG", None)
                self.assertEqual(active.resolve(), primary)


if __name__ == "__main__":
    unittest.main()
