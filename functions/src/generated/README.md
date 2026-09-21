# Generated curriculum assets

`curriculum_catalog.json` is the full canonical catalog copied from
`content/curriculum/v1/catalog.json`.

`exercise_bank.json` is the static exercise bank for Cloud Functions.
Individual copies also live under `exercises/`.

Do not hand-edit the JSON. Regenerate table-ready lessons with
`python3 tools/curriculum/author_table_ready.py` and preflop lessons with
`python3 tools/curriculum/author_preflop.py`. New exercise content belongs in
those scripts or under `content/curriculum/v1/exercises/`.
