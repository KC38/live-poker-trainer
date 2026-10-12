#!/usr/bin/env python3
"""Drive the debug app via ext.poker.agent (tap / openlesson / type / tree).

The default log follows the mini's **active** flutter session
(`/tmp/flutter-iphone-13-mini.active.log`, set by `flutter_run_fast.sh` /
`flutter_hot_restart.sh`). Ticket worktrees no longer need
`--log /tmp/flutter-$SLUG.log` unless you override. Falls back to the
primary checkout log when no active pointer exists.

UI commands (`tap`, `openlesson`, `type`, `back`) wait for the app's
`last` outcome and print it. A tap that matched nothing exits 3, so a
wrong needle is visible without a screenshot.

Queries answer directly:
  * `tree` — visible labels top-to-bottom with `[enabled]`/`[disabled]`
    tap state and `gold` (SoftPulse cue) / `cyan` (selection) glow.
    Add `--json` for the raw payload.
  * `whoami` — Firebase uid + anonymous flag (used by tools/agent_seed.py).

Only the holder of the simulator lock (`tools/sim_lock.py`) may drive the
mini. Pass the run id with `--run-id` or `$SIM_LOCK_RUN_ID`.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import sys
import time
import types
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any


def _load_module(name: str) -> types.ModuleType:
    """Load a sibling tools/*.py module."""
    path = Path(__file__).with_name(f"{name}.py")
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


sim_lock = _load_module("sim_lock")
flutter_active_log = _load_module("flutter_active_log")

DEFAULT_LOG = flutter_active_log.ACTIVE_LINK
PRIMARY_LOG = flutter_active_log.PRIMARY_LOG
# Back-compat alias for older callers/tests.
QA_LOG = PRIMARY_LOG
LOG = DEFAULT_LOG

QUERIES = {"tree", "whoami", "last"}
UI_COMMANDS = ("tap", "taptext", "openlesson", "open_lesson", "type", "enter", "back")
EXIT_NOMATCH = 3


def resolve_log(log: Path | None = None) -> Path:
    """Resolve the flutter log (active pointer, env, or primary)."""
    return flutter_active_log.resolve(log)


def vm_base(log: Path | None = None) -> tuple[str, str]:
    """Return (port, token) from a Flutter run log."""
    path = resolve_log(log)
    text = path.read_bytes().replace(b"\x00", b"").decode("utf-8", "replace")
    # Last URI: a relaunch appends a new VM service after the old one.
    matches = re.findall(r"http://127\.0\.0\.1:(\d+)/([A-Za-z0-9_\-=]+)/", text)
    if not matches:
        raise SystemExit(f"No Dart VM URI in {path} yet")
    return matches[-1]


def isolate_id(port: str, token: str) -> str:
    """Pick the main isolate id."""
    with urllib.request.urlopen(f"http://127.0.0.1:{port}/{token}/getVM") as resp:
        payload = json.load(resp)
    isolates = payload["result"]["isolates"]
    for isolate in isolates:
        if "main" in isolate.get("name", "").lower():
            return isolate["id"]
    return isolates[0]["id"]


def call(cmd: str, log: Path | None = None, **extra: str) -> dict[str, Any]:
    """Invoke ext.poker.agent and return its decoded result object."""
    port, token = vm_base(log)
    iso = isolate_id(port, token)
    query = urllib.parse.urlencode({"isolateId": iso, "cmd": cmd, **extra})
    url = f"http://127.0.0.1:{port}/{token}/ext.poker.agent?{query}"
    with urllib.request.urlopen(url) as resp:
        payload = json.load(resp)
    if "error" in payload:
        raise SystemExit(f"agent_tap: {cmd} failed: {payload['error']}")
    return payload.get("result", {})


def query(name: str, log: Path | None = None) -> Any:
    """Run a read-only agent query (`tree`, `whoami`, `last`)."""
    return call(name, log=log).get("result")


def agent(cmd: str, log: Path | None = None, **extra: str) -> None:
    """Invoke ext.poker.agent with cmd (+ optional text/label)."""
    result = call(cmd, log=log, **extra)
    print(cmd, extra or "", "->", json.dumps(result))


def last_outcome(log: Path | None = None) -> dict[str, Any] | None:
    """The driver's `last` outcome, or None on builds without the query."""
    try:
        return query("last", log=log) or {}
    except SystemExit:
        return None


def wait_outcome(
    before: int, log: Path | None = None, timeout: float = 3.0
) -> dict[str, Any] | None:
    """Poll `last` until the driver records a command after [before]."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        last = last_outcome(log=log)
        if last is None:
            return None
        if int(last.get("seq", 0)) > before:
            return last
        time.sleep(0.1)
    return None


def format_tree(tree: dict[str, Any]) -> str:
    """Render the `tree` payload as one line per visible label."""
    lines = [
        f"screen: {tree.get('screen') or '?'}  size: {tree.get('size')}",
        f"gold SoftPulse: {', '.join(tree.get('gold') or []) or 'none'}",
    ]
    for entry in tree.get("entries", []):
        x, y, w, h = entry["rect"]
        tags = []
        if entry.get("tap"):
            tags.append(entry["tap"])
        if entry.get("glow"):
            tags.append(entry["glow"])
        if entry.get("key"):
            tags.append(f"key={entry['key']}")
        tag = f" [{' '.join(tags)}]" if tags else ""
        lines.append(f"  ({x},{y} {w}x{h}) {entry['label']!r}{tag}")
    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    """CLI parser. The default log is the iPhone 13 mini session."""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "cmd", help="Agent command (tap, openlesson, type, back, tree, whoami, ...)"
    )
    parser.add_argument("--text", default="", help="Label/text for tap/type/openlesson")
    parser.add_argument(
        "--log",
        type=Path,
        default=None,
        help=(
            "Flutter run log to read the Dart VM URI from. "
            f"Default: active mini session ({DEFAULT_LOG}) or "
            f"{PRIMARY_LOG}."
        ),
    )
    parser.add_argument(
        "--run-id",
        default=None,
        help="Simulator lock run id. Default $SIM_LOCK_RUN_ID.",
    )
    parser.add_argument("--json", action="store_true", help="Raw JSON for queries")
    return parser


def main(argv: list[str] | None = None) -> int:
    """CLI entrypoint. Refuses unless this run holds the simulator lock."""
    args = build_parser().parse_args(argv)
    log = resolve_log(args.log)
    lock_args = ["guard"] + (["--run-id", args.run_id] if args.run_id else [])
    if sim_lock.main(lock_args) != sim_lock.EXIT_OK:
        raise SystemExit("agent_tap: the iPhone 13 mini lock is not yours (tools/sim_lock.py status)")
    cmd = args.cmd.strip().lower()
    if cmd in QUERIES:
        result = query(cmd, log=log)
        if cmd == "tree" and not args.json:
            print(format_tree(result or {}))
        else:
            print(json.dumps(result, indent=2, ensure_ascii=False))
        return 0
    extra = {"text": args.text} if args.text else {}
    before = int((last_outcome(log=log) or {}).get("seq", 0))
    agent(cmd, log=log, **extra)
    if not cmd.startswith(UI_COMMANDS):
        return 0
    outcome = wait_outcome(before, log=log)
    if outcome is None:
        print("outcome: (no driver outcome within 3 s)")
        return 0
    print(f"outcome: {outcome.get('outcome')}")
    return EXIT_NOMATCH if str(outcome.get("outcome", "")).startswith("nomatch") else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
