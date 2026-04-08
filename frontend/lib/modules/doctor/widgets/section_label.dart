import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.mutedText,
        letterSpacing: 1.2,
      ),
    );
  }
}
