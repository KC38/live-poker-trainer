# UI design agent run memory

Overflow operational notes when ui-design-agent-learnings.md is at the
40-bullet cap. Grep before repeating a retry.

## Fold 2026-10-12

- Prefer a simpler open-queue JQL (`project = LPT AND labels = ui-agent AND statusCategory != Done`) then filter out `needs-human` / `grokbot` locally — Jira `labels != X` searches can hang for 10+ minutes with no stdout (2026-10-13).
