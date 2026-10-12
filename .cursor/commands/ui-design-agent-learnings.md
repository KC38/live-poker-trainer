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
6. Ship the edit in the ticket PR (write it before step 8's merge). After
   the merge, or on a run without a product PR (`SIM_NOT_READY`, `clean`,
   `JIRA_UNAVAILABLE`), append to
   `~/.live-poker-trainer/ui-agent-learnings-pending.md` instead — the
   next run's step 6 folds it into its ticket PR. A learnings-only chore
   PR (`chore/ui-agent-learnings-<YYYYMMDD>`) only when pending holds 5+
   bullets and this run has no ticket PR.
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
- Never thrash the unattended loop on Cursor `ActionRequiredError` /
  Auto usage limit. The loop launches via `@cursor/sdk` cloud+machine
  (`cursor-agent-worker-4c8b3dc416` on this Mac mini) so chats appear as
  `bc-*` in the Agents sidebar, with Auto (`default`). It backs off
  (exit 14) until the day after the stated cycle end. Use
  `UI_AGENT_SDK_RUNTIME=local`, `UI_AGENT_LAUNCHER=cli`, or a non-Auto
  `UI_AGENT_MODEL` only when required. After `gh pr create`, rename
  **this** chat via cloud MCP `rename-chat` (`cursor-cloud`) to
  `LPT-NN PR-<n>` (step 8; step 10 fallback). That is the sidebar title
  only — never rename a make-change branch to `cursor/…` (LPT-69). Keep
  `fix/LPT-NN-…` / `feature/LPT-NN-…`. When ManagePullRequest refuses a
  make-change branch for lacking `cursor/`, recreate with
  `skip_branch_prefix_check: true` — do not rename the ticket branch to
  `cursor/…` (LPT-70). Skip rename-chat when the tool is missing or either
  id is unknown — never invent a title or rename another chat.
- Never hardcode a simulator UDID (always
  `DEVICE="$(tools/iphone_13_mini_udid.sh)"`) or launch a subagent / second
  parallel `/ui-design-agent` run.
- Never implement more than one ticket in a run. Filing many ui-agent
  tickets from one walk is required when several distinct bugs have
  screenshots; only the chosen KEY gets make-change → close. Later runs
  pick up the rest from the open queue.
- Never claim, implement, companion-fold, or close a `grokbot` ticket on
  this Mac mini. Queue JQL must keep `labels != grokbot`. File
  browser-validatable layout-only findings as `ui,grokbot,<area>` (no
  `ui-agent`); SoftPulse / Hint / hearts / randomization / deal timing /
  iOS-only stay on `ui-agent`. Never end a run (or let the loop spawn a
  new agent) when this run's filings are only `grokbot` — keep walking
  until you have a `ui-agent` KEY or every remaining surface is clean for
  Mac-mini work.
- Never edit the primary checkout (make-change worktrees only), invent
  GitHub owner/URLs from a person's name (`gh` only,
  `KC38/live-poker-trainer`), or let LaunchAgent `ensure`/`start`
  kill-session a live run-loop when the pid file is stale — recover the
  pid from the tmux session instead. Soft-stop clears STOP on the next
  `start`/`ensure`, runs `prepare_launcher` (SDK `npm ci`) before claiming
  the mini, and schedules `ensure` after the soft-stopped loop exits so
  the next ticket does not wait on LaunchAgent `StartInterval` (use
  `kill`/`uninstall` to leave the loop down).
- Never `gh pr merge` a draft, and never `git push --delete` the ticket
  branch / remove the worktree until `mergedAt` is set (LPT-71: draft
  merge failed then branch delete closed #1676 — recover via local commit
  SHA, `gh pr reopen`, `gh pr ready`, then squash-merge).

## Prefer

- Prefer exact `agent_tap` labels from the screen. Broad needles like
  `Continue` can hit Home chrome instead of the lesson control.
- Prefer `python3 tools/agent_tap.py back` (no `--text`) to dismiss modal
  bottom sheets (Hearts refill, legends). A `tap --text Back` needle is
  not required and often missing on sheets.
- Prefer `openlesson` with the catalog id from `course_catalog` / `rg`
  (`lesson-01-02-02-best-five-kickers`), not the Home title and not a
  guessed `01-01-0N` from ledger order — both yield "Unknown lesson".
  Button and blinds is `lesson-01-01-03-blinds-and-button` (not
  `…-button-and-blinds`).
- Prefer copying gitignored `lib/firebase_options.dart` (and iOS/Android
  Google services files) into the ticket worktree before `flutter run`;
  without them the worktree build fails even when primary runs fine. When a
  prior-run worktree for the same KEY is behind `origin/main`,
  `reset --hard origin/main` and re-apply the patch before tests (LPT-63).
- Prefer patching `content/course/v2/course.json` + `npm --prefix functions
  run course:generate` over `node tools/course/build_seed_course.mjs` when
  only one activity needs a bank field — full seed rebuilds from wave
  sources and can wipe hand-maintained catalog rows that diverged (LPT-74
  streets `seat-co`). Keep wave helpers in sync for the next full seed.
- Prefer merging + Functions deploy before mini-proving a
  `gradeCourseResponse` / Nice! feedback change — the worktree app still
  hits production Cloud Functions until that deploy lands (LPT-74).
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
  gold (LPT-57). Quiet multi-press boards must report
  `remainingPressCount` from untapped targets even when SoftPulse/
  `showGuidance` is off after a wave closes — gating remaining on
  SoftPulse visibility leaves Hint disabled for presses 2+ (LPT-72
  `LessonSuitBoardTable`). After SoftPulse lands on explain, grep the sibling picker —
  blinds guided frames in `select_identify` still need `cuePuckLabel` (D/SB/BB),
  not only `LessonBlindsClockwiseTable` (LPT-69). Puck SoftPulse needs an
  inflated hit box + `reserveLayout: true` or the glow clips inside a tight
  `SizedBox`. After Hint then a grade, read the dock bubble — Hint copy under
  Oops is a bug; clear `_hintVisible` on `finishSubmit` / `presentLocalMiss`
  (LPT-60). Hint must stay off whenever `showTargetCue` is true (LPT-63);
  judge that by greyed chrome + unchanged bubble — `agent_tap tap Hint` still
  returns ok on a disabled control. Call `notifyFeltDealReady(true)` before
  asserting `showTargetCue` in controller unit tests. Blinds scaffolded
  SoftPulse paints only after Hint — do not auto-unlock `showTargetCue` for
  those ids or Hint stays dead with no gold (LPT-73
  `lessonFrameBlindsSoftPulseWaitsForHint`); keep Best five kicker SoftPulse
  on by default. When the cued BB puck is not posted yet, SoftPulse must
  fall back to the seat ring. Never judge Hint SoftPulse at zero hearts —
  `_heartsGateActive` disables Hint unless Practice
  (`allowZeroHeartsPractice`); earn a heart or use Practice first.
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
  (LPT-59 closeout orphan `LPT-59-validated.png`). Pass every closeout PNG in
  one `--attach a.png b.png` list — repeating `--attach` with `nargs=*` keeps
  only the last group and the comment fails on missing embeds (LPT-69). If
  `jira.py comment` exits non-zero, do **not** `transition … Done` — fix the
  attach/body and re-comment first (LPT-62: first closeout failed, Done raced
  ahead). After a successful closeout comment, `jira.py verify-embeds LPT-NN`
  must pass before Done.
- Prefer, after a one-surface fix (Theme CTA, `boardSlots: false`, SoftPulse
  on explain), grepping sibling call sites / builders in the same walk so
  twins do not wait another run (LPT-45/46, LPT-50/52, LPT-55→57).
- Prefer, when `openlesson` resumes mid-lesson past the beat under test,
  finishing/restarting or validating a sibling activity on the **same**
  code path for closeout proof instead of filing unreachable. Same-concept
  quiet ids (`lessonFrameSameConceptQuietIds`, e.g. guided-suits ★) SoftPulse
  only via Hint — after Oops Continue, Hint must work again
  (`clearFeedbackForRetry` clears hintUsed; LPT-71).
- Prefer trusting `refresh-simulator.sh` after hot-restart — it waits for a
  Dart VM URI and cold-starts (cached `Runner.app` when native inputs
  match) if stuck on `Launching…`. If it still fails, relaunch with
  `tools/flutter_run_fast.sh` — never a hand-rolled tmux `flutter run`.
  On Xcode "No space left on device", run `python3 tools/disk_guard.py
  --min-free-gb 40` (orphan DerivedData, idle worktree builds) then retry
  once (LPT-61) — do not wipe the primary's DerivedData, rewrite refresh,
  or `needs-human` on the first disk-full build.
- Prefer a full process restart (kill `flutter run`, relaunch) after
  patching guest `flutter.onboarding_draft_v1` on disk — hot-restart keeps
  cached SharedPreferences so `dailyGoalMinutes` stays null and Lesson
  Complete still shows AMAZING (LPT-39). After the last Nice!, poll for
  Lesson Complete before tapping CONTINUE — a second Continue can skip
  the result onto Home.
- Prefer waiting until the target beat is settled before
  `<KEY>-validated.png` (not bootstrap spinner). On hole-card peeks, wait
  until the hero cards are face-up (not empty outlines) before `tap You`.
  On locked-start, capture the Open-previous / Retry gate and read Rex's
  bubble against the gold Open-previous CTA — Retry-only copy with that
  button is a bug (LPT-51). For board SoftPulse tickets, read the coach
  line first — unguided-mix is "Tap the community cards."; hole SoftPulse
  on guided/scaffolded is a different cue (LPT-68 closeout).
- Prefer adopting `sim_lock_run_id` from
  `~/.live-poker-trainer/ui-agent-handoff.json` (then
  `simulator-lock.json`) when `$SIM_LOCK_RUN_ID` is unset in a
  cloud/machine shell — export it once and continue. The ~40s before the
  first assistant is SDK boot, not sim connect; loop preflight already
  claimed + warmed the Dart VM (~1–2s). Do not spend another ~60s grepping
  the flutter log / re-checking the lock when handoff has
  `dart_vm_ready` / `skip_sim_verify_at_start` — go to step 2.
  Clear Hint / SoftPulse before staging an invalid Best five for Undo proof
  so cyan matches the five taps.
- Never loop dozens of `tap Continue` to brute-force prerequisite lessons —
  course start rate-limits with "Too many course requests" and blocks the
  mini until Retry/backoff. Use `python3 tools/agent_seed.py unlock
  --lesson "<title>" --open` (and `hearts N` / `gems N`) to jump there;
  "later lessons need a guest progress chain" is no longer unreachable.
  When SoftPulse/cues are missing because the lesson is already complete
  (review mode), use `fresh --lesson … --open` — not ad-hoc Firestore
  patches or `unlock` alone (unlock keeps the lesson in completedLessonIds).
  Never run `sips -c` in place on the only issue/validated PNG — copy first,
  then crop the copy.

- Prefer, on Best five SoftPulse closeout: clear the lesson from `completedLessonIds` + hot-restart so review mode does not hide cues; judge seat SoftPulse by the PNG (`You [enabled gold]`), not only the gold summary (hole labels nest under seat glow); and tap picker SoftPulse twice when the first press leaves `0/5 selected` (LPT-75).
- Prefer `fresh --lesson … --open` when the walk must start at activity 0 —
  it now nulls `course/main.resume`, clears matching `currentLessonId`, and
  deletes open `courseAttempts` for that lesson (LPT-76). Do not hand-patch
  Firestore for resume when `fresh` is available.

## Ops (simulator, CLI, Jira)

- Cursor CLI over SSH / LaunchAgent needs `CURSOR_API_KEY` in
  `~/.live-poker-trainer/secrets.env`. Do not call `agent login`. The loop
  sets `AGENT_CLI_CREDENTIAL_STORE=memory` and clears a stuck
  `cursor-access-token` keychain item before each start so
  `errSecDuplicateItem` / `auth.refresh.persistFailed` cannot burn the run.
- Heartbeat during long worktree `flutter run`, validates, and Cloud
  Functions deploy; the stall watchdog kills a silent agent (tmux
  `deploy-LPT-*` / `refresh-LPT-*` count as alive). Launch builds with
  `tools/flutter_run_fast.sh` and hot-restart with
  `tools/flutter_hot_restart.sh` — both block and heartbeat for you, and
  a Dart-only worktree skips Xcode via the cached `Runner.app`. Bare
  `AwaitShell` / `sleep` while Xcode builds burns minutes and risks stall
  (LPT-72). Write coverage before long compiles when the ticket is
  already Done in Jira.
- Jira: `ATLASSIAN_EMAIL` + `ATLASSIAN_API_TOKEN` in that secrets file.
  `jira.py check` failure → `JIRA_UNAVAILABLE`. `create` prints
  `KEY<TAB>URL` — take column 1 only for `edit` / `get` / `comment`.
- Loop preflight is programmatic (claim → refresh → Dart VM → handoff
  JSON) before the machine SDK agent. At step 2 trust that VM; refresh
  only when switching builds. `dart_vm_ready` needs macOS-safe
  `[A-Za-z0-9_=-]`. One refresh + one retry then `SIM_NOT_READY` (often
  `pub get` Terminated: 15); do not rewrite refresh mid-run. Consecutive
  misses back off ~10 min.
- `refresh-simulator` must claim with `--pid $$`. Worktree validate uses
  `/tmp/flutter-$SLUG.log`; origin/main uses
  `/tmp/flutter-live-poker-trainer.run.log` (must be a normal file).
  When primary flutter dies during closeout, run `refresh-simulator.sh`
  — do not hand-roll tmux + `AwaitShell`. A stale VM URI above a newer
  `Launching…` is not ready, and a cached-app launch is not ready until
  its first `Restarted application` (`<log>.prebuilt` sidecar);
  `tools/flutter_log_ready.py` / `wait_flutter_vm.sh` handle both.

## Product judgment

- "Your two cards" and similar peeks must not show empty board slots when
  no board is in play for that beat.
- When the design record and a shipped screen disagree, the record (plus
  stakeholder brief) wins; file or reopen the ticket rather than
  "accepting" the screen as intentional chrome.

## Recent run notes

Short dated notes for context. Drop notes older than ~14 days when
trimming. Durable rules belong in the sections above, not only here.

- 2026-10-12: LPT-76 Best five explain Nice! `okFeedback` (same path as
  LPT-74); clear resume/`courseAttempts` before explain walks; deploy
  Functions before mini proof. LPT-75 kicker SoftPulse; LPT-73–71 Hint/
  SoftPulse; ManagePullRequest `skip_branch_prefix_check` for `fix/LPT-*`.
