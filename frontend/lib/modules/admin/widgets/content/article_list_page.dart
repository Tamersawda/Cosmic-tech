import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class ArticlesListPage extends StatelessWidget {
  const ArticlesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),

      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        child: SizedBox(
          width: 1000,

          child: Column(
            children: [
              /// HEADER
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),

                child: Row(
                  children: [
                    Expanded(flex: 4, child: Text("ARTICLE")),
                    Expanded(flex: 2, child: Text("CATEGORY")),
                    Expanded(flex: 2, child: Text("STATUS")),
                    Expanded(flex: 2, child: Text("DATE")),
                    Expanded(flex: 2, child: Text("VIEWS")),
                    Expanded(flex: 2, child: Text("ACTIONS")),
                  ],
                ),
              ),

              const Divider(height: 1),

              articleRow(
                title: "10 Tips for Heart Health",
                id: "ART-001",
                category: "Cardiology",
                status: "Published",
                date: "08 Mar 2026",
                views: "1,240",
              ),

              articleRow(
                title: "Understanding Anxiety Disorders",
                id: "ART-002",
                category: "Mental Health",
                status: "Published",
                date: "05 Mar 2026",
                views: "2,130",
              ),

              articleRow(
                title: "Managing Diabetes Through Diet",
                id: "ART-003",
                category: "General Health",
                status: "Draft",
                date: "03 Mar 2026",
                views: "0",
              ),

              articleRow(
                title: "Skin Care in Summer Months",
                id: "ART-004",
                category: "Dermatology",
                status: "Published",
                date: "28 Feb 2026",
                views: "876",
              ),

              articleRow(
                title: "When to See a Neurologist",
                id: "ART-005",
                category: "Neurology",
                status: "Review",
                date: "25 Feb 2026",
                views: "0",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ARTICLE ROW
  Widget articleRow({
    required String title,
    required String id,
    required String category,
    required String status,
    required String date,
    required String views,
  }) {
    Color badgeColor;

    if (status == "Published") {
      badgeColor = Colors.green;
    } else if (status == "Draft") {
      badgeColor = Colors.grey;
    } else {
      badgeColor = Colors.orange;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

          child: Row(
            children: [
              /// ARTICLE COLUMN
              Expanded(
                flex: 4,

                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,

                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.article_outlined,
                        color: AppColors.primaryColor,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// CATEGORY
              Expanded(
                flex: 2,
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              /// STATUS
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              /// DATE
              Expanded(
                flex: 2,
                child: Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              /// VIEWS
              Expanded(
                flex: 2,
                child: Text(
                  views,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              /// ACTIONS
              const Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(Icons.edit_outlined, color: AppColors.primaryColor),

                    SizedBox(width: 12),

                    Icon(Icons.delete_outline, color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),
      ],
    );
  }
}
