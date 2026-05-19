# Design Contract: Timer Onboarding

## Experience Goal

Deliver a high-speed, high-trust introduction to the timer's background capabilities and gesture controls.

## Routes

| Route Name | Path | Purpose |
| --- | --- | --- |
| Onboarding | `/onboarding` | Single-screen welcome and tutorial |
| Timer (Root) | `/` | The main timer screen |

## Components Needed

| Component | Purpose | Status |
| --- | --- | --- |
| Onboarding Screen | Main container for the welcome flow | New |
| Feature Row | Icon + Text pair for value points | New |
| Help Button | Subtle '?' icon on Timer screen to re-open onboarding | New |

## Design Tokens

Uses the established tokens from `docs/features/minimal-timer-app/design-contract.md`:
- **Seed Color**: `#2F6F63`
- **Background**: `#FAF9F5`
- **Max Width**: `520`

## Accessibility

- **Heading**: "Welcome to Minimal Timer" should be marked as an H1.
- **Icons**:
  - "Stays with you" icon: `Semantics(label: "Background notification indicator")`
  - "Fast Adjust" icon: `Semantics(label: "Gesture control tutorial")`
  - "Silence is Golden" icon: `Semantics(label: "Privacy and silence guarantee")`
- **Button**: "Start Timing" should have a clear tap target (min 48x48 dp).
- **Reading Order**: Title -> Tagline -> Feature 1 -> Feature 2 -> Feature 3 -> Button -> Help Hint.

## Acceptance Criteria

### Visual Markers
- [ ] Icons are Material Symbols Outlined style.
- [ ] Onboarding screen has a background color of `#FAF9F5`.
- [ ] "Start Timing" button uses the Material 3 Filled button style with the `#2F6F63` primary color.
- [ ] Layout is centered and scales gracefully on mobile and tablet (max width 520).

### Interactive Markers
- [ ] Tapping "Start Timing" navigates to `/` and sets `onboarding_complete = true`.
- [ ] The transition to the Timer screen is a cross-fade animation.
- [ ] A small '?' icon appears in the top-right or bottom-right of the Timer screen.
- [ ] Tapping the '?' icon navigates back to `/onboarding`.

### Functional Markers
- [ ] Onboarding does not appear if `onboarding_complete` is already `true` on launch.
- [ ] Onboarding state survives app restarts (local persistence).
