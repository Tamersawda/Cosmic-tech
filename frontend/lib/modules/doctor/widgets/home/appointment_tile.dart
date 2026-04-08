import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

enum AppointmentStatus { upcoming, inProgress, cancelled }

class AppointmentData {
  final String time;
  final String name;
  final String type;
  final AppointmentStatus status;
  final String initials;
  final Color color;
  final Color avatarBg;

  const AppointmentData({
    required this.time,
    required this.name,
    required this.type,
    required this.status,
    required this.initials,
    required this.color,
    required this.avatarBg,
  });
}

class StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  final Color color;

  const StatusBadge({super.key, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AppointmentStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.accentGreen,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'In Progress',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        );
      case AppointmentStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEEEE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Cancelled',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.dangerRed,
            ),
          ),
        );
      case AppointmentStatus.upcoming:
        return GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(
              'View',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        );
    }
  }
}

class AppointmentTile extends StatelessWidget {
  final AppointmentData data;
  final bool isMobile;

  const AppointmentTile({
    super.key,
    required this.data,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = data.status == AppointmentStatus.cancelled;
    final isInProgress = data.status == AppointmentStatus.inProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInProgress
              ? AppColors.accentGreen.withValues(alpha: 0.4)
              : AppColors.borderColor,
          width: isInProgress ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isInProgress
                ? AppColors.accentGreen.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Colored left accent bar
          Container(
            width: 4,
            height: 46,
            decoration: BoxDecoration(
              color: isCancelled ? AppColors.borderColor : data.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCancelled ? AppColors.bgColor : data.avatarBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.initials,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isCancelled ? AppColors.softMuted : data.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.time,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCancelled ? AppColors.softMuted : data.color,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.name,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w800,
                    color: isCancelled
                        ? AppColors.mutedText
                        : AppColors.darkText,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.type,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Status badge / action
          StatusBadge(status: data.status, color: data.color),
        ],
      ),
    );
  }
}
