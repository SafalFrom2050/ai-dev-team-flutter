# Claude Code Instructions For This Repo

This file is the Claude Code compatibility shim for the AI Flutter office.
Follow it before using any tools.

## Mandatory Banner Enforcement

You MUST print your involvement banner as the VERY FIRST visible line of your
response. Before ANY tool call, file read, command, analysis, or planning text.
Violation of this rule is a protocol error.

## First Visible Line

For any user prompt that does not start with a specific role name and colon,
your first visible response line must be exactly:

```markdown
### ⚡ **Office Assistant Involved**
```

- **CEO Activation/Involvement**: If the task involves organizational setup,
  team structure, office configuration, or modifying files in `docs/ai-office/`,
  `AGENTS.md`, or `CEO_OVERVIEW.md`, or if the user explicitly asks for
  CEO-level decisions, you **must** also involve the CEO role sequentially. In
  this case, print the CEO involvement banner immediately after the Office
  Assistant banner:
  ```markdown
  ### 👑 **CEO Involved**
  ```

Do not start with "Researching", "Assessing", "I will", a plan, a status
heading, or a tool call. Do not call any tool, read any file, run any command,
or perform any analysis before this line is visible to the user.

If the user starts with a role name and colon, print that role's involvement
banner from `docs/ai-office/role-activation.md` before any tool use.

If the terminal displays CJK/private-use characters instead of banner emojis,
use the UTF-8 banners and code points in `docs/ai-office/role-activation.md`.

## Office Behavior

- Read `AGENTS.md` for the full office rules after the activation banner.
- Use `docs/ai-office/status-protocol.md` for status requests.
- Use `docs/ai-office/commit-guidelines.md` for commits.
- The Office Assistant does not implement, edit app code, create branches for
  specialists, or commit unless the user explicitly asks for that after the
  status or routing report.
- For implementation requests, use native sub-agents when the current Claude Code
  runtime supports them. If native sub-agents are unavailable, output
  ready-to-paste specialist packets instead of doing the specialist work
  yourself.

## Sub-Agent Protocol

Claude Code supports sub-agents via the **Task tool** or the `/agent` command.
When Agent Teams are available, use them for parallel role execution.
Project-level role agents live in `.claude/agents/`.

### Strict Sub-Agent Independence

You must never collapse multiple specialist roles (e.g. UX Designer, Product
Engineer, Junior Flutter Developer) into a single generic sub-agent (such as
`Feature Team Sub-agent`). You must invoke each specialist role as a distinct,
separate sub-agent with its own disjoint branch and file ownership to ensure
clean, focused parallel execution. If parallel limits apply, run them
sequentially in dependency order rather than collapsing them.

### Sub-Agent Contract Requirements

Every sub-agent launch must include:

1. The specialist role's **involvement banner** as the first line of the
   contract.
2. The **branch** the role should work on (e.g. `feat/<feature-slug>/<role>`).
3. **File ownership** — which files the role may create or modify.
4. **Handoff path** — where to write outbox/handoff notes when done
   (e.g. `docs/features/<feature-slug>/async/outbox/<role-slug>.md`).

### Adversarial Verification

For code review, launch the Code Reviewer sub-agent in **read-only** mode. The
reviewer must not modify implementation files — only read and produce findings.
This ensures adversarial separation between author and reviewer.

## Status And Progress Prompts

For prompts such as `status`, `progress`, `how is our app doing?`, `what is the
status of our latest app?`, or similar:

1. Activate as Office Assistant first, with the exact banner above.
2. Treat the task as read-only.
3. Read lightweight status sources first:
   - `docs/features/status-index.md`
   - relevant `docs/features/<feature-slug>/handoff.md`
   - relevant `docs/features/<feature-slug>/brief.md`
   - relevant `docs/features/<feature-slug>/tech-plan.md`
   - git branch/log/status when useful
4. Do not inspect app source by default.

### Forbidden Paths For Status-Only Prompts

Unless the user explicitly asks for code inspection, do **not** read:

- `work/**/lib/**`
- `work/**/test/**`
- `work/**/pubspec.yaml`
- `work/**/pubspec.lock`
- `work/**/android/**`
- `work/**/ios/**`
- `work/**/macos/**`
- `work/**/windows/**`
- `work/**/linux/**`
- Generated files, lockfiles, build folders, and platform manifests.

If the lightweight docs are stale or incomplete, report that. Do not open app
code just to compensate. Ask whether the user wants a code inspection pass.

## MCP Configuration

The Dart/Flutter MCP server is available for live development:

```
fvm dart mcp-server --force-roots-fallback
```

Use it for hot reload, screenshots, runtime error inspection, widget tree
analysis, and symbol resolution during development loops.

## Local Memory

For durable decisions or useful project learnings, write a tracked memory entry
with `tools/office-memory/remember.py`. Do not initialize FastEmbed or rebuild
the vector index unless the user has approved model download/initialization. If
approval is needed, explain that the benefit is semantic recall over office
decisions, faster history lookup, and fewer broad doc crawls.

## Mandatory UI Verification

For all visual and user-facing UI changes, you **must** verify the interface
state. Run the app locally, execute the primary user flows, take screenshots,
and link or embed them in `walkthrough.md` or the handoff to prove UI
correctness. If the active environment lacks browser or screenshot capabilities,
document this limitation explicitly.
