import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class DoctorInfoBanner extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color bgColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color textColor;

  const DoctorInfoBanner({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.bgColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.textColor,
  });

  factory DoctorInfoBanner.blue({
    required String title,
    required String description,
    IconData icon = Icons.shield_outlined,
  }) {
    return DoctorInfoBanner(
      title: title,
      description: description,
      icon: icon,
      bgColor: const Color(0xFFEFF6FF),
      iconBgColor: AppColors.primaryColor.withValues(alpha: 0.1),
      iconColor: AppColors.primaryColor,
      textColor: const Color(0xFF475569),
    );
  }

  factory DoctorInfoBanner.amber({
    required String title,
    required String description,
    IconData icon = Icons.trending_up,
  }) {
    return DoctorInfoBanner(
      title: title,
      description: description,
      icon: icon,
      bgColor: const Color(0xFFFEF3C7),
      iconBgColor: AppColors.accentAmber.withValues(alpha: 0.15),
      iconColor: AppColors.accentAmber,
      textColor: const Color(0xFF92400E),
    );
  }

  factory DoctorInfoBanner.teal({
    required String title,
    required String description,
    IconData icon = Icons.lightbulb_outline,
  }) {
    return DoctorInfoBanner(
      title: title,
      description: description,
      icon: icon,
      bgColor: const Color(0xFFE0F2FE),
      iconBgColor: AppColors.accentTeal.withValues(alpha: 0.15),
      iconColor: AppColors.accentTeal,
      textColor: const Color(0xFF0369A1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: textColor, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
