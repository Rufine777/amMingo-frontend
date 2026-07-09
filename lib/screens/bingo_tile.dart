import 'package:flutter/material.dart';

class BingoTile extends StatelessWidget {
  final BingoCell cell;
  final VoidCallback onTap;

  const BingoTile({super.key, required this.cell, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool isFree = cell.letter == "FREE";
    final bool isMarked = cell.isMarked || isFree;

    final Color tileColor = isMarked
        ? colorScheme.primary
        : colorScheme.outline;

    final Color textColor = isMarked
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return GestureDetector(
      onTap: isMarked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 5),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: isFree
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 20, color: colorScheme.onPrimary),
                    const SizedBox(height: 4),
                    Text(
                      "FREE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                )
              : Text(
                  cell.letter,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}

class BingoCell {
  final String letter;
  final bool isMarked;
  final int row;
  final int col;

  const BingoCell({
    required this.letter,
    this.isMarked = false,
    required this.row,
    required this.col,
  });

  BingoCell copyWith({String? letter, bool? isMarked, int? row, int? col}) {
    return BingoCell(
      letter: letter ?? this.letter,
      isMarked: isMarked ?? this.isMarked,
      row: row ?? this.row,
      col: col ?? this.col,
    );
  }
}
