import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class DoctorNotificationsPage extends StatefulWidget {
  const DoctorNotificationsPage({super.key});

  @override
  State<DoctorNotificationsPage> createState() =>
      _DoctorNotificationsPageState();
}

class _DoctorNotificationsPageState extends State<DoctorNotificationsPage> {
  // Master
  bool _allNotifications = true;

  // Appointments
  bool _appointmentReminders = true;
  bool _rescheduleAlerts     = true;
  bool _cancellationAlerts   = true;
  bool _noShowAlerts         = false;

  // Patients
  bool _newPatientAlerts  = true;
  bool _patientMessages   = true;
  bool _reviewAlerts      = false;

  // Financial
  bool _paymentReceived   = true;
  bool _earningsReports   = false;
  bool _refundAlerts      = true;

  // Clinical
  bool _labReportAlerts   = true;
  bool _prescriptionAlerts= false;

  // System
  bool _appUpdates        = true;
  bool _securityAlerts    = true;
  bool _platformNews      = false;

  // Delivery channels
  bool _pushEnabled  = true;
  bool _emailEnabled = true;
  bool _smsEnabled   = false;

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Notification preferences saved'),
      backgroundColor: AppColors.accentGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText)),
            Text('Manage your alert preferences',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [

          // ── Master toggle ──────────────────────────────────────────────────
          _MasterToggle(
            value: _allNotifications,
            onChanged: (v) => setState(() => _allNotifications = v),
          ),

          if (_allNotifications) ...[
            const SizedBox(height: 20),

            // ── Delivery channels ────────────────────────────────────────────
            _groupLabel('DELIVERY CHANNELS'),
            _ChannelRow(
              pushEnabled:  _pushEnabled,
              emailEnabled: _emailEnabled,
              smsEnabled:   _smsEnabled,
              onPush:  (v) => setState(() => _pushEnabled  = v),
              onEmail: (v) => setState(() => _emailEnabled = v),
              onSms:   (v) => setState(() => _smsEnabled   = v),
            ),

            const SizedBox(height: 20),

            // ── Appointments ─────────────────────────────────────────────────
            _groupLabel('APPOINTMENTS'),
            _NotifGroup(items: [
              _NotifItem(
                icon: Icons.alarm_outlined,
                color: const Color(0xFF16A34A),
                title: 'Appointment Reminders',
                subtitle: 'Before each scheduled session',
                value: _appointmentReminders,
                onChanged: (v) =>
                    setState(() => _appointmentReminders = v),
              ),
              _NotifItem(
                icon: Icons.event_repeat_outlined,
                color: AppColors.accentTeal,
                title: 'Reschedule Alerts',
                subtitle: 'When a patient reschedules',
                value: _rescheduleAlerts,
                onChanged: (v) =>
                    setState(() => _rescheduleAlerts = v),
              ),
              _NotifItem(
                icon: Icons.event_busy_outlined,
                color: const Color(0xFFDC2626),
                title: 'Cancellation Alerts',
                subtitle: 'When a patient cancels',
                value: _cancellationAlerts,
                onChanged: (v) =>
                    setState(() => _cancellationAlerts = v),
              ),
              _NotifItem(
                icon: Icons.person_off_outlined,
                color: const Color(0xFFF59E0B),
                title: 'No-Show Alerts',
                subtitle: 'When a patient misses their slot',
                value: _noShowAlerts,
                onChanged: (v) => setState(() => _noShowAlerts = v),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Patients ─────────────────────────────────────────────────────
            _groupLabel('PATIENTS'),
            _NotifGroup(items: [
              _NotifItem(
                icon: Icons.person_add_outlined,
                color: const Color(0xFF7C3AED),
                title: 'New Patient Bookings',
                subtitle: 'When a new patient books',
                value: _newPatientAlerts,
                onChanged: (v) =>
                    setState(() => _newPatientAlerts = v),
              ),
              _NotifItem(
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryColor,
                title: 'Patient Messages',
                subtitle: 'New messages from patients',
                value: _patientMessages,
                onChanged: (v) =>
                    setState(() => _patientMessages = v),
              ),
              _NotifItem(
                icon: Icons.star_border_rounded,
                color: const Color(0xFFF59E0B),
                title: 'Patient Reviews',
                subtitle: 'When a patient leaves a review',
                value: _reviewAlerts,
                onChanged: (v) => setState(() => _reviewAlerts = v),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Financial ─────────────────────────────────────────────────────
            _groupLabel('FINANCIAL'),
            _NotifGroup(items: [
              _NotifItem(
                icon: Icons.payments_outlined,
                color: const Color(0xFF16A34A),
                title: 'Payment Received',
                subtitle: 'When a consultation fee is paid',
                value: _paymentReceived,
                onChanged: (v) =>
                    setState(() => _paymentReceived = v),
              ),
              _NotifItem(
                icon: Icons.receipt_long_outlined,
                color: AppColors.accentTeal,
                title: 'Earnings Reports',
                subtitle: 'Weekly/monthly summaries',
                value: _earningsReports,
                onChanged: (v) =>
                    setState(() => _earningsReports = v),
              ),
              _NotifItem(
                icon: Icons.money_off_outlined,
                color: const Color(0xFFDC2626),
                title: 'Refund Alerts',
                subtitle: 'When a refund is processed',
                value: _refundAlerts,
                onChanged: (v) => setState(() => _refundAlerts = v),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Clinical ──────────────────────────────────────────────────────
            _groupLabel('CLINICAL'),
            _NotifGroup(items: [
              _NotifItem(
                icon: Icons.science_outlined,
                color: const Color(0xFF0891B2),
                title: 'Lab Report Alerts',
                subtitle: 'When patient lab results arrive',
                value: _labReportAlerts,
                onChanged: (v) =>
                    setState(() => _labReportAlerts = v),
              ),
              _NotifItem(
                icon: Icons.medication_outlined,
                color: const Color(0xFF7C3AED),
                title: 'Prescription Alerts',
                subtitle: 'Prescription renewal reminders',
                value: _prescriptionAlerts,
                onChanged: (v) =>
                    setState(() => _prescriptionAlerts = v),
              ),
            ]),

            const SizedBox(height: 16),

            // ── System ────────────────────────────────────────────────────────
            _groupLabel('SYSTEM'),
            _NotifGroup(items: [
              _NotifItem(
                icon: Icons.system_update_outlined,
                color: AppColors.labelColor,
                title: 'App Updates',
                subtitle: 'New versions and features',
                value: _appUpdates,
                onChanged: (v) => setState(() => _appUpdates = v),
              ),
              _NotifItem(
                icon: Icons.security_outlined,
                color: const Color(0xFFDC2626),
                title: 'Security Alerts',
                subtitle: 'Login attempts & account changes',
                value: _securityAlerts,
                onChanged: (v) =>
                    setState(() => _securityAlerts = v),
              ),
              _NotifItem(
                icon: Icons.campaign_outlined,
                color: AppColors.accentAmber,
                title: 'Platform News',
                subtitle: 'Announcements & updates',
                value: _platformNews,
                onChanged: (v) =>
                    setState(() => _platformNews = v),
              ),
            ]),
          ],

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Save Preferences',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _groupLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.mutedText,
            letterSpacing: 0.8,
          ),
        ),
      );
}

// ── Master toggle ─────────────────────────────────────────────────────────────

class _MasterToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MasterToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? AppColors.primarySurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? AppColors.primaryColor.withValues(alpha: 0.35)
              : AppColors.borderColor,
          width: value ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_active_outlined,
                size: 20, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('All Notifications',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText)),
                Text(
                  value ? 'Notifications are enabled' : 'All notifications are off',
                  style: TextStyle(
                      fontSize: 12,
                      color: value
                          ? AppColors.primaryColor
                          : AppColors.mutedText),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ── Delivery channel row ──────────────────────────────────────────────────────

class _ChannelRow extends StatelessWidget {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final ValueChanged<bool> onPush;
  final ValueChanged<bool> onEmail;
  final ValueChanged<bool> onSms;

  const _ChannelRow({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.onPush,
    required this.onEmail,
    required this.onSms,
  });

  @override
  Widget build(BuildContext context) {
    final channels = [
      {'label': 'Push', 'icon': Icons.phone_android_outlined,
       'value': pushEnabled, 'onChanged': onPush},
      {'label': 'Email', 'icon': Icons.email_outlined,
       'value': emailEnabled, 'onChanged': onEmail},
      {'label': 'SMS', 'icon': Icons.sms_outlined,
       'value': smsEnabled, 'onChanged': onSms},
    ];

    return Row(
      children: channels.asMap().entries.map((e) {
        final i       = e.key;
        final c       = e.value;
        final val     = c['value'] as bool;
        final changed = c['onChanged'] as ValueChanged<bool>;
        final icon    = c['icon'] as IconData;
        final label   = c['label'] as String;

        return Expanded(
          child: GestureDetector(
            onTap: () => changed(!val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: val
                    ? AppColors.primaryColor.withValues(alpha: 0.08)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: val
                      ? AppColors.primaryColor.withValues(alpha: 0.3)
                      : AppColors.borderColor,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      size: 20,
                      color: val
                          ? AppColors.primaryColor
                          : AppColors.mutedText),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: val
                          ? AppColors.primaryColor
                          : AppColors.labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Notification group ────────────────────────────────────────────────────────

class _NotifGroup extends StatelessWidget {
  final List<_NotifItem> items;

  const _NotifGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                const Divider(
                    height: 1,
                    indent: 66,
                    color: AppColors.borderColor),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Notification item ─────────────────────────────────────────────────────────

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.mutedText)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
