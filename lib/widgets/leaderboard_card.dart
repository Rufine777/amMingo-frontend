import 'package:flutter/material.dart';

Widget leaderboardCard(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final width = MediaQuery.of(context).size.width;

  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      border: Border.all(color: colorScheme.outline, width: width * 0.001),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            "1",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const CircleAvatar(radius: 22, backgroundColor: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Player 1",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "1456",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "PTS",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: width * 0.025,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
