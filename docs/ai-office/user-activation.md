# User Activation Contract

The user should not need to remember role names, branch names, workflow steps,
packet paths, or template formats.

Any unstructured prompt is an Office Assistant prompt. The Office Assistant
reads lightweight project docs, determines the role sequence, and outputs
ready-to-paste agent packets.

## Just Type Your Task

No prefix needed. These all activate the Office Assistant:

```text
I want to start an idea for a habit tracker app.
```

```text
add onboarding to the timer app
```

```text
I found a layout bug in the dashboard. The timer overflows at 61 minutes.
```

```text
status
```

```text
give me progress on the onboarding feature
```

## Direct Role Invocation

To skip the Office Assistant and activate a specific role, start your message
with the role name and a colon:

```text
Senior Flutter Engineer: implement the auth screen using the design contract
in docs/features/auth/design-contract.md
```

```text
QA/Test Engineer: write widget tests for the onboarding card
```

This goes directly to that specialist. The Office Assistant does not intervene.

## What You Get Back

For any unstructured task, the Office Assistant produces:

1. A **phase plan** showing which roles run and in what order.
2. **Ready-to-paste packets** for each agent session.
3. Each packet starts with the role's activation banner.
4. Each packet includes: role, mission, branch, file ownership, boundaries,
   concurrent agent awareness, and output location.

You copy-paste each packet into a separate agent session (Codex, Cursor, Gemini
CLI, Claude Code, or any AI coding tool) and the agent works within its defined
boundaries.

## What You Do Not Need To Specify

- Which role owns the work.
- Which branch to create.
- Whether to use `org/main`, `main`, or `integrate/<feature>`.
- Which workflow document to read.
- Which template to use.
- Which files each agent should own or avoid.
- Whether agents can run in parallel.

The Office Assistant figures all of that out from the repository's office docs,
feature docs, and git state.

## What The Office Assistant Does First

In a fresh session, the Office Assistant:

1. Announces:
   `Office Assistant Activated: I am your Office Assistant and responsible for analyzing tasks and producing ready-to-paste agent packets.`
2. Reads `AGENTS.md` for team rules.
3. Reads `CEO_OVERVIEW.md` for current office state and open items.
4. Reads `docs/ai-office/role-activation.md` for banner text.
5. Reads `docs/features/status-index.md` when the prompt asks for status or
   refers to an existing feature.
6. Checks the current git branch and status.
7. If a feature folder exists, reads its lightweight docs and handoffs for prior
   context.

Then it produces the phase plan and ready-to-paste packets.

For status-only prompts, it should not scan `work/<app-slug>/lib`, platform
folders, generated files, lockfiles, or build output unless the user asks for
implementation-level inspection.

## Portable Starter Prompt

For AI tools that need explicit instructions, this prompt bootstraps the Office
Assistant behavior:

```text
<task>

You are the Office Assistant for this project. Read AGENTS.md for rules.
First print the Office Assistant activation banner from
docs/ai-office/role-activation.md before using tools. Analyze the lightweight
project docs, determine the role sequence and file ownership, and output
ready-to-paste agent packets. Each packet must start with the target role's
activation banner. Do not implement the task yourself.
```

This prompt is optional when `AGENTS.md` is already loaded as a project rule.

## If The Tool Cannot Edit Files

If an AI tool cannot directly edit files, the Office Assistant should still
produce:

- The phase plan.
- The complete packet text for each agent.
- The exact branch names and file paths.

The user can then paste these into tools that can edit files.

## If The Task Is Too Vague

Ask the minimum useful clarification:

```text
What is the target user and the main outcome you want?
```

Do not ask the user to choose internal office mechanics.

## Summary

```text
Unstructured prompt -> Office Assistant -> ready-to-paste packets -> user pastes
into agent sessions -> agents work within boundaries -> handoffs through outbox
```

The user calls the office. The office produces the instructions.
