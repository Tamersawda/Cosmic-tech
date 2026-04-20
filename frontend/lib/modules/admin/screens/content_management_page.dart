import 'package:frontend/modules/admin/screens/content/content_editor_page.dart';
import 'package:frontend/modules/admin/widgets/content/article_list_page.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class ContentManagementPage extends StatefulWidget {
  const ContentManagementPage({super.key});

  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: ListView(
          children: [
            /// HEADER
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Content Management",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Manage articles, health guides, and platform content",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedTab = 1;
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "New Article",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// TABS
            buildTabs(),

            const SizedBox(height: 25),

            /// PAGE SWITCH
            if (selectedTab == 0)
              const ArticlesListPage()
            else
              const ContentEditorPage(),
          ],
        ),
      ),
    );
  }

  /// TAB SWITCHER
  Widget buildTabs() {
    return Container(
      padding: const EdgeInsets.all(6),

      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tabButton("Articles List", 0),
          const SizedBox(width: 10),
          tabButton("Content Editor", 1),
        ],
      ),
    );
  }

  Widget tabButton(String title, int index) {
    bool selected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),

        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
