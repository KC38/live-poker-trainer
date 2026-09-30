#!/usr/bin/env bash
# Resolve the available iPhone 13 mini simulator UDID via simctl.
# Never hardcode a UDID — call this (or source it) whenever a device id is needed.
#
# Usage:
#   DEVICE="$(tools/iphone_13_mini_udid.sh)"
#   # or:
#   source tools/iphone_13_mini_udid.sh
#   DEVICE="$(resolve_iphone_13_mini_udid)"
set -euo pipefail

resolve_iphone_13_mini_udid() {
  local line udid
  while IFS= read -r line; do
    case "$line" in
      *'iPhone 13 mini'*|*'iPhone 13 Mini'*)
        if [[ "$line" =~ \(([0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})\) ]]; then
          udid="${BASH_REMATCH[1]}"
          printf '%s\n' "$udid"
          return 0
        fi
        ;;
    esac
  done < <(xcrun simctl list devices available 2>/dev/null)
  echo "error: no available iPhone 13 mini simulator found" >&2
  return 1
}

if [[ "${BASH_SOURCE[0]-}" == "${0}" ]]; then
  resolve_iphone_13_mini_udid
fi
