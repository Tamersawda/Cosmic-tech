import 'package:flutter/material.dart';

class ReviewsHeader extends StatelessWidget {
  const ReviewsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reviews & Ratings",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 6),

        Text(
          "Moderate patient reviews and highlight top doctors",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
