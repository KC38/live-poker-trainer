#!/usr/bin/env python3
"""Generate table SFX and lounge ambient via the ElevenLabs API.

Creates several takes per asset, scores them with ffmpeg loudness/silence
heuristics, and writes the winners into ``assets/sounds`` under the filenames
``SoundService`` already loads. Old matching assets are removed first.

Credentials (never commit)::

    # tool/.env.local  (gitignored)
    ELEVENLABS_API_KEY=sk_...

Usage::

    python3 tool/gen_audio_ai.py
    python3 tool/gen_audio_ai.py --takes 3 --dry-run
"""

from __future__ import annotations

import argparse
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
from dataclasses import dataclass

REPO = pathlib.Path(__file__).resolve().parent.parent
OUT_DIR = REPO / "assets" / "sounds"
CANDIDATE_DIR = REPO / "tool" / ".audio_candidates"
ENV_FILE = REPO / "tool" / ".env.local"
API_BASE = "https://api.elevenlabs.io/v1"


@dataclass(frozen=True)
class AssetSpec:
    """One bundled audio asset to generate and score."""

    name: str
    out_name: str
    kind: str  # "sfx" | "ambient"
    text: str
    duration_seconds: float
    loop: bool = False
    target_lufs: float = -16.0
    prompt_influence: float = 0.45


ASSETS: tuple[AssetSpec, ...] = (
    AssetSpec(
        name="deal",
        out_name="deal.wav",
        kind="sfx",
        text=(
            "Two playing cards dealt face-down onto a felt poker table in quick "
            "succession, soft paper flick and brief slide, close-mic Foley, dry, "
            "no music, no voices"
        ),
        duration_seconds=0.55,
        target_lufs=-14.0,
        prompt_influence=0.55,
    ),
    AssetSpec(
        name="chip",
        out_name="chip.wav",
        kind="sfx",
        text=(
            "Small stack of clay poker chips pushed forward on felt, short "
            "clacks and clicks, realistic casino Foley, dry, no music"
        ),
        duration_seconds=0.55,
        target_lufs=-14.0,
        prompt_influence=0.55,
    ),
    AssetSpec(
        name="knock",
        out_name="knock.wav",
        kind="sfx",
        text=(
            "Two knuckles gently tapping felt poker table to check, soft wooden "
            "thump with a dry click, close-mic, no music"
        ),
        duration_seconds=0.5,
        target_lufs=-15.0,
        prompt_influence=0.55,
    ),
    AssetSpec(
        name="fold",
        out_name="fold.wav",
        kind="sfx",
        text=(
            "Playing cards sliding away across felt as a fold, soft descending "
            "paper swish, quiet, dry Foley, no music"
        ),
        duration_seconds=0.65,
        target_lufs=-18.0,
        prompt_influence=0.5,
    ),
    AssetSpec(
        name="win",
        out_name="win.wav",
        kind="sfx",
        text=(
            "Poker pot of clay chips pushed toward the winner with a soft "
            "cascade of chip clacks, warm short major chime underneath, "
            "satisfying but not arcade-like, no voices"
        ),
        duration_seconds=1.1,
        target_lufs=-14.0,
        prompt_influence=0.45,
    ),
    AssetSpec(
        name="lounge_ambient",
        out_name="lounge_ambient.mp3",
        kind="ambient",
        text=(
            "Seamless looping soft poker lounge ambient pad, warm low drone, "
            "quiet brown room tone, calm evening casino atmosphere, "
            "instrumental only, no melody hook, no percussion hits, no vocals, "
            "designed to loop forever"
        ),
        duration_seconds=8.0,
        loop=True,
        target_lufs=-22.0,
        prompt_influence=0.4,
    ),
)


def load_api_key() -> str:
    """Reads ``ELEVENLABS_API_KEY`` from the environment or ``tool/.env.local``."""
    key = os.environ.get("ELEVENLABS_API_KEY", "").strip()
    if key:
        return key
    if ENV_FILE.is_file():
        for line in ENV_FILE.read_text().splitlines():
            if line.startswith("ELEVENLABS_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    raise SystemExit(
        "Missing ELEVENLABS_API_KEY. Put it in tool/.env.local (gitignored)."
    )


def credit_count(api_key: str) -> int:
    """Returns used credits from the subscription endpoint."""
    req = urllib.request.Request(
        f"{API_BASE}/user/subscription",
        headers={"xi-api-key": api_key},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read().decode())
    return int(data.get("character_count") or 0)


def generate_sfx_mp3(
    api_key: str,
    *,
    text: str,
    duration_seconds: float,
    prompt_influence: float,
    loop: bool,
    dest: pathlib.Path,
) -> None:
    """Calls ElevenLabs sound-generation and writes an MP3 to ``dest``."""
    payload = {
        "text": text,
        "duration_seconds": duration_seconds,
        "prompt_influence": prompt_influence,
        "model_id": "eleven_text_to_sound_v2",
        "loop": loop,
    }
    body = json.dumps(payload).encode()
    req = urllib.request.Request(
        f"{API_BASE}/sound-generation?output_format=mp3_44100_128",
        data=body,
        headers={
            "xi-api-key": api_key,
            "Content-Type": "application/json",
            "Accept": "audio/mpeg",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            dest.write_bytes(resp.read())
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")
        raise RuntimeError(f"ElevenLabs HTTP {exc.code}: {detail}") from exc


def run_ffmpeg(args: list[str]) -> subprocess.CompletedProcess[str]:
    """Runs ffmpeg/ffprobe and returns the completed process."""
    return subprocess.run(
        args,
        check=True,
        capture_output=True,
        text=True,
    )


def convert_to_wav(
    src_mp3: pathlib.Path,
    dest_wav: pathlib.Path,
    target_lufs: float,
) -> None:
    """Converts MP3 to mono 22.05 kHz WAV with peak-safe gain for short SFX.

    Single-pass ``loudnorm`` under-boosts sub-second clips, so short table
    sounds are peak-normalized to ``-1.5 dBTP`` instead. ``target_lufs`` is
    kept for API symmetry with ambient normalization.
    """
    del target_lufs  # ambient uses LUFS; SFX use true-peak targeting.
    dest_wav.parent.mkdir(parents=True, exist_ok=True)
    # First write a temp WAV, measure peak, then apply gain.
    with tempfile.TemporaryDirectory() as tmp:
        raw = pathlib.Path(tmp) / "raw.wav"
        run_ffmpeg(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(src_mp3),
                "-ac",
                "1",
                "-ar",
                "22050",
                "-c:a",
                "pcm_s16le",
                str(raw),
            ]
        )
        metrics = measure(raw)
        # Raise quiet Foley toward -1.5 dBTP; never boost already-hot clips.
        gain_db = max(0.0, min(24.0, -1.5 - metrics["true_peak"]))
        run_ffmpeg(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(raw),
                "-af",
                f"volume={gain_db}dB,alimiter=limit=0.89:level=disabled",
                "-c:a",
                "pcm_s16le",
                str(dest_wav),
            ]
        )


def normalize_mp3(src: pathlib.Path, dest: pathlib.Path, target_lufs: float) -> None:
    """Loudness-normalizes an MP3 for ambient playback."""
    dest.parent.mkdir(parents=True, exist_ok=True)
    run_ffmpeg(
        [
            "ffmpeg",
            "-y",
            "-i",
            str(src),
            "-af",
            f"loudnorm=I={target_lufs}:TP=-1.5:LRA=11",
            "-c:a",
            "libmp3lame",
            "-qscale:a",
            "4",
            str(dest),
        ]
    )


def measure(path: pathlib.Path) -> dict[str, float]:
    """Returns duration, integrated LUFS, true peak, and leading silence ratio."""
    probe = run_ffmpeg(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=nw=1:nk=1",
            str(path),
        ]
    )
    duration = float(probe.stdout.strip() or "0")

    # ebur128 gives integrated loudness; silence detect estimates dead air.
    ebu = subprocess.run(
        [
            "ffmpeg",
            "-i",
            str(path),
            "-af",
            "ebur128=peak=true",
            "-f",
            "null",
            "-",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    lufs = -70.0
    true_peak = -70.0
    for line in (ebu.stderr or "").splitlines():
        if "I:" in line and "LUFS" in line:
            # e.g. "    I:         -23.4 LUFS"
            try:
                lufs = float(line.split("I:")[1].split("LUFS")[0].strip())
            except ValueError:
                pass
        if "Peak:" in line and "dBFS" in line:
            try:
                true_peak = float(line.split("Peak:")[1].split("dBFS")[0].strip())
            except ValueError:
                pass

    silence = subprocess.run(
        [
            "ffmpeg",
            "-i",
            str(path),
            "-af",
            "silencedetect=noise=-40dB:d=0.05",
            "-f",
            "null",
            "-",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    leading_silence = 0.0
    for line in (silence.stderr or "").splitlines():
        if "silence_start:" in line:
            try:
                start = float(line.split("silence_start:")[1].strip())
            except ValueError:
                continue
            if start <= 0.02:
                leading_silence = 0.05
        if "silence_end:" in line and "|" in line:
            try:
                end = float(line.split("silence_end:")[1].split("|")[0].strip())
                if end < duration * 0.5:
                    leading_silence = max(leading_silence, end)
            except ValueError:
                pass

    return {
        "duration": duration,
        "lufs": lufs,
        "true_peak": true_peak,
        "leading_silence": leading_silence,
    }


def score_take(spec: AssetSpec, path: pathlib.Path) -> float:
    """Higher is better. Prefers target loudness, tight leading silence, length."""
    m = measure(path)
    if m["duration"] < 0.15:
        return -1e9

    loud_err = abs(m["lufs"] - spec.target_lufs)
    silence_pen = m["leading_silence"] * 40.0
    peak_pen = 0.0
    if m["true_peak"] > -1.0:
        peak_pen = (m["true_peak"] + 1.0) * 8.0

    length_pen = abs(m["duration"] - spec.duration_seconds) * 6.0
    # Ambient should fill most of the requested window.
    if spec.kind == "ambient" and m["duration"] < spec.duration_seconds * 0.7:
        length_pen += 25.0

    return 100.0 - loud_err * 3.0 - silence_pen - peak_pen - length_pen


def clear_old_assets() -> None:
    """Removes previously bundled sound files so winners fully replace them."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for path in OUT_DIR.iterdir():
        if path.suffix.lower() in {".wav", ".mp3", ".ogg", ".m4a"}:
            path.unlink()
            print(f"removed {path.relative_to(REPO)}")


def write_winner(spec: AssetSpec, src: pathlib.Path) -> pathlib.Path:
    """Normalizes/converts ``src`` into the final bundled path."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    dest = OUT_DIR / spec.out_name
    if spec.kind == "sfx":
        convert_to_wav(src, dest, spec.target_lufs)
    else:
        normalize_mp3(src, dest, spec.target_lufs)
    print(f"wrote {dest.relative_to(REPO)} ({dest.stat().st_size} bytes)")
    return dest


def generate_all(*, takes: int, dry_run: bool) -> None:
    """Generates, scores, and installs every asset."""
    api_key = load_api_key()
    before = credit_count(api_key)
    print(f"credits used before: {before}")

    if dry_run:
        for spec in ASSETS:
            print(f"[dry-run] {spec.out_name}: {takes} takes, {spec.duration_seconds}s")
        return

    CANDIDATE_DIR.mkdir(parents=True, exist_ok=True)
    winners: dict[str, pathlib.Path] = {}

    for spec in ASSETS:
        best_path: pathlib.Path | None = None
        best_score = -1e18
        print(f"\n=== {spec.name} ({takes} takes) ===")
        for take in range(1, takes + 1):
            raw = CANDIDATE_DIR / f"{spec.name}_t{take}.mp3"
            print(f"  generating take {take}…")
            generate_sfx_mp3(
                api_key,
                text=spec.text,
                duration_seconds=spec.duration_seconds,
                prompt_influence=spec.prompt_influence,
                loop=spec.loop,
                dest=raw,
            )
            scored = score_take(spec, raw)
            metrics = measure(raw)
            print(
                f"  take {take}: score={scored:.1f} "
                f"lufs={metrics['lufs']:.1f} "
                f"dur={metrics['duration']:.2f}s "
                f"lead_sil={metrics['leading_silence']:.2f}s"
            )
            if scored > best_score:
                best_score = scored
                best_path = raw
        assert best_path is not None
        winners[spec.name] = best_path
        print(f"  winner: {best_path.name} (score={best_score:.1f})")

    clear_old_assets()
    for spec in ASSETS:
        write_winner(spec, winners[spec.name])

    after = credit_count(api_key)
    print(f"\ncredits used after: {after} (delta={after - before})")
    print(f"candidates kept under {CANDIDATE_DIR.relative_to(REPO)} for review")


def main(argv: list[str] | None = None) -> None:
    """CLI entry point."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--takes",
        type=int,
        default=3,
        help="Number of candidates per asset (default: 3)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the plan without calling the API",
    )
    args = parser.parse_args(argv)
    if args.takes < 1:
        raise SystemExit("--takes must be >= 1")
    if shutil.which("ffmpeg") is None or shutil.which("ffprobe") is None:
        raise SystemExit("ffmpeg and ffprobe are required on PATH")
    generate_all(takes=args.takes, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
