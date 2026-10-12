#!/usr/bin/env bash
# Run a command, tee stdout/stderr to a log, exit with the command's status
# (not tee's). Bare `cmd | tee log; echo EXIT:$?` masks failures because tee
# succeeds — ui-agent LPT-367 hit EXIT:0 after "Some tests failed".
#
# Usage:
#   tools/tee_exit.sh /tmp/test-LPT-367.log flutter test test/foo_test.dart
#   tools/tee_exit.sh /tmp/analyze-LPT-367.log dart analyze
#
# Prints EXIT:<code> on the last line (and to the log) for tmux capture, and
# writes <log-without-.log>.done with that code so waiters can poll a file
# instead of grepping the pane (send-keys text itself contains EXIT:$? and
# false-triggers early kills — LPT-391).
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <log-path> <command> [args...]" >&2
  exit 2
fi

log="$1"
shift

if [[ "$log" == *.log ]]; then
  done_file="${log%.log}.done"
else
  done_file="${log}.done"
fi

mkdir -p "$(dirname "$log")"
rm -f "$done_file"
set +e
set -o pipefail
"$@" 2>&1 | tee -a "$log"
code="${PIPESTATUS[0]}"
set +o pipefail
set -e

printf 'EXIT:%s\n' "$code" | tee -a "$log"
printf '%s\n' "$code" >"$done_file"
exit "$code"
