import 'package:frontend/modules/admin/widgets/reviews/average_rating_card.dart';
import 'package:frontend/modules/admin/widgets/reviews/pagination_bar.dart';
import 'package:frontend/modules/admin/widgets/reviews/review_header.dart';
import 'package:frontend/modules/admin/widgets/reviews/reviews_table.dart';
import 'package:frontend/modules/admin/widgets/reviews/search_sort_bar.dart';
import 'package:flutter/material.dart';

class ReviewsAndRatingsPage extends StatefulWidget {
  const ReviewsAndRatingsPage({super.key});

  @override
  State<ReviewsAndRatingsPage> createState() => _ReviewsAndRatingsPageState();
}

class _ReviewsAndRatingsPageState extends State<ReviewsAndRatingsPage> {
  List<Map<String, dynamic>> reviews = [
    {
      "patient": "Anjali Rao",
      "doctor": "Dr. Priya Sharma",
      "rating": 5,
      "review": "Exceptional care. Very thorough and kind.",
      "date": "10 Mar 2026",
    },
    {
      "patient": "Rohan Gupta",
      "doctor": "Dr. Vikram Nair",
      "rating": 4,
      "review": "Good doctor. Wait time was a bit long.",
      "date": "09 Mar 2026",
    },
    {
      "patient": "Meena Iyer",
      "doctor": "Dr. Suresh Patel",
      "rating": 2,
      "review": "Was not given proper time.",
      "date": "08 Mar 2026",
    },
  ];

  String search = "";
  String sortOption = "Highest Rating";

  int currentPage = 0;
  int rowsPerPage = 3;

  List<Map<String, dynamic>> get filteredReviews {
    List<Map<String, dynamic>> list = reviews.where((r) {
      return r["patient"].toLowerCase().contains(search.toLowerCase()) ||
          r["doctor"].toLowerCase().contains(search.toLowerCase());
    }).toList();

    if (sortOption == "Highest Rating") {
      list.sort((a, b) => b["rating"].compareTo(a["rating"]));
    }

    if (sortOption == "Lowest Rating") {
      list.sort((a, b) => a["rating"].compareTo(b["rating"]));
    }

    return list;
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;

    double sum = reviews.fold(0, (prev, e) => prev + e["rating"]);

    return sum / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    List pageData = filteredReviews
        .skip(currentPage * rowsPerPage)
        .take(rowsPerPage)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: ListView(
          children: [
            const ReviewsHeader(),
            const SizedBox(height: 20),
            SearchSortBar(
              search: search,
              sortOption: sortOption,
              onSearch: (v) {
                setState(() {
                  search = v;
                });
              },
              onSortChanged: (v) {
                setState(() {
                  sortOption = v;
                });
              },
            ),
            const SizedBox(height: 25),
            AverageRatingCard(rating: averageRating),
            const SizedBox(height: 25),
            ReviewsTable(reviews: pageData),
            const SizedBox(height: 20),
            PaginationBar(
              currentPage: currentPage,
              totalItems: filteredReviews.length,
              rowsPerPage: rowsPerPage,
              onNext: () {
                setState(() {
                  currentPage++;
                });
              },
              onPrev: () {
                setState(() {
                  currentPage--;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
