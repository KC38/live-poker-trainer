# Course contract v2

Canonical live-cash No-Limit Hold'em course source for Flutter and Cloud
Functions. Plan 02 defines the contract and pipeline only — full lesson
authoring lands in later content-wave plans.

## Layout

| Path | Role |
|---|---|
| `course.json` | Canonical authored source (public + private grading) |
| `schemas/` | JSON Schema documents for every contract surface |
| `fixtures/invalid/` | Deliberately invalid catalogs for validator tests |

## Pipeline

From the repo root:

```bash
node tools/course/validate_course.mjs
```

That command:

1. Validates `course.json` against domain rules (and schema shapes)
2. Writes sanitized client catalog → `assets/course/v2/catalog.json`
3. Writes private Functions bank → `functions/src/generated/course_bank.json`
4. Embeds matching `catalogVersion` + `contentChecksum` in both outputs

CI check (fail if generated outputs are stale):

```bash
node tools/course/validate_course.mjs --check
```

Rebuild the seed catalog from the checked-in builder:

```bash
node tools/course/build_seed_course.mjs
```

## Scope

`scope` is always `live_cash_nlh`. The validator rejects tournaments,
online/HUD instruction, PLO/other variants, and rake lessons.
