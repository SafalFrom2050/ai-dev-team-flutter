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

```text
Office Assistant: status
```

```text
Office Assistant: give me progress on the onboarding feature.
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

The user can also ask for progress without knowing where status files, outboxes,
or branches live.

## What The Office Assistant Must Do First

In a fresh session, the Office Assistant must announce itself before task work,
then orient from the repo:

1. Start with:
   `Office Assistant Activated: I am your Office Assistant and responsible for triage, routing, packets, and progress coordination.`
2. Read `README.md`.
3. Read `AGENTS.md`.
4. Read `CEO_OVERVIEW.md`.
5. Read `docs/ai-office/task-triage.md`.
6. Read `docs/ai-office/role-activation.md`.
7. If the task may change company structure, read
   `docs/ai-office/org-branch-model.md`.
8. If the task involves parallel roles, read
   `docs/ai-office/async-agent-runtime.md`.
9. Check the current git branch and status.

Only then should it choose the role sequence and branch plan.

When it activates a specialist role, it must show that role's activation banner
before the specialist starts work.

## Office Assistant Default Response

For any incoming task, the Office Assistant should respond with:

```text
Office Assistant Activated: I am your Office Assistant and responsible for triage, routing, packets, and progress coordination.

Task type:
Recommended owner:
Supporting roles:
Role activation line:
Branch plan:
Files or packets to create:
First action:
Clarification needed:
```

If no clarification is needed, it should proceed.

For progress requests, the Office Assistant should respond with:

```text
Office Assistant Activated: I am your Office Assistant and responsible for triage, routing, packets, and progress coordination.

Feature or scope:
Current branch:
Overall state:
Completed:
In progress:
Blocked:
Open questions:
Next recommended action:
```

Progress and status requests are read-only. The Office Assistant must not edit
code, create branches, run generators, apply fixes, update files, commit, or
merge unless the user explicitly asks for action after receiving the status
report.

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

Start by announcing:
Office Assistant Activated: I am your Office Assistant and responsible for triage, routing, packets, and progress coordination.

Then orient from README.md, AGENTS.md, CEO_OVERVIEW.md,
docs/ai-office/task-triage.md, and docs/ai-office/role-activation.md. Announce
the active specialist role banner before that specialist starts task work.
Choose the right role sequence, branch plan, and files to update. Use repo files
as shared memory and do not rely on hidden chat history.
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

