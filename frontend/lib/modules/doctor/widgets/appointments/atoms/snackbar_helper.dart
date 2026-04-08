import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Shows a floating branded snackbar.
/// Call from any StatefulWidget that has access to [BuildContext].
void showAppSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}
