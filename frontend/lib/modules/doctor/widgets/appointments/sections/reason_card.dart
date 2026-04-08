import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Section card showing the reason for the appointment visit.
class ReasonCard extends StatelessWidget {
  final String reason;

  const ReasonCard({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Reason for Visit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reason,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.labelColor,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
