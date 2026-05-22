# User Involvement Contract

The user should not need to remember role names, branch names, workflow steps,
packet paths, or template formats.

Any unstructured prompt is an Office Assistant prompt. The Office Assistant
reads lightweight project docs, determines the role sequence, and creates role
contracts. If the current tool can start native sub-agents, the Office Assistant
uses those contracts to launch the team. If not, it outputs ready-to-paste agent
packets.

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

To skip the Office Assistant and involve a specific role, start your message
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
2. **Native sub-agent launches** when the current tool supports them.
3. **Ready-to-paste packets** as the fallback when native sub-agents are not
   available.
4. Each role contract starts with the role's involvement banner.
5. Each contract includes: role, mission, branch, file ownership, boundaries,
   concurrent agent awareness, and output location.

When native sub-agents are available, the main chat starts those agents for you.
When they are not, you copy-paste each packet into a separate agent session
(Codex, Cursor, Gemini CLI, Antigravity CLI, Claude Code, or any AI coding tool)
and the agent works within its defined boundaries.

For build or fix requests, the office should continue across roles until the
feature is release-ready, blocked, or waiting for final approval. The user should
not have to ask for the next role after every handoff or toolchain step.

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
   `### ⚡ **Office Assistant Involved**`
2. Reads `AGENTS.md` for team rules.
3. Reads `CEO_OVERVIEW.md` for current office state and open items.
4. Reads `docs/ai-office/role-activation.md` for banner text.
5. Reads `docs/features/status-index.md` when the prompt asks for status or
   refers to an existing feature.
6. Checks the current git branch and status.
7. If a feature folder exists, reads its lightweight docs and handoffs for prior
   context.
8. Checks whether the current tool can create native sub-agents for the selected
   roles.

Then it produces the phase plan. If native sub-agents are available and the task
is an execution task, it starts them. If not, it prints the packet fallbacks.

For execution tasks, the Office Assistant or main chat keeps orchestrating the
next clear step. It only stops to ask the user when a blocker, permission,
credential, device requirement, destructive operation, merge conflict, unclear
failed gate, or final release decision needs human input.

For status-only prompts, it should not scan `work/<app-slug>/lib`, platform
folders, generated files, lockfiles, or build output unless the user asks for
implementation-level inspection.

## Portable Starter Prompt

For AI tools that need explicit instructions, this prompt bootstraps the Office
Assistant behavior:

```text
<task>

You are the Office Assistant for this project. Read AGENTS.md for rules.
First print the Office Assistant involvement banner from
docs/ai-office/role-activation.md before using tools. Analyze the lightweight
project docs, determine the role sequence and file ownership, and create role
contracts. If this tool can start native sub-agents, launch the relevant roles
with those contracts. If it cannot, output ready-to-paste packets. Each contract
or packet must start with the target role's involvement banner. Do not implement
the specialist task yourself.
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
Unstructured prompt -> Office Assistant -> role contracts -> native sub-agents
or packet fallback -> agents work within boundaries -> gates and review ->
release-ready handoff or blocker
```

The user calls the office. The office produces the instructions.
