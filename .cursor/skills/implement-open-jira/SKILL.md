---
name: implement-open-jira
description: >-
  Implement every open Jira ticket assigned to the current user, one at a
  time, on a branch and worktree named for that ticket. Validate each change
  live on the agent iPhone 17 Pro, then close the ticket with a comment and
  screenshots. Use when the user invokes /implement-open-jira or asks to
  implement, ship, and close their open Jira tickets.
disable-model-invocation: true
---

# Implement open Jira tickets

Slash command. You are the engineer who owns each ticket from the board
through production. Ship one assigned open ticket at a time, prove it on
the agent simulator, then close it. Do not start the next ticket until this
one is closed or recorded as skipped or blocked.

Code changes go through [make-change](../make-change/SKILL.md) in this
session. Do not launch a subagent. Do not edit `~/live-poker-trainer`.

## Professional standard

Same bar as the rest of this repo's delivery path:

- The ticket is the spec. Read the summary, description, acceptance
  criteria, **Validate before closing**, comments, and links before any
  edit. The outcome is those checks, in the ticket's words.
- Ship the smallest change that makes every criterion true. Fix the cause.
  Leave behavior the ticket does not mention alone. No bundled fixes.
- One ticket, one branch, one PR. Tests lock the criteria. A green suite
  is not done: each criterion is shown on the agent iPhone 17 Pro, on the
  worktree before merge and again on `origin/main` after.
- If a criterion cannot be shown, comment the gap and leave the ticket
  open. Do not close it.
- Honor **Blocks**. An open issue that blocks this one means this one waits.
- If the writeup is too vague to implement without guessing product
  behavior, comment what is missing and skip it. Do not invent scope.

## Queue

1. Call `getAccessibleAtlassianResources` once and reuse `cloudId` on every
   later Jira call.
2. Search with `searchJiraIssuesUsingJql`:

   `assignee = currentUser() AND statusCategory != Done ORDER BY priority DESC, rank ASC`

   Page with `nextPageToken` until `isLast` is true. That is the queue:
   every unresolved ticket assigned to the signed-in user, highest priority
   first. An empty queue means stop and say so.
3. Tell the user the ordered keys and summaries, then start at the top.

## Branch and worktree

Name them from the ticket so the board, git, and the simulator session match.

```
KEY=LPT-12
SLUG="LPT-12-action-dock-clips"   # KEY, hyphen, short kebab summary
BRANCH="fix/$SLUG"                # Bug → fix. Story or Task → feature.
```

Worktree: `~/live-poker-trainer/.worktrees/$SLUG`.
Simulator tmux session from make-change: `flutter-pro-$SLUG`.

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
4. Before merge, validate the worktree build live on the agent iPhone 17
   Pro (`F1AE4938-D9BE-4EA1-8C98-58555A0DE62A`). Drive the UI with
   `tools/agent_tap.py`. Leave the user iPhone 17
   (`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`) alone. Screenshot details are in
   [docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).
   Walk the ticket's own steps, including **Validate before closing**.
   When those steps say fresh guest, uninstall and relaunch this worktree.
   A hot restart of a signed-in session is not that check.
5. Review `git diff origin/main...HEAD` against the ticket. Remove anything
   the criteria do not require.
6. PR test plan is those same criteria. Merge, deploy Cloud Functions, and
   refresh simulators (make-change steps 6–9).
7. After that refresh, walk the same steps again on `origin/main` and save
   the closeout screenshots to
   `~/live-poker-trainer/.cursor/tmp/<KEY>-*.png`. Those shots are the
   evidence for the Jira comment. A backend-only ticket still needs a live
   check on that Pro session (the screen or log that shows the behavior).

If implement, test, sim validation, or merge fails, comment the failure and
the blocker on the ticket. Do not transition it to Done. Stop the queue and
report the remaining keys.

## Close

Close a ticket only after the post-merge Pro walk succeeded and the
closeout screenshots exist. Every acceptance criterion was checked on that
walk.

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
   - each acceptance criterion and how it was checked on the Pro after
     merge
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
