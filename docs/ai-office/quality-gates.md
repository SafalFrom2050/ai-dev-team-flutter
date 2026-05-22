# Quality Gates

These gates define what "production ready on main" means for the AI dev office.

## Main Branch Gate

Before anything merges to `main`:

- Code is formatted.
- Static analysis passes.
- Relevant unit and widget tests pass.
- Release build checks pass for the target platform.
- Important UI states match the design contract.
- **Mandatory Browser Smoke & UI Verification**: For all visual and user-facing UI changes, interactive browser testing is mandatory. Open the app in the browser using the browser tool, click through all primary user flows, verify that no layout overflows occur, capture screenshots of all primary visual states, and link/embed them in the walkthrough or final PR. If browser capability is missing in the environment, document this limitation explicitly.
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

For any visual or user-facing feature, the active specialist (e.g. Junior Flutter Developer, UI/UX Designer) and the QA/Test Engineer **must** perform a rigorous UI verification pass using browser automation or manual browser tools:

1. Build or run the web app (e.g. `fvm flutter run -d chrome` or `npm run dev`).
2. Open the app's local dev address in the browser tool.
3. Exercise the primary user flow, empty states, error states, and the main changed visual state.
4. Interactively check for visual defects, layout overflows, text truncations, or alignment issues.
5. Capture screenshots of each verified state using the browser screenshot tool, save them under `docs/features/<feature-slug>/assets/` or copy them to the artifacts directory, and embed them using standard markdown syntax `![caption](absolute_path)` in the walkthrough/outbox.
6. Record the test evidence and screenshots explicitly in `docs/features/<feature-slug>/handoff.md` or the outbox.

If browser tooling is completely unavailable in the active tool environment, document this limitation honestly in the PR instead of marking the gate green, and specify the manual verification required by the user.

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
