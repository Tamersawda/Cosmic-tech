import 'package:frontend/modules/doctor/widgets/appointments/atoms/avatar_bubble.dart';
import 'package:frontend/modules/doctor/widgets/appointments/atoms/status_badge.dart';
import 'package:frontend/modules/doctor/widgets/appointments/atoms/type_pill.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/doctor/models/appointment_model.dart';
import 'package:flutter/material.dart';

/// Tappable card that shows a patient appointment summary in the list view.
/// Includes avatar, name, gender/age, reason snippet, date/time footer, and fee.
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Color avatarColor;
  final bool isMobile;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.avatarColor,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = appointment.status == 'Confirmed';
    final isCancelled = appointment.status == 'Cancelled';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isConfirmed
                ? AppColors.primaryColor.withValues(alpha: 0.2)
                : AppColors.borderColor,
            width: isConfirmed ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Top row: avatar + info + status badge ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarBubble(
                    initials: appointment.initials,
                    color: avatarColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                appointment.name,
                                style: TextStyle(
                                  fontSize: isMobile ? 15 : 16,
                                  fontWeight: FontWeight.w800,
                                  color: isCancelled
                                      ? AppColors.mutedText
                                      : AppColors.darkText,
                                  decoration: isCancelled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            StatusBadge(status: appointment.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appointment.gender} • ${appointment.age} yrs',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointment.reason,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.labelColor,
                            height: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ── Footer row: date / time / type / fee ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      appointment.date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.borderColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      appointment.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TypePill(type: appointment.type),
                    const SizedBox(width: 8),
                    Text(
                      appointment.fee,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
