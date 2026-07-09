import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget activityCard(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final width = MediaQuery.of(context).size.width;
  return Container(
    padding: EdgeInsets.all(12),
    margin: EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      border: Border.all(color: colorScheme.outline, width: width * 0.001),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        CircleAvatar(radius: 22),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Player 1",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Completed Tile A", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              "1456",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: width * 0.04,
              ),
            ),
            Text(
              "PTS",
              style: TextStyle(color: Colors.grey, fontSize: width * 0.02),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(CupertinoIcons.person_badge_minus, color: Colors.red),
        ),
      ],
    ),
  );
}
