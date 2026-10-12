#!/usr/bin/env python3
"""ISO-8601 helpers for ui-design-agent loop coverage/health timestamps.

macOS Xcode Python 3.9 rejects a trailing ``Z`` in ``datetime.fromisoformat``.
Coverage lines often use UTC ``…Z``; without this helper those rows are skipped
and health.jsonl loses the ticket (LPT-63 stamp 20261010-213534).

The same Python also rejects compact numeric offsets like ``+0530`` (no colon).
Coverage written with ``strftime`` / some emitters uses that form; repair then
misses the window and leaves null-ticket / stamp=reconciled orphans (LPT-490,
LPT-492).
"""

from __future__ import annotations

import re
from datetime import datetime
from typing import Optional

# Trailing ±HHMM without a colon (not ±HH:MM).
_COMPACT_OFFSET = re.compile(r"([+-])(\d{2})(\d{2})$")


def parse_iso_epoch(value: Optional[str]) -> Optional[float]:
    """Parse an ISO-8601 timestamp to epoch seconds, or ``None`` if invalid."""
    if not value:
        return None
    text = value.strip()
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    else:
        match = _COMPACT_OFFSET.search(text)
        if match is not None:
            text = (
                text[: match.start()]
                + f"{match.group(1)}{match.group(2)}:{match.group(3)}"
            )
    try:
        return datetime.fromisoformat(text).timestamp()
    except ValueError:
        return None
