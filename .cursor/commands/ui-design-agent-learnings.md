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
   `~/.live-poker-trainer/ui-agent-learnings-pending.md` — the **next**
   run's step 6 must fold it (or run `tools/fold_agent_learnings.sh ui`
   and ship `chore/ui-agent-learnings-<YYYYMMDD>`). Do not leave pending
   unfolder across many loops. Overflow past the 40-bullet cap goes to
   `docs/agents/ui-agent-run-memory.md`.
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
  `fix/LPT-NN-…` / `feature/LPT-NN-…`. On this Mac mini ui-agent loop prefer
  `gh pr create` / `gh pr merge` from make-change; only reach for
  ManagePullRequest when `gh` is unavailable — its `cursor/` prefix check
  burns minutes (LPT-390). When ManagePullRequest refuses a make-change
  branch for lacking `cursor/`, recreate with
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
  this Mac mini. Pick the open queue with `python3 tools/jira.py ui-queue`
  (never Jira `labels != grokbot` / `labels != needs-human` — those
  searches can hang 10+ minutes). File browser-validatable layout-only
  findings as `ui,grokbot,<area>` (no `ui-agent`); SoftPulse / Hint /
  hearts / randomization / deal timing / iOS-only stay on `ui-agent`.
  Never end a run (or let the loop spawn a new agent) when this run's
  filings are only `grokbot` — keep walking until you have a `ui-agent`
  KEY or every remaining surface is clean for Mac-mini work.
- Never hand-write coverage JSONL or `strftime(..., '%z')` timestamps
  (`+0530` breaks macOS Python 3.9 health repair). Use
  `python3 tools/ui_agent_coverage.py append …` in step 10.
- Never pipe `deploy-functions.sh` through `| tee … | tail` (masks the
  real exit). Run it directly (or via `tools/tee_exit.sh`). Concurrent
  deploys share a lock under `~/.live-poker-trainer/functions-deploy.lock.d`
  and prune dead `deploy-<pid>` worktrees — do not hand-delete a live one.
- Never edit the primary checkout (make-change worktrees only), invent
  GitHub owner/URLs from a person's name (`gh` only,
  `KC38/live-poker-trainer`), or let LaunchAgent `ensure`/`start`
  kill-session a live run-loop when the pid file is stale — recover the
  pid from the tmux session instead. Soft-stop clears STOP on the next
  `start`/`ensure`, runs `prepare_launcher` (SDK `npm ci`) before claiming
  the mini, and schedules `ensure` via a default-server tmux one-shot (not
  the dying `tmux -L ui-agent` pane; nohup fallback) after the
  soft-stopped loop exits (a plain background `&` died with the tmux
  pane on SIGHUP — 2026-10-13) so the next ticket does not wait on
  LaunchAgent `StartInterval` (use `kill`/`uninstall` to leave the loop
  down).
- Never `gh pr merge` a draft, and never `git push --delete` the ticket
  branch / remove the worktree until `mergedAt` is set (LPT-71: draft
  merge failed then branch delete closed #1676 — recover via local commit
  SHA, `gh pr reopen`, `gh pr ready`, then squash-merge). Prefer
  make-change's `gh pr create` → `gh pr ready` → `gh pr merge --squash`
  over ManagePullRequest (MCP create defaults to draft; LPT-508 burned a
  merge attempt on a draft).

## Prefer

- Prefer exact `agent_tap` labels from the screen (card Semantics `A♣`, not
  ASCII `Ac`). Broad needles like `Continue` can hit Home chrome; short
  codes can miss the card or open Hearts. Prefer
  `python3 tools/agent_tap.py back` (no `--text`) to dismiss modal bottom
  sheets (Hearts refill, legends) — a `tap --text Back` needle is often
  missing. Prefer `tester.element(finder)` / `tester.state<State>` over
  `tester.state<DealtCardReveal>` (needs a `State` subtype; LPT-97).
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
  Prefer reopening a Done `ui-agent` ticket that still reproduces over
  filing a near-duplicate.
- Prefer one lesson-content bug (fixed cards, stacked/enabled-empty Hint,
  Hint stuck under Oops/Nice! after a Hint press, multi-target or
  inconsistent SoftPulse, bad coach copy, hearts that do not spend or
  restore) or teach-by-doing gap over spacing chrome.   When SoftPulse golds
  every densified tile, check `_buildOutcomePhases` for a missing
  `guideRegion` (`null` SoftPulses all phases — LPT-424 Meet Calling
  Station; LPT-433 Observe narrow; LPT-505/506 LessonTableContext densify).
  Verify with Hint+`tree` before implementing: framed `_LessonChoiceStack`
  + `_framedDockPulseChoiceId` (e.g. Size with a message unguided) already
  SoftPulses only the first choice — close as no-repro (LPT-504); densify
  builders still need `guideRegion`. When fixing multi SoftPulse, update
  tests that assert `findsNWidgets(N>1)` on `glow-highlight` for that
  surface — they may have locked the bug (LPT-55).
  Ids in `lessonFrameSameConceptQuietIds` (e.g. guided-seven) stay SoftPulse
  off until Hint by design — judge Hint-reopened SoftPulse, not first-press
  gold (LPT-57). Quiet multi-press boards must report
  `remainingPressCount` from untapped targets even when SoftPulse/
  `showGuidance` is off after a wave closes — gating remaining on
  SoftPulse visibility leaves Hint disabled for presses 2+ (LPT-72
  `LessonSuitBoardTable`). After SoftPulse lands on explain, grep the sibling picker —
  blinds guided frames in `select_identify` still need `cuePuckLabel` (D/SB/BB),
  not only `LessonBlindsClockwiseTable` (LPT-69). Position labels
  `act-02-01-01-*` on `LessonTableStage` need the same `cuePuckLabel` + seat
  fallback — seat-only SoftPulse leaves D/SB pucks uncued (LPT-118). Puck
  SoftPulse needs an inflated hit box + `reserveLayout: true` or the glow
  clips inside a tight `SizedBox`. After Hint then a grade, read the dock bubble — Hint copy under
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
  Densified classify Hint (Hand families unguided/checkpoint) must name the
  remapped hero holes — `alignLessonActionCopy` falls through to
  `dealtLessonTableScene` when there is no action spot, or Hint keeps
  authored 76s / 72o (LPT-134). Open or fold catalog Oops may say
  `Seventy-two offsuit` (decade compound) while `_spokenStartingHand` is
  `seven-two offsuit` — both aliases must rewrite via
  `alignStartingHandCopy` or remapped trash still grades as 72o (LPT-164).
- Prefer a second open when judging card randomization (screenshot hole/board
  A vs B) and screenshot heart counts before/after a paid miss (and after
  Practice/refill) before claiming cards or hearts work. Read ranks from the
  latest PNG before tapping SoftPulse; a stale rank needle misses the gold
  card. Read PNGs you just captured — do not close from memory.
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
- Prefer `tools/flutter_run_fast.sh` / `flutter_hot_restart.sh` /
  `refresh-simulator.sh` over hand-rolled tmux `flutter run`. Trust
  refresh after hot-restart (it waits for Dart VM / cold-starts cached
  `Runner.app`). Re-judge Hint/SoftPulse after `origin/main` advances
  mid-walk — a stale Dart isolate can look like SoftPulse-off +
  Hint-disabled deadlock (how-pots before #1706). On How pots open-pot,
  wait until the felt deal settles before judging Hint SoftPulse — early
  Hint greys the button while `feltDealReady` is still false (LPT-84). On
  Xcode "No space left on device", run
  `python3 tools/disk_guard.py --min-free-gb 40` then retry once (LPT-61)
  — do not wipe primary DerivedData or `needs-human` on the first disk-full
  build. After patching guest `flutter.onboarding_draft_v1` on disk, prefer
  a full process restart — hot-restart keeps cached SharedPreferences so
  `dailyGoalMinutes` stays null and Lesson Complete still shows AMAZING
  (LPT-39). After the last Nice!, poll for Lesson Complete before CONTINUE.
- Prefer waiting until the target beat is settled before
  `<KEY>-validated.png` (not bootstrap spinner). On hole-card peeks, wait
  until the hero cards are face-up (not empty outlines) before `tap You`,
  and do not show empty board slots when no board is in play for that beat.
  On locked-start, capture the Open-previous / Retry gate and read Rex's
  bubble against the gold Open-previous CTA — Retry-only copy with that
  button is a bug (LPT-51). For board SoftPulse tickets, read the coach
  line first — unguided-mix is "Tap the community cards."; hole SoftPulse
  on guided/scaffolded is a different cue (LPT-68 closeout). Prefer
  `python3 tools/agent_tap.py wait-gold` after `openlesson` / deal settle
  (and wait for Nice! after the last explain tap) before taps or validated
  shots — early taps nomatch Home (LPT-79/97). Acting order explain can take
  ~7s before `gold SoftPulse:` names UTG; do not file SoftPulse-off from a
  1–2s tree (LPT-147).
- Prefer adopting `sim_lock_run_id` from
  `~/.live-poker-trainer/ui-agent-handoff.json` (then
  `simulator-lock.json`) when `$SIM_LOCK_RUN_ID` is unset in a
  cloud/machine shell — export it once and continue. Loop preflight already
  claimed + warmed the Dart VM; go to step 2 when handoff has
  `dart_vm_ready`. Clear Hint / SoftPulse before staging an invalid Best
  five for Undo proof so cyan matches the five taps.
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

- Prefer `fresh --lesson … --open` when the walk must start at activity 0 —
  it nulls `course/main.resume`, clears matching `currentLessonId`, and
  deletes open `courseAttempts` (LPT-76). Do not hand-patch Firestore for
  resume. On Best five SoftPulse closeout, judge seat glow by the PNG
  (`You [enabled gold]`); retap picker SoftPulse when the first press
  leaves `0/5 selected` (LPT-75).
- Prefer omitting `--log` on `agent_tap` / `agent_seed` after
  `flutter_run_fast.sh` / `flutter_hot_restart.sh` — they point
  `/tmp/flutter-iphone-13-mini.active.log` at the worktree session. Passing
  the primary `/tmp/flutter-live-poker-trainer.run.log` while the worktree
  owns the mini talks to the wrong VM (LPT-78).
- Prefer a Dart-side Hint / coach override (or `--no-cache` full rebuild)
  when a fix changes `assets/course/v2/catalog.json` — cached `Runner.app`
  via `flutter_run_fast.sh` hot-restarts Dart but can keep a stale asset
  bundle, so catalog-only Hint copy looks unfixed until Xcode rebuilds
  (LPT-327).
- Prefer flush/straight showdown remap templates with **five** suited cards
  in the made flush (board + holes) and rank span < 12 so `_remapSpotCards`
  can vary boards; a four-suited flush template always falls back to one
  fixed board (LPT-107 deal test). Postflop teach fingerprints must keep a
  made-pair bit — `HandClassifier` labels underpair+strong-draw as
  `strongDraw`, so a “missed” air template can otherwise remap to TT/QQ
  (LPT-367 multiway scaffolded). Prefer verifying gutshot/OESD templates
  with `HandClassifier.drawOuts` (four consecutive-looking ranks like
  A-J-T-9-8 are not a straight) before locking coach “four outs” copy —
  JT on A72 remapped as air under a gutshot ask (LPT-381). Split `HandClass.strongMade` with `isSet` + `distinctBoardPairingHoles` so top-two river templates never remap to a set (LPT-392).
- Prefer merging + Functions deploy before mini-proving a
  `gradeCourseResponse` / Nice! / `course_bank` sequence-id change — the
  worktree app still hits production until that deploy lands (LPT-74,
  LPT-107). When local `deploy-functions.sh` races GitHub Deploy Cloud
  Functions (HTTP 409 unable to queue), wait for local EXIT:0 — a
  concurrent Actions failure does not mean the merge SHA is undeployed if
  the local script finished Successful update for `submitCourseStep` /
  course graders (LPT-199).
- Prefer treating `tools/main_matches_validated.sh` `differs` on
  `assets/course/v2/catalog.json` (or other concurrent-main files) as a
  required origin/main re-walk, not a failed fix — LPT-173 squash matched
  the worktree lib change while catalog moved on main.
- Prefer `villainSeatCount: 0` on conceptual outcome scenes that do not
  deal holes (effective-stack / depth tiles; default `1` paints a decoy
  Them pair — LPT-220). Prefer framed `LessonTableStage` with
  `lessonNineMaxVillainCount` + `seatNames: Seat N` when coach copy names
  seat numbers on a nine-handed ask (LPT-240); densify `blindsSeats`+
  `numberSeats` covers the no-frame path.
- Prefer extending `alignLessonTableCopy` (board+hole card tokens and
  spoken rank/suit words) when densified isomorphic remap leaves catalog
  prompts / Nice! / Oops naming the template flop — frame speech alone is
  not enough if grade lines still say “Pair of kings” (LPT-261).
- Prefer waiting until Continue is enabled in `tree` after multi-press
  explain grades (Clean→Dirty→Price, Raise→Barrel→Count, and other ladder
  Nice!) before tapping Continue or SoftPulse validated shots — an early
  Continue nomatches and can capture the Nice! dock instead of densify
  gold (LPT-274, LPT-462 closeout). Prefer `tap --text Continue` over
  `agent_tap next` on a Nice! dock — `next` can report ok while the
  lesson stays on Nice! and burn minutes in a wait-gold loop (LPT-502).
- Prefer extending `selectIdentifyDensifiedCoachLine` (not only
  `_coachText`) when a densified select_identify ask still shows catalog
  + "Tap the best answer." in the frame bubble — framed speech reads that
  helper before `resolveLessonCoachPrompt` (LPT-221, LPT-279, LPT-343
  Close the river checkpoint, LPT-412 SPR guided, LPT-636 Recognize
  capped). Densified lines need a pick/tap verb so
  `withLessonTapInstruction` does not append the generic footer. A local
  `_coachText` string alone leaves framed speech on catalog.
- Prefer densify tile titles (`Call 10`, `Suited conn`, `Call`) over
  shared gold fragments like `chips` / suit-only glyphs when advancing
  SoftPulse asks — a `chips` needle can hit the wrong Call-price column
  and burn hearts (LPT-634).

- Prefer `tools/flutter_run_fast.sh --checkout PRIMARY` when `refresh-simulator.sh` aborts on an untracked primary file (e.g. `test/ui/course/_content_agent_probe_*.dart` from a content-agent) — do not discard that dirt or `needs-human` the ticket; origin/main Dart still hot-restarts (LPT-407).
- Prefer `rg '<<<<<<<|=======|>>>>>>>'` on conflicted files after a merge resolution **before** `git commit` — an earlier StrReplace can leave markers in HEAD while the working tree looks clean until the next edit (LPT-520).

## Ops (simulator, CLI, Jira)

- Secrets in `~/.live-poker-trainer/secrets.env`: `CURSOR_API_KEY` for CLI /
  LaunchAgent (do not `agent login`; loop uses
  `AGENT_CLI_CREDENTIAL_STORE=memory` and clears a stuck
  `cursor-access-token` keychain item so `errSecDuplicateItem` /
  `auth.refresh.persistFailed` cannot burn the run);
  `ATLASSIAN_EMAIL` + `ATLASSIAN_API_TOKEN` for Jira — `jira.py check`
  failure → `JIRA_UNAVAILABLE`; `create` prints `KEY<TAB>URL` (column 1
  only for `edit` / `get` / `comment`).
- Heartbeat during long worktree `flutter run`, validates, `flutter test` /
  analyze, and Cloud Functions deploy — including immediately before and
  after long `test-LPT-*` / `analyze-LPT-*` tmux sessions (LPT-240: lock
  freed mid-suite while tests were quiet; reclaim with `sim_lock.py claim`
  then continue). If heartbeat / guard prints FREE / not the holder mid-run,
  reclaim immediately and keep the new `SIM_LOCK_RUN_ID` — do not keep
  driving the mini with a stale preflight id (LPT-637). The stall watchdog kills a silent agent (those named
  tmux sessions count as alive, and a growing ui-agent run log also
  counts — machine SDK streams can skip heartbeats for >10 min). Launch
  builds with `tools/flutter_run_fast.sh` and hot-restart with
  `tools/flutter_hot_restart.sh` — both block and heartbeat for you, and
  a Dart-only worktree skips Xcode via the cached `Runner.app`. Bare
  `AwaitShell` / `sleep` while Xcode builds burns minutes and risks stall
  (LPT-72). Prefer named `test-LPT-*` tmux for long suites over anonymous
  sessions — run them with `tools/tee_exit.sh /tmp/test-LPT-….log flutter
  test …` (same for `analyze-LPT-*` / `dart analyze`) so `EXIT:N` is the
  command status and `/tmp/test-LPT-….done` appears only when finished;
  block with `tools/wait_done.sh /tmp/test-LPT-….done` (heartbeats the
  lock; optional `--timeout N` / `--purpose TEXT` in any order) — never
  bare AwaitShell/sleep, never grep the pane for `EXIT:` (send-keys text
  itself contains `EXIT:$?` and false-kills mid-suite — LPT-391). Prefer
  `tee_exit` writing the numeric code into `.done`; `wait_done` also
  accepts `DONE` / `DONE:N` / `EXIT:N` (LPT-410 hung on a bare `DONE`
  marker). Do not pass `--purpose` as the positional timeout (LPT-462:
  bash arithmetic treated it as `--purpose` decrement). Bare
  `cmd | tee; echo EXIT:$?` also masks failures as 0 (LPT-367). Write
  coverage before long compiles when the ticket is already Done in Jira.
- Loop preflight is programmatic (claim → refresh → Dart VM → handoff
  JSON) before the machine SDK agent. At step 2 trust that VM; refresh
  only when switching builds. `dart_vm_ready` needs macOS-safe
  `[A-Za-z0-9_=-]`. One refresh + one retry then `SIM_NOT_READY` (often
  `pub get` Terminated: 15); do not rewrite refresh mid-run. Consecutive
  misses back off ~10 min. `refresh-simulator` must claim with `--pid $$`.
  Worktree validate uses `/tmp/flutter-$SLUG.log`; origin/main uses
  `/tmp/flutter-live-poker-trainer.run.log` (must be a normal file). When
  primary flutter dies during closeout, run
  `REFRESH_ALLOW_HOLDER=1 …/refresh-simulator.sh` (you hold the
  ui-design-agent lock) — do not hand-roll tmux + `AwaitShell`. A stale
  VM URI above a newer `Launching…` is not ready, and a cached-app launch
  is not ready until its first `Restarted application` (`<log>.prebuilt`
  sidecar); `tools/flutter_log_ready.py` / `wait_flutter_vm.sh` handle both.

## Product judgment

- Lesson walks must exercise Hint (one at a time), one gold SoftPulse,
  coach mood/copy that names the felt, hearts lose/restore, and a second
  attempt for card randomization — not only Continue through the happy
  path. Hole-card peeks must not show empty board slots when no board is
  in play. Every ticket needs a current-issue screenshot and a validated
  origin/main closeout shot; text-only closeouts are not enough. When the
  design record and a shipped screen disagree, the record wins — file or
  reopen rather than accepting the screen as intentional chrome.

## Recent run notes

- 2026-10-13 LPT-641: loop rewrote `ui-agent-handoff.json` / reclaimed the mini while this agent was mid-implement (`purpose: agent starting`). When `heartbeat`/`guard` print not-the-holder, stop driving the mini until `sim_lock.py claim` succeeds again (LPT-637); do not force-release the loop holder. Keep implementing offline tests in the worktree meanwhile.

Short dated notes for context. Drop notes older than ~14 days when
trimming. Durable rules belong in the sections above, not only here.
