#!/usr/bin/env bash
# Resolve the primary live-poker-trainer checkout on this machine.
#
# Machines differ: some use ~/live-poker-trainer, others ~/live_poker_trainer.
# Prefer PRIMARY when set, then the hyphenated home path, then the underscore
# path, then the git toplevel that owns this script.
#
# Usage:
#   PRIMARY="$(tools/primary_checkout.sh)"
#   # or:
#   source tools/primary_checkout.sh
#   PRIMARY="$(resolve_primary_checkout)"
set -euo pipefail

resolve_primary_checkout() {
  local candidate resolved script_dir repo_root
  if [[ -n "${PRIMARY:-}" && -f "${PRIMARY}/pubspec.yaml" ]]; then
    (cd "$PRIMARY" && pwd -P)
    return 0
  fi

  for candidate in \
    "${HOME}/live-poker-trainer" \
    "${HOME}/live_poker_trainer"
  do
    if [[ -f "${candidate}/pubspec.yaml" ]]; then
      (cd "$candidate" && pwd -P)
      return 0
    fi
  done

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  repo_root="$(cd "${script_dir}/.." && pwd -P)"
  if [[ -f "${repo_root}/pubspec.yaml" ]]; then
    printf '%s\n' "$repo_root"
    return 0
  fi

  echo "error: could not resolve primary checkout (tried \$PRIMARY, ~/live-poker-trainer, ~/live_poker_trainer)" >&2
  return 1
}

if [[ "${BASH_SOURCE[0]-}" == "${0}" ]]; then
  resolve_primary_checkout
fi
