import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool confirmed = appointment.status == "Confirmed";
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
              child: Text(
                appointment.initials,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    appointment.reason,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        appointment.type == "Video"
                            ? Icons.videocam
                            : Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${appointment.type} • ${appointment.time}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: confirmed
                    ? const Color(0xFFE8F7EE)
                    : const Color(0xFFFFF4E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                appointment.status,
                style: TextStyle(
                  color: confirmed ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
