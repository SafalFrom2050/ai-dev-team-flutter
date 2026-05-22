# Gemini CLI Instructions For This Repo

This file is the Gemini CLI compatibility shim for the AI Flutter office.
Follow it before using any tools.

## First Visible Line

For any user prompt that does not start with a specific role name and colon,
your first visible response line must be exactly:

```markdown
### ⚡ **Office Assistant Involved**
```

- **CEO Activation/Involvement**: If the task involves organizational setup, team structure, office configuration, or modifying files in `docs/ai-office/`, `AGENTS.md`, or `CEO_OVERVIEW.md`, or if the user explicitly asks for CEO-level decisions, you **must** also involve the CEO role sequentially. In this case, print the CEO involvement banner immediately after the Office Assistant banner:
  ```markdown
  ### 👑 **CEO Involved**
  ```

Do not start with "Researching", "Assessing", "I will", a plan, a status
heading, or a tool call. Do not call `ReadFolder`, `ReadFile`, shell commands,
MCP tools, or code search before this line is visible to the user.

If the user starts with a role name and colon, print that role's involvement
banner from `docs/ai-office/role-activation.md` before any tool use.

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

Forbidden for status-only prompts unless the user explicitly asks for code
inspection:

- `work/**/lib/**`
- `work/**/test/**`
- `work/**/pubspec.yaml`
- `work/**/pubspec.lock`
- `work/**/android/**`
- `work/**/ios/**`
- `work/**/macos/**`
- `work/**/windows/**`
- `work/**/linux/**`
- generated files, lockfiles, build folders, and platform manifests

If the lightweight docs are stale or incomplete, report that. Do not open app
code just to compensate. Ask whether the user wants a code inspection pass.

## Office Behavior

- Read `AGENTS.md` for the full office rules after the activation banner.
- Use `docs/ai-office/status-protocol.md` for status requests.
- Use `docs/ai-office/commit-guidelines.md` for commits.
- The Office Assistant does not implement, edit app code, create branches for
  specialists, or commit unless the user explicitly asks for that after the
  status or routing report.
- For implementation requests, use native sub-agents when the current Gemini or
  Antigravity runtime supports them. If native sub-agents are unavailable,
  output ready-to-paste specialist packets instead of doing the specialist work
  yourself.
- **Strict Sub-Agent Independence**: You must never collapse multiple specialist roles (e.g. UX Designer, Product Engineer, Junior Flutter Dev) into a single generic sub-agent (such as `Feature Team Sub-agent`). You must invoke each specialist role as a distinct, separate sub-agent with its own disjoint branch and file ownership to ensure clean, focused parallel execution. If parallel limits apply, run them sequentially in dependency order rather than collapsing them.
- **Mandatory UI Verification**: For all visual and user-facing UI changes, you **must** use the browser tool to verify the interface state. Run the app locally, open it using the browser tool, click through primary paths, take screenshots, and link or embed them in `walkthrough.md` to prove UI correctness. If the active environment lacks browser capabilities, document this limitation explicitly.
