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

GitHub Actions deploys Functions on pushes to `main` once
`.github/workflows/deploy-functions.yml` exists (copy from
[docs/github-actions/deploy-functions.yml](docs/github-actions/deploy-functions.yml)
in the GitHub UI; agent tokens cannot write workflow files).

The job is non-interactive and needs one GitHub Actions secret (Settings →
Secrets and variables → Actions):

- `FIREBASE_SERVICE_ACCOUNT` — JSON key for a GCP service account that can
  deploy Firebase Functions (preferred), or
- `FIREBASE_TOKEN` — token from
  `npx -y firebase-tools@15.30.2 login:ci`

The same variable names work in a Cloud Agent environment secret so local
`.cursor/skills/ship-change/scripts/deploy-functions.sh` can deploy without
a browser login.

Manual deploy (still requires one of those credentials):

```bash
npx -y firebase-tools@15.30.2 deploy \
  --project live-poker-trainer \
  --only firestore:rules,firestore:indexes,storage,functions \
  --non-interactive
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

## Profile

Profile is a tab root with three separate sections:

- Identity and avatar
- Course progress (XP, streak, accepted accuracy, current section, mastery,
  reviews due). Legacy academy XP, when present, is labeled and is not course
  XP or an unlock.
- Live Training (coaching record, net result, streets, style, player types)

Course accuracy and Live coaching statistics are not combined. Settings and
sign-out are on Profile.

## Course rollout

`appConfig/courseFlags` is server-owned. Clients, including signed-out guests,
may read it and cannot write it. A missing, malformed, failed, or
too-old-client read disables the course. The client reloads flags when the
auth uid changes so a signed-out failure is not reused after anonymous
sign-in. The kill switch hides course starts and guest onboarding. Signed-in
Live Training and Profile stay available.

Rollout order:

1. Internal catalog and runtime validation.
2. Staff accounts with course state enabled.
3. New guest onboarding cohort (`guestCourseEnabled`).
4. Authenticated existing-user cohort.
5. Full rollout after crash, completion, merge, and Live Training checks.

`courseEnabled=false` stops course entry. `guestCourseEnabled=false` keeps
the course available for signed-in accounts but sends signed-out and new
anonymous guests to sign-in; a guest who already finished the first lesson
can still save progress. `courseStartsEnabled=false` pauses new Home starts
while an already started attempt can finish. None of these flags disable
Live Training.

## Analytics

Events cover tab selection, onboarding steps, lessons, grade band, life loss,
remediation, jump tests, warm-ups, account conversion, and progress merge.
They may include public lesson or activity ids, timing, and closed-set
outcomes. They must not include hole cards, unrevealed cards, grading keys,
coach prompts, or free text.

## Legacy academy migration

The migration is dry-run by default. Execute mode requires an exact project
confirmation and `--confirm-telemetry=legacy-academy-observed`. Production
also requires `--allow-production-migration`.

```bash
cd functions
npm run migrate:academy:dry -- --project=live-poker-trainer
```

Compatible lifetime XP is stored as `legacyLifetimeXp` with label
`legacy_academy`. Old lesson ids are not copied onto completions or unlocks.
Authentication, identity, avatar, preferences, audio, and Live Training
history stay in place.

## Functions build

`npm run build` deletes `functions/lib/` before generating the course bank and
running `tsc`, so stale academy output cannot survive into the deploy bundle.
Deployed exports are the live-hand, course, and transfer callables plus the
live pool workers. The v2 situation fetch, progress, and pool callables are
not exported.
