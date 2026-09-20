# Exploit coaching quality

## Scope

The coach teaches exploitative live No-Limit Hold'em, not solver-perfect GTO.
Version one covers standard cash games without rake, straddles, bomb pots,
run-it-twice, or time rake. Advice is qualitative and may mark several actions
reasonable.

## Information boundary

Opponent decisions receive only that actor's private cards, bounded visible
tendency profile, and public state/history. Coaching receives Hero's private
cards, visible profiles, and public state/history. It never receives villain
cards or unrevealed runout cards.

`coaching_facts.ts` is the only production context builder. Metamorphic tests
replace villain cards and future runouts while requiring identical coaching
facts.

## Evidence hierarchy

1. The server engine supplies legal actions, stacks, pot, position, SPR, and
   pot odds.
2. Versioned bounded tendency templates supply the only permitted player reads.
3. Gemini evaluates all legal actions together using the fair-information facts.
4. A second high-thinking pass corrects unsupported certainty, invented
   statistics, mathematical contradictions, and inconsistent rankings.
5. Deterministic parsing requires every action exactly once, at least one
   recommendation, legal alternatives, and known tendency keys.

The benchmark is AI-curated and is not represented as human-expert ground
truth. It uses broad high-signal acceptable sets and confidence calibration to
avoid fake strategic precision.

## Benchmark

`exploit-benchmark-v1` contains 720 cases:

- five archetypes;
- four streets;
- 20, 100, and 200 BB effective stacks;
- in-position, out-of-position, and multiway/blind configurations;
- thin value, low-equity bluff, bluff-catch, and strong-value spots.

The online runner invokes the exact production draft/critic pipeline. A
dimension-stratified 60-case run is the per-release gate; the full corpus is the
periodic certification gate for model, prompt, profile, or benchmark-version
changes.

Every scored case records:

- quality gates (structural, acceptable set, forbidden avoidance, tendency
  grounding, confidence calibration);
- `estimatedCostUsdMicros` from Gemini usage metadata and the model rate card;
- `durationMs` wall-clock for the draft + critique HTTP calls.

Reports aggregate average/max cost and latency alongside the quality rates.

### Model and thinking comparison

Use `--compare` to evaluate the default catalog (Flash / Flash-Lite / Pro and
low / medium / high thinking mixes) on the same stratified sample. Selection is
lexicographic:

1. highest quality (gate pass, then acceptable-set rate, then other rates);
2. lowest average estimated cost;
3. lowest average response time.

Override a single run with `--model=`, `--draft-thinking=`, and
`--critic-thinking=`.

The latest checked-in stratified run is
[`coaching-benchmark-latest.json`](coaching-benchmark-latest.json): 60 cases
covering every archetype, street, stack depth, spot type, and heads-up/multiway
variant. It achieved 98.33% acceptable-set agreement and 100% on structural,
forbidden-action, tendency-grounding, and confidence-calibration gates. The
single known miss remains explicit in that artifact rather than being hidden by
an aggregate score. Re-run with the current runner to refresh cost and latency
fields on that artifact.

```bash
cd functions
GEMINI_API_KEY=... npm run benchmark:coach
GEMINI_API_KEY=... npm run benchmark:coach:full
GEMINI_API_KEY=... npm run benchmark:coach:compare
GEMINI_API_KEY=... npm run benchmark:coach -- --model=gemini-3.8-flash --draft-thinking=medium --critic-thinking=high
```

Release thresholds:

- 100% structural action coverage;
- at least 95% recommendation inside the broad acceptable set;
- at least 99% avoidance of explicitly harmful exploit recommendations;
- at least 95% grounding in a relevant visible tendency;
- at least 99% confidence calibration.

Model, tendency-template, or benchmark-version changes require a new full
report. Ordinary releases require a new stratified report. Failed cases remain
auditable in the generated JSON report. Prefer the `--compare` winner only when
it still passes the quality gates above.
