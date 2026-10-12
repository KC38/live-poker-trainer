#!/usr/bin/env python3
"""Jump the simulator guest straight to a course state (debug agent tool).

Walking prerequisite lessons by tapping costs minutes, trips the course
rate limit ("Too many course requests"), and left later lessons
unreachable. This writes the *simulator guest's* course profile directly
with Firestore admin access, then optionally opens the lesson:

    python3 tools/agent_seed.py lessons --grep blinds
    python3 tools/agent_seed.py unlock --lesson "Hand ranks" --open
    python3 tools/agent_seed.py fresh --lesson "Best five" --open
    python3 tools/agent_seed.py unlock --lesson lesson-02-01-01 --hearts 0
    python3 tools/agent_seed.py hearts 1
    python3 tools/agent_seed.py gems 50

`unlock` marks every transitive prerequisite of the lesson complete
(`users/{uid}/course/main.completedLessonIds`), so the server lets that
lesson start. `fresh` sets completedLessonIds to **exactly** those
prerequisites — clearing the lesson itself and any later progress — so a
completed lesson is not opened in review mode (SoftPulse/cues hidden).
`fresh` also nulls `course/main.resume` (and `currentLessonId` when it
names that lesson) and deletes open `courseAttempts` for the lesson so
`openlesson` lands on activity 0 instead of mid-lesson resume (LPT-76).
Hearts/gems set the wallet for refill/restore checks.

Safety: the uid comes from the running debug app (`whoami`), the profile
must already exist (finish onboarding first), and signed-in accounts are
refused unless `--allow-account`. Auth uses `FIREBASE_TOKEN` (env or
`~/.live-poker-trainer/secrets.env`), the same token functions deploys use.
Only the simulator lock holder may run it.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import sys
import types
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

PROJECT = "live-poker-trainer"
ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "functions/src/generated/course_bank.json"
SECRETS = Path.home() / ".live-poker-trainer/secrets.env"
FIRESTORE = (
    f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"
)
# Public OAuth client that `firebase login:ci` refresh tokens are minted for
# (published in firebase-tools). Needed to exchange FIREBASE_TOKEN.
FIREBASE_CLI_CLIENT_ID = (
    "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com"
)
FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi"


def _load_agent_tap() -> types.ModuleType:
    """Load the sibling agent_tap.py (VM-service client + lock guard)."""
    path = Path(__file__).with_name("agent_tap.py")
    spec = importlib.util.spec_from_file_location("agent_tap", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def load_lessons(catalog: Path = CATALOG) -> list[dict[str, Any]]:
    """All catalog lessons in course order with id, title, prerequisites."""
    data = json.loads(catalog.read_text(encoding="utf-8"))
    lessons = []
    for section in data["sections"]:
        for unit in section["units"]:
            for lesson in unit["lessons"]:
                lessons.append(
                    {
                        "id": lesson["id"],
                        "title": lesson.get("title", ""),
                        "prerequisites": list(lesson.get("prerequisites", [])),
                    }
                )
    return lessons


def resolve_lesson(lessons: list[dict[str, Any]], needle: str) -> dict[str, Any]:
    """Match by exact id, id prefix, or case-insensitive title."""
    lowered = needle.strip().lower()
    for lesson in lessons:
        if lesson["id"] == needle:
            return lesson
    matches = [
        lesson
        for lesson in lessons
        if lesson["id"].startswith(needle) or lesson["title"].lower() == lowered
    ]
    if len(matches) == 1:
        return matches[0]
    if not matches:
        raise SystemExit(f"agent_seed: no lesson matches {needle!r} (try `lessons --grep`)")
    names = ", ".join(f"{m['id']} ({m['title']})" for m in matches[:5])
    raise SystemExit(f"agent_seed: {needle!r} is ambiguous: {names}")


def prerequisite_closure(
    lessons: list[dict[str, Any]], lesson_id: str
) -> list[str]:
    """Every lesson that must be complete before [lesson_id], course order."""
    by_id = {lesson["id"]: lesson for lesson in lessons}
    needed: set[str] = set()
    stack = list(by_id[lesson_id]["prerequisites"])
    while stack:
        current = stack.pop()
        if current in needed or current not in by_id:
            continue
        needed.add(current)
        stack.extend(by_id[current]["prerequisites"])
    return [lesson["id"] for lesson in lessons if lesson["id"] in needed]


def string_array(values: list[str]) -> dict[str, Any]:
    """Firestore REST arrayValue of strings."""
    return {"arrayValue": {"values": [{"stringValue": v} for v in values]}}


def read_string_array(field: dict[str, Any] | None) -> list[str]:
    """Decode a Firestore REST arrayValue of strings (missing → [])."""
    if not field:
        return []
    values = field.get("arrayValue", {}).get("values", [])
    return [v["stringValue"] for v in values if "stringValue" in v]


def read_int(field: dict[str, Any] | None, default: int) -> int:
    """Decode a Firestore REST integer/double field."""
    if not field:
        return default
    if "integerValue" in field:
        return int(field["integerValue"])
    if "doubleValue" in field:
        return int(field["doubleValue"])
    return default


def _firebase_token() -> str:
    """FIREBASE_TOKEN from the environment or the loop's secrets file."""
    token = os.environ.get("FIREBASE_TOKEN", "").strip()
    if token or not SECRETS.is_file():
        return token
    for line in SECRETS.read_text(encoding="utf-8").splitlines():
        if line.startswith("FIREBASE_TOKEN="):
            return line.split("=", 1)[1].strip().strip("'\"")
    return ""


def access_token() -> str:
    """Exchange FIREBASE_TOKEN for a short-lived Google access token."""
    refresh = _firebase_token()
    if not refresh:
        raise SystemExit("agent_seed: FIREBASE_TOKEN missing (env or secrets.env)")
    body = urllib.parse.urlencode(
        {
            "client_id": FIREBASE_CLI_CLIENT_ID,
            "client_secret": FIREBASE_CLI_CLIENT_SECRET,
            "refresh_token": refresh,
            "grant_type": "refresh_token",
        }
    ).encode()
    try:
        with urllib.request.urlopen("https://oauth2.googleapis.com/token", body) as resp:
            return json.load(resp)["access_token"]
    except urllib.error.HTTPError as exc:
        raise SystemExit(f"agent_seed: token exchange failed ({exc.code})") from exc


def _request(method: str, url: str, token: str, body: Any = None) -> dict[str, Any]:
    """Authenticated Firestore REST call returning decoded JSON ({} if empty)."""
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read()
            if not raw:
                return {}
            return json.loads(raw.decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", "replace")[:300]
        raise SystemExit(f"agent_seed: Firestore {method} {exc.code}: {detail}") from exc


def profile_url(uid: str) -> str:
    """REST URL of the guest's course profile document."""
    return f"{FIRESTORE}/users/{urllib.parse.quote(uid)}/course/main"


def attempts_collection_url(uid: str) -> str:
    """REST URL of the guest's courseAttempts collection."""
    return f"{FIRESTORE}/users/{urllib.parse.quote(uid)}/courseAttempts"


def patch_profile(uid: str, token: str, fields: dict[str, Any]) -> None:
    """Update only [fields]; fail when the profile does not exist."""
    params = [("updateMask.fieldPaths", name) for name in fields]
    params.append(("currentDocument.exists", "true"))
    url = f"{profile_url(uid)}?{urllib.parse.urlencode(params)}"
    _request("PATCH", url, token, {"fields": fields})


def list_attempt_documents(uid: str, token: str) -> list[dict[str, Any]]:
    """All courseAttempts documents for [uid] (paginated)."""
    docs: list[dict[str, Any]] = []
    page_token = ""
    while True:
        params: list[tuple[str, str]] = [("pageSize", "100")]
        if page_token:
            params.append(("pageToken", page_token))
        url = f"{attempts_collection_url(uid)}?{urllib.parse.urlencode(params)}"
        payload = _request("GET", url, token)
        docs.extend(payload.get("documents") or [])
        page_token = payload.get("nextPageToken") or ""
        if not page_token:
            break
    return docs


def clear_open_attempts(uid: str, token: str, lesson_id: str) -> int:
    """Delete in_progress/remediation courseAttempts for [lesson_id]."""
    deleted = 0
    for doc in list_attempt_documents(uid, token):
        fields = doc.get("fields") or {}
        lesson = (fields.get("lessonId") or {}).get("stringValue")
        status = (fields.get("status") or {}).get("stringValue")
        if lesson != lesson_id or status not in ("in_progress", "remediation"):
            continue
        name = doc.get("name")
        if not name:
            continue
        _request("DELETE", f"https://firestore.googleapis.com/v1/{name}", token)
        deleted += 1
    return deleted


def apply_fresh_resume_clear(
    profile: dict[str, Any], lesson_id: str
) -> dict[str, Any]:
    """Profile field patches that drop mid-lesson resume for [lesson_id]."""
    fields: dict[str, Any] = {"resume": {"nullValue": None}}
    current = (profile.get("currentLessonId") or {}).get("stringValue")
    if current == lesson_id:
        fields["currentLessonId"] = {"nullValue": None}
    return fields


def current_guest(agent_tap: types.ModuleType, log: Path, allow_account: bool) -> str:
    """Uid of the app's signed-in user; refuses real accounts by default."""
    try:
        who = agent_tap.query("whoami", log=log) or {}
    except SystemExit as exc:
        raise SystemExit(
            f"agent_seed: whoami failed ({exc}); is this build older than the query?"
        ) from exc
    uid = who.get("uid")
    if not uid:
        raise SystemExit("agent_seed: no signed-in user yet; finish onboarding first")
    if not who.get("isAnonymous") and not allow_account:
        raise SystemExit(
            "agent_seed: refusing to edit a signed-in account (pass --allow-account)"
        )
    return uid


def build_parser() -> argparse.ArgumentParser:
    """CLI parser."""
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("--log", type=Path, default=Path("/tmp/flutter-live-poker-trainer.run.log"))
    parser.add_argument("--run-id", default=None, help="Sim lock run id (default $SIM_LOCK_RUN_ID)")
    parser.add_argument("--allow-account", action="store_true")
    sub = parser.add_subparsers(dest="action", required=True)

    lessons = sub.add_parser("lessons", help="List lesson ids and titles")
    lessons.add_argument("--grep", default="")

    unlock = sub.add_parser("unlock", help="Complete a lesson's prerequisites")
    unlock.add_argument("--lesson", required=True, help="Lesson id, id prefix, or title")
    unlock.add_argument("--hearts", type=int, default=None)
    unlock.add_argument("--gems", type=int, default=None)
    unlock.add_argument("--open", action="store_true", help="openlesson after seeding")

    fresh = sub.add_parser(
        "fresh",
        help="Prereqs only; clear resume/open attempts for activity-0 SoftPulse",
    )
    fresh.add_argument("--lesson", required=True, help="Lesson id, id prefix, or title")
    fresh.add_argument("--hearts", type=int, default=None)
    fresh.add_argument("--gems", type=int, default=None)
    fresh.add_argument("--open", action="store_true", help="openlesson after seeding")

    hearts = sub.add_parser("hearts", help="Set livesRemaining")
    hearts.add_argument("count", type=int)

    gems = sub.add_parser("gems", help="Set the gem balance")
    gems.add_argument("count", type=int)
    return parser


def main(argv: list[str]) -> int:
    """CLI entrypoint."""
    args = build_parser().parse_args(argv)
    lessons = load_lessons()
    if args.action == "lessons":
        needle = args.grep.lower()
        for lesson in lessons:
            if needle in lesson["id"].lower() or needle in lesson["title"].lower():
                print(f"{lesson['id']}\t{lesson['title']}")
        return 0

    agent_tap = _load_agent_tap()
    lock_args = ["guard"] + (["--run-id", args.run_id] if args.run_id else [])
    if agent_tap.sim_lock.main(lock_args) != agent_tap.sim_lock.EXIT_OK:
        raise SystemExit("agent_seed: the iPhone 13 mini lock is not yours")
    uid = current_guest(agent_tap, args.log, args.allow_account)
    token = access_token()
    profile = _request("GET", profile_url(uid), token).get("fields", {})
    fields: dict[str, Any] = {}
    lives_max = read_int(profile.get("livesMax"), 5)

    target = None
    if args.action == "unlock":
        target = resolve_lesson(lessons, args.lesson)
        done = read_string_array(profile.get("completedLessonIds"))
        needed = prerequisite_closure(lessons, target["id"])
        merged = done + [lesson_id for lesson_id in needed if lesson_id not in done]
        fields["completedLessonIds"] = string_array(merged)
        print(
            f"unlock {target['id']} ({target['title']}): "
            f"+{len(merged) - len(done)} prerequisite(s), {len(merged)} complete"
        )
    elif args.action == "fresh":
        target = resolve_lesson(lessons, args.lesson)
        done = read_string_array(profile.get("completedLessonIds"))
        needed = prerequisite_closure(lessons, target["id"])
        fields["completedLessonIds"] = string_array(needed)
        fields.update(apply_fresh_resume_clear(profile, target["id"]))
        removed = [lesson_id for lesson_id in done if lesson_id not in needed]
        abandoned = clear_open_attempts(uid, token, target["id"])
        print(
            f"fresh {target['id']} ({target['title']}): "
            f"{len(needed)} prerequisite(s), cleared {len(removed)} completed id(s), "
            f"resume reset, abandoned {abandoned} open attempt(s)"
        )
    hearts = args.count if args.action == "hearts" else getattr(args, "hearts", None)
    if hearts is not None:
        hearts = max(0, min(hearts, lives_max))
        fields["livesRemaining"] = {"integerValue": str(hearts)}
        if hearts >= lives_max:
            fields["livesNextRefillAtMs"] = {"nullValue": None}
        print(f"hearts -> {hearts}/{lives_max}")
    gems = args.count if args.action == "gems" else getattr(args, "gems", None)
    if gems is not None:
        fields["gems"] = {"integerValue": str(max(0, gems))}
        print(f"gems -> {max(0, gems)}")

    if fields:
        patch_profile(uid, token, fields)
        print(f"seeded guest {uid[:8]}…")
    if target is not None and args.open:
        agent_tap.agent("openlesson", log=args.log, text=target["id"])
    elif fields:
        print("open a lesson (agent_tap openlesson) or relaunch to see the new state")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
