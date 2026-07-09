import 'dart:async';
import 'package:amingo/services/auth_service.dart';
import 'package:amingo/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'bingo_tile.dart';
import 'friend_verification.dart';
import 'package:amingo/screens/leaderboard_screen.dart';

class BingoBoard extends StatefulWidget {
  final String eventName;
  final String hostName;
  final int timelimit;
  final String joinCode;
  final String description;

  const BingoBoard({
    super.key,
    required this.eventName,
    required this.hostName,
    required this.timelimit,
    required this.joinCode,
    required this.description,
  });

  @override
  State<BingoBoard> createState() => _BingoBoardState();
}

class _BingoBoardState extends State<BingoBoard> {
  List<BingoCell> board = [];
  int checkedTiles = 0;
  late int timeLeft;
  int score = 0;
  int bingoId = 0;
  bool isLoading = true;
  int boardSize = 5;
  DateTime? endTime;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Fallback if API takes time
    timeLeft = widget.timelimit * 60;
    _fetchBoard();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (endTime != null) {
        final now = DateTime.now().toUtc();
        final diff = endTime!.difference(now).inSeconds;
        if (mounted) {
          setState(() {
            timeLeft = diff > 0 ? diff : 0;
          });
        }
        if (diff <= 0) {
          t.cancel();
          _showTimeUp();
        }
      } else {
        if (timeLeft <= 0) {
          t.cancel();
          _showTimeUp();
          return;
        }
        if (mounted) {
          setState(() {
            timeLeft--;
          });
        }
      }
    });
  }

  void _showTimeUp() {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text("Time's up!")));
    }
  }

  Future<void> _fetchBoard() async {
    try {
      final response = await AuthService().getBoard(widget.joinCode);
      final data = response.data;
      final List<dynamic> tilesData = data['tiles'];

      final gameResponse = await AuthService().getGameDetails(widget.joinCode);
      final gameData = gameResponse.data;

      if (mounted) {
        setState(() {
          bingoId = data['bingo_id'];
          score = data['points'];

          boardSize = (tilesData.length == 9)
              ? 3
              : (tilesData.length == 16)
              ? 4
              : 5;

          board = tilesData.map((t) {
            String char = (t['bingo_char'] ?? "?")
                .toString()
                .trim()
                .toUpperCase();
            return BingoCell(
              letter: char,
              isMarked: t['image_url'] != null,
              row: t['row'] ?? 0,
              col: t['col'] ?? 0,
            );
          }).toList();

          if (gameData['end_time'] != null) {
            endTime = DateTime.parse(gameData['end_time']).toUtc();
          }

          checkedTiles = board.where((c) => c.isMarked).length;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching board: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // TILE MARKING
  Future<void> onTileTap(int index) async {
    final cell = board[index];

    if (cell.isMarked || cell.letter == "FREE") return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendVerification(
          letter: cell.letter,
          bingoId: bingoId,
          row: cell.row,
          col: cell.col,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      _fetchBoard(); // Refresh board after successful submission
    }
  }

  String formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/amMingo.png', height: 40),
            const SizedBox(width: 8),
            Text(
              "Amingo",
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          _buildScoreBadge(colorScheme),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              _buildHeader(textTheme, colorScheme),
              const SizedBox(height: 24),
              _buildBingoBoard(colorScheme, textTheme, size),
              const SizedBox(height: 24),
              _buildStats(colorScheme, textTheme, size),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(colorScheme, textTheme),
    );
  }

  Widget _buildScoreBadge(ColorScheme cs) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "SCORE",
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            ),
            Text(
              "$score",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme tt, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            widget.eventName,
            textAlign: TextAlign.center,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text("Hosted By: ${widget.hostName}", style: tt.titleSmall),
        ],
      ),
    );
  }

  Widget _buildBingoBoard(ColorScheme cs, TextTheme tt, Size size) {
    final double boardWidth = size.width * 0.92;
    return Center(
      child: Container(
        width: boardWidth,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "B  I  N  G  O      B  O  A  R  D",
              style: tt.titleMedium?.copyWith(
                color: cs.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: board.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: boardSize,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return BingoTile(
                      cell: board[index],
                      onTap: () => onTileTap(index),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(ColorScheme cs, TextTheme tt, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              "ITEMS CHECKED",
              "$checkedTiles / ${board.length}",
              cs,
              tt,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              "TIME LEFT",
              formatTime(timeLeft),
              cs,
              tt,
              isTimer: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    ColorScheme cs,
    TextTheme tt, {
    bool isTimer = false,
  }) {
    final Color valColor = (isTimer && timeLeft < 60)
        ? Colors.red
        : cs.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ColorScheme cs, TextTheme tt) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.grid_view_rounded, "HOME", false, cs, tt, () {
              Navigator.pop(context);
            }),
            _navItem(Icons.play_arrow_rounded, "PLAY", true, cs, tt, () {}),
            _navItem(Icons.leaderboard_rounded, "RANKS", false, cs, tt, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LeaderboardScreen(joinCode: widget.joinCode),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool isActive,
    ColorScheme cs,
    TextTheme tt,
    VoidCallback onTap,
  ) {
    final Color color = isActive ? cs.primary : cs.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isActive
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: cs.onPrimary, size: 24),
                  )
                : Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
