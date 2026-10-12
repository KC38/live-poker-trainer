#!/usr/bin/env python3
"""Tests for tools/ui_agent_coverage.py."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from ui_agent_coverage import append_row, build_row, main, now_iso


class UiAgentCoverageTest(unittest.TestCase):
    """Coverage append helper contracts."""

    def test_now_iso_uses_colon_offset(self) -> None:
        stamp = now_iso()
        self.assertRegex(stamp, r"[+-]\d{2}:\d{2}$")

    def test_build_row_defaults_at(self) -> None:
        row = build_row(
            sha="abc",
            surface="lesson-runner:x",
            result="closed",
            ticket="LPT-1",
            learnings="unchanged",
            leads=["next"],
        )
        self.assertEqual(row["ticket"], "LPT-1")
        self.assertEqual(row["leads"], ["next"])
        self.assertRegex(row["at"], r"[+-]\d{2}:\d{2}$")

    def test_rejects_compact_offset(self) -> None:
        with self.assertRaises(ValueError):
            build_row(
                sha="abc",
                surface="lesson-runner:x",
                result="closed",
                ticket="LPT-1",
                learnings="unchanged",
                at="2026-10-12T21:48:30+0530",
            )

    def test_append_cli(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "coverage.jsonl"
            code = main(
                [
                    "append",
                    "--file",
                    str(path),
                    "--sha",
                    "deadbeef",
                    "--surface",
                    "lesson-runner:foo",
                    "--result",
                    "closed",
                    "--ticket",
                    "LPT-503",
                    "--learnings",
                    "unchanged",
                    "--lead",
                    "LPT-504 next",
                ]
            )
            self.assertEqual(code, 0)
            rows = [
                json.loads(line)
                for line in path.read_text(encoding="utf-8").splitlines()
                if line.strip()
            ]
            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0]["ticket"], "LPT-503")
            self.assertRegex(rows[0]["at"], r"[+-]\d{2}:\d{2}$")
            append_row(path, rows[0])
            self.assertEqual(len(path.read_text(encoding="utf-8").splitlines()), 2)


if __name__ == "__main__":
    unittest.main()
