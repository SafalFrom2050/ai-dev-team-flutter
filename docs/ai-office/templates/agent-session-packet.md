# Agent Session Packet: <role>

## Role

<role name>

## Activation Banner

Paste the matching line from `docs/ai-office/role-activation.md` as the first
visible line in the role session.

## Mission

What should this role accomplish? Keep to one to three sentences.

## Branch

`<branch-name>`

## Files Owned

These are the only files this agent should create or modify:

- <owned paths>

## Files To Avoid

These files are owned by other agents or are out of scope:

- 

## Other Agents Working Now

Who else is running concurrently and what do they own?

- <concurrent role ownership, or "none">

## Context

Read these files before starting:

- `AGENTS.md`
- <task-specific context files>

## When Done

Commit your work and write your summary to:

```text
docs/features/<feature-slug>/async/outbox/<role-slug>.md
```

## Stop Conditions

Stop and write a blocker note if:

- A required input file is missing or contradictory.
- You need to edit a file outside your ownership.
- The mission is ambiguous enough that you might break another agent's work.
