---
name: new-user-qa
description: >-
  Charter one uncovered iOS path on the agent simulator, file or update LPT
  tickets with screenshots, and record the path so the next run does not
  repeat it. Use when the user runs /new-user-qa or asks for a new-user,
  guest, or exploratory QA walk of the app.
disable-model-invocation: true
---

# New-user QA

Slash command. One chartered path per run. File tickets. Do not change
product code and do not follow [make-change](../make-change/SKILL.md).
Shipping a filed ticket is
[/implement-open-jira](../implement-open-jira/SKILL.md).

The journeys are [paths.md](paths.md). Coverage lives outside the git tree
so the primary clone stays clean. A fresh install is the precondition of
some paths. It is not the default once those paths are covered.

Site: `https://livepokertrainer.atlassian.net`. Project: **LPT**.
Call `getAccessibleAtlassianResources` once and pass that `cloudId` on every
Jira call. Read each tool schema with `GetDynamicTools` before calling it.
`uploadAttachmentToJiraIssue`, `createJiraIssueLink`, and
`listJiraIssueTransitions` run through `executeWrite` / `executeRead`.

```
Session progress:
- [ ] origin/main SHA recorded; primary clone clean on main
- [ ] Coverage read; one due path chosen
- [ ] That path's precondition met
- [ ] Path chartered against the product, not taste
- [ ] Findings matched to existing LPT issues
- [ ] Tickets created, updated, or reopened, with screenshots
- [ ] Blocks links for order and dependencies
- [ ] Coverage row appended
- [ ] Scratch screenshots deleted
```

## 1. Pick the path

Read [paths.md](paths.md) and the coverage log (section 7).

A path is **covered** when its latest row has result `clean` or `findings`.
`skipped` and `blocked` are not coverage.

A covered path is **due again** when `git diff --name-only <row.sha> origin/main`
touches any of its `watch` prefixes, or when `<row.sha>` is not an ancestor
of `origin/main`. An unknown SHA counts as due.

Choose exactly one path:

1. The user named a path id, or said to walk as a new user / fresh guest:
   walk that path. Set `repeat` when it was already covered.
2. Otherwise the due path in the earliest phase, then the lowest `order`,
   among paths whose precondition you can meet this session.
   Phases: `bootstrap`, `guest-home`, `fresh-variant`, `destructive`.
3. Nothing due: stop. Report the SHA and one line per path (last result,
   last SHA). Do not walk a covered path to have something to do.

`live-training-one-hand` needs an account the user gave you in this session.
Without one it is not a candidate. Say so in the report. Do not append a row
for it until you walk it or confirm the product still locks it.

After `fresh-guest-recommended` is covered, and the simulator has a guest on
Home, do not pick `fresh-variant` or `destructive` while any `guest-home`
path is still a candidate. Finish the guest you already have.

`sign-out-discards-guest` is the only `destructive` path. Do not pick it
while any earlier path is still a candidate.

Do not take a branch that belongs to a different path. See the path you
picked for the branch it owns.

## 2. Build and persona

Read [launch-simulator](../launch-simulator/SKILL.md),
[simulator-refresh](../simulator-refresh/SKILL.md), and
[docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).

Drive only the iPhone 17 Pro
(`F1AE4938-D9BE-4EA1-8C98-58555A0DE62A`). That device is this skill.

The iPhone 17 (`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`) belongs to
[implement-open-jira](../implement-open-jira/SKILL.md). Do not boot, uninstall,
terminate, kill, hot-restart, screenshot, or tap it. A booted iPhone 17 is
not a reason to skip this path.

Run from the primary clone `~/live-poker-trainer` on latest `origin/main`.
`git fetch` and fast-forward only when that clone is on `main` and clean.
If it is dirty, on another branch, or will not fast-forward, stop and report.
Do not reset, stash, or use a feature worktree for the walk.

Record the `origin/main` SHA.

Read `lib/ui/screens/onboarding_screens.dart`, `lib/routing/app_root.dart`,
and the screens this path names so labels match this build. Drive the UI
with `python3 tools/agent_tap.py` and no `--log` flag. That default reads
`/tmp/flutter-live-poker-trainer.run.log` (this Pro). Do not pass the
iPhone 17 log. Prefer exact visible labels. A broad needle such as
`Continue` can hit a control under the current route.

**`fresh-install`.** A hot restart keeps the container. Uninstall, then
boot:

1. Stop only the Pro `flutter run` session (`flutter-pro-lessons`, pid file
   `/tmp/flutter-live-poker-trainer.pid`) when that session is this clone.
   Do not stop `flutter-iphone17-*` or any `flutter run -d 20ACECD5-…`.
2. `xcrun simctl uninstall F1AE4938-D9BE-4EA1-8C98-58555A0DE62A com.pokerlab.livePokerTrainer`
3. Boot the Pro if needed and start `flutter run` from the primary clone in
   tmux, using the launch-simulator recipe (same pid file and log path).

Wait until the log shows a Dart VM service on iPhone 17 Pro.

**`guest-home`.** Do not uninstall. The app must open on Home as a guest.
If `flutter run` is already this clone on the Pro and that Home is showing,
keep the process. Hot-restart only the Pro pid
(`/tmp/flutter-live-poker-trainer.pid`) when that build is behind
`origin/main`. Do not signal the iPhone 17 pid.

If the container is not a guest on Home:

- `fresh-guest-recommended` still due: walk that path instead.
- It is covered, and the container was wiped: replay the experience label
  and daily-goal minutes from that path's last row as **setup**. Setup gets
  the guest to Home. Do not charter those screens again and do not add a
  coverage row for them.

**Signed-in.** `live-training-one-hand` is the only path that needs an
account, and only an account the user gave you in this session. Do not
create an account. Do not sign into an account you were not given.
`signout` is not a new user.

If course flags send a signed-out guest straight to sign-in, that can be
the current rollout (`guestCourseEnabled`). Read the Course rollout section
in `README.md` before filing it. Still inspect every screen you can reach
without credentials. A path you cannot start because of that gate is
`blocked`, not a new defect, when the README describes the gate.

## 3. Charter

On each screen of the chosen path, before leaving it:

1. **Finish the step** the screen is for, or record the control that stopped you.
2. **State** you just set is still true on the next screen: experience, goal,
   lesson title, activity index, XP, streak, accuracy, chip format, lock copy.
3. **Recovery** the path asks for (back, force-quit, relaunch) matches the
   product. Guest copy says progress stays on this device until an account
   exists, and can be lost if the session is cleared.
4. **Copy** matches the code and README you read. Course stats and Live
   Training stats stay separate. A paused start, an anonymous Live Training
   block, or a locked mode must not deal a hand anyway.
5. **Layout** on this phone: clipped text, overflow, overlapping controls,
   a control with no name.
6. **Poker**, only on a lesson or hand step: the grade, the coach line, and
   the chip math refer to this choice and the amounts on screen. File a
   contradiction you can point at.

Skip taste-only nits and anything you did not see.

Retry open LPT issues whose steps sit on this path. Comment with this SHA
whether they still reproduce.

Screenshot before leaving a broken or misleading screen:

```bash
xcrun simctl io F1AE4938-D9BE-4EA1-8C98-58555A0DE62A screenshot .cursor/tmp/<nn>-<slug>.png
```

Scratch files stay in `.cursor/tmp/`. Delete them after they are attached.

## 4. Match existing issues before creating one

Search more than once, with different phrases:

```
project = LPT AND text ~ "distinctive phrase" ORDER BY updated DESC
```

Open each candidate with `getJiraIssue` (`view: evidence`).

- Same defect, not Done: do not create another issue. Comment with this
  walk's path id, steps, SHA, and new screenshots. Edit the description
  only when the steps or expected result are now wrong.
- Same defect, Done (or any done-category status), and it still reproduces:
  reopen it. `listJiraIssueTransitions`, then `transitionJiraIssue` to
  **To Do** (prefer a transition named Reopen or To Do). Edit the
  description to the current repro. Comment that it was closed and this
  walk still shows it, and what changed since the old writeup. Attach new
  screenshots.
- Closed, and the old problem is gone: leave it closed.
- No match: create one issue.

## 5. Ticket body

Match tickets already in LPT (see LPT-12).

- **Bug** — behavior is wrong.
- **Story** — the UI works, and a player on this path would still be
  blocked, misled, or unclear.
- Labels: `new-user`, `ios`, and one area label (`onboarding`, `lesson`,
  `home`, `live-training`, `profile`, `account`).
- Priority: **Highest** if this path's goal cannot be finished. **High** if
  a primary action is missing or wrong. **Medium** for a clear improvement.
  **Low** for polish.

```markdown
## What happened

<what the screen did, in concrete UI text>

## Steps

1. <path id> on the agent iPhone 17 Pro (<precondition>).
2. <exact taps>

## Expected

<what the product should do, from the screen or README you read>

## Screenshots

Attached: <filenames and what each shows>.

## Validate before closing

1. <observable check on this path>
2. <state that must remain true on the next screen>

Device: iPhone 17 Pro simulator, debug build on main, <date>, `<sha>`.
```

`createJiraIssue` with `contentFormat: markdown`. Then attach each screenshot
with `uploadAttachmentToJiraIssue`: phase 1 returns an `uploadCommand` to run
in the shell; phase 2 passes the `fileId`. Put the same shots on the reopen
comment when you did not create a new issue.

## 6. Order and blockers

After every finding from this walk has a key, link them.

`createJiraIssueLink` with `linkType: "Blocks"`: **inwardIssue blocks
outwardIssue**. The inward issue is the one that must land first.

Use **Blocks** when:

- one fix has to land before the other can be validated, or
- the player hits them in an order that makes the later fix meaningless
  until the earlier one is done.

Use **Relates** when two findings share a screen and can ship independently.

Name the blocker key in the blocked issue's description, and why it is first.
Do not link an issue to itself. Do not use a parent or epic as a stand-in
for a block.

## 7. Coverage

Log path: `<User's personal store>/live-poker-trainer/new-user-qa/coverage.json`.
The store path is in the session context under Available persistent agent
stores. Use the personal store, not the current conversation's store.

Create the file when it is missing:

```json
{ "version": 1, "walks": [] }
```

Append one object after tickets for this session exist. Rewrite the file.
If it changed while you were walking, re-read and append again. Do not
commit it. Do not write it into the git working tree.

```json
{
  "path": "home-continue",
  "sha": "<origin/main full sha>",
  "date": "YYYY-MM-DD",
  "result": "clean",
  "issues": [],
  "repeat": false,
  "notes": "Experience and goal if this path set them. Lesson title. What blocked or why skipped."
}
```

`result` is `clean`, `findings`, `blocked`, or `skipped`.
`issues` lists keys created, commented, or reopened.
`blocked`: name the screen where the path stopped.
`skipped`: you reached the path and the product still will not let you
finish it (Live Training locked for the account you were given). The path
stays due. A missing account is not a row.

A sweep (the user asked to walk every due path) still charters each path
separately, appends one row each, and stops when a Highest defect blocks
the next path's precondition.

## 8. Report

Delete every file you added under `.cursor/tmp/`.

Reply with the SHA, the path id, and the result. Then one line per issue:
key, created / reopened / commented, summary. Then the block order
(`LPT-a blocks LPT-b`). Then the next due path, or that coverage is current.
Name any path still waiting on an account. Include screens you could not reach.
