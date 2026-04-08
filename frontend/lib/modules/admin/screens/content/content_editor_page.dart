import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_card_container.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_dropdown_field.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_text_field.dart';

class ContentEditorPage extends StatefulWidget {
  const ContentEditorPage({super.key});

  @override
  State<ContentEditorPage> createState() => _ContentEditorPageState();
}

class _ContentEditorPageState extends State<ContentEditorPage> {
  final TextEditingController titleController = TextEditingController(
    text: "10 Tips for Heart Health",
  );

  final TextEditingController contentController = TextEditingController();

  String category = "Cardiology";
  String status = "Draft";

  @override
  Widget build(BuildContext context) {
    bool mobile = Responsive.isMobile(context);

    return Padding(
      padding: const EdgeInsets.all(20),

      child: mobile
          ? Column(
              children: [
                editorCard(),

                const SizedBox(height: 20),

                publishSettings(),

                const SizedBox(height: 20),

                featuredImage(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT EDITOR
                Expanded(flex: 3, child: editorCard()),

                const SizedBox(width: 20),

                /// RIGHT PANEL
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      publishSettings(),

                      const SizedBox(height: 20),

                      featuredImage(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// EDITOR
  Widget editorCard() {
    return AdminCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminTextField(
            topLabel: "Article Title",
            controller: titleController,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),

          const SizedBox(height: 20),

          const Text("Content"),

          const SizedBox(height: 8),

          toolbar(),

          const SizedBox(height: 8),

          AdminTextField(
            controller: contentController,
            maxLines: 15,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ],
      ),
    );
  }

  /// TOOLBAR
  Widget toolbar() {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          toolbarButton("B"),
          toolbarButton("I"),
          toolbarButton("U"),
          toolbarButton("H1"),
          toolbarButton("H2"),
          toolbarButton("• List"),
          toolbarButton("Link"),
        ],
      ),
    );
  }

  Widget toolbarButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),

      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  /// PUBLISH SETTINGS
  Widget publishSettings() {
    return AdminCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Publish Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          AdminDropdownField<String>(
            label: "Category",
            value: category,
            items: const [
              DropdownMenuItem(value: "Cardiology", child: Text("Cardiology")),

              DropdownMenuItem(
                value: "Mental Health",
                child: Text("Mental Health"),
              ),

              DropdownMenuItem(
                value: "Dermatology",
                child: Text("Dermatology"),
              ),
            ],

            onChanged: (v) {
              setState(() {
                category = v!;
              });
            },
          ),

          const SizedBox(height: 20),

          AdminDropdownField<String>(
            label: "Status",
            value: status,
            items: const [
              DropdownMenuItem(value: "Draft", child: Text("Draft")),

              DropdownMenuItem(value: "Published", child: Text("Published")),

              DropdownMenuItem(value: "Review", child: Text("Review")),
            ],

            onChanged: (v) {
              setState(() {
                status = v!;
              });
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: const Size(double.infinity, 45),
            ),

            onPressed: () {},

            child: const Text(
              "Publish Article",
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),

            onPressed: () {},

            child: const Text("Save as Draft"),
          ),
        ],
      ),
    );
  }

  /// FEATURED IMAGE
  Widget featuredImage() {
    return AdminCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Featured Image",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Container(
            height: 140,

            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 30),

                  SizedBox(height: 8),

                  Text("Upload image"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
