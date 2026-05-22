import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/timer_controller.dart';
import '../services/haptic_service.dart';

class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key, required this.controller});

  final TimerController controller;

  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerStateChanged);
  }

  void _onControllerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerStateChanged);
    super.dispose();
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

  String _getSoundDesc(String soundId) {
    switch (soundId) {
      case 'chime':
        return 'A soothing singing bowl pattern for clear, calm waking.';
      case 'beep':
        return 'Crisp retro synthesized chirps for reliable alerts.';
      case 'echo':
        return 'A gentle vibrating bell with long harmonious tails.';
      default:
        return '';
    }
  }

  Widget _buildWaveform(bool isPlaying) {
    final List<double> heights = [16.0, 32.0, 48.0, 24.0, 38.0, 56.0, 32.0, 42.0, 18.0, 30.0, 12.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: heights.map((h) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 4,
          height: isPlaying ? h : 6.0,
          decoration: BoxDecoration(
            color: isPlaying ? const Color(0xFF00F5D4) : const Color(0xFF2A3342),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMuted = widget.controller.alarmConfig.isMuted;
    final activeSound = widget.controller.alarmConfig.soundId;
    final isRunning = widget.controller.isRunning;

    final soundOptions = [
      {
        'id': 'chime',
        'title': 'Zen Chime',
        'subtitle': 'Zen Bowl',
        'desc': 'Deep resonance singing bowl',
        'icon': Icons.spa_outlined,
      },
      {
        'id': 'beep',
        'title': 'Retro Beep',
        'subtitle': 'Digital Synthesizer',
        'desc': 'Snappy alarm alerts',
        'icon': Icons.settings_input_hdmi_outlined,
      },
      {
        'id': 'echo',
        'title': 'Classic Bell',
        'subtitle': 'Echo Tail',
        'desc': 'Soft repeating bell chime',
        'icon': Icons.notifications_active_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Obsidian background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 120.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Studio Header
                  const Icon(
                    Icons.graphic_eq,
                    size: 38,
                    color: Color(0xFF00F5D4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sound Studio',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFF8FAFC),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customize your focus and waking vibes',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 1. Live Studio Monitor Card (Active preset & visualizer)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2530),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF2A3342),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0B0F19),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isMuted ? Icons.volume_off : Icons.volume_up,
                                    color: isMuted
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF00F5D4),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'STUDIO MONITOR',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isMuted ? 'Muted' : _getSoundLabel(activeSound),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFF8FAFC),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isMuted
                                    ? const Color(0xFF2A3342)
                                    : const Color(0xFF00F5D4).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isMuted ? 'MUTED' : 'ONLINE',
                                style: GoogleFonts.plusJakartaSans(
                                  color: isMuted ? const Color(0xFF94A3B8) : const Color(0xFF00F5D4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Waveform Visualizer
                        _buildWaveform(!isMuted && !isRunning),
                        const SizedBox(height: 18),
                        Text(
                          isMuted
                              ? 'Unmute to hear live sound previews'
                              : _getSoundDesc(activeSound),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 2. Mute Toggle Control
                  InkWell(
                    onTap: isRunning ? null : widget.controller.toggleMute,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2530).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isMuted ? const Color(0xFF2A3342) : const Color(0xFF00F5D4).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isMuted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
                            color: isMuted ? const Color(0xFF94A3B8) : const Color(0xFF00F5D4),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mute Audible Alarm',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFF8FAFC),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isMuted ? 'Muted (Vibration Only)' : 'Active (Audible Sound + Vibration)',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            key: const Key('volume-mute-toggle'),
                            activeThumbColor: const Color(0xFF00F5D4),
                            activeTrackColor: const Color(0xFF00F5D4).withValues(alpha: 0.2),
                            inactiveThumbColor: const Color(0xFF94A3B8),
                            inactiveTrackColor: const Color(0xFF2A3342),
                            value: isMuted,
                            onChanged: isRunning
                                ? null
                                : (_) {
                                    widget.controller.toggleMute();
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 3. Sound Studio Grid Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PRESET SOUNDS',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Sound Presets Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 1,
                    childAspectRatio: 3.8,
                    mainAxisSpacing: 12,
                    children: soundOptions.map((opt) {
                      final id = opt['id'] as String;
                      final title = opt['title'] as String;
                      final subtitle = opt['subtitle'] as String;
                      final desc = opt['desc'] as String;
                      final icon = opt['icon'] as IconData;
                      final isSelected = activeSound == id;

                      return Semantics(
                        button: true,
                        selected: isSelected,
                        child: InkWell(
                          key: Key('sound-chip-$id'),
                          onTap: isRunning
                              ? null
                              : () {
                                  widget.controller.selectSound(id);
                                  HapticService().mediumImpact();
                                },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00F5D4).withValues(alpha: 0.08)
                                  : const Color(0xFF1E2530),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00F5D4)
                                    : const Color(0xFF2A3342),
                                width: 1.4,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF00F5D4).withValues(alpha: 0.15)
                                        : const Color(0xFF0B0F19),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: isSelected ? const Color(0xFF00F5D4) : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            title,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: isSelected ? const Color(0xFF00F5D4) : const Color(0xFFF8FAFC),
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '•  $subtitle',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFF94A3B8),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        desc,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF94A3B8),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.play_circle_filled,
                                    color: Color(0xFF00F5D4),
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
