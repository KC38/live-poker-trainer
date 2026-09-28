---
name: implement-open-jira
description: >-
  Implement every open Jira ticket in the Live Poker Trainer project, one at
  a time, on a branch and worktree named for that ticket. Validate each
  change live on the iPhone 17, then close the ticket with a
  comment and screenshots. Use when the user invokes /implement-open-jira or
  asks to implement, ship, and close open tickets in that project.
disable-model-invocation: true
---

# Implement open Jira tickets

Slash command. You are the engineer who owns each ticket from the board
through production. Ship one open ticket at a time, prove it on the agent
simulator, then close it. Do not start the next ticket until this one is
closed or recorded as skipped or blocked.

Code changes go through [make-change](../make-change/SKILL.md) in this
session. Do not launch a subagent. Do not edit `~/live-poker-trainer`.

## Professional standard

Same charter as [new-user QA](../new-user-qa/SKILL.md), applied as the
engineer who ships the ticket:

- The ticket is the spec. Read the summary, description, acceptance
  criteria, **Validate before closing**, comments, and links before any
  edit. The outcome is those checks, in the ticket's words.
- When the ticket names a path id, that path in
  [paths.md](../new-user-qa/paths.md) is the journey, including its
  precondition. Do not prove the fix on a different path.
- On the screens the ticket touches, the same six checks hold:
  1. The step the screen is for can be finished, or you record the control that still stops it.
  2. State this step set is still true on the next screen.
  3. Recovery the ticket mentions matches the product.
  4. Copy matches the code and README you read.
  5. Layout on this phone is intact: no new clip, overflow, or unnamed control.
  6. On a lesson or hand, the grade, the coach line, and the chip math refer to this choice and the amounts on screen.
  A written criterion that passes while one of these fails on the same path is not done.
- Ship the smallest change that makes every criterion true. Fix the cause.
  Leave behavior the ticket does not mention alone. No bundled fixes.
- One ticket, one branch, one PR. Tests lock the criteria. A green suite
  is not done: each criterion is shown on the iPhone 17, on the
  worktree before merge and again on `origin/main` after.
- If a criterion cannot be shown, comment the gap and leave the ticket
  open. Do not close it.
- Honor **Blocks**. An open issue that blocks this one means this one waits.
- If the writeup is too vague to implement without guessing product
  behavior, comment what is missing and skip it. Do not invent scope.

## UI tickets

When the ticket has the `ui` label, or it names `docs/ui/design-record.md`:

- Read [flutter-ui-ux](../flutter-ui-ux/SKILL.md) and
  [docs/ui/design-record.md](../../../docs/ui/design-record.md) before editing.
- Reuse the poker-table bands and the asset slot the ticket names. Do not
  add a second table, palette, or sound for the same role.
- Update the design-record section named in the ticket in the same change
  as the widget or asset. The file must say what the ticket said it would
  say, including a `Shipped` note with the widget or asset path.
- The close comment names that section and quotes the sentence that landed.

## Queue

1. Call `getAccessibleAtlassianResources` once and reuse `cloudId` on every
   later Jira call.
2. Search with `searchJiraIssuesUsingJql`. The project is Live Poker Trainer
   (key `LPT`):

   `project = LPT AND statusCategory != Done ORDER BY priority DESC, rank ASC`

   Page with `nextPageToken` until `isLast` is true. That is the queue:
   every unresolved ticket in that project, highest priority first. An empty
   queue means stop and say so.
3. Tell the user the ordered keys and summaries, then start at the top.

## Branch and worktree

Name them from the ticket so the board, git, and the simulator session match.

```
KEY=LPT-12
SLUG="LPT-12-action-dock-clips"   # KEY, hyphen, short kebab summary
BRANCH="fix/$SLUG"                # Bug → fix. Story or Task → feature.
```

Worktree: `~/live-poker-trainer/.worktrees/$SLUG`.
Simulator tmux session from make-change: `flutter-iphone17-$SLUG`.
Device: iPhone 17 `20ACECD5-FBEE-4663-9044-E11D5F0A26FC`.

Pass that `BRANCH` and `SLUG` into make-change step 1. Do not drop the
issue key. Do not reuse another ticket's worktree.

PR title: `LPT-12: Action dock clips the fold button`. The squash commit
on `main` uses that title, so the key remains after the branch is deleted.
Commit subjects include the key (`fix: keep the fold button on screen (LPT-12)`).

## One ticket

Read it with `getJiraIssue` (`view: full`) before any code.

Leave it open and continue when it is not a code change in this repo, when
another open issue blocks it, or when the spec is too vague to implement.
Comment that reason on the ticket, then take the next one.

Otherwise run make-change in this session for this ticket only:

1. After the worktree exists, load transitions with `executeRead`
   operation `listJiraIssueTransitions` and take the one whose target is
   In Progress when it exists (`transitionJiraIssue`).
2. Implement only that ticket, against its acceptance criteria.
3. Add or update tests that lock those criteria.
4. Before merge, validate the worktree build live on the iPhone 17
   (`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`). Drive the UI with
   `tools/agent_tap.py --log "$LOG_FILE"` for this session's log
   (`/tmp/flutter-$SLUG.log` before merge). Do not use the default log:
   that drives the iPhone 17 Pro, which belongs to
   [new-user-qa](../new-user-qa/SKILL.md). Do not boot, uninstall,
   terminate, kill, hot-restart, screenshot, or tap the Pro
   (`F1AE4938-D9BE-4EA1-8C98-58555A0DE62A`). Screenshot with
   `xcrun simctl io 20ACECD5-FBEE-4663-9044-E11D5F0A26FC screenshot …`.
   Other device details are in
   [docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).
   Walk the ticket's own steps, including **Validate before closing**,
   and the six charter checks above. Meet the path precondition from
   [paths.md](../new-user-qa/paths.md): `fresh-install` means uninstall and
   relaunch this worktree on the iPhone 17 only; `guest-home` means do not
   uninstall. A hot restart of a signed-in session is not a fresh-install
   check.
5. Review `git diff origin/main...HEAD` against the ticket. Remove anything
   the criteria do not require.
6. PR test plan is those same criteria. Merge, deploy Cloud Functions, and
   refresh the iPhone 17 only (`refresh-simulator.sh implement`,
   make-change steps 6–9). That refresh must not restart the Pro.
7. After that refresh, walk the same steps again on `origin/main` on the
   iPhone 17 and save the closeout screenshots to
   `~/live-poker-trainer/.cursor/tmp/<KEY>-*.png`. Those shots are the
   evidence for the Jira comment. The post-merge log is
   `/tmp/flutter-live-poker-trainer-iphone17.run.log`. A backend-only
   ticket still needs a live check on that iPhone 17 session (the screen
   or log that shows the behavior). Do not walk it on the Pro.

If implement, test, sim validation, or merge fails, comment the failure and
the blocker on the ticket. Do not transition it to Done. Stop the queue and
report the remaining keys.

## Close

Close a ticket only after the post-merge iPhone 17 walk succeeded and the
closeout screenshots exist. Every acceptance criterion and the six
charter checks were checked on that walk.

1. Upload each screenshot with `executeWrite` operation
   `uploadAttachmentToJiraIssue`: call with `filePath` to get
   `uploadCommand`, run that command, and keep the returned `fileId` and
   collection. Do not run phase 2 for the same file. Embed the file on the
   comment instead.
2. Add one comment with `addOrEditJiraIssueComment`. Use
   `contentFormat: html` plus `inlineFileId` and `inlineFileCollection`
   from the upload. The comment must stand alone:
   - what shipped
   - branch name and PR URL
   - each acceptance criterion and the six charter checks, and how each
     was checked on the iPhone 17 after merge
   - that the images are from that live session
   Do not put the comment on `transitionJiraIssue` `update`. That path
   drops the comment.
3. Load transitions with `executeRead` operation `listJiraIssueTransitions`.
   Call `transitionJiraIssue` with the transition whose target status
   category is Done (`transitionId` from that list). `transitionName` is
   the transition's own name, which often differs from the status name.
   Confirm the status the tool returns.
4. Delete `~/live-poker-trainer/.cursor/tmp/<KEY>-*.png`.

## Report

When the queue ends, one short list: key, closed or skipped or blocked,
branch name, and PR URL when there is one.
