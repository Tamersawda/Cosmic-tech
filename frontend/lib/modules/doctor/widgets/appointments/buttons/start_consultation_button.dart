import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Full-width gradient CTA button for starting a video consultation.
class StartConsultationButton extends StatelessWidget {
  final VoidCallback onTap;

  const StartConsultationButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_rounded, color: AppColors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Start Video Consultation',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
