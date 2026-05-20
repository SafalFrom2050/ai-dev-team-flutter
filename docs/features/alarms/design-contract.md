# Design Contract: Alarms

## Experience Goal

The alarm experience must feel **audible, clear, minimal, and immediately dismissible**. It provides reliable feedback when a timer finishes without causing sensory distress, respecting user settings while remaining highly visible and responsive.

---

## Primary Flow

1. **User starts at**: The main Timer screen. A sound indicator toggle (`Icons.volume_up` or `Icons.volume_off`) sits prominently alongside the preset chips.
2. **User chooses sound**: User taps the sound indicator or expansions button, opening a horizontal shelf of minimalist tone chips. Tapping a chip ("Chime", "Beep", "Echo") plays a 1.5-second audio preview.
3. **User quick mutes**: User taps the volume toggle to instantly silence/activate the sound, shifting the icon representation immediately.
4. **System responds at completion**: When the countdown reaches `00:00`, the app instantly displays the vibrant, full-screen "Time's Up!" ringing overlay, initiates looping playback of the selected tone, and begins a rhythmic haptic vibration.
5. **User completes by dismissing**: User taps the massive centered "Dismiss" button on the screen. Audio, vibration, and overlay stop instantly (<100ms), and the app resets to the main timer screen.

---

## Screen States

- **Default State**:
  - Alarm is active/enabled.
  - Icon: `const Icon(Icons.volume_up)` with a subtle text badge or semantic label identifying the tone: "Chime (Zen Bowl)".
  - Sound Selector: Collapsed/Hidden.
- **Sound Selector Collapsed**:
  - Tidy control bar showing only the mute/unmute toggle.
- **Sound Selector Expanded**:
  - A subtle shelf container appearing directly beneath the presets.
  - Horizontal chip row containing three items: `Chime (Zen Bowl)`, `Beep (Digital)`, `Echo (Classic Bell)`.
  - Selected chip is filled with the primary seed color `#2F6F63` and contains a check icon `Icons.check`.
  - Unselected chips are outlined and plain.
- **Fullscreen Ringing Overlay (Vibrant Active State)**:
  - Takes over 100% of the viewport (mobile) or fits as a centered 520dp modal (tablet/desktop).
  - Ambient dark green `#2F6F63` solid background with a radial pulse animation scaling from `1.0` to `1.15`.
  - Large pulsing icon at the center: `const Icon(Icons.notifications_active, size: 80, color: Colors.white)`.
  - Title: "Time's Up!" in extra large white lettering (`FontWeight.w900`).
  - Massive bottom action: A rounded pill "Dismiss" button (`height: 80dp`, background `#FFFFFF`, text `#2F6F63` in bold uppercase).
- **Muted / Silent State**:
  - Icon: `const Icon(Icons.volume_off)` with a slash.
  - When timer reaches `00:00`, the Fullscreen Ringing Overlay is visual-only and vibrates. No audio plays.

---

## Layout Rules

- **Mobile**:
  - The sound selector row spans the available width with horizontal scrolling enabled if constraints are tight.
  - The Fullscreen Ringing Overlay occupies 100% of the mobile safe area, placing the massive "Dismiss" button in the lower third for easy, ergonomic single-handed thumb tap.
- **Tablet**:
  - Main timer controls are constrained to `520dp` max width.
  - The ringing state displays as a beautiful, centered modal overlay with `520dp` max width, rounded corners (`24dp`), and a high-contrast shadow. The background page outside is dimmed by 60% black overlay.
- **Desktop**:
  - Same as tablet. Fully responsive centering, keeping the button in the middle-bottom of the dialog, easily clickable.

---

## Interaction Rules

- **Mute Toggle Tap**:
  - Tapping the mute button instantly flips the state between muted/unmuted, saves it to `shared_preferences`, and triggers a short mechanical haptic tick (e.g. `HapticFeedback.lightImpact()`).
- **Tone Chips Selection**:
  - Tapping an unselected tone chip immediately plays a 1.5s preview of the tone, marks it as selected, updates local persistence, and highlights the chip using a smooth selection slide/fade.
- **Fullscreen Swipe/Dismiss Actions**:
  - Tapping the large centered "Dismiss" button or swiping upward anywhere on the lower half of the screen dismisses the alarm instantly.
  - Pressing the device's physical volume-down or power button immediately silences the active audio loop (preventing auditory disturbance in public) but keeps the visual ringing screen active for dismissal.

---

## Components Needed

| Component | Purpose | Existing or New |
| --- | --- | --- |
| `SoundMuteToggle` | Quick toggle button for turning sound on/off on the main screen. | New |
| `SoundSelectorShelf` | Collapsible horizontal row of chips to select the active tone. | New |
| `SoundToneChip` | Individual selectable chip for each tone option. | New |
| `RingingOverlay` | Immersive, high-visibility, full-screen completion state container. | New |
| `DismissButton` | Oversized, highly accessible button to shut off alarm haptics/audio. | New |

---

## Design Tokens

| Token | Value | Usage |
| --- | --- | --- |
| Primary Seed | `#2F6F63` | Standard app theme primary color |
| Scaffold Background | `#FAF9F5` | Main screen surface tone |
| Ringing Background | `#2F6F63` | Solid immersive background during alarm |
| Ringing Text | `#FFFFFF` | Text color on active ringing background |
| Ringing Icon Color | `#FFFFFF` | Ringing status bell color |
| Ringing Button Fill | `#FFFFFF` | Dismiss button background |
| Ringing Button Text | `#2F6F63` | Dismiss button text label |
| Ringing Pulse Scale | `1.0` to `1.15` | Ambient ring pulsing animation |
| Swipe Threshold | `80.0dp` | Scroll/drag offset required for swipe-up dismiss |
| Vibration Cadence | Double-beat (heartbeat): [0ms, 150ms, 150ms, 150ms] | Foreground service vibration haptic rhythm |

---

## Copy

- **Primary Action (Main Screen)**: "Start", "Pause", "Reset", "Restart"
- **Primary Action (Ringing)**: "DISMISS" (Uppercase, bold)
- **Ringing Title**: "Time's Up!"
- **Ringing Subtitle**: "Your timer has completed successfully."
- **Tone Names**:
  - "Chime" (Zen Bowl)
  - "Beep" (Digital)
  - "Echo" (Classic Bell)
- **Accessibility Hints**:
  - "Mute alarm sound. Currently playing Chime."
  - "Unmute alarm sound. Currently muted."
  - "Zen Bowl chime tone. Tap to select and play preview."

---

## Accessibility

- **Semantic Labels**:
  - Mute/Unmute buttons must have descriptive semantic labels: `Semantics(label: "Alarm sound toggle, currently active. Tap to mute.", button: true)`.
  - Each chip has a semantic label: `Semantics(label: "Select ${toneName} alarm tone.", selected: isActive, button: true)`.
- **Live Regions**:
  - The active ringing screen is wrapped in a `Semantics` widget with `liveRegion: true` and `container: true`, causing screen readers to immediately announce the completion text "Timer complete: Time's Up!" when it appears.
- **Contrast Notes**:
  - White text (`#FFFFFF`) and white button fill on a `#2F6F63` background guarantees a contrast ratio exceeding 7.0:1, making it highly readable for users with visual impairments.
- **Physical Mute fallback**:
  - Screen readers or keyboard controls can easily target the oversized "Dismiss" button, which has a focus node that is auto-focused on entry.

---

## Golden Or Screenshot Expectations

- **Sound Selector shelf**: Must expand downwards from the presets without causing layout jitter or overlapping the primary timer dial.
- **Ringing Overlay**: In portrait mobile view, should fit exactly inside safe areas with a full dark green bleed. In desktop landscape view, must center precisely as a 520dp wide card with rounded corners, and clear, dark scrim behind it.
- **Active Tone Chip**: Must show a checkmark icon on the left, clear solid green background, and white text. Unselected chips must show a thin gray border and gray text.

---

## Open Design Questions

- **Auto-Timeout**: Should the alarm automatically silence itself (auto-timeout) after a period (e.g., 3 minutes) if left unattended to prevent battery drain?
  - *Recommendation*: Yes. If left untouched, the alarm should auto-dismiss and silent-reset after 5 minutes of continuous ringing to preserve system resources and battery life.
- **Independent Vibration Toggle**: Do we support vibration-only mode, or does muting the sound also mute the haptics?
  - *Recommendation*: Muting the alarm toggles *audio only*. The haptic heartbeat vibration will still fire during foreground completion to ensure silent tactile awareness. Completely silencing both audio and haptics should honor the system's "Do Not Disturb" settings.
