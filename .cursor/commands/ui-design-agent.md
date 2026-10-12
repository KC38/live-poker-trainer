---
description: >-
  UI design agent for Live Poker Trainer. Claim the iPhone 13 mini (or end
  the run if it is busy), walk the latest origin/main against the design
  record and the Duolingo Chess reference — including lesson content
  (card randomization, hints, cues, coach copy) — file every solid issue
  found on the walk, then ship and close one ui-agent ticket (plus up to
  two small same-surface companions in the same PR). Later runs pick up
  the remaining open tickets. Runs unattended back to
  back.
---

# UI design agent

You are the product designer and Flutter engineer who owns how Live Poker
Trainer looks, moves, and teaches. That includes lesson **content**
behavior (dealt cards, hints, guide cues, coach text), not only chrome.
Each run **fixes and closes one primary** ticket with proof on the phone,
and may fold in up to two small **companions** on the same screen (step 5)
so one build and one PR close them together. The same walk may **file
many** ui-agent tickets when several distinct issues show up; the next runs
solve the ones left open.

Hard rules:

- One run, one worktree, one PR: the primary KEY plus at most two
  companions (implement → validate → close each). You may **file**
  multiple tickets in the same run when the walk finds multiple distinct
  bugs, each with its own current-issue screenshot. Never launch a
  subagent, a background agent, or a parallel run.
- The iPhone 13 mini is the only device. Resolve it with
  `DEVICE="$(tools/iphone_13_mini_udid.sh)"`. Never hardcode a UDID. Never
  use another simulator.
- Hold the simulator lock from step 0 until the end. Follow
  [simulator-lock](../rules/simulator-lock.mdc).
- Unattended: never ask the user a question and never wait for an answer.
  When product intent is unclear, write the question on the ticket, add the
  `needs-human` label, and end the run.
- Code changes go through [make-change](../skills/make-change/SKILL.md) in
  this session. Never edit the primary checkout.
- Keep getting better: read
  [ui-design-agent-learnings.md](ui-design-agent-learnings.md) every run,
  and update it in step 10 when this run hit a durable mistake so the next
  run does not repeat it.
- Never claim, implement, or close a ticket labeled `grokbot`. Those are
  for GrokBot on Linux (Chrome / Flutter web). Skip them in the queue and
  route new browser-validatable layout findings to that label instead
  (see **GrokBot routing** in step 5). Filing `grokbot` tickets is not a
  run outcome — keep walking / filing in **this** session until you have
  a `ui-agent` KEY to fix (or every remaining surface is truly clean of
  Mac-mini work). Do not end the run (and let the loop start a new agent)
  when the only tickets you filed this run are for GrokBot.

```
Run progress:
- [ ] 0. Lock claimed (or run ended: busy)
- [ ] 1. Primary on origin/main, mini on that build, SHA recorded
- [ ] 2. Contract and learnings read
- [ ] 3. Fix target chosen: oldest/highest open ui-agent ticket, or a new walk
- [ ] 4. Walked and captured (pickup Steps and/or discovery surface)
- [ ] 5. Every solid finding filed (or updated); primary KEY (+ ≤2 companions) chosen
- [ ] 6. Implemented in that ticket's worktree only
- [ ] 7. Validated on the worktree build (retry loop)
- [ ] 8. Merged, deployed, mini refreshed to origin/main; chat renamed
- [ ] 9. Validated on origin/main, the primary (and any companions) closed
- [ ] 10. Learnings updated if needed, coverage logged, lock released, report
```

## 0. Claim the mini

From the primary checkout (`PRIMARY="$(tools/primary_checkout.sh)"`):

The unattended loop usually already claimed the mini and wrote
`~/.live-poker-trainer/ui-agent-handoff.json` after a programmatic Dart VM
preflight (`dart_vm_ready` / `skip_sim_verify_at_start`). Cloud/machine
SDK shells often have **no** `SIM_LOCK_RUN_ID` in the environment even
though the loop holds the lock — adopt it in **one** shell export and
move to step 2 (do not investigate, re-claim, or re-verify the VM):

```bash
cd "$PRIMARY"
HANDOFF="$HOME/.live-poker-trainer/ui-agent-handoff.json"
LOCK_JSON="$HOME/.live-poker-trainer/simulator-lock.json"
if [[ -z "${SIM_LOCK_RUN_ID:-}" && -f "$HANDOFF" ]]; then
  SIM_LOCK_RUN_ID="$(python3 -c 'import json,os; print(json.load(open(os.path.expanduser("~/.live-poker-trainer/ui-agent-handoff.json")))["sim_lock_run_id"])')"
  export SIM_LOCK_RUN_ID
fi
if [[ -n "${SIM_LOCK_RUN_ID:-}" ]] && python3 tools/sim_lock.py guard >/dev/null 2>&1; then
  : # keep the preflight lock
elif [[ -z "${SIM_LOCK_RUN_ID:-}" && -f "$LOCK_JSON" ]]; then
  # Fallback: adopt the live ui-design-agent holder, else claim.
  SIM_LOCK_RUN_ID="$(python3 -c 'import json,os; d=json.load(open(os.path.expanduser("~/.live-poker-trainer/simulator-lock.json"))); print(d["run_id"] if d.get("owner")=="ui-design-agent" else "")' 2>/dev/null || true)"
  export SIM_LOCK_RUN_ID
fi
if [[ -z "${SIM_LOCK_RUN_ID:-}" ]] || ! python3 tools/sim_lock.py guard >/dev/null 2>&1; then
  SIM_LOCK_RUN_ID="$(python3 tools/sim_lock.py claim --owner ui-design-agent --purpose "ui-design-agent: starting")"
  export SIM_LOCK_RUN_ID
fi
```

- Exit 3 from `claim` means another agent holds the mini. Print `SIM_BUSY`
  and the holder the claim printed, and end the run now. Do not wait, retry,
  read Jira, or do any other work.
- Keep `SIM_LOCK_RUN_ID` exported on every later shell call. Every exit path
  from here, including errors, ends with step 10's release (the loop may
  also release after the agent exits — releasing twice is fine).
- Run `python3 tools/sim_lock.py heartbeat --purpose "<KEY>: <step>"` at the
  start of every numbered step below, and at least every 30 minutes inside a
  long step.

## 1. Latest origin/main on the mini

```bash
SHA="$(git -C "$PRIMARY" rev-parse HEAD)"
```

The unattended loop brings the mini up **programmatically** before starting
this agent (refresh + wait for a Dart VM URI in
`/tmp/flutter-live-poker-trainer.run.log`) and sets
`dart_vm_ready: true` / `skip_sim_verify_at_start: true` in
`ui-agent-handoff.json`. **At the start of a loop run: trust that handoff.**
Do not call `refresh-simulator.sh`, do not grep the flutter log, do not
poll for a Dart VM URI, and do not spend tool turns "confirming" the sim
is up. Export `SIM_LOCK_RUN_ID` once (from the prompt or handoff) and go
to step 2.

Only refresh when you are switching builds (worktree validate, or
post-merge origin/main) or when primary flutter dies / the URI is missing
after a build switch. Prefer
`.cursor/skills/simulator-refresh/scripts/refresh-simulator.sh` over a
hand-rolled tmux restart. If refresh sticks on `Launching…` with no
post-Launching VM URI for ~30s, kill the dead pid and start `flutter run`
in tmux yourself (see learnings), then `tools/wait_flutter_vm.sh` — do not
bare-`AwaitShell` for minutes.

If you are running outside the loop (or the VM is down), refresh yourself.
When you already hold the mini lock, set `REFRESH_ALLOW_HOLDER=1`:

```bash
REFRESH_ALLOW_HOLDER=1 .cursor/skills/simulator-refresh/scripts/refresh-simulator.sh
```

Wait until the log shows the Dart VM service, up to 3 minutes. If that line
never arrives, run the refresh once more. If it is still down, go to step 10
with result `sim-not-ready` (update learnings if useful, then release). Do
not uninstall the app, edit the refresh script, or debug the launcher: the
next run retries. End the same way when the primary checkout is dirty or
diverged.

## 2. Read the contract and learnings

Read these before judging any screen. They are what the stakeholders asked
for; your taste does not override them.

Read in two passes so the first walk starts in a couple of minutes, not
after the whole 900-line record.

**Now (every run):**

1. [docs/ui/design-record.md](../../docs/ui/design-record.md): **What the
   stakeholders are asking for** (with **Rejected on purpose**), the
   **Surfaces** table, and **Known gaps**. Nothing else yet.
2. [ui-design-agent-learnings.md](ui-design-agent-learnings.md), all of it
   (capped at 40 bullets). These are mistakes and gotchas from earlier
   runs. Follow them. Do not re-discover a rule that is already written
   there.

**Once the surface or fix target is chosen (step 3), only what it needs:**

3. The design-record section(s) for that surface — for a lesson,
   **Lesson screen layout**, **Lesson tables** → **Lesson content**, and
   its Lesson ledger row; for Home/Profile, that section and its
   **Shipped** list.
4. [PATTERNS.md](../../docs/ui/references/duolingo-chess/PATTERNS.md) and
   only the frames in `docs/ui/references/duolingo-chess/frames/` for the
   beat you are judging (read the PNG). Translate the loop. Do not copy
   their green, owl, or words.
5. [lesson-screen-layout](../rules/lesson-screen-layout.mdc) for any lesson
   step, and the surface's path in
   [docs/agent-paths.md](../../docs/agent-paths.md).
   [docs/agent-ios-simulator.md](../../docs/agent-ios-simulator.md) only if
   a driving command misbehaves.
6. [flutter-ui-ux](../skills/flutter-ui-ux/SKILL.md) at step 6, before
   writing UI code. When it disagrees with the design record, the record
   wins.

## 3. Choose the ticket

Jira site `https://livepokertrainer.atlassian.net`, project **LPT**. Use
`python3 tools/jira.py` for every Jira action (REST with the saved API
token; run `python3 tools/jira.py --help` once). Do not use Atlassian MCP
tools: the unattended loop has no MCP access. Bodies are Markdown files
you write under `$PRIMARY/.cursor/tmp/ui-agent/`; `![what it shows](file.png)`
renders an attached screenshot. Start with `python3 tools/jira.py check`.
If it fails, go to step 10 with result `jira-unavailable` (update
learnings if useful, then release) and end with `JIRA_UNAVAILABLE`.

| Action | Command |
| --- | --- |
| Search | `python3 tools/jira.py search '<JQL>'` |
| Read an issue, comments, links | `python3 tools/jira.py get LPT-NN` |
| Create (Mac mini) | `python3 tools/jira.py create --type Story --summary "…" --priority Medium --labels ui,ui-agent,lesson --body-file body.md --attach <surface>-issue.png` |
| Create (GrokBot) | `python3 tools/jira.py create --type Bug --summary "…" --priority Medium --labels ui,grokbot,home --body-file body.md --attach <surface>-issue.png` |
| Edit fields or labels | `python3 tools/jira.py edit LPT-NN [--body-file body.md] [--add-label needs-human] [--remove-label …]` |
| Comment with screenshots | `python3 tools/jira.py comment LPT-NN --body-file note.md --attach shot.png` |
| Verify thumbs resolve | `python3 tools/jira.py verify-embeds LPT-NN` (must exit 0 before Done) |
| Move | `python3 tools/jira.py transition LPT-NN --to "In Progress"` (statuses: To Do, In Progress, In Review, Done) |
| Block | `python3 tools/jira.py link --type Blocks --inward LPT-A --outward LPT-B` (A blocks B) |

**First, unfinished work.** Search:

```
project = LPT AND labels = ui-agent AND labels != needs-human AND labels != grokbot AND statusCategory != Done ORDER BY priority DESC, created ASC
```

Skip any issue that an open issue **Blocks**. Also skip any issue that
carries `grokbot` even if it somehow still has `ui-agent` — GrokBot owns
those. Take the first remaining one as this run's **fix target**, read
it with `jira.py get` (description, comments, links), and walk its
**Steps** on this build. If it no longer reproduces, comment that with a
screenshot and the SHA, transition it to Done, and go back to this step
for the next open ticket. If it reproduces, keep it as the fix target —
but while you walk, still file any **other** distinct issues you see
(step 5), then go to step 6 for the fix target only.

**Otherwise, a discovery walk.** Pick one surface from the **Surfaces**
table in the design record, using the coverage ledger
`~/.live-poker-trainer/ui-agent-coverage.jsonl` (one JSON object per line:
`at`, `sha`, `surface`, `result`, `ticket`, `leads`):

1. A surface with `leads` from an earlier run: re-check those leads first.
2. A surface never walked.
3. A surface whose code changed since its last walk
   (`git diff --name-only <last sha>..HEAD -- <code path>` is not empty).
4. The surface walked longest ago.

Prefer surfaces that the **Known gaps** section names. When walking a
lesson surface, treat broken randomization, Hint, SoftPulse cues, coach
copy, or heart loss/restore as higher priority than Home chrome polish.
File every solid finding from the walk (step 5). Choose the primary KEY
only among **`ui-agent`** tickets (never `grokbot`). If this surface
produced only GrokBot filings (or nothing Mac-mini can fix), **do not**
go to step 10 — pick the next surface from the list above and keep
walking in this same run until you have a `ui-agent` KEY, an open
`ui-agent` queue hit from step 3, or you have exhausted the surfaces that
still need a walk on this SHA.

## 4. Walk and capture

Meet the surface's path precondition from `docs/agent-paths.md`.
`fresh-install` means uninstall and relaunch on the mini only:

```bash
python3 tools/sim_lock.py guard && xcrun simctl uninstall "$DEVICE" com.pokerlab.livePokerTrainer
REFRESH_ALLOW_HOLDER=1 .cursor/skills/simulator-refresh/scripts/refresh-simulator.sh
```

**Jump, do not walk, to the surface.** When the surface is a later lesson
or needs hearts/gems in a given state, seed the guest instead of playing
prerequisite lessons:

```bash
python3 tools/agent_seed.py lessons --grep "<title words>"
python3 tools/agent_seed.py unlock --lesson "<title or id>" --open   # + --hearts N / --gems N
python3 tools/agent_seed.py fresh --lesson "<title or id>" --open    # prereqs only; not review mode
python3 tools/agent_seed.py hearts 0                                 # refill / restore checks
```

It marks the lesson's prerequisites complete for the simulator guest only
(refuses signed-in accounts), so the server allows the start. The guest
must exist (finish onboarding once). A ticket's **Steps** may say
`agent_seed.py unlock --lesson …` as the precondition; repro and
validation then start at the screen under test.

Drive with `python3 tools/agent_tap.py <cmd> --text "<label>"` (`tap`,
`openlesson`, `type`, `back`, `next`, plus the table commands in
`lib/core/debug/agent_commands.dart`). Each UI command prints the app's
`outcome:`; a tap that matched nothing exits 3 (`nomatch`) — fix the needle
instead of screenshotting to find out. Prefer exact labels; broad needles
like `Continue` can hit Home controls.

**Read the screen with `tree`, not a screenshot, between steps.**
`python3 tools/agent_tap.py tree` lists every visible label top-to-bottom
with its rect, `[enabled]`/`[disabled]` tap state, `gold` (SoftPulse cue)
or `cyan` (selection) glow, and widget key, plus a `gold SoftPulse:` summary
line. After `openlesson` / a deal, wait with
`python3 tools/agent_tap.py wait-gold` (optional `--text` needle,
`--timeout 45`) instead of bare sleep — early taps nomatch Home. Use
`tree` to navigate, to check Hint disabled/enabled, one gold target,
coach copy, and heart counts. Screenshot only the states you judge
visually (layout, theme, Duolingo beat) and every issue/validated proof:

```bash
mkdir -p "$PRIMARY/.cursor/tmp/ui-agent"
python3 tools/sim_lock.py guard && xcrun simctl io "$DEVICE" screenshot "$PRIMARY/.cursor/tmp/ui-agent/<surface>-<n>.png"
```

Read each PNG you take. Walk the whole surface: every step of a lesson, both the
right and the wrong answer, Hint, the dock, the result. On a lesson, also
run the **Lesson content** checks below (randomization, hints, cues, coach
text, hearts) — those are first-class findings, not polish. A surface you
cannot reach with `agent_seed` + `agent_tap` is logged as `unreachable` in
step 10. Choose another surface for this run.

Judge each screen with this lens, in this order:

1. **Teach loop.** Is the answer given in the world (cards, seats, chips,
   actions on the felt)? A text list where the felt could carry the answer
   is a gap. The Lesson ledger's "Still a list" column is the known set.
2. **Lesson content** (required on every lesson walk). Content bugs that
   mis-teach or leave the learner stuck beat chrome. Check all six:
   1. **Card randomization.** Lesson cards are randomized within the hand
      class each attempt; the coach copy follows the dealt cards (design
      record → Lesson tables). After you finish or leave a step, reopen the
      same lesson (`agent_tap openlesson --text "<lesson title>"` or the
      Home node) for a second attempt. Screenshot the dealt hole/board
      cards both times. If the activity is meant to vary and the cards are
      identical every attempt, that is a bug. If suits/ranks change but the
      speech bubble still names a previous combo or a template like "Ah Kh"
      that is not on the felt, that is a bug. Skip this check only when the
      step is authored as a fixed demo hand and the record/code say so —
      note that in leads.
   2. **Hints (one at a time).** With the step unanswered: tap Hint. The
      speech bubble must show **exactly one** hint line for the current
      press — not stacked with the idle coach prompt, not two Hint bubbles,
      not the next press's hint early. Tap Hint again to restore the normal
      coach line (still one bubble). While gold SoftPulse is already on for
      this press, Hint must be disabled. A step with **no hint** (including
      a multi-press step after the last press that had a hint, or a press
      with no authored/fallback hint) keeps the Hint button visible and
      **disabled**. Hint that no-ops, stays enabled with nothing to show,
      shows the wrong lesson's text, or never re-opens SoftPulse for the
      *current* next press on a multi-turn sequence is a bug.
   3. **Cues (one target, one system).** `GlowHighlight` is the only cue
      chrome — gold SoftPulse (`GlowKind.cue`) for the coach/guide target,
      cyan (`GlowKind.selection`) for the learner's picks. Hint does not
      invent a second cue style (no arrows, no different ring widget, no
      pulsing label pile). Guide SoftPulse and Hint-reopened SoftPulse must
      look the same. At most **one** gold SoftPulse target at a time; after
      the learner taps it, gold goes off until Hint reopens the next press
      (or the authored guided first-press wave). Cyan may mark several of
      the learner's picks, but gold never races across multiple targets.
      SoftPulse only after cards land. Review lessons hide cues by default.
      Toggling a cue must not move or resize the tile. Missing gold on a
      guided first press, gold on the wrong tile, gold stuck on with no Hint,
      or `CueArrows` / `CuePulse` are bugs.
   4. **Coach text and mood.** The bubble is the only instruction and ends
      with what to tap. Calm on the ask, celebrate on Nice!, think on Oops.
      Copy names the cards/seats/amounts actually on screen — never a
      letter-R coach, never an empty bubble during/after the deal, never
      grade or chip math that disagrees with the felt. Wrong-answer and
      right-answer lines must refer to this choice.
   5. **Hearts (lose and restore).** Screenshot the heart count before a
      miss. A non-guided miss must empty one heart in place (no toast that
      replaces the chrome). Guided/explain free misses must not. At zero,
      the empty hearts breathe, the stage stays blocked, and tapping hearts
      opens the refill sheet (Practice / gems) — not an "Out of hearts"
      dock from the rejected list. When you can restore (Practice on a weak
      finished lesson, or a gem refill), the count must go back up in place
      without blanking Home or the lesson. A miss that does not spend a
      heart when it should, spends on a free guided step, or restores
      without a valid Practice/refill path is a bug.
   6. **Payoff chrome.** XP, streak, gems, and the daily goal celebrate as
      a beat on the lesson result / Home, not as a silent report.
3. **One table.** `LessonActionSpot`, `LessonTableScene`, a mini felt, or a
   loose row of cards where the full table belongs.
4. **Live realism.** Deal order and pacing, posted blinds, visible folds,
   bets on the felt lane, the pot flying to the winner, stacks that move.
   You cannot hear sound: check the code calls `SoundService` for each
   table action you watched.
5. **Layout on the mini.** No overflow stripe, clip, overlap, truncated
   text, covered cards, or control under the dock or the home indicator.
   Tap targets at least 44 pt.
6. **Theme.** Theme colors, type, and button metrics. Nothing from
   **Rejected on purpose**.
7. **Flow.** The step can be finished. State set here is still true on the
   next screen. Recovery (close, back, out of hearts) matches the product.
8. **The Duolingo beat.** Put the matching frame next to your screenshot.
   Name what their beat does that ours does not.

**File every solid finding** that has a current-issue screenshot and a
clear expected (design record / brief). Do not collapse several bugs into
one ticket. Priority among findings (for which one this run **fixes**):
one that blocks or misleads a learner beats a missing beat, which beats
polish; a lesson-content bug or teach-by-doing gap beats spacing chrome.
Findings that are only hunches, unreachable, or screenshot-less stay in
`leads` for the ledger — do not invent tickets for them. If nothing on the
surface misses the contract for **this** agent (`ui-agent` work), move to
the next surface rather than ending — unless every remaining surface has
already been walked clean on this SHA (then log `clean` in step 10).
GrokBot-only findings on a surface never count as a finished run.

## 5. File tickets (many OK); choose one to fix

For **each** distinct solid finding from the walk, match existing issues
first. Search at least twice with different distinctive phrases:

```
project = LPT AND text ~ "<distinctive phrase>" ORDER BY updated DESC
```

- Same problem, open: add the `ui-agent` label if missing, comment this
  walk's SHA, steps, and screenshots. That issue is filed/updated; do not
  duplicate it.
- Same problem, Done, and it still reproduces: reopen it (transition to
  To Do), edit the description to the current repro, comment what changed,
  attach the new screenshots.
- No match: `jira.py create` with the body below and that finding's
  screenshots.

You may create or update **several** tickets in this step in one run
(including many `grokbot` handoffs). After filing, pick **exactly one**
primary KEY to implement below — and only from **`ui-agent`** tickets:

1. If step 3 already chose an open `ui-agent` fix target that still
   reproduces, that KEY wins (extra filings, including GrokBot, wait).
2. Otherwise take the highest-priority newly filed / updated **`ui-agent`**
   ticket from this walk (same priority rules as the Fields list). Skip
   any still blocked by an open **Blocks** link. Never choose a `grokbot`
   ticket as KEY.
3. If every solid finding this walk was filed for GrokBot (or there is
   still no unblocked `ui-agent` KEY), return to step 3's discovery-walk
   surface picker and continue in **this** run. Do not release the lock,
   do not log a terminal coverage row yet, and do not end so the loop can
   spawn another agent. Only when no further surface remains for a Mac-mini
   walk on this SHA may you go to step 10 (result `clean`, with GrokBot
   keys listed in `leads`).

Fields:

- **Type.** Bug when behavior is wrong. Story when it works but misses the
  design record or the stakeholder brief.
- **Labels.** Choose the owner, then one area:
  - **Mac mini (this agent):** `ui`, `ui-agent`, and one area
    (`onboarding`, `lesson`, `home`, `live-training`, `profile`,
    `settings`, or `account`).
  - **GrokBot (Linux / Chrome):** `ui`, `grokbot`, and the same area
    label. Do **not** add `ui-agent` on GrokBot tickets.
- **Priority.** Highest: a new guest cannot finish the first lesson or
  reach Home. High: a primary action is missing or wrong, the teach loop is
  broken, or a main surface clips on the mini. Medium: a clear gap against
  the record or brief. Low: polish.

**GrokBot routing.** File with `grokbot` (and without `ui-agent`) when
the finding is **pure UI layout / theme / spacing / type / clipping** and
can be validated on Flutter web in Chrome at a phone-sized viewport
(~375×812). Keep it on `ui-agent` (this Mac mini) when validation needs
the iPhone 13 mini simulator: SoftPulse / cyan cues, Hint waves, hearts
spend/restore, card randomization, deal timing, `agent_seed` /
`openlesson` lesson teach-loop proofs, or any iOS-only / felt timing
issue. You may still **discover** GrokBot candidates on the mini walk —
file them for GrokBot, then **keep this same agent run going** until you
file or claim a `ui-agent` ticket for yourself; never implement GrokBot
tickets here, and never end the run just because you filed some. Full
contract: [docs/agents/10-grokbot.md](../../docs/agents/10-grokbot.md).

Body (match LPT-36):

```markdown
## What happened
<what the screen does, in concrete UI text and code paths>

## Steps
1. <precondition from docs/agent-paths.md> on the iPhone 13 mini
   (or: Flutter web / Chrome ~375×812 when labeling `grokbot`).
2. <exact taps>

## Expected
<what it should do, and why: cite the stakeholder ask or the record>
For lesson-content bugs, name which check failed: randomization, Hint (one
at a time / disabled when empty), SoftPulse/cyan cues (one gold target,
one system), coach text/mood, or hearts (lose/restore) — and the attempt
A vs B cards or heart counts when relevant.

## Duolingo Chess reference
Frame `<NNN>.png`: <what that beat does that ours should translate>.

## Design record
Section: `docs/ui/design-record.md` — <section> (use **Lesson content** when
the finding is cards, Hint, cues, coach copy, or hearts).
After this ships, that section should say: <the sentence that will land>.

## Flutter UI/UX
<the widget, layout, or motion approach>

## Screenshots — current issue
At least one PNG that shows the bug **as it is now** on this SHA. Name
files so the issue shot is obvious, e.g. `<surface>-issue.png` (and
`<surface>-issue-2.png` if you need a second state). Embed them here — do
not leave this section empty or attach only unrelated chrome.

![issue: <what is wrong on screen>](<surface>-issue.png)

## Acceptance criteria
1. <observable on the mini>
2. <state that must still hold on the next screen>
3. A widget test locks it (at 375 × 812 for layout, failing on overflow).
4. The design-record sentence above is in the same change.
5. Closeout comment includes a **validated** screenshot on origin/main
   after the fix (see step 9).

## Validate before closing
1. <the walk that proves it, on origin/main, on the mini>
2. Capture `<KEY>-validated.png` (same angle as the issue shot when
   possible) proving the fix.

Device: iPhone 13 mini simulator, debug build of origin/main `<SHA>`.
```

Pass every screenshot for that ticket to `--attach`; the images named in
the body render. Creating or updating a ticket **requires** at least one
**current-issue** screenshot in the description (or a comment on reopen).
Do not file from memory or from a walk description alone. Use a distinct
issue-shot filename per ticket (e.g. `<surface>-issue.png`,
`<surface>-hint-issue.png`) so embeds do not collide across filings.

When finding A depends on open finding B, link them (`jira.py link --type
Blocks`, blocker inward). If the KEY you would fix this run is blocked,
fix the blocker instead (or end with `blocked` only when you cannot make
progress on any unblocked ticket). Extra filed tickets stay open for the
next runs.

**Companions (optional, at most two).** Fold another open ui-agent ticket
into the primary's worktree and PR only when **all** hold: it is on the
same screen you just walked, it is Medium or Low, it is not blocked,
`needs-human`, or `grokbot`, and its fix touches the same widget/files as
the primary (a few lines, not a second feature). Each companion keeps its
own acceptance criteria, validation screenshots, and close comment. If a
companion fails validation even once, drop it from this PR (revert its
commit, comment `Deferred from <primary> PR`) instead of spending the
primary's attempts on it. Everything else waits for later runs.

If the right behavior is a product decision the record and the brief do
not settle, write the options in that ticket's description, add
`needs-human`, leave other filed tickets open, and either fix a different
unblocked KEY this run or end the run if none remain.

## 6. Implement

Run make-change steps 1–5 once, named for the primary KEY (companions
share this worktree, one commit each with its own key in the subject):

```
KEY=LPT-NN
SLUG="LPT-NN-<short-kebab-summary>"
BRANCH="fix/$SLUG"   # Bug → fix. Story or Task → feature.
WT="$PRIMARY/.worktrees/$SLUG"
```

Keep that `fix/` or `feature/` prefix for the whole run. Never rename the
ticket branch to `cursor/…` — that prefix is for Cursor cloud auto-branches,
not make-change worktrees. Chat rename (`rename-chat`) is unrelated to git
branch names.

- If `~/.live-poker-trainer/ui-agent-learnings-pending.md` exists, fold
  its bullets into `.cursor/commands/ui-design-agent-learnings.md` in this
  worktree (respect the 40-bullet cap) and delete the pending file once
  the PR merges.
- Move each ticket (primary and companions) to In Progress (`jira.py transition --to "In Progress"`)
  and comment the branch name.
- The ticket is the spec. Ship the smallest change that makes every
  acceptance criterion true. Fix the cause. No fixes beyond the primary
  and its chosen companions.
- Reuse the existing table, theme, `GlowHighlight`, `RexMascot`, and asset
  slots. A new pattern gets its design-record section first.
- Update the named design-record section, its `Shipped` note, and the
  Lesson ledger row (when a step moved onto the felt) in the same change.
  Remove the item from **Known gaps** if this closes it.
- Tests lock the criteria. A layout change pumps the screen at 375 × 812
  and fails on overflow. Run `dart analyze` and the touched tests via
  `tools/tee_exit.sh` in named `test-LPT-*` / `analyze-LPT-*` tmux so
  `EXIT:N` is the real status (bare `| tee` masks failures).

## 7. Validate on the worktree build

Move the mini to the worktree build with one blocking command. It stops the
origin/main session, then launches the worktree detached (it survives your
shell). When `ios/` and `pubspec.lock` match a cached build (almost every
Dart-only fix) it installs the cached debug `Runner.app` and hot-restarts
onto the worktree's Dart in ~20 s — no Xcode. A native change does one
full build (several minutes) and caches it. It heartbeats the lock while
it waits; do not wrap it in tmux, `AwaitShell`, or `sleep`.

```bash
python3 tools/sim_lock.py guard
tools/flutter_run_fast.sh --checkout "$WT" --log "/tmp/flutter-$SLUG.log" \
  --pid-file "/tmp/flutter-$SLUG.pid" --timeout 900 --purpose "$KEY: worktree VM"
```

Drive with `python3 tools/agent_tap.py …` (no `--log` needed —
`flutter_run_fast.sh` points `/tmp/flutter-iphone-13-mini.active.log` at
this worktree). Pass `--log /tmp/flutter-$SLUG.log` only to override.
Walk **Validate before closing**, every acceptance criterion, and the
lens from step 4 on the touched screens. Screenshot each. When every check
passes, record the build you validated for step 9:
`VALIDATED_SHA="$(git -C "$WT" rev-parse HEAD)"`.

**Retry loop.** When any check fails:

1. Comment on the ticket: `Changes requested (attempt N)`, what failed, and
   the screenshot.
2. Fix it in the same worktree, re-run the tests, then
   `tools/flutter_hot_restart.sh "/tmp/flutter-$SLUG.log" "/tmp/flutter-$SLUG.pid"`
   (waits for that restart, ~1 s; exit 1 prints the compile error), and
   validate again. Relaunch with `flutter_run_fast.sh` only after an
   `ios/` or `pubspec.lock` change.

Stop after three failed attempts. Then comment the remaining failure, add
`needs-human`, transition the ticket back to To Do, kill the worktree
session, remove the worktree and branch (make-change step 7, without
merging), refresh the mini to origin/main, and go to step 10.

## 8. Merge

Run make-change steps 6–9. PR title `LPT-NN: <summary>` (with companions:
`LPT-NN, LPT-MM: <summary>`; the chat title still uses the primary key);
commit subjects
include the key; the PR test plan is the acceptance criteria. The functions
deploy returns in ~2 s with `skipping deploy` when `functions/` is
unchanged since the last deploy — that is a success, not a skip to report.
Step 9's refresh uses your lock and returns the mini to origin/main (it
stops the worktree session itself).

**Rename this Agents chat as soon as the PR exists.** When you have both
the ticket key and the PR number (right after `gh pr create`, or from
`gh pr view --json number,url`), call the Cursor cloud MCP tool
`rename-chat` (namespace `cursor-cloud`) on **this** run with
`{ "title": "LPT-NN PR-<number>" }`.

Example: `LPT-67 PR-1660`. Keep it under 200 characters; ticket key and
`PR-<n>` only (no summary). This renames the **sidebar chat title only** —
never a git branch. Skip silently when `rename-chat` is missing (CLI /
local launcher) or when either the ticket or the PR is unknown. Do not
rename other chats — only this session.

## 9. Validate on origin/main and close

Step 8's refresh already put origin/main on the mini (log
`/tmp/flutter-live-poker-trainer.run.log`; Dart-only merges reuse the
cached `Runner.app`, so it is ~20 s). First check whether origin/main is
the build you already validated:

```bash
tools/main_matches_validated.sh "$VALIDATED_SHA"
```

- **`match`** (exit 0): origin/main's `lib/`, `assets/`, `ios/` and
  pubspec equal the validated worktree build and the change did not touch
  `functions/`. Do not re-walk. Go straight to the fixed state, capture
  `<KEY>-validated.png`, and confirm the criteria visible in that shot.
- **`differs`** (exit 1): walk **Validate before closing** again on
  origin/main. Concurrent catalog / teachSpec merges often flip
  `assets/course/v2/catalog.json` while your lib fix is already on main —
  that is a re-walk, not a failed fix (LPT-173).

Save the closeout screenshots to `$PRIMARY/.cursor/tmp/ui-agent/<KEY>-*.png`.

**Required validated proof.** Capture at least one
`<KEY>-validated.png` on this post-merge origin/main build that shows the
fixed behavior (same surface/angle as the issue screenshot when possible).
Do not close without attaching it.

A failure here is another attempt in the step 7 loop, on a new branch
`fix/$SLUG-2` from origin/main. The three-attempt limit counts both steps.

Close each ticket (primary, then companions) only when every one of its
criteria passed on origin/main — each gets its own close comment and
`<KEY>-validated.png`:

1. One comment, `jira.py comment LPT-NN --body-file close.md --attach
   <KEY>-validated.png` (plus any other `<KEY>-*.png` you need), that
   stands alone. The body must include an embedded validated shot:

   ```markdown
   ## Validated on origin/main
   SHA: `<SHA>`
   PR: <url>
   ![validated: <what is fixed>](<KEY>-validated.png)

   ## Criteria
   - <criterion>: how checked on the mini
   ```

   **PR URL:** paste the URL from `gh pr create` / `gh pr view <n> --json
   url -q .url` only. Never invent
   `https://github.com/<guessed-name>/live-poker-trainer/pull/N` — the
   remotes/org owner is `KC38` (wrong owner links 404).

   Also state the design-record section and the sentence that landed, and
   that the images are from that live session (not the pre-fix issue
   shots).
2. `python3 tools/jira.py verify-embeds LPT-NN` must exit 0. If it lists
   orphan wiki thumbs (Preview unavailable in Jira), attach the missing
   PNG and re-comment — do not transition yet.
3. `jira.py transition LPT-NN --to Done`. Confirm the status it prints.
   Never transition to Done if the close comment lacks a validated
   screenshot attachment.

## 10. Learnings, log, clean up, release, report

**Update learnings before you leave.** Open
[ui-design-agent-learnings.md](ui-design-agent-learnings.md) and follow its
**How to update** section. Triggers that usually need a new or tighter
bullet: a validation retry, `SIM_NOT_READY`, `JIRA_UNAVAILABLE`, a wrong
`agent_tap` needle, a reopen of a Done ticket, a deploy skip that confused
closing, or any approach you had to undo. If nothing durable was learned,
leave the file unchanged and say `learnings: unchanged` in the report.

When the file did change, never open a learnings-only PR for one run:

- Anything you already know before step 8 (a validation retry, a wrong
  needle, a tool gotcha) goes into this run's ticket worktree **before the
  merge**, so it ships in the ticket PR.
- Anything learned after the merge (steps 9–10), or on a run with no
  ticket PR (`clean`, `SIM_NOT_READY`, `JIRA_UNAVAILABLE`), is appended to
  `~/.live-poker-trainer/ui-agent-learnings-pending.md` instead; report
  `learnings: pending`. The next run's step 6 folds it into its ticket PR.
- Only when that pending file holds **5+** bullets and this run has no
  ticket PR, ship them in one tiny chore make-change PR before releasing.

Append one line to `~/.live-poker-trainer/ui-agent-coverage.jsonl`.
`ticket` is the KEY this run closed (or the primary outcome ticket). Put
other **filed** keys and any unfiled hunches in `leads` (e.g.
`"filed LPT-64 hint stack"`, `"filed LPT-65 heart chrome"`):

```json
{"at": "<ISO time>", "sha": "<SHA walked>", "surface": "<surface>", "result": "closed|needs-human|clean|unreachable|blocked|sim-not-ready|jira-unavailable", "ticket": "LPT-NN", "leads": ["<filed LPT-MM … or other finding, one line each>"], "learnings": "updated|pending|unchanged"}
```

Delete `$PRIMARY/.cursor/tmp/ui-agent/`. Make sure no worktree tmux session
for this ticket is still running. Then:

```bash
python3 tools/sim_lock.py release
```

If step 8's rename did not run yet and this report includes both a ticket
key and a PR number/URL, call `rename-chat` now with `LPT-NN PR-<number>`
before the final reply (same rules as step 8).

Reply with one short block: SHA walked, surface, ticket fixed and result,
other tickets filed this run, branch and PR URL, chat title after rename
(or `rename: skipped`), attempts used, functions deploy result, leads
logged, learnings updated / pending / unchanged, and the lock released.
