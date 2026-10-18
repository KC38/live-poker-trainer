#!/usr/bin/env python3
"""Motion / multi-frame surfaces the ui-agent should prioritize with video.

Static screenshots miss SoftPulse breathe, deal land, Hint waves, multi-press
gold advances, and ceremony transitions. This list is the discovery shortlist
for those classes — pair each walk with ``tools/sim_record.py``.

Commands:

  list                 Print every target (tsv: id, class, surface, seed hint).
  classes              Print motion classes and what to prove on video.
  pick [--coverage F]  Prefer never-walked / oldest motion surfaces from
                       ``~/.live-poker-trainer/ui-agent-coverage.jsonl``
                       (surface field, aliases, and lead OK claims).
  check-seeds          Exit 1 if any ``openlesson`` seed is missing from
                       ``assets/course/v2/catalog.json`` (LPT-1027).
"""

from __future__ import annotations

import argparse
import json
import re
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
        # Live post-LPT-87 id (retired lesson-01-01-03-blinds-and-button).
        # SB→BB SoftPulse lives on Small and big blinds; D-only is dealer-button.
        surface="lesson-01-01-03-02-small-and-big-blind",
        seed="openlesson lesson-01-01-03-02-small-and-big-blind",
        prove="multi-press SB→BB SoftPulse advances; Hint waves; no layout jump",
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
        # Live post-LPT-93 id (retired lesson-01-02-02-best-five-kickers).
        surface="lesson-01-02-02-01-best-five",
        seed="openlesson lesson-01-02-02-01-best-five",
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
        seed="agent_tap / ext.poker.agent cmd=opensectionend (or opensectionend:1:Never Played)",
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
# Short tokens agents put in coverage ``--lead`` prose when they walk a
# motion target during a densify lesson (surface stays the lesson slug).
LEAD_TOKENS: dict[str, tuple[str, ...]] = {
    "deal-your-two-cards": ("deal-your-two-cards", "deal-your-two"),
    "deal-blinds-button": ("deal-blinds-button", "blinds-and-button"),
    # Agents write "suits multi-press SoftPulse OK" (LPT-1015 coverage).
    "multi-press-suits": (
        "multi-press-suits",
        "suits multi-press",
        "multi-press suits",
    ),
    "multi-press-best-five": (
        "multi-press-best-five",
        "best-five",
        "best five multi-press",
        "multi-press best-five",
    ),
    "softpulse-breathe": ("softpulse-breathe", "soft-pulse-breathe"),
    "hearts-breathe": ("hearts-breathe", "hearts-0", "hearts-zero"),
    "lesson-result-ceremony": ("lesson-result-ceremony", "lesson-result"),
    "section-end-ceremony": ("section-end-ceremony", "section-end"),
    "pot-and-stacks": ("pot-and-stacks", "felt-pot-stacks"),
    "coach-transition": ("coach-transition", "coach-mood"),
}

SURFACE_ALIASES: dict[str, tuple[str, ...]] = {
    "lesson-01-01-01-your-two-cards": (
        "lesson-01-01-01-your-two-cards",
        "lesson-runner:your-two-cards",
    ),
    "lesson-01-01-03-02-small-and-big-blind": (
        "lesson-01-01-03-02-small-and-big-blind",
        "lesson-01-01-03-blinds-and-button",  # retired pre-split alias
        "lesson-01-01-03-01-dealer-button",
        "lesson-blind-labels",
        "lesson-button-and-blinds",
        "lesson-runner:blinds-and-button",
    ),
    "lesson-01-01-02-01-suits": (
        "lesson-01-01-02-01-suits",
        "lesson-runner:suits",
    ),
    "lesson-01-02-02-01-best-five": (
        "lesson-01-02-02-01-best-five",
        "lesson-01-02-02-best-five-kickers",  # retired pre-split alias
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

# Repo-root relative path to the shipped course catalog (LPT-1027).
_DEFAULT_CATALOG = (
    Path(__file__).resolve().parent.parent / "assets" / "course" / "v2" / "catalog.json"
)
_OPENLESSON_SEED_RE = re.compile(
    r"(?:^|\s)(?:openlesson|agent_seed\s+openlesson)\s+(lesson-[\w-]+)",
    re.IGNORECASE,
)


def catalog_lesson_ids(catalog_path: Path | None = None) -> frozenset[str]:
    """Return every ``lesson-…`` id in the course catalog JSON."""
    path = catalog_path or _DEFAULT_CATALOG
    payload = json.loads(path.read_text(encoding="utf-8"))
    found: set[str] = set()

    def walk(node: object) -> None:
        if isinstance(node, dict):
            raw = node.get("id")
            if isinstance(raw, str) and raw.startswith("lesson-"):
                found.add(raw)
            for value in node.values():
                walk(value)
        elif isinstance(node, list):
            for value in node:
                walk(value)

    walk(payload)
    return frozenset(found)


def openlesson_seed_ids(
    targets: tuple[MotionTarget, ...] = TARGETS,
) -> list[str]:
    """Lesson ids embedded in ``openlesson …`` seeds (skips prose-only seeds)."""
    ids: list[str] = []
    for target in targets:
        match = _OPENLESSON_SEED_RE.search(target.seed)
        if match:
            ids.append(match.group(1))
    return ids


def missing_openlesson_seeds(
    targets: tuple[MotionTarget, ...] = TARGETS,
    catalog_path: Path | None = None,
) -> list[str]:
    """Return openlesson seed ids absent from the catalog (should be empty)."""
    catalog = catalog_lesson_ids(catalog_path)
    return [lesson_id for lesson_id in openlesson_seed_ids(targets) if lesson_id not in catalog]


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


def _normalize_lead(text: str) -> str:
    """Lowercase lead prose and collapse SoftPulse / hyphen variants."""
    low = text.lower()
    low = low.replace("soft pulse", "softpulse")
    low = low.replace("soft-pulse", "softpulse")
    # "suits multi-press" and "multi-press-suits" share the same tokens.
    low = re.sub(r"[-_]+", " ", low)
    return re.sub(r"\s+", " ", low).strip()


def lead_credits_motion(lead: str, motion_id: str) -> bool:
    """True when coverage lead prose claims this motion id was walked OK.

    Agents often keep ``surface`` as the densify lesson slug and write
    ``coach-transition / softpulse-breathe OK on walk`` in leads. Those
    claims must demote the motion id in ``pick``. Do not credit
    ``motion pick remaining: … still under-walked`` lists unless the id
    itself is marked OK in that lead (LPT-1026-class starvation).
    """
    raw = (lead or "").strip()
    if not raw:
        return False
    low = _normalize_lead(raw)
    tokens = LEAD_TOKENS.get(motion_id, (motion_id,))
    token_res = [
        re.compile(rf"(?<![a-z0-9]){re.escape(_normalize_lead(tok))}(?![a-z0-9])")
        for tok in tokens
    ]

    def has_token(chunk: str) -> bool:
        return any(rx.search(chunk) for rx in token_res)

    remaining_ish = (
        "remaining" in low
        or "under-walked" in low
        or "under walked" in low
    )
    if remaining_ish:
        for seg in re.split(r"[;|]", low):
            if not has_token(seg):
                continue
            if re.search(r"\bok\b", seg) and not re.search(
                r"under-?walked|still\s+under",
                seg,
            ):
                return True
        return False
    if not has_token(low):
        return False
    return bool(re.search(r"\b(ok|walked|clean)\b", low))


def last_walk_by_surface(rows: Iterable[dict]) -> dict[str, datetime]:
    """Map surface → latest walk time (field + lead OK claims)."""
    latest: dict[str, datetime] = {}
    for row in rows:
        at = _parse_at(str(row.get("at") or ""))
        surface = str(row.get("surface") or "").strip()
        if surface:
            prev = latest.get(surface)
            if prev is None or at > prev:
                latest[surface] = at
        leads = row.get("leads") or []
        if not isinstance(leads, list):
            continue
        for target in TARGETS:
            for lead in leads:
                if not lead_credits_motion(str(lead), target.id):
                    continue
                prev = latest.get(target.surface)
                if prev is None or at > prev:
                    latest[target.surface] = at
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


def cmd_check_seeds(args: argparse.Namespace) -> int:
    """Exit 1 when any openlesson seed is missing from the catalog (LPT-1027)."""
    catalog = Path(args.catalog).expanduser() if args.catalog else _DEFAULT_CATALOG
    missing = missing_openlesson_seeds(catalog_path=catalog)
    if missing:
        print(
            "missing openlesson seeds in catalog: " + ", ".join(missing),
            file=sys.stderr,
        )
        return 1
    print("ok: all openlesson motion-target seeds exist in catalog")
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
    p_check = sub.add_parser(
        "check-seeds",
        help="fail if openlesson seeds are missing from catalog.json",
    )
    p_check.add_argument(
        "--catalog",
        default=str(_DEFAULT_CATALOG),
        help="path to assets/course/v2/catalog.json",
    )
    p_check.set_defaults(func=cmd_check_seeds)
    return parser


def main(argv: list[str] | None = None) -> int:
    """CLI entrypoint."""
    args = build_parser().parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
