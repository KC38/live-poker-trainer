#!/usr/bin/env python3
"""Record the iPhone 13 mini simulator to MP4 (and extract review frames).

Static screenshots miss SoftPulse timing, Hint waves, deal animations, and
coach transitions. Prefer a short clip for those judgments; extract PNGs so
agents can still Read frames. Attach the MP4 to Jira for humans.

Commands:

  record --out PATH [--seconds N] [--codec h264|hevc]
      Guard the sim lock, run ``simctl io … recordVideo``, wait until
      "Recording started", then record for N seconds (default 10) and
      finalize with SIGINT. Prints the output path.

  frames --video PATH --out-dir DIR [--every SEC] [--max N]
      Extract up to N PNGs via ffmpeg (default every 1.0s, max 8).
      Prints frame paths one per line.

  start --out PATH [--codec h264|hevc]
      Begin a background recording (pid under ~/.live-poker-trainer/).

  stop
      SIGINT the background recording and wait for finalize.

Only the sim-lock holder may record. Pass ``--run-id`` or ``$SIM_LOCK_RUN_ID``.
"""

from __future__ import annotations

import argparse
import importlib.util
import os
import signal
import subprocess
import sys
import time
import types
from pathlib import Path
from typing import Any, Sequence


def _load_module(name: str) -> types.ModuleType:
    """Load a sibling tools/*.py module."""
    path = Path(__file__).with_name(f"{name}.py")
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


sim_lock = _load_module("sim_lock")

DEFAULT_SECONDS = 10.0
DEFAULT_CODEC = "h264"
DEFAULT_FRAME_EVERY = 1.0
DEFAULT_FRAME_MAX = 8
# simctl can leave a 0-byte (or header-only) path until finalize flushes;
# agents then attach empty MP4s (LPT-868 lead). Require a real clip.
MIN_VIDEO_BYTES = 2048
STATE_DIR = Path.home() / ".live-poker-trainer"
PID_FILE = STATE_DIR / "sim-record.pid"
OUT_FILE = STATE_DIR / "sim-record.out"
EXIT_OK = 0
EXIT_FAIL = 1


def device_udid() -> str:
    """Resolve the iPhone 13 mini UDID via tools/iphone_13_mini_udid.sh."""
    script = Path(__file__).with_name("iphone_13_mini_udid.sh")
    result = subprocess.run(
        ["bash", str(script)],
        check=True,
        capture_output=True,
        text=True,
    )
    udid = (result.stdout or "").strip()
    if not udid:
        raise SystemExit("sim_record: empty iPhone 13 mini UDID")
    return udid


def guard_lock(run_id: str | None) -> None:
    """Refuse unless this run holds the simulator lock."""
    lock_args = ["guard"] + (["--run-id", run_id] if run_id else [])
    if sim_lock.main(lock_args) != sim_lock.EXIT_OK:
        raise SystemExit(
            "sim_record: the iPhone 13 mini lock is not yours "
            "(tools/sim_lock.py status)"
        )


def heartbeat(run_id: str | None) -> None:
    """Refresh the lock heartbeat during a long record."""
    args = ["heartbeat"] + (["--run-id", run_id] if run_id else [])
    try:
        sim_lock.main(args)
    except SystemExit:
        pass


def record_video_cmd(
    udid: str,
    out: Path,
    *,
    codec: str = DEFAULT_CODEC,
) -> list[str]:
    """Build the simctl recordVideo argv."""
    return [
        "xcrun",
        "simctl",
        "io",
        udid,
        "recordVideo",
        f"--codec={codec}",
        "--force",
        str(out),
    ]


def wait_recording_started(
    proc: subprocess.Popen[str],
    *,
    timeout: float = 30.0,
) -> None:
    """Block until simctl prints Recording started on stderr."""
    assert proc.stderr is not None
    deadline = time.monotonic() + timeout
    buf = ""
    while time.monotonic() < deadline:
        if proc.poll() is not None:
            err = buf + (proc.stderr.read() or "")
            raise SystemExit(
                f"sim_record: recordVideo exited early ({proc.returncode}): {err}"
            )
        line = proc.stderr.readline()
        if not line:
            time.sleep(0.05)
            continue
        buf += line
        if "Recording started" in line:
            return
    raise SystemExit("sim_record: timed out waiting for Recording started")


def finalize_recording(proc: subprocess.Popen[str], *, wait: float = 60.0) -> int:
    """SIGINT simctl and wait for the MP4 to finalize."""
    if proc.poll() is None:
        proc.send_signal(signal.SIGINT)
    try:
        return proc.wait(timeout=wait)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait(timeout=10)
        raise SystemExit("sim_record: timed out finalizing recording")


def wait_stable_video(
    path: Path,
    *,
    min_bytes: int = MIN_VIDEO_BYTES,
    timeout: float = 45.0,
    settle: float = 0.4,
    poll: float = 0.15,
) -> int:
    """Block until [path] is a non-trivial MP4 whose size has stopped growing.

    ``simctl recordVideo`` often creates the output path immediately and only
    flushes media on SIGINT finalize. Checking ``st_size > 0`` too early yields
    empty clips that fail ``frames`` and Jira attaches (ui-agent LPT-868).
    """
    deadline = time.monotonic() + timeout
    last_size = -1
    stable_since: float | None = None
    while time.monotonic() < deadline:
        if path.is_file():
            size = path.stat().st_size
            if size >= min_bytes:
                if size == last_size:
                    now = time.monotonic()
                    if stable_since is None:
                        stable_since = now
                    elif now - stable_since >= settle:
                        return size
                else:
                    last_size = size
                    stable_since = None
            else:
                last_size = size
                stable_since = None
        time.sleep(poll)
    size = path.stat().st_size if path.is_file() else 0
    raise SystemExit(
        f"sim_record: video not ready at {path} "
        f"(size={size}, need>={min_bytes} stable)"
    )


def cmd_record(args: argparse.Namespace) -> int:
    """Record for a fixed duration, then finalize."""
    guard_lock(args.run_id)
    out = Path(args.out).expanduser()
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        out.unlink()
    udid = device_udid()
    cmd = record_video_cmd(udid, out, codec=args.codec)
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    try:
        wait_recording_started(proc)
        end = time.monotonic() + float(args.seconds)
        while time.monotonic() < end:
            heartbeat(args.run_id)
            remaining = end - time.monotonic()
            time.sleep(min(5.0, max(0.05, remaining)))
            if proc.poll() is not None:
                raise SystemExit(
                    f"sim_record: recordVideo died during clip ({proc.returncode})"
                )
    except BaseException:
        if proc.poll() is None:
            proc.send_signal(signal.SIGINT)
            try:
                proc.wait(timeout=30)
            except subprocess.TimeoutExpired:
                proc.kill()
        raise
    code = finalize_recording(proc)
    try:
        wait_stable_video(out)
    except SystemExit as exc:
        raise SystemExit(f"{exc} (recordVideo exit {code})") from exc
    print(out)
    return EXIT_OK


def cmd_start(args: argparse.Namespace) -> int:
    """Start a background recording (pair with stop)."""
    guard_lock(args.run_id)
    if PID_FILE.is_file():
        old = int(PID_FILE.read_text(encoding="utf-8").strip() or "0")
        if old and _pid_alive(old):
            raise SystemExit(f"sim_record: already recording (pid {old}); stop first")
        PID_FILE.unlink(missing_ok=True)
    out = Path(args.out).expanduser()
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        out.unlink()
    udid = device_udid()
    cmd = record_video_cmd(udid, out, codec=args.codec)
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    # Detach: keep stderr for Recording started poll in a sidecar log.
    log_path = STATE_DIR / "sim-record.stderr"
    log_f = open(log_path, "w", encoding="utf-8")
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=log_f,
        start_new_session=True,
    )
    log_f.close()
    # Wait until started so callers can drive the UI next.
    deadline = time.monotonic() + 30.0
    while time.monotonic() < deadline:
        if proc.poll() is not None:
            raise SystemExit(
                f"sim_record: background recordVideo exited ({proc.returncode}); "
                f"see {log_path}"
            )
        text = log_path.read_text(encoding="utf-8", errors="replace")
        if "Recording started" in text:
            break
        time.sleep(0.1)
    else:
        proc.send_signal(signal.SIGINT)
        raise SystemExit("sim_record: timed out waiting for Recording started")
    PID_FILE.write_text(f"{proc.pid}\n", encoding="utf-8")
    OUT_FILE.write_text(f"{out}\n", encoding="utf-8")
    print(out)
    return EXIT_OK


def _pid_alive(pid: int) -> bool:
    """True when pid exists."""
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True


def cmd_stop(args: argparse.Namespace) -> int:
    """Stop the background recording."""
    guard_lock(args.run_id)
    if not PID_FILE.is_file():
        raise SystemExit("sim_record: no active recording (missing pid file)")
    pid = int(PID_FILE.read_text(encoding="utf-8").strip() or "0")
    out = (
        Path(OUT_FILE.read_text(encoding="utf-8").strip())
        if OUT_FILE.is_file()
        else None
    )
    if pid and _pid_alive(pid):
        os.kill(pid, signal.SIGINT)
        deadline = time.monotonic() + 60.0
        while time.monotonic() < deadline and _pid_alive(pid):
            heartbeat(args.run_id)
            time.sleep(0.2)
        if _pid_alive(pid):
            os.kill(pid, signal.SIGKILL)
            raise SystemExit("sim_record: had to SIGKILL recorder; video may be truncated")
    PID_FILE.unlink(missing_ok=True)
    if out is None:
        raise SystemExit("sim_record: no video after stop (missing out path)")
    wait_stable_video(out)
    print(out)
    return EXIT_OK


def extract_frames(
    video: Path,
    out_dir: Path,
    *,
    every: float = DEFAULT_FRAME_EVERY,
    max_frames: int = DEFAULT_FRAME_MAX,
    ffmpeg_bin: str = "ffmpeg",
) -> list[Path]:
    """Extract review PNGs from [video] into [out_dir].

    Short clips (< ``every`` seconds) often yield zero PNGs with
    ``-vf fps=…`` alone — discovery then stalls on "ffmpeg wrote no frames".
    Fall back to a single still at t=0 so agents can still Read proof.
    """
    if not video.is_file() or video.stat().st_size <= 0:
        raise SystemExit(f"sim_record: video missing or empty: {video}")
    out_dir.mkdir(parents=True, exist_ok=True)
    # Clear prior frames for this stem so agents do not Read stale PNGs.
    stem = video.stem
    for old in out_dir.glob(f"{stem}-frame-*.png"):
        old.unlink()
    pattern = str(out_dir / f"{stem}-frame-%03d.png")
    fps = 1.0 / every if every > 0 else 1.0
    cmd = [
        ffmpeg_bin,
        "-hide_banner",
        "-loglevel",
        "error",
        "-y",
        "-i",
        str(video),
        "-vf",
        f"fps={fps}",
        "-frames:v",
        str(max_frames),
        pattern,
    ]
    subprocess.run(cmd, check=True)
    frames = sorted(out_dir.glob(f"{stem}-frame-*.png"))
    if not frames:
        # Sub-second / short clips: grab one still at the start.
        still = out_dir / f"{stem}-frame-001.png"
        fallback = [
            ffmpeg_bin,
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-ss",
            "0",
            "-i",
            str(video),
            "-frames:v",
            "1",
            str(still),
        ]
        subprocess.run(fallback, check=True)
        frames = sorted(out_dir.glob(f"{stem}-frame-*.png"))
    if not frames:
        raise SystemExit(f"sim_record: ffmpeg wrote no frames from {video}")
    return frames


def cmd_frames(args: argparse.Namespace) -> int:
    """CLI wrapper for extract_frames."""
    frames = extract_frames(
        Path(args.video).expanduser(),
        Path(args.out_dir).expanduser(),
        every=float(args.every),
        max_frames=int(args.max),
    )
    for path in frames:
        print(path)
    return EXIT_OK


def build_parser() -> argparse.ArgumentParser:
    """CLI parser."""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--run-id",
        default=None,
        help="Simulator lock run id. Default $SIM_LOCK_RUN_ID.",
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_rec = sub.add_parser("record", help="record a fixed-length clip")
    p_rec.add_argument("--out", required=True, help="output .mp4 path")
    p_rec.add_argument(
        "--seconds",
        type=float,
        default=DEFAULT_SECONDS,
        help=f"clip length (default {DEFAULT_SECONDS})",
    )
    p_rec.add_argument(
        "--codec",
        choices=("h264", "hevc"),
        default=DEFAULT_CODEC,
        help="simctl codec (default h264 for broader playback)",
    )
    p_rec.set_defaults(func=cmd_record)

    p_start = sub.add_parser("start", help="start background recording")
    p_start.add_argument("--out", required=True, help="output .mp4 path")
    p_start.add_argument(
        "--codec",
        choices=("h264", "hevc"),
        default=DEFAULT_CODEC,
    )
    p_start.set_defaults(func=cmd_start)

    p_stop = sub.add_parser("stop", help="stop background recording")
    p_stop.set_defaults(func=cmd_stop)

    p_frames = sub.add_parser("frames", help="extract PNGs from a clip")
    p_frames.add_argument("--video", required=True, help="input .mp4")
    p_frames.add_argument("--out-dir", required=True, help="directory for PNGs")
    p_frames.add_argument(
        "--every",
        type=float,
        default=DEFAULT_FRAME_EVERY,
        help=f"seconds between frames (default {DEFAULT_FRAME_EVERY})",
    )
    p_frames.add_argument(
        "--max",
        type=int,
        default=DEFAULT_FRAME_MAX,
        help=f"max frames (default {DEFAULT_FRAME_MAX})",
    )
    p_frames.set_defaults(func=cmd_frames)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    """CLI entrypoint."""
    args = build_parser().parse_args(list(argv) if argv is not None else None)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
