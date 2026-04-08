import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class StatData {
  final IconData icon;
  final String value;
  final String title;
  final Color color;
  final Color bg;
  final String? trend;
  final bool? trendUp;

  const StatData({
    required this.icon,
    required this.value,
    required this.title,
    required this.color,
    required this.bg,
    this.trend,
    this.trendUp,
  });
}

class StatCard extends StatelessWidget {
  final StatData data;
  final bool isMobile;

  const StatCard({super.key, required this.data, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          // Value + title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: TextStyle(
                  fontSize: isMobile ? 22 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
          // Trend badge
          if (data.trend != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: data.trendUp == true
                    ? const Color(0xFFDCFCE7)
                    : data.trendUp == false
                    ? const Color(0xFFFFEEEE)
                    : AppColors.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (data.trendUp != null) ...[
                    Icon(
                      data.trendUp!
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 11,
                      color: data.trendUp!
                          ? AppColors.accentGreen
                          : AppColors.dangerRed,
                    ),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    data.trend!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: data.trendUp == true
                          ? AppColors.accentGreen
                          : data.trendUp == false
                          ? AppColors.dangerRed
                          : AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
