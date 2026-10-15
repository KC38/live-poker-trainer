#!/usr/bin/env python3
"""Scan SoftPulse densify stems for choice-label spoils.

Discovery keeps re-walking SoftPulse-quiet densify by hand. This CLI compares
``selectIdentifyDensifiedCoachLine`` stems to catalog choice labels and lists
likely spoils (idle coach names a tile answer while SoftPulse is off / after
Hint only). Matches full labels, short numeric tiles (``55bb``), and
distinctive em-dash fragments (``straight and flush`` inside
``Draw — straight and flush potential``; LPT-877 / LPT-878).

Commands:

  list [--quiet-only]   Print densify ids whose stem embeds a choice label.
  check [--quiet-only]  Exit 1 when any spoil remains (CI / discovery gate).

SoftPulse-quiet / SoftPulse-off are inferred from:

1. The comment immediately above each stem (``SoftPulse-quiet``,
   ``SoftPulse-off``, ``kind: none``), and/or
2. The activity id (``-unguided``, ``-scaffolded``, ``-checkpoint``,
   ``-jump``) — SoftPulse-after-Hint / SoftPulse-off densify often ships
   without a quiet comment (LPT-880 / LPT-881 empty ``list`` misses).

Guided SoftPulse-on stems (``-guided`` without a quiet comment) that name
the answer on purpose are omitted unless ``--include-guided``.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = REPO / "lib" / "ui" / "course" / "widgets" / "rex_coach_line.dart"
DEFAULT_CATALOG = REPO / "assets" / "course" / "v2" / "catalog.json"

# Skip short / generic labels that appear in almost every stem.
_STOP_LABELS = frozenset(
    {
        "tap",
        "pick",
        "call",
        "fold",
        "raise",
        "check",
        "bet",
        "pot",
        "board",
        "cards",
        "seat",
        "hero",
        "villain",
        "next",
        "plan",
        "label",
        "matching",
        "continue",
        "hint",
    }
)

# Function words + weak scene nouns — fragment "in the middle" must not spoil
# a stem that only says "board in the middle" (Your two cards unguided).
_FRAG_STOP = frozenset(
    {
        "a",
        "an",
        "and",
        "at",
        "for",
        "in",
        "of",
        "on",
        "or",
        "the",
        "to",
        "vs",
        "board",
        "cards",
        "hole",
        "holes",
        "label",
        "matching",
        "middle",
        "plan",
        "pot",
        "seat",
        "stack",
        "table",
    }
)
_CARDISH = re.compile(r"^(?:[2-9tjqka]{1,2}[cdhs]?|\d+bb)$", re.IGNORECASE)

_ENTRY = re.compile(
    r"(?P<prefix>(?://[^\n]*\n|\s)*)"
    r"""['\"](?P<id>act-[^'\"]+)['\"]\s*=>\s*['\"](?P<stem>(?:\\.|[^'\\])*)['\"]""",
    re.DOTALL,
)

# Densify SoftPulse-after-Hint / SoftPulse-off assessment ids (even when the
# map entry lacks a SoftPulse-quiet comment — LPT-880 / LPT-881).
_QUIET_ID_MARKERS = (
    "-unguided",
    "-scaffolded",
    "-checkpoint",
    "-jump",
)


def activity_id_implies_quiet(activity_id: str) -> bool:
    """True when [activity_id] is SoftPulse-quiet densify by naming convention."""
    # Guided SoftPulse-on teaching may spoil on purpose — only treat as quiet
    # when the id is not a plain -guided stem (same-concept quiet guided is
    # rare and should keep an explicit SoftPulse-quiet comment).
    if re.search(r"-guided(?:-|$)", activity_id) and not any(
        marker in activity_id
        for marker in ("-unguided", "-scaffolded", "-checkpoint", "-jump")
    ):
        return False
    return any(marker in activity_id for marker in _QUIET_ID_MARKERS)


def parse_densify_entries(source: Path) -> list[dict[str, str | bool]]:
    """Parse densify map entries with SoftPulse-quiet/off flags."""
    text = source.read_text(encoding="utf-8")
    start = text.find("String? selectIdentifyDensifiedCoachLine")
    if start < 0:
        return []
    body = text[start:]
    end = body.find("\nString ")
    if end < 0:
        end = body.find("\nWidget ")
    if end > 0:
        body = body[:end]
    rows: list[dict[str, str | bool]] = []
    for match in _ENTRY.finditer(body):
        prefix = match.group("prefix") or ""
        activity_id = match.group("id")
        stem = match.group("stem").replace(r"\'", "'").replace(r"\n", "\n")
        quiet_comment = bool(
            re.search(
                r"SoftPulse-quiet|SoftPulse-off|kind:\s*none",
                prefix,
                re.IGNORECASE,
            )
        )
        quiet = quiet_comment or activity_id_implies_quiet(activity_id)
        rows.append(
            {
                "id": activity_id,
                "stem": stem,
                "quiet": quiet,
            }
        )
    return rows


def load_choice_labels(catalog: Path) -> dict[str, list[str]]:
    """Map activity id → choice label strings from course v2 catalog."""
    data = json.loads(catalog.read_text(encoding="utf-8"))
    labels: dict[str, list[str]] = {}

    def walk(obj: object) -> None:
        if isinstance(obj, dict):
            activity_id = obj.get("id")
            choices = obj.get("choices")
            if (
                isinstance(activity_id, str)
                and activity_id.startswith("act-")
                and isinstance(choices, list)
            ):
                found: list[str] = []
                for choice in choices:
                    if not isinstance(choice, dict):
                        continue
                    for key in ("label", "title", "text", "id"):
                        raw = choice.get(key)
                        if isinstance(raw, str) and raw.strip():
                            found.append(raw.strip())
                            break
                if found:
                    labels[activity_id] = found
            for value in obj.values():
                walk(value)
        elif isinstance(obj, list):
            for value in obj:
                walk(value)

    walk(data)
    return labels


def _normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip().lower())


# Stack / chip tiles are short ("55bb") but distinctive SoftPulse-off spoils
# (LPT-877 jump-stack named 120bb while scan required len>=6).
_NUMERIC_TILE = re.compile(
    r"^\d+(\.\d+)?\s*(bb|chips?|big blinds?)?$",
    re.IGNORECASE,
)


def _label_significant(norm: str) -> bool:
    """True when [norm] is specific enough to count as a spoil needle."""
    if len(norm) < 4 or norm in _STOP_LABELS:
        return False
    if _NUMERIC_TILE.match(norm):
        return True
    if " " in norm or len(norm) >= 6:
        return True
    return False


def _fragment_contentful(phrase: str) -> bool:
    """True when [phrase] has poker-meaningful words (not only 'in the middle')."""
    words = phrase.split()
    content = [w for w in words if w not in _FRAG_STOP]
    if len(content) >= 2:
        return True
    if len(content) == 1 and (
        _CARDISH.match(content[0]) or len(content[0]) >= 5
    ):
        return True
    return False


def _distinctive_fragments(label: str) -> list[str]:
    """Subphrases of [label] that SoftPulse-off stems must not echo (LPT-878).

    Exact full-label match misses ``straight and flush`` inside
    ``Draw — straight and flush potential``.
    """
    frags: list[str] = []
    seen: set[str] = set()
    # Split em-dash / slash / pipe subtitles.
    for part in re.split(r"\s*[—|/]\s*", label):
        words = _normalize(part).split()
        # Sliding windows of 2+ words, length ≥12 (skip lone "draw").
        for start in range(len(words)):
            for end in range(start + 2, len(words) + 1):
                phrase = " ".join(words[start:end])
                if (
                    len(phrase) >= 12
                    and _fragment_contentful(phrase)
                    and phrase not in seen
                ):
                    seen.add(phrase)
                    frags.append(phrase)
    return frags


def _answer_cue(hay: str, needle: str) -> bool:
    """True when [needle] is cued as the answer (tap/pick), not prose overlap."""
    return bool(
        re.search(
            rf"\b(?:tap|pick|choose|select)\s+{re.escape(needle)}\b",
            hay,
        )
    )


def _numeric_answer_cue(hay: str, tile: str) -> bool:
    """True when [tile] is cued as the answer, not only situation setup.

    SoftPulse-quiet stems may say ``You have 150bb. Villain has 60bb`` while
    tiles are those sizes (LPT-849 / LPT-787 accepted). Spoil when the stem
    tells the learner to tap/pick that tile (LPT-877 jump-stack).
    """
    return _answer_cue(hay, tile)


def spoil_labels(stem: str, choices: list[str]) -> list[str]:
    """Choice labels (or distinctive fragments) echoed inside [stem]."""
    hay = _normalize(stem)
    hits: list[str] = []
    seen: set[str] = set()
    for label in choices:
        norm = _normalize(label)
        if not _label_significant(norm):
            continue
        matched = False
        if _NUMERIC_TILE.match(norm):
            matched = _numeric_answer_cue(hay, norm)
        elif norm in hay:
            # Short labels like "Only you" often appear mid-instruction
            # ("only you can see") — require tap/pick cue (LPT-880 class still
            # catches "tap Stronger" / "tap Call 10").
            if _answer_cue(hay, norm) or len(norm) >= 18 or norm.count(" ") >= 3:
                matched = True
        else:
            for frag in _distinctive_fragments(label):
                if frag in hay:
                    matched = True
                    break
        if matched and norm not in seen:
            seen.add(norm)
            hits.append(label)
    return hits


def find_spoils(
    entries: list[dict[str, str | bool]],
    labels: dict[str, list[str]],
    *,
    quiet_only: bool,
    include_guided: bool,
) -> list[tuple[str, list[str], str, bool]]:
    """Return (id, spoil_labels, stem, quiet) rows."""
    rows: list[tuple[str, list[str], str, bool]] = []
    for entry in entries:
        activity_id = str(entry["id"])
        stem = str(entry["stem"])
        quiet = bool(entry["quiet"])
        if quiet_only and not quiet:
            continue
        if not include_guided and not quiet:
            # Skip stems without SoftPulse-quiet/off comment (usually guided
            # SoftPulse-on that may name the answer on purpose).
            continue
        choices = labels.get(activity_id, [])
        hits = spoil_labels(stem, choices)
        if hits:
            rows.append((activity_id, hits, stem, quiet))
    return rows


def cmd_list(args: argparse.Namespace) -> int:
    """Print densify stems that embed catalog choice labels."""
    entries = parse_densify_entries(Path(args.source).expanduser())
    labels = load_choice_labels(Path(args.catalog).expanduser())
    rows = find_spoils(
        entries,
        labels,
        quiet_only=bool(args.quiet_only),
        include_guided=bool(args.include_guided),
    )
    print("id\tquiet\tspoil_labels\tstem")
    for activity_id, hits, stem, quiet in rows:
        compact = stem.replace("\n", " ")
        print(
            f"{activity_id}\t{int(quiet)}\t{' | '.join(hits)}\t{compact}"
        )
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    """Exit 1 when SoftPulse-quiet densify still spoils a choice label."""
    entries = parse_densify_entries(Path(args.source).expanduser())
    labels = load_choice_labels(Path(args.catalog).expanduser())
    rows = find_spoils(
        entries,
        labels,
        quiet_only=bool(args.quiet_only),
        include_guided=bool(args.include_guided),
    )
    if not rows:
        print("ok: no densify choice-label spoils")
        return 0
    print(f"FAIL: {len(rows)} densify stem(s) embed choice labels:")
    for activity_id, hits, stem, quiet in rows:
        tag = "quiet" if quiet else "guided"
        print(f"  {activity_id} ({tag}): {', '.join(hits)}")
        print(f"    {stem[:140]}")
    return 1


def build_parser() -> argparse.ArgumentParser:
    """CLI parser."""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--source", default=str(DEFAULT_SOURCE))
    parser.add_argument("--catalog", default=str(DEFAULT_CATALOG))
    sub = parser.add_subparsers(dest="cmd", required=True)

    def add_filters(p: argparse.ArgumentParser) -> None:
        p.add_argument(
            "--all-modes",
            action="store_true",
            help="include stems without SoftPulse-quiet comments (and guided)",
        )
        p.add_argument(
            "--include-guided",
            action="store_true",
            help="also report SoftPulse-on guided stems (often intentional)",
        )

    p_list = sub.add_parser("list", help="list densify choice-label spoils")
    add_filters(p_list)
    p_list.set_defaults(func=cmd_list)
    p_check = sub.add_parser("check", help="exit 1 if quiet densify spoils remain")
    add_filters(p_check)
    p_check.set_defaults(func=cmd_check)
    return parser


def _apply_filter_flags(args: argparse.Namespace) -> None:
    """Default SoftPulse-quiet-only; --all-modes widens the scan."""
    if getattr(args, "all_modes", False):
        args.quiet_only = False
        args.include_guided = True
    else:
        args.quiet_only = True


def main(argv: list[str] | None = None) -> int:
    """Entrypoint."""
    parser = build_parser()
    args = parser.parse_args(argv)
    _apply_filter_flags(args)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
