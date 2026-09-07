#!/usr/bin/env python3
"""Synthesize a short looping poker-lounge ambient pad.

Soft drones and quiet room tone — calm felt atmosphere for the Home screen,
not table SFX. Writes a WAV then (when ffmpeg is available) a compact MP3.

Usage::

    python3 tool/gen_ambient.py
"""

from __future__ import annotations

import math
import pathlib
import random
import shutil
import struct
import subprocess
import wave

REPO = pathlib.Path(__file__).resolve().parent.parent
OUT_DIR = REPO / "assets" / "sounds"
SAMPLE_RATE = 16000
DURATION = 8.0


def _clamp(value: float) -> float:
    """Clip to the PCM sample range."""
    return max(-1.0, min(1.0, value))


def build_lounge_ambient() -> list[float]:
    """Warm A-minor-ish pad with brown room tone, crossfaded for looping."""
    length = int(SAMPLE_RATE * DURATION)
    buf = [0.0] * length
    rng = random.Random(42)
    drones = (
        (110.0, 0.22, 0.07),
        (164.81, 0.16, 0.11),
        (196.0, 0.12, 0.09),
        (261.63, 0.08, 0.13),
        (329.63, 0.045, 0.17),
    )
    for freq, amp, lfo_hz in drones:
        phase = rng.uniform(0, math.tau)
        lfo_phase = rng.uniform(0, math.tau)
        for i in range(length):
            t = i / SAMPLE_RATE
            breathe = 0.72 + 0.28 * math.sin(math.tau * lfo_hz * t + lfo_phase)
            wobble = 1.0 + 0.0015 * math.sin(math.tau * 0.23 * t + phase)
            sample = math.sin(math.tau * freq * wobble * t + phase) * amp * breathe
            sample += (
                0.16
                * amp
                * math.sin(math.tau * freq * 2 * t + phase)
                * breathe
            )
            buf[i] += sample

    noise_state = 0.0
    for i in range(length):
        white = rng.uniform(-1.0, 1.0)
        noise_state = 0.97 * noise_state + 0.03 * white
        t = i / SAMPLE_RATE
        buf[i] += noise_state * 0.04
        buf[i] += (
            0.055
            * math.sin(math.tau * 55.0 * t)
            * (0.85 + 0.15 * math.sin(math.tau * 0.05 * t))
        )

    xfade = int(0.5 * SAMPLE_RATE)
    for i in range(xfade):
        alpha = i / xfade
        end_i = length - xfade + i
        buf[end_i] = buf[end_i] * (1.0 - alpha) + buf[i] * alpha

    peak = max(abs(sample) for sample in buf) or 1.0
    gain = 0.40 / peak
    return [sample * gain for sample in buf]


def write_wav(name: str, samples: list[float]) -> pathlib.Path:
    """Writes mono 16-bit PCM WAV and returns its path."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUT_DIR / name
    pcm = [int(_clamp(sample) * 32767) for sample in samples]
    with wave.open(str(path), "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(struct.pack(f"<{len(pcm)}h", *pcm))
    return path


def encode_mp3(wav_path: pathlib.Path, mp3_name: str) -> pathlib.Path | None:
    """Encodes [wav_path] to MP3 when ffmpeg is on PATH."""
    ffmpeg = shutil.which("ffmpeg")
    if ffmpeg is None:
        return None
    mp3_path = OUT_DIR / mp3_name
    subprocess.run(
        [
            ffmpeg,
            "-y",
            "-i",
            str(wav_path),
            "-codec:a",
            "libmp3lame",
            "-qscale:a",
            "6",
            str(mp3_path),
        ],
        check=True,
        capture_output=True,
    )
    return mp3_path


def main() -> None:
    """Writes lounge ambient WAV and compact MP3 when possible."""
    samples = build_lounge_ambient()
    wav_path = write_wav("lounge_ambient.wav", samples)
    mp3_path = encode_mp3(wav_path, "lounge_ambient.mp3")
    if mp3_path is not None:
        wav_path.unlink(missing_ok=True)
        print(f"Wrote {mp3_path} ({mp3_path.stat().st_size} bytes)")
    else:
        print(f"Wrote {wav_path} ({wav_path.stat().st_size} bytes; install ffmpeg for MP3)")


if __name__ == "__main__":
    main()
