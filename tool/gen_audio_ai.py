#!/usr/bin/env python3
"""Generate table SFX and lounge ambient via the ElevenLabs API.

Creates several takes per asset, scores them with ffmpeg loudness/silence
heuristics, and writes the winners into ``assets/sounds`` under the filenames
``SoundService`` already loads.

Lounge ambient is built from multiple Sound Effects pad prompts (and optional
layered mixes). The Music API requires a paid ElevenLabs plan, so free-tier
runs stay on text-to-sound with ``loop=true``.

Credentials (never commit)::

    # tool/.env.local  (gitignored)
    ELEVENLABS_API_KEY=sk_...

Usage::

    python3 tool/gen_audio_ai.py
    python3 tool/gen_audio_ai.py --only lounge_ambient --takes 2
    python3 tool/gen_audio_ai.py --dry-run
"""

from __future__ import annotations

import argparse
import array
import json
import math
import os
import pathlib
import shutil
import struct
import subprocess
import tempfile
import urllib.error
import urllib.request
import wave
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


# Distinct musical beds — avoid "casino floor" noise prompts that read as SFX.
AMBIENT_VARIANTS: tuple[tuple[str, str], ...] = (
    (
        "rhodes",
        "Seamless looping soft Rhodes electric piano ambient pad in A minor, "
        "warm sustained chords only, no melody line, no riffs, no percussion, "
        "no drums, no vocals, gentle tape warmth, calm focus music, infinite loop",
    ),
    (
        "analog_pad",
        "Seamless looping warm analog synthesizer pad, deep soft low-mid drone "
        "with very slow filter movement, dark ambient soundtrack bed, no drums, "
        "no melody, no voices, no sound effects, infinite loop",
    ),
    (
        "muted_strings",
        "Seamless looping soft muted string ensemble pad, quiet cinematic "
        "underscore bed, warm and calm, no melody, no percussion, no vocals, "
        "no sound effects, infinite loop",
    ),
    (
        "jazz_bed",
        "Seamless looping extremely soft jazz lounge music bed, distant muted "
        "piano chords and soft upright bass notes barely audible, intimate "
        "late-night club underscore, no solos, no vocals, no drums, no crowd "
        "noise, no chip sounds, infinite loop",
    ),
)

ROOM_TONE_PROMPT = (
    "Seamless looping very quiet brown room tone with soft air, empty calm "
    "interior, no voices, no footsteps, no machinery, no music, infinite loop"
)


ASSETS: tuple[AssetSpec, ...] = (
    AssetSpec(
        name="deal",
        out_name="deal.wav",
        kind="sfx",
        text=(
            "One playing card dealt face-down onto a felt poker table, a single "
            "short paper flick and brief slide, close-mic Foley, dry, no second "
            "card, no music, no voices"
        ),
        duration_seconds=0.5,
        target_lufs=-14.0,
        prompt_influence=0.6,
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
        out_name="lounge_ambient.wav",
        kind="ambient",
        text=AMBIENT_VARIANTS[0][1],
        duration_seconds=14.0,
        loop=True,
        target_lufs=-22.0,
        prompt_influence=0.55,
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
        with urllib.request.urlopen(req, timeout=180) as resp:
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
    """Converts MP3 to mono 22.05 kHz WAV with peak-safe gain for short SFX."""
    del target_lufs
    dest_wav.parent.mkdir(parents=True, exist_ok=True)
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


def decode_mono_wav(src: pathlib.Path, dest: pathlib.Path, sample_rate: int = 44100) -> None:
    """Decodes any audio file to mono PCM WAV."""
    run_ffmpeg(
        [
            "ffmpeg",
            "-y",
            "-i",
            str(src),
            "-ac",
            "1",
            "-ar",
            str(sample_rate),
            "-c:a",
            "pcm_s16le",
            str(dest),
        ]
    )


def _read_mono_pcm16(path: pathlib.Path) -> tuple[array.array, int]:
    """Reads a mono 16-bit WAV into a sample array and sample rate."""
    with wave.open(str(path), "rb") as handle:
        if handle.getnchannels() != 1 or handle.getsampwidth() != 2:
            raise RuntimeError(
                f"expected mono 16-bit wav, got {handle.getnchannels()}ch "
                f"{handle.getsampwidth()}B"
            )
        rate = handle.getframerate()
        samples = array.array("h")
        samples.frombytes(handle.readframes(handle.getnframes()))
    return samples, rate


def _write_mono_pcm16(path: pathlib.Path, samples: array.array, rate: int) -> None:
    """Writes a mono 16-bit WAV."""
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(rate)
        handle.writeframes(struct.pack(f"<{len(samples)}h", *samples))


def make_seamless_loop_wav(
    src: pathlib.Path,
    dest: pathlib.Path,
    xfade_sec: float = 3.0,
) -> None:
    """Builds a true seamless loop via overlap-add crossfade.

    Crossfades the clipped-off tail onto the start, then drops that tail so
    ``out[-1]`` and ``out[0]`` were adjacent samples in the source. Equal-power
    fades avoid a dip at the join. WAV (not MP3) preserves gapless playback.
    """
    samples, rate = _read_mono_pcm16(src)
    xfade = min(len(samples) // 3, max(8, int(xfade_sec * rate)))
    if len(samples) <= xfade * 2:
        dest.write_bytes(src.read_bytes())
        return

    out_len = len(samples) - xfade
    out = array.array("h", samples[:out_len])
    for i in range(xfade):
        t = i / xfade
        # Equal-power: start fades in, discarded tail fades out.
        fade_in = math.sin(t * math.pi * 0.5)
        fade_out = math.cos(t * math.pi * 0.5)
        mixed = int(samples[i] * fade_in + samples[out_len + i] * fade_out)
        out[i] = max(-32767, min(32767, mixed))

    _write_mono_pcm16(dest, out, rate)
    # Loop join should match original adjacency (samples[out_len-1] → samples[out_len]).
    join_delta = abs(out[-1] - out[0])
    src_delta = abs(samples[out_len - 1] - samples[out_len])
    print(
        f"  seamless loop: {len(out)/rate:.2f}s, xfade={xfade/rate:.2f}s, "
        f"join_delta={join_delta} (src_adj={src_delta})"
    )


def polish_ambient_wav(src: pathlib.Path, dest: pathlib.Path, target_lufs: float) -> None:
    """EQ/loudnorm first, then seamless-loop last, writing gapless WAV."""
    dest.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = pathlib.Path(tmp)
        raw = tmp_path / "raw.wav"
        shaped_ext = tmp_path / "shaped_ext.wav"
        shaped = tmp_path / "shaped.wav"
        looped = tmp_path / "looped.wav"
        decode_mono_wav(src, raw, sample_rate=44100)
        # Shape before looping so loudnorm cannot reopen a seam afterward.
        run_ffmpeg(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(raw),
                "-af",
                (
                    "highpass=f=45,lowpass=f=6500,"
                    "acompressor=threshold=-24dB:ratio=2.5:attack=25:release=250,"
                    f"loudnorm=I={target_lufs}:TP=-2.0:LRA=8"
                ),
                "-c:a",
                "pcm_s16le",
                str(shaped_ext),
            ]
        )
        # loudnorm often writes WAVE_FORMAT_EXTENSIBLE; re-wrap as classic PCM.
        run_ffmpeg(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(shaped_ext),
                "-ac",
                "1",
                "-ar",
                "44100",
                "-c:a",
                "pcm_s16le",
                "-map_metadata",
                "-1",
                str(shaped),
            ]
        )
        # Loop last and write it untouched: any resample after this point
        # filters the two ends independently and reopens the seam.
        make_seamless_loop_wav(shaped, looped, xfade_sec=3.0)
        shutil.copyfile(looped, dest)


def mix_wavs(paths: list[pathlib.Path], dest: pathlib.Path, gains_db: list[float]) -> None:
    """Mixes mono WAVs with per-input gain into ``dest``."""
    if len(paths) != len(gains_db):
        raise ValueError("paths/gains length mismatch")
    inputs: list[str] = []
    filters = []
    for index, (path, gain) in enumerate(zip(paths, gains_db)):
        inputs.extend(["-i", str(path)])
        filters.append(f"[{index}:a]volume={gain}dB[a{index}]")
    mix_inputs = "".join(f"[a{i}]" for i in range(len(paths)))
    filters.append(
        f"{mix_inputs}amix=inputs={len(paths)}:normalize=0:duration=longest[out]"
    )
    run_ffmpeg(
        [
            "ffmpeg",
            "-y",
            *inputs,
            "-filter_complex",
            ";".join(filters),
            "-map",
            "[out]",
            "-c:a",
            "pcm_s16le",
            str(dest),
        ]
    )


def measure(path: pathlib.Path) -> dict[str, float]:
    """Returns duration, LUFS, true peak, leading silence, and HF energy proxy."""
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

    # Mean absolute sample energy after a 4 kHz high-pass ≈ hiss/noise proxy.
    hf = subprocess.run(
        [
            "ffmpeg",
            "-i",
            str(path),
            "-af",
            "highpass=f=4000,astats=metadata=1:reset=1",
            "-f",
            "null",
            "-",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    hf_rms = 0.0
    for line in (hf.stderr or "").splitlines():
        if "RMS level dB" in line:
            try:
                hf_rms = float(line.rsplit(":", 1)[1].strip())
            except ValueError:
                pass

    return {
        "duration": duration,
        "lufs": lufs,
        "true_peak": true_peak,
        "leading_silence": leading_silence,
        "hf_rms": hf_rms,
    }


def score_take(spec: AssetSpec, path: pathlib.Path) -> float:
    """Higher is better. Ambient also prefers less high-frequency noise."""
    m = measure(path)
    if m["duration"] < 0.15:
        return -1e9

    loud_err = abs(m["lufs"] - spec.target_lufs)
    silence_pen = m["leading_silence"] * 40.0
    peak_pen = 0.0
    if m["true_peak"] > -1.0:
        peak_pen = (m["true_peak"] + 1.0) * 8.0

    length_pen = abs(m["duration"] - spec.duration_seconds) * 6.0
    if spec.kind == "ambient" and m["duration"] < spec.duration_seconds * 0.7:
        length_pen += 25.0

    hf_pen = 0.0
    if spec.kind == "ambient":
        # Quieter HF is better for a lounge pad; -60 dB is ideal-ish.
        hf_pen = max(0.0, m["hf_rms"] + 55.0) * 1.8

    return 100.0 - loud_err * 3.0 - silence_pen - peak_pen - length_pen - hf_pen


def clear_assets(names: set[str]) -> None:
    """Removes only the named bundled assets before rewriting winners."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name in names:
        path = OUT_DIR / name
        if path.exists():
            path.unlink()
            print(f"removed {path.relative_to(REPO)}")


def write_winner(spec: AssetSpec, src: pathlib.Path) -> pathlib.Path:
    """Normalizes/converts ``src`` into the final bundled path."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    dest = OUT_DIR / spec.out_name
    if spec.kind == "sfx":
        convert_to_wav(src, dest, spec.target_lufs)
    else:
        polish_ambient_wav(src, dest, spec.target_lufs)
    print(f"wrote {dest.relative_to(REPO)} ({dest.stat().st_size} bytes)")
    return dest


def generate_lounge_candidates(
    api_key: str,
    *,
    spec: AssetSpec,
    takes_per_variant: int,
) -> list[pathlib.Path]:
    """Generates pad variants, room tone, and layered mixes for ambient."""
    CANDIDATE_DIR.mkdir(parents=True, exist_ok=True)
    candidates: list[pathlib.Path] = []
    pad_wavs: dict[str, pathlib.Path] = {}

    for variant_name, prompt in AMBIENT_VARIANTS:
        for take in range(1, takes_per_variant + 1):
            raw = CANDIDATE_DIR / f"lounge_{variant_name}_t{take}.mp3"
            print(f"  generating {variant_name} take {take}…")
            generate_sfx_mp3(
                api_key,
                text=prompt,
                duration_seconds=spec.duration_seconds,
                prompt_influence=spec.prompt_influence,
                loop=True,
                dest=raw,
            )
            candidates.append(raw)
            if take == 1:
                wav = CANDIDATE_DIR / f"lounge_{variant_name}_t{take}.wav"
                decode_mono_wav(raw, wav)
                pad_wavs[variant_name] = wav

    room_mp3 = CANDIDATE_DIR / "lounge_room_t1.mp3"
    print("  generating soft room tone…")
    generate_sfx_mp3(
        api_key,
        text=ROOM_TONE_PROMPT,
        duration_seconds=spec.duration_seconds,
        prompt_influence=0.5,
        loop=True,
        dest=room_mp3,
    )
    room_wav = CANDIDATE_DIR / "lounge_room_t1.wav"
    decode_mono_wav(room_mp3, room_wav)
    candidates.append(room_mp3)

    # Layered mixes tend to sound more like music beds than raw Foley pads.
    mixes = (
        ("mix_rhodes_room", ["rhodes"], [0.0], -12.0),
        ("mix_analog_room", ["analog_pad"], [0.0], -11.0),
        ("mix_jazz_room", ["jazz_bed"], [0.0], -13.0),
        ("mix_rhodes_analog", ["rhodes", "analog_pad"], [-3.0, -5.0], None),
        ("mix_strings_room", ["muted_strings"], [0.0], -12.0),
    )
    for mix_name, keys, gains, room_gain in mixes:
        paths = [pad_wavs[key] for key in keys if key in pad_wavs]
        gain_list = list(gains[: len(paths)])
        if not paths:
            continue
        if room_gain is not None:
            paths.append(room_wav)
            gain_list.append(room_gain)
        mixed_wav = CANDIDATE_DIR / f"lounge_{mix_name}.wav"
        mixed_mp3 = CANDIDATE_DIR / f"lounge_{mix_name}.mp3"
        print(f"  mixing {mix_name}…")
        mix_wavs(paths, mixed_wav, gain_list)
        run_ffmpeg(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(mixed_wav),
                "-c:a",
                "libmp3lame",
                "-qscale:a",
                "4",
                str(mixed_mp3),
            ]
        )
        candidates.append(mixed_mp3)

    return candidates


def generate_all(*, takes: int, dry_run: bool, only: set[str] | None) -> None:
    """Generates, scores, and installs selected assets."""
    api_key = load_api_key()
    before = credit_count(api_key)
    print(f"credits used before: {before}")

    selected = [spec for spec in ASSETS if only is None or spec.name in only]
    if not selected:
        raise SystemExit(f"No assets matched --only {sorted(only or [])}")

    if dry_run:
        for spec in selected:
            if spec.kind == "ambient":
                print(
                    f"[dry-run] {spec.out_name}: "
                    f"{len(AMBIENT_VARIANTS)} variants x {takes} takes + mixes"
                )
            else:
                print(
                    f"[dry-run] {spec.out_name}: {takes} takes, "
                    f"{spec.duration_seconds}s"
                )
        return

    CANDIDATE_DIR.mkdir(parents=True, exist_ok=True)
    winners: dict[str, pathlib.Path] = {}

    for spec in selected:
        print(f"\n=== {spec.name} ===")
        if spec.kind == "ambient":
            candidates = generate_lounge_candidates(
                api_key, spec=spec, takes_per_variant=takes
            )
        else:
            candidates = []
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
                candidates.append(raw)

        best_path: pathlib.Path | None = None
        best_score = -1e18
        for candidate in candidates:
            scored = score_take(spec, candidate)
            metrics = measure(candidate)
            print(
                f"  {candidate.name}: score={scored:.1f} "
                f"lufs={metrics['lufs']:.1f} "
                f"hf={metrics['hf_rms']:.1f} "
                f"dur={metrics['duration']:.2f}s"
            )
            if scored > best_score:
                best_score = scored
                best_path = candidate
        assert best_path is not None
        winners[spec.name] = best_path
        print(f"  winner: {best_path.name} (score={best_score:.1f})")

    clear_assets({spec.out_name for spec in selected})
    for spec in selected:
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
        default=2,
        help="Takes per SFX asset / per ambient variant (default: 2)",
    )
    parser.add_argument(
        "--only",
        action="append",
        default=None,
        help="Asset name to generate (repeatable). Example: lounge_ambient",
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
    only = set(args.only) if args.only else None
    generate_all(takes=args.takes, dry_run=args.dry_run, only=only)


if __name__ == "__main__":
    main()
