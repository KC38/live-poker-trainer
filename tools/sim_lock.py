#!/usr/bin/env python3
"""Shared usage lock for the one agent simulator (iPhone 13 mini).

Every agent that boots, runs, restarts, installs, taps, types into, or
screenshots the mini holds this lock first. The lock is a JSON file outside
the git tree so every checkout and worktree sees the same one:

    ~/.live-poker-trainer/simulator-lock.json   (current holder, or free)
    ~/.live-poker-trainer/simulator-lock.log    (claim / release history)

Set ``SIM_LOCK_DIR`` to use another directory (tests do).

Commands:

    status                 Show the holder. Exit 0 when free, 3 when in use.
    claim --owner NAME     Take the lock. Prints the run id. Exit 3 when busy.
    heartbeat --run-id ID  Prove the holder is alive. Exit 4 if not holder.
    guard [--run-id ID]    Exit 0 only when ID holds the lock (refreshes the
                           heartbeat). Tools call this before touching the mini.
    release --run-id ID    Free the lock. ``--force`` frees any holder.
                           ``--if-pid PID`` frees only a lock claimed by PID.

``--run-id`` defaults to ``$SIM_LOCK_RUN_ID``. ``claim --pid`` defaults to
``$SIM_LOCK_PID``. A held lock is stale, and free to claim, when its pid has
exited or its last heartbeat is older than its TTL (default two hours).
"""

from __future__ import annotations

import argparse
import contextlib
import fcntl
import json
import os
import secrets
import socket
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterator, Optional

DEVICE = "iPhone 13 mini"
DEFAULT_TTL_SECONDS = 2 * 60 * 60
# Holders that never recorded a pid (buggy claim) must not block the mini
# for the full TTL. Ten minutes without a heartbeat is enough to call them
# orphaned.
NO_PID_STALE_SECONDS = 10 * 60
EXIT_OK = 0
EXIT_BUSY = 3
EXIT_NOT_HOLDER = 4

State = Dict[str, Any]


def lock_dir() -> Path:
    """Directory that holds the lock, its mutex, and its history."""
    override = os.environ.get("SIM_LOCK_DIR")
    if override:
        return Path(override).expanduser()
    return Path.home() / ".live-poker-trainer"


def lock_path() -> Path:
    """Path of the current-holder JSON file."""
    return lock_dir() / "simulator-lock.json"


def history_path() -> Path:
    """Path of the append-only claim / release history."""
    return lock_dir() / "simulator-lock.log"


def _iso(epoch: float) -> str:
    """Local wall-clock time with offset, for humans reading the file."""
    return datetime.fromtimestamp(epoch).astimezone().isoformat(timespec="seconds")


def _free_state(last: Optional[State] = None) -> State:
    """A free lock, optionally remembering the previous holder."""
    state: State = {"state": "free", "device": DEVICE}
    if last:
        state["last"] = last
    return state


@contextlib.contextmanager
def _mutex() -> Iterator[None]:
    """Serialize read-modify-write of the lock file across processes."""
    directory = lock_dir()
    directory.mkdir(parents=True, exist_ok=True)
    with open(directory / "simulator-lock.mutex", "a+", encoding="utf-8") as handle:
        fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(handle.fileno(), fcntl.LOCK_UN)


def read_state() -> State:
    """Return the lock file contents, or a free state when absent or corrupt."""
    try:
        data = json.loads(lock_path().read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return _free_state()
    if not isinstance(data, dict) or data.get("state") not in ("free", "in_use"):
        return _free_state()
    return data


def _write_state(state: State) -> None:
    """Atomically replace the lock file."""
    path = lock_path()
    tmp = path.with_suffix(f".{os.getpid()}.tmp")
    tmp.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
    os.replace(tmp, path)


def _log(event: str, state: State, **extra: Any) -> None:
    """Append one history line. History is best effort."""
    entry = {
        "at": _iso(time.time()),
        "event": event,
        "owner": state.get("owner"),
        "run_id": state.get("run_id"),
        "purpose": state.get("purpose"),
        **extra,
    }
    try:
        with open(history_path(), "a", encoding="utf-8") as handle:
            handle.write(json.dumps(entry) + "\n")
    except OSError:
        pass


def pid_alive(pid: int) -> bool:
    """True when a process with this pid exists."""
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def stale_reason(state: State, now: Optional[float] = None) -> Optional[str]:
    """Why a held lock may be taken over, or None when it is live or free."""
    if state.get("state") != "in_use":
        return None
    now = time.time() if now is None else now
    pid = state.get("pid")
    if isinstance(pid, int) and not pid_alive(pid):
        return f"owner pid {pid} exited"
    ttl = int(state.get("ttl_seconds") or DEFAULT_TTL_SECONDS)
    beat = float(state.get("heartbeat_epoch") or state.get("claimed_epoch") or 0)
    age = now - beat
    if not isinstance(pid, int) and age > NO_PID_STALE_SECONDS:
        return (
            f"no pid and no heartbeat for {int(age // 60)} min "
            f"(orphan grace {NO_PID_STALE_SECONDS // 60} min)"
        )
    if age > ttl:
        return f"no heartbeat for {int(age // 60)} min (ttl {ttl // 60} min)"
    return None


def is_busy(state: State) -> bool:
    """True when someone live holds the lock."""
    return state.get("state") == "in_use" and stale_reason(state) is None


def describe(state: State) -> str:
    """One human-readable paragraph about the lock."""
    if state.get("state") != "in_use":
        text = f"{DEVICE}: FREE"
        last = state.get("last")
        if isinstance(last, dict):
            text += (
                f"\n  last: {last.get('owner')} ({last.get('run_id')}), "
                f"{last.get('reason', 'released')} at {last.get('released_at')}"
            )
        return text
    now = time.time()
    beat = float(state.get("heartbeat_epoch") or now)
    pid = state.get("pid")
    pid_text = "none"
    if isinstance(pid, int):
        pid_text = f"{pid} ({'alive' if pid_alive(pid) else 'exited'})"
    stale = stale_reason(state, now)
    head = "STALE (claimable)" if stale else "IN USE"
    lines = [
        f"{DEVICE}: {head} by {state.get('owner')} (run {state.get('run_id')})",
        f"  purpose: {state.get('purpose') or '-'}",
        f"  since: {state.get('claimed_at')}, heartbeat {int((now - beat) // 60)} min ago, "
        f"ttl {int(state.get('ttl_seconds') or DEFAULT_TTL_SECONDS) // 60} min",
        f"  pid: {pid_text}, host: {state.get('host')}",
    ]
    if stale:
        lines.append(f"  stale: {stale}")
    return "\n".join(lines)


def claim(
    owner: str,
    purpose: str = "",
    pid: Optional[int] = None,
    ttl_seconds: int = DEFAULT_TTL_SECONDS,
) -> tuple[int, State]:
    """Take the lock for ``owner``. Returns (exit code, resulting state)."""
    with _mutex():
        current = read_state()
        if is_busy(current):
            return EXIT_BUSY, current
        reason = stale_reason(current)
        if reason:
            _log("stale-cleared", current, reason=reason)
        now = time.time()
        stamp = datetime.fromtimestamp(now).strftime("%Y%m%d-%H%M%S")
        state: State = {
            "state": "in_use",
            "device": DEVICE,
            "owner": owner,
            "run_id": f"{owner}-{stamp}-{secrets.token_hex(2)}",
            "pid": pid,
            "host": socket.gethostname(),
            "purpose": purpose,
            "claimed_at": _iso(now),
            "claimed_epoch": now,
            "heartbeat_at": _iso(now),
            "heartbeat_epoch": now,
            "ttl_seconds": ttl_seconds,
        }
        _write_state(state)
        _log("claim", state, pid=pid)
        return EXIT_OK, state


def _holds(state: State, run_id: Optional[str]) -> bool:
    """True when ``run_id`` is the live holder."""
    return bool(run_id) and is_busy(state) and state.get("run_id") == run_id


def heartbeat(run_id: Optional[str], purpose: Optional[str] = None) -> tuple[int, State]:
    """Refresh the holder's heartbeat (and optionally its purpose)."""
    with _mutex():
        current = read_state()
        if not _holds(current, run_id):
            return (EXIT_BUSY if is_busy(current) else EXIT_NOT_HOLDER), current
        now = time.time()
        current["heartbeat_at"] = _iso(now)
        current["heartbeat_epoch"] = now
        if purpose:
            current["purpose"] = purpose
        _write_state(current)
        return EXIT_OK, current


def release(
    run_id: Optional[str] = None,
    force: bool = False,
    if_pid: Optional[int] = None,
) -> tuple[int, State]:
    """Free the lock. Only the holder may, unless ``force`` or ``if_pid`` matches."""
    with _mutex():
        current = read_state()
        if current.get("state") != "in_use":
            return EXIT_OK, current
        if if_pid is not None:
            if current.get("pid") != if_pid:
                return EXIT_OK, current
            reason = f"released after pid {if_pid} ended"
        elif force:
            reason = "force-released"
        elif current.get("run_id") == run_id and run_id:
            reason = "released"
        else:
            return (EXIT_BUSY if is_busy(current) else EXIT_NOT_HOLDER), current
        last = {
            "owner": current.get("owner"),
            "run_id": current.get("run_id"),
            "purpose": current.get("purpose"),
            "claimed_at": current.get("claimed_at"),
            "released_at": _iso(time.time()),
            "reason": reason,
        }
        free = _free_state(last)
        _write_state(free)
        _log(reason.split(" ")[0], current, reason=reason)
        return EXIT_OK, free


def guard(run_id: Optional[str]) -> tuple[int, State]:
    """Exit 0 only for the live holder. Refreshes its heartbeat."""
    return heartbeat(run_id)


def _env_int(name: str) -> Optional[int]:
    """Integer env var, or None when unset or not a number."""
    raw = os.environ.get(name, "").strip()
    return int(raw) if raw.isdigit() else None


def build_parser() -> argparse.ArgumentParser:
    """CLI parser."""
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    status = sub.add_parser("status", help="show the holder; exit 3 when in use")
    status.add_argument("--json", action="store_true", help="print the raw JSON")

    claim_p = sub.add_parser("claim", help="take the lock; prints the run id")
    claim_p.add_argument("--owner", required=True, help="who is claiming, e.g. ui-design-agent")
    claim_p.add_argument("--purpose", default="", help="what the mini is being used for")
    claim_p.add_argument("--pid", type=int, default=None, help="pid whose exit frees the lock")
    claim_p.add_argument(
        "--ttl", type=int, default=DEFAULT_TTL_SECONDS, help="seconds without a heartbeat before stale"
    )

    beat = sub.add_parser("heartbeat", help="refresh the holder's heartbeat")
    beat.add_argument("--run-id", default=None)
    beat.add_argument("--purpose", default=None, help="replace the purpose text")

    guard_p = sub.add_parser("guard", help="exit 0 only when --run-id holds the lock")
    guard_p.add_argument("--run-id", default=None)

    rel = sub.add_parser("release", help="free the lock")
    rel.add_argument("--run-id", default=None)
    rel.add_argument("--force", action="store_true", help="free any holder (humans only)")
    rel.add_argument("--if-pid", type=int, default=None, help="free only a lock claimed by this pid")
    return parser


def main(argv: Optional[list[str]] = None) -> int:
    """CLI entrypoint. Returns the process exit code."""
    args = build_parser().parse_args(argv)
    run_id = getattr(args, "run_id", None) or os.environ.get("SIM_LOCK_RUN_ID") or None

    if args.cmd == "status":
        state = read_state()
        print(json.dumps(state, indent=2) if args.json else describe(state))
        return EXIT_BUSY if is_busy(state) else EXIT_OK

    if args.cmd == "claim":
        pid = args.pid if args.pid is not None else _env_int("SIM_LOCK_PID")
        code, state = claim(args.owner, args.purpose, pid, args.ttl)
        if code == EXIT_OK:
            print(state["run_id"])
            print(f"claimed {DEVICE} as {state['run_id']}", file=sys.stderr)
        else:
            print(describe(state), file=sys.stderr)
        return code

    if args.cmd in ("heartbeat", "guard"):
        purpose = getattr(args, "purpose", None)
        code, state = heartbeat(run_id, purpose)
        if code != EXIT_OK:
            hint = "" if is_busy(state) else f"\nClaim it first: python3 tools/sim_lock.py claim --owner <you>"
            print(f"{describe(state)}\nnot the holder (run id {run_id or 'unset'}){hint}", file=sys.stderr)
        return code

    code, state = release(run_id, args.force, args.if_pid)
    if code == EXIT_OK:
        print(describe(state), file=sys.stderr)
    else:
        print(f"{describe(state)}\nnot the holder (run id {run_id or 'unset'})", file=sys.stderr)
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
