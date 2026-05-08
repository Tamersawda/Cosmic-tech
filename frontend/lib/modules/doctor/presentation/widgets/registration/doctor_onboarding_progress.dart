import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class DoctorOnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final String? subtitle;

  const DoctorOnboardingProgress({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    required this.stepTitle,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "ONBOARDING PROGRESS" label
          const Text(
            'ONBOARDING PROGRESS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),

          // Step title + step counter
          Row(
            children: [
              Expanded(
                child: Text(
                  stepTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                    height: 1.25,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currentStep of $totalSteps',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.labelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              totalSteps,
              (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: i < currentStep
                        ? AppColors.primaryColor
                        : AppColors.borderColor,
                    borderRadius: BorderRadius.circular(4),
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
