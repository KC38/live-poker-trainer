#!/usr/bin/env python3
"""Unit tests for tools/sim_record.py (no live simulator required)."""

from __future__ import annotations

import importlib.util
import subprocess
import tempfile
import types
import unittest
from pathlib import Path
from unittest import mock


def _load() -> types.ModuleType:
    """Load tools/sim_record.py."""
    path = Path(__file__).with_name("sim_record.py")
    spec = importlib.util.spec_from_file_location("sim_record", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


sim_record = _load()


class SimRecordCmdTest(unittest.TestCase):
    """Argv builders and frame extraction."""

    def test_record_video_cmd_uses_h264_force(self) -> None:
        cmd = sim_record.record_video_cmd(
            "UDID-1", Path("/tmp/clip.mp4"), codec="h264"
        )
        self.assertEqual(cmd[0:5], ["xcrun", "simctl", "io", "UDID-1", "recordVideo"])
        self.assertIn("--codec=h264", cmd)
        self.assertIn("--force", cmd)
        self.assertEqual(cmd[-1], "/tmp/clip.mp4")

    def test_extract_frames_from_generated_mp4(self) -> None:
        if subprocess.run(["which", "ffmpeg"], capture_output=True).returncode != 0:
            self.skipTest("ffmpeg not installed")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            video = root / "demo.mp4"
            # 3s solid color so fps=1 yields multiple frames.
            subprocess.run(
                [
                    "ffmpeg",
                    "-hide_banner",
                    "-loglevel",
                    "error",
                    "-y",
                    "-f",
                    "lavfi",
                    "-i",
                    "color=c=red:s=320x240:d=3",
                    "-c:v",
                    "libx264",
                    "-pix_fmt",
                    "yuv420p",
                    str(video),
                ],
                check=True,
            )
            frames = sim_record.extract_frames(
                video, root / "frames", every=1.0, max_frames=3
            )
            self.assertGreaterEqual(len(frames), 1)
            self.assertLessEqual(len(frames), 3)
            for frame in frames:
                self.assertTrue(frame.is_file())
                self.assertGreater(frame.stat().st_size, 0)
                self.assertTrue(frame.name.startswith("demo-frame-"))

    def test_parser_record_defaults(self) -> None:
        args = sim_record.build_parser().parse_args(
            ["record", "--out", "/tmp/a.mp4"]
        )
        self.assertEqual(args.seconds, sim_record.DEFAULT_SECONDS)
        self.assertEqual(args.codec, "h264")

    def test_cmd_record_guards_lock(self) -> None:
        args = sim_record.build_parser().parse_args(
            ["record", "--out", "/tmp/a.mp4", "--seconds", "1"]
        )
        with mock.patch.object(sim_record.sim_lock, "main", return_value=3):
            with self.assertRaises(SystemExit) as ctx:
                sim_record.cmd_record(args)
        self.assertIn("lock is not yours", str(ctx.exception))

    def test_wait_stable_video_accepts_settled_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "clip.mp4"
            path.write_bytes(b"x" * (sim_record.MIN_VIDEO_BYTES + 10))
            size = sim_record.wait_stable_video(
                path, timeout=2.0, settle=0.05, poll=0.02
            )
            self.assertGreaterEqual(size, sim_record.MIN_VIDEO_BYTES)

    def test_wait_stable_video_rejects_tiny_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "clip.mp4"
            path.write_bytes(b"tiny")
            with self.assertRaises(SystemExit) as ctx:
                sim_record.wait_stable_video(
                    path, timeout=0.35, settle=0.05, poll=0.05
                )
            self.assertIn("not ready", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
