import 'package:frontend/modules/doctor/presentation/widgets/appointments/atoms/avatar_bubble.dart';
import 'package:frontend/modules/doctor/presentation/widgets/appointments/atoms/status_badge.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/modules/doctor/presentation/models/appointment_model.dart';
import 'package:flutter/material.dart';

/// Hero card at the top of the Appointment Detail page.
/// Shows the patient avatar, name, gender/age, and a live status badge.
class PatientCard extends StatelessWidget {
  final Appointment appointment;
  final Color avatarColor;
  final String currentStatus;
  final bool isMobile;

  const PatientCard({
    super.key,
    required this.appointment,
    required this.avatarColor,
    required this.currentStatus,
    this.isMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = isMobile ? 58.0 : 68.0;
    final avatarFontSize = isMobile ? 20.0 : 24.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarBubble(
            initials: appointment.initials,
            color: avatarColor,
            size: avatarSize,
            fontSize: avatarFontSize,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.name,
                  style: TextStyle(
                    fontSize: isMobile ? 17 : 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.gender} • ${appointment.age} years old',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                StatusBadge(status: currentStatus, showDot: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
