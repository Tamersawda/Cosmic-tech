import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

/// Green success banner shown when an appointment has been completed.
class CompletedBanner extends StatelessWidget {
  const CompletedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.accentGreen,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This appointment has been completed successfully.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.accentGreen,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
