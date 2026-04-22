import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class DoctorRow extends StatelessWidget {
  final String initials;
  final String name;
  final String id;
  final String specialization;
  final String experience;
  final String fee;
  final String status;
  final String role;

  const DoctorRow({
    super.key,
    required this.initials,
    required this.name,
    required this.id,
    required this.specialization,
    required this.experience,
    required this.fee,
    required this.status,
    required this.role,
  });

  Color get statusColor {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xffe3e8f0),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          id,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(flex: 2, child: Text(specialization)),
              Expanded(flex: 2, child: Text(experience)),
              Expanded(flex: 2, child: Text(fee)),

              /// ROLE
              const Expanded(flex: 2, child: Text("Doctor")),

              /// STATUS
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: Wrap(
                  spacing: 10,
                  children: [
                    const Icon(Icons.edit, color: Colors.teal),
                    if (status == "Pending")
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    const Icon(Icons.delete, color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),
      ],
    );
  }
}
