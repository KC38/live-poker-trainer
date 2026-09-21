# Course contract v2

Canonical live-cash No-Limit Hold'em course source for Flutter and Cloud
Functions. Plan 02 defines the contract and pipeline. Plan 07 authors
Sections 1–2 (Never Played; Rules Known / Home Games). Plan 08 authors
Sections 3–4 (First Casino Sessions; Regular Live Cash Player). Later
sections remain stubs until wave three.

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

Section 1–2 authoring lives in `tools/course/wave_one_foundations.mjs`.
Section 3–4 authoring lives in `tools/course/wave_two_live_competence.mjs`.
Both are composed by `build_seed_course.mjs`.

## Scope

`scope` is always `live_cash_nlh`. The validator rejects tournaments,
online/HUD instruction, PLO/other variants, and rake lessons.
