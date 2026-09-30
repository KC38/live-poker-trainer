---
name: make-change
description: >-
  Implement a bug fix or feature in a .worktrees worktree directly in this session,
  then commit, PR, merge, sync the primary checkout, hot-restart the simulator,
  and deploy Cloud Functions. Use when the user asks for a code change. Never
  edit the primary checkout.
---

# Make a change

The primary checkout stays untouched while you implement. Resolve it once per
run (machines differ — `~/live-poker-trainer` or `~/live_poker_trainer`):

```bash
PRIMARY="$(tools/primary_checkout.sh)"
```

Do not hardcode either home path. `PRIMARY=...` still overrides when set.

CRITICAL: Do NOT spawn background subagents. Execute all steps sequentially in the current agent session.

```
Change progress:
- [ ] 1. Worktree off origin/main with tracking branch
- [ ] 2. Implement and verify
- [ ] 3. Logical commits
- [ ] 4. Review the diff
- [ ] 5. Tests cover the change
- [ ] 6. Push, open PR, squash merge (keep remote branch alive)
- [ ] 7. Dismantle worktree, sync primary main, delete branches
- [ ] 8. Deploy Cloud Functions
- [ ] 9. Refresh the iPhone 13 mini (only after a successful primary pull)
```

Work only inside the worktree directory `.worktrees/<slug>`. Do not edit the primary checkout.

### 1. Worktree off origin/main

From the primary checkout:

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
PRIMARY="$(tools/primary_checkout.sh)"
WT="$PRIMARY/.worktrees/$SLUG"

cd "$PRIMARY"
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
cd "$PRIMARY"
```

Copy untracked Firebase config files into the worktree:

```bash
[ -f lib/firebase_options.dart ] && cp lib/firebase_options.dart "$WT/lib/"
[ -f ios/Runner/GoogleService-Info.plist ] && cp ios/Runner/GoogleService-Info.plist "$WT/ios/Runner/"
[ -f android/app/google-services.json ] && cp android/app/google-services.json "$WT/android/app/"
```

### 2. Implement and verify

Keep the diff scoped to the request. Run targeted checks (`dart analyze`, relevant tests). Note: If `flutter pub get` encounters a lock conflict from another process, wait 5 seconds and retry.

Do not boot simulators, take screenshots, drive the UI, or call `simulator-refresh` during implement/verify. Verification in this step is analyze and tests only. Simulator refresh happens only in step 9, after a successful primary pull.

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

Return to the primary checkout, force-remove the ticket worktree, sync
`origin/main`, and only then delete the remote and local branches:

```bash
PRIMARY="$(tools/primary_checkout.sh)"
cd "$PRIMARY"

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

`git pull` only when the primary tree is clean and on `main`.

#### When the primary pull fails

If primary is dirty, diverged, or not on `main`, **stop the sync** and
report `git status -sb` (and behind/ahead counts). Do **not** reset, stash,
or discard those changes. Still finish worktree/branch cleanup above when
safe.

Then:

- Skip step 9 (`simulator-refresh`). Refresh itself requires a clean
  primary on `main`, and the mini would still be on the pre-merge
  checkout.
- Continue step 8 (functions deploy) when credentials allow — deploy uses
  a detached worktree of `origin/main`, not the dirty primary tree.
- In the report: primary is **not** at tip, the simulator was **not**
  refreshed, and the user must clean or keep the local dirt before a
  later pull + refresh can land the merge on disk and on the mini.

Ask before discarding local dirt. Never discard it on your own.

### 8. Deploy Cloud Functions (always)

```bash
.cursor/skills/make-change/scripts/deploy-functions.sh
```

The script deploys `origin/main` from `.worktrees/deploy-<pid>` and removes that worktree. It needs Node 22 and one of `FIREBASE_SERVICE_ACCOUNT`, `GOOGLE_APPLICATION_CREDENTIALS`, or `FIREBASE_TOKEN`.

If none of those are set, skip the local script and report that production depends on `.github/workflows/deploy-functions.yml`. Do not run `firebase login`. If the local deploy fails, report the error.

### 9. Refresh the iPhone 13 mini (successful primary pull only)

Only after step 7's `git pull --ff-only origin main` succeeded:

```bash
.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh
```

That hot-restarts an existing primary `flutter run` on the iPhone 13 mini
when one is attached, or starts one from the primary checkout when none is.
Skip this step when the primary pull failed (see above). If the mini cannot
boot, skip and report — do not fail the ship.

Do not drive the UI or take screenshots as part of this skill.

## Report

One short block: worktree path, branch, PR URL, merge status, primary sync
result (pulled SHA or dirty/skipped), simulator refresh result, functions
deploy result.
