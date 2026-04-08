import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class ServiceSelectionStep extends StatelessWidget {
  final String? selectedService;
  final ValueChanged<String> onServiceChanged;

  // Default therapy types — can be overridden for different doctor categories
  static const List<String> defaultServices = [
    'Individual Therapy',
    'Couple Therapy',
    'Teen Therapy',
  ];

  const ServiceSelectionStep({
    super.key,
    required this.selectedService,
    required this.onServiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '* Service:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: defaultServices.map((service) {
              final isSelected = selectedService == service;
              return InkWell(
                onTap: () => onServiceChanged(service),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySurface
                        : Colors.transparent,
                    border: const Border(
                      bottom: BorderSide(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.mutedText,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        service,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
