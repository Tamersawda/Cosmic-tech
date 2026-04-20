import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class DoctorEditConsultationPage extends StatefulWidget {
  const DoctorEditConsultationPage({super.key});

  @override
  State<DoctorEditConsultationPage> createState() =>
      _DoctorEditConsultationPageState();
}

class _DoctorEditConsultationPageState
    extends State<DoctorEditConsultationPage> {
  final _onlineFeeCtrl  = TextEditingController(text: '800');
  final _offlineFeeCtrl = TextEditingController(text: '1200');
  final _emergencyCtrl  = TextEditingController(text: '2000');
  bool _isSaving        = false;

  // Session type selection — Individual / Couple / Both
  final Set<String> _sessionTypes = {'Individual'};

  // Slot durations
  String _individualDuration = '50 min';
  String _coupleDuration     = '75 min';

  final List<String> _individualOptions = [
    '30 min', '45 min', '50 min', '60 min', '90 min'
  ];
  final List<String> _coupleOptions = [
    '60 min', '75 min', '90 min', '120 min'
  ];

  @override
  void dispose() {
    _onlineFeeCtrl.dispose();
    _offlineFeeCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Consultation settings updated'),
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
            Text('Consultation Fees',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText)),
            Text('Fees, session types & durations',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [

          // ── Session types ──────────────────────────────────────────────────
          _sectionLabel('SESSION TYPES OFFERED'),
          const SizedBox(height: 10),
          _SessionTypeSelector(
            selected: _sessionTypes,
            onToggle: (type) {
              setState(() {
                if (_sessionTypes.contains(type)) {
                  if (_sessionTypes.length > 1) {
                    _sessionTypes.remove(type);
                  }
                } else {
                  _sessionTypes.add(type);
                }
              });
            },
          ),

          const SizedBox(height: 20),

          // ── Session durations ──────────────────────────────────────────────
          _sectionLabel('SESSION DURATIONS'),
          const SizedBox(height: 10),
          _DurationCard(
            icon: Icons.person_outline_rounded,
            color: AppColors.primaryColor,
            title: 'Individual Session',
            subtitle: '10 min buffer automatically applied',
            selected: _individualDuration,
            options: _individualOptions,
            onChanged: (v) => setState(() => _individualDuration = v!),
            enabled: _sessionTypes.contains('Individual'),
          ),
          const SizedBox(height: 10),
          _DurationCard(
            icon: Icons.people_outline_rounded,
            color: const Color(0xFF0891B2),
            title: 'Couple Session',
            subtitle: '15 min buffer automatically applied',
            selected: _coupleDuration,
            options: _coupleOptions,
            onChanged: (v) => setState(() => _coupleDuration = v!),
            enabled: _sessionTypes.contains('Couple'),
          ),

          const SizedBox(height: 20),

          // ── Consultation fees ──────────────────────────────────────────────
          _sectionLabel('CONSULTATION FEES'),
          const SizedBox(height: 10),
          _FeeCard(
            icon: Icons.videocam_outlined,
            color: AppColors.primaryColor,
            title: 'Online Consultation',
            subtitle: 'Video / audio session',
            controller: _onlineFeeCtrl,
          ),
          const SizedBox(height: 10),
          _FeeCard(
            icon: Icons.local_hospital_outlined,
            color: const Color(0xFF16A34A),
            title: 'In-Clinic Visit',
            subtitle: 'In-person appointment',
            controller: _offlineFeeCtrl,
          ),
          const SizedBox(height: 10),
          _FeeCard(
            icon: Icons.emergency_outlined,
            color: const Color(0xFFDC2626),
            title: 'Emergency / Urgent',
            subtitle: 'Priority same-day slots',
            controller: _emergencyCtrl,
          ),

          const SizedBox(height: 16),

          // ── Info note ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: Color(0xFFD97706)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Buffer time is applied automatically after each session. '
                    'Fees are visible to patients on your public profile and '
                    'take effect immediately after saving.',
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
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.mutedText,
          letterSpacing: 0.8,
        ),
      );

  Widget _buildSaveButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Text('Save Changes',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      );
}

// ── Session Type Selector ─────────────────────────────────────────────────────

class _SessionTypeSelector extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _SessionTypeSelector({
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {'key': 'Individual', 'icon': Icons.person_outline_rounded,
       'color': AppColors.primaryColor, 'desc': '50 min + 10 min buffer'},
      {'key': 'Couple', 'icon': Icons.people_outline_rounded,
       'color': const Color(0xFF0891B2), 'desc': '75 min + 15 min buffer'},
    ];

    return Row(
      children: types.map((t) {
        final key      = t['key'] as String;
        final isOn     = selected.contains(key);
        final color    = t['color'] as Color;
        final icon     = t['icon'] as IconData;
        final desc     = t['desc'] as String;

        return Expanded(
          child: GestureDetector(
            onTap: () => onToggle(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: key == 'Individual' ? 10 : 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isOn
                    ? color.withValues(alpha: 0.08)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isOn
                      ? color.withValues(alpha: 0.4)
                      : AppColors.borderColor,
                  width: isOn ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: isOn ? color : AppColors.mutedText),
                      const Spacer(),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isOn ? color : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isOn ? color : AppColors.borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: isOn
                            ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isOn ? color : AppColors.labelColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.mutedText),
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

// ── Duration Card ─────────────────────────────────────────────────────────────

class _DurationCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String selected;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const _DurationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.options,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selected,
                  isDense: true,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: AppColors.labelColor),
                  items: options
                      .map((o) => DropdownMenuItem(
                          value: o, child: Text(o)))
                      .toList(),
                  onChanged: enabled ? onChanged : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fee Card ──────────────────────────────────────────────────────────────────

class _FeeCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final TextEditingController controller;

  const _FeeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.controller,
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
              offset: const Offset(0, 2)),
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
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color),
              hintText: '0',
              hintStyle: const TextStyle(
                  fontSize: 22, color: AppColors.mutedText),
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
                  borderSide: BorderSide(color: color, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}