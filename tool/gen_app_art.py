#!/usr/bin/env python3
"""Generate app art with the Gemini image API and install platform icons.

Reads ``GEMINI_API_KEY`` from the environment or ``.env`` (never committed),
asks Gemini for the source artwork, then writes:

* ``assets/brand/app_icon.png``      - 1024x1024 master icon
* ``assets/brand/logo_mark.png``     - transparent-ish mark used on Home
* ``ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`` - iOS icon set
* ``android/app/src/main/res/mipmap-*/ic_launcher.png``   - Android icons

Usage::

    python3 tool/gen_app_art.py            # generate everything
    python3 tool/gen_app_art.py --icons    # re-derive platform icons only
"""

from __future__ import annotations

import argparse
import base64
import io
import json
import os
import pathlib
import sys
import urllib.error
import urllib.request

REPO = pathlib.Path(__file__).resolve().parent.parent
BRAND_DIR = REPO / "assets" / "brand"
IOS_ICON_DIR = REPO / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
ANDROID_RES = REPO / "android" / "app" / "src" / "main" / "res"

IMAGE_MODEL = "gemini-3-pro-image"
API_ROOT = "https://generativelanguage.googleapis.com/v1beta/models"

ICON_PROMPT = (
    "Square 1:1 mobile app icon for a premium poker training app. "
    "Centered emblem: a stylized gold ace-of-spades pip whose stem becomes a "
    "subtle upward analytics arrow. Background is deep emerald poker felt with "
    "a dark navy vignette and a thin brushed-gold rim just inside the edge. "
    "Flat, vector-like, minimal, high contrast, crisp edges, no text, no "
    "letters, no numbers, no drop shadows, full-bleed square, centered "
    "composition with generous margin so it survives being masked to a circle."
)

LOGO_PROMPT = (
    "Square emblem on a solid very dark navy background (#0A0E16) for a poker "
    "strategy app. A gold ace-of-spades pip flanked by two thin gold arcs "
    "suggesting a poker table rail. Flat, vector-like, minimal, luxurious, "
    "high contrast, no text, no letters, no numbers, centered, generous "
    "margin."
)

# (pixel size, filename) pairs for the iOS AppIcon set.
IOS_SIZES = [
    (20, "Icon-App-20x20@1x.png"),
    (40, "Icon-App-20x20@2x.png"),
    (60, "Icon-App-20x20@3x.png"),
    (29, "Icon-App-29x29@1x.png"),
    (58, "Icon-App-29x29@2x.png"),
    (87, "Icon-App-29x29@3x.png"),
    (40, "Icon-App-40x40@1x.png"),
    (80, "Icon-App-40x40@2x.png"),
    (120, "Icon-App-40x40@3x.png"),
    (120, "Icon-App-60x60@2x.png"),
    (180, "Icon-App-60x60@3x.png"),
    (76, "Icon-App-76x76@1x.png"),
    (152, "Icon-App-76x76@2x.png"),
    (167, "Icon-App-83.5x83.5@2x.png"),
    (1024, "Icon-App-1024x1024@1x.png"),
]

ANDROID_SIZES = [
    (48, "mipmap-mdpi"),
    (72, "mipmap-hdpi"),
    (96, "mipmap-xhdpi"),
    (144, "mipmap-xxhdpi"),
    (192, "mipmap-xxxhdpi"),
]


def api_key() -> str:
    """Resolves the Gemini key from the environment or a local .env."""
    key = os.environ.get("GEMINI_API_KEY", "").strip()
    if key:
        return key
    env_file = REPO / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if line.startswith("GEMINI_API_KEY="):
                return line.split("=", 1)[1].strip()
    sys.exit("GEMINI_API_KEY not set (env or .env)")


def generate_image(prompt: str, key: str) -> bytes:
    """Calls Gemini and returns the first inline image payload."""
    body = json.dumps(
        {
            "contents": [{"role": "user", "parts": [{"text": prompt}]}],
            "generationConfig": {"responseModalities": ["IMAGE"]},
        }
    ).encode()
    request = urllib.request.Request(
        f"{API_ROOT}/{IMAGE_MODEL}:generateContent?key={key}",
        data=body,
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            payload = json.load(response)
    except urllib.error.HTTPError as exc:  # pragma: no cover - network path
        sys.exit(f"Gemini HTTP {exc.code}: {exc.read()[:400]!r}")

    for part in payload["candidates"][0]["content"]["parts"]:
        inline = part.get("inlineData") or part.get("inline_data")
        if inline and inline.get("data"):
            return base64.b64decode(inline["data"])
    sys.exit(f"No image returned: {json.dumps(payload)[:400]}")


def load_pillow():
    """Imports Pillow, with an actionable message when it is missing."""
    try:
        from PIL import Image, ImageFilter  # noqa: PLC0415
    except ImportError:  # pragma: no cover - environment dependent
        sys.exit("Pillow is required: python3 -m pip install --user Pillow")
    return Image, ImageFilter


def save_png(image, path: pathlib.Path, colors: int = 128) -> None:
    """Saves a palette-quantized PNG.

    Gemini adds felt grain that balloons a full-colour PNG past a megabyte;
    quantizing the flat emblem to a palette keeps every icon well under
    100 KB with no visible difference at launcher sizes.
    """
    Image, ImageFilter = load_pillow()
    # A light blur flattens the generated felt grain, which would otherwise
    # dominate the palette and triple the encoded size.
    smoothed = image.convert("RGB").filter(ImageFilter.GaussianBlur(0.4))
    quantized = smoothed.quantize(
        colors=colors, method=Image.MEDIANCUT, dither=Image.NONE
    )
    quantized.save(path, "PNG", optimize=True)


def write_master(name: str, data: bytes, size: int = 1024) -> pathlib.Path:
    """Normalizes generated bytes to a square PNG master."""
    Image, _ = load_pillow()
    BRAND_DIR.mkdir(parents=True, exist_ok=True)
    image = Image.open(io.BytesIO(data)).convert("RGB")
    side = min(image.size)
    left = (image.width - side) // 2
    top = (image.height - side) // 2
    image = image.crop((left, top, left + side, top + side))
    image = image.resize((size, size), Image.LANCZOS)
    path = BRAND_DIR / name
    save_png(image, path)
    print(f"wrote {path.relative_to(REPO)} ({path.stat().st_size // 1024} KB)")
    return path


def install_icons(master: pathlib.Path) -> None:
    """Derives the iOS and Android launcher icon sets from the master PNG."""
    Image, _ = load_pillow()
    source = Image.open(master).convert("RGB")

    IOS_ICON_DIR.mkdir(parents=True, exist_ok=True)
    for size, filename in IOS_SIZES:
        save_png(
            source.resize((size, size), Image.LANCZOS),
            IOS_ICON_DIR / filename,
        )
    print(f"wrote {len(IOS_SIZES)} iOS icons")

    for size, folder in ANDROID_SIZES:
        out_dir = ANDROID_RES / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        save_png(
            source.resize((size, size), Image.LANCZOS),
            out_dir / "ic_launcher.png",
        )
    print(f"wrote {len(ANDROID_SIZES)} Android icons")


def main() -> None:
    """Entry point."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--icons",
        action="store_true",
        help="skip generation and re-derive platform icons from the master",
    )
    args = parser.parse_args()

    master = BRAND_DIR / "app_icon.png"
    if not args.icons:
        key = api_key()
        master = write_master(
            "app_icon.png", generate_image(ICON_PROMPT, key), size=512
        )
        write_master("logo_mark.png", generate_image(LOGO_PROMPT, key), size=512)

    if not master.exists():
        sys.exit(f"missing master icon: {master}")
    install_icons(master)


if __name__ == "__main__":
    main()
