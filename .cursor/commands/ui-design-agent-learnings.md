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
  Skip the local deploy script and note it. When the fix is in Cloud
  Functions, wait for GitHub `Deploy Cloud Functions` on the merge SHA
  before mini closeout — client chrome alone cannot prove a grade/hearts
  rule until that job succeeds.
- Never hardcode a simulator UDID. Always
  `DEVICE="$(tools/iphone_13_mini_udid.sh)"`.
- Never launch a subagent or a second parallel `/ui-design-agent` run.
- Never implement more than one ticket in a run. Filing many ui-agent
  tickets from one walk is required when several distinct bugs have
  screenshots; only the chosen KEY gets make-change → close. Later runs
  pick up the rest from the open queue.
- Never edit the primary checkout. All code changes go through make-change
  in a `.worktrees/<slug>` worktree.
- Never invent a GitHub owner/URL from a person's name (e.g.
  `kushalchachan/...`). PR links must come from `gh pr create` output or
  `gh pr view <n> --json url -q .url` (repo is `KC38/live-poker-trainer`).

## Prefer

- Prefer exact `agent_tap` labels from the screen. Broad needles like
  `Continue` can hit Home chrome instead of the lesson control.
- Prefer `python3 tools/agent_tap.py back` (no `--text`) to dismiss modal
  bottom sheets (Hearts refill, legends). A `tap --text Back` needle is
  not required and often missing on sheets.
- Prefer `openlesson` with the catalog id from `course_catalog` / `rg`
  (`lesson-01-02-02-best-five-kickers`), not the Home title and not a
  guessed `01-01-0N` from ledger order — both yield "Unknown lesson".
- Prefer copying gitignored `lib/firebase_options.dart` (and iOS/Android
  Google services files) into the ticket worktree before `flutter run`;
  without them the worktree build fails even when primary runs fine.
- Prefer not to treat `tap --text Gems` as proof the gem control works:
  the strip Tooltip is "Gems" with no `onTap`, and the needle can land on
  Hearts / the refill sheet instead.
- Prefer reopening a Done `ui-agent` ticket that still reproduces over
  filing a near-duplicate.
- Prefer one lesson-content bug (fixed cards, stacked/enabled-empty Hint,
  Hint stuck under Oops/Nice! after a Hint press, multi-target or
  inconsistent SoftPulse, bad coach copy, hearts that do not spend or
  restore) or teach-by-doing gap over spacing chrome. When fixing multi
  SoftPulse, update tests that assert `findsNWidgets(N>1)` on
  `glow-highlight` for that surface — they may have locked the bug (LPT-55).
  Ids in `lessonFrameSameConceptQuietIds` (e.g. guided-seven) stay SoftPulse
  off until Hint by design — judge Hint-reopened SoftPulse, not first-press
  gold (LPT-57). After SoftPulse lands on explain, grep the sibling picker.
  After Hint then a grade, read the dock bubble — Hint copy under Oops is a
  bug; clear `_hintVisible` on `finishSubmit` / `presentLocalMiss` (LPT-60).
- Prefer card `agent_tap` needles as Semantics display (`A♣`), not ASCII
  codes like `Ac` — short codes can miss the card or open Hearts.
- Prefer a second open of the same lesson when judging card randomization —
  screenshot hole/board cards on attempt A and attempt B before deciding
  the deal is fixed. Read ranks from the latest PNG before tapping a
  SoftPulse target; a stale rank needle misses the gold card.
- Prefer screenshotting the heart count before and after a paid miss (and
  after Practice/refill) before claiming hearts work. Read PNGs you just
  captured; do not close from memory of an earlier run.
- Prefer naming Jira shots `<surface>-issue.png` and
  `<KEY>-validated.png`. Never file without an issue shot; never close
  without a validated shot on origin/main. Every Markdown image in the
  body must be a real on-disk path (or listed in `--attach`); `jira.py`
  refuses comments/creates that would post `!file|thumbnail!` for a file
  that did not upload — that is what shows as Preview unavailable in Jira
  (LPT-59 closeout orphan `LPT-59-validated.png`). If `jira.py comment`
  exits non-zero, do **not** `transition … Done` — fix the attach/body and
  re-comment first (LPT-62: first closeout failed, Done raced ahead). After
  a successful closeout comment, `jira.py verify-embeds LPT-NN` must pass
  before Done.
- Prefer, after a one-surface fix (Theme CTA, `boardSlots: false`, SoftPulse
  on explain), grepping sibling call sites / builders in the same walk so
  twins do not wait another run (LPT-45/46, LPT-50/52, LPT-55→57).
- Prefer, when `openlesson` resumes mid-lesson past the beat under test,
  finishing/restarting or validating a sibling activity on the **same**
  code path for closeout proof instead of filing unreachable.
- Prefer, when `refresh-simulator.sh` leaves only a `Launching…` line and a
  dead pid, starting `flutter run` yourself in tmux with
  `SIM_LOCK_RUN_ID=…` exported on that command line. On Xcode "No space
  left on device", clear `~/Library/Developer/Xcode/DerivedData/Runner-*`
  (and `/tmp/flutter_tools.*`) then retry once (LPT-61) — do not rewrite
  refresh or `needs-human` on the first disk-full build.
- Prefer waiting until the target beat is settled before
  `<KEY>-validated.png` (not bootstrap spinner). On locked-start, capture
  the Open-previous / Retry gate and read Rex's bubble against the gold
  Open-previous CTA — Retry-only copy with that button is a bug (LPT-51).
- Prefer clearing Hint / SoftPulse before staging an invalid Best five for
  Undo proof so the status hits "Five tapped — try a stronger five" and
  cyan matches the five taps.

## Ops (simulator, CLI, Jira)

- Cursor CLI over SSH / LaunchAgent needs `CURSOR_API_KEY` in
  `~/.live-poker-trainer/secrets.env`. Do not call `agent login`. The loop
  sets `AGENT_CLI_CREDENTIAL_STORE=memory` and clears a stuck
  `cursor-access-token` keychain item before each start so
  `errSecDuplicateItem` / `auth.refresh.persistFailed` cannot burn the run.
- Heartbeat during long worktree `flutter run`, validates, and Cloud
  Functions deploy; the stall watchdog kills a silent agent (tmux
  `deploy-LPT-*` / `refresh-LPT-*` count as alive). Write coverage before
  long compiles when the ticket is already Done in Jira.
- Jira: `ATLASSIAN_EMAIL` + `ATLASSIAN_API_TOKEN` in that secrets file.
  `jira.py check` failure → `JIRA_UNAVAILABLE`. `create` prints
  `KEY<TAB>URL` — take column 1 only for `edit` / `get` / `comment`.
- "Connection lost, reconnecting…" is normal; let the CLI retry once.
- Loop preflight is programmatic (claim → refresh → Dart VM) before
  `agent -p`. `dart_vm_ready` needs macOS-safe `[A-Za-z0-9_=-]`. One
  refresh + one retry then `SIM_NOT_READY` (often `pub get` Terminated: 15);
  do not rewrite refresh mid-run. Consecutive misses back off ~10 min.
- `refresh-simulator` must claim with `--pid $$`. Export `SIM_LOCK_RUN_ID`
  inside tmux `send-keys`. Worktree validate uses
  `/tmp/flutter-$SLUG.log`; origin/main uses
  `/tmp/flutter-live-poker-trainer.run.log` (must be a normal file).
- Attach pane only shows start/end; live detail is in
  `~/.live-poker-trainer/ui-agent-logs/run-*.log` and the agent transcript.

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

- 2026-10-10: LPT-55–57 / LPT-61 best-five SoftPulse (one target; no post-grade
  multi-glow; quiet ids until Hint; sibling picker after explain). LPT-59
  guided free miss; LPT-60 clear Hint on grade. LPT-62 draft-mirror Undo;
  closeout comment must succeed before Done.
