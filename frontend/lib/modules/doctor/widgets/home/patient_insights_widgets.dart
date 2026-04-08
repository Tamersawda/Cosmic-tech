import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const RatingBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '${(value * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class InsightStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const InsightStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
