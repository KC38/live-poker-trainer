#!/usr/bin/env python3
"""Split the Freesound card-mixing clip into eight ordered deal hits.

Source: Freesound community "card mixing" (id 48088). The recording has eight
deal flicks in sequence, then leftover handling noise that we drop.

Usage::

    python3 tool/split_deal_variations.py
"""

from __future__ import annotations

import math
import pathlib
import struct
import subprocess
import tempfile
import wave

REPO = pathlib.Path(__file__).resolve().parent.parent
SRC = REPO / "tool" / "audio_src" / "card-mixing-48088.mp3"
OUT_DIR = REPO / "assets" / "sounds"
SAMPLE_RATE = 22050
PEAK = 27000.0

# Start/end seconds of the eight deal hits; audio after 3.36s is ignored.
CUTS: tuple[tuple[float, float], ...] = (
    (0.175, 0.520),
    (0.640, 0.900),
    (1.040, 1.280),
    (1.420, 1.640),
    (1.830, 2.040),
    (2.210, 2.430),
    (2.630, 2.860),
    (3.070, 3.360),
)


def _decode_mono(path: pathlib.Path) -> list[float]:
    """Decode [path] to mono float samples at [SAMPLE_RATE]."""
    with tempfile.NamedTemporaryFile(suffix=".wav") as tmp:
        subprocess.check_call(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(path),
                "-ac",
                "1",
                "-ar",
                str(SAMPLE_RATE),
                tmp.name,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        with wave.open(tmp.name, "rb") as wav:
            raw = wav.readframes(wav.getnframes())
    samples = list(
        struct.unpack("<" + "h" * (len(raw) // 2), raw),
    )
    return [s / 32768.0 for s in samples]


def _trim(samples: list[float], pad_ms: float = 8.0) -> list[float]:
    """Drop leading/trailing near-silence, keeping [pad_ms] of pad."""
    thresh = 0.012
    first = 0
    while first < len(samples) and abs(samples[first]) < thresh:
        first += 1
    last = len(samples) - 1
    while last > first and abs(samples[last]) < thresh:
        last -= 1
    pad = int(SAMPLE_RATE * pad_ms / 1000.0)
    start = max(0, first - pad)
    end = min(len(samples), last + pad + 1)
    return samples[start:end]


def _fade(samples: list[float], fade_in_ms: float = 4.0, fade_out_ms: float = 12.0) -> None:
    """Apply short linear fades in place."""
    fade_in = max(1, int(SAMPLE_RATE * fade_in_ms / 1000.0))
    fade_out = max(1, int(SAMPLE_RATE * fade_out_ms / 1000.0))
    for i in range(min(fade_in, len(samples))):
        samples[i] *= i / fade_in
    for i in range(min(fade_out, len(samples))):
        samples[-1 - i] *= i / fade_out


def _normalize(samples: list[float]) -> list[int]:
    """Peak-normalize to the other table SFX level."""
    peak = max((abs(s) for s in samples), default=0.0)
    gain = (PEAK / 32768.0) / peak if peak > 1e-6 else 1.0
    out: list[int] = []
    for sample in samples:
        value = int(round(sample * gain * 32768.0))
        out.append(max(-32768, min(32767, value)))
    return out


def _write_wav(path: pathlib.Path, pcm: list[int]) -> None:
    """Write 16-bit mono PCM."""
    with wave.open(str(path), "w") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(struct.pack("<" + "h" * len(pcm), *pcm))


def main() -> None:
    """Cut, trim, and write ``deal_01.wav`` … ``deal_08.wav``."""
    if not SRC.exists():
        raise SystemExit(f"missing source clip: {SRC}")
    samples = _decode_mono(SRC)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for index, (start, end) in enumerate(CUTS, start=1):
        a = int(start * SAMPLE_RATE)
        b = int(end * SAMPLE_RATE)
        clip = _trim(samples[a:b])
        _fade(clip)
        pcm = _normalize(clip)
        out = OUT_DIR / f"deal_{index:02d}.wav"
        _write_wav(out, pcm)
        dur = len(pcm) / SAMPLE_RATE
        rms = math.sqrt(sum(s * s for s in pcm) / max(1, len(pcm)))
        print(f"{out.name}  {dur:.3f}s  rms={rms:.0f}  n={len(pcm)}")


if __name__ == "__main__":
    main()
