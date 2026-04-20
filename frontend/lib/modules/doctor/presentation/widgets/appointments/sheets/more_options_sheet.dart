import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

/// Individual tappable row inside a bottom sheet options list.
class OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with Mark as Completed, Share, and Close options.
class MoreOptionsSheet extends StatelessWidget {
  final VoidCallback? onMarkCompleted;
  final VoidCallback onShare;

  const MoreOptionsSheet({
    super.key,
    required this.onMarkCompleted,
    required this.onShare,
  });

  /// Convenience method to show this sheet.
  static void show(
    BuildContext context, {
    VoidCallback? onMarkCompleted,
    required VoidCallback onShare,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          MoreOptionsSheet(onMarkCompleted: onMarkCompleted, onShare: onShare),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (onMarkCompleted != null) ...[
            OptionTile(
              icon: Icons.check_circle_outline_rounded,
              label: 'Mark as Completed',
              color: AppColors.accentGreen,
              bg: const Color(0xFFDCFCE7),
              onTap: onMarkCompleted!,
            ),
            const SizedBox(height: 10),
          ],
          OptionTile(
            icon: Icons.share_rounded,
            label: 'Share Appointment',
            color: AppColors.primaryColor,
            bg: AppColors.primarySurface,
            onTap: onShare,
          ),
          const SizedBox(height: 10),
          OptionTile(
            icon: Icons.close_rounded,
            label: 'Close',
            color: AppColors.labelColor,
            bg: AppColors.bgColor,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
