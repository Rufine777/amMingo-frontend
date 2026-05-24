import 'dart:async';

import 'package:flutter/material.dart';

class GameMonitorScreen extends StatefulWidget {
  final String eventName;
  final int time;
  final String maxParticipants;

  const GameMonitorScreen({
    super.key,
    required this.eventName,
    required this.time,
    required this.maxParticipants,
  });

  @override
  State<GameMonitorScreen> createState() => _GameMonitorScreenState();
}

class _GameMonitorScreenState extends State<GameMonitorScreen> {
  late int remainingSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.time * 60;
    timer = Timer.periodic(const Duration(seconds: 1), (activeTimer) {
      if (remainingSeconds <= 0) {
        activeTimer.cancel();
        return;
      }

      setState(() {
        remainingSeconds--;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  int get hours => remainingSeconds ~/ 3600;
  int get minutes => (remainingSeconds % 3600) ~/ 60;
  int get seconds => remainingSeconds % 60;

  int get totalSeconds => widget.time * 60;

  double get progress {
    if (totalSeconds <= 0) return 0;
    return (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  Widget _badge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }

  Widget _timeChip(BuildContext context, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required BuildContext context,
    required String label,
    required String value,
    required String helper,
    required IconData icon,
    required Color accent,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String timeLabel,
    required Color accent,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, color: accent, size: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.sports_esports_rounded,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAME MONITOR',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withValues(alpha: 0.88),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.eventName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.bold,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Live event control room',
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.88),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _badge(context, 'LIVE', colorScheme.onPrimary),
              _badge(
                context,
                'PARTICIPANTS ${widget.maxParticipants}',
                colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'AMINGO',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroHeader(context),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TIME LEFT',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _timeChip(context, twoDigits(hours), 'HRS'),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 22,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _timeChip(context, twoDigits(minutes), 'MIN'),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 22,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _timeChip(context, twoDigits(seconds), 'SEC'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 24) / 3;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _statCard(
                            context: context,
                            label: 'TILES DONE',
                            value: '142',
                            helper: 'Marked successfully',
                            icon: Icons.grid_view_rounded,
                            accent: colorScheme.primary,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _statCard(
                            context: context,
                            label: 'ACTIVE',
                            value: '32',
                            helper: 'Players online right now',
                            icon: Icons.people_alt_rounded,
                            accent: Colors.teal,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _statCard(
                            context: context,
                            label: 'MAX CAP',
                            value: widget.maxParticipants,
                            helper: 'Player limit',
                            icon: Icons.how_to_reg_rounded,
                            accent: Colors.deepOrange,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle(
                      context,
                      'Live Activity Feed',
                      'Latest updates from the board',
                    ),
                    Text(
                      'JUST NOW',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _activityCard(
                  context: context,
                  title: 'Player activity update',
                  subtitle:
                      'A new player just completed a tile and the board is updating in real time.',
                  timeLabel: 'NOW',
                  accent: colorScheme.primary,
                ),
                _activityCard(
                  context: context,
                  title: 'Leaderboard reshuffle',
                  subtitle:
                      'One player crossed into the top three after a fresh tile verification.',
                  timeLabel: '2M',
                  accent: Colors.teal,
                ),
                _activityCard(
                  context: context,
                  title: 'Event pulse check',
                  subtitle:
                      'Attendance is stable and the game monitor is tracking live participants.',
                  timeLabel: '5M',
                  accent: Colors.deepOrange,
                ),
                _activityCard(
                  context: context,
                  title: 'Match activity synced',
                  subtitle:
                      'Recent bingo updates were pushed to the monitor successfully.',
                  timeLabel: '8M',
                  accent: Colors.indigo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
