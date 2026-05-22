import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/sleep_controller.dart';
import '../models/activity_log.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import 'sleep_canvas_screen.dart';

class SleepTabScreen extends StatefulWidget {
  final SleepController controller;

  const SleepTabScreen({super.key, required this.controller});

  @override
  State<SleepTabScreen> createState() => _SleepTabScreenState();
}

class _SleepTabScreenState extends State<SleepTabScreen> {
  late final HapticService _hapticService;
  late final StorageService _storageService;

  // Scroll Controllers for Picker Wheel
  late final FixedExtentScrollController _hourScrollController;
  late final FixedExtentScrollController _minuteScrollController;
  late final FixedExtentScrollController _ampmScrollController;

  List<ActivityLog> _logs = [];
  bool _isLoadingLogs = true;
  bool _isCanvasPresented = false;

  @override
  void initState() {
    super.initState();
    _hapticService = HapticService();
    _storageService = StorageService();

    // Initialize Scroll Controllers based on initial wake time
    final wakeTime = widget.controller.targetWakeTime;
    final isPm = wakeTime.hour >= 12;
    final hour12 = wakeTime.hour == 0
        ? 12
        : (wakeTime.hour > 12 ? wakeTime.hour - 12 : wakeTime.hour);

    _hourScrollController = FixedExtentScrollController(
      initialItem: hour12 - 1,
    );
    _minuteScrollController = FixedExtentScrollController(
      initialItem: wakeTime.minute,
    );
    _ampmScrollController = FixedExtentScrollController(
      initialItem: isPm ? 1 : 0,
    );

    // Listen to changes in the controller to push/pop SleepCanvasScreen
    widget.controller.addListener(_onSleepStateChanged);

    // Load logs timeline
    _loadLogs();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSleepStateChanged);
    _hourScrollController.dispose();
    _minuteScrollController.dispose();
    _ampmScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await _storageService.loadActivityLogs();
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoadingLogs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingLogs = false;
        });
      }
    }
  }

  void _onSleepStateChanged() {
    if (!mounted) return;

    if (widget.controller.isSleepActive) {
      if (!_isCanvasPresented) {
        _isCanvasPresented = true;
        Navigator.of(context)
            .push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return SleepCanvasScreen(controller: widget.controller);
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                fullscreenDialog: true,
              ),
            )
            .then((_) {
              _isCanvasPresented = false;
              _loadLogs(); // Reload logs once user returns from active sleep
            });
      }
    } else {
      if (_isCanvasPresented) {
        Navigator.of(context).pop();
        _isCanvasPresented = false;
        _loadLogs();
      }
    }
  }

  void _updateWakeTime() {
    final hour12 = _hourScrollController.selectedItem + 1;
    final minute = _minuteScrollController.selectedItem;
    final isPm = _ampmScrollController.selectedItem == 1;

    final hour24 = isPm
        ? (hour12 == 12 ? 12 : hour12 + 12)
        : (hour12 == 12 ? 0 : hour12);

    widget.controller.setTargetWakeTime(
      TimeOfDay(hour: hour24, minute: minute),
    );
  }

  Future<void> _deleteLog(String id, int index) async {
    _hapticService.lightTap();
    setState(() {
      _logs.removeAt(index);
    });
    await _storageService.deleteLogItem(id);
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dt.month - 1];
    final day = dt.day;
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $hour:$min $amPm';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds secs';
    final mins = (seconds / 60).round();
    if (mins < 60) return '$mins mins';
    final hrs = mins ~/ 60;
    final remainingMins = mins % 60;
    if (remainingMins == 0) return '$hrs hrs';
    return '$hrs hrs $remainingMins mins';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060913), // Midnight Sapphire backdrop
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            24.0,
            24.0,
            24.0,
            100.0,
          ), // Padding bottom for floating nav bar space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SLEEP',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF00FFCC), // Neon Mint
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rest & Restore',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFF8FAFC),
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.nights_stay_outlined,
                    color: Color(0xFFB39DDB), // Soft Lavender
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // --- 1. Wake Picker Wheel Block ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF161B26,
                  ).withValues(alpha: 0.4), // Slate Obsidian
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: const Color(0xFFE8D3FF).withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'ESTIMATED REST',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFE8D3FF).withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.controller.estimatedRestDuration,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Spinning wheels row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hours
                        _buildPickerWheel(
                          controller: _hourScrollController,
                          itemCount: 12,
                          labelBuilder: (index) => '${index + 1}',
                        ),
                        Text(
                          ':',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD369),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Minutes
                        _buildPickerWheel(
                          controller: _minuteScrollController,
                          itemCount: 60,
                          labelBuilder: (index) =>
                              index.toString().padLeft(2, '0'),
                        ),
                        const SizedBox(width: 8),
                        // AM / PM
                        _buildPickerWheel(
                          controller: _ampmScrollController,
                          itemCount: 2,
                          labelBuilder: (index) => index == 0 ? 'AM' : 'PM',
                          width: 60,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Wake-up Alarm Time Target',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. Wind-Down Sounds Shelf ---
              Text(
                'WIND-DOWN SOUND',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFE8D3FF).withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSoundChip('rain', '🌧️ Rain'),
                  const SizedBox(width: 12),
                  _buildSoundChip('waves', '🌊 Waves'),
                  const SizedBox(width: 12),
                  _buildSoundChip('silent', '📴 Silent'),
                ],
              ),
              const SizedBox(height: 24),

              // --- 3. Wind-Down Duration Shelf ---
              Text(
                'WIND-DOWN DURATION',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFE8D3FF).withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDurationChip(900, '15 Min'),
                  const SizedBox(width: 12),
                  _buildDurationChip(1800, '30 Min'),
                  const SizedBox(width: 12),
                  _buildDurationChip(2700, '45 Min'),
                ],
              ),
              const SizedBox(height: 32),

              // --- 4. Call To Action Trigger ---
              InkWell(
                onTap: () {
                  widget.controller.enterSleepMode();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF00FFCC), // Neon Mint
                        Color(0xFF00B4D8), // Soft Teal
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFCC).withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'ENTER DEEP SLEEP MODE',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(
                          0xFF060913,
                        ), // Midnight Sapphire dark text
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // --- 5. Timeline Logs Section ---
              Text(
                'ACTIVITY TIMELINE',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFE8D3FF).withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoadingLogs)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: CircularProgressIndicator(color: Color(0xFF00FFCC)),
                  ),
                )
              else if (_logs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B26).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: const Color(0xFF2A3342).withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.5),
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No activities registered yet.',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return _buildTimelineItem(log, index);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Wheel Selector Builder ---
  Widget _buildPickerWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
    double width = 50.0,
  }) {
    return SizedBox(
      width: width,
      height: 90.0,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 38.0,
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: 1.2,
        onSelectedItemChanged: (index) {
          _hapticService.selectionTick();
          _updateWakeTime();
          setState(() {}); // Rebuild to update "Estimated Rest" calculation
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected = controller.selectedItem == index;
            return Center(
              child: Text(
                labelBuilder(index),
                style: GoogleFonts.outfit(
                  color: isSelected
                      ? const Color(0xFFFFD369) // Starry Gold
                      : const Color(0xFF94A3B8).withValues(alpha: 0.4),
                  fontSize: isSelected ? 24 : 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Sound Shelf Chip ---
  Widget _buildSoundChip(String soundId, String label) {
    final isSelected = widget.controller.selectedSoundId == soundId;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.controller.selectWindDownSound(soundId);
          setState(() {});
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00FFCC).withValues(alpha: 0.12)
                : const Color(0xFF161B26).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00FFCC)
                  : const Color(0xFFE8D3FF).withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected
                    ? const Color(0xFF00FFCC)
                    : const Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Wind Down Duration Chip ---
  Widget _buildDurationChip(int seconds, String label) {
    final isSelected = widget.controller.windDownSeconds == seconds;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.controller.setWindDownSeconds(seconds);
          setState(() {});
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFB39DDB).withValues(
                    alpha: 0.12,
                  ) // Soft Lavender accent
                : const Color(0xFF161B26).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFB39DDB)
                  : const Color(0xFFE8D3FF).withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected
                    ? const Color(0xFFB39DDB)
                    : const Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Beautiful Timeline Card ---
  Widget _buildTimelineItem(ActivityLog log, int index) {
    final isFocus = log is FocusSession;

    String ratingEmoji = '😌';
    Color ratingColor = const Color(0xFF00FFCC);
    if (log is SleepSession) {
      if (log.rating == 'restless') {
        ratingEmoji = '😔';
        ratingColor = const Color(0xFFFF9E80);
      } else if (log.rating == 'neutral') {
        ratingEmoji = '😐';
        ratingColor = const Color(0xFFFFD369);
      } else {
        ratingEmoji = '😌';
        ratingColor = const Color(0xFF00FFCC);
      }
    }

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteLog(log.id, index),
      background: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.redAccent,
          size: 26,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left indicator column
            Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isFocus
                        ? const Color(0xFF00FFCC)
                        : const Color(0xFFFFD369),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isFocus
                                    ? const Color(0xFF00FFCC)
                                    : const Color(0xFFFFD369))
                                .withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFF161B26),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Card Panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF161B26,
                    ).withValues(alpha: 0.4), // Slate Obsidian
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                      color: const Color(0xFFE8D3FF).withValues(alpha: 0.04),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon Badge
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isFocus
                              ? const Color(0xFF00FFCC).withValues(alpha: 0.08)
                              : const Color(0xFFFFD369).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(
                          isFocus
                              ? Icons.timer_outlined
                              : Icons.nights_stay_outlined,
                          color: isFocus
                              ? const Color(0xFF00FFCC)
                              : const Color(0xFFFFD369),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFocus
                                  ? 'Focus Session Completed'
                                  : 'Sleep Cycle Finished',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFF8FAFC),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(log.timestamp),
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Duration & rating badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDuration(log.durationSeconds),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isFocus) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ratingColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: ratingColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ratingEmoji,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (log as SleepSession).rating.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: ratingColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
