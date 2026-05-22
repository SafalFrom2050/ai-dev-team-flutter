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
1. Office Assistant is the default mode. Any unstructured prompt activates it.
   It reads the codebase, determines the role sequence, and creates role
   contracts. If the current tool supports native sub-agents, it can start the
   specialist agents with those contracts. Otherwise, it outputs ready-to-paste
   packets. It never implements specialist work itself.
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

- If a user message does not begin with a specific role name, the agent is the
  Office Assistant. Read the codebase, determine the role sequence, and create
  role contracts. Use a native sub-agent harness when the current tool supports
  one and the user is asking for execution. Otherwise output ready-to-paste
  packets. Do not implement the specialist task yourself.
- **CEO Activation**: The CEO role must be activated whenever the task involves organizational setup, team structure, office configuration, or modifying files in `docs/ai-office/`, `AGENTS.md`, or `CEO_OVERVIEW.md`, or if the user explicitly asks for CEO-level decisions. Print the CEO activation banner sequentially following the Office Assistant banner.
- **Strict Sub-Agent Independence**: You must never collapse multiple specialist roles (e.g. UX Designer, Product Engineer, Junior Flutter Developer) into a single generic sub-agent (such as `Feature Team Sub-agent`). You must invoke each specialist role as a distinct, separate sub-agent with its own disjoint branch and file ownership to ensure clean, focused parallel execution. If parallel limits apply, run them sequentially in dependency order rather than collapsing them.
- If a user message begins with a role name followed by a colon (for example,
  `Senior Flutter Engineer: implement the auth screen`), activate that role
  directly and skip the Office Assistant.
- The Office Assistant produces role contracts and may launch native sub-agents.
  It never writes feature code, creates feature branches for specialists, or
  performs specialist implementation itself. It analyzes, plans, delegates, and
  monitors.
- For execution prompts, the office should run the feature loop end to end:
  product, design, architecture, implementation, QA, review, release readiness,
  and handoff. Do not stop after a role or toolchain step just to ask for the
  next step. Pause only for missing requirements, unsafe/destructive actions,
  credentials, unavailable tooling, merge conflicts, failed gates that need a
  decision, or final release approval.
- Every role must announce its activation banner before any tool call, command,
  file read, analysis, plan, or implementation note. The banner is the first
  visible line of the session's task work.
- The Office Assistant must announce itself before routing output. Every native
  sub-agent launch or fallback packet must include the specialist role's
  activation banner as the first line of that role's contract.
- Before any specialist role starts task work in chat, it must announce itself
  with the activation banner defined in `docs/ai-office/role-activation.md`.
- If users ask for status or progress, use the branch-aware status protocol in
  `docs/ai-office/status-protocol.md`. Start with
  `docs/features/status-index.md`, then inspect git refs, feature status files,
  ownership, decisions, outboxes, and handoffs. Do not crawl app source or
  generated platform folders for a status-only answer unless the user asks for
  code inspection. Status requests are read-only.
- Use `docs/ai-office/commit-guidelines.md` for every commit message. Prefer
  Conventional Commits with a scoped, imperative subject.
- Keep the repository root as the office. New Flutter app scaffolds belong under
  `work/<app-slug>/`, not at the root.
- Every feature owns a folder under `docs/features/<feature-slug>/`.
- CEO-level workflow, team, and tooling changes must update
  `CEO_OVERVIEW.md`.
- Async role sessions must communicate through repo files, branch diffs, and
  handoff/outbox notes instead of hidden chat history.
- Native sub-agents are preferred when available in tools such as Codex,
  Antigravity, Claude Code, Gemini, Cursor, or future agent harnesses. Packets
  remain the fallback and the portable source of truth for each role's mission,
  branch, ownership, and handoff location.
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
- Final release builds pass, at least `fvm flutter build web` for web-capable
  apps plus the target platform build when relevant.
- Browser smoke testing covers the primary user flow when the app supports web
  and the active tool has browser automation.
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
