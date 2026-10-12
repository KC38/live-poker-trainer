#!/usr/bin/env python3
"""Point agent tools at the iPhone 13 mini's current flutter run log.

Worktree sessions write ``/tmp/flutter-$SLUG.log`` while the primary
checkout uses ``/tmp/flutter-live-poker-trainer.run.log``. Agents that
forget ``--log`` used to hit the wrong VM (LPT-78). ``set_active`` keeps a
symlink + path file on the mini's latest session; ``resolve`` prefers that
over the primary default.
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

ACTIVE_LINK = Path("/tmp/flutter-iphone-13-mini.active.log")
PRIMARY_LOG = Path("/tmp/flutter-live-poker-trainer.run.log")
STATE_PATH = Path.home() / ".live-poker-trainer/flutter-mini-active.logpath"


def set_active(log: Path) -> Path:
    """Record [log] as the mini's active flutter run log. Returns resolved path."""
    resolved = log.expanduser().resolve()
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(f"{resolved}\n", encoding="utf-8")
    if ACTIVE_LINK.is_symlink() or ACTIVE_LINK.exists():
        ACTIVE_LINK.unlink()
    ACTIVE_LINK.symlink_to(resolved)
    return resolved


def resolve(explicit: Path | None = None) -> Path:
    """Pick the flutter log to read the Dart VM URI from.

    Order: explicit path when it exists (or is a live symlink); else the
    active pointer; else ``$FLUTTER_RUN_LOG``; else the primary checkout log.
    """
    if explicit is not None:
        path = explicit.expanduser()
        if path.exists():
            return path.resolve() if path.is_symlink() else path
    if ACTIVE_LINK.exists():
        return ACTIVE_LINK.resolve()
    if STATE_PATH.is_file():
        candidate = Path(STATE_PATH.read_text(encoding="utf-8").strip())
        if candidate.is_file():
            return candidate
    env = os.environ.get("FLUTTER_RUN_LOG", "").strip()
    if env:
        env_path = Path(env).expanduser()
        if env_path.exists():
            return env_path
    return PRIMARY_LOG


def main(argv: list[str] | None = None) -> int:
    """CLI: ``set <log>`` or ``resolve [--log PATH]``."""
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)
    set_p = sub.add_parser("set", help="Mark a log as the mini's active session")
    set_p.add_argument("log", type=Path)
    res_p = sub.add_parser("resolve", help="Print the log path agent tools should use")
    res_p.add_argument("--log", type=Path, default=None)
    args = parser.parse_args(argv)
    if args.cmd == "set":
        print(set_active(args.log))
        return 0
    print(resolve(args.log))
    return 0


if __name__ == "__main__":
    sys.exit(main())
