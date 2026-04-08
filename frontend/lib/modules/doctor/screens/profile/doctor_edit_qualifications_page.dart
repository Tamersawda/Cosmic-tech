import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/doctor/screens/doctor_profile_page.dart';

// ── Qualification entry model ─────────────────────────────────────────────────

class QualEntry {
  final String type; // 'UG' | 'PG' | 'Additional'
  final TextEditingController degree;
  final TextEditingController institution;
  final TextEditingController year;
  String? certificate;

  QualEntry({required this.type, String deg = '', String inst = '', String yr = ''})
      : degree      = TextEditingController(text: deg),
        institution = TextEditingController(text: inst),
        year        = TextEditingController(text: yr);

  void dispose() {
    degree.dispose();
    institution.dispose();
    year.dispose();
  }
}


class DoctorEditQualificationsPage extends StatefulWidget {
  final DoctorProfileData data;

  const DoctorEditQualificationsPage({super.key, required this.data});

  @override
  State<DoctorEditQualificationsPage> createState() =>
      _DoctorEditQualificationsPageState();
}

class _DoctorEditQualificationsPageState
    extends State<DoctorEditQualificationsPage> {
  late final QualEntry _ug;
  late final List<QualEntry> _pg;
  late final List<QualEntry> _additional;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ug = QualEntry(type: 'UG', deg: 'MBBS',
        inst: 'Bangalore Medical College', yr: '2008');
    _pg = [
      QualEntry(type: 'PG', deg: 'MD – Internal Medicine',
          inst: 'AIIMS New Delhi', yr: '2014'),
    ];
    _additional = [];
  }

  @override
  void dispose() {
    _ug.dispose();
    for (final e in [..._pg, ..._additional]) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Qualifications updated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const _BackButton(),
        title: const Text('Qualifications',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── UG ─────────────────────────────────
            _QualSectionLabel(
              badge: 'UG',
              color: const Color(0xFF0891B2),
              subtitle: 'Undergraduate  •  MBBS, BDS, BHMS',
            ),
            _QualCard(entry: _ug, accentColor: const Color(0xFF0891B2)),

            const SizedBox(height: 16),

            // ── PG ─────────────────────────────────
            _QualSectionLabel(
              badge: 'PG',
              color: AppColors.primaryColor,
              subtitle: 'Postgraduate  •  MD, MS, DNB, MCh',
            ),
            ..._pg.asMap().entries.map((e) => _QualCard(
                  entry: e.value,
                  accentColor: AppColors.primaryColor,
                  onRemove: _pg.length > 1
                      ? () => setState(() {
                            _pg[e.key].dispose();
                            _pg.removeAt(e.key);
                          })
                      : null,
                )),
            _AddButton(
              label: 'Add PG Qualification',
              onTap: () =>
                  setState(() => _pg.add(QualEntry(type: 'PG'))),
            ),

            const SizedBox(height: 16),

            // ── Additional ─────────────────────────
            _QualSectionLabel(
              badge: 'Additional',
              color: const Color(0xFF16A34A),
              subtitle: 'Fellowship, Diploma, Certification  (optional)',
            ),
            if (_additional.isEmpty)
              _EmptyQualState(
                onTap: () => setState(
                    () => _additional.add(QualEntry(type: 'Additional'))),
              )
            else
              ..._additional.asMap().entries.map((e) => _QualCard(
                    entry: e.value,
                    accentColor: const Color(0xFF16A34A),
                    onRemove: () => setState(() {
                      _additional[e.key].dispose();
                      _additional.removeAt(e.key);
                    }),
                  )),

            if (_additional.isNotEmpty)
              _AddButton(
                label: 'Add Another',
                onTap: () => setState(
                    () => _additional.add(QualEntry(type: 'Additional'))),
              ),

            const SizedBox(height: 28),
            _SaveButton(saving: _saving, onTap: _save),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _QualSectionLabel extends StatelessWidget {
  final String badge;
  final Color color;
  final String subtitle;

  const _QualSectionLabel({
    required this.badge,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badge,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}

class _QualCard extends StatelessWidget {
  final QualEntry entry;
  final Color accentColor;
  final VoidCallback? onRemove;

  const _QualCard({
    required this.entry,
    required this.accentColor,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
          top: BorderSide(color: AppColors.borderColor),
          right: BorderSide(color: AppColors.borderColor),
          bottom: BorderSide(color: AppColors.borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onRemove != null)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline,
                          size: 13, color: Color(0xFFDC2626)),
                      SizedBox(width: 4),
                      Text('Remove',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626))),
                    ],
                  ),
                ),
              ),
            ),
          if (onRemove != null) const SizedBox(height: 8),
          _QualField(label: 'Degree Name', controller: entry.degree,
              hint: 'e.g. MBBS'),
          const SizedBox(height: 10),
          _QualField(label: 'Institution', controller: entry.institution,
              hint: 'e.g. AIIMS New Delhi'),
          const SizedBox(height: 10),
          _QualField(label: 'Completion Year', controller: entry.year,
              hint: 'YYYY',
              keyboardType: TextInputType.number),
        ],
      ),
    );
  }
}

class _QualField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _QualField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.labelColor,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 13, color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.bgColor,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: AppColors.primaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _EmptyQualState extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyQualState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline,
                size: 26, color: Color(0xFF16A34A)),
            SizedBox(height: 6),
            Text('Tap to add a certification',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF16A34A))),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                  color: AppColors.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.add, size: 13, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// doctor_edit_consultation_page.dart
// ═══════════════════════════════════════════════════════════════════════════

class DoctorEditConsultationPage extends StatefulWidget {
  final DoctorProfileData data;

  const DoctorEditConsultationPage({super.key, required this.data});

  @override
  State<DoctorEditConsultationPage> createState() =>
      _DoctorEditConsultationPageState();
}

class _DoctorEditConsultationPageState
    extends State<DoctorEditConsultationPage> {
  late final TextEditingController _onlineCtrl;
  late final TextEditingController _offlineCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _onlineCtrl  = TextEditingController(text: widget.data.onlineFee);
    _offlineCtrl = TextEditingController(text: widget.data.offlineFee);
  }

  @override
  void dispose() {
    _onlineCtrl.dispose();
    _offlineCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    widget.data.onlineFee  = _onlineCtrl.text.trim();
    widget.data.offlineFee = _offlineCtrl.text.trim();
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation fees updated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const _BackButton(),
        title: const Text('Consultation Fees',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _FeeCard(
              icon: Icons.videocam_outlined,
              title: 'Online Consultation',
              subtitle: 'Video / audio session fee',
              controller: _onlineCtrl,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 14),
            _FeeCard(
              icon: Icons.local_hospital_outlined,
              title: 'In-Clinic Visit',
              subtitle: 'In-person appointment fee',
              controller: _offlineCtrl,
              color: const Color(0xFF16A34A),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Color(0xFFD97706)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fees are shown to patients on your public profile. '
                      'Changes take effect immediately after saving.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _SaveButton(saving: _saving, onTap: _save),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final Color color;

  const _FeeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.mutedText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color),
              hintText: '0',
              hintStyle: const TextStyle(
                  fontSize: 20, color: AppColors.mutedText),
              filled: true,
              fillColor: AppColors.bgColor,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.borderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.borderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: color, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// doctor_notifications_page.dart
// ═══════════════════════════════════════════════════════════════════════════

class DoctorNotificationsPage extends StatefulWidget {
  final DoctorProfileData data;

  const DoctorNotificationsPage({super.key, required this.data});

  @override
  State<DoctorNotificationsPage> createState() =>
      _DoctorNotificationsPageState();
}

class _DoctorNotificationsPageState extends State<DoctorNotificationsPage> {
  late bool _allNotif;
  late bool _appointmentReminders;
  late bool _newPatientAlerts;
  bool _rescheduleAlerts = true;
  bool _paymentAlerts = true;
  bool _reviewAlerts = false;
  bool _systemUpdates = true;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _allNotif             = d.notificationsEnabled;
    _appointmentReminders = d.appointmentReminders;
    _newPatientAlerts     = d.newPatientAlerts;
  }

  void _save() {
    widget.data.notificationsEnabled = _allNotif;
    widget.data.appointmentReminders = _appointmentReminders;
    widget.data.newPatientAlerts     = _newPatientAlerts;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const _BackButton(),
        title: const Text('Notifications',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Master toggle
            _NotifCard(
              icon: Icons.notifications_active_outlined,
              color: AppColors.primaryColor,
              title: 'All Notifications',
              subtitle: 'Enable or disable all notifications',
              value: _allNotif,
              onChanged: (v) => setState(() => _allNotif = v),
              isMaster: true,
            ),

            const SizedBox(height: 20),

            if (_allNotif) ...[
              _NotifGroupLabel('APPOINTMENTS'),
              _NotifGroup(items: [
                _NotifItem(
                  icon: Icons.alarm_outlined,
                  color: const Color(0xFF16A34A),
                  title: 'Appointment Reminders',
                  subtitle: 'Before scheduled appointments',
                  value: _appointmentReminders,
                  onChanged: (v) => setState(() => _appointmentReminders = v),
                ),
                _NotifItem(
                  icon: Icons.event_available_outlined,
                  color: AppColors.accentTeal,
                  title: 'Rescheduling Alerts',
                  subtitle: 'When patients reschedule',
                  value: _rescheduleAlerts,
                  onChanged: (v) => setState(() => _rescheduleAlerts = v),
                ),
              ]),

              const SizedBox(height: 16),

              _NotifGroupLabel('PATIENTS'),
              _NotifGroup(items: [
                _NotifItem(
                  icon: Icons.person_add_outlined,
                  color: const Color(0xFF7C3AED),
                  title: 'New Patient Alerts',
                  subtitle: 'New patient bookings',
                  value: _newPatientAlerts,
                  onChanged: (v) => setState(() => _newPatientAlerts = v),
                ),
                _NotifItem(
                  icon: Icons.star_border_rounded,
                  color: const Color(0xFFF59E0B),
                  title: 'Review Notifications',
                  subtitle: 'When a patient leaves a review',
                  value: _reviewAlerts,
                  onChanged: (v) => setState(() => _reviewAlerts = v),
                ),
              ]),

              const SizedBox(height: 16),

              _NotifGroupLabel('FINANCIAL'),
              _NotifGroup(items: [
                _NotifItem(
                  icon: Icons.payments_outlined,
                  color: const Color(0xFF16A34A),
                  title: 'Payment Alerts',
                  subtitle: 'Consultation fee received',
                  value: _paymentAlerts,
                  onChanged: (v) => setState(() => _paymentAlerts = v),
                ),
              ]),

              const SizedBox(height: 16),

              _NotifGroupLabel('SYSTEM'),
              _NotifGroup(items: [
                _NotifItem(
                  icon: Icons.system_update_outlined,
                  color: AppColors.labelColor,
                  title: 'System Updates',
                  subtitle: 'App updates and announcements',
                  value: _systemUpdates,
                  onChanged: (v) => setState(() => _systemUpdates = v),
                ),
              ]),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isMaster;

  const _NotifCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isMaster = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMaster
            ? (value
                ? AppColors.primarySurface
                : AppColors.white)
            : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isMaster && value
                ? AppColors.primaryColor.withValues(alpha: 0.3)
                : AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
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
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

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
            offset: const Offset(0, 2),
          ),
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
                    height: 1, indent: 68, color: AppColors.borderColor),
            ],
          );
        }).toList(),
      ),
    );
  }
}

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

class _NotifGroupLabel extends StatelessWidget {
  final String text;

  const _NotifGroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onTap;

  const _SaveButton({required this.saving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Text('Save Changes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}


class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 16, color: AppColors.darkText),
      ),
    );
  }
}