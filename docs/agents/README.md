# Agent handbook

**Start here** when you are an AI agent working on Exploitative Poker Lab
(Live Poker Trainer). These docs explain the product goal, how the repo is
structured, how the systems work, and the preferences you must not undo.

Human-oriented product docs still live in [README.md](../../README.md),
[architecture.md](../architecture.md), and
[ui/design-record.md](../ui/design-record.md). This handbook is the
orientation layer on top of those sources of truth.

## Read order (new agent)

1. [01 — Product goal](01-product-goal.md) — what we are building and why
2. [02 — Repo map](02-repo-map.md) — where code lives
3. [03 — Flutter client](03-client.md) — app bootstrap, routing, state
4. [04 — Course system](04-course.md) — lessons, hearts, grading, content
5. [05 — Live Training](05-live-training.md) — server-authored hands
6. [06 — UI and preferences](06-ui-and-preferences.md) — visual contract
7. [07 — Reusable components](07-reusable-components.md) — what to reuse
8. [08 — Backend](08-backend.md) — Cloud Functions and Firestore
9. [09 — Working as an agent](09-agent-workflow.md) — change flow, sims, tools

## Hard rules (never skip)

| Rule | Where |
| --- | --- |
| Edit in a `.worktrees/<slug>` worktree, not the primary checkout | `.cursor/rules/make-change.mdc` |
| Ship via `.cursor/skills/make-change/SKILL.md` | same |
| One poker table widget: `FeltTableView` | design record + lesson layout rule |
| Teach by doing — no boring text Q&A as the default | design record |
| Course stats and Live Training stats stay separate | architecture / Profile |
| Server owns cards, legal actions, pots, coaching | architecture |
| Keep these agent docs and code comments current | `.cursor/rules/agent-docs-maintenance.mdc` |
| iPhone 13 mini only; claim with `tools/sim_lock.py` | simulator-lock rule |

## Related deep docs

- [architecture.md](../architecture.md) — trust boundaries, pools, engine
- [coaching-quality.md](../coaching-quality.md) — coaching release gate
- [ui/design-record.md](../ui/design-record.md) — visual/interaction contract
- [agent-paths.md](../agent-paths.md) — named simulator validation journeys
- [agent-ios-simulator.md](../agent-ios-simulator.md) — Device Hub / mini ops
