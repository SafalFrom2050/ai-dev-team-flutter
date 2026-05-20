# AI Dev Team Flutter

![AI Dev Team Flutter: from idea to production main](docs/assets/readme/featured.png)

An experimental Flutter studio where AI agents work like a real product team,
with role-specific sub-agents, repo-backed memory, Flutter quality gates, and a
production `main` branch.

This repo is not just a Flutter app. It is an office: a structured collaboration
system for taking a rough idea, shaping it through product and design, building
it with Flutter specialists, testing it, reviewing it, and merging only
production-ready work into `main`.

The ambition is simple and slightly dangerous in the best engineering way:
build the best Flutter AI dev team in the world.

## The Big Idea

This project is not a prompt collection and not a single chatbot with a bigger
context window. It is an **AI dev office**: one main chat acts like the CEO or
Office Assistant, then launches specialist sub-agents for product, design,
architecture, Flutter implementation, QA, code review, and release.

![Native sub-agent harness for the AI Flutter office](docs/assets/readme/subagent-harness.svg)

The main chat should stay light: it routes work, monitors branch state, reads
handoffs, and decides when to ask the user. The specialist agents do the deep
work inside their own context windows and leave durable output in the repo.

| Office Primitive | What It Does |
|---|---|
| Main chat | Orchestrates the whole feature run from idea to release-ready handoff. |
| Role contracts | Give each sub-agent its mission, branch, file ownership, and handoff path. |
| Native sub-agents | Let supported tools run specialists in parallel without bloating one chat. |
| Packet fallback | Keeps the same workflow portable when a tool cannot create sub-agents. |
| Repo memory | Stores decisions in docs, branches, commits, status files, and outboxes. |

## Why Sub-Agents Are The Headline

Large Flutter projects are too much for one chat to hold cleanly. Product intent,
screen states, architecture decisions, implementation details, test evidence,
browser checks, and release risk all compete for context. This office splits that
work by role.

![Why role-specific sub-agents scale better than one giant chat](docs/assets/readme/agent-context-scaling.svg)

Role-specific sub-agents make the office stronger because:

- Product, design, architecture, implementation, QA, and review each get focused
  context instead of fighting inside one long transcript.
- Parallel work becomes safer because every agent has explicit branch and file
  ownership.
- The main chat can keep moving through the feature loop instead of asking the
  user to manually trigger each next step.
- Failed or weak role output can be retried from the same role contract without
  replaying the whole project.
- Handoffs and outboxes make progress inspectable by Codex, Antigravity, Claude
  Code, Gemini, Cursor, or a future tool.

Antigravity 2.0 is especially interesting here because its agent harness maps
directly onto this design: a main conversation can spin up specialist workers,
background jobs, managed agents, and SDK/CLI-driven workflows from the same
Markdown role contracts. Other platforms should work through the same contract,
but this repo is honest about the current state: Antigravity is the clearest fit
so far; other sub-agent harnesses still need more real project testing.

## Open Source

AI Dev Team Flutter is open source under the MIT License.

- License: `LICENSE`
- Contributing guide: `CONTRIBUTING.md`
- Code of conduct: `CODE_OF_CONDUCT.md`
- Security policy: `SECURITY.md`

Contributions are welcome when they make the office clearer, more useful, more
Flutter-native, or more reliable.

## What This Project Is

Most AI coding workflows treat the assistant like one very busy developer. This
project treats AI as a team.

Each role has a job:

- The CEO keeps the office coherent.
- The Office Assistant turns unstructured tasks into role contracts, launches
  native sub-agents when available, and prints packets as fallback.
- The Product Lead clarifies what is worth building.
- The UI/UX Designer makes the experience implementable.
- The Product Engineer turns intent into architecture.
- Flutter developers build focused slices.
- QA proves behavior.
- Code Review protects quality.
- Release Engineering protects `main`.

The result should feel less like random code generation and more like walking
into a serious Flutter studio where every agent knows where to sit, what to own,
and when to hand off.

## Office Entrance

Welcome to the office architecture. Every feature starts as a conversation, then
becomes native sub-agents or packets, branches, handoffs, review, and finally
production code.

![AI Flutter Office architecture](docs/assets/readme/office-round-table.svg)

The diagram is intentionally simple: prompts enter through the Office Assistant,
role contracts create scoped branch work through native sub-agents or packet
fallbacks, the repository preserves memory, and the delivery pipeline protects
`main`. Each role owns a different kind of decision: product and design clarify
intent, engineering builds, QA and review protect quality, and release protects
production.

CEO-level decisions live in `CEO_OVERVIEW.md`.

## The Production Path

The office does not let every agent write straight to `main`.

![AI Flutter Office production path](docs/assets/readme/production-path.svg)

The path is intentionally gated: product, design, and architecture artifacts
come before implementation; tests and review come before release; only release
work moves into production `main`.

Work happens through an integration branch:

```text
main
  integrate/<feature-slug>
    product/<feature-slug>
    design/<feature-slug>
    arch/<feature-slug>
    feat/<feature-slug>/<slice>
    test/<feature-slug>
    fix/<feature-slug>/<issue>
```

`main` is production. `integrate/<feature-slug>` is the office workbench.

The office itself has a longer-lived home:

```text
org/main
```

`org/main` is the company operating system: roles, workflows, templates, skills,
MCP config, FVM setup, and CEO memory. Product `main` is where the current app
becomes production code. New products can start from `org/main` without
reinventing the office.

## Workspace Layout

The repository root is the office. Product apps live under `work/`.

```text
.
  AGENTS.md
  CEO_OVERVIEW.md
  docs/
  work/
    <app-slug>/
      lib/
      test/
      android/
      ios/
      web/
```

This keeps generated Flutter platform folders from taking over the office lobby.

Create new Flutter apps like this:

```powershell
fvm flutter create --project-name <dart_package_name> work/<app-slug>
```

Run app commands from the app workspace:

```powershell
Push-Location work/<app-slug>
fvm flutter pub get
fvm flutter analyze
fvm flutter test
Pop-Location
```

## Why It Is Flutter-Native

This office is tuned for Flutter, not generic app development.

Flutter work must account for:

- Widget tree clarity.
- Route contracts.
- Loading, empty, error, disabled, ready, and success states.
- Responsive layout across phone, tablet, desktop, keyboard, and text scaling.
- `ThemeData`, tokens, reusable widgets, and semantics.
- Unit, widget, integration, and golden tests.
- Flutter-specific review risks such as layout overflow, hidden state ownership,
  broad rebuilds, async context bugs, and brittle tests.

The docs under `docs/ai-office/` describe how each agent handles those concerns.

## Tooling

This repo uses FVM as the Flutter cockpit.

```powershell
fvm flutter --version --no-version-check
fvm dart --version
fvm dart mcp-server --help
```

Current verified local setup:

- FVM is installed.
- This repo is pinned with `.fvmrc` to `stable`.
- FVM resolves Flutter `3.38.8`.
- FVM resolves Dart `3.10.7`.
- `fvm dart mcp-server --help` works.

Project-local MCP configs are included for tools that support them:

- `.cursor/mcp.json`
- `.gemini/settings.json`
- `GEMINI.md`

The MCP configs launch:

```powershell
fvm dart mcp-server --force-roots-fallback
```

`GEMINI.md` is the Gemini CLI instruction shim. It makes Gemini announce the
active role before tools and keeps status prompts on lightweight docs instead of
scanning app source.

Official Flutter and Dart agent skills are installed in `.agents/skills`, with
their hashes recorded in `skills-lock.json`.

## How To Fire Up The Office

Just describe your task. No prefix needed:

```text
I want to build a habit tracker app.
```

```text
add onboarding to the timer app
```

```text
fix the timer overflow bug where it shows 61 minutes
```

Any unstructured prompt activates the Office Assistant, which reads lightweight
office and feature docs, determines the role sequence, and creates
**role contracts**.

If the current tool supports native sub-agents, the Assistant can start the
roles directly. If not, it outputs ready-to-paste packets for separate sessions
(Codex, Cursor, Gemini CLI, Antigravity CLI, Claude Code, or any AI tool), and
each agent works within its defined scope.

For build or fix requests, the office should keep going until the feature is
release-ready, blocked, or waiting for final approval. You should not have to
ask it to run the next role after each toolchain checkpoint.

When using Gemini CLI, start it from the repo root so it loads `GEMINI.md`:

```powershell
gemini
```

If you are already inside a Gemini session after pulling new office rules, run
`/memory reload` or restart the session.

To skip the Office Assistant and invoke a specific role directly:

```text
Senior Flutter Engineer: implement the auth screen
```

Ask for progress at any time:

```text
status
```

```text
give me progress on onboarding
```

Status mode is read-only and branch-aware. The Assistant starts with
`docs/features/status-index.md`, handoffs, outboxes, and git refs instead of
crawling app source or generated platform folders.

### Role Activation In Action

Every role announces itself before work starts. The CEO example shows office
governance activation, while the Office Assistant examples show unstructured
status prompts being routed through a lightweight, read-only status protocol.
The same contract is portable across tools: Codex gets it through `AGENTS.md`,
while Gemini CLI gets it through `GEMINI.md`.

**CEO**

![CEO activation](docs/assets/readme/ceo-activation.png)

**Office Assistant - Codex**

![Office Assistant activation in Codex](docs/assets/readme/office-assistant-activation.png)

**Office Assistant - Gemini CLI**

![Office Assistant activation in Gemini CLI](docs/assets/readme/office-assistant-activation-gemini.png)

### What A Packet Looks Like

The Office Assistant outputs prompts like this for each agent:

```text
Senior Flutter Engineer Activated: I am your senior Flutter engineer and responsible for complex implementation, shared patterns, state, navigation, and platform risk.

You are the Senior Flutter Engineer for this project.
Read AGENTS.md for team rules.

Mission: build the onboarding screen shell and route registration.
Branch: feat/onboarding/senior-navigation
You own: work/minimal-timer-app/lib/features/onboarding/
Do NOT edit: work/minimal-timer-app/lib/shared/widgets/
Other agents: Junior Flutter Developer is working on shared widgets.
When done: commit using docs/ai-office/commit-guidelines.md and write summary to
  docs/features/onboarding/async/outbox/senior-flutter-engineer.md
```

Each role runs in a separate session on its own branch with disjoint file
ownership. The integration branch is where everything comes together.

## Quality Gates

Once the Flutter app scaffold exists, the default gates are:

```powershell
Push-Location work/<app-slug>
fvm flutter pub get
fvm dart format --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
fvm flutter build web
Pop-Location
```

Release candidates should also earn target platform checks:

```powershell
Push-Location work/<app-slug>
fvm flutter build apk --debug
Pop-Location
```

For web-capable features, QA or Release Engineering should use browser tools
when available to open the app and smoke-test the primary user flow. If browser
automation is unavailable, the handoff should say so plainly.

## Map Of The Office

Start here if you are visiting:

- `CEO_OVERVIEW.md`: executive map, decisions, team structure, open items.
- `AGENTS.md`: rules every agent follows.
- `GEMINI.md`: Gemini CLI-specific first-response and status-mode guardrails.
- `docs/ai-office/org-branch-model.md`: how the company structure stays stable
  across products.
- `docs/ai-office/roles.md`: each role and its definition of done.
- `docs/ai-office/role-activation.md`: visible chat banners for activated
  roles.
- `docs/ai-office/status-protocol.md`: lightweight branch-aware progress checks.
- `docs/ai-office/commit-guidelines.md`: the office commit message standard.
- `docs/ai-office/task-triage.md`: which role to call when the task is unclear.
- `docs/ai-office/user-activation.md`: what to type in a brand-new AI session.
- `docs/ai-office/workflow.md`: branch and handoff model.
- `docs/ai-office/async-agent-runtime.md`: parallel multi-session execution.
- `docs/ai-office/runtime-adapters.md`: native sub-agent harnesses and packet
  fallback behavior.
- `docs/ai-office/flutter-specialization.md`: what makes this Flutter-specific.
- `docs/ai-office/mcp-and-skills.md`: MCP and official skills setup.
- `docs/ai-office/gemini-cli.md`: Gemini CLI context loading and status
  guardrails.
- `docs/features/README.md`: where feature work lives.
- `work/README.md`: where product app scaffolds live.

## Current Status

The office is built, and the current product branch contains a Minimal Timer
Flutter app tracked under:

```text
docs/features/minimal-timer-app/
work/minimal-timer-app/
```

Current product state:

1. `minimal-timer-app` is shipped to `main`.
2. `android-background-timer` is implemented on `main` and needs a verification
   pass, especially Android emulator/device background behavior.
3. `docs/features/status-index.md` is the lightweight source for progress
   checks.
