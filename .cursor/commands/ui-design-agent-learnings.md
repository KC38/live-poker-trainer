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
- Prefer not to treat `tap --text Gems` as proof the gem control works:
  the strip Tooltip is "Gems" with no `onTap`, and the needle can land on
  Hearts / the refill sheet instead.
- Prefer reopening a Done `ui-agent` ticket that still reproduces over
  filing a near-duplicate.
- Prefer one lesson-content bug (fixed cards, stacked/enabled-empty Hint,
  multi-target or inconsistent SoftPulse, bad coach copy, hearts that do
  not spend or restore) or teach-by-doing gap over spacing chrome.
- Prefer a second open of the same lesson when judging card randomization —
  screenshot hole/board cards on attempt A and attempt B before deciding
  the deal is fixed.
- Prefer screenshotting the heart count before and after a paid miss (and
  after Practice/refill) before claiming hearts work.
- Prefer reading PNGs you just captured before judging; do not close from
  memory of an earlier run's screenshot.
- Prefer naming Jira shots `<surface>-issue.png` and
  `<KEY>-validated.png`. Never file without an issue shot; never close
  without a validated shot on origin/main.
- Prefer, when fixing a stadium `FilledButton` → Theme elevated CTA on one
  surface (Settings, Profile, Save progress), grepping sibling guest
  **Create an account** call sites in the same walk so the twin does not
  wait another run (LPT-45 then LPT-46).

## Ops (simulator, CLI, Jira)

- Cursor CLI over SSH / LaunchAgent needs `CURSOR_API_KEY` in
  `~/.live-poker-trainer/secrets.env`. A locked login keychain is not
  fixable mid-run; do not call `agent login`.
- Jira needs `ATLASSIAN_EMAIL` + `ATLASSIAN_API_TOKEN` in that same
  secrets file. If `jira.py check` fails, release and end with
  `JIRA_UNAVAILABLE`.
- `jira.py create` prints `KEY<TAB>URL`. Capture the key with
  `KEY=$(python3 tools/jira.py create … | awk '{print $1}')` — never pass
  the whole line into `edit` / `get` / `comment`.
- "Connection lost, reconnecting…" from the CLI is normal. Let it retry;
  do not kill the run or the loop for a single reconnect.
- `dart_vm_ready` must use a macOS-safe grep class (`[A-Za-z0-9_=-]`, '-' last).
  A bad `\-=` range made every preflight report SIM_NOT_READY even when the
  Dart VM URI was already in the Flutter log.
- The unattended loop prepares the mini **programmatically** (claim →
  refresh → wait for Dart VM) and only then starts `agent -p`. A
  `SIM_NOT_READY` preflight never starts the agent. Do not re-claim the
  lock when `SIM_LOCK_RUN_ID` already guards, and do not re-refresh when
  the Flutter log already has a VM URI.
- Flutter may stick at "Launching…" with no Dart VM line and no pid file.
  After the mandated one retry, end `SIM_NOT_READY` — do not uninstall the
  app or chase Device Hub UI. A common cause is `flutter pub get`
  Terminated: 15 while another agent holds the Flutter cache lock;
  `refresh-simulator.sh` retries pub get — do not rewrite it mid-run.
- After consecutive `SIM_NOT_READY`, the loop backs off (~10 min) so other
  flutter pub/test work can finish before the next claim.
- `refresh-simulator` must claim with `--pid $$`. Pid-less locks go stale
  after 10 minutes; never force-hold the mini without a pid.
- `/tmp/flutter-live-poker-trainer.run.log` must be a normal file. If a
  stale symlink or directory is there, the refresh script should recreate
  it; do not hand-edit launcher scripts during a ticket run.
- Worktree validation uses `--log /tmp/flutter-$SLUG.log` and its own
  tmux session. Origin/main validation uses
  `/tmp/flutter-live-poker-trainer.run.log`. Do not mix them.
- When starting `refresh-simulator.sh` (or any sim tool) from tmux
  `send-keys`, export `SIM_LOCK_RUN_ID=…` in that command line. A bare
  tmux shell does not inherit the agent export, so refresh reports the
  mini busy under your own run id.
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
- Lesson walks must exercise Hint (one line, disabled when empty — including
  multiturn), one gold SoftPulse at a time with the same cue UI for guide
  and Hint, coach mood/copy, hearts lose/restore, and a second attempt for
  card randomization — not only Continue through the happy path.
- Every ticket needs a current-issue screenshot on file and a validated
  origin/main screenshot on the Done comment. Text-only closeouts are not
  enough.
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
- 2026-10-10: LPT-44 filed `needs-human` for gems tap (shop vs
  explanation vs defer). Parse `jira.py create` key before `edit`.
- 2026-10-10: LPT-45 Settings then LPT-46 Profile twin (stadium
  `FilledButton` → Theme elevated). Grep sibling guest Create an account
  CTAs in the same walk; export `SIM_LOCK_RUN_ID` inside tmux
  `send-keys` for post-merge refresh.
