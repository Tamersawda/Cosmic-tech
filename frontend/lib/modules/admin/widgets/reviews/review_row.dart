import 'package:flutter/material.dart';
import 'star_rating.dart';

class ReviewRow extends StatelessWidget {
  final Map review;

  const ReviewRow({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xfff1f5f9))),
      ),

      child: Row(
        children: [
          Expanded(child: Text(review["patient"])),

          Expanded(child: Text(review["doctor"])),

          Expanded(child: StarRating(rating: review["rating"])),

          Expanded(flex: 2, child: Text(review["review"])),

          Expanded(child: Text(review["date"])),
        ],
      ),
    );
  }
}
