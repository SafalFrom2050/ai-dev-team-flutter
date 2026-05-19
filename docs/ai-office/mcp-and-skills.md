# Flutter MCP And Skills

The Flutter office should be wired to official Flutter/Dart AI tooling wherever
possible.

## Current Local Status

Checked on this machine:

- Global `dart --version`: Dart `3.4.1`
- Global `flutter --version`: `flutter` is not currently on PATH
- Repo-local `.fvmrc`: `stable`
- `fvm flutter --version`: Flutter `3.38.8`, Dart `3.10.7`
- `fvm dart mcp-server --help`: available

The official Dart and Flutter MCP server currently requires Dart `3.9` or later,
so this repo should use FVM commands instead of the older global Dart command.

## Official Dart And Flutter MCP Server

The official server is started through FVM with:

```powershell
fvm dart mcp-server --force-roots-fallback
```

Configure Codex CLI with:

```powershell
codex mcp add dart -- fvm dart mcp-server --force-roots-fallback
```

Why this matters for the AI office:

- Agents can inspect Dart and Flutter project context.
- Agents can analyze and fix errors with tool context.
- Agents can resolve symbols and fetch documentation/signatures.
- Agents can inspect and interact with a running Flutter app.
- Agents can search `pub.dev` and manage `pubspec.yaml` dependencies.
- Agents can run tests, format code, and analyze results through Flutter/Dart
  tooling.

## Project-Local MCP Configs

This repo includes project-local examples for tools that support checked-in MCP
configuration:

- `.cursor/mcp.json`
- `.gemini/settings.json`
- `GEMINI.md`

The MCP configs point to `fvm dart mcp-server --force-roots-fallback`.

`GEMINI.md` is not an MCP config. It is Gemini CLI's project context file. It
exists so Gemini sees the office activation and status-mode rules before using
MCP tools.

## Installed Official Agent Skills

Flutter and Dart now maintain official agent-skill repositories:

- `flutter/skills`: Flutter-specific workflows such as responsive layouts,
  declarative routing, and JSON serialization.
- `dart-lang/skills`: Dart-specific workflows such as unit tests, dependency
  resolution, and static-analysis fixes.

Installed in this workspace:

```text
.agents/skills/
  dart-add-unit-test
  dart-build-cli-app
  dart-collect-coverage
  dart-fix-runtime-errors
  dart-generate-test-mocks
  dart-migrate-to-checks-package
  dart-resolve-package-conflicts
  dart-run-static-analysis
  dart-use-pattern-matching
  flutter-add-integration-test
  flutter-add-widget-preview
  flutter-add-widget-test
  flutter-apply-architecture-best-practices
  flutter-build-responsive-layout
  flutter-fix-layout-issues
  flutter-implement-json-serialization
  flutter-setup-declarative-routing
  flutter-setup-localization
  flutter-use-http-package
```

The install also created `skills-lock.json` so the skill set can be reviewed and
kept reproducible.

To reinstall or update later, use:

```powershell
npx skills add flutter/skills --skill '*' --agent universal
npx skills add dart-lang/skills --skill '*' --agent universal
```

The installer flagged `flutter-use-http-package` as high risk in its security
assessment. Keep it available, but use the package decision process before any
agent adds networking dependencies.

After adding or updating skills, restart Codex or the relevant agent client so it
can discover the new skills.

## Recommended Tooling Layers

Use the layers like this:

- `AGENTS.md`: durable team rules for every agent.
- `GEMINI.md`: Gemini CLI-specific guardrails for first response and status
  mode.
- `.fvmrc`: repo-local Flutter SDK pin.
- Official Flutter/Dart rules: baseline framework behavior and best practices.
- Agent Skills: task-specific playbooks for routing, layout, testing, package
  decisions, and analysis fixes.
- MCP server: live tool access to analyzer, tests, package search, docs,
  runtime errors, and widget tree inspection.

Rules define the team culture. Skills define how to do a specific job. MCP gives
agents hands and eyes inside the Flutter toolchain.

## Setup Checklist

- [x] Pin this repo to FVM `stable`.
- [x] Verify `fvm flutter --version` works.
- [x] Ensure repo-local Dart is `3.9+`.
- [x] Run `fvm dart mcp-server --help` once to verify the command exists.
- [ ] Add the MCP server to Codex, Cursor, Gemini CLI, or the preferred agent
      client.
- [x] Install official Flutter and Dart skills into `.agents/skills`.
- [ ] Create Flutter app scaffolds under `work/<app-slug>/`.
- [ ] Run `fvm flutter analyze` and `fvm flutter test` from the app workspace.
