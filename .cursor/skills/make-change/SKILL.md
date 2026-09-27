---
name: make-change
description: >-
  Implement a bug fix or feature in a .worktrees worktree via one subagent,
  then commit, PR, merge, deploy Cloud Functions, and refresh simulators.
  Use when the user asks for a code change. Never edit ~/live-poker-trainer.
---

# Make a change

The primary checkout `~/live-poker-trainer` stays untouched. A subagent does
the work in `.worktrees/<slug>`.

## Parent

Do not edit files, commit, or switch branches in `~/live-poker-trainer`.

Launch one subagent with the requested change and this skill. It creates the
worktree and runs every step below. When it returns, do not resume it.

## Subagent

```
Change progress:
- [ ] 1. Worktree off origin/main
- [ ] 2. Implement, verify, validate
- [ ] 3. Logical commits
- [ ] 4. Review the diff
- [ ] 5. Tests cover the change
- [ ] 6. Push, open PR, merge to main
- [ ] 7. Delete branch and worktree; sync primary
- [ ] 8. Deploy Cloud Functions
- [ ] 9. Refresh simulators if any are running
```

Work only inside the worktree. Do not edit the primary checkout.

### 1. Worktree off origin/main

From `~/live-poker-trainer`:

If `.worktrees` does not exist, create it. If `.gitignore` has no
`.worktrees/` entry, add one inside the worktree.

```bash
git fetch origin main
mkdir -p .worktrees
git worktree add -b feature/<slug> .worktrees/<slug> origin/main
grep -qxF '.worktrees/' .worktrees/<slug>/.gitignore 2>/dev/null \
  || echo '.worktrees/' >> .worktrees/<slug>/.gitignore
```

Use `fix/<slug>` for a bug fix. `<slug>` is kebab-case. The directory is
`.worktrees/<slug>`, not a nested path.

Copy gitignored Firebase files into the worktree when they are missing:

- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json`

### 2. Implement, verify, validate

Keep the diff scoped to the request. Run targeted checks (`dart analyze`,
relevant tests). Leave the worktree runnable.

Simulator validation must show the worktree, not `origin/main`. Do not
call [simulator-refresh](../simulator-refresh/SKILL.md) until after the
merge. That skill always returns sims to the primary clone.

Use only the agent iPhone 17 Pro
(`F1AE4938-D9BE-4EA1-8C98-58555A0DE62A`). Leave the user iPhone 17
(`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`) alone.

Hot restart (`kill -USR2`) reloads the directory that `flutter run` was
started from. It cannot point a session from `~/live-poker-trainer` at
`.worktrees/<slug>`. Once the Pro session **is** that worktree, every later
validation is a hot restart. Do not kill and relaunch for those.

If the Pro `flutter run` cwd is already `.worktrees/<slug>`:

```bash
kill -USR2 "$(cat /tmp/flutter-live-poker-trainer.pid)"
```

Replace the process only when no Pro session is running, or the running one
was started from a different checkout. Boot the Pro if it is not booted.
Do not follow [launch-simulator](../launch-simulator/SKILL.md); that starts
`origin/main`.

```bash
PRO=F1AE4938-D9BE-4EA1-8C98-58555A0DE62A
WT="$HOME/live-poker-trainer/.worktrees/<slug>"
SESSION=flutter-pro-lessons

open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app
xcrun simctl bootstatus "$PRO" -b || xcrun simctl boot "$PRO"

tmux kill-session -t "$SESSION" 2>/dev/null || true
tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "cd '$WT' && flutter run -d $PRO --pid-file /tmp/flutter-live-poker-trainer.pid 2>&1 | tee /tmp/flutter-live-poker-trainer.run.log; echo EXIT:\$?" Enter
```

Wait for `Dart VM Service on iPhone 17 Pro` in the log. A screenshot used
to confirm the change goes in the worktree's `.cursor/tmp/`. Delete it
after you have read it.

After the merge, step 9 stops this session and puts running sims back on
`origin/main`.

### 3. Logical commits

Commit on the feature branch only. Separate commits by logical change.
Why-focused messages. Never commit on `main`. Never stage secrets
(`.env*`, `*.pem`, `android/app/google-services.json`,
`ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart`).

### 4. Review the diff

Read `git diff origin/main...HEAD`. Fix correctness, regressions, secrets,
and scope creep before opening the PR.

### 5. Tests

Add or update tests that cover the change. Do not merge without them.

### 6. Push, PR, merge

```bash
git push -u origin HEAD
gh pr create --title "<concise title>" --body "$(cat <<'EOF'
## Summary
- <what / why>

## Test plan
- [ ] <how to verify>
EOF
)"
gh pr merge --squash --delete-branch
```

Never force-push `main`. If `gh` fails, stop and report.

### 7. Delete the branch and worktree, then sync primary

```bash
cd ~/live-poker-trainer
git worktree remove .worktrees/<slug>
git branch -d feature/<slug>   # or fix/<slug>
git push origin --delete feature/<slug> 2>/dev/null || true
git fetch --prune
git pull --ff-only origin main
```

`git pull` only when the primary tree is clean and on `main`. If it is
dirty or diverged, stop and report. Do not reset, stash, or discard those
changes.

### 8. Deploy Cloud Functions (always)

```bash
.cursor/skills/make-change/scripts/deploy-functions.sh
```

The script deploys `origin/main` from `.worktrees/deploy-<pid>` and removes
that worktree. It needs Node 22 and one of `FIREBASE_SERVICE_ACCOUNT`,
`GOOGLE_APPLICATION_CREDENTIALS`, or `FIREBASE_TOKEN`.

If none of those are set, skip the local script and report that production
depends on `.github/workflows/deploy-functions.yml`. Do not run
`firebase login`. If the local deploy fails, report the error.

### 9. Refresh simulators

If a simulator is already running, follow
[simulator-refresh](../simulator-refresh/SKILL.md). If none is booted, skip.
Do not block the change on a missing simulator.

## Report

One short block: worktree path, branch, PR URL, merge status, functions
deploy result, simulator action.
