#!/usr/bin/env python3
"""Flutter run-log readiness: ignore stale Dart VM URIs.

A hot-restart or cold re-launch can leave an older ``http://127.0.0.1:…``
line in the log while the process is stuck on ``Launching…`` / Xcode build.
Callers must only treat the log as ready when a VM URI (or
``Restarted application in``) appears *after* the latest Launching line.

When ``<log>.prebuilt`` exists, the app was launched from a cached
``Runner.app`` (``tools/flutter_run_fast.sh``) and is still running the
bundled Dart until the first hot restart lands, so only
``Restarted application in`` after Launching counts.
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


def _last(pattern: re.Pattern[str], text: str) -> int:
    """Offset of the last [pattern] match in [text], or -1."""
    last = -1
    for match in pattern.finditer(text):
        last = match.start()
    return last


def log_is_ready(text: str, *, require_restart: bool = False) -> bool:
    """Return True when the log shows a post-Launching ready signal."""
    last_launch = _last(_LAUNCHING, text)
    if _last(_RESTARTED, text) > last_launch:
        return True
    if require_restart:
        return False
    return _last(_VM_URI, text) > last_launch


def prebuilt_marker(log: Path) -> Path:
    """Sidecar that marks a prebuilt launch still waiting on hot restart."""
    return log.with_name(log.name + ".prebuilt")


def main(argv: list[str]) -> int:
    """CLI: exit 0 when ready, 1 when not, 2 on usage/IO errors."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", type=Path, help="flutter run log path")
    parser.add_argument(
        "--vm-only",
        action="store_true",
        help="Ignore the .prebuilt sidecar (a fresh VM URI is enough).",
    )
    args = parser.parse_args(argv)
    try:
        text = args.log.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(f"flutter_log_ready: {exc}", file=sys.stderr)
        return 2
    require_restart = (
        not args.vm_only and prebuilt_marker(args.log).exists()
    )
    return 0 if log_is_ready(text, require_restart=require_restart) else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
