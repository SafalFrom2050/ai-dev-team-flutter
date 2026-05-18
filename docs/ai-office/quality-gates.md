# Quality Gates

These gates define what "production ready on main" means for the AI dev office.

## Main Branch Gate

Before anything merges to `main`:

- Code is formatted.
- Static analysis passes.
- Relevant unit and widget tests pass.
- Important UI states match the design contract.
- Accessibility and responsive behavior have been checked for user-facing UI.
- Known risks are documented in the PR.

Recommended commands once the Flutter app exists:

```powershell
fvm flutter pub get
fvm dart format --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

Add platform build checks as the app matures:

```powershell
fvm flutter build web
fvm flutter build apk --debug
```

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
