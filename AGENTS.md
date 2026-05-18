# AI Dev Team Operating Rules

This repository is run like an office of specialist AI agents. The shared goal is
simple: turn a product idea into production-ready Flutter code on `main` without
losing product intent, design quality, or engineering discipline.

## Prime Directive

`main` represents production quality. It should always be buildable, tested, and
reviewed. Agents do their work in branches, leave clear handoffs, and merge only
through review.

## Default Team Loop

0. CEO defines the office direction, records decisions in `CEO_OVERVIEW.md`, and
   keeps the team structure coherent.
1. Office Assistant triages unclear incoming tasks and routes them to the right
   role or role sequence.
2. Product Lead turns the idea into a scoped feature brief.
3. UI/UX Designer turns the brief into flows, states, copy, design tokens, and
   acceptance criteria.
4. Product Engineer or Architect turns the brief and design contract into a
   technical plan.
5. Flutter developers implement from the technical plan on scoped branches.
6. QA/Test Engineer verifies behavior, edge cases, and regressions.
7. Code Reviewer blocks risky or unclear changes before merge.
8. Release Engineer merges the integration branch into `main` only after all
   gates pass.

## Branch Model

Use `org/main` as the stable company operating system branch. It stores the
office structure, roles, workflows, templates, MCP/skills setup, and CEO history.
Product work should not casually change it.

Use one integration branch per meaningful feature:

- `org/main`: canonical AI office/company structure.
- `org/<initiative>`: proposed company structure, workflow, tooling, or
  governance changes.
- `office/<initiative>`: CEO-owned office structure, workflow, and governance
  changes.
- `integrate/<feature-slug>`: shared staging branch for one feature.
- `product/<feature-slug>`: product brief and acceptance criteria.
- `design/<feature-slug>`: UX flows, design contract, tokens, UI component specs,
  screenshots, and golden references.
- `arch/<feature-slug>`: architecture notes, data contracts, state management,
  and risk decisions.
- `feat/<feature-slug>/<agent-or-slice>`: implementation branches.
- `test/<feature-slug>`: test coverage, fixtures, and QA automation.
- `fix/<feature-slug>/<issue>`: review or QA follow-up fixes.

Agents branch from the current `integrate/<feature-slug>` branch unless the task
is pure discovery. They merge back into `integrate/<feature-slug>` through PRs.
Only the Release Engineer opens the final PR from `integrate/<feature-slug>` to
`main`.

## Design Agents Work In Git Too

Designer agents do not only produce opinions. They produce versioned artifacts:

- `docs/features/<feature-slug>/ux.md`
- `docs/features/<feature-slug>/design-contract.md`
- Flutter theme and token changes when needed.
- Reusable widget specs for shared UI.
- Golden-test references or screenshot expectations for important UI states.

The design branch should merge before implementation branches when possible.
Developers should treat the design contract as part of the spec.

## Collaboration Rules

- Users do not need to specify branches, packets, or workflows. If they call the
  Office Assistant with a task, orient from the repo and choose the workflow.
- Every feature owns a folder under `docs/features/<feature-slug>/`.
- CEO-level workflow, team, and tooling changes must update
  `CEO_OVERVIEW.md`.
- Async role sessions must communicate through repo files, branch diffs, and
  handoff/outbox notes instead of hidden chat history.
- Every agent updates `handoff.md` before asking for review.
- Every PR declares its role, scope, changed files, test evidence, and known
  risks.
- Parallel agents must have disjoint file ownership whenever possible.
- If two agents need the same file, the integration branch owner coordinates the
  order instead of allowing hidden conflicts.
- If a product feature needs to change the office itself, split that work into a
  separate `org/<initiative>` branch.
- Do not introduce secrets, private keys, real customer data, or unlicensed
  assets.
- Prefer Flutter and Dart patterns that are idiomatic, testable, and boring in
  the best way.

## Quality Bar

Before code reaches `main`, expect:

- `fvm dart format` clean.
- `fvm flutter analyze` clean.
- Unit, widget, and integration tests appropriate to the change.
- UI states reviewed against the design contract.
- Accessibility and responsive behavior checked for user-facing screens.
- Release notes or a short product summary for user-visible changes.

## Flutter-Specific Rules

- Treat widgets as product surface, not just implementation detail.
- Every user-facing feature should define route, state, layout, accessibility,
  and test expectations before implementation.
- Prefer small composable widgets with stable keys for important interactive
  elements.
- Keep business logic outside widgets unless the logic is truly presentational.
- Use Flutter's official docs, API docs, `pub.dev`, and the Dart/Flutter MCP
  server when available before inventing APIs from memory.
- Use installed skills under `.agents/skills` for Flutter/Dart tasks when a
  relevant skill exists.
- Designer agents should map visual decisions to Flutter-native artifacts:
  `ThemeData`, design tokens, component states, responsive breakpoints, semantic
  labels, and golden-test expectations.
- Reviewer agents should look for Flutter-specific failure modes: excessive
  rebuilds, layout overflows, missing mounted checks after async gaps, unstable
  keys, inaccessible controls, brittle golden tests, and platform assumptions.
