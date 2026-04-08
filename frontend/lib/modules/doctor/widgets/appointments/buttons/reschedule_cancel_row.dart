import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Side-by-side Reschedule (amber) and Cancel (red) action row.
class RescheduleCancelRow extends StatelessWidget {
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const RescheduleCancelRow({
    super.key,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onReschedule,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accentAmber.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_calendar_rounded,
                    size: 16,
                    color: AppColors.accentAmber,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Reschedule',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentAmber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.dangerRed.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: AppColors.dangerRed,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dangerRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
