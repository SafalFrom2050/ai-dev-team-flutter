# Commit Guidelines

Use clear, searchable commit messages. The office standard is Conventional
Commits with a scoped, imperative subject.

## Format

```text
<type>(<scope>): <imperative summary>

<why this changed, when useful>

Refs: <issue/pr/feature doc, when useful>
```

Examples:

```text
docs(office): add branch-aware status protocol
```

```text
feat(timer): add Android foreground service wrapper
```

```text
test(timer): cover pause and reset states
```

## Types

- `feat`: user-visible feature or capability.
- `fix`: bug fix.
- `docs`: documentation, office process, briefs, handoffs, or release notes.
- `test`: tests, fixtures, mocks, or QA evidence.
- `refactor`: code restructuring without behavior change.
- `perf`: performance improvement.
- `build`: build system, dependencies, generated build metadata.
- `ci`: CI configuration.
- `chore`: maintenance that does not fit another type.
- `revert`: reverts a prior commit.

## Scopes

Use a short noun that makes the commit easy to search:

- `office`
- `workflow`
- `status`
- `timer`
- `android`
- `design`
- `qa`
- `release`

Prefer product or feature scopes for app work, and `office` or `workflow` for
company operating-system changes.

## Subject Rules

- Use the imperative mood: `add`, `fix`, `document`, `move`, `sync`.
- Keep the subject under 72 characters when practical.
- Do not end the subject with a period.
- Avoid vague subjects such as `updates`, `fixes`, `changes`, or `wip`.
- Mention the specific product area or workflow in the scope.

## Body Rules

Add a body when the "why" is not obvious, when the commit changes a workflow, or
when reviewers need risk context.

Good body content:

- Why the change exists.
- What constraints mattered.
- Follow-up risk or migration notes.
- Test evidence for risky code changes.

## AI Role Handoff

Each role's handoff should include the commit it created or the exact proposed
commit message if it did not commit.

For generated or tool-heavy Flutter changes, separate the intent from generated
artifacts when practical:

```text
feat(timer): add notification-backed background countdown
build(timer): refresh Flutter platform registrants
test(timer): update widget tests for background service state
```

Do not rewrite published history just to improve old messages unless the CEO or
Release Engineer explicitly asks for a history cleanup.
