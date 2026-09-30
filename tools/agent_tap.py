#!/usr/bin/env python3
"""Drive the debug app via ext.poker.agent (tap / openlesson / type).

The default log is the iPhone 17 Pro session. /implement-open-jira
passes --log for the iPhone 17 session so the two roles do not tap each
other's app.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

QA_LOG = Path("/tmp/flutter-live-poker-trainer.run.log")
IMPLEMENT_LOG = Path("/tmp/flutter-live-poker-trainer-iphone17.run.log")
LOG = QA_LOG


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
    """CLI parser. The default log is the Pro session."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cmd", help="Agent command (tap, openlesson, type, ...)")
    parser.add_argument("--text", default="", help="Label/text for tap/type/openlesson")
    parser.add_argument(
        "--log",
        type=Path,
        default=QA_LOG,
        help=(
            "Flutter run log to read the Dart VM URI from. "
            f"Default {QA_LOG} (Pro). "
            f"/implement-open-jira uses {IMPLEMENT_LOG} or its worktree log."
        ),
    )
    return parser


def main(argv: list[str] | None = None) -> None:
    """CLI entrypoint."""
    args = build_parser().parse_args(argv)
    extra = {"text": args.text} if args.text else {}
    agent(args.cmd, log=args.log, **extra)


if __name__ == "__main__":
    main(sys.argv[1:])
