import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Red info banner shown when an appointment has been cancelled.
class CancelledBanner extends StatelessWidget {
  const CancelledBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.dangerRed,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This appointment has been cancelled. You can create a new appointment from the Appointments page.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.dangerDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
