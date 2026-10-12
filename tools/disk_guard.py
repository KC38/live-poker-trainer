#!/usr/bin/env python3
"""Free disk before simulator builds so Xcode never dies on a full disk.

Each make-change worktree leaves a ~4 GB Xcode DerivedData folder and a
``build/`` tree. A full disk mid-build (LPT-39) forced a DerivedData wipe
and a from-scratch Pods rebuild that cost ~15 minutes.

Always removes garbage that nothing can use again:
  * DerivedData folders whose workspace path no longer exists.
  * ``/tmp/flutter_tools.*`` scratch older than a day.
  * Unregistered ``.worktrees/deploy-*`` leftovers.

When free space is under ``--min-free-gb`` it also removes idle worktree
``build/`` trees and their DerivedData (untouched for two hours and not
used by a running process), and trims the Runner.app cache to one entry.
The primary checkout's own build and DerivedData are never touched.

Usage:
    python3 tools/disk_guard.py [--min-free-gb 25] [--dry-run] [--quiet]
"""

from __future__ import annotations

import argparse
import os
import plistlib
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

DERIVED_DATA = Path.home() / "Library/Developer/Xcode/DerivedData"
APP_CACHE = Path(
    os.environ.get(
        "UI_AGENT_APP_CACHE_DIR",
        str(Path.home() / ".live-poker-trainer/app-cache"),
    )
)
IDLE_SECONDS = 2 * 3600
TMP_SECONDS = 24 * 3600


@dataclass
class Report:
    """What was (or would be) removed."""

    dry_run: bool
    removed: list[tuple[Path, int]] = field(default_factory=list)

    def remove(self, path: Path) -> None:
        """Delete [path] (unless dry-run) and record its size."""
        size = _du(path)
        self.removed.append((path, size))
        if self.dry_run:
            return
        if path.is_dir() and not path.is_symlink():
            shutil.rmtree(path, ignore_errors=True)
        else:
            path.unlink(missing_ok=True)

    @property
    def freed(self) -> int:
        """Total bytes freed."""
        return sum(size for _, size in self.removed)


def _du(path: Path) -> int:
    """Best-effort recursive size in bytes."""
    if path.is_file() or path.is_symlink():
        try:
            return path.lstat().st_size
        except OSError:
            return 0
    total = 0
    for root, _dirs, files in os.walk(path, onerror=lambda _e: None):
        for name in files:
            try:
                total += os.lstat(os.path.join(root, name)).st_size
            except OSError:
                pass
    return total


def free_gb(path: Path = Path("/")) -> float:
    """Free space on the volume holding [path], in GiB."""
    return shutil.disk_usage(path).free / (1024**3)


def _primary() -> Path:
    """Primary checkout (tools/primary_checkout.sh)."""
    script = Path(__file__).with_name("primary_checkout.sh")
    out = subprocess.run(
        ["bash", str(script)], capture_output=True, text=True, check=False
    ).stdout.strip()
    return Path(out or Path(__file__).resolve().parents[1])


def _workspace_of(derived: Path) -> Path | None:
    """WorkspacePath recorded in a DerivedData folder, if any."""
    info = derived / "info.plist"
    try:
        with info.open("rb") as handle:
            value = plistlib.load(handle).get("WorkspacePath")
    except (OSError, plistlib.InvalidFileException):
        return None
    return Path(value) if value else None


def _age(path: Path) -> float:
    """Seconds since [path] was last modified."""
    try:
        return time.time() - path.stat().st_mtime
    except OSError:
        return 0.0


def _process_commands() -> str:
    """All running command lines (to spot in-use worktrees)."""
    return subprocess.run(
        ["ps", "-axo", "command="], capture_output=True, text=True, check=False
    ).stdout


def _registered_worktrees(primary: Path) -> set[Path]:
    """Paths `git worktree list` still knows about."""
    out = subprocess.run(
        ["git", "-C", str(primary), "worktree", "list", "--porcelain"],
        capture_output=True,
        text=True,
        check=False,
    ).stdout
    return {
        Path(line.split(" ", 1)[1])
        for line in out.splitlines()
        if line.startswith("worktree ")
    }


def prune_garbage(report: Report, primary: Path) -> None:
    """Remove artifacts that no checkout can reuse."""
    if DERIVED_DATA.is_dir():
        for derived in DERIVED_DATA.iterdir():
            if not derived.is_dir():
                continue
            workspace = _workspace_of(derived)
            if workspace is not None and not workspace.exists():
                report.remove(derived)
    tmp = Path("/tmp")
    for scratch in tmp.glob("flutter_tools.*"):
        if _age(scratch) > TMP_SECONDS:
            report.remove(scratch)
    registered = _registered_worktrees(primary)
    worktrees = primary / ".worktrees"
    if worktrees.is_dir():
        for leftover in worktrees.glob("deploy-*"):
            if leftover not in registered and _age(leftover) > 3600:
                report.remove(leftover)


def prune_idle_worktrees(report: Report, primary: Path) -> None:
    """Remove idle ticket-worktree builds and their DerivedData."""
    commands = _process_commands()
    worktrees = primary / ".worktrees"
    idle: list[Path] = []
    if worktrees.is_dir():
        for tree in worktrees.iterdir():
            build = tree / "build"
            # Long-lived `*-main` worktrees back other simulators (play-test).
            if tree.name.endswith("main"):
                continue
            if not build.is_dir() or str(tree) in commands:
                continue
            if _age(build) > IDLE_SECONDS:
                idle.append(tree)
                report.remove(build)
    if DERIVED_DATA.is_dir():
        for derived in DERIVED_DATA.iterdir():
            workspace = _workspace_of(derived)
            if workspace is None:
                continue
            if any(str(workspace).startswith(str(tree)) for tree in idle):
                report.remove(derived)
    if APP_CACHE.is_dir():
        entries = sorted(
            (p for p in APP_CACHE.iterdir() if p.is_dir()),
            key=lambda p: p.stat().st_mtime,
            reverse=True,
        )
        for stale in entries[1:]:
            report.remove(stale)


def main(argv: list[str]) -> int:
    """CLI entrypoint."""
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--min-free-gb",
        type=float,
        default=float(os.environ.get("UI_AGENT_MIN_FREE_GB", "25")),
    )
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args(argv)

    primary = _primary()
    report = Report(dry_run=args.dry_run)
    before = free_gb()
    prune_garbage(report, primary)
    if before - report.freed / (1024**3) < args.min_free_gb:
        prune_idle_worktrees(report, primary)
    verb = "would free" if args.dry_run else "freed"
    if not args.quiet or report.removed:
        for path, size in report.removed:
            print(f"disk_guard: {verb} {size / (1024**3):.1f}G {path}")
        print(
            f"disk_guard: {verb} {report.freed / (1024**3):.1f}G; "
            f"free {free_gb():.1f}G (min {args.min_free_gb:.0f}G)"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
