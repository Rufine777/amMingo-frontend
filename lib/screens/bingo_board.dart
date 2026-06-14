import 'dart:async';
import 'package:amingo/screens/event_details.dart';
import 'package:flutter/material.dart';
import 'bingo_tile.dart';
import 'friend_verification.dart';
import 'package:amingo/screens/leaderboard_screen.dart';

class BingoBoard extends StatefulWidget {
  final String eventName;
  final String hostName;
  final int timelimit;
  final String description;

  const BingoBoard({
    super.key,
    required this.eventName,
    required this.hostName,
    required this.timelimit,
    required this.description,
  });

  @override
  State<BingoBoard> createState() => _BingoBoardState();
}

class _BingoBoardState extends State<BingoBoard> {
  List<BingoCell> board = [];

  int checkedTiles = 1;
  late int timeLeft;

  int score = 12450;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    timeLeft = widget.timelimit * 60;

    board = generateBoard();

    // TIMER LOGIC
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(content: Text("Time's up!")));

        return;
      }

      setState(() {
        timeLeft--;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // bingo board with Free tile
  List<BingoCell> generateBoard() {
    List<String> letters = List.generate(
      25,
      (i) => String.fromCharCode(65 + i),
    );

    letters.shuffle();

    letters[12] = "FREE";

    return letters
        .map((l) => BingoCell(letter: l, isMarked: l == "FREE"))
        .toList();
  }

  // TILE MARKING
  Future<void> onTileTap(int index) async {
    final cell = board[index];

    if (cell.isMarked || cell.letter == "FREE") return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendVerification(letter: cell.letter),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        board[index] = cell.copyWith(isMarked: true);
        checkedTiles++;
      });

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text("${cell.letter} verified")));
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // APP BAR
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        centerTitle: true,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/amMingo.png', height: height * 0.05),
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
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetails(
                          eventName: widget.eventName,
                          hostName: widget.hostName,
                          hostPfp: 'https://i.pravatar.cc/150?img=6',
                          joinOrStart: 'PLAY',
                          duration: widget.timelimit,
                          description: widget.description,
                        ),
                      ),
                    );
                  },
                  child: const Text("LEAVE"),
                ),

                SizedBox(width: width * 0.04),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("TOTAL SCORE", style: TextStyle(fontSize: 9)),
                    Text(
                      "$score",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                SizedBox(width: width * 0.03),

                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaderboardScreen(),
                      ),
                    ); // to be navigated to the profile page
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // BODY
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // Event Name
            Text(
              widget.eventName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),

            // host name
            Text("Hosted By: ${widget.hostName}", style: textTheme.titleSmall),

            SizedBox(height: height * 0.05),

            // BINGO BOARD
            Container(
              width: width * 0.9,
              height: height * 0.6,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(20),
              ),

              // BINGO HEADING
              child: Column(
                children: [
                  Text(
                    "B  I  N  G  O         B  O  A  R  D",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: board.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
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

                  SizedBox(height: height * 0.02),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "ITEMS CHECKED",
                                style: textTheme.bodyMedium,
                              ),
                              SizedBox(height: height * 0.01),
                              Text(
                                "$checkedTiles / ${board.length}",
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: width * 0.03),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text("TIME LEFT", style: textTheme.bodyMedium),
                              SizedBox(height: height * 0.01),
                              Text(
                                formatTime(timeLeft),
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: timeLeft < 10
                                      ? Colors.red
                                      : colorScheme.primary,
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
          ],
        ),
      ),

      // BOTTOM NAV
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetails(
                        eventName: widget.eventName,
                        hostName: widget.hostName,
                        hostPfp: 'https://i.pravatar.cc/150?img=6',
                        joinOrStart: 'PLAY',
                        duration: widget.timelimit,
                        description: widget.description,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.grid_view, color: colorScheme.onSurface),
                    SizedBox(height: height * 0.01),
                    Text(
                      "HOME",
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow, color: colorScheme.surface),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    "PLAY",
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen(),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart, color: colorScheme.onSurface),
                    const SizedBox(height: 4),
                    Text(
                      "RANKS",
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
