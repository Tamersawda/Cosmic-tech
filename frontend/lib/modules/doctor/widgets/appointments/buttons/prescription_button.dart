import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Full-width outlined button that opens the prescription bottom sheet.
class PrescriptionButton extends StatelessWidget {
  final VoidCallback onTap;

  const PrescriptionButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 18,
              color: AppColors.primaryColor,
            ),
            SizedBox(width: 8),
            Text(
              'Write Prescription',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
