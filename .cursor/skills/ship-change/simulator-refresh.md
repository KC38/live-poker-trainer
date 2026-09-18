# Simulator refresh

Used after `main` is updated with a shipped change.

## Prefer the script

```bash
.cursor/skills/ship-change/scripts/refresh-simulator.sh
```

Behavior:

1. If `/tmp/flutter-live-poker-trainer.pid` exists → `kill -USR2` (hot restart).
2. Else if a `flutter_tools … run` process exists → `kill -USR2` on that pid.
3. Else start `flutter run` on a booted iOS simulator (fallback: Android, then macOS) with that pid-file.
4. If no device → skip (do not fail the ship).
