# UX Design: Alarms

## Overview

The alarm experience in Minimal Timer is designed to be **unmistakable, reliable, and calm**. Unlike traditional jarring alarm apps, the Minimal Timer alarm uses pleasant, high-quality minimalist tones and a synchronized haptic vibration to capture attention without causing stress. The flow is optimized for immediate, zero-friction dismissal.

---

## 1. Flow & Interactive Steps

### Flow A: Sound Configuration
1. **Discover**: User notices a small, elegant sound icon (`Icons.volume_up` or `Icons.volume_off`) on the main timer screen next to the main countdown dial.
2. **Toggle Mute**: A single tap on this icon toggles the app-wide alarm sound status (Muted vs. Unmuted) with instant haptic feedback.
3. **Select Tone**: A long-press or a secondary gear/dropdown icon next to it expands a subtle, horizontal row of sound selector chips below the main controls:
   - **Chime (Zen Bowl)**: High-pitched, soothing, resonant bowl tone.
   - **Beep (Digital)**: Crisp, clean, dual-frequency electronic beep.
   - **Echo (Classic Bell)**: Gentle but highly repeating acoustic bell tone.
4. **Preview**: Tapping a chip immediately plays a 1.5-second preview of that tone and saves the choice locally.
5. **Dismiss/Collapse**: The panel automatically collapses after a sound is chosen or when tapping outside, keeping the interface tidy.

### Flow B: Foreground Ringing & Dismissal
1. **Trigger**: The countdown reaches `00:00`.
2. **Transition**: The active timer screen cross-fades into a vibrant, full-screen ringing overlay within 300ms.
3. **Alert State**:
   - The phone begins repeating the selected audio tone in a loop.
   - The device vibrates in a distinctive double-beat "heartbeat" pattern.
   - The screen shows a high-contrast visual display with a pulsing ambient background.
4. **Dismissal**: The user taps anywhere in the bottom half of the screen (which acts as a massive dismiss target) or presses the prominent, centered "Dismiss" button.
5. **Silence**: Audio and haptics cease *instantly* (latency <100ms), and the app fades back to the ready screen.

### Flow C: Background Alert & Notification Dismissal
1. **Trigger**: The user is in another app or the device is locked when the timer reaches `00:00`.
2. **Heads-up Notification**: A high-priority system notification slides down from the top of the screen.
3. **Alert State**: Sound loops and haptics pulse continuously via the foreground service.
4. **Direct Dismissal**: The notification features an explicit, large "Stop" button. Tapping it silences the alarm and clears the notification immediately, without bringing the main app to the foreground.
5. **Deep Link**: Tapping the notification body opens the app and displays the idle timer screen, silences the alarm, and resets the interface.

---

## 2. Screen States

### State 1: Default (Sound Active, Tone Configured)
- Main screen displays `Icons.volume_up` in a semi-transparent slate gray.
- Current active tone is saved as "Chime".

### State 2: Expanded Sound Selector
- Expands below the timer presets using an animated expansion widget (250ms curve).
- Displays a small label: "Select Alarm Sound" in a small, muted, uppercase font.
- Displays three pill-shaped chips horizontally:
  - **Selected Chip**: Uses primary seed color (`#2F6F63`) as the background with high-contrast white text. A checkmark icon (`Icons.check`) precedes the name.
  - **Unselected Chips**: Light cream background (`#FAF9F5`), subtle slate outline, slate text.
- Standard spacing is maintained: 8dp between chips, 12dp top/bottom padding.

### State 3: Fullscreen Ringing Overlay (Vibrant Active State)
- **Background**: Immersive, full-screen color using `#2F6F63` (Dark Sage). A subtle, continuous radial pulse animation scales a softer background gradient from `1.0` to `1.15` every 1.5 seconds.
- **Header**: Large, bold label "Time's Up!" (Material 3 Display Large, white, centered, `FontWeight.w900`).
- **Sub-header**: Minimal timer metadata (e.g., "5-minute timer completed") in a soft, semi-transparent white body font.
- **Center Action**: A massive, circular, white button (`Icons.notifications_active` transitioning to a ripple effect).
- **Bottom Dismiss Bar**: A prominent, full-width pill button labeled **"Dismiss"** in dark text on a bright white background, providing a massive tap target (minimum height 80dp).

### State 4: Muted / Silent State
- Main screen displays `Icons.volume_off` with a line through it.
- When the timer completes:
  - Audio remains completely silent.
  - Fullscreen Ringing Overlay displays normally (vibrating).
  - Haptic vibration pattern still fires to ensure the user feels the completion.

---

## 3. Layout & Alignment Rules

- **Responsive Scaling**:
  - **Mobile**: Full-screen overlay fills 100% of the screen height and width. The "Dismiss" button sits in the lower third, comfortably within natural thumb-reach (safe area bottom + 32dp).
  - **Tablet & Desktop**: The ringing overlay does not stretch to extreme widths; instead, it centers as a beautiful, high-contrast modal dialog constrained to `520dp` max width, with the background outside it dimmed to `#000000` with 60% opacity.
- **Sound Selector Chips**: On narrow screens, the chips row wraps horizontally or allows smooth horizontal scrolling to avoid text truncation or clipping.

---

## 4. Accessibility & Semantics

- **Screen Reader Announcements**:
  - When the fullscreen ringing state opens, a screen-reader accessibility event is triggered (`Semantics(liveRegion: true)`) announcing: *"Timer completed. Time's Up! Tap bottom button to dismiss."*
  - The mute toggle uses a clear semantic description: *"Toggle alarm sound. Currently unmuted, playing Chime."*
- **High Contrast**:
  - Fullscreen Ringing Overlay text uses pure white (`#FFFFFF`) against `#2F6F63` background, achieving a contrast ratio of >7:1 (well exceeding WCAG AAA standard).
- **Physical Controls**:
  - Pressing the hardware volume buttons while the alarm is ringing in the foreground immediately mutes the active audio loop, providing a physical panic-mute option before full dismissal.
