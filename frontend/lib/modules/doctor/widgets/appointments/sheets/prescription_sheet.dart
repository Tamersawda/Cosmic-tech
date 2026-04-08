import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet for writing and saving a patient prescription.
/// Pass a [controller] for the text field and an [onSubmit] callback.
class PrescriptionSheet extends StatelessWidget {
  final String patientName;
  final TextEditingController controller;
  final void Function(String) onSubmit;

  const PrescriptionSheet({
    super.key,
    required this.patientName,
    required this.controller,
    required this.onSubmit,
  });

  /// Convenience method to show this sheet from any context.
  static void show(
    BuildContext context, {
    required String patientName,
    required void Function(String) onSubmit,
  }) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrescriptionSheet(
        patientName: patientName,
        controller: controller,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Write Prescription',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    'For $patientName',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: TextField(
              controller: controller,
              maxLines: 6,
              style: const TextStyle(fontSize: 13, color: AppColors.darkText),
              decoration: const InputDecoration(
                hintText: 'Enter medicines, dosage, instructions...',
                hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => onSubmit(controller.text),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Save Prescription',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
