import 'dart:async';
import 'package:amingo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:amingo/screens/leaderboard_screen.dart';

class GameMonitorScreen extends StatefulWidget {
  final String eventName;
  final int time;
  final String maxParticipants;
  final String joinCode;

  const GameMonitorScreen({
    super.key,
    required this.eventName,
    required this.time,
    required this.maxParticipants,
    required this.joinCode,
  });

  @override
  State<GameMonitorScreen> createState() => _GameMonitorScreenState();
}

class _GameMonitorScreenState extends State<GameMonitorScreen> {
  late int remainingSeconds;
  Timer? timer;
  Timer? statusTimer;
  int tilesDone = 0;
  int activePlayers = 0;
  String maxCap = '0';

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.time * 60;
    maxCap = widget.maxParticipants;
    _startTimers();
    _fetchStatus();
  }

  void _startTimers() {
    timer = Timer.periodic(const Duration(seconds: 1), (activeTimer) {
      if (remainingSeconds <= 0) {
        activeTimer.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          remainingSeconds--;
        });
      }
    });

    // Fetch status every 10 seconds and sync time
    statusTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchStatus(),
    );
  }

  Future<void> _fetchStatus() async {
    try {
      final statusResponse = await AuthService().getGameStatus(widget.joinCode);
      final statusData = statusResponse.data;

      final gameResponse = await AuthService().getGameDetails(widget.joinCode);
      final gameData = gameResponse.data;

      if (mounted) {
        setState(() {
          tilesDone = statusData['tiles_done'];
          activePlayers = statusData['active_players'];
          maxCap = statusData['max_cap'].toString();

          if (gameData['end_time'] != null) {
            final endTime = DateTime.parse(gameData['end_time']).toUtc();
            final now = DateTime.now().toUtc();
            remainingSeconds = endTime.difference(now).inSeconds;
            if (remainingSeconds < 0) remainingSeconds = 0;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching status: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    statusTimer?.cancel();
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
                'PARTICIPANTS $activePlayers',
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
        actions: [
          IconButton(
            icon: Icon(Icons.emoji_events_rounded, color: colorScheme.primary),
            tooltip: "View Leaderboard",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LeaderboardScreen(joinCode: widget.joinCode),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
                            value: '$tilesDone',
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
                            value: '$activePlayers',
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
                            value: maxCap,
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
