#!/usr/bin/env python3
"""Drive the debug app via ext.poker.agent (tap / openlesson / type).

Reads the Dart VM URI from /tmp/flutter-live-poker-trainer.run.log.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

LOG = Path("/tmp/flutter-live-poker-trainer.run.log")


def vm_base() -> tuple[str, str]:
    """Return (port, token) from the Flutter run log."""
    text = LOG.read_bytes().replace(b"\x00", b"").decode("utf-8", "replace")
    match = re.search(r"http://127\.0\.0\.1:(\d+)/([A-Za-z0-9_\-=]+)/", text)
    if not match:
        raise SystemExit("No Dart VM URI in flutter run log yet")
    return match.group(1), match.group(2)


def isolate_id(port: str, token: str) -> str:
    """Pick the main isolate id."""
    with urllib.request.urlopen(f"http://127.0.0.1:{port}/{token}/getVM") as resp:
        payload = json.load(resp)
    isolates = payload["result"]["isolates"]
    for isolate in isolates:
        if "main" in isolate.get("name", "").lower():
            return isolate["id"]
    return isolates[0]["id"]


def agent(cmd: str, **extra: str) -> None:
    """Invoke ext.poker.agent with cmd (+ optional text/label)."""
    port, token = vm_base()
    iso = isolate_id(port, token)
    params = {"isolateId": iso, "cmd": cmd, **extra}
    query = urllib.parse.urlencode(params)
    url = f"http://127.0.0.1:{port}/{token}/ext.poker.agent?{query}"
    with urllib.request.urlopen(url) as resp:
        print(cmd, extra or "", "->", resp.read().decode())


def main() -> None:
    """CLI entrypoint."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cmd", help="Agent command (tap, openlesson, type, ...)")
    parser.add_argument("--text", default="", help="Label/text for tap/type/openlesson")
    args = parser.parse_args()
    extra = {"text": args.text} if args.text else {}
    agent(args.cmd, **extra)


if __name__ == "__main__":
    main()
