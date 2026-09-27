---
name: make-change
description: >-
  Implement a bug fix or feature in a .worktrees worktree directly in this session,
  then commit, PR, merge, deploy Cloud Functions, and refresh simulators.
  Use when the user asks for a code change. Never edit ~/live-poker-trainer.
---

# Make a change

The primary checkout `~/live-poker-trainer` stays untouched. 

CRITICAL: Do NOT spawn or launch background subagents. Execute all steps sequentially in the current agent session.

```
Change progress:
- [ ] 1. Worktree off origin/main and push remote ref
- [ ] 2. Implement, verify, validate
- [ ] 3. Logical commits
- [ ] 4. Review the diff
- [ ] 5. Tests cover the change
- [ ] 6. Push, open PR, merge to main
- [ ] 7. Delete branch and worktree; sync primary
- [ ] 8. Deploy Cloud Functions
- [ ] 9. Refresh simulators if any are running
```

Work only inside the worktree directory `.worktrees/<slug>`. Do not edit the primary checkout.

### 1. Worktree off origin/main

From `~/live-poker-trainer`:

Determine the branch name: `feature/<slug>` or `fix/<slug>`. `<slug>` must be kebab-case (or Jira issue key like `feature/PROJ-123`).

Clean up any stale references, create the worktree, and immediately push an empty commit to `origin` so Cursor's internal branch monitors do not throw ref errors:

```bash
BRANCH="feature/<slug>"  # or fix/<slug>
SLUG="<slug>"
WT="$HOME/live-poker-trainer/.worktrees/$SLUG"

git fetch origin main
git worktree prune
git branch -D "$BRANCH" 2>/dev/null || true
git push origin --delete "$BRANCH" 2>/dev/null || true

git worktree add -b "$BRANCH" ".worktrees/$SLUG" origin/main

# Immediately push upstream ref to avoid Cursor agent-root fetch errors
cd "$WT"
git commit --allow-empty -m "chore: start $BRANCH"
git push -u origin "$BRANCH"
cd ~/live-poker-trainer
```

Copy untracked Firebase config files into the worktree:

```bash
[ -f lib/firebase_options.dart ] && cp lib/firebase_options.dart "$WT/lib/"
[ -f ios/Runner/GoogleService-Info.plist ] && cp ios/Runner/GoogleService-Info.plist "$WT/ios/Runner/"
[ -f android/app/google-services.json ] && cp android/app/google-services.json "$WT/android/app/"
```

### 2. Implement, verify, validate

Keep the diff scoped to the request. Run targeted checks (`dart analyze`, relevant tests). Note: If `flutter pub get` encounters a lock conflict from another process, wait 5 seconds and retry.

Simulator validation must show the worktree, not `origin/main`. Do not call `simulator-refresh` until after the merge.

Use only the agent iPhone 17 Pro (`F1AE4938-D9BE-4EA1-8C98-58555A0DE62A`). Leave the user iPhone 17 (`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`) alone.

Hot restart (`kill -USR2`) reloads the directory that `flutter run` was started from. Once the Pro session **is** that worktree, every later validation is a hot restart:

```bash
PID_FILE="/tmp/flutter-$SLUG.pid"
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  kill -USR2 "$(cat "$PID_FILE")"
fi
```

If no session exists for this worktree, boot the simulator and launch Flutter in a slug-scoped tmux session:

```bash
PRO=F1AE4938-D9BE-4EA1-8C98-58555A0DE62A
SESSION="flutter-pro-$SLUG"
PID_FILE="/tmp/flutter-$SLUG.pid"
LOG_FILE="/tmp/flutter-$SLUG.log"

open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app
xcrun simctl bootstatus "$PRO" -b || xcrun simctl boot "$PRO"

tmux kill-session -t "$SESSION" 2>/dev/null || true
tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "cd '$WT' && flutter run -d $PRO --pid-file '$PID_FILE' 2>&1 | tee '$LOG_FILE'; echo EXIT:\$?" Enter
```

Wait for `Dart VM Service on iPhone 17 Pro` in `$LOG_FILE`. Any verification screenshots belong in `$WT/.cursor/tmp/` and must be deleted after inspection.

### 3. Logical commits

All git operations in this step must run from within the worktree directory: `cd "$WT"`.

Commit on the feature branch only. Separate commits by logical change. Why-focused messages. Never commit on `main`. Never stage secrets (`.env*`, `*.pem`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart`).

### 4. Review the diff

Inside `$WT`, run `git diff origin/main...HEAD`. Fix correctness, regressions, secrets, and scope creep before opening the PR.

### 5. Tests

Add or update tests covering the change. Do not merge without them.

### 6. Push, PR, merge

Inside `$WT`:

```bash
git push origin HEAD
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

Clean up the tmux session and log artifacts, force-remove the worktree (to bypass untracked Firebase/build artifacts), force-delete the local branch, and sync `~/live-poker-trainer`:

```bash
cd ~/live-poker-trainer

tmux kill-session -t "flutter-pro-$SLUG" 2>/dev/null || true
rm -f "/tmp/flutter-$SLUG.pid" "/tmp/flutter-$SLUG.log"

git worktree remove --force ".worktrees/$SLUG"
git branch -D "$BRANCH" 2>/dev/null || true
git fetch --prune
git pull --ff-only origin main
```

`git pull` only when the primary tree is clean and on `main`. If it is dirty or diverged, stop and report. Do not reset, stash, or discard those changes.

### 8. Deploy Cloud Functions (always)

```bash
.cursor/skills/make-change/scripts/deploy-functions.sh
```

The script deploys `origin/main` from `.worktrees/deploy-<pid>` and removes that worktree. It needs Node 22 and one of `FIREBASE_SERVICE_ACCOUNT`, `GOOGLE_APPLICATION_CREDENTIALS`, or `FIREBASE_TOKEN`.

If none of those are set, skip the local script and report that production depends on `.github/workflows/deploy-functions.yml`. Do not run `firebase login`. If the local deploy fails, report the error.

### 9. Refresh simulators

If a simulator is already running, follow [simulator-refresh](../simulator-refresh/SKILL.md). If none is booted, skip. Do not block the change on a missing simulator.

## Report

One short block: worktree path, branch, PR URL, merge status, functions deploy result, simulator action.
