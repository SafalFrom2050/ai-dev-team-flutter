# Context Compression Protocol

This protocol addresses the challenge of context accumulation in long-running feature loops. As an initiative moves through Product, Design, Architecture, Implementation, and QA, the chat context becomes bloated. This protocol defines how to compress that history into a single, structured summary so subsequent roles can spin up instantly.

## The Problem

When a developer agent takes over a feature branch, reading the entire conversation history of the Product Lead, UX Designer, and Product Engineer uses up valuable context space. This leads to model distraction, higher token costs, and slow response times.

## The Solution

Instead of reading old chat history, the main orchestrator (or handoff role) writes a compressed context summary to the repository at:

```text
docs/features/<feature-slug>/async/context-summary.md
```

Subsequent agents read ONLY this summary and the active branch codebase, keeping their context budgets clean.

## When to Use

- **First Compression**: Immediately after the Product Lead, Designer, and Architect finish the planning phase (before developers start coding).
- **Updates**: After each major role handoff (e.g., Senior Developer handoff to QA).
- **Handoff Rules**: Refer to [Async Agent Runtime](file:///d:/Workspace/Personal/ai-dev-team-flutter/docs/ai-office/async-agent-runtime.md) for context budgeting limits.

## Context Summary Template

Every `context-summary.md` must follow this structure:

```markdown
# Context Summary: [Feature Name]

Last Updated: YYYY-MM-DD
Updated By: [Role Name]
Current Branch: [branch-name]

## 1. Executive Status
- **Current Phase**: [e.g., Planning / Implementation / QA / Release]
- **Target App**: [e.g., work/minimal-timer-app]
- **Completed Roles**: [e.g., Product Lead, UI/UX Designer]

## 2. Key Decisions & Specifications
Brief list of architectural, design, or business rule choices already approved:
- **Decision 1**: [Description]
- **Decision 2**: [Description]

## 3. File Ownership Map
Which roles currently own or have modified specific directories or files:
- **Product Engineer**: [docs/features/<feature>/tech-plan.md]
- **Senior Flutter Engineer**: [work/<app>/lib/core/**]
- **Junior Flutter Developer**: [work/<app>/lib/features/dashboard/**]

## 4. Remaining Checklist
Condensed TODO list for the next active role:
- [ ] Task 1
- [ ] Task 2

## 5. Reference Links
- [Brief](file:///d:/Workspace/Personal/ai-dev-team-flutter/docs/features/<feature-slug>/brief.md)
- [Design Contract](file:///d:/Workspace/Personal/ai-dev-team-flutter/docs/features/<feature-slug>/design-contract.md)
- [Tech Plan](file:///d:/Workspace/Personal/ai-dev-team-flutter/docs/features/<feature-slug>/tech-plan.md)
```

## Orchestrator Duty

Before booting a subagent (such as Codex or Claude Code), the main orchestrator must:
1. Verify if `context-summary.md` exists and is up to date.
2. If stale or missing, compile the recent outbox reports and write an updated `context-summary.md`.
3. Provide ONLY the path to the summary file as the input context for the next subagent, rather than pasting historical logs.
