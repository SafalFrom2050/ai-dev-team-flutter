# Design Contract: Minimal Timer App

## Experience Goal

The screen should feel quiet, immediate, and easy to trust. The timer is the
main object; controls stay secondary until needed.

## Primary Flow

1. User starts at the timer screen.
2. User chooses a duration or keeps 5 minutes.
3. System shows a large countdown with Ready, Running, Paused, or Done state.
4. User completes by resetting or restarting.

## Screen States

- Default: `05:00`, Ready, 5 minute preset selected.
- Loading: Not applicable.
- Empty: Not applicable.
- Error: Not applicable for this local-only feature.
- Disabled: Duration controls are disabled while the timer is running.
- Success: Timer reaches `00:00` and shows Done.

## Layout Rules

- Mobile: Centered single column with safe-area padding and vertical scrolling
  if space is short.
- Tablet: Same content, constrained to a readable max width.
- Desktop or wide layout: Keep the timer centered; do not stretch controls.

## Interaction Rules

- Tap/click behavior: Preset chips and minute step buttons update duration only
  when not running.
- Back/navigation behavior: Single route; platform back exits app.
- Form/input behavior: No text input.
- Animation or transition behavior: Progress ring updates with timer ticks.

## Components Needed

| Component | Purpose | Existing or New |
| --- | --- | --- |
| Timer dial | Remaining time, progress, status | New |
| Duration controls | Presets and minute steppers | New |
| Timer actions | Start, pause, reset, restart | New |

## Design Tokens

| Token | Value | Usage |
| --- | --- | --- |
| Seed color | `#2F6F63` | Material color scheme |
| Background | `#FAF9F5` | Scaffold surface |
| Max content width | `520` | Desktop/tablet content constraint |
| Dial max size | `320` | Countdown focal point |

## Copy

- Primary action: Start, Pause, Restart.
- Secondary action: Reset.
- Empty state: Not applicable.
- Error message: Not applicable.
- Success message: Done.

## Accessibility

- Semantic labels: Timer display exposes remaining time as a live region.
- Focus order: Title, timer, duration controls, primary actions.
- Contrast notes: Material 3 color scheme provides foreground/background pairs.
- Text scaling: Main content scrolls and wraps on constrained screens.

## Golden Or Screenshot Expectations

- Default ready state should show centered timer dial and controls without
  overflow on narrow and wide layouts.

## Open Design Questions

- Whether the next iteration should add sound, haptics, or notification
  behavior on completion.
