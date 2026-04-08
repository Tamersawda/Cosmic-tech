import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Colored pill badge that renders an appointment status label.
/// Supports an optional leading dot (used in the detail page patient card).
class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const StatusBadge({super.key, required this.status, this.showDot = false});

  Color get _color {
    switch (status) {
      case 'Confirmed':
        return AppColors.primaryColor;
      case 'Pending':
        return AppColors.accentAmber;
      case 'Completed':
        return AppColors.accentGreen;
      default:
        return AppColors.dangerRed;
    }
  }

  Color get _bg {
    switch (status) {
      case 'Confirmed':
        return AppColors.primarySurface;
      case 'Pending':
        return const Color(0xFFFFF4E6);
      case 'Completed':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFFFEEEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: showDot ? 11 : 10,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
