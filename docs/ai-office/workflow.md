# Workflow

The office workflow turns a rough idea into production code through versioned
artifacts, scoped branches, and explicit handoffs.

## Feature Folder

Every feature gets a folder:

```text
docs/features/<feature-slug>/
  brief.md
  ux.md
  design-contract.md
  tech-plan.md
  handoff.md
  test-plan.md
  release-notes.md
```

Not every file must be long. A short, clear document beats a large vague one.

Product app code belongs under:

```text
work/<app-slug>/
```

Do not initialize Flutter apps at the repository root.

## Branch Flow

0. CEO updates `CEO_OVERVIEW.md` for team, workflow, tooling, and direction
   changes. Durable company-structure changes should start on
   `org/<initiative>` and merge to `org/main`.
1. Release Engineer creates `integrate/<feature-slug>` from `main`.
2. Product Lead creates `product/<feature-slug>` from the integration branch.
3. UI/UX Designer creates `design/<feature-slug>` from the integration branch.
4. Product Engineer creates `arch/<feature-slug>` from the integration branch.
5. Developer agents create `feat/<feature-slug>/<slice>` branches after the
   brief, design contract, and tech plan are approved enough to start.
6. QA/Test Engineer may work in `test/<feature-slug>` in parallel once behavior
   is stable enough to test.
7. All agent PRs target `integrate/<feature-slug>`.
8. The final production PR targets `main`.

## Collaboration Contracts

Each agent branch should declare:

- Role.
- Scope.
- Files owned.
- Files touched outside ownership, if any.
- Test evidence.
- Open questions.
- Follow-up risks.

This is more important than pretending parallel work has no coordination cost.

## Recommended Order

Use this order for most features:

0. CEO confirms the feature fits the office direction.
1. Product brief.
2. UX and design contract.
3. Technical plan.
4. Shared theme/component foundation, if needed.
5. Feature implementation slices.
6. Test pass.
7. Code review fixes.
8. Release PR.

Small changes can compress steps, but should not skip product clarity, review, or
tests.

## Organization Versus Product Work

Use `org/main` for stable company structure. Use product `main` and feature
branches for the app being built.

If a feature needs both product work and office changes, split the work:

- `org/<initiative>`: role, workflow, tooling, template, or governance changes.
- `integrate/<feature-slug>`: user-facing product changes.

## Ownership Map

Before parallel implementation starts, write a simple ownership map in
`handoff.md`:

```text
Agent                     Owns
------------------------  -----------------------------------------
Senior Flutter Engineer   work/my-app/lib/features/auth/, navigation changes
Junior Flutter Developer  work/my-app/lib/shared/widgets/primary_button.dart
QA/Test Engineer          work/my-app/test/features/auth/, work/my-app/integration_test/
UI/UX Designer            docs/features/auth/design-contract.md
```

For a smaller slice, keep the same app-workspace prefix:

```text
Senior Flutter Engineer   work/my-app/lib/features/auth/
QA/Test Engineer          work/my-app/test/features/auth/
```

If two agents need the same file, appoint one owner and have the other agent
submit suggestions through the handoff or a follow-up branch.

## Conflict Strategy

- Prefer small branches with clear ownership.
- Merge product/design/architecture artifacts before implementation branches.
- Rebase or merge the integration branch into long-running feature branches
  before review.
- Resolve semantic conflicts in the integration branch with the owning agents'
  handoffs visible.

## When To Use A Separate Agent Branch

Use a separate branch when:

- The agent owns a distinct artifact or module.
- Work can be reviewed independently.
- The branch can merge cleanly into the integration branch.

Do not split branches just for theater. If two agents are constantly editing the
same file, one agent should own the implementation and the other should review.
