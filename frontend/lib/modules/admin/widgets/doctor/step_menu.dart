import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class StepMenu extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepChanged;

  const StepMenu({
    super.key,
    required this.currentStep,
    required this.onStepChanged,
  });

  final steps = const [
    "Basic Information",
    "Professional Details",
    "Qualifications",
    "Identity Verification",
    "Appointment Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: steps.length,
      itemBuilder: (_, i) {
        bool selected = currentStep == i;

        return GestureDetector(
          onTap: () => onStepChanged(i),

          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

            decoration: BoxDecoration(
              color: selected ? const Color(0xffeef2ff) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),

            child: Text(
              steps[i],
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primaryColor : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
