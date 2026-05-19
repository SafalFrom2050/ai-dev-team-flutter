# Feature Workspace

Create one folder per feature:

```text
docs/features/<feature-slug>/
```

Keep `docs/features/status-index.md` current on product branches. The Office
Assistant reads it first for progress checks, so status requests stay lightweight
and branch-aware.

Start from the templates in `docs/ai-office/templates/`:

- `feature-brief.md`
- `design-contract.md`
- `tech-plan.md`
- `test-plan.md`
- `handoff.md`

The feature folder is the office desk for that feature. Product, design,
engineering, QA, review, and release agents should all leave their current
decisions here.

For async or parallel role sessions, add:

```text
async/
  runbook.md
  status.md
  ownership.md
  decisions.md
  packets/
  outbox/
```

See `docs/ai-office/async-agent-runtime.md`.
