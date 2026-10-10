#!/usr/bin/env python3
"""ISO-8601 helpers for ui-design-agent loop coverage/health timestamps.

macOS Xcode Python 3.9 rejects a trailing ``Z`` in ``datetime.fromisoformat``.
Coverage lines often use UTC ``…Z``; without this helper those rows are skipped
and health.jsonl loses the ticket (LPT-63 stamp 20261010-213534).
"""

from __future__ import annotations

from datetime import datetime
from typing import Optional


def parse_iso_epoch(value: Optional[str]) -> Optional[float]:
    """Parse an ISO-8601 timestamp to epoch seconds, or ``None`` if invalid."""
    if not value:
        return None
    text = value.strip()
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    try:
        return datetime.fromisoformat(text).timestamp()
    except ValueError:
        return None
