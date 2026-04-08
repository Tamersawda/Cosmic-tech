import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class DoctorBottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSaveDraft;
  final VoidCallback onNext;
  final String nextLabel;
  final IconData nextIcon;
  final bool showBack;
  final bool showSaveDraft;

  const DoctorBottomBar({
    super.key,
    this.onBack,
    this.onSaveDraft,
    required this.onNext,
    this.nextLabel = 'Next Step',
    this.nextIcon = Icons.arrow_forward,
    this.showBack = true,
    this.showSaveDraft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack)
            TextButton.icon(
              onPressed: onBack ?? () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                size: 16,
                color: AppColors.labelColor,
              ),
              label: const Text(
                'Back',
                style: TextStyle(
                  color: AppColors.labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (showSaveDraft)
            TextButton(
              onPressed: onSaveDraft ?? () {},
              child: const Text(
                'Save\nDraft',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.labelColor,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            onPressed: onNext,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nextLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(nextIcon, size: 16, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
