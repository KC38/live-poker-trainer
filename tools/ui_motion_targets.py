#!/usr/bin/env python3
"""Motion / multi-frame surfaces the ui-agent should prioritize with video.

Static screenshots miss SoftPulse breathe, deal land, Hint waves, multi-press
gold advances, and ceremony transitions. This list is the discovery shortlist
for those classes — pair each walk with ``tools/sim_record.py``.

Commands:

  list                 Print every target (tsv: id, class, surface, seed hint).
  classes              Print motion classes and what to prove on video.
  pick [--coverage F]  Prefer never-walked / oldest motion surfaces from
                       ``~/.live-poker-trainer/ui-agent-coverage.jsonl``.
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class MotionTarget:
    """One motion-heavy surface the agent can open and film."""

    id: str
    motion_class: str  # multi_frame | static_move | dynamic
    surface: str
    seed: str
    prove: str


# Curated from docs/ui/design-record.md (deal, SoftPulse, multi-press, ceremony).
# Keep ids stable — coverage ``surface`` fields often match these strings.
TARGETS: tuple[MotionTarget, ...] = (
    MotionTarget(
        id="deal-your-two-cards",
        motion_class="dynamic",
        surface="lesson-01-01-01-your-two-cards",
        seed="agent_seed openlesson lesson-01-01-01-your-two-cards (or Home)",
        prove="hole cards land one-at-a-time; coach not empty mid-deal; SoftPulse only after land",
    ),
    MotionTarget(
        id="deal-blinds-button",
        motion_class="multi_frame",
        surface="lesson-01-01-03-blinds-and-button",
        seed="openlesson lesson-01-01-03-blinds-and-button",
        prove="multi-press D→SB→BB SoftPulse advances; Hint waves; puck SoftPulse without layout jump",
    ),
    MotionTarget(
        id="multi-press-suits",
        motion_class="multi_frame",
        surface="lesson-01-01-02-01-suits",
        seed="openlesson lesson-01-01-02-01-suits",
        prove="board multi-press; SoftPulse/Hint per press; no gold race across tiles",
    ),
    MotionTarget(
        id="multi-press-best-five",
        motion_class="multi_frame",
        surface="lesson-01-02-02-best-five-kickers",
        seed="openlesson lesson-01-02-02-best-five-kickers",
        prove="playOrder / checkpoint SoftPulse sequence; Hint disabled while gold on",
    ),
    MotionTarget(
        id="softpulse-breathe",
        motion_class="static_move",
        surface="lesson-runner:softpulse-breathe",
        seed="any guided SoftPulse step (e.g. blinds) — film gold ring while idle",
        prove="gold breathes in place; tile does not move/resize when cue toggles",
    ),
    MotionTarget(
        id="hearts-breathe",
        motion_class="static_move",
        surface="home:hearts-zero-breathe",
        seed="agent_seed hearts 0 (or miss to zero) then film Home/lesson chrome",
        prove="empty hearts breathe; stage blocked; refill sheet path",
    ),
    MotionTarget(
        id="lesson-result-ceremony",
        motion_class="dynamic",
        surface="lesson-result:ceremony",
        seed="finish a short lesson → Lesson Complete / result ceremony",
        prove="Rex celebrate transition; CONTINUE; no stuck mid-ceremony frame",
    ),
    MotionTarget(
        id="section-end-ceremony",
        motion_class="dynamic",
        surface="home:section-end-ceremony",
        seed="complete a section (or seed section-end) → section ceremony",
        prove="one ceremony beat (mascot, title, one button); no flash/double sheet",
    ),
    MotionTarget(
        id="pot-and-stacks",
        motion_class="dynamic",
        surface="lesson-runner:felt-pot-stacks",
        seed="any full-table action lesson with pot/stack moves",
        prove="pot fly / stack updates after resolution; folds visible post-deal",
    ),
    MotionTarget(
        id="coach-transition",
        motion_class="static_move",
        surface="lesson-runner:coach-mood-transition",
        seed="any lesson: idle → Nice! / Oops! → restore",
        prove="mood swap without empty bubble flash; one bubble through transition",
    ),
)

DEFAULT_COVERAGE = Path.home() / ".live-poker-trainer" / "ui-agent-coverage.jsonl"

# Coverage ``surface`` strings often differ from the curated motion id
# (lesson slug vs ``lesson-runner:…``, densify ticket surfaces, ceremony
# aliases). Without these, ``pick`` forever ranks already-walked motion
# targets as never-walked and starves the rest of the catalog.
SURFACE_ALIASES: dict[str, tuple[str, ...]] = {
    "lesson-01-01-01-your-two-cards": (
        "lesson-01-01-01-your-two-cards",
        "lesson-runner:your-two-cards",
    ),
    "lesson-01-01-03-blinds-and-button": (
        "lesson-01-01-03-blinds-and-button",
        "lesson-01-01-03-01-dealer-button",
        "lesson-01-01-03-02-small-and-big-blind",
        "lesson-blind-labels",
        "lesson-button-and-blinds",
        "lesson-runner:blinds-and-button",
    ),
    "lesson-01-01-02-01-suits": (
        "lesson-01-01-02-01-suits",
        "lesson-runner:suits",
    ),
    "lesson-01-02-02-best-five-kickers": (
        "lesson-01-02-02-best-five-kickers",
        "lesson-01-02-02-01-best-five",
        "lesson-best-five-checkpoint-build",
        "lesson-runner:best-five-kickers",
    ),
    "lesson-runner:softpulse-breathe": (
        "lesson-runner:softpulse-breathe",
        "lesson-runner:open-strong-softpulse",
    ),
    "home:hearts-zero-breathe": (
        "home:hearts-zero-breathe",
        "home:hearts",
    ),
    "lesson-result:ceremony": (
        "lesson-result:ceremony",
        "lesson-complete",
        "lesson-result:openlesson-continue-home",
    ),
    "home:section-end-ceremony": ("home:section-end-ceremony",),
    "lesson-runner:felt-pot-stacks": (
        "lesson-runner:felt-pot-stacks",
        "lesson-how-pots-open-pot",
        "lesson-winning-pots-open-pot",
    ),
    "lesson-runner:coach-mood-transition": (
        "lesson-runner:coach-mood-transition",
        "lesson-runner:coach-transition",
    ),
}

CLASSES = {
    "multi_frame": (
        "Several presses or authored beats on one step (SoftPulse advances, "
        "Hint per press). Film the whole sequence — not one still mid-way."
    ),
    "static_move": (
        "Motion in place without layout travel (SoftPulse breathe, empty-heart "
        "breathe, coach mood swap). Film idle ≥2s; prove no tile jump/resize."
    ),
    "dynamic": (
        "Objects travel or land (deal, pot fly, stacks, ceremony enter/exit). "
        "Film from before motion starts until settled."
    ),
}


def _parse_at(raw: str) -> datetime:
    """Best-effort parse of coverage ``at`` timestamps."""
    try:
        return datetime.fromisoformat(raw.replace("Z", "+00:00"))
    except ValueError:
        return datetime.min


def load_coverage(path: Path) -> list[dict]:
    """Load coverage JSONL rows (ignore bad lines)."""
    if not path.is_file():
        return []
    rows: list[dict] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            rows.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return rows


def last_walk_by_surface(rows: Iterable[dict]) -> dict[str, datetime]:
    """Map surface → latest walk time."""
    latest: dict[str, datetime] = {}
    for row in rows:
        surface = str(row.get("surface") or "").strip()
        if not surface:
            continue
        at = _parse_at(str(row.get("at") or ""))
        prev = latest.get(surface)
        if prev is None or at > prev:
            latest[surface] = at
    return latest


def coverage_keys_for(surface: str) -> frozenset[str]:
    """Canonical motion surface plus known coverage aliases."""
    aliases = SURFACE_ALIASES.get(surface, ())
    return frozenset((surface, *aliases))


def last_walk_for_surface(
    latest: dict[str, datetime],
    surface: str,
) -> datetime | None:
    """Latest coverage walk matching [surface] or its aliases."""
    best: datetime | None = None
    for key in coverage_keys_for(surface):
        at = latest.get(key)
        if at is None:
            continue
        if best is None or at > best:
            best = at
    return best


def pick_targets(
    targets: tuple[MotionTarget, ...] = TARGETS,
    coverage_path: Path = DEFAULT_COVERAGE,
    *,
    limit: int = 3,
) -> list[MotionTarget]:
    """Prefer never-walked motion surfaces, then oldest walks."""
    latest = last_walk_by_surface(load_coverage(coverage_path))

    def rank_key(t: MotionTarget) -> tuple[int, datetime, str]:
        walked_at = last_walk_for_surface(latest, t.surface)
        return (
            0 if walked_at is None else 1,
            walked_at or datetime.min,
            t.id,
        )

    ranked = sorted(targets, key=rank_key)
    return ranked[: max(1, limit)]


def cmd_list(_: argparse.Namespace) -> int:
    """Print all targets as TSV."""
    print("id\tclass\tsurface\tseed\tprove")
    for t in TARGETS:
        print(f"{t.id}\t{t.motion_class}\t{t.surface}\t{t.seed}\t{t.prove}")
    return 0


def cmd_classes(_: argparse.Namespace) -> int:
    """Print motion class definitions."""
    for name, blurb in CLASSES.items():
        print(f"{name}\t{blurb}")
    return 0


def cmd_pick(args: argparse.Namespace) -> int:
    """Print the next motion surfaces to walk with video."""
    path = Path(args.coverage).expanduser() if args.coverage else DEFAULT_COVERAGE
    chosen = pick_targets(coverage_path=path, limit=int(args.limit))
    print("id\tclass\tsurface\tseed\tprove")
    for t in chosen:
        print(f"{t.id}\t{t.motion_class}\t{t.surface}\t{t.seed}\t{t.prove}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    """CLI parser."""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="cmd", required=True)
    p_list = sub.add_parser("list", help="list all motion targets")
    p_list.set_defaults(func=cmd_list)
    p_cls = sub.add_parser("classes", help="describe motion classes")
    p_cls.set_defaults(func=cmd_classes)
    p_pick = sub.add_parser("pick", help="pick next motion surfaces from coverage")
    p_pick.add_argument(
        "--coverage",
        default=str(DEFAULT_COVERAGE),
        help="ui-agent coverage JSONL path",
    )
    p_pick.add_argument("--limit", type=int, default=3, help="how many to print")
    p_pick.set_defaults(func=cmd_pick)
    return parser


def main(argv: list[str] | None = None) -> int:
    """CLI entrypoint."""
    args = build_parser().parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
