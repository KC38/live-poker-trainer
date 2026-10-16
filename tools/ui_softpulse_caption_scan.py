#!/usr/bin/env python3
"""Scan AuthoredCue SoftPulse explains for missing teaching captions.

Discovery keeps filing SoftPulse explain caption gaps one lesson at a time
(LPT-883 → LPT-914+). AuthoredCue tiles call
``authoredSoftPulseExplainCaption``; unknown targets render label-only.
This CLI diffs catalog ``soft_pulse`` targets on activities that resolve to
``CoachDialogueVisualKind.authoredCues`` against the caption map in
``lesson_action_table.dart``.

Commands:

  list   Print activity id, lesson slug, and missing caption targets.
  check  Exit 1 when any gap remains (CI / discovery gate).

Dedicated demo visuals (explicit ``case 'act-…':`` arms in
``resolveCoachDialogueVisual``) are skipped — they do not use
``LessonAuthoredCueExplainTable``. Densify SoftPulse cues with lowercase
targets are ignored (not AuthoredCue explain tiles).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
DEFAULT_CAPTION_SOURCE = (
    REPO / "lib" / "ui" / "course" / "widgets" / "lesson_action_table.dart"
)
DEFAULT_VISUAL_SOURCE = (
    REPO / "lib" / "ui" / "course" / "activities" / "coach_dialogue_activity.dart"
)
DEFAULT_CATALOG = REPO / "assets" / "course" / "v2" / "catalog.json"

_CAPTION_MAP = re.compile(
    r"String authoredSoftPulseExplainCaption\(String target\) \{.*?"
    r"const captions = <String, String>\{(.*?)\n  \};",
    re.DOTALL,
)
_CAPTION_KEY = re.compile(r"'([^']+)'\s*:")
_DEDICATED_CASE = re.compile(r"case\s+'(act-[^']+)':")


def parse_caption_keys(source: Path) -> set[str]:
    """Return keys in ``authoredSoftPulseExplainCaption``."""
    text = source.read_text(encoding="utf-8")
    match = _CAPTION_MAP.search(text)
    if match is None:
        return set()
    return set(_CAPTION_KEY.findall(match.group(1)))


def parse_dedicated_visual_ids(source: Path) -> set[str]:
    """Activity ids with a dedicated SoftPulse demo visual (not AuthoredCue).

    Parses ``case 'act-…':`` arms in the ``switch (activity.id)`` that ends
    just before the ``authoredSoftPulseTargets`` → ``authoredCues`` fallback.
    """
    text = source.read_text(encoding="utf-8")
    marker = "if (authoredSoftPulseTargets(activity) != null)"
    idx = text.find(marker)
    if idx < 0:
        return set()
    pre = text[:idx]
    switch_at = pre.rfind("switch (activity.id)")
    if switch_at < 0:
        return set()
    block = pre[switch_at:idx]
    return set(_DEDICATED_CASE.findall(block))


def is_explain_target(target: str) -> bool:
    """True when [target] looks like an AuthoredCue SoftPulse tile label."""
    if not target or not isinstance(target, str):
        return False
    # Densify SoftPulse cues use lowercase choice ids / short stems.
    if target != target.upper():
        return False
    return True


def soft_pulse_targets(activity: dict) -> list[str]:
    """Press-ordered soft_pulse targets from teachSpec.cues."""
    teach = activity.get("teachSpec")
    if not isinstance(teach, dict):
        return []
    raw = teach.get("cues")
    if not isinstance(raw, list):
        return []
    cues: list[tuple[int, str]] = []
    for cue in raw:
        if not isinstance(cue, dict):
            continue
        if cue.get("kind") != "soft_pulse":
            continue
        press = cue.get("press")
        target = cue.get("target")
        if isinstance(press, int) and isinstance(target, str) and target:
            cues.append((press, target))
    cues.sort(key=lambda row: row[0])
    return [target for _, target in cues]


def walk_authored_cue_explains(
    catalog: Path,
    *,
    dedicated_ids: set[str],
) -> list[dict[str, object]]:
    """Catalog activities that render ``LessonAuthoredCueExplainTable``."""
    data = json.loads(catalog.read_text(encoding="utf-8"))
    rows: list[dict[str, object]] = []

    def walk(obj: object, lesson_id: str | None = None) -> None:
        if isinstance(obj, dict):
            next_lesson = lesson_id
            obj_id = obj.get("id")
            # Course lessons are `lesson-…` nodes that own `activities`.
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
                and activity_id not in dedicated_ids
                and renderer in (None, "coachDialogue", "coach_dialogue")
            ):
                targets = soft_pulse_targets(obj)
                explain_targets = [t for t in targets if is_explain_target(t)]
                if explain_targets:
                    rows.append(
                        {
                            "id": activity_id,
                            "slug": next_lesson or "",
                            "targets": explain_targets,
                        }
                    )
            for value in obj.values():
                walk(value, next_lesson)
        elif isinstance(obj, list):
            for value in obj:
                walk(value, lesson_id)

    walk(data)
    return rows


def find_caption_gaps(
    *,
    catalog: Path,
    caption_source: Path,
    visual_source: Path,
) -> list[dict[str, object]]:
    """Return AuthoredCue explains with SoftPulse targets missing captions."""
    keys = parse_caption_keys(caption_source)
    dedicated = parse_dedicated_visual_ids(visual_source)
    gaps: list[dict[str, object]] = []
    for row in walk_authored_cue_explains(catalog, dedicated_ids=dedicated):
        targets = row["targets"]
        assert isinstance(targets, list)
        missing = [t for t in targets if t not in keys]
        if missing:
            gaps.append(
                {
                    "id": row["id"],
                    "slug": row["slug"],
                    "targets": targets,
                    "missing": missing,
                }
            )
    return gaps


def _print_gaps(gaps: list[dict[str, object]]) -> None:
    if not gaps:
        print("ok: no AuthoredCue SoftPulse caption gaps")
        return
    print(f"gaps: {len(gaps)} AuthoredCue SoftPulse explain(s) missing captions")
    for row in gaps:
        missing = ", ".join(str(x) for x in row["missing"])  # type: ignore[arg-type]
        slug = row["slug"] or "-"
        print(f"  {row['id']}  lesson={slug}  missing=[{missing}]")


def main(argv: list[str] | None = None) -> int:
    """CLI entry."""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "command",
        choices=("list", "check"),
        help="list gaps or fail when any remain",
    )
    parser.add_argument(
        "--catalog",
        type=Path,
        default=DEFAULT_CATALOG,
        help="course v2 catalog path",
    )
    parser.add_argument(
        "--caption-source",
        type=Path,
        default=DEFAULT_CAPTION_SOURCE,
        help="Dart file with authoredSoftPulseExplainCaption",
    )
    parser.add_argument(
        "--visual-source",
        type=Path,
        default=DEFAULT_VISUAL_SOURCE,
        help="Dart file with resolveCoachDialogueVisual",
    )
    args = parser.parse_args(argv)
    gaps = find_caption_gaps(
        catalog=args.catalog,
        caption_source=args.caption_source,
        visual_source=args.visual_source,
    )
    _print_gaps(gaps)
    if args.command == "check" and gaps:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
