#!/usr/bin/env python3
"""Scan AuthoredCue SoftPulse explains for felt / coach hand-class mismatches.

LPT-994: SoftPulse explains defaulted to AhKd on Qs7c2d while coach copy said
"second pair". Discovery still finds the same class of honesty bugs by eye.
This CLI diffs coach / accessibility copy that claims top / second / third
pair against ``authoredCueExplainFeltCodes`` (and the AhKd / Q72 default).

Commands:

  list            Print activity id, claimed class, and felt codes.
  drafts [--limit N]
                  Print Jira-ready title + summary lines (default N=3).
  check           Exit 1 when any mismatch remains (CI / discovery gate).

Dedicated demo visuals are skipped (same set as
``ui_softpulse_caption_scan``). Conceptual SoftPulse labels alone are not
enough — the coach / accessibility blob must name the hand class.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
DEFAULT_FELT_SOURCE = (
    REPO / "lib" / "ui" / "course" / "widgets" / "lesson_action_table.dart"
)
DEFAULT_VISUAL_SOURCE = (
    REPO / "lib" / "ui" / "course" / "activities" / "coach_dialogue_activity.dart"
)
DEFAULT_CATALOG = REPO / "assets" / "course" / "v2" / "catalog.json"

# Reuse dedicated-visual parsing from the SoftPulse caption scanner.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from ui_softpulse_caption_scan import (  # noqa: E402
    is_explain_target,
    parse_dedicated_visual_ids,
    soft_pulse_targets,
)

_DEFAULT_HERO = ("Ah", "Kd")
_DEFAULT_BOARD = ("Qs", "7c", "2d")

_CARD = re.compile(r"^([2-9TJQKA])([cdhs])$", re.IGNORECASE)
_RANK_ORDER = {
    "2": 2,
    "3": 3,
    "4": 4,
    "5": 5,
    "6": 6,
    "7": 7,
    "8": 8,
    "9": 9,
    "T": 10,
    "J": 11,
    "Q": 12,
    "K": 13,
    "A": 14,
}

_PAIR_CLAIM = re.compile(
    r"\b(top pair|second pair|third pair|bottom pair)\b",
    re.IGNORECASE,
)

_OVERRIDE_BLOCK = re.compile(
    r"authoredCueExplainFeltCodes\(CourseActivity activity\) \{(.*?)^\}\n",
    re.DOTALL | re.MULTILINE,
)
_OVERRIDE_IF = re.compile(
    r"id\s*==\s*'(act-[^']+)'",
)
_RETURN_CODES = re.compile(
    r"heroCodes:\s*const\s*\[([^\]]+)\].*?boardCodes:\s*const\s*\[([^\]]+)\]",
    re.DOTALL,
)


def _parse_codes(raw: str) -> tuple[str, ...]:
    return tuple(
        m.group(1)
        for m in re.finditer(r"'([2-9TJQKAtjqka][cdhsCDHS])'", raw)
    )


def parse_felt_codes(source: Path) -> dict[str, tuple[tuple[str, ...], tuple[str, ...]]]:
    """Map activity id → (hero, board); empty id key is the default return."""
    text = source.read_text(encoding="utf-8")
    block_match = _OVERRIDE_BLOCK.search(text)
    if block_match is None:
        return {"": (_DEFAULT_HERO, _DEFAULT_BOARD)}
    block = block_match.group(1)
    # Default is the final return (…).
    returns = list(_RETURN_CODES.finditer(block))
    if not returns:
        return {"": (_DEFAULT_HERO, _DEFAULT_BOARD)}
    default_hero = _parse_codes(returns[-1].group(1))
    default_board = _parse_codes(returns[-1].group(2))
    mapping: dict[str, tuple[tuple[str, ...], tuple[str, ...]]] = {
        "": (default_hero or _DEFAULT_HERO, default_board or _DEFAULT_BOARD)
    }
    # Pair each if (id == …) with the nearest following return.
    for if_match in _OVERRIDE_IF.finditer(block):
        aid = if_match.group(1)
        after = block[if_match.end() :]
        ret = _RETURN_CODES.search(after)
        if ret is None:
            continue
        mapping[aid] = (
            _parse_codes(ret.group(1)) or _DEFAULT_HERO,
            _parse_codes(ret.group(2)) or _DEFAULT_BOARD,
        )
    return mapping


def _rank(card: str) -> str:
    match = _CARD.match(card.strip())
    if match is None:
        return ""
    return match.group(1).upper().replace("10", "T")


def board_pair_ranks(board: tuple[str, ...] | list[str]) -> list[str]:
    """Unique board ranks highest-first (flop/turn/river order by rank)."""
    ranks = [_rank(c) for c in board]
    ranks = [r for r in ranks if r]
    uniq = sorted(set(ranks), key=lambda r: _RANK_ORDER.get(r, 0), reverse=True)
    return uniq


def hero_board_pair_class(
    hero: tuple[str, ...] | list[str],
    board: tuple[str, ...] | list[str],
) -> str | None:
    """Return top/second/third/bottom pair when hero pairs the board once."""
    hero_ranks = {_rank(c) for c in hero if _rank(c)}
    board_ranks = board_pair_ranks(board)
    if not board_ranks:
        return None
    paired = [r for r in board_ranks if r in hero_ranks]
    if not paired:
        return None
    # One pair with the board (ignore two-pair for this honesty gate).
    pair_rank = paired[0]
    index = board_ranks.index(pair_rank)
    labels = ("top pair", "second pair", "third pair", "bottom pair")
    if index >= len(labels):
        return "bottom pair"
    if index == len(board_ranks) - 1 and index > 0:
        # Lowest board rank → bottom pair (also third on a 3-card flop).
        if index == 2:
            return "third pair"
        return "bottom pair"
    return labels[index]


def coach_blob(activity: dict) -> str:
    """Concatenate coach-facing strings for an activity."""
    parts: list[str] = []
    for key in ("accessibilityText", "okFeedback", "prompt"):
        value = activity.get(key)
        if isinstance(value, str) and value.strip():
            parts.append(value)
    media = activity.get("coachMedia")
    if isinstance(media, list):
        for item in media:
            if isinstance(item, dict):
                text = item.get("text")
                if isinstance(text, str) and text.strip():
                    parts.append(text)
    return " ".join(parts)


def felt_for_activity(
    activity_id: str,
    felt_map: dict[str, tuple[tuple[str, ...], tuple[str, ...]]],
) -> tuple[tuple[str, ...], tuple[str, ...]]:
    """Resolve hero/board for an AuthoredCue explain activity."""
    return felt_map.get(activity_id, felt_map.get("", (_DEFAULT_HERO, _DEFAULT_BOARD)))


def find_felt_mismatches(
    *,
    catalog: Path,
    felt_source: Path,
    visual_source: Path,
) -> list[dict[str, object]]:
    """Return AuthoredCue explains whose coach claim disagrees with the felt."""
    felt_map = parse_felt_codes(felt_source)
    dedicated = parse_dedicated_visual_ids(visual_source)
    data = json.loads(catalog.read_text(encoding="utf-8"))
    gaps: list[dict[str, object]] = []

    def walk(obj: object, lesson_id: str | None = None) -> None:
        if isinstance(obj, dict):
            next_lesson = lesson_id
            obj_id = obj.get("id")
            if (
                isinstance(obj_id, str)
                and obj_id.startswith("lesson-")
                and isinstance(obj.get("activities"), list)
            ):
                next_lesson = obj_id
            activity_id = obj_id
            renderer = obj.get("renderer")
            if (
                isinstance(activity_id, str)
                and activity_id.startswith("act-")
                and activity_id not in dedicated
                and renderer in (None, "coachDialogue", "coach_dialogue")
            ):
                targets = soft_pulse_targets(obj)
                explain_targets = [t for t in targets if is_explain_target(t)]
                if explain_targets:
                    blob = coach_blob(obj)
                    claim_match = _PAIR_CLAIM.search(blob)
                    if claim_match is not None:
                        claim = claim_match.group(1).lower()
                        hero, board = felt_for_activity(activity_id, felt_map)
                        actual = hero_board_pair_class(hero, board)
                        if actual != claim:
                            gaps.append(
                                {
                                    "id": activity_id,
                                    "slug": next_lesson or "",
                                    "claim": claim,
                                    "actual": actual or "no board pair",
                                    "hero": list(hero),
                                    "board": list(board),
                                    "snippet": blob[:160],
                                }
                            )
            for value in obj.values():
                walk(value, next_lesson)
        elif isinstance(obj, list):
            for value in obj:
                walk(value, lesson_id)

    walk(data)
    return gaps


def draft_ticket(row: dict[str, object]) -> dict[str, str]:
    """Build a Jira-ready title + summary for one felt mismatch."""
    activity_id = str(row.get("id") or "")
    slug = str(row.get("slug") or "")
    claim = str(row.get("claim") or "")
    actual = str(row.get("actual") or "")
    hero = "/".join(str(x) for x in row.get("hero") or [])  # type: ignore[arg-type]
    board = "".join(str(x) for x in row.get("board") or [])  # type: ignore[arg-type]
    lesson_bit = slug
    if slug.startswith("lesson-"):
        lesson_bit = re.sub(r"^lesson-(?:\d+-)+", "", slug).replace("-", " ")
        if lesson_bit == slug.replace("-", " "):
            lesson_bit = slug.removeprefix("lesson-").replace("-", " ")
    title = f"{lesson_bit} AuthoredCue felt shows {actual}, coach says {claim}"
    if len(title) > 120:
        title = f"AuthoredCue felt honesty: {claim} vs {actual} ({activity_id})"
    summary = (
        f"`{activity_id}` coach copy claims **{claim}** but "
        f"`authoredCueExplainFeltCodes` deals {hero} on {board} "
        f"({actual}). Align the SoftPulse explain felt with the teach "
        f"copy (LPT-994 class)."
    )
    return {
        "title": title,
        "summary": summary,
        "activity": activity_id,
        "lesson": slug,
    }


def _print_gaps(gaps: list[dict[str, object]]) -> None:
    if not gaps:
        print("ok: no AuthoredCue SoftPulse felt / coach pair mismatches")
        return
    print(f"gaps: {len(gaps)} AuthoredCue SoftPulse felt honesty issue(s)")
    for row in gaps:
        print(
            f"  {row['id']}  lesson={row['slug'] or '-'}  "
            f"claim={row['claim']}  actual={row['actual']}  "
            f"felt={''.join(row['hero'])} on {''.join(row['board'])}"  # type: ignore[arg-type]
        )


def _print_drafts(gaps: list[dict[str, object]], *, limit: int) -> None:
    if not gaps:
        print("ok: no AuthoredCue SoftPulse felt / coach pair mismatches")
        return
    batch = gaps[: max(0, limit)]
    print(f"drafts: {len(batch)} of {len(gaps)} AuthoredCue felt honesty gaps")
    for index, row in enumerate(batch, start=1):
        draft = draft_ticket(row)
        print(f"--- {index} ---")
        print(f"title: {draft['title']}")
        print(f"summary: {draft['summary']}")


def main(argv: list[str] | None = None) -> int:
    """CLI entry."""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "command",
        choices=("list", "drafts", "check"),
        help="list gaps, print filing drafts, or fail when any remain",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=3,
        help="max drafts to print (drafts command only; default 3)",
    )
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--felt-source", type=Path, default=DEFAULT_FELT_SOURCE)
    parser.add_argument(
        "--visual-source",
        type=Path,
        default=DEFAULT_VISUAL_SOURCE,
    )
    args = parser.parse_args(argv)
    gaps = find_felt_mismatches(
        catalog=args.catalog,
        felt_source=args.felt_source,
        visual_source=args.visual_source,
    )
    if args.command == "drafts":
        _print_drafts(gaps, limit=args.limit)
    else:
        _print_gaps(gaps)
    if args.command == "check" and gaps:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
