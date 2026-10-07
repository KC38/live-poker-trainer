#!/usr/bin/env python3
"""Drive the debug app via ext.poker.agent (tap / openlesson / type).

The default log is the iPhone 13 mini session
(`/tmp/flutter-live-poker-trainer.run.log`). Ticket worktree sessions pass
`--log /tmp/flutter-$SLUG.log`.

Only the holder of the simulator lock (`tools/sim_lock.py`) may drive the
mini. Pass the run id with `--run-id` or `$SIM_LOCK_RUN_ID`.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import sys
import types
import urllib.parse
import urllib.request
from pathlib import Path


def _load_sim_lock() -> types.ModuleType:
    """Load the sibling sim_lock.py whether or not tools/ is a package."""
    path = Path(__file__).with_name("sim_lock.py")
    spec = importlib.util.spec_from_file_location("sim_lock", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


sim_lock = _load_sim_lock()

DEFAULT_LOG = Path("/tmp/flutter-live-poker-trainer.run.log")
# Back-compat alias for older callers/tests.
QA_LOG = DEFAULT_LOG
LOG = DEFAULT_LOG


def vm_base(log: Path | None = None) -> tuple[str, str]:
    """Return (port, token) from a Flutter run log."""
    path = LOG if log is None else log
    text = path.read_bytes().replace(b"\x00", b"").decode("utf-8", "replace")
    match = re.search(r"http://127\.0\.0\.1:(\d+)/([A-Za-z0-9_\-=]+)/", text)
    if not match:
        raise SystemExit(f"No Dart VM URI in {path} yet")
    return match.group(1), match.group(2)


def isolate_id(port: str, token: str) -> str:
    """Pick the main isolate id."""
    with urllib.request.urlopen(f"http://127.0.0.1:{port}/{token}/getVM") as resp:
        payload = json.load(resp)
    isolates = payload["result"]["isolates"]
    for isolate in isolates:
        if "main" in isolate.get("name", "").lower():
            return isolate["id"]
    return isolates[0]["id"]


def agent(cmd: str, log: Path | None = None, **extra: str) -> None:
    """Invoke ext.poker.agent with cmd (+ optional text/label)."""
    port, token = vm_base(log)
    iso = isolate_id(port, token)
    params = {"isolateId": iso, "cmd": cmd, **extra}
    query = urllib.parse.urlencode(params)
    url = f"http://127.0.0.1:{port}/{token}/ext.poker.agent?{query}"
    with urllib.request.urlopen(url) as resp:
        print(cmd, extra or "", "->", resp.read().decode())


def build_parser() -> argparse.ArgumentParser:
    """CLI parser. The default log is the iPhone 13 mini session."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cmd", help="Agent command (tap, openlesson, type, ...)")
    parser.add_argument("--text", default="", help="Label/text for tap/type/openlesson")
    parser.add_argument(
        "--log",
        type=Path,
        default=DEFAULT_LOG,
        help=(
            "Flutter run log to read the Dart VM URI from. "
            f"Default {DEFAULT_LOG} (iPhone 13 mini). "
            "Ticket worktrees pass /tmp/flutter-$SLUG.log."
        ),
    )
    parser.add_argument(
        "--run-id",
        default=None,
        help="Simulator lock run id. Default $SIM_LOCK_RUN_ID.",
    )
    return parser


def main(argv: list[str] | None = None) -> None:
    """CLI entrypoint. Refuses unless this run holds the simulator lock."""
    args = build_parser().parse_args(argv)
    lock_args = ["guard"] + (["--run-id", args.run_id] if args.run_id else [])
    if sim_lock.main(lock_args) != sim_lock.EXIT_OK:
        raise SystemExit("agent_tap: the iPhone 13 mini lock is not yours (tools/sim_lock.py status)")
    extra = {"text": args.text} if args.text else {}
    agent(args.cmd, log=args.log, **extra)


if __name__ == "__main__":
    main(sys.argv[1:])
