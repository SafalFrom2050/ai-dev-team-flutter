# Agent Role Contract: <role>

Use this file as the portable packet for a role session. When the runtime
supports and permits native sub-agents, the same completed packet can be used as
the sub-agent prompt. In Codex, pass it to `multi_agent_v1.spawn_agent` only
when the user explicitly asks for sub-agents, delegation, or parallel agent
work, or when runtime policy otherwise permits native spawning. If native
spawning is not available or not allowed, paste it into a separate agent session
as the packet fallback.

## Role

<role name>

## Activation Banner

Paste the matching line from `docs/ai-office/role-activation.md` as the first
visible line in the role session or sub-agent prompt.

For permitted Codex native sub-agents, this banner must be the first line of the
`spawn_agent` prompt.

## Mission

What should this role accomplish? Keep to one to three sentences.

## Context Budget

- Task tier: <T0/T1/T2/T3/T4 from docs/ai-office/token-budgeting.md>
- Model route: <recommended Codex model/reasoning route>
- Memory cap: <none / top 3-5 hits, then read source files>
- Native sub-agent: <not allowed / allowed if requested / required and why>

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

## Native Harness Notes

- Codex: launch with one `multi_agent_v1.spawn_agent` call for this role only
  when the user explicitly asks for sub-agents, delegation, or parallel agent
  work, or runtime policy otherwise permits native spawning.
- Use the matching role-specific Codex `agent_type` when available.
- Do not combine this role with another specialist role in one agent.
- Keep `fork_context` false unless this packet explicitly requires hidden chat
  history.

## Context

Read these files before starting:

- `AGENTS.md`
- `docs/features/<feature-slug>/async/context-summary.md` first for T3/T4 work
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
