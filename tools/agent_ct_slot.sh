#!/usr/bin/env bash
# Hold Mac mini agent schedules on America/Chicago wall-clock times.
#
# The Mac mini runs on IST (no DST) while targets are CT (CDT UTC-5 until
# Nov 1 2026, then CST UTC-6). launchd StartCalendarInterval only knows
# local time, so install() registers BOTH local candidates for each CT
# target (the CDT one and the CST one, an hour apart) and tick() runs only
# when the current America/Chicago time is within CT_SLOT_WINDOW_MIN
# (default 10, inclusive) of a target. A stamp file keeps one run per CT
# slot (last 40 ids), so the off-season candidate is a no-op. No edits
# needed at DST changes.
#
# Source this file, then:
#   ct_slot_calendar "03:00 15:00"      -> "H M" lines (local) for launchd
#   ct_slot_due "03:00 15:00" STAMP      -> prints slot id + returns 0 if due
#   ct_slot_mark STAMP SLOT              -> record the slot as run
#   ct_slot_next "03:00 15:00"           -> next target as "YYYY-MM-DD HH:MM CT"
# Env: CT_SLOT_NOW_EPOCH (tests), CT_SLOT_WINDOW_MIN.

_ct_slot_py() {
  python3 - "$@" <<'PY'
import os, sys, time
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
CT = ZoneInfo("America/Chicago")
cmd, targets = sys.argv[1], sys.argv[2].split()
now = datetime.fromtimestamp(float(os.environ.get("CT_SLOT_NOW_EPOCH") or time.time()), timezone.utc)
win = int(os.environ.get("CT_SLOT_WINDOW_MIN") or 10)
def hm(t):
    h, m = t.split(":"); return int(h), int(m)
if cmd == "calendar":
    local_off = now.astimezone().utcoffset()
    seen = []
    for t in targets:
        h, m = hm(t)
        for ct_off in (-5, -6):  # CDT, CST
            base = datetime(2000, 1, 1, h, m) - timedelta(hours=ct_off) + local_off
            key = (base.hour, base.minute)
            if key not in seen:
                seen.append(key)
    for h, m in seen:
        print(h, m)
elif cmd == "due":
    stamp = sys.argv[3]
    done = set()
    if os.path.exists(stamp):
        done = set(open(stamp).read().split())
    n = now.astimezone(CT)
    for t in targets:
        h, m = hm(t)
        for d in (-1, 0, 1):
            tgt = datetime(n.year, n.month, n.day, h, m, tzinfo=CT) + timedelta(days=d)
            if abs((n - tgt).total_seconds()) <= win * 60:
                slot = tgt.strftime("%Y-%m-%dT%H:%M")
                if slot in done:
                    print("already-ran " + slot); sys.exit(3)
                print(slot); sys.exit(0)
    print("not-due (now %s CT; targets %s)" % (n.strftime("%Y-%m-%d %H:%M"), " ".join(targets)))
    sys.exit(1)
elif cmd == "next":
    n = now.astimezone(CT)
    cands = []
    for t in targets:
        h, m = hm(t)
        for d in (0, 1):
            tgt = datetime(n.year, n.month, n.day, h, m, tzinfo=CT) + timedelta(days=d)
            if tgt > n: cands.append(tgt)
    print(min(cands).strftime("%Y-%m-%d %H:%M CT"))
PY
}

ct_slot_calendar() { _ct_slot_py calendar "$1"; }
ct_slot_due() { _ct_slot_py due "$1" "$2"; }
ct_slot_next() { _ct_slot_py next "$1"; }
ct_slot_mark() {
  mkdir -p "$(dirname "$1")"
  echo "$2" >>"$1"
  # Keep the stamp file short.
  tail -n 40 "$1" >"$1.tmp" && mv "$1.tmp" "$1"
}

# launchd <array> body of <dict>s for the given CT targets.
ct_slot_plist_entries() {
  local h m
  while read -r h m; do
    printf '    <dict><key>Hour</key><integer>%d</integer><key>Minute</key><integer>%d</integer></dict>\n' "$h" "$m"
  done < <(ct_slot_calendar "$1")
}
