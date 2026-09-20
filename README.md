# Exploitative Poker Lab

Online Flutter trainer for exploitative live No-Limit Hold'em. The server owns
cards, legal fixed actions, opponent decisions, coaching, side pots, history,
and progress. The app contains no LLM credential or offline gameplay fallback.

## Quick start

Requires Flutter 3.47+ / Dart 3.13+.

```bash
flutter pub get
flutter run
```

The launch default is random six-max $1/$2 with a 200 BB maximum. Every hand
gets a new ordered lineup of bounded player tendencies, visible by tapping a
villain. Gemini chooses the button, varied 20–200 BB stacks, private cards, and
the fixed runout.

## Live training flow

1. `startLiveHand` allocates an unseen, fully warmed hand and returns only
   Hero's cards plus public state.
2. Hero chooses from fixed server-provided actions. Fold is never offered when
   Check is free.
3. `submitLiveAction` validates an idempotent state/version/action command.
4. The shared branch is loaded or generated. Each villain is called
   sequentially with only its own cards and public information.
5. A pre-generated all-actions exploit rubric is revealed for Hero's choice.
6. The server returns replay events and the next projected decision/terminal.
7. `resumeLiveHand` restores authoritative state after interruptions.

Hero folding ends training immediately. Villain cards are revealed only for
non-folded players at a real showdown.

## Shared pools and trees

Pools live under `liveTableSetups/{setupKey}/hands`. A new setup becomes
available after ten hands have complete first-node coaching and three warmed
non-fold branches. When a user has five or fewer unseen hands, ten more shared
hands are queued. Only zero unseen hands blocks that user.

Each hand owns a lazy tree of canonical state/history nodes and fixed-action
edges. Generation leases make first expansion deterministic under concurrent
users; later users receive the stored response.

The authoritative engine supports unequal stacks, incomplete raises, unmatched
refunds, main/side pots, ties, odd cents, fixed all-in runouts, and deterministic
showdown evaluation. Gemini selects legal action IDs but never computes state
or payouts.

## Coaching quality

Coaching is qualitative and profile-driven, not presented as solver EV.
Deterministic facts, bounded visible tendencies, a high-thinking draft, an
adversarial correction pass, strict output validation, hidden-information
metamorphic tests, a 720-case corpus, and a dimension-stratified 60-case online
run form the release gate.

See [docs/coaching-quality.md](docs/coaching-quality.md).

## Firebase

Project: `live-poker-trainer`

Runtime services:

- Firebase Authentication
- Cloud Functions (`startLiveHand`, `submitLiveAction`, `resumeLiveHand`,
  `refillLiveHandPool`, `processLiveHandGenerationJob`)
- Firestore (private deals/trees/sessions/receipts; owner-readable history and
  progress)
- Firebase Storage (user-owned avatars)
- Secret Manager (`GEMINI_API_KEY`, Functions only)

Deploy:

```bash
npx -y firebase-tools@latest deploy \
  --project live-poker-trainer \
  --only firestore:rules,firestore:indexes,storage,functions
```

Set or rotate the secret separately:

```bash
npx -y firebase-tools@latest functions:secrets:set GEMINI_API_KEY \
  --project live-poker-trainer
```

## Reset and seed

The reset is dry-run by default and requires an exact target. Production
execution also requires the explicit production guard.

```bash
cd functions
npm run reset:dry -- --project=live-poker-trainer

npx ts-node --transpile-only scripts/reset_obsolete_data.ts \
  --project=live-poker-trainer \
  --execute \
  --confirm-project=live-poker-trainer \
  --allow-production-reset
```

The reset preserves Auth accounts, names, avatars, and device-local audio. It
deletes all old/new training data and resets gameplay preferences to the launch
default.

After v3 Functions and rules are deployed:

```bash
npm run seed:live -- \
  --project=live-poker-trainer \
  --confirm-project=live-poker-trainer
```

The seed command enables client version 2.0.0 and waits for ten warmed default
hands.

## Development

```bash
cd functions
npm ci
npm run build
npm test

cd ..
flutter pub get
flutter analyze
flutter test
```

Run the sampled, full, or multi-model coaching gate with `GEMINI_API_KEY` in the
environment:

```bash
cd functions
npm run benchmark:coach
npm run benchmark:coach:full
npm run benchmark:coach:compare
```

Reports include quality rates plus estimated cost and response-time averages.
`--compare` ranks configs by quality, then cost, then latency.

See [docs/architecture.md](docs/architecture.md) for complete boundaries and
data flow.
