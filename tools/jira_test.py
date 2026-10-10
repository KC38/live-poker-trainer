"""Tests for the LPT Jira REST client used by /ui-design-agent."""

from __future__ import annotations

import importlib.util
import io
import os
import tempfile
import types
import unittest
import urllib.error
from email.message import Message
from pathlib import Path
from typing import Any, Dict, List
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
        with tempfile.TemporaryDirectory() as tmp:
            home1 = Path(tmp) / "home-1.png"
            home2 = Path(tmp) / "home-2.png"
            home1.write_bytes(b"png1")
            home2.write_bytes(b"png2")
            with mock.patch.object(jira, "request", fake), mock.patch.object(
                jira, "attach", return_value=["home-1.png", "home-2.png"]
            ) as attach:
                key = jira.create(
                    "Story",
                    "Home clips",
                    f"## What happened\n![clip]({home1})",
                    priority="High",
                    labels=["ui", "ui-agent"],
                    files=[str(home1), str(home2)],
                )
        self.assertEqual(key, "LPT-41")
        attach.assert_called_once()
        self.assertEqual(attach.call_args.args[0], "LPT-41")
        self.assertEqual(
            {Path(p).name for p in attach.call_args.args[1]},
            {"home-1.png", "home-2.png"},
        )
        created = self.calls[0][2]["fields"]
        self.assertEqual(created["project"], {"key": "LPT"})
        self.assertEqual(created["labels"], ["ui", "ui-agent"])
        self.assertEqual(created["priority"], {"name": "High"})
        # Initial create must not embed thumbs before upload is confirmed.
        self.assertNotIn("!home-1.png", created["description"])
        description = self.calls[1][2]["fields"]["description"]
        self.assertEqual(description.count("!home-1.png|thumbnail!"), 1)
        self.assertIn("!home-2.png|thumbnail!", description)

    def test_comment_refuses_orphan_wiki_embeds(self) -> None:
        fake = self._fake({
            ("GET", "/2/issue/LPT-59"): {
                "fields": {"attachment": [{"filename": "LPT-59-before.png"}]},
            },
        })
        with mock.patch.object(jira, "request", fake), mock.patch.object(
            jira, "attach", return_value=["LPT-59-before.png"]
        ):
            with self.assertRaises(jira.JiraError) as ctx:
                jira.comment(
                    "LPT-59",
                    "![validated](LPT-59-validated.png)\n![before](LPT-59-before.png)",
                    files=[],
                )
        self.assertIn("LPT-59-validated.png", str(ctx.exception))
        self.assertFalse(any(c[0] == "POST" and c[1].endswith("/comment") for c in self.calls))

    def test_attach_rejects_missing_and_empty_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            missing = Path(tmp) / "nope.png"
            empty = Path(tmp) / "empty.png"
            empty.write_bytes(b"")
            with self.assertRaises(jira.JiraError) as missing_ctx:
                jira.attach("LPT-59", [str(missing)])
            self.assertIn("not a file", str(missing_ctx.exception))
            with self.assertRaises(jira.JiraError) as empty_ctx:
                jira.attach("LPT-59", [str(empty)])
            self.assertIn("empty file", str(empty_ctx.exception))

    def test_attach_requires_returned_filename(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "shot.png"
            path.write_bytes(b"png")
            fake = self._fake({("POST", "/3/issue/LPT-59/attachments"): []})
            with mock.patch.object(jira, "request", fake):
                with self.assertRaises(jira.JiraError) as ctx:
                    jira.attach("LPT-59", [str(path)])
            self.assertIn("did not return that file name", str(ctx.exception))

    def test_wiki_embed_names_require_image_extension(self) -> None:
        wiki = (
            "!LPT-60-validated.png|thumbnail!\n"
            "plain !emphasis! is not an image\n"
            "!shot.JPG|thumbnail!"
        )
        self.assertEqual(
            jira._wiki_embed_names(wiki),
            ["LPT-60-validated.png", "shot.JPG"],
        )

    def test_verify_embeds_lists_orphans(self) -> None:
        fake = self._fake({
            ("GET", "/2/issue/LPT-60"): {
                "fields": {
                    "attachment": [{"filename": "LPT-60-hint.png"}],
                    "description": "!lesson-issue.png|thumbnail!",
                    "comment": {
                        "comments": [
                            {
                                "id": "10167",
                                "body": "!LPT-60-validated.png|thumbnail!\n!LPT-60-hint.png|thumbnail!",
                            }
                        ]
                    },
                }
            }
        })
        with mock.patch.object(jira, "request", fake):
            report = jira.verify_embeds(["LPT-60"])
        self.assertEqual(
            report,
            [
                "LPT-60\tdescription\tlesson-issue.png",
                "LPT-60\tcomment:10167\tLPT-60-validated.png",
            ],
        )

    def test_repair_embeds_strips_orphans(self) -> None:
        issue = {
            "fields": {
                "attachment": [{"filename": "LPT-60-hint.png"}],
                "description": "Before\n\n!missing.png|thumbnail!\n\nAfter",
                "comment": {
                    "comments": [
                        {
                            "id": "10167",
                            "body": "ok\n!LPT-60-validated.png|thumbnail!\n!LPT-60-hint.png|thumbnail!",
                        }
                    ]
                },
            }
        }
        fake = self._fake({("GET", "/2/issue/LPT-60"): issue})
        with mock.patch.object(jira, "request", fake):
            changed = jira.repair_embeds(["LPT-60"])
        self.assertEqual(
            changed,
            [
                "LPT-60\tdescription\tstripped orphans",
                "LPT-60\tcomment:10167\tstripped orphans",
            ],
        )
        put_desc = [c for c in self.calls if c[0] == "PUT" and c[1] == "/2/issue/LPT-60"][0]
        self.assertNotIn("missing.png", put_desc[2]["fields"]["description"])
        put_comment = [
            c for c in self.calls if c[0] == "PUT" and c[1].endswith("/comment/10167")
        ][0]
        self.assertNotIn("LPT-60-validated.png", put_comment[2]["body"])
        self.assertIn("!LPT-60-hint.png|thumbnail!", put_comment[2]["body"])

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


class SearchTest(unittest.TestCase):
    """Search pages with nextPageToken and stops instead of looping."""

    def test_search_follows_the_next_page_until_last(self) -> None:
        pages = [
            {
                "issues": [{"key": "LPT-1"}],
                "isLast": False,
                "nextPageToken": "page-2",
            },
            {"issues": [{"key": "LPT-2"}], "isLast": True},
        ]
        queries: List[Dict[str, Any]] = []
        paths: List[str] = []

        def fake_request(
            method: str,
            path: str,
            body: Any = None,
            query: Any = None,
            **kwargs: Any,
        ) -> Any:
            self.assertEqual(method, "GET")
            paths.append(path)
            queries.append(dict(query or {}))
            return pages[len(queries) - 1]

        with mock.patch.object(jira, "request", fake_request):
            found = jira.search("project = LPT ORDER BY key", limit=10)
        self.assertEqual([item["key"] for item in found], ["LPT-1", "LPT-2"])
        self.assertEqual(paths, ["/3/search/jql", "/3/search/jql"])
        self.assertNotIn("nextPageToken", queries[0])
        self.assertEqual(queries[1]["nextPageToken"], "page-2")
        self.assertEqual(queries[0]["jql"], "project = LPT ORDER BY key")
        self.assertEqual(queries[0]["maxResults"], 10)

    def test_search_stops_once_the_page_fills_the_limit(self) -> None:
        calls = 0

        def fake_request(
            method: str,
            path: str,
            body: Any = None,
            query: Any = None,
            **kwargs: Any,
        ) -> Any:
            nonlocal calls
            calls += 1
            self.assertEqual(query["maxResults"], 2)
            return {
                "issues": [{"key": "LPT-1"}, {"key": "LPT-2"}],
                "isLast": False,
                "nextPageToken": "more",
            }

        with mock.patch.object(jira, "request", fake_request):
            found = jira.search("project = LPT", limit=2)
        self.assertEqual(calls, 1)
        self.assertEqual([item["key"] for item in found], ["LPT-1", "LPT-2"])

    def test_search_does_not_follow_a_token_when_is_last_is_omitted(self) -> None:
        calls = 0

        def fake_request(
            method: str,
            path: str,
            body: Any = None,
            query: Any = None,
            **kwargs: Any,
        ) -> Any:
            nonlocal calls
            calls += 1
            return {"issues": [{"key": "LPT-9"}], "nextPageToken": "again"}

        with mock.patch.object(jira, "request", fake_request):
            found = jira.search("project = LPT", limit=50)
        self.assertEqual(calls, 1)
        self.assertEqual(found[0]["key"], "LPT-9")


class RequestFailureTest(unittest.TestCase):
    """HTTP and network failures become JiraError text the agent can read."""

    def test_http_401_keeps_the_status_and_body(self) -> None:
        err = urllib.error.HTTPError(
            "https://api.atlassian.com/ex/jira/x/rest/api/3/myself",
            401,
            "Unauthorized",
            Message(),
            io.BytesIO(b'{"message":"scope refused"}'),
        )
        with mock.patch.object(jira, "credentials", return_value=("a@b.c", "tok")), mock.patch.object(
            jira.urllib.request, "urlopen", side_effect=err
        ):
            with self.assertRaises(jira.JiraError) as ctx:
                jira.request("GET", "/3/myself")
        message = str(ctx.exception)
        self.assertIn("GET /3/myself", message)
        self.assertIn("HTTP 401", message)
        self.assertIn("scope refused", message)

    def test_url_error_names_the_reason(self) -> None:
        err = urllib.error.URLError("timed out")
        with mock.patch.object(jira, "credentials", return_value=("a@b.c", "tok")), mock.patch.object(
            jira.urllib.request, "urlopen", side_effect=err
        ):
            with self.assertRaises(jira.JiraError) as ctx:
                jira.request("GET", "/3/myself")
        self.assertIn("GET /3/myself failed: timed out", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
