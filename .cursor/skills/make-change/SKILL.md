---
name: make-change
description: >-
  Implement a bug fix or feature in a .worktrees worktree directly in this session,
  then commit, PR, merge, deploy Cloud Functions, and refresh simulators.
  Use when the user asks for a code change. Never edit ~/live-poker-trainer.
---

# Make a change

The primary checkout `~/live-poker-trainer` stays untouched. 

CRITICAL: Do NOT spawn background subagents. Execute all steps sequentially in the current agent session.

```
Change progress:
- [ ] 1. Worktree off origin/main with tracking branch
- [ ] 2. Implement, verify, validate
- [ ] 3. Logical commits
- [ ] 4. Review the diff
- [ ] 5. Tests cover the change
- [ ] 6. Push, open PR, squash merge (keep remote branch alive)
- [ ] 7. Dismantle worktree, sync primary main, delete branches
- [ ] 8. Deploy Cloud Functions
- [ ] 9. Refresh simulators if any are running
```

Work only inside the worktree directory `.worktrees/<slug>`. Do not edit the primary checkout.

### 1. Worktree off origin/main

From `~/live-poker-trainer`:

Determine the branch name: `feature/<slug>` or `fix/<slug>`. `<slug>` is kebab-case.

When the change is a Jira ticket, `<slug>` is the issue key plus a short kebab summary, and the prefix matches the issue type (Bug → `fix`, Story or Task → `feature`):

```
SLUG="LPT-12-action-dock-clips"
BRANCH="fix/$SLUG"
```

The worktree is `.worktrees/LPT-12-action-dock-clips`. Keep the issue key in both names. Do not name the branch from the summary alone.

Otherwise `<slug>` is a short kebab description of the change.

Ensure the primary checkout is cleanly on `main`, clean up any stale worktree/branch refs, create the worktree, and immediately push an empty commit so Cursor's internal workspace monitors do not fail:

```bash
BRANCH="feature/<slug>"  # or fix/<slug>
SLUG="<slug>"
WT="$HOME/live-poker-trainer/.worktrees/$SLUG"

cd ~/live-poker-trainer
git checkout main 2>/dev/null || true
git fetch origin main
git worktree prune
git branch -D "$BRANCH" 2>/dev/null || true
git push origin --delete "$BRANCH" 2>/dev/null || true

git worktree add -b "$BRANCH" ".worktrees/$SLUG" origin/main

# Immediately push upstream ref so remote ref checks pass
cd "$WT"
git commit --allow-empty -m "chore: initialize $BRANCH"
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

Simulator validation must show the worktree, not `origin/main`. Do not call `simulator-refresh` until after step 7.

Validate on the iPhone 17 (`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`). That device is [implement-open-jira](../implement-open-jira/SKILL.md).

The iPhone 17 Pro (`F1AE4938-D9BE-4EA1-8C98-58555A0DE62A`) belongs to [new-user-qa](../new-user-qa/SKILL.md). Do not boot, uninstall, terminate, kill, hot-restart, screenshot, or tap it. Do not stop `flutter-pro-lessons`.

The iPhone 17 Pro Max (`7CB7DDCF-CBEA-414F-8A92-D490C7AAE35F`) belongs to [ui-consistency-qa](../ui-consistency-qa/SKILL.md). Do not boot, uninstall, terminate, kill, hot-restart, screenshot, or tap it. Do not stop `flutter-ui-pro-max`.

Drive the UI with `python3 tools/agent_tap.py --log "$LOG_FILE"`. The default log is the Pro session.

Hot restart (`kill -USR2`) reloads the directory that `flutter run` was started from. Once the iPhone 17 session **is** that worktree, every later validation is a hot restart:

```bash
PID_FILE="/tmp/flutter-$SLUG.pid"
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  kill -USR2 "$(cat "$PID_FILE")"
fi
```

If no session exists for this worktree, stop any flutter run already attached to the iPhone 17, then boot that simulator and launch Flutter in a slug-scoped tmux session. Leave any `flutter run -d F1AE4938-…` running.

```bash
DEVICE=20ACECD5-FBEE-4663-9044-E11D5F0A26FC
SESSION="flutter-iphone17-$SLUG"
PID_FILE="/tmp/flutter-$SLUG.pid"
LOG_FILE="/tmp/flutter-$SLUG.log"

while IFS= read -r pid; do
  [[ -z "$pid" ]] && continue
  kill "$pid" 2>/dev/null || true
done < <(pgrep -f "flutter_tools\\.snapshot run -d ${DEVICE}" || true)

open -a /Applications/Xcode.app/Contents/Applications/DeviceHub.app
xcrun simctl bootstatus "$DEVICE" -b || xcrun simctl boot "$DEVICE"

tmux kill-session -t "$SESSION" 2>/dev/null || true
tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "cd '$WT' && flutter run -d $DEVICE --pid-file '$PID_FILE' 2>&1 | tee '$LOG_FILE'; echo EXIT:\$?" Enter
```

Wait for `Dart VM Service on iPhone 17 is` in `$LOG_FILE` (that line is the non-Pro phone). Screenshots:

```bash
xcrun simctl io "$DEVICE" screenshot "$WT/.cursor/tmp/<name>.png"
```

Delete them after inspection.

### 3. Logical commits

All git operations in this step must run from within the worktree directory: `cd "$WT"`.

Commit on the feature branch only. Separate commits by logical change. Why-focused messages. Never commit on `main`. Never stage secrets (`.env*`, `*.pem`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `lib/firebase_options.dart`).

### 4. Review the diff

Inside `$WT`, run `git diff origin/main...HEAD`. Fix correctness, regressions, secrets, and scope creep before opening the PR.

### 5. Tests

Add or update tests covering the change. Do not merge without them.

### 6. Push, PR, merge

Inside `$WT`. When this change is a Jira ticket, the PR title is `LPT-12: <summary>` so the squash commit on `main` keeps the key. Commit subjects include the key.

```bash
git push origin HEAD
gh pr create --title "<concise title>" --body "$(cat <<'EOF'
## Summary
- <what / why>

## Test plan
- [ ] <how to verify>
EOF
)"

# DO NOT use --delete-branch here. Deleting the remote ref before leaving
# the worktree causes Cursor's background ref fetcher to crash the session.
gh pr merge --squash
```

Never force-push `main`. If `gh` fails, stop and report.

### 7. Delete the branch and worktree, then sync primary

Stop the iPhone 17 ticket tmux session only. Do not kill `flutter-pro-lessons`. Pulling the primary clone does not restart the Pro. Return to `~/live-poker-trainer`, force-remove the ticket worktree, sync `origin/main`, and only then delete the remote and local branches. Leave `.worktrees/iphone17-main` in place:

```bash
cd ~/live-poker-trainer

tmux kill-session -t "flutter-iphone17-$SLUG" 2>/dev/null || true
rm -f "/tmp/flutter-$SLUG.pid" "/tmp/flutter-$SLUG.log"

# Force-remove worktree directory before deleting refs
git worktree remove --force ".worktrees/$SLUG"

# Verify primary is on main and sync latest commits
git checkout main
git fetch origin main
git pull --ff-only origin main

# Delete remote and local branches safely after exiting the worktree
git push origin --delete "$BRANCH" 2>/dev/null || true
git branch -D "$BRANCH" 2>/dev/null || true
git fetch --prune
```

`git pull` only when the primary tree is clean and on `main`. If it is dirty or diverged, stop and report. Do not reset, stash, or discard those changes.

### 8. Deploy Cloud Functions (always)

```bash
.cursor/skills/make-change/scripts/deploy-functions.sh
```

The script deploys `origin/main` from `.worktrees/deploy-<pid>` and removes that worktree. It needs Node 22 and one of `FIREBASE_SERVICE_ACCOUNT`, `GOOGLE_APPLICATION_CREDENTIALS`, or `FIREBASE_TOKEN`.

If none of those are set, skip the local script and report that production depends on `.github/workflows/deploy-functions.yml`. Do not run `firebase login`. If the local deploy fails, report the error.

### 9. Refresh simulators

Refresh the iPhone 17 only, from [simulator-refresh](../simulator-refresh/SKILL.md):

```bash
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh implement
```

That leaves the iPhone 17 Pro session alone. Do not pass `qa`. If the iPhone 17 cannot boot, skip. Do not block the change on a missing simulator.

## Report

One short block: worktree path, branch, PR URL, merge status, functions deploy result, simulator action.
