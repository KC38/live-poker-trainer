#!/usr/bin/env python3
"""Scan LessonActionSpot villain lines for unparsed multiway caller counts.

LPT-1021 / LPT-1024 / LPT-1025: densify felts must keep named callers live.
``parseLessonCallerCount`` handles ``2 callers``, ``three callers``, digit
``4-way``, word ``four-way``, and ``BB + MP call``. This CLI extracts
``villainLine`` strings from ``lesson_action_table.dart`` that look
multiway and lists any that still parse to null (coach/felt honesty gaps).

Commands:

  list     Print multiway-looking villain lines and their parsed counts.
  check    Exit 1 when any multiway-looking line fails to parse.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = (
    REPO / "lib" / "ui" / "course" / "widgets" / "lesson_action_table.dart"
)

_VILLAIN_LINE = re.compile(r"villainLine:\s*'([^']+)'")
_MULTIWAYISH = re.compile(
    r"(?i)\b("
    r"\d+\s+callers?|"
    r"(?:one|two|three|four|five)\s+callers?|"
    r"\d+\s*-?\s*way|"
    r"(?:two|three|four|five|six|seven|eight|nine)-?way|"
    r"bb\s*\+\s*mp|mp\s*\+\s*bb|"
    r"callers?\s+behind|"
    r"multiway"
    r")\b"
)
# Soft / non-count lines — coach flavor without a numeric multiway contract.
_SOFT_SKIP = re.compile(
    r"(?i)^(sticky caller|raise · reraise multiway|multiway · deep stacks)$"
)

_WORDS = {
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
}
_WAY_WORDS = {
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
}
_POS_TOKENS = (
    "utg+1",
    "mp+1",
    "utg",
    "mp",
    "hj",
    "co",
    "btn",
    "sb",
    "bb",
)


def parse_named_caller_positions(villain_line: str) -> list[str]:
    """Port of [parseLessonNamedCallerPositions] (opener excluded loosely)."""
    lower = villain_line.lower()
    if not re.search(r"\bcalls?\b", lower):
        return []
    segments = re.split(r"[·;|]", lower)
    call_segment = next(
        (segment for segment in segments if re.search(r"\bcalls?\b", segment)),
        lower,
    )
    opener_match = re.search(
        r"\b(" + "|".join(re.escape(t) for t in _POS_TOKENS) + r")\b.*\bopens?\b",
        lower,
    )
    if opener_match is None:
        opener_match = re.search(
            r"\b("
            + "|".join(re.escape(t) for t in _POS_TOKENS)
            + r")\s+open\b",
            lower,
        )
    opener = opener_match.group(1).upper() if opener_match else None
    found: list[str] = []
    for token in _POS_TOKENS:
        if not re.search(rf"\b{re.escape(token)}\b", call_segment):
            continue
        pos = token.upper()
        if opener is not None and pos == opener:
            continue
        found.append(pos)
    return found


def parse_caller_count(villain_line: str) -> int | None:
    """Port of [parseLessonCallerCount]."""
    lower = villain_line.lower()
    digit = re.search(r"(\d+)\s+callers?", lower)
    if digit is not None:
        return int(digit.group(1))
    for word, count in _WORDS.items():
        if re.search(rf"{word}\s+callers?", lower):
            return count
    way = re.search(r"(\d+)\s*-?\s*way\b", lower)
    if way is not None:
        players = int(way.group(1))
        if players >= 2:
            return players - 1
    for word, players in _WAY_WORDS.items():
        if re.search(rf"{word}-?way\b", lower):
            return players - 1
    named = parse_named_caller_positions(villain_line)
    if named:
        return len(named)
    return None


def extract_villain_lines(source: Path) -> list[str]:
    """Unique villainLine literals from [source]."""
    text = source.read_text(encoding="utf-8")
    seen: set[str] = set()
    rows: list[str] = []
    for match in _VILLAIN_LINE.finditer(text):
        line = match.group(1)
        if line not in seen:
            seen.add(line)
            rows.append(line)
    return rows


def multiway_gaps(source: Path) -> list[tuple[str, int | None]]:
    """Multiway-looking lines with their parsed counts (None = gap)."""
    gaps: list[tuple[str, int | None]] = []
    for line in extract_villain_lines(source):
        if _SOFT_SKIP.match(line.strip()):
            continue
        if not _MULTIWAYISH.search(line):
            continue
        gaps.append((line, parse_caller_count(line)))
    return gaps


def cmd_list(args: argparse.Namespace) -> int:
    """Print multiway-looking villain lines."""
    source = Path(args.source).expanduser()
    rows = multiway_gaps(source)
    print(f"multiway villain lines: {len(rows)}")
    for line, count in rows:
        flag = "ok" if count is not None and count > 0 else "GAP"
        print(f"  [{flag}] count={count!s:4}  {line}")
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    """Exit 1 when any multiway-looking line fails to parse."""
    source = Path(args.source).expanduser()
    rows = multiway_gaps(source)
    bad = [(line, count) for line, count in rows if count is None or count <= 0]
    if not bad:
        print(f"ok: {len(rows)} multiway villain line(s) parse to a caller count")
        return 0
    print(f"FAIL: {len(bad)} multiway villain line(s) unparsed by caller count")
    for line, count in bad:
        print(f"  count={count!s}  {line}")
    return 1


def main(argv: list[str] | None = None) -> int:
    """CLI entry."""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--source",
        default=str(DEFAULT_SOURCE),
        help="path to lesson_action_table.dart",
    )
    sub = parser.add_subparsers(dest="cmd", required=True)
    p_list = sub.add_parser("list", help="list multiway villain lines")
    p_list.set_defaults(func=cmd_list)
    p_check = sub.add_parser("check", help="fail when any multiway line is unparsed")
    p_check.set_defaults(func=cmd_check)
    args = parser.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
