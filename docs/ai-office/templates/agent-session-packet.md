# Agent Role Contract: <role>

Use this file as a native sub-agent prompt when the runtime supports sub-agents.
If not, paste it into a separate agent session as the packet fallback.

## Role

<role name>

## Activation Banner

Paste the matching line from `docs/ai-office/role-activation.md` as the first
visible line in the role session or sub-agent prompt.

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

Use `docs/ai-office/commit-guidelines.md` for commit messages.

Commit your work, update `docs/features/status-index.md` if feature state
changed, and write your summary to:

```text
docs/features/<feature-slug>/async/outbox/<role-slug>.md
```

## Stop Conditions

Stop and write a blocker note if:

- A required input file is missing or contradictory.
- You need to edit a file outside your ownership.
- The mission is ambiguous enough that you might break another agent's work.
