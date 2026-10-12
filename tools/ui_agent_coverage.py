#!/usr/bin/env python3
"""Append / inspect ui-design-agent coverage ledger rows.

Agents used to hand-write ``at`` with ``strftime(..., '%z')``, which emits
compact offsets like ``+0530``. macOS Python 3.9 ``fromisoformat`` rejects
those, so health repair missed tickets (LPT-490/492). This helper always
writes ``datetime.isoformat`` (``+05:30``) and validates required fields.

Usage::

    python3 tools/ui_agent_coverage.py append \\
      --sha <sha> --surface lesson-runner:foo --result closed \\
      --ticket LPT-503 --learnings unchanged \\
      --lead 'LPT-504 SoftPulse next' --lead 'LPT-44 needs-human'
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

DEFAULT_PATH = Path.home() / ".live-poker-trainer" / "ui-agent-coverage.jsonl"
# Compact ±HHMM (no colon) — macOS Python 3.9 fromisoformat rejects these.
_COMPACT_OFFSET = re.compile(r"[+-]\d{4}$")

VALID_RESULTS = frozenset(
    {
        "closed",
        "needs-human",
        "clean",
        "unreachable",
        "blocked",
        "sim-not-ready",
        "jira-unavailable",
        "usage-limit",
        "stalled",
    }
)
VALID_LEARNINGS = frozenset({"updated", "pending", "unchanged"})


def coverage_path(override: Optional[str] = None) -> Path:
    """Resolve the coverage JSONL path (env UI_AGENT_COVERAGE_FILE wins)."""
    if override:
        return Path(override).expanduser()
    env = os.environ.get("UI_AGENT_COVERAGE_FILE", "").strip()
    if env:
        return Path(env).expanduser()
    return DEFAULT_PATH


def now_iso() -> str:
    """Local ISO-8601 timestamp with a colon in the offset (``+05:30``)."""
    return datetime.now().astimezone().isoformat(timespec="seconds")


def build_row(
    *,
    sha: str,
    surface: str,
    result: str,
    ticket: str,
    learnings: str,
    leads: Optional[List[str]] = None,
    at: Optional[str] = None,
) -> Dict[str, Any]:
    """Build a validated coverage row dict."""
    sha = (sha or "").strip()
    surface = (surface or "").strip()
    result = (result or "").strip()
    ticket = (ticket or "").strip()
    learnings = (learnings or "").strip()
    if not sha:
        raise ValueError("sha is required")
    if not surface:
        raise ValueError("surface is required")
    if result not in VALID_RESULTS:
        raise ValueError(
            f"result must be one of {sorted(VALID_RESULTS)}; got {result!r}"
        )
    if not ticket:
        raise ValueError("ticket is required")
    if learnings not in VALID_LEARNINGS:
        raise ValueError(
            f"learnings must be one of {sorted(VALID_LEARNINGS)}; "
            f"got {learnings!r}"
        )
    stamp = (at or now_iso()).strip()
    # Reject compact ±HHMM so we never re-introduce the parse miss.
    if _COMPACT_OFFSET.search(stamp) and ":" not in stamp[-6:]:
        raise ValueError(
            f"at must use a colon in the offset (+05:30), not compact form: {stamp}"
        )
    return {
        "at": stamp,
        "sha": sha,
        "surface": surface,
        "result": result,
        "ticket": ticket,
        "leads": list(leads or []),
        "learnings": learnings,
    }


def append_row(path: Path, row: Dict[str, Any]) -> None:
    """Append one JSONL coverage row, creating the parent dir if needed."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(row, ensure_ascii=False) + "\n")


def cmd_append(args: argparse.Namespace) -> int:
    """CLI: append one coverage row and print it."""
    row = build_row(
        sha=args.sha,
        surface=args.surface,
        result=args.result,
        ticket=args.ticket,
        learnings=args.learnings,
        leads=args.lead,
        at=args.at,
    )
    path = coverage_path(args.file)
    append_row(path, row)
    print(json.dumps(row, ensure_ascii=False))
    print(f"appended → {path}", file=sys.stderr)
    return 0


def main(argv: Optional[List[str]] = None) -> int:
    """Parse argv and run a subcommand."""
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    append_p = sub.add_parser("append", help="append one coverage ledger row")
    append_p.add_argument(
        "--file",
        default=None,
        help="coverage JSONL path (default: ~/.live-poker-trainer/…)",
    )
    append_p.add_argument("--sha", required=True)
    append_p.add_argument("--surface", required=True)
    append_p.add_argument("--result", required=True)
    append_p.add_argument("--ticket", required=True)
    append_p.add_argument(
        "--learnings",
        required=True,
        choices=sorted(VALID_LEARNINGS),
    )
    append_p.add_argument(
        "--lead",
        action="append",
        default=[],
        help="lead line (repeatable)",
    )
    append_p.add_argument(
        "--at",
        default=None,
        help="override ISO timestamp (tests only; must include : in offset)",
    )
    append_p.set_defaults(func=cmd_append)

    args = parser.parse_args(argv)
    try:
        return int(args.func(args))
    except ValueError as exc:
        print(f"ui_agent_coverage: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
