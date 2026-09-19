# Exploitative Poker Lab

Multi-platform Flutter trainer for live No-Limit Hold'em. Training situations,
coaching, hand history, and progress are server-authored and require an
authenticated network connection.

## Quick start

Requires Flutter 3.47+ / Dart 3.13+.

```bash
flutter pub get
flutter run
```

There are no LLM keys or training-data fallbacks in the app bundle. The Flutter
client authenticates with Firebase, requests one situation from Cloud
Functions, and keeps only that active hand in memory.

## Training flow

1. The client sends the current table setup to `fetchSituation`.
2. The server canonicalizes the setup and atomically allocates a situation that
   has never been served to that user.
   If a new pool is still being generated, the callable returns immediately
   and the client polls with a short backoff while showing “Preparing hand…”.
3. Every situation starts preflop and contains a validated action graph:
   scripted opponent actions, fixed runouts, curated hero decisions, and
   general coaching for every available hero action.
4. The Flutter engine replays that graph. It does not generate cards, opponent
   lines, or coaching.
5. `recordSituationProgress` validates the reported path against the stored
   graph before writing the hand and updating Progress.

An allocation receipt is created when a situation is delivered, so abandoning
a hand cannot cause that same situation to be served to the user again.

## Situation generation

Pools are stored under `tableSetups/{setupKey}/situations`. Custom tables use
their exact ordered lineup and positions. Random tables use a normalized setup
key and receive a server-generated lineup inside each situation.

The server queues five concurrent generation attempts for a new setup and five
more when the globally never-served count reaches one. A Firestore-triggered
worker performs that work outside the latency-sensitive callable, while a
Firestore-backed lease prevents duplicate batches.

All AI work uses `gemini-3.8-flash` in Firebase Functions. Generation is
followed by a separate critique/correction pass, then deterministic validators
check graph structure, cards, streets, action legality, bet sizing, stack/pot
consistency, and coaching metadata before publication.

## Progress

Progress preserves identity, style and sample-gated poker metrics, trends,
coaching accuracy/EV, and street/archetype breakdowns. Hand history and
aggregates live under the authenticated user's Firestore document. Leak Finder
and Coach Review have been removed.

User photos are normalized in memory, uploaded to
`avatars/{uid}/avatar.png`, and referenced from the Firestore user profile.
Only audio preferences remain device-local.

## Firebase

Project: `live-poker-trainer`

Runtime services:

- Firebase Authentication
- Cloud Functions (`fetchSituation`, `recordSituationProgress`)
- Firestore (private pools, receipts, history, progress, preferences)
- Firebase Storage (user-owned avatars)
- Secret Manager (`GEMINI_API_KEY`, Functions only)

Deploy with the current Firebase CLI:

```bash
npx -y firebase-tools@latest deploy \
  --project live-poker-trainer \
  --only firestore:rules,firestore:indexes,storage,functions
```

Set or rotate the server secret separately:

```bash
npx -y firebase-tools@latest functions:secrets:set GEMINI_API_KEY \
  --project live-poker-trainer
```

The obsolete-data reset requires an explicit target and is dry-run by default:

```bash
cd functions
npm run reset:dry -- --project=my-staging-project
```

Execution has no short package command. The target must be repeated exactly:

```bash
npx ts-node --transpile-only scripts/reset_obsolete_data.ts \
  --project=my-staging-project \
  --execute \
  --confirm-project=my-staging-project
```

Production additionally requires the explicit production-reset guard:

```bash
npx ts-node --transpile-only scripts/reset_obsolete_data.ts \
  --project=live-poker-trainer \
  --execute \
  --confirm-project=live-poker-trainer \
  --allow-production-reset
```

The reset preserves Authentication accounts and retained identity/preferences.
It deletes obsolete training collections, user training stats, and the private
`system/situationPoolLimits` quota document when present.

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

See [docs/architecture.md](docs/architecture.md) for data flow and security
boundaries.
