# Test Plan: Minimal Timer App

## Test Scope

Prove that the first timer screen renders, accepts duration changes, ticks,
pauses, resets, and reaches completion.

## Automated Tests

- Unit: Not added.
- Widget: `work/minimal-timer-app/test/widget_test.dart`.
- Integration: Not added.
- Golden: Not added.

## Manual QA Matrix

| Case | Steps | Expected Result | Status |
| --- | --- | --- | --- |
| Happy path | Open app, keep 5 minutes, start | Timer enters Running and begins ticking | Covered by widget test |
| Duration preset | Choose 1 minute | Display and duration label update to 1 minute | Covered by widget test |
| Pause | Start, wait one tick, pause | Remaining time stays fixed | Covered by widget test |
| Reset | Pause after a tick, reset | Timer returns to selected duration | Covered by widget test |
| Completion | Run 1 minute timer to zero | Status is Done and action is Restart | Covered by widget test |
| Small device | Review centered scrollable layout | No overflow expected | Not run manually |
| Large device | Review constrained layout | Content stays centered and readable | Not run manually |

## Regression Areas

- Flutter scaffold still builds across generated platforms.
- App-local generated artifacts stay under `work/minimal-timer-app/`.
- Starter counter test and demo copy are fully removed.
- Reset remains disabled only when there is nothing to reset.

## Bugs Found

- Initial widget tests exposed that the action controls could sit below the
  default test viewport. Fixed by tightening vertical spacing and sizing the
  dial from available height as well as width.

## Release Confidence

- Green: Core behavior has widget coverage.
- Yellow: No manual emulator/browser pass yet.
- Red: Background alarms and notifications are out of scope.
