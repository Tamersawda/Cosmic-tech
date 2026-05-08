import 'package:frontend/modules/doctor/presentation/screens/registration/qualification.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_info_banner.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_labeled_dropdown_button.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_labeled_text_field.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_onboarding_progress.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_section_card.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_upload_box.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/router/onboarding_page_route.dart';

class ProfessionalDetails extends StatefulWidget {
  const ProfessionalDetails({super.key});

  @override
  State<ProfessionalDetails> createState() => _ProfessionalDetailsState();
}

class _ProfessionalDetailsState extends State<ProfessionalDetails> {
  final _formKey = GlobalKey<FormState>();

  // ── Professional Identity ─────────────────────────────────────────────────
  String? _primaryTitle;
  final _secondaryTitlesCtrl = TextEditingController();
  static const List<String> _primaryTitleOptions = [
    'Clinical Psychologist',
    'Consultant Psychologist',
    'Therapist',
  ];

  // ── Specialization (2-layer) ──────────────────────────────────────────────
  final Set<String> _selectedCategories = {};
  final Map<String, Set<String>> _selectedSubSpecs = {};

  static const Map<String, List<String>> _categorySubSpecs = {
    'Anxiety Issues': ['Panic attacks', 'Social anxiety', 'Overthinking', 'Phobias'],
    'Depression & Mood': ['Major depression', 'Bipolar disorder', 'Seasonal depression', 'Persistent sadness'],
    'Stress & Burnout': ['Work stress', 'Academic burnout', 'Caregiver fatigue', 'Chronic stress'],
    'Relationships': ['Couple conflicts', 'Attachment issues', 'Trust issues', 'Communication gaps'],
    'Career & Productivity': ['Career transitions', 'Imposter syndrome', 'Procrastination', 'Work-life balance'],
    'Self-Development': ['Self-esteem', 'Confidence building', 'Motivation', 'Emotional intelligence'],
    'Behavioral Issues': ['Anger management', 'Addiction', 'Compulsive behavior', 'Habit breaking'],
    'Sleep Issues': ['Insomnia', 'Sleep anxiety', 'Irregular patterns', 'Nightmares'],
    'Grief & Loss': ['Bereavement', 'Pet loss', 'Divorce grief', 'Anticipatory grief'],
    'Identity & Personal Growth': ['Gender identity', 'Sexual orientation', 'Cultural identity', 'Life purpose'],
    'Social Issues': ['Loneliness', 'Social withdrawal', 'Peer pressure', 'Bullying'],
    'Thought Patterns': ['Negative thinking', 'Rumination', 'Catastrophizing', 'Perfectionism'],
    'Lifestyle Issues': ['Body image', 'Eating habits', 'Screen addiction', 'Lifestyle changes'],
    'Mild Clinical Conditions': ['OCD tendencies', 'Mild PTSD', 'Adjustment disorder', 'Somatization'],
  };

  // ── Therapy Approach ──────────────────────────────────────────────────────
  final Set<String> _selectedApproaches = {};

  static const Map<String, List<String>> _approachGroups = {
    'Cognitive & Behavioral': ['CBT', 'DBT', 'REBT', 'Behavioral Therapy', 'Exposure Therapy'],
    'Psychodynamic': ['Psychodynamic', 'Psychoanalytic'],
    'Humanistic': ['Person-Centered', 'Gestalt', 'Existential'],
    'Relationship': ['Couples Therapy', 'Marriage Counseling'],
    'Mindfulness': ['ACT', 'MBCT'],
    'Short-term': ['Solution-Focused'],
    'Integrative': ['Integrative Therapy'],
  };

  // ── Government ID ─────────────────────────────────────────────────────────
  String? _idFrontFileName;
  String? _idBackFileName;

  // ── Languages ─────────────────────────────────────────────────────────────
  final List<String> _selectedLanguages = ['English'];
  bool _showAllLanguages = false;

  final List<String> _availableLanguages = [
    'English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Malayalam',
    'Marathi', 'Bengali', 'Gujarati', 'Punjabi', 'Urdu', 'Odia',
    'Assamese', 'Sanskrit', 'French', 'Spanish', 'German', 'Arabic',
    'Mandarin', 'Japanese',
  ];

  // ── About You / Professional Bio ──────────────────────────────────────────
  final _bioCtrl = TextEditingController();

  @override
  void dispose() {
    _secondaryTitlesCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _toggleLanguage(String lang) {
    setState(() {
      if (_selectedLanguages.contains(lang)) {
        _selectedLanguages.remove(lang);
      } else {
        _selectedLanguages.add(lang);
      }
    });
  }

  void _toggleCategory(String cat) {
    setState(() {
      if (_selectedCategories.contains(cat)) {
        _selectedCategories.remove(cat);
        _selectedSubSpecs.remove(cat);
      } else if (_selectedCategories.length < 5) {
        _selectedCategories.add(cat);
        _selectedSubSpecs[cat] = {};
      }
    });
  }

  void _toggleSubSpec(String cat, String sub) {
    setState(() {
      final subs = _selectedSubSpecs.putIfAbsent(cat, () => {});
      if (subs.contains(sub)) {
        subs.remove(sub);
      } else if (subs.length < 5) {
        subs.add(sub);
      }
    });
  }

  void _toggleApproach(String approach) {
    setState(() {
      if (_selectedApproaches.contains(approach)) {
        _selectedApproaches.remove(approach);
      } else {
        _selectedApproaches.add(approach);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopBar(),

            const DoctorOnboardingProgress(
              currentStep: 2,
              stepTitle: 'Step 2: Professional\nBackground',
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tell us about your therapy expertise. This helps us\nverify your credentials and match patients to you.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 1. Professional Identity ─────────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionDividerLabel(
                              label: 'PROFESSIONAL IDENTITY',
                              icon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 14),

                            DoctorLabeledField(
                              label: 'Primary Title *',
                              field: DoctorDropdown(
                                value: _primaryTitle,
                                hint: 'Select your primary title',
                                items: _primaryTitleOptions,
                                onChanged: (v) => setState(() => _primaryTitle = v),
                              ),
                            ),

                            const SizedBox(height: 8),
                            DoctorLabeledField(
                              label: 'Secondary Title (Optional)',
                              field: DoctorUnderlineTextField(
                                controller: _secondaryTitlesCtrl,
                                hint: 'e.g. Counselor, Life Coach',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── 2. Specialization (2-layer) ────────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionDividerLabel(
                              label: 'SPECIALIZATION',
                              icon: Icons.psychology_outlined,
                            ),
                            const SizedBox(height: 14),
                            ..._categorySubSpecs.entries.map((e) {
                              final cat = e.key;
                              final subs = e.value;
                              final isSel = _selectedCategories.contains(cat);
                              return _CategoryCard(
                                category: cat,
                                subSpecs: subs,
                                isSelected: isSel,
                                selectedSubs: _selectedSubSpecs[cat] ?? {},
                                onToggleCategory: () => _toggleCategory(cat),
                                onToggleSub: (sub) => _toggleSubSpec(cat, sub),
                                disabled: !isSel && _selectedCategories.length >= 5,
                              );
                            }),
                          ],
                        ),
                      ),

                      // ── 3. Therapy Approach ────────────────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionDividerLabel(
                              label: 'THERAPY APPROACH',
                              icon: Icons.auto_fix_high_outlined,
                            ),
                            const SizedBox(height: 14),
                            ..._approachGroups.entries.map((group) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.key,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.labelColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: group.value.map((a) {
                                      final sel = _selectedApproaches.contains(a);
                                      return GestureDetector(
                                        onTap: () => _toggleApproach(a),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: sel ? AppColors.accentPurple.withValues(alpha: 0.10) : AppColors.inputBgLight,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: sel ? AppColors.accentPurple : AppColors.borderColor,
                                              width: sel ? 1.5 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (sel) ...[
                                                const Icon(Icons.check_circle, size: 14, color: AppColors.accentPurple),
                                                const SizedBox(width: 6),
                                              ],
                                              Text(
                                                a,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                                  color: sel ? AppColors.accentPurple : AppColors.darkText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      // ── 4. Languages ──────────────────────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionDividerLabel(
                              label: 'LANGUAGES SPOKEN',
                              icon: Icons.translate_outlined,
                            ),
                            const SizedBox(height: 14),

                            DoctorFieldLabel('Select Languages'),
                            const SizedBox(height: 8),
                            _LanguageChipSelector(
                              availableLanguages: _availableLanguages,
                              selectedLanguages: _selectedLanguages,
                              onToggle: _toggleLanguage,
                              expanded: _showAllLanguages,
                              onToggleExpand: () => setState(
                                () => _showAllLanguages = !_showAllLanguages,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── 5. About You / Professional Bio ───────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionDividerLabel(
                              label: 'ABOUT YOU / PROFESSIONAL BIO',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 14),

                            DoctorLabeledField(
                              label: 'Professional Bio (Optional)',
                              field: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.inputBgLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: TextField(
                                  controller: _bioCtrl,
                                  maxLines: 5,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkText,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'e.g. I am a licensed clinical psychologist with 8+ years of experience helping individuals with anxiety, depression, and relationship challenges. My approach is warm, evidence-based, and tailored to each client\'s unique needs...',
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

                            const SizedBox(height: 8),

                            // ── Character count hint ────────────────────────
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _bioCtrl,
                              builder: (_, value, __) {
                                final count = value.text.length;
                                final color = count > 600
                                    ? const Color(0xFFDC2626)
                                    : AppColors.mutedText;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'This will be visible to clients on your profile.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                    Text(
                                      '$count / 600',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // ── Government ID ──────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.badge_outlined, size: 16, color: AppColors.primaryColor),
                                const SizedBox(width: 8),
                                const Text(
                                  'GOVERNMENT-ISSUED ID',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Container(height: 1, color: AppColors.borderColor)),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Required',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Upload a clear photo of your Passport, Aadhar Card, or Driver's License. Ensure all text is legible.",
                              style: TextStyle(fontSize: 13, color: AppColors.labelColor, height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DoctorUploadBox(
                                    label: 'Front Side',
                                    subtitle: 'JPG, PNG or PDF',
                                    fileName: _idFrontFileName,
                                    onTap: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DoctorUploadBox(
                                    label: 'Back Side',
                                    subtitle: 'JPG, PNG or PDF',
                                    fileName: _idBackFileName,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Info banner ───────────────────────────────────────
                      DoctorInfoBanner.blue(
                        title: 'WHY WE NEED THIS?',
                        description:
                            'Regulatory compliance requires us to maintain verified records of all practicing therapists on the Sanctuary platform.',
                        icon: Icons.shield_outlined,
                      ),
                      const SizedBox(height: 16),

                      // ── Verification badge ────────────────────────────────
                      const _VerificationBadgeSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            DoctorBottomBar(
              showBack: true,
              nextLabel: 'Next Step',
              onNext: () => Navigator.push(
                context,
                smoothOnboardingRoute(const Qualifications()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category card (expandable 2-layer) ───────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final String category;
  final List<String> subSpecs;
  final bool isSelected;
  final Set<String> selectedSubs;
  final VoidCallback onToggleCategory;
  final ValueChanged<String> onToggleSub;
  final bool disabled;

  const _CategoryCard({
    required this.category,
    required this.subSpecs,
    required this.isSelected,
    required this.selectedSubs,
    required this.onToggleCategory,
    required this.onToggleSub,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.04)
              : AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: disabled ? null : onToggleCategory,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                      color: isSelected
                          ? AppColors.primaryColor
                          : (disabled ? AppColors.hintColor : AppColors.mutedText),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: disabled
                              ? AppColors.hintColor
                              : (isSelected ? AppColors.primaryColor : AppColors.darkText),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.keyboard_arrow_up, size: 20, color: AppColors.primaryColor)
                    else if (!disabled)
                      const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.mutedText),
                  ],
                ),
              ),
            ),
            if (isSelected) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1, color: AppColors.borderColor),
                    const SizedBox(height: 10),
                    Text(
                      'Select sub-specializations (${selectedSubs.length}/5)',
                      style: const TextStyle(fontSize: 11, color: AppColors.labelColor),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subSpecs.map((sub) {
                        final sel = selectedSubs.contains(sub);
                        return GestureDetector(
                          onTap: () => onToggleSub(sub),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.accentTeal.withValues(alpha: 0.10)
                                  : AppColors.inputBgLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: sel ? AppColors.accentTeal : AppColors.borderColor,
                              ),
                            ),
                            child: Text(
                              sub,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                color: sel ? AppColors.accentTeal : AppColors.darkText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared Private sub-widgets ────────────────────────────────────────────────

class _SectionDividerLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionDividerLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: AppColors.borderColor)),
      ],
    );
  }
}

class _LanguageChipSelector extends StatelessWidget {
  final List<String> availableLanguages;
  final List<String> selectedLanguages;
  final ValueChanged<String> onToggle;
  final bool expanded;
  final VoidCallback onToggleExpand;

  static const int _collapsedCount = 9;

  const _LanguageChipSelector({
    required this.availableLanguages,
    required this.selectedLanguages,
    required this.onToggle,
    required this.expanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final visibleLanguages = expanded
        ? availableLanguages
        : availableLanguages.take(_collapsedCount).toList();
    final hasMore = availableLanguages.length > _collapsedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: visibleLanguages.map((lang) {
            final isSelected = selectedLanguages.contains(lang);
            return GestureDetector(
              onTap: () => onToggle(lang),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withValues(alpha: 0.12)
                      : AppColors.inputBgLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check_circle, size: 14, color: AppColors.primaryColor),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      lang,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.primaryColor : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (hasMore) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onToggleExpand,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  expanded ? 'See Less' : 'See More',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _VerificationBadgeSection extends StatelessWidget {
  const _VerificationBadgeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_outlined, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VERIFICATION BADGE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Clinical Sanctuary Trust Badge',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Complete all steps to earn your verified badge.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}