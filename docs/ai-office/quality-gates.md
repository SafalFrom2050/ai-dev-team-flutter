# Quality Gates

These gates define what "production ready on main" means for the AI dev office.

## Main Branch Gate

Before anything merges to `main`:

- Code is formatted.
- Static analysis passes.
- Relevant unit and widget tests pass.
- Release build checks pass for the target platform.
- Important UI states match the design contract.
- Browser smoke testing covers the primary flow when the app supports web and
  the active agent runtime has browser tools.
- Accessibility and responsive behavior have been checked for user-facing UI.
- Known risks are documented in the PR.

Recommended commands once the Flutter app exists:

```powershell
Push-Location work/<app-slug>
fvm flutter pub get
fvm dart format --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
fvm flutter build web
Pop-Location
```

Add target-platform build checks for the release target:

```powershell
Push-Location work/<app-slug>
fvm flutter build apk --debug
Pop-Location
```

For a web-capable feature, the Release Engineer or QA/Test Engineer should also
run a browser smoke check when the active tool supports browser automation:

1. Build or run the web app.
2. Open the app in a browser.
3. Exercise the primary user flow and the main changed state.
4. Capture the result in `docs/features/<feature-slug>/handoff.md` or
   `docs/features/<feature-slug>/async/outbox/qa-test-engineer.md`.

If browser tooling is unavailable, record that honestly instead of marking the
browser gate green.

## PR Review Gate

Each PR should answer:

- What role produced this work?
- What feature folder or issue does it belong to?
- What files were intentionally owned?
- What behavior changed?
- What tests were run?
- What screenshots or golden references prove UI changes?
- What risks or follow-ups remain?

## Design Gate

For user-facing screens, the design branch should specify:

- Primary user flow.
- Navigation entry and exit points.
- Loading state.
- Empty state.
- Error state.
- Disabled state.
- Success or completion state.
- Responsive behavior.
- Accessibility notes.
- Copy tone.

If the designer cannot specify an important state, the Product Lead should decide
whether that state is out of scope or still undefined.

## QA Gate

QA should cover:

- Happy path.
- Most likely failure path.
- Boundary input.
- Empty data.
- Slow network or loading state.
- Device size differences.
- Regression around nearby existing behavior.

## Reviewer Gate

Code review should block on:

- Incorrect behavior.
- Broken acceptance criteria.
- State bugs.
- Race conditions.
- Data loss.
- Security or privacy risk.
- Missing meaningful tests for risky logic.
- Confusing architecture that will slow future features.

Code review should not block on:

- Personal taste when project conventions are already followed.
- Large refactors unrelated to the feature.
- Unrequested rewrites that do not reduce real risk.
