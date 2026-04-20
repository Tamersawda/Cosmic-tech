import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

class ActionData {
  final IconData icon;
  final String title;
  final Color color;
  final Color bg;

  const ActionData({
    required this.icon,
    required this.title,
    required this.color,
    required this.bg,
  });
}

class ActionTile extends StatelessWidget {
  final ActionData data;
  final VoidCallback? onTap;

  const ActionTile({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: data.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: data.color.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: data.color.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.labelColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
