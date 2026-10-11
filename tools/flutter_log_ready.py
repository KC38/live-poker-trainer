#!/usr/bin/env python3
"""Flutter run-log readiness: ignore stale Dart VM URIs.

A hot-restart or cold re-launch can leave an older ``http://127.0.0.1:…``
line in the log while the process is stuck on ``Launching…`` / Xcode build.
Callers must only treat the log as ready when a VM URI (or
``Restarted application in``) appears *after* the latest Launching line.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

_LAUNCHING = re.compile(
    r"Launching lib/main\.dart|Launching…|Launching\.\.\."
)
_RESTARTED = re.compile(r"Restarted application in")
_VM_URI = re.compile(r"http://127\.0\.0\.1:[0-9]+/[A-Za-z0-9_=-]+/")


def log_is_ready(text: str) -> bool:
    """Return True when the log shows a post-Launching ready signal."""
    last_launch = -1
    for match in _LAUNCHING.finditer(text):
        last_launch = match.start()
    last_restarted = -1
    for match in _RESTARTED.finditer(text):
        last_restarted = match.start()
    last_uri = -1
    for match in _VM_URI.finditer(text):
        last_uri = match.start()
    if last_restarted > last_launch:
        return True
    if last_uri > last_launch:
        return True
    return False


def main(argv: list[str]) -> int:
    """CLI: exit 0 when ready, 1 when not, 2 on usage/IO errors."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", type=Path, help="flutter run log path")
    args = parser.parse_args(argv)
    try:
        text = args.log.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(f"flutter_log_ready: {exc}", file=sys.stderr)
        return 2
    return 0 if log_is_ready(text) else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
