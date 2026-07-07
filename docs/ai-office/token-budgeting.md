# Token Budgeting And Model Routing

The office should spend model attention where it changes the outcome. When the
runtime exposes token telemetry, record the actual usage. When it does not,
enforce the budget through task tiers, small read sets, summary-first handoffs,
and explicit model routing.

## Task Tiers

| Tier | Use For | Default Context | Sub-Agents | Default Codex Route |
| --- | --- | --- | --- | --- |
| T0 status | Status, progress, branch health | `docs/features/status-index.md`, git refs, active feature status/outboxes | Never | `gpt-5.4-mini`, low or medium |
| T1 docs/readme | README, copy, small docs, metadata, simple config notes | Target files plus `rg` results | No | `gpt-5.4-mini`, low or medium |
| T2 planning | Briefs, UX plans, architecture planning, scoped governance | Feature folder, targeted office docs, relevant source maps | Packets by default; native only if requested | `gpt-5.4-mini` medium, escalate to `gpt-5.5` for design/architecture risk |
| T3 implementation | Code changes, tests, QA follow-up, risky debugging | `async/context-summary.md` first, then only contract-named files | Only when the task earns parallel work | Role default; escalate senior/risky work to `gpt-5.5` high |
| T4 release | Review, release readiness, final gate, merge prep | Context summary, diff, handoffs, test evidence, release notes | Only for complex review or verification splits | `gpt-5.5` high |

## Context Budget Rules

- Start every routed task by naming the tier in the role contract.
- T0 and T1 tasks must not read the whole office protocol stack. Use the target
  file, `rg` results, and one directly relevant policy file only when needed.
- T3 and T4 role contracts require
  `docs/features/<feature-slug>/async/context-summary.md` before
  implementation, QA, review, or release work begins.
- Role packets stay under 200 words when practical. Pass file paths and
  boundaries, not pasted history.
- Keep `fork_context` false by default. Hidden chat history is expensive and
  less repeatable than repo-visible summaries, handoffs, and outboxes.
- If a role reads extra files beyond the contract, record the reason in the
  outbox.

## Model Routing

Use the cheapest model that can protect the outcome:

- `gpt-5.4-mini`: T0 status, T1 docs, product briefs, packet generation, narrow
  implementation slices, normal QA/test execution, and read-heavy scans.
- `gpt-5.5` medium: UX/design quality, ambiguous product decisions, and
  multi-step planning that needs better synthesis.
- `gpt-5.5` high: architecture, senior implementation with shared-state risk,
  risky debugging, code review, release readiness, and governance changes.

Do not use native sub-agents merely because they are available. Use them when
parallelism or independent role context is worth the extra model work.

## Memory Search Cap

Memory search is pointer-first:

- Start with `docs/features/status-index.md` for status and release questions.
- For semantic memory, request the top 3-5 hits first.
- Read the cited source files before treating a hit as true.
- Do not paste full memory/history into packets unless exact prior evidence is
  required.

## Visual Asset Rule

For README and simple docs visuals, keep the SVG/source artifact when possible
and render once. Screenshot and image-inspection loops are reserved for design
work, product UI changes, or visual assets whose correctness depends on the
rendered result.
