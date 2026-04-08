import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class TrainingHeader extends StatelessWidget {
  final VoidCallback onUpload;

  const TrainingHeader({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Training Modules",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                "Upload and manage training content",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        ElevatedButton.icon(
          onPressed: onUpload,
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: const Text(
            "Upload Module",
            style: TextStyle(color: Colors.white),
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
      ],
    );
  }
}
