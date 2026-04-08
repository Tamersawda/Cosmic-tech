import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class PaymentSelectionStep extends StatelessWidget {
  final String fee;

  const PaymentSelectionStep({super.key, required this.fee});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount to Pay:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                fee,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Simulate payment gateway opening here...',
          style: TextStyle(
            color: AppColors.mutedText,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
