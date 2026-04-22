import 'package:frontend/modules/admin/presentation/widgets/reviews/star_rating.dart';
import 'package:flutter/material.dart';

class AverageRatingCard extends StatelessWidget {
  final double rating;

  const AverageRatingCard({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),

      child: Row(
        children: [
          StarRating(rating: rating.round()),

          const SizedBox(width: 10),

          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
