# 09 — Working as an agent

## Default change flow

Follow `.cursor/skills/make-change/SKILL.md` end to end:

1. Worktree off `origin/main` under `.worktrees/<slug>` with tracking branch.
2. Implement + `dart analyze` / targeted tests (no simulator drive yet).
3. Logical commits on the feature branch only.
4. Review `git diff origin/main...HEAD`.
5. Tests cover the change.
6. Push, `gh pr create`, `gh pr merge --squash` (**do not** `--delete-branch`
   before leaving the worktree).
7. Remove worktree, sync primary `main`, then delete remote/local branch.
8. Deploy Cloud Functions.
9. Refresh iPhone 13 mini **only if** primary pull succeeded.

Never edit or commit on the primary checkout. Never move the agent root into
the worktree (toast about `main` already used is expected).

## Documentation duty

Every change that affects behavior, structure, preferences, or reusable APIs
must update:

1. Relevant `docs/agents/*.md` sections (and deep docs if contracts change).
2. Library / agent comments in the files you touched.
3. Design record / architecture / agent-paths when those contracts move.

Rule: `.cursor/rules/agent-docs-maintenance.mdc` (always apply).

## Simulator

- Device: **iPhone 13 mini** only. UDID from `tools/iphone_13_mini_udid.sh`.
- Lock: `tools/sim_lock.py` + `.cursor/rules/simulator-lock.mdc`.
- Ops: [agent-ios-simulator.md](../agent-ios-simulator.md).
- Named journeys: [agent-paths.md](../agent-paths.md) — do not invent path
  names mid-session; add them to that file when the product grows a journey.

make-change does **not** drive UI or take screenshots; that is for UI design
/ play-test skills.

## UI design agent

Command: `.cursor/commands/ui-design-agent.md`. Loop:
`tools/ui_design_agent_loop.sh`. Keep learnings file updated.

## Tmp files

Do not litter the repo root with agent scratch logs. Follow
`.cursor/rules/tmp-files.mdc`.

## Jira tickets

When the change is a ticket, branch/worktree slug includes the key
(`fix/LPT-12-…` / `feature/LPT-12-…`), and the PR title starts with
`LPT-12: …`.

## Verification cheat sheet

```bash
# Client
flutter analyze
flutter test test/path/to/relevant_test.dart

# Functions
cd functions && npm ci && npm run build && npm test
```

Prefer targeted tests that lock the preference or contract you changed
(see `test/docs/` for doc-contract tests).

## What “done” means for the next agent

Someone else can open `docs/agents/README.md`, skim the section for your
area, read the file header comments you left, and continue without asking
“why is it like this?” for decisions you already made.
