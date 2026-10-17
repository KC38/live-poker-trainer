#!/usr/bin/env bash
# Boundary tests for the shared CT slot gate (tools/agent_ct_slot.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=agent_ct_slot.sh
source "$ROOT/tools/agent_ct_slot.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

epoch_at() {
  python3 - "$@" <<'PY'
import sys
from datetime import datetime
from zoneinfo import ZoneInfo

parts = [int(x) for x in sys.argv[1:7]]
when = datetime(*parts, tzinfo=ZoneInfo("America/Chicago"))
print(int(when.timestamp()))
PY
}

base="$(epoch_at 2026 10 16 9 0 0)"
targets="09:00 21:00"
stamp="$(mktemp)"
markfile="$(mktemp)"
trap 'rm -f "$stamp" "$markfile"' EXIT

due_out="$(CT_SLOT_NOW_EPOCH=$((base + 600)) ct_slot_due "$targets" "$stamp")"
[[ "$due_out" == "2026-10-16T09:00" ]] \
  || fail "10 min late must still be due: $due_out"

set +e
late="$(CT_SLOT_NOW_EPOCH=$((base + 601)) ct_slot_due "$targets" "$stamp" 2>&1)"
late_code=$?
set -e
[[ "$late_code" -eq 1 ]] \
  || fail "10 min + 1s must not be due (code $late_code): $late"
grep -q 'not-due' <<<"$late" || fail "expected not-due: $late"

early="$(CT_SLOT_NOW_EPOCH=$((base - 600)) ct_slot_due "$targets" "$stamp")"
[[ "$early" == "2026-10-16T09:00" ]] \
  || fail "10 min early must be due: $early"

set +e
too_early="$(CT_SLOT_NOW_EPOCH=$((base - 601)) ct_slot_due "$targets" "$stamp" 2>&1)"
too_code=$?
set -e
[[ "$too_code" -eq 1 ]] \
  || fail "10 min + 1s early must not be due (code $too_code): $too_early"

echo "2026-10-16T09:00" >"$stamp"
set +e
again="$(CT_SLOT_NOW_EPOCH="$base" ct_slot_due "$targets" "$stamp" 2>&1)"
again_code=$?
set -e
[[ "$again_code" -eq 3 ]] \
  || fail "stamped slot must be already-ran (code $again_code): $again"
grep -q 'already-ran 2026-10-16T09:00' <<<"$again" \
  || fail "already-ran text: $again"

echo "2026-10-15T09:00" >"$stamp"
today="$(CT_SLOT_NOW_EPOCH="$base" ct_slot_due "$targets" "$stamp")"
[[ "$today" == "2026-10-16T09:00" ]] \
  || fail "prior day must not block today's slot: $today"

next_at="$(CT_SLOT_NOW_EPOCH="$base" ct_slot_next "$targets")"
[[ "$next_at" == "2026-10-16 21:00 CT" ]] \
  || fail "next at 09:00 sharp should be 21:00: $next_at"

night="$(epoch_at 2026 10 16 21 30 0)"
next_night="$(CT_SLOT_NOW_EPOCH="$night" ct_slot_next "$targets")"
[[ "$next_night" == "2026-10-17 09:00 CT" ]] \
  || fail "next after 21:30 should be tomorrow 09:00: $next_night"

: >"$markfile"
i=1
while [[ "$i" -le 41 ]]; do
  ct_slot_mark "$markfile" "slot-$i"
  i=$((i + 1))
done
lines="$(wc -l <"$markfile" | tr -d ' ')"
[[ "$lines" -eq 40 ]] || fail "stamp should keep 40 lines, got $lines"
[[ "$(head -n 1 "$markfile")" == "slot-2" ]] \
  || fail "oldest slot should drop, head=$(head -n 1 "$markfile")"
[[ "$(tail -n 1 "$markfile")" == "slot-41" ]] \
  || fail "newest slot should remain, tail=$(tail -n 1 "$markfile")"

cal_ui="$(TZ=Asia/Kolkata CT_SLOT_NOW_EPOCH="$base" ct_slot_calendar "09:00 21:00")"
for hm in "19 30" "20 30" "7 30" "8 30"; do
  grep -qx "$hm" <<<"$cal_ui" || fail "UI IST candidate missing $hm: $cal_ui"
done
cal_content="$(TZ=Asia/Kolkata CT_SLOT_NOW_EPOCH="$base" ct_slot_calendar "03:00 15:00")"
for hm in "13 30" "14 30" "1 30" "2 30"; do
  grep -qx "$hm" <<<"$cal_content" \
    || fail "content IST candidate missing $hm: $cal_content"
done

cal_ct="$(TZ=America/Chicago CT_SLOT_NOW_EPOCH="$base" ct_slot_calendar "09:00 21:00")"
for hm in "9 0" "10 0" "21 0" "22 0"; do
  grep -qx "$hm" <<<"$cal_ct" || fail "Chicago candidate missing $hm: $cal_ct"
done

echo "agent_ct_slot ok"
