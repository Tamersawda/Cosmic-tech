import 'package:frontend/modules/admin/presentation/widgets/reviews/review_row.dart';
import 'package:flutter/material.dart';

class ReviewsTable extends StatelessWidget {
  final List reviews;

  const ReviewsTable({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),

      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: Text("PATIENT")),
                Expanded(child: Text("DOCTOR")),
                Expanded(child: Text("RATING")),
                Expanded(flex: 2, child: Text("REVIEW")),
                Expanded(child: Text("DATE")),
              ],
            ),
          ),

          ...reviews.map((r) => ReviewRow(review: r)),
        ],
      ),
    );
  }
}
