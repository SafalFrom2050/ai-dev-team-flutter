# UX Design: Timer Onboarding

## Overview

The onboarding experience is a single, focused "Welcome" screen designed to build trust and explain gestures without clutter. It maintains the app's minimal aesthetic: plenty of white space, clear typography, and subtle iconography.

## Screen Layout: "Welcome to Minimal Timer"

- **Header Section (Top 20%)**:
  - **Title**: "Minimal Timer" (Large, Bold, Material 3 Display Medium)
  - **Tagline**: "Simple. Silent. Persistent." (Material 3 Body Large, secondary color)
- **Feature Section (Middle 50%)**:
  - Three vertical rows, each with a large icon on the left and a short description on the right.
  - **Row 1: "Stays with you"**
    - **Icon**: A bell icon inside a rounded square with a subtle "background" ripple effect.
    - **Text**: "Timer keeps running in the background and sends a notification when done."
  - **Row 2: "Fast Adjust"**
    - **Icon**: A hand gesture icon (finger tapping) over a circular clock face.
    - **Text**: "Tap the preset chips or use the +/- buttons to change duration instantly."
  - **Row 3: "Silence is Golden"**
    - **Icon**: A simple crescent moon or a "no-sound" bell icon.
    - **Text**: "No accounts, no ads, no noise. Just focus."
- **Action Section (Bottom 30%)**:
  - **Primary Button**: "Start Timing" (Material 3 Filled Button, full-width on mobile, centered on tablet).
  - **Hint**: "You can see these tips again by tapping the '?' on the timer screen." (Small, muted text).

## Visual Style

- **Color Palette**: Strictly adheres to the `#2F6F63` seed color and `#FAF9F5` background.
- **Typography**: Uses the Material 3 "Roboto" or system font stacks.
- **Iconography**: Outlined Material Symbols with a stroke weight of 1.5 for a light, airy feel.

## Transitions & Animations

- **Entry**: The "Welcome" screen fades in over 400ms when the app first launches.
- **Icon Animation**: Icons subtly slide in from the left (offset 20px) after the text appears.
- **Exit (Start Timing)**:
  - The onboarding screen cross-fades into the main Timer screen.
  - Duration: 500ms.
  - The Timer dial on the next screen should subtly scale from 0.9 to 1.0 during the transition to feel like it's "popping" into focus.

## Responsive Behavior

- **Mobile**: Single column, centered content.
- **Tablet/Desktop**: Content is constrained to a max width of 520px. Vertical spacing increases to fill the height, keeping the button at the bottom of the safe area.
