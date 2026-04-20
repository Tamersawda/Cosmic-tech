import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

class ModuleCard extends StatelessWidget {
  final Map module;
  final VoidCallback onRemove;

  const ModuleCard({super.key, required this.module, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,

                decoration: BoxDecoration(
                  color: module["isVideo"]
                      ? Colors.orange.shade50
                      : AppColors.primaryColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(
                  module["isVideo"] ? Icons.videocam : Icons.picture_as_pdf,
                  color: module["isVideo"]
                      ? Colors.orange
                      : AppColors.primaryColor,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  module["title"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const Spacer(),

          Row(
            children: [
              Text(
                module["file"].name,
                style: TextStyle(color: AppColors.primaryColor),
              ),

              const Spacer(),

              GestureDetector(
                onTap: onRemove,
                child: const Text(
                  "Remove",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
