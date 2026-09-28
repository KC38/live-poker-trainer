---
name: ui-consistency-qa
description: >-
  Charter one iOS surface against the UI design record, file or update LPT
  tickets for visual inconsistencies, shared poker-table reuse, missing
  assets, and learning screens that are not a game loop, and record the
  path so the next run does not repeat it. Use when the user runs
  /ui-consistency-qa or asks for a UI consistency, visual polish, or
  design-system walk of the app.
disable-model-invocation: true
---

# UI consistency QA

Slash command. One chartered path per run. File tickets. Do not change
product code and do not follow [make-change](../make-change/SKILL.md).
Shipping a filed ticket is
[/implement-open-jira](../implement-open-jira/SKILL.md).

Before the first screen, read
[flutter-ui-ux](../flutter-ui-ux/SKILL.md),
[docs/ui/design-record.md](../../../docs/ui/design-record.md), and
[docs/ui/references/duolingo-chess/PATTERNS.md](../../../docs/ui/references/duolingo-chess/PATTERNS.md).
The Flutter skill is how a screen is built. The design record is what
this app has already decided. The Duolingo Chess frames are the teaching
loop to translate: one step, the table as the hero, a mascot beat on
right and wrong, then XP. Do not copy their green, their owl, or their
copy. When a sample in the Flutter skill disagrees with the record
(button radius, elevation, palette), the record wins. A finding that
needs a new color, control, table, or asset updates a named section of
the record. It does not start a second visual language.

The journeys are [paths.md](paths.md). Coverage lives outside the git tree
so the primary clone stays clean.

Site: `https://livepokertrainer.atlassian.net`. Project: **LPT**.
Call `getAccessibleAtlassianResources` once and pass that `cloudId` on every
Jira call. Read each tool schema with `GetDynamicTools` before calling it.
`uploadAttachmentToJiraIssue`, `createJiraIssueLink`, and
`listJiraIssueTransitions` run through `executeWrite` / `executeRead`.

```
Session progress:
- [ ] origin/main SHA recorded
- [ ] Flutter UI/UX skill, design record, and Duolingo Chess patterns read
- [ ] Coverage read; one due path chosen
- [ ] That path's precondition met on the Pro Max
- [ ] Path chartered against the design record
- [ ] Findings matched to existing LPT issues
- [ ] Tickets created, updated, or reopened, with screenshots and a design-record section
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

1. The user named a path id: walk that path. Set `repeat` when it was already covered.
2. Otherwise the due path in the earliest phase, then the lowest `order`,
   among paths whose precondition you can meet this session.
   Phases: `bootstrap`, `guest-home`, `table`.
3. Nothing due: stop. Report the SHA and one line per path (last result,
   last SHA). Do not walk a covered path to have something to do.

`live-table-reference` needs an account the user gave you in this session.
Without one it is not a candidate. Say so in the report. Do not append a
row until you walk it or the hub still blocks the hand (`skipped`).

After `onboarding-chrome` is covered, and the simulator has a guest on
Home, do not uninstall while any `guest-home` path is still a candidate.

Do not take a branch that belongs to a different path. See the path you
picked for the branch it owns. Do not sign out.

## 2. Build and persona

Read [docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).

Drive only the iPhone 17 Pro Max on iOS 26.5
(`7CB7DDCF-CBEA-414F-8A92-D490C7AAE35F`). That device is this skill.

The iPhone 17 Pro belongs to [new-user-qa](../new-user-qa/SKILL.md). The
iPhone 17 belongs to [implement-open-jira](../implement-open-jira/SKILL.md).
Do not boot, uninstall, terminate, kill, hot-restart, screenshot, or tap
either one. A booted Pro or iPhone 17 is not a reason to skip this path.

Run from `<primary>/.worktrees/ui-main`, a checkout of
`origin/main`. The primary clone is `~/live_poker_trainer` or
`~/live-poker-trainer`, whichever contains this repo. Create `ui-main`
when it is missing. Do not edit product code
there. Do not use a feature branch. `git fetch` and fast-forward that
worktree only. If it will not fast-forward, stop and report. Do not reset
or stash it, and do not touch the primary clone.

```bash
if [ -d "$HOME/live_poker_trainer/.git" ]; then
  PRIMARY="$HOME/live_poker_trainer"
elif [ -d "$HOME/live-poker-trainer/.git" ]; then
  PRIMARY="$HOME/live-poker-trainer"
else
  echo "primary clone not found" >&2
  exit 1
fi
WT="$PRIMARY/.worktrees/ui-main"
git -C "$PRIMARY" fetch origin main
git -C "$PRIMARY" worktree add "$WT" origin/main 2>/dev/null || git -C "$WT" merge --ff-only origin/main
```

Copy `lib/firebase_options.dart` and `ios/Runner/GoogleService-Info.plist`
from the primary clone when the worktree does not already have them.

Record the `origin/main` SHA.

Read the design record, then the screens this path names, so labels match
this build. Drive the UI with `python3 tools/agent_tap.py --log /tmp/flutter-live-poker-trainer-ui.run.log`.
Do not use the default log. That log is the Pro.

**`fresh-install`.** A hot restart keeps the container. Uninstall, then boot:

1. Stop only this skill's `flutter run` (`flutter-ui-pro-max`, pid file
   `/tmp/flutter-live-poker-trainer-ui.pid`) when that session is `ui-main`.
   Do not stop `flutter-pro-lessons` or any `flutter run` on the Pro or the
   iPhone 17.
2. `xcrun simctl uninstall 7CB7DDCF-CBEA-414F-8A92-D490C7AAE35F com.pokerlab.livePokerTrainer`
3. Boot the Pro Max if needed and start `flutter run` from `ui-main` in
   tmux session `flutter-ui-pro-max`, with that pid file and
   `/tmp/flutter-live-poker-trainer-ui.run.log`.

Wait until the log shows a Dart VM service on iPhone 17 Pro Max.

**`guest-home`.** Do not uninstall. The app must open on Home as a guest.
If `flutter run` is already `ui-main` on the Pro Max and Home is showing,
keep the process. Hot-restart only `/tmp/flutter-live-poker-trainer-ui.pid`
when that build is behind `origin/main`.

If the container is not a guest on Home:

- `onboarding-chrome` still due: walk that path instead.
- It is covered, and the container was wiped: replay the experience label
  and daily-goal minutes from that path's last row as **setup**. Setup gets
  the guest to Home. Do not charter those screens again and do not add a
  coverage row for them.

If course flags send a signed-out guest straight to sign-in, read the
Course rollout section in `README.md` before filing it. A path you cannot
start because of that gate is `blocked`, not a new defect, when the README
describes the gate.

## 3. Charter

On each screen of the chosen path, before leaving it:

1. **Finish the step** the screen is for, or record the control that stopped you.
2. **Theme.** Type, color, buttons, cards, and radius match the Theme section. Name the widget when they do not.
3. **Table.** A hand (hole cards, board, pot, or action) uses the Poker table bands. `LessonActionSpot` and `LessonTableScene` on a hand step are findings. One ticket per layout.
4. **Assets.** Logo, mascot, icons, motion, sound effects, and music match the Asset inventory. A missing slot is a finding. Quote the slot name.
5. **Game loop.** A lesson, Home path, or result matches Gamified learning. One job on screen, the table or path is the hero, Rex reacts on a right or wrong answer, and the lesson pays off in XP before Home. Open the cited frame in `docs/ui/references/duolingo-chess/frames/` when you are unsure what that beat looks like. A form, a text wall, or a silent exit is a finding. One ticket per missing beat, not per step that shares it.
6. **Layout.** Clipped text, overflow, overlapping bands, or a control with no name.
7. **Record.** The fix you would file names the design-record section it changes. A second gold, a second table, or a one-off font is not a finding to build. It is a finding to remove.

Skip a nit the record does not mention and that you did not see. Skip
strategy, grading, and coach truth. Those belong to
[new-user-qa](../new-user-qa/SKILL.md).

Retry open LPT issues whose steps sit on this path. Comment with this SHA
whether they still reproduce.

Screenshot before leaving a screen that breaks the record:

```bash
xcrun simctl io 7CB7DDCF-CBEA-414F-8A92-D490C7AAE35F screenshot .cursor/tmp/<nn>-<slug>.png
```

Scratch files stay in `.cursor/tmp/` under `ui-main`. Delete them after
they are attached.

## 4. Match existing issues before creating one

Search more than once, with different phrases. Include the design-record
section name and the widget or asset slot:

```
project = LPT AND text ~ "FeltTableView" ORDER BY updated DESC
```

Open each candidate with `getJiraIssue` (`view: evidence`).

- Same gap, not Done: do not create another issue. Comment with this
  walk's path id, steps, SHA, and new screenshots. Edit the description
  only when the steps, the expected result, or the design-record section
  are now wrong.
- Same gap, Done (or any done-category status), and it still reproduces:
  reopen it. `listJiraIssueTransitions`, then `transitionJiraIssue` to
  **To Do** (prefer a transition named Reopen or To Do). Edit the
  description to the current repro. Comment that it was closed and this
  walk still shows it. Attach new screenshots.
- Closed, and the screen now matches the record: leave it closed.
- No match: create one issue.

## 5. Ticket body

- **Bug** — the screen clips, overlaps, or hides a control.
- **Story** — the screen works, and it still breaks the design record
  (wrong chrome, a hand off the shared table, an empty asset slot, or a
  learning step with no game loop).
- Labels: `ui`, `ios`, and one area label (`onboarding`, `lesson`,
  `home`, `live-training`, `profile`, `account`). Asset-slot stories use
  the area of the screen where you saw the gap.
- Priority: **High** if a hand cannot use the shared table or a primary
  control is unusable. **Medium** for a clear mismatch or a missing asset
  slot. **Low** for polish on a screen that already matches the record.
  **Highest** only when this path's step cannot be finished.

```markdown
## What happened

<what the screen showed, in concrete UI text, and which record section it breaks>

## Steps

1. <path id> on the agent iPhone 17 Pro Max (<precondition>).
2. <exact taps>

## Expected

<the design-record section the screen should match>

## Design record

Section: `docs/ui/design-record.md` — <section name>.
After this ships, that section should say: <one or two sentences the implementer will write into the file>.

## Flutter UI/UX

<which phase applies: composition, responsive layout, animation, theme, or performance>

## Screenshots

Attached: <filenames and what each shows>.

## Validate before closing

1. <this path shows the updated section>
2. <the next screen that shares the widget still matches the same section>
3. <`docs/ui/design-record.md` contains the sentence from Design record>

Device: iPhone 17 Pro Max simulator, debug build on main, <date>, `<sha>`.
```

`createJiraIssue` with `contentFormat: markdown`. Then attach each screenshot
with `uploadAttachmentToJiraIssue`: phase 1 returns an `uploadCommand` to run
in the shell; phase 2 passes the `fileId`. Put the same shots on the reopen
comment when you did not create a new issue.

Do not edit `docs/ui/design-record.md` on this walk. The ticket is the
instruction. The implementer writes the file.

## 6. Order and blockers

After every finding from this walk has a key, link them.

`createJiraIssueLink` with `linkType: "Blocks"`: **inwardIssue blocks
outwardIssue**. The inward issue is the one that must land first.

Use **Blocks** when:

- the shared table, theme token, or asset slot has to land before a
  screen-level tweak can be checked, or
- the player hits them in an order that makes the later fix meaningless
  until the earlier one is done.

Use **Relates** when two findings share a screen and can ship independently.

Name the blocker key in the blocked issue's description, and why it is first.
Do not link an issue to itself. Do not use a parent or epic as a stand-in
for a block.

A ticket that retires `LessonActionSpot` or `LessonTableScene` for a hand
blocks a ticket that only restyles that mini-table.

## 7. Coverage

Log path: `<User's personal store>/live-poker-trainer/ui-consistency-qa/coverage.json`.
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
  "path": "lesson-full-table",
  "sha": "<origin/main full sha>",
  "date": "YYYY-MM-DD",
  "result": "findings",
  "issues": ["LPT-00"],
  "repeat": false,
  "notes": "Lesson title and activity id. Which table layout was on screen. Asset slots you checked."
}
```

`result` is `clean`, `findings`, `blocked`, or `skipped`.
`issues` lists keys created, commented, or reopened.
`blocked`: name the screen where the path stopped.
`skipped`: you reached `live-table-reference` and the product still will
not deal. The path stays due. A missing account is not a row.

A sweep (the user asked to walk every due path) still charters each path
separately, appends one row each, and stops when a Highest defect blocks
the next path's precondition.

## 8. Report

Delete every file you added under `.cursor/tmp/`.

Reply with the SHA, the path id, and the result. Then one line per issue:
key, created / reopened / commented, summary, and the design-record section
it updates. Then the block order (`LPT-a blocks LPT-b`). Then the next due
path, or that coverage is current. Name `live-table-reference` when it is
still waiting on an account. Include screens you could not reach.
