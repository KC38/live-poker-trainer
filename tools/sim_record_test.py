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

    def test_extract_frames_falls_back_on_subsecond_clip(self) -> None:
        """fps=1 on a 0.2s clip yields no PNGs without the still fallback."""
        if subprocess.run(["which", "ffmpeg"], capture_output=True).returncode != 0:
            self.skipTest("ffmpeg not installed")
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            video = root / "short.mp4"
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
                    "color=c=blue:s=320x240:d=0.2",
                    "-c:v",
                    "libx264",
                    "-pix_fmt",
                    "yuv420p",
                    str(video),
                ],
                check=True,
            )
            frames = sim_record.extract_frames(
                video, root / "frames", every=1.0, max_frames=8
            )
            self.assertEqual(len(frames), 1)
            self.assertTrue(frames[0].is_file())
            self.assertGreater(frames[0].stat().st_size, 0)

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

    def test_wait_stable_video_rejects_missing_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "missing.mp4"
            with self.assertRaises(SystemExit) as ctx:
                sim_record.wait_stable_video(
                    path, timeout=0.25, settle=0.05, poll=0.05
                )
            self.assertIn("size=0", str(ctx.exception))

    def test_wait_stable_video_resets_settle_when_size_grows(self) -> None:
        """A clip that passes the byte floor and then grows is not ready yet."""
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "clip.mp4"
            path.write_bytes(b"x")
            clock = {"t": 0.0}
            floor = sim_record.MIN_VIDEO_BYTES
            plan = [floor, floor, floor + 400, floor + 400, floor + 400]
            seen = {"i": 0}
            big_at = {"t": -1.0}

            def monotonic() -> float:
                return clock["t"]

            def sleep(dt: float) -> None:
                clock["t"] += dt

            real_stat = path.stat

            def stat(*_args: object, **_kwargs: object) -> object:
                index = min(seen["i"], len(plan) - 1)
                size = plan[index]
                seen["i"] += 1
                if size > floor and big_at["t"] < 0:
                    big_at["t"] = clock["t"]
                path.write_bytes(b"x" * size)
                return real_stat()

            with (
                mock.patch.object(sim_record.time, "monotonic", monotonic),
                mock.patch.object(sim_record.time, "sleep", sleep),
                mock.patch.object(Path, "is_file", lambda _self: True),
                mock.patch.object(Path, "stat", stat),
            ):
                size = sim_record.wait_stable_video(
                    path,
                    timeout=5.0,
                    settle=0.3,
                    poll=0.1,
                )
            self.assertEqual(size, floor + 400)
            # Growth must restart the settle window. Returning on the first
            # plateau, or keeping its timer across the jump, finishes sooner
            # than `settle` after the larger size first appears.
            self.assertGreaterEqual(clock["t"] - big_at["t"], 0.3)


if __name__ == "__main__":
    unittest.main()
