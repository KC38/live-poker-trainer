"""Tests for agent_seed lesson resolution and Firestore encoding."""

from __future__ import annotations

import importlib.util
import types
import unittest
from pathlib import Path


def _load() -> types.ModuleType:
    """Load tools/agent_seed.py without installing it as a package."""
    path = Path(__file__).with_name("agent_seed.py")
    spec = importlib.util.spec_from_file_location("agent_seed", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


agent_seed = _load()

LESSONS = [
    {"id": "lesson-01-01-01-your-two-cards", "title": "Your two cards", "prerequisites": []},
    {
        "id": "lesson-01-01-02-suits-and-ranks",
        "title": "Suits and ranks",
        "prerequisites": ["lesson-01-01-01-your-two-cards"],
    },
    {
        "id": "lesson-01-01-03-blinds-and-button",
        "title": "Button and blinds",
        "prerequisites": ["lesson-01-01-02-suits-and-ranks"],
    },
]


class ResolveTest(unittest.TestCase):
    """Lesson needles resolve by id, prefix, or title."""

    def test_title_is_case_insensitive(self) -> None:
        lesson = agent_seed.resolve_lesson(LESSONS, "button AND blinds")
        self.assertEqual(lesson["id"], "lesson-01-01-03-blinds-and-button")

    def test_id_prefix(self) -> None:
        lesson = agent_seed.resolve_lesson(LESSONS, "lesson-01-01-02")
        self.assertEqual(lesson["title"], "Suits and ranks")

    def test_ambiguous_prefix_fails(self) -> None:
        with self.assertRaises(SystemExit):
            agent_seed.resolve_lesson(LESSONS, "lesson-01-01")


class ClosureTest(unittest.TestCase):
    """Prerequisites are transitive and in course order."""

    def test_chain(self) -> None:
        self.assertEqual(
            agent_seed.prerequisite_closure(LESSONS, "lesson-01-01-03-blinds-and-button"),
            ["lesson-01-01-01-your-two-cards", "lesson-01-01-02-suits-and-ranks"],
        )

    def test_first_lesson_needs_nothing(self) -> None:
        self.assertEqual(
            agent_seed.prerequisite_closure(LESSONS, "lesson-01-01-01-your-two-cards"),
            [],
        )

    def test_fresh_profile_is_exactly_prerequisites(self) -> None:
        """`fresh` writes only the prereq closure — not the lesson itself."""
        lesson_id = "lesson-01-01-03-blinds-and-button"
        self.assertEqual(
            agent_seed.prerequisite_closure(LESSONS, lesson_id),
            ["lesson-01-01-01-your-two-cards", "lesson-01-01-02-suits-and-ranks"],
        )
        self.assertNotIn(lesson_id, agent_seed.prerequisite_closure(LESSONS, lesson_id))

    def test_real_catalog_loads(self) -> None:
        lessons = agent_seed.load_lessons()
        self.assertGreater(len(lessons), 50)
        last = lessons[-1]["id"]
        self.assertGreater(len(agent_seed.prerequisite_closure(lessons, last)), 10)


class EncodingTest(unittest.TestCase):
    """Firestore REST values round-trip."""

    def test_string_array_round_trip(self) -> None:
        encoded = agent_seed.string_array(["a", "b"])
        self.assertEqual(agent_seed.read_string_array(encoded), ["a", "b"])
        self.assertEqual(agent_seed.read_string_array(None), [])

    def test_read_int(self) -> None:
        self.assertEqual(agent_seed.read_int({"integerValue": "3"}, 5), 3)
        self.assertEqual(agent_seed.read_int({"doubleValue": 4.0}, 5), 4)
        self.assertEqual(agent_seed.read_int(None, 5), 5)


class FreshResumeClearTest(unittest.TestCase):
    """fresh always nulls resume; currentLessonId only when it matches."""

    def test_nulls_resume_and_matching_current_lesson(self) -> None:
        lesson_id = "lesson-01-01-03-blinds-and-button"
        fields = agent_seed.apply_fresh_resume_clear(
            {
                "resume": {
                    "mapValue": {
                        "fields": {
                            "lessonId": {"stringValue": lesson_id},
                            "attemptId": {"stringValue": "att-1"},
                        }
                    }
                },
                "currentLessonId": {"stringValue": lesson_id},
            },
            lesson_id,
        )
        self.assertEqual(fields["resume"], {"nullValue": None})
        self.assertEqual(fields["currentLessonId"], {"nullValue": None})

    def test_keeps_other_current_lesson(self) -> None:
        fields = agent_seed.apply_fresh_resume_clear(
            {"currentLessonId": {"stringValue": "lesson-other"}},
            "lesson-01-01-03-blinds-and-button",
        )
        self.assertEqual(fields["resume"], {"nullValue": None})
        self.assertNotIn("currentLessonId", fields)


if __name__ == "__main__":
    unittest.main()
