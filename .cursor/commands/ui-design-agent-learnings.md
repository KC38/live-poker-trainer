# UI design agent learnings

Living rules for `/ui-design-agent`. Read this in step 2 of every run.
Update it in step 10 when this run hit a durable mistake, retry, or gotcha
that the next run would otherwise repeat.

This file is **operational memory**, not product taste. Product contract
stays in `docs/ui/design-record.md`. Do not paste ticket prose here.

## How to update (step 10)

1. Ask: would the next run make the same mistake without a new rule?
2. If no, leave this file alone.
3. If yes, add or tighten **one** bullet under the right section. Prefer
   editing an existing bullet over appending a near-duplicate.
4. Keep each bullet one or two lines: **Do / Never / Prefer**, then why.
5. Cap: at most **40** bullets total across all sections. When over the
   cap, merge the oldest low-signal ones before adding.
6. Ship the edit with the ticket PR when this run has one. When the run
   ends without a product PR (for example `SIM_NOT_READY`, `clean`,
   `JIRA_UNAVAILABLE`) but learnings changed, open a tiny chore PR via
   make-change (`feature/ui-agent-learnings-<YYYYMMDD>`) before releasing
   the lock. One commit, this file only (plus the test lock if needed).
7. Never log secrets, tokens, UDIDs, or full crash dumps here.

## Never again

- Never use Atlassian MCP (or any MCP) from the unattended loop. Use
  `python3 tools/jira.py` only; the loop has no MCP auth.
- Never wait for the simulator lock. Exit 3 from `sim_lock.py claim` means
  print `SIM_BUSY` and end the run immediately.
- Never debug or rewrite `refresh-simulator.sh` mid-run when the Dart VM
  never appears. One refresh + one retry, then `SIM_NOT_READY`, release,
  end. The next run retries from a free mini.
- Never treat a missing local Firebase CI login as a ticket failure.
  Skip Cloud Functions deploy, note it in the report, and still close the
  ticket when the mini criteria passed on origin/main.
- Never hardcode a simulator UDID. Always
  `DEVICE="$(tools/iphone_13_mini_udid.sh)"`.
- Never launch a subagent or a second parallel `/ui-design-agent` run.
- Never edit the primary checkout. All code changes go through make-change
  in a `.worktrees/<slug>` worktree.

## Prefer

- Prefer exact `agent_tap` labels from the screen. Broad needles like
  `Continue` can hit Home chrome instead of the lesson control.
- Prefer reopening a Done `ui-agent` ticket that still reproduces over
  filing a near-duplicate.
- Prefer one teach-by-doing or behavior gap over spacing chrome when
  ranking findings.
- Prefer reading PNGs you just captured before judging; do not close from
  memory of an earlier run's screenshot.

## Ops (simulator, CLI, Jira)

- Cursor CLI over SSH / LaunchAgent needs `CURSOR_API_KEY` in
  `~/.live-poker-trainer/secrets.env`. A locked login keychain is not
  fixable mid-run; do not call `agent login`.
- Jira needs `ATLASSIAN_EMAIL` + `ATLASSIAN_API_TOKEN` in that same
  secrets file. If `jira.py check` fails, release and end with
  `JIRA_UNAVAILABLE`.
- "Connection lost, reconnecting…" from the CLI is normal. Let it retry;
  do not kill the run or the loop for a single reconnect.
- Flutter may stick at "Launching…" with no Dart VM line and no pid file.
  After the mandated one retry, end `SIM_NOT_READY` — do not uninstall the
  app or chase Device Hub UI.
- `/tmp/flutter-live-poker-trainer.run.log` must be a normal file. If a
  stale symlink or directory is there, the refresh script should recreate
  it; do not hand-edit launcher scripts during a ticket run.
- Worktree validation uses `--log /tmp/flutter-$SLUG.log` and its own
  tmux session. Origin/main validation uses
  `/tmp/flutter-live-poker-trainer.run.log`. Do not mix them.
- Attach / the loop pane only prints run start and end. Live detail is in
  `~/.live-poker-trainer/ui-agent-logs/run-*.log` and the run's agent
  transcript. Do not stall waiting for the attach pane to stream tokens.

## Product judgment

- Live Training lock copy names the Home lesson that unlocks it (for
  example "Baseline jump check"). It must not say "Section 2".
- Profile Course place should show `SECTION N, UNIT N` and the unit title
  when progress exists — not a bare "Never Played" once the learner has
  a place in the course.
- "Your two cards" and similar peeks must not show empty board slots when
  no board is in play for that beat.
- When the design record and a shipped screen disagree, the record (plus
  stakeholder brief) wins; file or reopen the ticket rather than
  "accepting" the screen as intentional chrome.

## Recent run notes

Short dated notes for context. Drop notes older than ~14 days when
trimming. Durable rules belong in the sections above, not only here.

- 2026-10-10: Two back-to-back runs hit Flutter never reaching a Dart VM
  service after refresh (`SIM_NOT_READY`). Next runs should keep the
  one-retry rule and move on; do not burn the attempt budget debugging
  launch.
- 2026-10-10: LPT-16 regression returned ("Section 2" on the Live Training
  lock). Reopen Done tickets that still reproduce; do not file a twin.
- 2026-10-10: Local functions deploy skipped repeatedly (no Firebase CI
  creds). Closing on mini proof is enough; Actions owns deploy.
