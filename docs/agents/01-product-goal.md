# 01 — Product goal

## One sentence

Online Flutter trainer that teaches **exploitative** live No-Limit Hold'em
the way Duolingo Chess teaches chess: short interactive lessons, then
server-authoritative coached cash-game hands.

## Why this product exists

Most poker trainers either (a) dump theory as text, or (b) pretend a client
can safely own the deck and the solver. This app does neither.

- Learners **do** things on a real-feeling table (tap cards, seats, actions).
- The **server** owns deals, legal fixed actions, villain decisions, side
  pots, coaching, history, and progress.
- Coaching is **qualitative and profile-driven**, not fake EV from a solver.
- Gemini (and peers) never compute pots or invent action amounts — they pick
  from server-supplied legal action ids, or draft/critique rubrics from
  deterministic facts.

## Two product surfaces (do not merge)

| Surface | Job | Progress home |
| --- | --- | --- |
| **Course** | Structured lessons (hearts, XP, streak, path) | `users/{uid}/course/main` via course callables |
| **Live Training** | Coached six-max cash hands | `users/{uid}/liveProgress/main` + history |

Profile shows them in **separate sections**. Accepted course accuracy is not
"strong decisions" from Live. Never combine the numbers in UI or analytics.

## Player journey (happy path)

1. Guest onboarding (experience → daily goal → Rex → recommended lesson).
2. Finish first lesson; optional save-progress / create account.
3. Home path: next lesson nodes, reviews, hearts economy.
4. After unlock rules: Live Training hub → coached hands at the felt.
5. Profile: identity, course metrics, Live metrics, Settings.

## Design north star

Stakeholder brief (full text in the design record):

1. Duolingo Chess **loop**, not palette/owl/words.
2. Teach by doing on one phone-first poker table.
3. It feels like a live table (deal order, blinds, bets on felt, pot award).
4. Rex is the coach with a real face and mood.
5. Gentle honest guidance (SoftPulse gold cues; cyan for learner picks).
6. Visible fair economy (hearts, streak, XP, gems).
7. Home is a path, not a dashboard of cards.
8. Depth before breadth — finish one screen/lesson properly.

## Non-goals (rejected on purpose)

Do not reintroduce: text-only explain steps with lone Continue; mini felts /
suit tiles / rank slots; bouncing cue arrows; mixing course and Live stats;
client-side Gemini keys; offline hand continuation; free fold when Check is
legal.

See `docs/ui/design-record.md` → "Rejected on purpose".
