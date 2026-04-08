import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Shows a confirmation dialog before cancelling an appointment.
/// Calls [onConfirm] if the user confirms, dismisses otherwise.
Future<void> showCancelDialog(
  BuildContext context, {
  required String patientName,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      title: const Text(
        'Cancel Appointment',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
          fontSize: 17,
        ),
      ),
      content: Text(
        'Are you sure you want to cancel the appointment with $patientName? This action cannot be undone.',
        style: const TextStyle(
          color: AppColors.labelColor,
          fontSize: 13,
          height: 1.5,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Text(
              'Keep',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.dangerRed.withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.dangerRed,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
