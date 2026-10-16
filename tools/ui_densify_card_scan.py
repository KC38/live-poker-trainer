#!/usr/bin/env python3
"""Scan SoftPulse densify stems for template card tokens (remap honesty).

``selectIdentifyDensifiedCoachLine`` often keeps template codes
(``Board Qc 7d 2s. You hold 5h 4h``) so ``alignLessonTableCopy`` (via
``alignLessonActionCopy``) can rewrite them onto the remapped felt.
Tokens in the stem map are **expected** after LPT-851 — not a ticket by
themselves. File a remap bug only when idle coach on the mini still names
template cards while the felt shows isomorphic ranks (``check`` exit 1 =
speech path returns densify raw without align).

Commands:

  list                 Print densify activity ids whose stem embeds card codes
                       (walk candidates; not an open-bug list).
  check [--id ID]      Exit 0 when densify speech is wired through
                       ``alignLessonActionCopy`` / ``alignLessonTableCopy``
                       **and** ``alignStartingHandCopy`` still rewrites
                       high-card class shorthand (``suited king`` → remapped
                       high; LPT-1018). Exit 1 on align-raw regression,
                       missing high-card rewrite, or unknown --id.

Card token: rank ``2-9TJQKA`` + suit ``cdhs`` (case-insensitive), word-boundary.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = REPO / "lib" / "ui" / "course" / "widgets" / "rex_coach_line.dart"
DEFAULT_LAYOUT = (
    REPO / "lib" / "ui" / "course" / "widgets" / "lesson_screen_layout.dart"
)
DEFAULT_STARTING_HAND = (
    REPO / "lib" / "ui" / "course" / "widgets" / "lesson_starting_hand_copy.dart"
)

# High-card class shorthand rewrite arm (LPT-1018).
_HIGH_CARD_CLASS_MARKER = re.compile(
    r"suited king|High-card class shorthand|LPT-1018",
    re.IGNORECASE,
)

# Board Ks 9d / You hold Kh Qh / Flop As 7d
_CARD_TOKEN = re.compile(r"\b([2-9TJQKA][cdhs])\b", re.IGNORECASE)
# Lone "as"/"ah" in English ("treated as") is not a deal — require deal context
# or ≥2 card codes before flagging.
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


def densify_align_wired(layout: Path) -> bool:
    """True when densifiedSelect is passed through alignLesson*Copy (LPT-851)."""
    if not layout.is_file():
        return False
    text = layout.read_text(encoding="utf-8")
    # Prefer the assignment site — earlier call sites are comments / other arms.
    for needle in (
        "final densifiedSelect = selectIdentifyDensifiedCoachLine",
        "densifiedSelect = selectIdentifyDensifiedCoachLine",
        "selectIdentifyDensifiedCoachLine(activity.id)",
    ):
        idx = text.find(needle)
        if idx >= 0:
            break
    else:
        return False
    window = text[idx : idx + 900]
    if re.search(r"return\s+densifiedSelect\s*;", window):
        return False
    return (
        "alignLessonActionCopy" in window or "alignLessonTableCopy" in window
    )


def starting_hand_high_card_class_wired(source: Path) -> bool:
    """True when ``alignStartingHandCopy`` rewrites suited/offsuit high (LPT-1018)."""
    if not source.is_file():
        return False
    text = source.read_text(encoding="utf-8")
    start = text.find("String alignStartingHandCopy")
    if start < 0:
        return False
    # Bound to the function body.
    body = text[start:]
    end = body.find("\nString ")
    if end < 0:
        end = body.find("\nfinal ")
    if end > 0:
        body = body[:end]
    if not _HIGH_CARD_CLASS_MARKER.search(body):
        return False
    # Require the fit+rank rewrite (not only a comment).
    return bool(
        re.search(
            r"\$fit \$fromHigh",
            body,
        )
        and re.search(
            r"\$fit \$toHigh",
            body,
        )
    )


def cmd_list(args: argparse.Namespace) -> int:
    """Print densify stems that embed template card codes (not open bugs)."""
    source = Path(args.source).expanduser()
    layout = Path(args.layout).expanduser()
    rows = stems_with_cards(parse_densify_stems(source))
    wired = densify_align_wired(layout)
    status = "align_wired" if wired else "ALIGN_RAW_REGRESSION"
    print(f"# speech_path={status} (tokens in stems are expected for rewrite)")
    print("id\ttokens\tstem")
    for activity_id, tokens, stem in rows:
        compact = stem.replace("\n", " ")
        print(f"{activity_id}\t{','.join(tokens)}\t{compact}")
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    """Exit 1 when densify speech skips align or high-card rewrite is missing."""
    source = Path(args.source).expanduser()
    layout = Path(args.layout).expanduser()
    starting_hand = Path(args.starting_hand).expanduser()
    stems = parse_densify_stems(source)
    rows = stems_with_cards(stems)
    if args.id:
        if args.id not in stems:
            print(f"unknown densify id: {args.id}", file=sys.stderr)
            return 2
        rows = [r for r in rows if r[0] == args.id]
    wired = densify_align_wired(layout)
    if not wired:
        print(
            "FAIL: densifiedSelect speech path returns raw / missing align "
            "(LPT-851 / LPT-806 class — wire through alignLessonActionCopy)"
        )
        for activity_id, tokens, stem in rows[:8]:
            print(f"  {activity_id}: {', '.join(tokens)}")
            print(f"    {stem[:120]}")
        return 1
    if not starting_hand_high_card_class_wired(starting_hand):
        print(
            "FAIL: alignStartingHandCopy missing high-card class rewrite "
            "('suited king' / 'offsuit ace' → remapped high; LPT-1018)"
        )
        return 1
    if not rows:
        print(
            "ok: align wired + high-card class rewrite; "
            "no densify stems with card tokens"
        )
        return 0
    print(
        f"ok: align wired + high-card class rewrite "
        f"({len(rows)} stem(s) keep template tokens for rewrite)"
    )
    for activity_id, tokens, _stem in rows:
        print(f"  {activity_id}: {', '.join(tokens)}")
    return 0


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
    parser.add_argument(
        "--layout",
        default=str(DEFAULT_LAYOUT),
        help="path to lesson_screen_layout.dart (align wiring)",
    )
    parser.add_argument(
        "--starting-hand",
        default=str(DEFAULT_STARTING_HAND),
        help="path to lesson_starting_hand_copy.dart (LPT-1018 rewrite)",
    )
    sub = parser.add_subparsers(dest="cmd", required=True)
    p_list = sub.add_parser(
        "list",
        help="list densify stems with card tokens (walk candidates)",
    )
    p_list.set_defaults(func=cmd_list)
    p_check = sub.add_parser(
        "check",
        help="exit 1 if densify align or high-card class rewrite is missing",
    )
    p_check.add_argument("--id", help="limit listing to one activity id")
    p_check.set_defaults(func=cmd_check)
    return parser


def main(argv: list[str] | None = None) -> int:
    """Entrypoint."""
    parser = build_parser()
    args = parser.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
