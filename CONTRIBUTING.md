# Contributing

Thanks for helping improve AI Dev Team Flutter.

This project is both a Flutter app workspace and an experiment in running an AI
engineering office. Contributions are welcome when they make the office clearer,
more useful, more Flutter-native, or more reliable.

## Before You Start

Read these first:

- `README.md`
- `AGENTS.md`
- `GEMINI.md` if you use Gemini CLI
- `docs/ai-office/workflow.md`
- `docs/ai-office/commit-guidelines.md`

For office/process changes, also read `CEO_OVERVIEW.md`.

## Development Setup

This repo uses FVM.

```powershell
fvm flutter --version --no-version-check
```

Run Flutter commands from the app workspace:

```powershell
Push-Location work/<app-slug>
fvm flutter pub get
fvm dart format --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
Pop-Location
```

## Branches

Use the office branch model:

- `org/<initiative>` for reusable office/workflow/tooling changes.
- `integrate/<feature-slug>` for feature integration.
- `product/<feature-slug>` for briefs and acceptance criteria.
- `design/<feature-slug>` for UX/design contracts.
- `arch/<feature-slug>` for architecture and work slicing.
- `feat/<feature-slug>/<slice>` for implementation.
- `test/<feature-slug>` for QA and automated tests.
- `fix/<feature-slug>/<issue>` for follow-up fixes.

Small documentation fixes can use a simple descriptive branch.

## Pull Requests

Every PR should include:

- Role or contributor context.
- Scope and intentional non-goals.
- Changed files or owned area.
- Test evidence, or a clear reason tests were not run.
- Known risks and follow-ups.

Use `.github/PULL_REQUEST_TEMPLATE.md`.

## Commit Messages

Use Conventional Commits:

```text
<type>(<scope>): <imperative summary>
```

Examples:

```text
docs(readme): add featured hero image
feat(timer): add foreground service timer state
test(timer): cover pause and reset behavior
```

See `docs/ai-office/commit-guidelines.md`.

## AI Agent Contributions

AI-assisted contributions are welcome, but the repository must keep durable
context in files, not hidden chat transcripts.

If an AI role performs work:

- Start with the role activation banner.
- Keep file ownership explicit.
- Update handoff/outbox docs when relevant.
- Do not let the Office Assistant perform specialist implementation work.
- Update `docs/features/status-index.md` when feature state changes.

## Code Style

- Prefer idiomatic Dart and Flutter.
- Keep generated Flutter platform files inside `work/<app-slug>/`.
- Keep business logic outside widgets unless it is truly presentational.
- Add tests at the risk level of the change.

## License

By contributing, you agree that your contribution will be licensed under the MIT
License in `LICENSE`.
