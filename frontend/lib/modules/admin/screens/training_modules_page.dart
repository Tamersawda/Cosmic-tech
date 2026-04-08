import 'package:frontend/modules/admin/widgets/training/module_grid.dart';
import 'package:frontend/modules/admin/widgets/training/stat_card.dart';
import 'package:frontend/modules/admin/widgets/training/training_header.dart';
import 'package:frontend/modules/admin/widgets/training/upload_module_dialog.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TrainingModulesPage extends StatefulWidget {
  const TrainingModulesPage({super.key});

  @override
  State<TrainingModulesPage> createState() => _TrainingModulesPageState();
}

class _TrainingModulesPageState extends State<TrainingModulesPage> {
  List<Map<String, dynamic>> modules = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: ListView(
          children: [
            /// HEADER
            TrainingHeader(
              onUpload: () {
                showUploadDialog(context, (title, isVideo, PlatformFile? file) {
                  setState(() {
                    modules.add({
                      "title": title,
                      "isVideo": isVideo,
                      "file": file,
                      "date": "Today",
                      "views": 0,
                    });
                  });
                });
              },
            ),

            const SizedBox(height: 25),

            /// STATISTICS
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                StatCard(
                  icon: Icons.menu_book,
                  number: modules.length.toString(),
                  label: "Total Modules",
                ),

                StatCard(
                  icon: Icons.picture_as_pdf,
                  number: modules
                      .where((m) => m["isVideo"] == false)
                      .length
                      .toString(),
                  label: "PDFs",
                ),

                StatCard(
                  icon: Icons.videocam,
                  number: modules
                      .where((m) => m["isVideo"] == true)
                      .length
                      .toString(),
                  label: "Videos",
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// GRID
            ModuleGrid(
              modules: modules,

              onRemove: (index) {
                setState(() {
                  modules.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
