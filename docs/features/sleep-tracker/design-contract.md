# Design Contract: Sleep Tracker & Bottom Navigation Redesign

## Experience Goal

The **Sleep Tracker & Bottom Navigation** interface must feel **premium, celestial, tactile, and deeply calming**. It extends our digital wellness experience to late-night and early-morning hours, minimizing visual emissions while providing highly responsive, satisfying interactive animations. Tap interactions, sliding states, and the cosmic mascot must evoke a sense of premium craftsmanship through precise spring physics, soundscapes, and haptic signatures.

---

## 1. Precise Cosmic Color Palette

We extend our dark-mode design ecosystem with a dedicated Sleep palette designed for low-lux environments:

| Token Name | Hex Code | Visual Purpose / Usage | Contrast Ratio (on Obsidian) |
| --- | --- | --- | --- |
| **Midnight Sapphire** | `0xFF060913` | Primary sleep-themed backdrop; radial gradient start. | N/A (Scaffold base) |
| **Deep Obsidian** | `0xFF0B0F19` | Inactive screen backdrop; core shell structural panels. | N/A (Scaffold base) |
| **Neon Mint** | `0xFF00FFCC` | Active state highlights; focus timer core indicators; success indicators. | `8.2:1` (High accessibility) |
| **Starry Gold** | `0xFFFFD369` | Alarm visual overlays; glowing pucks; active stars; morning wake highlights. | `7.5:1` (High accessibility) |
| **Soft Lavender** | `0xFFB39DDB` | Inactive text; secondary details; sleep control chips; inactive indicators. | `5.6:1` (Passes WCAG AA) |
| **Slate Obsidian** | `0xFF161B26` | Card background tiles; navigation bar outline borders. | `1.4:1` (Structural borders only) |
| **Faded Lavender** | `0xFFE8D3FF` | Secondary text highlights; inner ear mascot accents. | `6.2:1` (Highly legible) |

---

## 2. Glassmorphic Bottom Navigation Design Tokens

The bottom navigation bar floats above the content layer, providing a tactile transition between focus and rest domains.

```
+---------------------------------------------+
|    [ (o) Focus ]   (   ) Sleep   [ ] Log    |  <-- Glass Container (Frosted Obsidian)
|          ^                                  |
|   Sliding Capsule (Springs behind active tab)|
+---------------------------------------------+
```

### Nav Bar Scaffolding Specs:
- **Placement**: Floating container, anchored at bottom center.
- **Margins**: `Left: 24dp`, `Right: 24dp`, `Bottom: MediaQuery.of(context).padding.bottom + 16dp`.
- **Dimensions**: Height: `64dp`, Max Width: `480dp` (Tablet/Desktop center-constrained).
- **Backdrop Blur**: Hardware-accelerated blur via `BackdropFilter` and `ImageFilter.blur(sigmaX: 20, sigmaY: 20)`.
- **Background Fill**: Frosted Obsidian (`0xFF161B26` with `0.70` opacity).
- **Border**: `1.0dp` solid outline in Slate Obsidian (`0xFF2C3243` at `0.30` opacity).
- **Corner Radius**: `24dp` (`BorderRadius.circular(24)`).

### Sliding Active Pill Capsule (Horizontal spring-pill):
- **Background Pill**: A sliding rounded capsule behind the active tab icon/label.
- **Pill Specs**: Rounded rect (`BorderRadius.circular(16)`), height: `44dp`, filled with Soft Lavender (`0xFFB39DDB` with `0.15` opacity).
- **Spring Physics**:
  - **Curve**: `SpringSimulation` or custom physics curve (`Curves.easeOutBack` or damping ratio `0.85`, response speed `0.3s`).
  - **Scale Bounce**: When shifting tabs, the sliding capsule horizontally squashes (`width * 1.15`) and stretches along the movement vector, then snaps back to standard dimensions upon settlement.

### Interactive Tab Buttons (Spring Scale Buttons):
- **Spring Scale on Tap**: Tapping a nav button triggers a micro-animation that scales down the icon to `0.92` on touch-down, and spring-boings back to `1.0` on touch-up over `150ms`.
- **Selected Tab Icon**:
  - **Focus**: `Icons.timer` in Neon Mint (`0xFF00FFCC`)
  - **Sleep**: `Icons.bedtime` in Soft Teal (`0xFF00B4D8`)
  - **Log**: `Icons.insert_chart` in Soft Lavender (`0xFFB39DDB`)
- **Unselected Tab Icon**: Low-opacity lavender-gray (`0xFFB39DDB` with `0.50` opacity) in outlined variant (`Icons.timer_outlined`, `Icons.bedtime_outlined`, `Icons.insert_chart_outlined`).

---

## 3. "Nebula" Space Cosmic Cat Mascot Vector Specs

The Space Cosmic Cat is a fully custom-drawn vector mascot acting as the emotional anchor of the Sleep mode, guiding users into deep recovery.

```
       / \ _ / \       <-- pointed ears (left & right pointed triangles)
      (  ='v'=  )      <-- head (smooth rounded oval/circle r:80dp)
     / ( cozy ) \      <-- floppy lavender sleeping cap draped to side
    (   |    |   )
     ^ ^      ^ ^
```

### Exact Drawing Coordinates & Shapes (for CustomPainter or Custom SVGs):
1. **Cat Head**:
   - **Shape**: Smooth, slightly squished horizontal oval/circle centered (`cx: 0, cy: 0, r: 80dp`).
   - **Color Fill**: Deep Midnight Blue/Obsidian (`0xFF1B2030` solid color paint).
2. **Cat Ears**:
   - **Left Ear**: Triangular path starting from head circumference top-left (`x1: -45, y1: -65`), pointing upward-left to peak (`x2: -65, y2: -110`), returning to head (`x3: -20, y3: -75`).
   - **Right Ear**: Triangular path matching right side (`x1: 45, y1: -65`, peak `x2: 65, y2: -110`, return `x3: 20, y3: -75`).
   - **Inner Ear Fill**: Faded Lavender/Pink (`0xFFE8D3FF`).
3. **Starry Eyes (Cozy Sleeping State)**:
   - **Left/Right Eyes**: Curved eyelids shaped as thin golden arcs curving downwards (`strokeWidth: 4dp`, Starry Gold `0xFFFFD369`).
   - **Radius**: `16dp`, spanning a sweep of `120 degrees`.
4. **Starry Eyes (Awake/Alarm State)**:
   - **Left/Right Eyes**: Replaced by perfect vector five-point stars in Starry Gold (`0xFFFFD369`), filled, size `24dp`.
5. **Cozy Sleeping Cap**:
   - **Base**: A white fur band (`0xFFFFFFFF`) wrapping the top-left of the head between the ears.
   - **Body**: Conical curved tail draping off the left side of the head, colored Soft Lavender (`0xFFB39DDB`).
   - **Cap Tip & Pom-Pom**: Floppy tip hanging downwards, ending in a soft circular pom-pom (`r: 12dp`) in clean white (`0xFFFFFFFF`).

### Micro-Animation & Physics Rules:
* **Breathing Simulation**:
  - **Frequency**: `0.8Hz` (1.25s per full breathe in/out cycle).
  - **Formula**: `scaleY = 1.0 + (0.04 * sin(2 * pi * t / 1.25))`, pivoting from the bottom center of the cat torso (`Alignment.bottomCenter`).
* **Floating Nightcap Sway**:
  - The cap's lavender tip and pom-pom sway/rotate slightly in synch with the breathing rhythm.
  - **Formula**: `rotationZ = 4.0 * cos(2 * pi * t / 1.25)` (degrees), anchored at the cap base.
* **Rising "zZz" Bubbles**:
  - **Spawn**: Spawns every `2.5 seconds` near the right side of the cat's head (`x: 40, y: -20`).
  - **Movement**: Floating path drifting upward (`y -= 1.5 * delta`) and rightward (`x += 0.5 * sin(2 * pi * t / 1.5)`).
  - **Visuals**: Letter `"z"` text strings of scaling font sizes (`12sp` -> `18sp` -> `24sp`) in Soft Lavender with `opacity` fading exponentially from `1.0` to `0.0` over exactly `3.0s`.
* **Interactive Scale Bounce**:
  - Tapping the cat squishes it: `scaleX = 1.1`, `scaleY = 0.9` instantly, which then triggers a damped harmonic spring simulation restoring it to `1.0` over `600ms`.

---

## 4. Screen-by-Screen Widget Specifications

### Screen 1: Sleep Configuration (SleepTab)
- **Scaffold Backdrop**: `Background: Deep Obsidian (0xFF0B0F19)`.
- **Top Bar**: Minimal title "Sleep Center" (`fontSize: 20sp`, color: `white`, `FontWeight.w700`).
- **Wake-up Picker Wheel**:
  - **Widget type**: Custom radial hour/minute selector or clean spinner dial.
  - **Visuals**: Concentric circular track in Slate Obsidian (`0xFF161B26`), dragging handle colored Starry Gold (`0xFFFFD369`) with a soft glow.
  - **Duration Card**: Positioned inside the center of the picker wheel:
    - Row 1: "ESTIMATED REST" (`fontSize: 10sp`, color: `Soft Lavender`, letterSpacing: `1.5dp`).
    - Row 2: "7 hrs 30 min" (`fontSize: 26sp`, color: `white`, `FontWeight.w800`).
- **Wind-Down Sounds Shelf**:
  - **Header Label**: "WIND-DOWN AUDIO" (uppercase, `fontSize: 11sp`, color: `Soft Lavender`, letterSpacing: `1.5dp`).
  - **Container**: Horizontal row of scrollable sound chips.
  - **Chip Specification**:
    - Border radius: `18dp`, height: `36dp`, background: `Slate Obsidian (0xFF161B26)`.
    - Selected chip: Solid Soft Teal (`0xFF00B4D8`) with white text and a leading checkmark icon (`Icons.check`).
    - Unselected chip: Slate outline (`1dp` at `0xFF2C3243`), text color `Soft Lavender`.
- **Wind-Down Duration Picker**:
  - Row of three pill chips: `15 Min`, `30 Min`, `45 Min`.
  - Selected chip is filled with Soft Lavender (`0xFFB39DDB`), unselected is outlined.
- **CTA Start Button**:
  - **Specs**: Height `56dp`, full-width card, margin `16dp` left/right.
  - **Fill**: Soft Teal (`0xFF00B4D8`) to Midnight Sapphire gradient.
  - **Text**: `"ENTER DEEP SLEEP MODE"` in bold white, letter spacing `2.0dp`.

### Screen 2: Active Sleep Canvas (SleepCanvasScreen)
- **Scaffold Backdrop**: Full-screen linear gradient: `0xFF060913` (Top) to `0xFF010205` (Bottom).
- **Mascot Placement**: Centered vertically and horizontally. Space Cosmic Cat sleeping beneath a pulsating golden crescent moon (`Icons.nightlight_round` at `0xFFFFD369` with `0.80` opacity).
- **Clock Display**: Extremely faint digital clock (`01:23 AM`) placed `48dp` below the mascot, in Deep Slate (`0xFF2C3243`) at `0.30` opacity to minimize OLED pixel emission.
- **Exit Action**:
  - Press-and-hold button anchored at bottom center (`Bottom + 48dp`).
  - **Visuals**: A soft circular ring outline in slate (`0xFF2C3243` at `0.50` opacity) that fills with Soft Teal (`0xFF00B4D8`) clockwise as the user holds down.
  - **Copy**: "Hold to Exit Sleep Mode" (`fontSize: 12sp`, color: `Soft Lavender` at `0.60` opacity).

### Screen 3: Progressive Alarm Overlay (AlarmScreen)
- **Scaffold Backdrop**: Full-screen pulsating gradient looping from Deep Indigo (`0xFF0A0F24`) to Cosmic Purple (`0xFF321B4F`).
- **Mascot State**: Star-eyed awake Space Cat center screen with perked ears, jumping/stretching micro-animation.
- **Header Block**:
  - Title: "Rise and Shine" (`fontSize: 32sp`, color: `white`, `FontWeight.w900`, centered).
  - Time display: Current system time (`fontSize: 48sp`, color: `Starry Gold`, `FontWeight.bold`).
- **Swipe-To-Wake Slider**:
  - **Dimensions**: Height `64dp`, width `280dp`, corner radius `32dp`.
  - **Track**: Frosted glassmorphic container, filled with Slate Obsidian at `0.40` opacity.
  - **Sliding Puck**: Solid circular button inside, diameter `56dp`, color: `Starry Gold (0xFFFFD369)`.
  - **Icon**: `Icons.chevron_right` in Deep Obsidian (`0xFF0B0F19`).
  - **Tension physics**: Built using custom gesture detectors. Releases before `x >= 224dp` trigger an elastic snap back to `0` position via `AnimationController`.

### Screen 4: Wake Quality Check-in Modal
- **Backdrop Scrim**: `Colors.black54` with BackdropFilter blur `sigma: 12.0`.
- **Modal Card**: Anchored to bottom. Height `240dp`, full-width, rounded top corners `28dp`.
- **Card Background**: Frosted Obsidian (`0xFF161B26` with `0.90` opacity).
- **Emoji Row**:
  - Three oversized circular buttons (`diameter: 64dp`), spacing: `24dp` between items.
  - Button 1 (Restless): 😔 (`0xFF1B2030` outline, soft amber scale text)
  - Button 2 (Neutral): 😐 (`0xFF1B2030` outline, soft grey text)
  - Button 3 (Restored): 🟢 (`0xFF1B2030` outline, vibrant mint text)

---

## 5. Responsive Layout & Breakpoint Rules

To maintain high visual fidelity across mobile, tablet, and foldable form factors, the following layout rules must be enforced:

### Mobile Viewports (<600dp width):
- All screens utilize full-screen viewport dimensions.
- Navigation bar is locked to the bottom safe area with `16dp` side margins.
- Center dial width is dynamically constrained to `MediaQuery.of(context).size.width * 0.8`.

### Tablet & Desktop Viewports (>=600dp width):
- **Navigation Shell**: Floating bottom navigation bar is locked to a fixed width of `480dp` and centered horizontally at the bottom of the screen.
- **Active Sleep Canvas & Setup**: The content is constrained inside a central column of `520dp` max width.
- **Alarm Overlay**: Renders as a beautiful, centered glassmorphic dialog card (`width: 520dp`, `height: 640dp`, rounded corners: `28dp`) floating in the center of the display. The screen outside the card is masked with a dark cosmic backdrop filter overlay (`Colors.black87` with `sigmaX: 15, sigmaY: 15`).

---

## 6. Interaction & Micro-Haptic Codes

We implement rich, tactile haptics to elevate interactive feedback:

- **Tab Change**: `HapticFeedback.lightImpact()` on user touch-down.
- **Picker Dial Rotation**: Triggers a rapid succession of light micro-vibrations (custom pattern or quick ticks) every `15 degrees` of rotation.
- **Wind-down Sound selection**: Standard `HapticFeedback.selectionClick()`.
- **Cancel Sleep (Hold)**: Progressive, accelerating vibration during the `2.0s` hold duration, culminating in a sharp, crisp tick when successfully canceled.
- **Alarm Volume Crescendo**: Vibration pulses scale dynamically matching the chime volume:
  - *Seconds 0-15*: Low-intensity double pulses every `2.5s`.
  - *Seconds 16-30*: Medium double pulses every `1.5s`.
  - *Seconds 31-60*: Deep heartbeat dual pulses every `0.8s`.

---

## 7. Components Table

| Component Name | Description / Visual Specification | Folder / Class Path | Type |
| --- | --- | --- | --- |
| `GlassmorphicBottomNavBar` | Floating bottom navigation shell with blur filter, border highlight, and sliding background capsule. | `lib/core/widgets/glass_nav_bar.dart` | New |
| `SpringScaleButton` | Wrapper widget applying spring scale down/up on tap gestures. | `lib/core/widgets/spring_button.dart` | New |
| `NebulaMascot` | CustomPainter vector Space Cat with breathing, nightcap-swaying, and star-eyes. | `lib/features/sleep/widgets/nebula_mascot.dart` | New |
| `SleepWakePicker` | Radial time-picker dial with star-glow pointer handles. | `lib/features/sleep/widgets/sleep_picker.dart` | New |
| `SoundChipRow` | Horizontal row of sound selectors in outline and soft teal variations. | `lib/features/sleep/widgets/sound_chip_row.dart` | New |
| `SwipeToWakeSlider` | Frosted slider channel containing a golden puck with spring snapback. | `lib/features/sleep/widgets/swipe_slider.dart` | New |
| `WakeQualityModal` | Bottom-sheet modal rating rest quality with three custom tactile emojis. | `lib/features/sleep/widgets/wake_modal.dart` | New |
| `TimelineLogCard` | Left-border indicators (Mint/Teal) displaying focus duration or sleep statistics with swipe action. | `lib/features/log/widgets/log_card.dart` | New |

---

## 8. Screen Golden Test & Review Expectations

* **Mascot Breathing Precision**: Breathing scale animations must use a stable time ticker provider. Verify that low-power devices do not stutter during scale cycles.
* **Bottom Nav Alignment**: Golden tests must verify that the floating navigation bar maintains its floating margins (`16dp` safe area bottom, `24dp` sides) on narrow viewports (e.g. iPhone SE, iPhone 13 mini) without overlapping bottom indicator bars.
* **Slide-to-Wake Spring Action**: Snapping back from `<80%` drag position must be tested with flutter driver tests, validating that the handle returns exactly to `x = 0` within `150ms`.
