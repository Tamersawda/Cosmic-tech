import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_text_field.dart';
import 'package:frontend/modules/admin/widgets/outline_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void showUploadDialog(
  BuildContext context,
  Function(String, bool, PlatformFile?) onUpload,
) {
  TextEditingController titleController = TextEditingController();

  bool isVideo = false;
  PlatformFile? selectedFile;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            child: Container(
              width: 520,
              padding: const EdgeInsets.all(28),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Text(
                    "Upload Training Module",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  AdminTextField(
                    topLabel: 'Module title',
                    hintText: 'Add module name',
                    controller: titleController,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlineButton(
                          text: 'PDF Guide',
                          selected: !isVideo,
                          onPressed: () {
                            setState(() {
                              isVideo = false;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: CustomOutlineButton(
                          text: 'Training Video',
                          selected: isVideo,
                          onPressed: () {
                            setState(() {
                              isVideo = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                    
                    },

                    child: Container(
                      height: 120,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade600),
                      ),

                      child: Center(
                        child: const Text("Click to upload file"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),

                          onPressed: () {
                            if (titleController.text.isEmpty) {
                              return;
                            }

                            onUpload(
                              titleController.text,
                              isVideo,
                              selectedFile,
                            );

                            Navigator.pop(context);
                          },

                          child: const Text(
                            "Upload",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
