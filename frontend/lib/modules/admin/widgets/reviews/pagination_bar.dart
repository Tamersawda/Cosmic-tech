import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int rowsPerPage;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.rowsPerPage,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 0 ? onPrev : null,
        ),

        Text("Page ${currentPage + 1}"),

        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: (currentPage + 1) * rowsPerPage < totalItems
              ? onNext
              : null,
        ),
      ],
    );
  }
}
