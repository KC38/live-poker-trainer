---
name: new-user-qa
description: >-
  Walk the live iOS simulator as a brand-new guest, find logic bugs, UI bugs,
  and UI improvements, and file or reopen detailed Jira tickets with
  screenshots and validation steps. Use when the user runs /new-user-qa or
  asks to walk the app as a new user and file Jira tickets.
disable-model-invocation: true
---

# New-user QA

Slash command. File tickets. Do not change product code and do not follow
[make-change](../make-change/SKILL.md). Shipping a filed ticket is
[/implement-open-jira](../implement-open-jira/SKILL.md).

Site: `https://livepokertrainer.atlassian.net`. Project: **LPT**.
Call `getAccessibleAtlassianResources` once and pass that `cloudId` on every
Jira call. Read each tool schema with `GetDynamicTools` before calling it.
`uploadAttachmentToJiraIssue`, `createJiraIssueLink`, and
`listJiraIssueTransitions` run through `executeWrite` / `executeRead`.

```
Walk progress:
- [ ] Latest origin/main on the agent iPhone 17 Pro, fresh install
- [ ] Guest path from Welcome through Home, Live Training, Profile, Settings
- [ ] Each finding matched against existing LPT issues
- [ ] Tickets created, updated, or reopened, with screenshots
- [ ] Blocks links for order and dependencies
- [ ] Scratch screenshots deleted
```

## 1. Fresh guest on the agent simulator

Read [launch-simulator](../launch-simulator/SKILL.md),
[simulator-refresh](../simulator-refresh/SKILL.md), and
[docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).

Drive only the agent iPhone 17 Pro
(`F1AE4938-D9BE-4EA1-8C98-58555A0DE62A`). Leave the user iPhone 17
(`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`) alone.

Run from the primary clone `~/live-poker-trainer` on latest `origin/main`.
`git fetch` and fast-forward only when that clone is on `main` and clean.
If it is dirty, on another branch, or will not fast-forward, stop and report.
Do not reset, stash, or use a feature worktree for the walk.

A hot restart keeps the current container. A new user needs an empty app:

1. Stop the Pro `flutter run` session (`flutter-pro-lessons`, pid file
   `/tmp/flutter-live-poker-trainer.pid`) when that session is this clone.
2. `xcrun simctl uninstall F1AE4938-D9BE-4EA1-8C98-58555A0DE62A com.pokerlab.livePokerTrainer`
3. Boot the Pro if needed and start `flutter run` from the primary clone in
   tmux, using the launch-simulator recipe (same pid file and log path).

Wait until the log shows a Dart VM service on iPhone 17 Pro. Record the
`origin/main` SHA.

`signout` is not a new user. Do not sign into an existing account. Do not
submit create-account.

## 2. Walk

Read `lib/ui/screens/onboarding_screens.dart` and `lib/routing/app_root.dart`
so labels match this build. Drive the UI with `python3 tools/agent_tap.py`.
Prefer exact visible labels. A broad needle such as `Continue` can hit a
control under the current route.

Path:

1. Welcome — **Get started**.
2. Experience — pick one band and record which.
3. Daily goal — pick one and record which.
4. Rex intro — **Continue**.
5. Recommended start — take the recommended lesson. Note **Start from the beginning instead** without a second full walk unless the first path is blocked.
6. Play that first lesson to the end. Check grading, coach copy, layout, and poker logic on each step.
7. Save-progress — open **Create an account to save your progress**, inspect, dismiss. Do not submit. Then **Continue learning**.
8. Home, Live Training, Profile, and Settings (gear). Scroll each. Tap the obvious primary actions a new guest would try.

If course flags send a signed-out guest straight to sign-in, that can be the
current rollout (`guestCourseEnabled`). Read the Course rollout section in
`README.md` before filing it. Still inspect every screen you can reach
without credentials.

On each screen look for wrong behavior, dead ends, clipped or overflowing UI,
unnamed controls, inconsistent state, and copy a new player would misunderstand.
Skip taste-only nits and anything you did not see.

Screenshot before leaving a broken or improvable screen:

```bash
xcrun simctl io F1AE4938-D9BE-4EA1-8C98-58555A0DE62A screenshot .cursor/tmp/<nn>-<slug>.png
```

Scratch files stay in `.cursor/tmp/`. Delete them after they are attached.

## 3. Match existing issues before creating one

Search more than once, with different phrases:

```
project = LPT AND text ~ "distinctive phrase" ORDER BY updated DESC
```

Open each candidate with `getJiraIssue` (`view: evidence`).

- Same defect, not Done: do not create another issue. Comment with this
  walk's steps, SHA, and new screenshots. Edit the description only when
  the steps or expected result are now wrong.
- Same defect, Done (or any done-category status), and it still reproduces:
  reopen it. `listJiraIssueTransitions`, then `transitionJiraIssue` to
  **To Do** (prefer a transition named Reopen or To Do). Edit the
  description to the current repro. Comment that it was closed and this
  walk still shows it, and what changed since the old writeup. Attach new
  screenshots.
- Closed, and the old problem is gone: leave it closed.
- No match: create one issue.

## 4. Ticket body

Match tickets already in LPT (see LPT-12).

- **Bug** — behavior is wrong.
- **Story** — the UI works, and a new user would still be blocked, misled, or unclear.
- Labels: `new-user`, `ios`, and one area label (`onboarding`, `lesson`, `home`, `live-training`, `profile`, `account`).
- Priority: **Highest** if the guest cannot finish the first lesson or reach Home. **High** if a primary action is missing or wrong. **Medium** for a clear improvement. **Low** for polish.

```markdown
## What happened

<what the screen did, in concrete UI text>

## Steps

1. Fresh guest on the agent iPhone 17 Pro.
2. <exact taps>

## Expected

<what should happen>

## Screenshots

Attached: <filenames and what each shows>.

## Validate before closing

1. <observable check on a fresh guest>
2. <state that must remain true on the next screen>

Device: iPhone 17 Pro simulator, debug build on main, <date>, `<sha>`.
```

`createJiraIssue` with `contentFormat: markdown`. Then attach each screenshot
with `uploadAttachmentToJiraIssue`: phase 1 returns an `uploadCommand` to run
in the shell; phase 2 passes the `fileId`. Put the same shots on the reopen
comment when you did not create a new issue.

## 5. Order and blockers

After every finding from this walk has a key, link them.

`createJiraIssueLink` with `linkType: "Blocks"`: **inwardIssue blocks
outwardIssue**. The inward issue is the one that must land first.

Use **Blocks** when:

- one fix has to land before the other can be validated, or
- the guest hits them in an order that makes the later fix meaningless until the earlier one is done.

Use **Relates** when two findings share a screen and can ship independently.

Name the blocker key in the blocked issue's description, and why it is first.
Do not link an issue to itself. Do not use a parent or epic as a stand-in
for a block.

## 6. Report

Delete every file you added under `.cursor/tmp/`.

Reply with the SHA you walked, then one line per issue: key, created /
reopened / commented, summary. Then the block order (`LPT-a blocks LPT-b`).
Include screens you could not reach.
