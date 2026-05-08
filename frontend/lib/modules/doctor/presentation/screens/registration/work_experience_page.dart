import 'package:frontend/modules/doctor/presentation/screens/registration/session_fee_page.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_labeled_text_field.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_onboarding_progress.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_section_card.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_upload_box.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/router/onboarding_page_route.dart';

// ── Data model ────────────────────────────────────────────────────────────────

enum _WorkType { hospital, privatePractice, ngo, onlinePlatform, other }

class _ExperienceEntry {
  final TextEditingController role = TextEditingController();
  final TextEditingController organization = TextEditingController();
  _WorkType? workType;
  final TextEditingController otherWorkType = TextEditingController();
  final TextEditingController supervisorName = TextEditingController();
  final TextEditingController description = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  bool currentlyWorking = false;
  String? proofFileName;

  _ExperienceEntry();

  Duration get duration {
    if (startDate == null) return Duration.zero;
    final end =
        currentlyWorking ? DateTime.now() : (endDate ?? DateTime.now());
    return end.difference(startDate!);
  }

  void dispose() {
    role.dispose();
    organization.dispose();
    otherWorkType.dispose();
    supervisorName.dispose();
    description.dispose();
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class WorkExperiencePage extends StatefulWidget {
  const WorkExperiencePage({super.key});

  @override
  State<WorkExperiencePage> createState() => _WorkExperiencePageState();
}

class _WorkExperiencePageState extends State<WorkExperiencePage> {
  final List<_ExperienceEntry> _entries = [_ExperienceEntry()];

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  double get _totalYears {
    final totalDays = _entries.fold<int>(
      0,
      (sum, e) => sum + e.duration.inDays,
    );
    return totalDays / 365.0;
  }

  String get _experienceLevel {
    final y = _totalYears;
    if (y < 1) return 'Beginner';
    if (y < 5) return 'Intermediate';
    return 'Experienced';
  }

  Color get _levelColor {
    final y = _totalYears;
    if (y < 1) return const Color(0xFF6B7280);
    if (y < 5) return const Color(0xFF0891B2);
    return AppColors.primaryColor;
  }

  void _addEntry() => setState(() => _entries.add(_ExperienceEntry()));

  void _removeEntry(int i) {
    if (_entries.length <= 1) return;
    _entries[i].dispose();
    setState(() => _entries.removeAt(i));
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  /// Matches _buildSectionLabel from Qualifications page
  Widget _buildSectionLabel(String title, Color color, String subtitle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required int index, required _ExperienceEntry entry}) {
    return _ExperienceCard(
      index: index,
      entry: entry,
      onChanged: () => setState(() {}),
      trailingAction: _entries.length > 1 ? _removeButton(() => _removeEntry(index)) : null,
    );
  }

  Widget _addButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _removeButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 14, color: Color(0xFFDC2626)),
            SizedBox(width: 4),
            Text(
              'Remove',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary card (always visible) ─────────────────────────────────────────

  Widget _buildSummaryCard() {
    final yrsDisplay = _totalYears.toStringAsFixed(1);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXPERIENCE SUMMARY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Experience: $yrsDisplay years',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _levelColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _experienceLevel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _levelColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Main build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopBar(),

            const DoctorOnboardingProgress(
              currentStep: 5,
              stepTitle: 'Step 5: Work Experience',
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section label (mirrors Qualifications style) ─────
                    _buildSectionLabel(
                      'EXP',
                      AppColors.primaryColor,
                      'Professional Experience  (Hospital, Clinic, NGO, etc.)',
                    ),

                    // ── Experience entries ───────────────────────────────
                    ...List.generate(
                      _entries.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCard(index: i, entry: _entries[i]),
                      ),
                    ),

                    _addButton('Add Another Experience', _addEntry),

                    // ── Summary always visible ───────────────────────────
                    _buildSummaryCard(),
                  ],
                ),
              ),
            ),

            DoctorBottomBar(
              showBack: true,
              showSaveDraft: true,
              nextLabel: 'Continue',
              onNext: () => Navigator.push(
                context,
                smoothOnboardingRoute(const SessionFeePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Experience card ───────────────────────────────────────────────────────────

class _ExperienceCard extends StatefulWidget {
  final int index;
  final _ExperienceEntry entry;
  final VoidCallback onChanged;
  final Widget? trailingAction;

  const _ExperienceCard({
    required this.index,
    required this.entry,
    required this.onChanged,
    this.trailingAction,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          widget.entry.startDate = picked;
        } else {
          widget.entry.endDate = picked;
        }
      });
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;

    return DoctorSectionCard(
      border: Border(
        left: BorderSide(color: AppColors.primaryColor, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Remove button (top-right, like Qualifications) ─────────────
          if (widget.trailingAction != null)
            Align(
              alignment: Alignment.centerRight,
              child: widget.trailingAction,
            ),

          // ── Role ────────────────────────────────────────────────────────
          DoctorLabeledField(
            label: 'Role / Position',
            field: DoctorTextField(
              controller: e.role,
              hint: 'e.g. Therapist, Consultant Psychologist, Intern',
              onChanged: (_) => widget.onChanged(),
            ),
          ),

          // ── Organization ────────────────────────────────────────────────
          DoctorLabeledField(
            label: 'Organization / Clinic Name',
            field: DoctorTextField(
              controller: e.organization,
              hint: 'e.g. NIMHANS, Vandrevala Foundation',
              onChanged: (_) => widget.onChanged(),
            ),
          ),

          // ── Work Type ───────────────────────────────────────────────────
          DoctorLabeledField(
            label: 'Work Type',
            field: _WorkTypeSelector(
              selected: e.workType,
              onSelect: (t) {
                setState(() => e.workType = t);
                widget.onChanged();
              },
            ),
          ),

          if (e.workType == _WorkType.other)
            DoctorLabeledField(
              label: 'Specify Work Type',
              field: DoctorTextField(
                controller: e.otherWorkType,
                hint: 'Describe your work type',
                onChanged: (_) => widget.onChanged(),
              ),
            ),

          // ── Duration ────────────────────────────────────────────────────
          DoctorLabeledField(
            label: 'Duration',
            field: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerBox(
                        label: 'Start Date *',
                        date: e.startDate,
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DatePickerBox(
                        label: e.currentlyWorking ? 'Present' : 'End Date *',
                        date: e.currentlyWorking ? null : e.endDate,
                        disabled: e.currentlyWorking,
                        onTap: e.currentlyWorking
                            ? null
                            : () => _pickDate(isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() => e.currentlyWorking = !e.currentlyWorking);
                    widget.onChanged();
                  },
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: e.currentlyWorking
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: e.currentlyWorking
                                ? AppColors.primaryColor
                                : AppColors.mutedText,
                            width: 1.5,
                          ),
                        ),
                        child: e.currentlyWorking
                            ? const Icon(Icons.check,
                                size: 11, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Currently Working Here',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.labelColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Description ─────────────────────────────────────────────────
          DoctorLabeledField(
            label: 'Description  (optional)',
            field: Container(
              decoration: BoxDecoration(
                color: AppColors.inputBgLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: TextField(
                controller: e.description,
                maxLines: 3,
                onChanged: (_) => widget.onChanged(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkText,
                ),
                decoration: const InputDecoration(
                  hintText:
                      'e.g. Worked with anxiety and relationship cases...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: AppColors.hintColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── Proof Upload (mirrors certificate upload from Qualifications)
          const Center(
            child: Text(
              'EXPERIENCE PROOF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.labelColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Experience Letter, Certificate or Offer Letter',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ),
          const SizedBox(height: 10),

          DoctorCertificateUploadBox(
            fileName: e.proofFileName,
            onTap: () => setState(() => e.proofFileName = 'proof.pdf'),
          ),
        ],
      ),
    );
  }
}

// ── Work Type chip selector ────────────────────────────────────────────────────

class _WorkTypeSelector extends StatelessWidget {
  final _WorkType? selected;
  final ValueChanged<_WorkType> onSelect;

  const _WorkTypeSelector({required this.selected, required this.onSelect});

  static const _labels = {
    _WorkType.hospital: 'Hospital',
    _WorkType.privatePractice: 'Private Practice',
    _WorkType.ngo: 'NGO',
    _WorkType.onlinePlatform: 'Online Platform',
    _WorkType.other: 'Other',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _WorkType.values.map((t) {
        final isSelected = selected == t;
        return GestureDetector(
          onTap: () => onSelect(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.1)
                  : AppColors.inputBgLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.5)
                    : AppColors.borderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              _labels[t]!,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.labelColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Date picker box ───────────────────────────────────────────────────────────

class _DatePickerBox extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool disabled;
  final VoidCallback? onTap;

  const _DatePickerBox({
    required this.label,
    required this.date,
    this.disabled = false,
    this.onTap,
  });

  String _fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')} / ${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.inputBgLight.withValues(alpha: 0.5)
              : AppColors.inputBgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: date != null && !disabled
                ? AppColors.primaryColor.withValues(alpha: 0.4)
                : AppColors.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: date != null && !disabled
                  ? AppColors.primaryColor
                  : AppColors.mutedText,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                disabled
                    ? 'Present'
                    : (date != null ? _fmt(date!) : label),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: date != null && !disabled
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: date != null && !disabled
                      ? AppColors.darkText
                      : disabled
                          ? AppColors.primaryColor
                          : AppColors.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}