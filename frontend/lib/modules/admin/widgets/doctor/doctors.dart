import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class Doctors extends StatelessWidget {
  const Doctors({
    super.key,
    required this.initials,
    required this.name,
    required this.id,
    required this.specialization,
    required this.experience,
    required this.fee,
    required this.role,
    required this.status,
  });

  final String initials;
  final String name;
  final String id;
  final String specialization;
  final String experience;
  final String fee;
  final String role;
  final String status;

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
              /// DOCTOR INFO
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
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
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

                        const SizedBox(height: 3),

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

              /// SPECIALIZATION
              Expanded(
                flex: 2,
                child: Text(
                  specialization,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              /// EXPERIENCE
              Expanded(
                flex: 2,
                child: Text(
                  experience,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              /// CONSULT FEE
              Expanded(
                flex: 2,
                child: Text(
                  fee,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              /// ROLE (NEW COLUMN)
              Expanded(
                flex: 2,
                child: Text(role, style: const TextStyle(color: Colors.grey)),
              ),

              /// STATUS
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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

              /// ACTIONS
              Expanded(
                flex: 2,
                child: Wrap(
                  spacing: 10,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      color: Colors.teal,
                      size: 20,
                    ),

                    if (status == "Pending")
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 20,
                      ),

                    const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 20,
                    ),
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
