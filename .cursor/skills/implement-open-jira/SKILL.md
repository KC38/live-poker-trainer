---
name: implement-open-jira
description: >-
  Implement every open Jira ticket assigned to the current user, one at a
  time, validate each change live on the agent iPhone 17 Pro, then close
  the ticket with a comment and screenshots. Use when the user invokes
  /implement-open-jira or asks to implement, ship, and close their open
  Jira tickets.
disable-model-invocation: true
---

# Implement open Jira tickets

Slash command. Ship each open ticket assigned to the current user, prove it
on the agent simulator, then close the ticket. One ticket at a time. Do not
start the next ticket until this one is closed or recorded as skipped or
blocked.

Code changes go through [make-change](../make-change/SKILL.md). Do not edit
`~/live-poker-trainer`.

## Queue

1. Call `getAccessibleAtlassianResources` once and reuse `cloudId` on every
   later Jira call.
2. Search with `searchJiraIssuesUsingJql`:

   `assignee = currentUser() AND statusCategory != Done ORDER BY priority DESC, rank ASC`

   Page with `nextPageToken` until `isLast` is true. That is the queue:
   every unresolved ticket assigned to the signed-in user, highest priority
   first. An empty queue means stop and say so.
3. Tell the user the ordered keys and summaries, then start at the top.

## One ticket

Read it with `getJiraIssue` (`view: full`) before any code: summary,
description, acceptance criteria, comments, and links.

Leave it open and continue when it is not a code change in this repo, or
when another issue blocks it. Comment that reason on the ticket, then take
the next one.

Otherwise launch **one** subagent with
[make-change](../make-change/SKILL.md) and the full ticket. Do not resume
it. Do not run two tickets at once; they share one simulator.

The subagent:

- Implements only that ticket.
- Before merge, validates the worktree build live on the agent iPhone 17
  Pro (`F1AE4938-D9BE-4EA1-8C98-58555A0DE62A`). Drive the UI with
  `tools/agent_tap.py`. Leave the user iPhone 17
  (`20ACECD5-FBEE-4663-9044-E11D5F0A26FC`) alone. Screenshot details are in
  [docs/agent-ios-simulator.md](../../../docs/agent-ios-simulator.md).
- Merges to `main`, deploys Cloud Functions, and refreshes simulators.
- After that refresh, walks the same flow again on `origin/main` and saves
  the closeout screenshots to
  `~/live-poker-trainer/.cursor/tmp/<KEY>-*.png`. Those shots are the
  evidence for the Jira comment. A backend-only ticket still needs a live
  check on that Pro session (the screen or log that shows the behavior).

If implement, test, sim validation, or merge fails, comment the failure and
the blocker on the ticket. Do not transition it. Stop the queue and report
the remaining keys.

## Close

Close a ticket only after the post-merge Pro walk succeeded and the
closeout screenshots exist.

1. Upload each screenshot with `executeWrite` operation
   `uploadAttachmentToJiraIssue`: call with `filePath` to get
   `uploadCommand`, run that command, and keep the returned `fileId` and
   collection. Do not run phase 2 for the same file. Embed the file on the
   comment instead.
2. Add one comment with `addOrEditJiraIssueComment`. Use
   `contentFormat: html` plus `inlineFileId` and `inlineFileCollection`
   from the upload. The comment must stand alone:
   - what shipped
   - PR URL
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
and PR URL when there is one.
