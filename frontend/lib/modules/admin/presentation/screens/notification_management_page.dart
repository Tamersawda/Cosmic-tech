import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/modules/admin/presentation/widgets/recent_notifications.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_card_container.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_dropdown_field.dart';
import 'package:frontend/modules/admin/presentation/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class NotificationManagementPage extends StatelessWidget {
  const NotificationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Send push notifications, promotions, and reminders",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// RESPONSIVE CARDS
            LayoutBuilder(
              builder: (context, constraints) {
                /// mobile layout
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      _sendNotificationCard(),
                      const SizedBox(height: 20),
                      _recentNotificationsCard(),
                    ],
                  );
                }

                /// desktop layout
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _sendNotificationCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _recentNotificationsCard()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// SEND NOTIFICATION CARD
  Widget _sendNotificationCard() {
    return AdminCardContainer(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.send_outlined, color: AppColors.primaryColor),
              SizedBox(width: 8),
              Text(
                "Send Notification",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 20),

          AdminTextField(topLabel: "Title", hintText: "Notification title..."),

          const SizedBox(height: 16),

          AdminTextField(
            topLabel: "Message",
            hintText: "Write your message...",
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          /// RESPONSIVE DROPDOWNS
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    _typeDropdown(),
                    const SizedBox(height: 12),
                    _recipientDropdown(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _typeDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _recipientDropdown()),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 45,

            child: ElevatedButton.icon(
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text(
                "Send Notification",
                style: TextStyle(color: Colors.white),
              ),

              onPressed: () {},

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// TYPE DROPDOWN
  Widget _typeDropdown() {
    return AdminDropdownField<String>(
      label: "Type",
      value: null,
      items: const [
        DropdownMenuItem(value: "system", child: Text("System")),
        DropdownMenuItem(value: "promo", child: Text("Promotional")),
        DropdownMenuItem(value: "reminder", child: Text("Reminder")),
      ],
      onChanged: (value) {},
    );
  }

  /// RECIPIENT DROPDOWN
  Widget _recipientDropdown() {
    return AdminDropdownField<String>(
      label: "Recipients",
      value: null,
      items: const [
        DropdownMenuItem(value: "all_users", child: Text("All Users")),
        DropdownMenuItem(value: "patients", child: Text("Active Patients")),
        DropdownMenuItem(value: "doctors", child: Text("All Doctors")),
      ],
      onChanged: (value) {},
    );
  }

  /// RECENT NOTIFICATIONS
  Widget _recentNotificationsCard() {
    return AdminCardContainer(
      padding: const EdgeInsets.all(22),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_none, color: AppColors.secondaryColor),
              SizedBox(width: 8),
              Text(
                "Recent Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          SizedBox(height: 20),

          RecentNotifications(
            title: "System Maintenance",
            subtitle: "System • All Users",
            date: "Mar 10, 2026",
          ),

          RecentNotifications(
            title: "New Feature: Video Consultation",
            subtitle: "Promotional • All Doctors",
            date: "Mar 9, 2026",
          ),

          RecentNotifications(
            title: "Appointment Reminder",
            subtitle: "Reminder • Active Patients",
            date: "Mar 8, 2026",
          ),
        ],
      ),
    );
  }
}
