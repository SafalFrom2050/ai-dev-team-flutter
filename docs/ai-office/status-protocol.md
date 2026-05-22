# Status Protocol

Status requests are a coordination task, not a code review.

The Office Assistant should answer "where are we?" without loading a large app
into context. It should use the repository's lightweight status artifacts first,
then only inspect code when the user explicitly asks for code-level detail.

## Involvement

The first visible line must be:

```markdown
### ⚡ **Office Assistant Involved**
```

This line comes before any shell command, file read, git query, or summary.

## Source Order

For `status`, `progress`, `where are we?`, or similar prompts, read in this
order:

1. `AGENTS.md`
2. `docs/features/status-index.md`
3. The requested feature folder under `docs/features/<feature-slug>/`
4. `docs/features/<feature-slug>/async/status.md`
5. `docs/features/<feature-slug>/async/ownership.md`
6. `docs/features/<feature-slug>/async/outbox/*.md`
7. `docs/features/<feature-slug>/handoff.md`
8. Git refs and recent commits for the relevant branches

Only read app source files after this if the user asks for implementation
inspection, bug diagnosis, review, or exact code evidence.

## Branch-Aware Checks

The current checkout is not always the source of truth. A feature may be active
on `integrate/<feature-slug>`, `feat/<feature-slug>/<slice>`, or another remote
branch.

Use branch-native git reads instead of switching branches for status:

```powershell
git branch --list -a "*<feature-slug>*"
git log --oneline --decorate --max-count=10 <branch>
git show <branch>:docs/features/status-index.md
git show <branch>:docs/features/<feature-slug>/handoff.md
git ls-tree -r --name-only <branch> -- docs/features/<feature-slug>
```

If the user explicitly asks to switch branches, check `git status --short` first,
then switch only if Git can do so safely. After switching, keep the status pass
read-only.

## Context Budget

Status mode may inspect:

- Git branch, log, diff stats, and file lists.
- Feature briefs, design contracts, tech plans, test plans, handoffs, outboxes,
  and release notes.
- `docs/features/status-index.md`.
- Package decision docs if the status question is dependency-related.

Status mode must not inspect by default:

- `work/<app-slug>/lib/**`
- `work/<app-slug>/android/**`
- `work/<app-slug>/ios/**`
- `work/<app-slug>/build/**`
- generated registrants, lockfiles, or platform scaffolds

Exceptions are allowed only when the user asks for code review, debugging,
implementation details, or exact file evidence.

## Status Index

Every product branch should keep `docs/features/status-index.md`. It is the
Office Assistant's first stop for project state.

Each feature entry should include:

- Feature slug and app workspace.
- Current source-of-truth branch.
- Current state.
- Last known quality gates.
- Manual QA status.
- Open blockers or risks.
- Pointers to the feature docs and handoff.
- Last updated date and role.

If the status index is stale or missing, say so. Then fall back to handoffs and
git refs, and recommend that the owning role update the index.

## Response Shape

Keep status answers concise:

```text
Feature: <name>
Source of truth: <branch/path>
Current checkout: <branch>
State: <one-line status>
Done: <completed work>
Open: <remaining work, risks, or missing QA>
Next: <recommended next action>
Evidence: <small list of files/commits read>
```

Avoid implementation packets unless the user asks to continue work. Status means
report first; action comes after explicit follow-up.
