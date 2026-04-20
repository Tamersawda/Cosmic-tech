import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class StepConnector extends StatelessWidget {
  final bool past;

  const StepConnector({super.key, required this.past});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 36,
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: past
              ? AppColors.primaryColor.withOpacity(0.25)
              : AppColors.borderColor,
        ),
      ),
    );
  }
}
