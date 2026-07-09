import 'dart:async';
import 'package:amingo/services/auth_service.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  final String? joinCode;
  const LeaderboardScreen({super.key, this.joinCode});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> leaderboard = [];
  bool isLoading = true;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
    // Auto-refresh every 15 seconds
    refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _fetchLeaderboard(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLeaderboard() async {
    if (widget.joinCode == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }
    try {
      final response = await AuthService().getLeaderboard(widget.joinCode!);
      if (mounted) {
        setState(() {
          leaderboard = response.data['leaderboard'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching leaderboard: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text(
          "LEADERBOARD",
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLeaderboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leaderboard.isNotEmpty) ...[
                    _buildPodium(width, height, colorScheme),
                    SizedBox(height: height * 0.05),
                  ],
                  Text(
                    "GLOBAL RANKING",
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontSize: width * 0.03,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (leaderboard.isEmpty)
                    const Center(child: Text("No rankings yet"))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leaderboard.length,
                      itemBuilder: (context, index) {
                        final entry = leaderboard[index];
                        return _buildRankingTile(index, entry, colorScheme);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(double width, double height, ColorScheme colorScheme) {
    final top1 = leaderboard[0];
    final top2 = leaderboard.length > 1 ? leaderboard[1] : null;
    final top3 = leaderboard.length > 2 ? leaderboard[2] : null;

    return Column(
      children: [
        Center(
          child: _podiumItem(
            top1,
            width * 0.125,
            "1ST",
            Colors.yellow,
            colorScheme,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (top2 != null)
              _podiumItem(top2, width * 0.1, "2ND", Colors.grey, colorScheme),
            if (top3 != null)
              _podiumItem(
                top3,
                width * 0.085,
                "3RD",
                Colors.orange,
                colorScheme,
              ),
          ],
        ),
      ],
    );
  }

  Widget _podiumItem(
    dynamic entry,
    double radius,
    String rank,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                (entry['name'] ?? "?")[0].toUpperCase(),
                style: TextStyle(fontSize: radius, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  rank,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          entry['name'] ?? "Unknown",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "${entry['points']} pts",
          style: TextStyle(color: colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildRankingTile(int index, dynamic entry, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            "#${index + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Text((entry['name'] ?? "?")[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry['name'] ?? "Unknown",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "${entry['points']} pts",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
