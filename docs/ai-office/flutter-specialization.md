# Flutter Specialization

The AI office becomes special for Flutter when each agent understands the shape
of a production Flutter app: declarative UI, widget trees, async state, platform
constraints, design tokens, tests, and runtime inspection.

## What Makes This Office Flutter-Native

Generic development asks "does the code work?" A Flutter office asks:

- Does the widget tree express the product intent clearly?
- Do all user-facing states exist: loading, empty, error, disabled, success?
- Does the layout survive small phones, tablets, desktop widths, rotation, text
  scaling, and keyboard insets?
- Are interaction targets accessible and semantically labeled?
- Is business logic separated from widget composition?
- Are rebuilds controlled and state ownership obvious?
- Can QA prove the behavior with unit, widget, integration, and golden tests?
- Can agents inspect the running app with Flutter tooling instead of guessing
  from static code only?

## Recommended App Shape

Once the Flutter app is created, use this as the starting structure unless a
feature has a strong reason to differ:

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    errors/
    services/
    utils/
  features/
    <feature>/
      data/
      domain/
      presentation/
        screens/
        widgets/
        controllers/
  shared/
    widgets/
    tokens/
test/
  features/
  shared/
integration_test/
```

The goal is not ceremony. The goal is for agents to know where work belongs.

## Default Technical Preferences

These are defaults, not laws:

- Navigation: `go_router` for non-trivial routing.
- State and dependency ownership: Riverpod when app state grows beyond local
  widget state.
- Immutable models: plain Dart first; `freezed` and `json_serializable` when
  model complexity or API contracts justify generation.
- Networking: typed API clients behind repositories.
- Local persistence: start simple; isolate storage behind interfaces.
- Design system: centralize `ThemeData`, tokens, spacing, typography, and shared
  controls early.

Any agent that wants to add a dependency should write a package decision record
before adding it.

## Flutter-Specific Agent Responsibilities

### UI/UX Designer

Design work must become Flutter-implementable:

- Route entry and exit points.
- Screen-state matrix.
- Component states and interaction rules.
- Responsive layout rules.
- Text scaling expectations.
- Semantic labels and focus order.
- Token changes: colors, spacing, typography, radius, elevation.
- Golden or screenshot expectations for important surfaces.

### Product Engineer

The technical plan should decide:

- Feature module boundaries.
- State ownership.
- Data flow.
- Route shape.
- Error model.
- Platform assumptions.
- Dependency choices.
- Test strategy.

### Flutter Developers

Implementation should:

- Keep widgets small and named after user intent.
- Use stable keys for test-critical controls.
- Push business rules into controllers, services, or domain objects.
- Avoid async UI bugs by checking lifecycle safety after awaited work.
- Respect design tokens instead of hard-coding visual drift.

### QA/Test Engineer

QA should combine:

- Unit tests for business rules.
- Widget tests for user-visible state and interaction.
- Golden tests for stable, important UI.
- Integration tests for critical flows.
- Manual checks for device size, keyboard, accessibility, and platform behavior.

### Code Reviewer

Flutter review should look for:

- Layout overflow risk.
- Overly broad rebuilds.
- Wrong `BuildContext` usage across async gaps.
- Hidden state ownership.
- Missing error/loading/empty states.
- Missing semantics.
- Fragile tests that depend on incidental widget structure.
- Dependencies that duplicate Flutter or Dart built-ins.

## Flutter Feature Definition Of Ready

A Flutter feature is ready for implementation when it has:

- Product acceptance criteria.
- Route contract.
- Screen-state matrix.
- Design contract.
- State management plan.
- File ownership map.
- Test plan.
- Package decisions, if new dependencies are needed.

## Flutter Definition Of Done

A Flutter feature is done when:

- `fvm dart format` is clean.
- `fvm flutter analyze` is clean.
- Relevant tests pass.
- UI has been checked at small and large sizes.
- Loading, empty, error, disabled, and success states behave correctly.
- Important controls have semantics.
- Design contract changes are either implemented or explicitly deferred.
- Release notes describe user-visible behavior.
