# Feature Status Index

This file is the Office Assistant's first stop for progress checks. Product
branches should keep it current so status requests do not require reading the
whole app or relying on hidden chat history.

## How To Update

Add one entry per active or recently shipped feature. Keep entries short and
link to the detailed feature folder.

```text
## <Feature Name>

- Slug: `<feature-slug>`
- App workspace: `work/<app-slug>/`
- Source of truth: `<branch-name>`
- State: `<idea | planned | in progress | review | ready | shipped | blocked>`
- Last quality gates: `<commands and result, or unknown>`
- Manual QA: `<not started | partial | done | not applicable>`
- Current owner: `<role or branch>`
- Open risks: `<short list>`
- Docs: `docs/features/<feature-slug>/`
- Handoff: `docs/features/<feature-slug>/handoff.md`
- Last updated: `<YYYY-MM-DD> by <role>`
```

If an entry is stale, update it before asking another role for status.
