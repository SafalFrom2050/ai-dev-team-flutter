import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F63)),
        scaffoldBackgroundColor: const Color(0xFFFAF9F5),
        useMaterial3: true,
      ),
      home: const TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int _defaultSeconds = 5 * 60;
  static const int _minimumSeconds = 60;
  static const int _maximumSeconds = 99 * 60;

  Timer? _ticker;
  int _durationSeconds = _defaultSeconds;
  int _remainingSeconds = _defaultSeconds;

  bool get _isRunning => _ticker?.isActive ?? false;

  double get _elapsedProgress {
    if (_durationSeconds == 0) {
      return 0;
    }

    return 1 - (_remainingSeconds / _durationSeconds);
  }

  String get _statusLabel {
    if (_remainingSeconds == 0) {
      return 'Done';
    }

    if (_isRunning) {
      return 'Running';
    }

    if (_remainingSeconds < _durationSeconds) {
      return 'Paused';
    }

    return 'Ready';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _selectDuration(int minutes) {
    if (_isRunning) {
      return;
    }

    final seconds = minutes * 60;
    setState(() {
      _durationSeconds = seconds;
      _remainingSeconds = seconds;
    });
  }

  void _adjustDuration(int deltaSeconds) {
    if (_isRunning) {
      return;
    }

    final nextDuration = math.min(
      _maximumSeconds,
      math.max(_minimumSeconds, _durationSeconds + deltaSeconds),
    );

    setState(() {
      _durationSeconds = nextDuration;
      _remainingSeconds = nextDuration;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
      return;
    }

    if (_remainingSeconds == 0) {
      setState(() {
        _remainingSeconds = _durationSeconds;
      });
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
    setState(() {});
  }

  void _pauseTimer() {
    _ticker?.cancel();
    setState(() {});
  }

  void _resetTimer() {
    _ticker?.cancel();
    setState(() {
      _remainingSeconds = _durationSeconds;
    });
  }

  void _onTick(Timer timer) {
    if (_remainingSeconds <= 1) {
      timer.cancel();
      setState(() {
        _remainingSeconds = 0;
      });
      return;
    }

    setState(() {
      _remainingSeconds -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dialSize = math.min(
              320.0,
              math.max(
                180.0,
                math.min(
                  constraints.maxWidth - 48,
                  constraints.maxHeight * .36,
                ),
              ),
            );

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Timer',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Minimal focus countdown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _TimerDial(
                        elapsedProgress: _elapsedProgress,
                        formattedTime: _formatSeconds(_remainingSeconds),
                        semanticTime: _formatSemanticTime(_remainingSeconds),
                        size: dialSize,
                        statusLabel: _statusLabel,
                      ),
                      const SizedBox(height: 28),
                      _DurationControls(
                        currentDurationSeconds: _durationSeconds,
                        enabled: !_isRunning,
                        onAdjustDuration: _adjustDuration,
                        onSelectDuration: _selectDuration,
                      ),
                      const SizedBox(height: 20),
                      _TimerActions(
                        isRunning: _isRunning,
                        canReset: _remainingSeconds != _durationSeconds,
                        isComplete: _remainingSeconds == 0,
                        onReset: _resetTimer,
                        onToggleTimer: _toggleTimer,
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
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
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
}

class _TimerDial extends StatelessWidget {
  const _TimerDial({
    required this.elapsedProgress,
    required this.formattedTime,
    required this.semanticTime,
    required this.size,
    required this.statusLabel,
  });

  final double elapsedProgress;
  final String formattedTime;
  final String semanticTime;
  final double size;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Timer display',
      value: semanticTime,
      liveRegion: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: elapsedProgress,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  key: const Key('timer-display'),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusLabel,
                  key: const Key('timer-status'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationControls extends StatelessWidget {
  const _DurationControls({
    required this.currentDurationSeconds,
    required this.enabled,
    required this.onAdjustDuration,
    required this.onSelectDuration,
  });

  final int currentDurationSeconds;
  final bool enabled;
  final ValueChanged<int> onAdjustDuration;
  final ValueChanged<int> onSelectDuration;

  @override
  Widget build(BuildContext context) {
    final durationLabel = '${currentDurationSeconds ~/ 60} min';

    return Column(
      children: [
        Text(
          'Duration $durationLabel',
          key: const Key('duration-label'),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 8,
          spacing: 8,
          children: [
            _DurationChip(
              minutes: 1,
              currentDurationSeconds: currentDurationSeconds,
              enabled: enabled,
              onSelected: onSelectDuration,
            ),
            _DurationChip(
              minutes: 5,
              currentDurationSeconds: currentDurationSeconds,
              enabled: enabled,
              onSelected: onSelectDuration,
            ),
            _DurationChip(
              minutes: 10,
              currentDurationSeconds: currentDurationSeconds,
              enabled: enabled,
              onSelected: onSelectDuration,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.outlined(
              key: const Key('decrease-duration-button'),
              onPressed: enabled ? () => onAdjustDuration(-60) : null,
              tooltip: 'Decrease duration',
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              key: const Key('increase-duration-button'),
              onPressed: enabled ? () => onAdjustDuration(60) : null,
              tooltip: 'Increase duration',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.currentDurationSeconds,
    required this.enabled,
    required this.minutes,
    required this.onSelected,
  });

  final int currentDurationSeconds;
  final bool enabled;
  final int minutes;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = currentDurationSeconds == minutes * 60;

    return ChoiceChip(
      key: Key('duration-$minutes-minute-chip'),
      label: Text('$minutes min'),
      selected: selected,
      onSelected: enabled ? (_) => onSelected(minutes) : null,
      showCheckmark: false,
    );
  }
}

class _TimerActions extends StatelessWidget {
  const _TimerActions({
    required this.canReset,
    required this.isComplete,
    required this.isRunning,
    required this.onReset,
    required this.onToggleTimer,
  });

  final bool canReset;
  final bool isComplete;
  final bool isRunning;
  final VoidCallback onReset;
  final VoidCallback onToggleTimer;

  @override
  Widget build(BuildContext context) {
    final primaryLabel = isRunning
        ? 'Pause'
        : isComplete
        ? 'Restart'
        : 'Start';

    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 12,
      spacing: 12,
      children: [
        FilledButton.icon(
          key: const Key('start-pause-button'),
          onPressed: onToggleTimer,
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(primaryLabel),
        ),
        OutlinedButton.icon(
          key: const Key('reset-button'),
          onPressed: canReset ? onReset : null,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
