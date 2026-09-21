---
name: ship-change
description: >-
  Ship bug fixes and features via a feature branch, review, PR merge to main,
  Cloud Functions deploy, branch cleanup, and Flutter simulator refresh. Use
  when implementing a bug fix or new feature, or when the user asks to ship,
  open a PR, merge, or /ship-change.
---

# Ship change (branch → review → merge → refresh)

Default delivery path for **bug fixes** and **new features** in this repo.
Do **not** commit straight to `main`.

Live remote: `origin` → https://github.com/KC38/live-poker-trainer (`main`).

## Checklist

```
Ship progress:
- [ ] 1. Branch from up-to-date main
- [ ] 2. Implement + verify
- [ ] 3. Commit on the feature branch
- [ ] 4. Review the diff
- [ ] 5. Push, open PR, merge to main
- [ ] 6. Delete remote/local feature branch; sync main
- [ ] 7. Deploy Cloud Functions from merged main (always)
- [ ] 8. Refresh **all** Flutter simulators (if running / available)
```

## 1. Branch

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b <type>/<short-slug>
```

- `type`: `fix` | `feat` | `refactor` | `chore` | `test` | `docs`
- `short-slug`: kebab-case, ≤40 chars (e.g. `fix/sign-out-nav-stack`)
- If already on a suitable feature branch with related work, keep it.
- Call `SetActiveBranch` with the new branch name after creating it.
- If `main` has local uncommitted work unrelated to this task, stop and ask.

## 2. Implement

- Keep the diff scoped to the requested change.
- Run targeted checks when practical (`dart analyze`, relevant tests).
- Do not leave the tree in a broken/unrunnable state before shipping.

## 3. Commit (feature branch only)

1. `git status` / `git diff` / `git log -5 --oneline` for style.
2. Stage only intentional project files. **Never** stage secrets:
   - `.env*`
   - `*.pem`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart`
3. Commit with a concise why-focused message (HEREDOC). Follow repo style.
4. Never commit directly on `main` for this workflow.

## 4. Review

Before opening/merging the PR:

1. Read `git diff origin/main...HEAD` (and unstaged if any).
2. Self-review for correctness, regressions, secrets, and scope creep.
3. If the user asked for Bugbot / security review, run that skill once and fix **critical** findings before merge.
4. Do not merge with known critical bugs from the review.

## 5. Push, PR, merge

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

- Prefer squash merge + `--delete-branch` (deletes remote feature branch).
- Wait for required checks if they exist and are still running; if a required check fails, fix on the branch and re-push—do not force-merge.
- Never `git push --force` to `main`.
- If `gh` auth/permissions fail, report the error and stop.

## 6. Cleanup and sync local main

```bash
git checkout main
git pull --ff-only origin main
git branch -d <feature-branch> 2>/dev/null || true
git fetch --prune
```

Confirm with `git status -sb` (should be `main` clean, in sync with `origin/main`).

## 7. Deploy Cloud Functions (always)

After merge, Functions should match `origin/main`.

GitHub Actions (`.github/workflows/deploy-functions.yml`, sourced from
`docs/github-actions/deploy-functions.yml`) deploys on pushes to `main`
that change `functions/`, using repository secrets
`FIREBASE_SERVICE_ACCOUNT` (preferred) or `FIREBASE_TOKEN` (`login:ci`).
If that workflow ran for the merge, wait for it rather than an interactive
`firebase login`.

If `FIREBASE_SERVICE_ACCOUNT`, `GOOGLE_APPLICATION_CREDENTIALS`, or
`FIREBASE_TOKEN` is already in this environment, also run:

```bash
.cursor/skills/ship-change/scripts/deploy-functions.sh
```

If none of those credentials are set, skip the local script and report that
production depends on the main-branch workflow (and on the GitHub secret
being present). Do not run `firebase login` in a headless agent.

Notes:

- The local script deploys from a disposable worktree on `origin/main`.
- Requires Node 22 (`brew` `node@22` on PATH when present).
- Uses `firebase-tools@15.30.2` (older CLI fails analyzing `jose` ESM).
- If a local deploy fails, report the error — do not claim the ship is live.

## 8. Flutter simulator refresh (all sims)

After merge to `main`, **always** refresh **every** running iOS simulator
`flutter run` — not just one:

```bash
.cursor/skills/ship-change/scripts/refresh-simulator.sh
```

Or follow [simulator-refresh.md](simulator-refresh.md).

- Hot **restart** (`USR2` / `R`) each attached sim session so apps pick up
  merged code.
- If a simulator is booted but no session is running, start `flutter run` on
  that device in the background (script starts one fallback device).
- If no device/simulator is available, skip and say so—do not block the ship.

## Hard limits

- No force-push to `main`.
- No amend of commits already on `origin/main`.
- No `git config` changes, no `--no-verify`, no history rewrite.
- No staging of secret/config files listed above.
- Trivial WIP / rejected experiments: do not ship.

## Report back

One short block: branch name, PR URL, merge status, functions deploy result,
whether simulators were restarted/started/skipped (list each if multiple).
