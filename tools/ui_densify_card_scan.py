#!/usr/bin/env python3
"""Scan SoftPulse densify stems for template card tokens (remap honesty).

``selectIdentifyDensifiedCoachLine`` often keeps template codes
(``Board Qc 7d 2s. You hold 5h 4h``) so ``alignLessonTableCopy`` can rewrite
them onto the remapped felt. When ``lessonFrameSpeech`` returns the stem
raw, idle coach names template cards while the felt shows isomorphic cards
(LPT-851 / LPT-806 class).

Commands:

  list                 Print densify activity ids whose stem embeds card codes.
  check [--id ID]      Exit 1 when any (or the given) stem still has codes —
                       discovery uses this before filing remap-honesty bugs.

Card token: rank ``2-9TJQKA`` + suit ``cdhs`` (case-insensitive), word-boundary.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = REPO / "lib" / "ui" / "course" / "widgets" / "rex_coach_line.dart"

# Board Ks 9d / You hold Kh Qh / Flop As 7d
_CARD_TOKEN = re.compile(r"\b([2-9TJQKA][cdhs])\b", re.IGNORECASE)
# Lone "as"/"ah" in English ("treated as") is not a deal — require deal context
# or ≥2 card codes before flagging (LPT-851 remap class).
_DEAL_CONTEXT = re.compile(
    r"(?i)\b(board|flop|turn|river|hold|holes|hero|you hold)\b",
)

# 'act-…' => 'stem…'  or  "act-…" => "stem…"
_ENTRY = re.compile(
    r"""['\"](?P<id>act-[^'\"]+)['\"]\s*=>\s*['\"](?P<stem>(?:\\.|[^'\\])*)['\"]""",
    re.DOTALL,
)


def parse_densify_stems(source: Path) -> dict[str, str]:
    """Parse activityId → densify stem from selectIdentifyDensifiedCoachLine."""
    text = source.read_text(encoding="utf-8")
    start = text.find("String? selectIdentifyDensifiedCoachLine")
    if start < 0:
        return {}
    # Bound to the function body; next top-level declaration is usually another
    # String / Widget / comment at column 0 after the closing brace.
    body = text[start:]
    end = body.find("\nString ")
    if end < 0:
        end = body.find("\nWidget ")
    if end > 0:
        body = body[:end]
    stems: dict[str, str] = {}
    for match in _ENTRY.finditer(body):
        activity_id = match.group("id")
        stem = match.group("stem").replace(r"\'", "'").replace(r"\n", "\n")
        stems[activity_id] = stem
    return stems


def card_tokens(stem: str) -> list[str]:
    """Unique deal card codes embedded in [stem] (lowercase).

    Ignores lone English lookalikes (``treated as``) unless the stem names a
    board/hold context or lists multiple codes.
    """
    found: list[str] = []
    seen: set[str] = set()
    for match in _CARD_TOKEN.finditer(stem):
        token = match.group(1).lower()
        if token not in seen:
            seen.add(token)
            found.append(token)
    if len(found) >= 2:
        return found
    if found and _DEAL_CONTEXT.search(stem):
        return found
    return []


def stems_with_cards(stems: dict[str, str]) -> list[tuple[str, list[str], str]]:
    """Rows of (activity_id, tokens, stem) for densify lines with card codes."""
    rows: list[tuple[str, list[str], str]] = []
    for activity_id, stem in sorted(stems.items()):
        tokens = card_tokens(stem)
        if tokens:
            rows.append((activity_id, tokens, stem))
    return rows


def cmd_list(args: argparse.Namespace) -> int:
    """Print densify stems that embed template card codes."""
    source = Path(args.source).expanduser()
    rows = stems_with_cards(parse_densify_stems(source))
    print("id\ttokens\tstem")
    for activity_id, tokens, stem in rows:
        compact = stem.replace("\n", " ")
        print(f"{activity_id}\t{','.join(tokens)}\t{compact}")
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    """Exit 1 when densify stems still embed card tokens (remap risk)."""
    source = Path(args.source).expanduser()
    rows = stems_with_cards(parse_densify_stems(source))
    if args.id:
        rows = [r for r in rows if r[0] == args.id]
        if not rows and args.id not in parse_densify_stems(source):
            print(f"unknown densify id: {args.id}", file=sys.stderr)
            return 2
    if not rows:
        print("ok: no densify stems with card tokens" + (f" for {args.id}" if args.id else ""))
        return 0
    print("densify stems with template card tokens (need alignLessonTableCopy on speech):")
    for activity_id, tokens, stem in rows:
        print(f"  {activity_id}: {', '.join(tokens)}")
        print(f"    {stem[:120]}")
    return 1


def build_parser() -> argparse.ArgumentParser:
    """CLI parser."""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--source",
        default=str(DEFAULT_SOURCE),
        help="path to rex_coach_line.dart",
    )
    sub = parser.add_subparsers(dest="cmd", required=True)
    p_list = sub.add_parser("list", help="list densify stems with card tokens")
    p_list.set_defaults(func=cmd_list)
    p_check = sub.add_parser("check", help="exit 1 if any stem still has card tokens")
    p_check.add_argument("--id", help="check a single activity id")
    p_check.set_defaults(func=cmd_check)
    return parser


def main(argv: list[str] | None = None) -> int:
    """Entrypoint."""
    parser = build_parser()
    args = parser.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
