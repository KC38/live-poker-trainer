"""Tests for the LPT Jira REST client used by /ui-design-agent."""

from __future__ import annotations

import importlib.util
import os
import tempfile
import types
import unittest
from pathlib import Path
from typing import Any, List
from unittest import mock


def _load() -> types.ModuleType:
    """Load tools/jira.py without installing it as a package."""
    path = Path(__file__).with_name("jira.py")
    spec = importlib.util.spec_from_file_location("lpt_jira", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


jira = _load()


class MarkdownToWikiTest(unittest.TestCase):
    """The ticket template's Markdown renders as Jira wiki markup."""

    def test_headings_lists_and_inline(self) -> None:
        md = (
            "## What happened\n"
            "Tap **Continue** in `lesson_runner_screen.dart`.\n"
            "1. Fresh guest\n"
            "   1. nested step\n"
            "- a bullet\n"
            "See [LPT-36](https://livepokertrainer.atlassian.net/browse/LPT-36)."
        )
        self.assertEqual(
            jira.md_to_wiki(md),
            "h2. What happened\n"
            "Tap *Continue* in {{lesson_runner_screen.dart}}.\n"
            "# Fresh guest\n"
            "## nested step\n"
            "* a bullet\n"
            "See [LPT-36|https://livepokertrainer.atlassian.net/browse/LPT-36].",
        )

    def test_images_render_attachments_by_file_name(self) -> None:
        self.assertEqual(
            jira.md_to_wiki("![Home clipped](/tmp/ui-agent/home-1.png)"),
            "!home-1.png|thumbnail!",
        )

    def test_code_blocks_are_left_alone(self) -> None:
        md = "```markdown\n## not a heading\n- not a list\n```"
        self.assertEqual(jira.md_to_wiki(md), "{code:markdown}\n## not a heading\n- not a list\n{code}")

    def test_tables_get_a_header_row(self) -> None:
        md = "| Check | Result |\n| --- | --- |\n| Overflow | `none` |"
        self.assertEqual(jira.md_to_wiki(md), "||Check||Result||\n|Overflow|{{none}}|")


class CredentialsTest(unittest.TestCase):
    """Credentials come from the environment, then secrets.env."""

    def test_secrets_file_with_shell_quoting(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            secrets = Path(tmp) / "secrets.env"
            secrets.write_text(
                "ATLASSIAN_EMAIL=kc@example.com\nATLASSIAN_API_TOKEN=tok\\=with\\ space\n",
                encoding="utf-8",
            )
            with mock.patch.object(jira, "SECRETS_FILE", secrets), mock.patch.dict(
                os.environ, {}, clear=True
            ):
                self.assertEqual(jira.credentials(), ("kc@example.com", "tok=with space"))

    def test_environment_wins(self) -> None:
        with mock.patch.dict(
            os.environ, {"ATLASSIAN_EMAIL": "env@example.com", "ATLASSIAN_API_TOKEN": "envtok"}
        ):
            self.assertEqual(jira.credentials(), ("env@example.com", "envtok"))

    def test_missing_credentials_name_the_setup_command(self) -> None:
        with mock.patch.object(jira, "SECRETS_FILE", Path("/nonexistent/secrets.env")), mock.patch.dict(
            os.environ, {}, clear=True
        ):
            with self.assertRaises(jira.JiraError) as ctx:
                jira.credentials()
            self.assertIn("ui_design_agent_loop.sh setup", str(ctx.exception))


class OperationsTest(unittest.TestCase):
    """Operations send the right requests."""

    def setUp(self) -> None:
        self.calls: List[tuple] = []

    def _fake(self, responses: dict) -> Any:
        def fake_request(method: str, path: str, body: Any = None, **kwargs: Any) -> Any:
            self.calls.append((method, path, body, kwargs))
            for (want_method, want_path), value in responses.items():
                if method == want_method and path == want_path:
                    return value
            return None

        return fake_request

    def test_transition_matches_target_status_case_insensitively(self) -> None:
        options = {
            "transitions": [
                {"id": "21", "name": "Start work", "to": {"name": "In Progress"}},
                {"id": "41", "name": "Close", "to": {"name": "Done"}},
            ]
        }
        fake = self._fake({
            ("GET", "/3/issue/LPT-41/transitions"): options,
            ("GET", "/3/issue/LPT-41"): {"fields": {"status": {"name": "Done"}}},
        })
        with mock.patch.object(jira, "request", fake):
            self.assertEqual(jira.transition("LPT-41", "done"), "Done")
        post = [c for c in self.calls if c[0] == "POST"][0]
        self.assertEqual(post[2], {"transition": {"id": "41"}})

    def test_transition_lists_options_when_target_is_unknown(self) -> None:
        fake = self._fake({("GET", "/3/issue/LPT-41/transitions"): {"transitions": [
            {"id": "11", "name": "To Do", "to": {"name": "To Do"}}]}})
        with mock.patch.object(jira, "request", fake):
            with self.assertRaises(jira.JiraError) as ctx:
                jira.transition("LPT-41", "Shipped")
        self.assertIn("To Do -> To Do", str(ctx.exception))

    def test_create_attaches_and_shows_screenshots(self) -> None:
        fake = self._fake({("POST", "/2/issue"): {"key": "LPT-41"}})
        with mock.patch.object(jira, "request", fake), mock.patch.object(
            jira, "attach", return_value=["home-1.png", "home-2.png"]
        ) as attach:
            key = jira.create(
                "Story", "Home clips", "## What happened\n![clip](home-1.png)",
                priority="High", labels=["ui", "ui-agent"], files=["/tmp/home-1.png", "/tmp/home-2.png"],
            )
        self.assertEqual(key, "LPT-41")
        attach.assert_called_once_with("LPT-41", ["/tmp/home-1.png", "/tmp/home-2.png"])
        created = self.calls[0][2]["fields"]
        self.assertEqual(created["project"], {"key": "LPT"})
        self.assertEqual(created["labels"], ["ui", "ui-agent"])
        self.assertEqual(created["priority"], {"name": "High"})
        description = self.calls[1][2]["fields"]["description"]
        self.assertEqual(description.count("!home-1.png|thumbnail!"), 1)
        self.assertIn("!home-2.png|thumbnail!", description)

    def test_edit_adds_and_removes_labels_without_replacing(self) -> None:
        fake = self._fake({})
        with mock.patch.object(jira, "request", fake):
            jira.edit("LPT-41", add_labels=["ui-agent"], remove_labels=["needs-human"])
        self.assertEqual(
            self.calls[0][2]["update"]["labels"],
            [{"add": "ui-agent"}, {"remove": "needs-human"}],
        )

    def test_blocks_link_puts_the_blocker_inward(self) -> None:
        fake = self._fake({})
        with mock.patch.object(jira, "request", fake):
            jira.link("Blocks", "LPT-41", "LPT-42")
        body = self.calls[0][2]
        self.assertEqual(body["inwardIssue"], {"key": "LPT-41"})
        self.assertEqual(body["outwardIssue"], {"key": "LPT-42"})


if __name__ == "__main__":
    unittest.main()
