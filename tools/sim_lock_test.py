"""Tests that only one agent at a time can hold the iPhone 13 mini."""

from __future__ import annotations

import importlib.util
import io
import json
import os
import subprocess
import sys
import tempfile
import time
import types
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from unittest import mock


def _load(name: str) -> types.ModuleType:
    """Load a sibling tools/*.py file without installing it as a package."""
    path = Path(__file__).with_name(f"{name}.py")
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


sim_lock = _load("sim_lock")


class SimLockTest(unittest.TestCase):
    """Claim, busy, heartbeat, stale takeover, and release."""

    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self._env = mock.patch.dict(
            os.environ, {"SIM_LOCK_DIR": self._tmp.name}, clear=False
        )
        self._env.start()
        os.environ.pop("SIM_LOCK_RUN_ID", None)
        os.environ.pop("SIM_LOCK_PID", None)

    def tearDown(self) -> None:
        self._env.stop()
        self._tmp.cleanup()

    def _run(self, *argv: str) -> tuple[int, str, str]:
        out, err = io.StringIO(), io.StringIO()
        with redirect_stdout(out), redirect_stderr(err):
            code = sim_lock.main(list(argv))
        return code, out.getvalue(), err.getvalue()

    def test_missing_file_is_free(self) -> None:
        code, out, _ = self._run("status")
        self.assertEqual(code, sim_lock.EXIT_OK)
        self.assertIn("FREE", out)

    def test_second_claim_is_refused_while_first_is_live(self) -> None:
        code, run_id, _ = self._run("claim", "--owner", "ui-design-agent", "--purpose", "walk Home")
        self.assertEqual(code, sim_lock.EXIT_OK)
        self.assertTrue(run_id.strip().startswith("ui-design-agent-"))

        code, out, err = self._run("claim", "--owner", "other-agent")
        self.assertEqual(code, sim_lock.EXIT_BUSY)
        self.assertEqual(out, "")
        self.assertIn("ui-design-agent", err)
        self.assertIn("walk Home", err)

        code, _, _ = self._run("status")
        self.assertEqual(code, sim_lock.EXIT_BUSY)

    def test_guard_passes_only_for_the_holder(self) -> None:
        _, run_id, _ = self._run("claim", "--owner", "a")
        run_id = run_id.strip()
        self.assertEqual(self._run("guard", "--run-id", run_id)[0], sim_lock.EXIT_OK)
        self.assertEqual(self._run("guard", "--run-id", "someone-else")[0], sim_lock.EXIT_BUSY)
        with mock.patch.dict(os.environ, {"SIM_LOCK_RUN_ID": run_id}):
            self.assertEqual(self._run("guard")[0], sim_lock.EXIT_OK)

    def test_guard_on_a_free_lock_says_claim_first(self) -> None:
        code, _, err = self._run("guard", "--run-id", "nobody")
        self.assertEqual(code, sim_lock.EXIT_NOT_HOLDER)
        self.assertIn("Claim it first", err)

    def test_only_the_holder_releases_without_force(self) -> None:
        _, run_id, _ = self._run("claim", "--owner", "a")
        run_id = run_id.strip()
        self.assertEqual(self._run("release", "--run-id", "intruder")[0], sim_lock.EXIT_BUSY)
        self.assertEqual(self._run("release", "--run-id", run_id)[0], sim_lock.EXIT_OK)
        state = sim_lock.read_state()
        self.assertEqual(state["state"], "free")
        self.assertEqual(state["last"]["run_id"], run_id)

    def test_force_release_frees_any_holder(self) -> None:
        self._run("claim", "--owner", "a")
        self.assertEqual(self._run("release", "--force")[0], sim_lock.EXIT_OK)
        self.assertEqual(sim_lock.read_state()["state"], "free")

    def test_if_pid_frees_only_that_pids_lock(self) -> None:
        self._run("claim", "--owner", "a", "--pid", str(os.getpid()))
        self.assertEqual(self._run("release", "--if-pid", "1")[0], sim_lock.EXIT_OK)
        self.assertEqual(sim_lock.read_state()["state"], "in_use")
        self._run("release", "--if-pid", str(os.getpid()))
        self.assertEqual(sim_lock.read_state()["state"], "free")

    def test_dead_pid_makes_the_lock_claimable(self) -> None:
        proc = subprocess.Popen([sys.executable, "-c", "pass"])
        proc.wait()
        self._run("claim", "--owner", "crashed", "--pid", str(proc.pid))
        code, run_id, _ = self._run("claim", "--owner", "next")
        self.assertEqual(code, sim_lock.EXIT_OK)
        self.assertTrue(run_id.startswith("next-"))
        history = Path(self._tmp.name, "simulator-lock.log").read_text(encoding="utf-8")
        self.assertIn("stale-cleared", history)

    def test_missed_heartbeat_makes_the_lock_claimable(self) -> None:
        self._run("claim", "--owner", "slow", "--ttl", "60")
        path = Path(self._tmp.name, "simulator-lock.json")
        state = json.loads(path.read_text(encoding="utf-8"))
        state["heartbeat_epoch"] = time.time() - 120
        path.write_text(json.dumps(state), encoding="utf-8")
        self.assertEqual(self._run("status")[0], sim_lock.EXIT_OK)
        self.assertEqual(self._run("claim", "--owner", "next")[0], sim_lock.EXIT_OK)

    def test_heartbeat_keeps_a_lock_alive(self) -> None:
        _, run_id, _ = self._run("claim", "--owner", "a", "--ttl", "60")
        run_id = run_id.strip()
        path = Path(self._tmp.name, "simulator-lock.json")
        state = json.loads(path.read_text(encoding="utf-8"))
        state["heartbeat_epoch"] = time.time() - 50
        path.write_text(json.dumps(state), encoding="utf-8")
        code, _, _ = self._run("heartbeat", "--run-id", run_id, "--purpose", "LPT-41 validate")
        self.assertEqual(code, sim_lock.EXIT_OK)
        fresh = sim_lock.read_state()
        self.assertGreater(fresh["heartbeat_epoch"], time.time() - 5)
        self.assertEqual(fresh["purpose"], "LPT-41 validate")

    def test_claim_reads_pid_from_env(self) -> None:
        with mock.patch.dict(os.environ, {"SIM_LOCK_PID": str(os.getpid())}):
            self._run("claim", "--owner", "loop")
        self.assertEqual(sim_lock.read_state()["pid"], os.getpid())


class AgentTapLockTest(unittest.TestCase):
    """agent_tap refuses to drive the mini without holding the lock."""

    def test_agent_tap_refuses_when_another_run_holds_the_mini(self) -> None:
        agent_tap = _load("agent_tap")
        with tempfile.TemporaryDirectory() as tmp, mock.patch.dict(
            os.environ, {"SIM_LOCK_DIR": tmp, "SIM_LOCK_RUN_ID": "mine"}
        ):
            agent_tap.sim_lock.claim("someone-else")
            with mock.patch.object(agent_tap, "agent") as fake, redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit):
                    agent_tap.main(["tap", "--text", "Continue"])
                fake.assert_not_called()

    def test_agent_tap_drives_the_mini_for_the_holder(self) -> None:
        agent_tap = _load("agent_tap")
        with tempfile.TemporaryDirectory() as tmp, mock.patch.dict(
            os.environ, {"SIM_LOCK_DIR": tmp}
        ):
            _, state = agent_tap.sim_lock.claim("me")
            with mock.patch.dict(os.environ, {"SIM_LOCK_RUN_ID": state["run_id"]}):
                with mock.patch.object(agent_tap, "agent") as fake:
                    agent_tap.main(["tap", "--text", "Continue"])
                fake.assert_called_once()


if __name__ == "__main__":
    unittest.main()
