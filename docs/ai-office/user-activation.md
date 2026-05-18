# User Activation Contract

The user should not need to remember branch names, workflow steps, packet paths,
or role order.

In any AI tool, the user should be able to make a natural request and rely on the
Office Assistant to orient itself from the repository.

## Minimal Prompt

Use this in a new chat session:

```text
Office Assistant: <task>
```

Examples:

```text
Office Assistant: I want to start an idea for a habit tracker app.
```

```text
Office Assistant: I found a layout bug in the dashboard. Route this to the right
role and prepare the next steps.
```

```text
Office Assistant: Add onboarding to the app.
```

## What The User Does Not Need To Specify

The user does not need to specify:

- Which role owns the work.
- Which branch to create.
- Whether to use `org/main`, `main`, or `integrate/<feature>`.
- Which workflow document to read.
- Which packet template to use.
- Which handoff file to update.
- Whether the task is product, design, engineering, QA, review, release, or org
  work.

The Office Assistant figures that out from the repo.

## What The Office Assistant Must Do First

In a fresh session, the Office Assistant must orient itself before acting:

1. Read `README.md`.
2. Read `AGENTS.md`.
3. Read `CEO_OVERVIEW.md`.
4. Read `docs/ai-office/task-triage.md`.
5. If the task may change company structure, read
   `docs/ai-office/org-branch-model.md`.
6. If the task involves parallel roles, read
   `docs/ai-office/async-agent-runtime.md`.
7. Check the current git branch and status.

Only then should it choose the role sequence and branch plan.

## Office Assistant Default Response

For any incoming task, the Office Assistant should respond with:

```text
Task type:
Recommended owner:
Supporting roles:
Branch plan:
Files or packets to create:
First action:
Clarification needed:
```

If no clarification is needed, it should proceed.

## Branch Choice Rules

The Office Assistant chooses branches as follows:

- Company/process/tooling/role change: `org/<initiative>` from `org/main`.
- New product feature: `integrate/<feature-slug>` from `main`.
- Product brief: `product/<feature-slug>` from the integration branch.
- Design work: `design/<feature-slug>` from the integration branch.
- Architecture work: `arch/<feature-slug>` from the integration branch.
- Implementation: `feat/<feature-slug>/<slice>` from the integration branch.
- QA/test work: `test/<feature-slug>` from the integration branch.
- Review fixes: `fix/<feature-slug>/<issue>` from the integration branch.

The user can override the branch plan, but should not have to provide one.

## New Tool Session Prompt

For maximum portability across Codex, Gemini CLI, Cursor, Claude Code, and other
AI coding tools, this is the recommended starter prompt:

```text
Office Assistant: <task>

Before acting, orient from README.md, AGENTS.md, CEO_OVERVIEW.md, and
docs/ai-office/task-triage.md. Choose the right role sequence, branch plan, and
files to update. Use repo files as shared memory and do not rely on hidden chat
history.
```

This prompt is optional but useful when the tool has no prior conversation.

## If The Tool Cannot Edit Files

If an AI tool cannot directly edit files, it should still produce:

- The recommended role sequence.
- The branch plan.
- The packet contents.
- The handoff contents.
- The exact file paths where the user should place them.

## If The Task Is Too Vague

Ask the minimum useful clarification.

Good:

```text
What is the target user and the main outcome you want?
```

Avoid asking the user to choose internal office mechanics unless the task truly
depends on that choice.

## User Rule

The user calls the Office Assistant. The Office Assistant calls the office.

