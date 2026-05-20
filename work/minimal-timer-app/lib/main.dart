import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/timer_controller.dart';
import 'screens/onboarding_screen.dart';
import 'services/background_timer_service.dart';
import 'services/haptic_service.dart';
import 'utils/test_helper.dart';
import 'widgets/ringing_overlay.dart';
import 'widgets/spring_scale_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(TimerApp(onboardingComplete: onboardingComplete, prefs: prefs));
}

class TimerApp extends StatelessWidget {
  const TimerApp({
    super.key,
    this.timerService,
    required this.onboardingComplete,
    required this.prefs,
  });

  final BackgroundTimerService? timerService;
  final bool onboardingComplete;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Timer',
      debugShowCheckedModeBanner: false,
      // System Theme: Enforced Dark Mode Only
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF0B0F19,
        ), // Deep Obsidian backdrop
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F5D4), // Electric Mint
          surface: Color(0xFF1E2530), // Slate Container
          outline: Color(0xFF2A3342), // Slate Muted
          onSurface: Color(0xFFF8FAFC), // Text Primary
          onSurfaceVariant: Color(0xFF94A3B8), // Text Secondary
        ),
        useMaterial3: true,
      ),
      initialRoute: onboardingComplete ? '/' : '/onboarding',
      onGenerateRoute: (settings) {
        if (settings.name == '/onboarding') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                OnboardingScreen(
                  onStartTiming: () async {
                    await prefs.setBool('onboarding_complete', true);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        }

        if (settings.name == '/') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                TimerScreen(timerService: timerService),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        }

        return null;
      },
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key, this.timerService});

  final BackgroundTimerService? timerService;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late final TimerController _controller;
  late final AnimationController _glowController;

  bool _isDirectEditing = false;
  final List<int> _presetMinutes = [1, 5, 10];

  @override
  void initState() {
    super.initState();
    _controller = TimerController(timerService: widget.timerService);
    _controller.addListener(_onControllerStateChanged);
    _controller.initialize();

    // Breathing glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Track running state to trigger breathing animation
    if (!isTesting) {
      _glowController.repeat(reverse: true);
    }
  }

  void _onControllerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatSemanticTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes == 0) {
      return '$seconds seconds remaining';
    }
    if (seconds == 0) {
      return '$minutes minutes remaining';
    }
    return '$minutes minutes and $seconds seconds remaining';
  }

  String _getSoundLabel(String soundId) {
    switch (soundId) {
      case 'chime':
        return 'Chime (Zen Bowl)';
      case 'beep':
        return 'Beep (Digital)';
      case 'echo':
        return 'Echo (Classic Bell)';
      default:
        return 'Chime (Zen Bowl)';
    }
  }

  // Edit custom preset block
  void _editPresetMinutes(int index) {
    final TextEditingController textEditingController = TextEditingController(
      text: _presetMinutes[index].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2530),
          title: Text(
            'Edit Custom Preset',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFF8FAFC),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: textEditingController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: GoogleFonts.outfit(
              color: const Color(0xFF00F5D4),
              fontSize: 24,
            ),
            decoration: const InputDecoration(
              suffixText: 'minutes',
              suffixStyle: TextStyle(color: Color(0xFF94A3B8)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2A3342)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00F5D4)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color(0xFF94A3B8)),
              ),
            ),
            TextButton(
              onPressed: () {
                final int? val = int.tryParse(textEditingController.text);
                if (val != null && val > 0 && val <= 99) {
                  setState(() {
                    _presetMinutes[index] = val;
                  });
                  HapticService().mediumImpact();
                }
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(color: const Color(0xFF00F5D4)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDirectInputField() {
    return SizedBox(
      width: 140,
      height: 70,
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          color: const Color(0xFF00F5D4),
          fontSize: 48,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFF00F5D4),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '00',
          hintStyle: TextStyle(color: Color(0xFF2A3342)),
        ),
        onSubmitted: (value) {
          final parsed = int.tryParse(value);
          if (parsed != null && parsed > 0) {
            _controller.setDirectSeconds(parsed * 60);
            HapticService().mediumImpact();
          }
          setState(() {
            _isDirectEditing = false;
          });
        },
      ),
    );
  }

  Widget _buildSoundConfigUI(BuildContext context) {
    final isMuted = _controller.alarmConfig.isMuted;
    final activeSound = _controller.alarmConfig.soundId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Frosted Glassmorphism sound settings bar
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2530).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x0DFFFFFF), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: isMuted
                        ? "Unmute alarm sound. Currently muted."
                        : "Mute alarm sound. Currently playing ${_getSoundLabel(activeSound)}.",
                    button: true,
                    child: IconButton(
                      key: const Key('volume-mute-toggle'),
                      icon: Icon(
                        isMuted ? Icons.volume_off : Icons.volume_up,
                        color: _controller.isRunning
                            ? const Color(0xFF2A3342)
                            : const Color(0xFF00F5D4),
                      ),
                      onPressed: _controller.isRunning
                          ? null
                          : _controller.toggleMute,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isMuted ? "Muted" : _getSoundLabel(activeSound),
                    style: GoogleFonts.plusJakartaSans(
                      color: _controller.isRunning
                          ? const Color(0xFF94A3B8).withValues(alpha: 0.4)
                          : const Color(0xFFF8FAFC),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: const Key('expand-sound-selector-button'),
                    icon: Icon(
                      _controller.isSoundSelectorExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: _controller.isRunning
                          ? const Color(0xFF2A3342)
                          : const Color(0xFF00F5D4),
                    ),
                    onPressed: _controller.isRunning
                        ? null
                        : _controller.toggleSoundSelector,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_controller.isSoundSelectorExpanded) ...[
          const SizedBox(height: 12),
          _buildSoundChips(context),
        ],
      ],
    );
  }

  Widget _buildSoundChips(BuildContext context) {
    final soundOptions = [
      {
        'id': 'chime',
        'label': 'Chime (Zen Bowl)',
        'semantic': 'Zen Bowl chime tone. Tap to select and play preview.',
      },
      {
        'id': 'beep',
        'label': 'Beep (Digital)',
        'semantic': 'Digital beep tone. Tap to select and play preview.',
      },
      {
        'id': 'echo',
        'label': 'Echo (Classic Bell)',
        'semantic': 'Classic Bell echo tone. Tap to select and play preview.',
      },
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: soundOptions.map((opt) {
        final id = opt['id'] as String;
        final label = opt['label'] as String;
        final semanticLabel = opt['semantic'] as String;
        final isSelected = _controller.alarmConfig.soundId == id;

        return Semantics(
          label: semanticLabel,
          button: true,
          selected: isSelected,
          child: ChoiceChip(
            key: Key('sound-chip-$id'),
            label: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected
                    ? const Color(0xFF0B0F19)
                    : const Color(0xFF94A3B8),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFF00F5D4),
            backgroundColor: const Color(0xFF1E2530),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF00F5D4)
                    : const Color(0xFF2A3342),
                width: 1.2,
              ),
            ),
            showCheckmark: false,
            onSelected: _controller.isRunning
                ? null
                : (selected) {
                    if (selected) {
                      _controller.selectSound(id);
                    }
                  },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canReset =
        _controller.remainingSeconds != _controller.durationSeconds ||
        _controller.isRunning;
    final durationLabel = '${_controller.durationSeconds ~/ 60} min';

    Widget screen = Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Obsidian background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF94A3B8)),
            tooltip: 'Help & Tutorial',
            onPressed: () {
              Navigator.of(context).pushNamed('/onboarding');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dialSize = math.min(
              280.0,
              math.max(
                200.0,
                math.min(
                  constraints.maxWidth - 48,
                  constraints.maxHeight * .38,
                ),
              ),
            );

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Timer',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFF8FAFC),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Minimal focus countdown',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Central interactive visual dial
                      Semantics(
                        label: 'Timer display',
                        value: _formatSemanticTime(
                          _controller.remainingSeconds,
                        ),
                        liveRegion: true,
                        child: SizedBox.square(
                          dimension: dialSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Breathing Glow (Running State)
                              if (_controller.isRunning)
                                AnimatedBuilder(
                                  animation: _glowController,
                                  builder: (context, child) {
                                    final double val = _glowController.value;
                                    final double scale = 1.0 + (val * 0.05);
                                    final double opacity = 0.06 + (val * 0.12);

                                    return Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        height: dialSize - 16,
                                        width: dialSize - 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF00F5D4,
                                              ).withValues(alpha: opacity),
                                              blurRadius: 36,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              // Interactive Rotary SpringDial
                              Positioned.fill(
                                child: SpringDial(
                                  controller: _controller,
                                  enabled: !_controller.isRunning,
                                ),
                              ),

                              // Time Readout & Double Tap trigger
                              GestureDetector(
                                onDoubleTap: () {
                                  if (!_controller.isRunning) {
                                    HapticService().lightTap();
                                    setState(() {
                                      _isDirectEditing = true;
                                    });
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _isDirectEditing
                                        ? _buildDirectInputField()
                                        : Text(
                                            _formatSeconds(
                                              _controller.remainingSeconds,
                                            ),
                                            key: const Key('timer-display'),
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFF8FAFC),
                                              fontSize: 52,
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                              letterSpacing: -1.2,
                                            ),
                                          ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _controller.statusLabel,
                                      key: const Key('timer-status'),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Duration controls, presets, and +/- adjusters
                      Column(
                        children: [
                          Text(
                            'Duration $durationLabel',
                            key: const Key('duration-label'),
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFF8FAFC),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Custom morphing preset cards with spring scaling
                          Wrap(
                            alignment: WrapAlignment.center,
                            runSpacing: 8,
                            spacing: 8,
                            children: List.generate(_presetMinutes.length, (
                              index,
                            ) {
                              final int minutes = _presetMinutes[index];
                              final bool isSelected =
                                  _controller.durationSeconds == minutes * 60;

                              return GestureDetector(
                                onLongPress: !_controller.isRunning
                                    ? () => _editPresetMinutes(index)
                                    : null,
                                child: ChoiceChip(
                                  key: Key('duration-$minutes-minute-chip'),
                                  label: Text('$minutes min'),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF00F5D4),
                                  backgroundColor: const Color(0xFF1E2530),
                                  labelStyle: GoogleFonts.plusJakartaSans(
                                    color: isSelected
                                        ? const Color(0xFF0B0F19)
                                        : const Color(0xFF94A3B8),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? const Color(0xFF00F5D4)
                                          : const Color(0xFF2A3342),
                                      width: 1.2,
                                    ),
                                  ),
                                  showCheckmark: false,
                                  onSelected: !_controller.isRunning
                                      ? (_) {
                                          _controller.selectDuration(minutes);
                                        }
                                      : null,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpringScaleButton(
                                enabled: !_controller.isRunning,
                                onTap: () => _controller.adjustDuration(-60),
                                child: Container(
                                  key: const Key('decrease-duration-button'),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1E2530),
                                    border: Border.all(
                                      color: const Color(0xFF2A3342),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              SpringScaleButton(
                                enabled: !_controller.isRunning,
                                onTap: () => _controller.adjustDuration(60),
                                child: Container(
                                  key: const Key('increase-duration-button'),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1E2530),
                                    border: Border.all(
                                      color: const Color(0xFF2A3342),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildSoundConfigUI(context),
                      const SizedBox(height: 28),

                      // Main spring action row (Play/Pause, Reset)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpringScaleButton(
                            enabled: true,
                            onTap: _controller.toggleTimer,
                            child: Container(
                              key: const Key('start-pause-button'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F5D4),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00F5D4,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _controller.isRunning
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: const Color(0xFF0B0F19),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _controller.isRunning
                                        ? 'Pause'
                                        : _controller.remainingSeconds == 0
                                        ? 'Restart'
                                        : 'Start',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF0B0F19),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SpringScaleButton(
                            enabled: canReset,
                            onTap: canReset ? _controller.resetTimer : () {},
                            child: Container(
                              key: const Key('reset-button'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: canReset
                                    ? const Color(0xFF1E2530)
                                    : const Color(
                                        0xFF161B26,
                                      ).withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: canReset
                                      ? const Color(0xFF2A3342)
                                      : const Color(0xFF1E2530),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: canReset
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF2A3342),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reset',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: canReset
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF2A3342),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Render ringing overlay when countdown finishes
    if (_controller.remainingSeconds == 0 &&
        _controller.statusLabel == 'Done') {
      screen = Stack(
        children: [
          screen,
          Positioned.fill(
            child: RingingOverlay(
              onDismiss: _controller.dismissAlarm,
              onRestart: () {
                _controller.dismissAlarm();
                _controller.toggleTimer();
              },
            ),
          ),
        ],
      );
    }

    return WithForegroundTask(child: screen);
  }
}

// Snappy custom spring dial
class SpringDial extends StatefulWidget {
  final TimerController controller;
  final bool enabled;

  const SpringDial({
    super.key,
    required this.controller,
    required this.enabled,
  });

  @override
  State<SpringDial> createState() => _SpringDialState();
}

class _SpringDialState extends State<SpringDial> {
  int _lastSnappedMinute = 5;

  void _updateDragAngle(Offset localPosition, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final dx = localPosition.dx - centerX;
    final dy = localPosition.dy - centerY;

    double angle = math.atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    // Polar translation range relative to 12 o'clock (-pi/2)
    double normalizedAngle = angle + math.pi / 2;
    if (normalizedAngle < 0) {
      normalizedAngle += 2 * math.pi;
    } else if (normalizedAngle > 2 * math.pi) {
      normalizedAngle -= 2 * math.pi;
    }

    double percent = normalizedAngle / (2 * math.pi);
    int selectedMinutes = (percent * 99).clamp(1, 99).round();

    if (selectedMinutes != _lastSnappedMinute) {
      _lastSnappedMinute = selectedMinutes;
      widget.controller.setDirectSeconds(selectedMinutes * 60);
      HapticService().selectionTick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: widget.enabled
          ? (details) {
              final box = context.findRenderObject() as RenderBox;
              _updateDragAngle(details.localPosition, box.size);
            }
          : null,
      onPanEnd: widget.enabled
          ? (details) {
              HapticService().lightTap();
            }
          : null,
      child: CustomPaint(
        painter: _DialPainter(
          progress: widget.controller.elapsedProgress,
          durationSeconds: widget.controller.durationSeconds,
          remainingSeconds: widget.controller.remainingSeconds,
          isRunning: widget.controller.isRunning,
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progress;
  final int durationSeconds;
  final int remainingSeconds;
  final bool isRunning;

  _DialPainter({
    required this.progress,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    // 1. Draw outer background track: Slate Muted
    final trackPaint = Paint()
      ..color = const Color(0xFF2A3342)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw outer glowing ring in Setup (Idle) state
    if (!isRunning) {
      final idlePaint = Paint()
        ..color = const Color(0xFF00F5D4).withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;
      canvas.drawCircle(center, radius, idlePaint);
    }

    // 3. Draw radial Mint filled progress arc starting at 12 o'clock (-pi/2)
    if (progress > 0.0) {
      final fillPaint = Paint()
        ..color = const Color(0xFF00F5D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fillPaint,
      );

      // Draw active glowing tick at the end of the arc
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final handlePos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final handlePaint = Paint()
        ..color = const Color(0xFFF8FAFC)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(handlePos, 4.0, handlePaint);

      final handleGlowPaint = Paint()
        ..color = const Color(0xFF00F5D4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(handlePos, 7.0, handleGlowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.durationSeconds != durationSeconds ||
        oldDelegate.remainingSeconds != remainingSeconds ||
        oldDelegate.isRunning != isRunning;
  }
}
