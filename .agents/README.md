# Installed Agent Skills

This workspace contains official Flutter and Dart agent skills under
`.agents/skills`.

Before starting a Flutter-specific task, agents should inspect the relevant skill
instead of relying only on general model knowledge. Examples:

- Responsive UI: `flutter-build-responsive-layout`
- Layout bug fixing: `flutter-fix-layout-issues`
- Widget tests: `flutter-add-widget-test`
- Integration tests: `flutter-add-integration-test`
- Declarative routing: `flutter-setup-declarative-routing`
- Localization: `flutter-setup-localization`
- Architecture review: `flutter-apply-architecture-best-practices`
- Static analysis: `dart-run-static-analysis`
- Unit tests: `dart-add-unit-test`
- Package conflicts: `dart-resolve-package-conflicts`

`skills-lock.json` records the installed skill hashes.

Note: the installer marked `flutter-use-http-package` as high risk. Do not use it
to add networking dependencies without a package decision record.

