import 'package:frontend/modules/doctor/screens/registration/qualification.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_info_banner.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_labeled_dropdown_button.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_labeled_text_field.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_onboarding_progress.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_section_card.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/router/onboarding_page_route.dart';

class ProfessionalDetails extends StatefulWidget {
  const ProfessionalDetails({super.key});

  @override
  State<ProfessionalDetails> createState() => _ProfessionalDetailsState();
}

class _ProfessionalDetailsState extends State<ProfessionalDetails> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSpecialty;
  String? _selectedCouncil;
  int _yearsOfExperience = 0;

  final List<String> _languages = ['English'];
  final _langCtrl = TextEditingController();
  final _subSpecCtrl = TextEditingController();
  final _regNumberCtrl = TextEditingController();

  final List<String> _specialties = [
    'Cardiology',
    'Dermatology',
    'Emergency Medicine',
    'Family Medicine',
    'Gastroenterology',
    'General Medicine',
    'Neurology',
    'Oncology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Surgery',
    'Urology',
    'Other',
  ];

  final List<String> _councils = [
    'Medical Council of India (MCI)',
    'National Medical Commission (NMC)',
    'American Medical Association (AMA)',
    'General Medical Council (GMC)',
    'Royal College of Physicians',
    'Other',
  ];

  @override
  void dispose() {
    _langCtrl.dispose();
    _subSpecCtrl.dispose();
    _regNumberCtrl.dispose();
    super.dispose();
  }

  void _addLanguage(String lang) {
    final trimmed = lang.trim().toUpperCase();
    if (trimmed.isNotEmpty && !_languages.contains(trimmed)) {
      setState(() {
        _languages.add(trimmed);
        _langCtrl.clear();
      });
    }
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
                        'Establish your clinical authority. This helps us verify\nyour credentials and match relevant patient cases.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Specialization card ───────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionDividerLabel(
                              label: 'SPECIALIZATION',
                              icon: Icons.medical_services_outlined,
                            ),
                            const SizedBox(height: 14),

                            DoctorLabeledField(
                              label: 'Primary Specialization',
                              field: DoctorDropdown(
                                value: _selectedSpecialty,
                                hint: 'Select Specialty',
                                items: _specialties,
                                onChanged: (v) =>
                                    setState(() => _selectedSpecialty = v),
                              ),
                            ),

                            DoctorLabeledField(
                              label: 'Sub-Specialization  (optional)',
                              field: DoctorUnderlineTextField(
                                controller: _subSpecCtrl,
                                hint: 'e.g. Interventional Cardiology',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Licensing card ────────────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionDividerLabel(
                              label: 'MEDICAL LICENSING',
                              icon: Icons.verified_outlined,
                            ),
                            const SizedBox(height: 14),

                            DoctorLabeledField(
                              label: 'Registration Number',
                              field: DoctorUnderlineTextField(
                                controller: _regNumberCtrl,
                                hint: 'e.g. MCI-12345 / KA-MED-2041',
                              ),
                            ),

                            DoctorLabeledField(
                              label: 'Medical Council',
                              field: DoctorDropdown(
                                value: _selectedCouncil,
                                hint: 'Select Council',
                                items: _councils,
                                onChanged: (v) =>
                                    setState(() => _selectedCouncil = v),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Experience + Languages ────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionDividerLabel(
                              label: 'EXPERIENCE & LANGUAGES',
                              icon: Icons.workspace_premium_outlined,
                            ),
                            const SizedBox(height: 14),

                            DoctorFieldLabel('Years of Experience'),
                            const SizedBox(height: 8),
                            _ExperienceStepper(
                              value: _yearsOfExperience,
                              onDecrement: () {
                                if (_yearsOfExperience > 0) {
                                  setState(() => _yearsOfExperience--);
                                }
                              },
                              onIncrement: () =>
                                  setState(() => _yearsOfExperience++),
                            ),
                            const SizedBox(height: 20),

                            DoctorFieldLabel('Languages Spoken'),
                            const SizedBox(height: 8),
                            _LanguagesField(
                              controller: _langCtrl,
                              languages: _languages,
                              onSubmit: _addLanguage,
                              onRemove: (lang) =>
                                  setState(() => _languages.remove(lang)),
                            ),
                          ],
                        ),
                      ),

                      // ── Info banner ───────────────────────
                      DoctorInfoBanner.blue(
                        title: 'WHY WE NEED THIS?',
                        description:
                            'Regulatory compliance requires us to maintain verified records of all practicing clinicians on the Sanctuary platform.',
                        icon: Icons.shield_outlined,
                      ),

                      const SizedBox(height: 16),

                      // ── Verification badge ────────────────
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

// ── Private sub-widgets ───────────────────────────────────────────────────────

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

class _ExperienceStepper extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _ExperienceStepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _StepBtn(icon: Icons.remove, onTap: onDecrement),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                const Text(
                  'years',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryColor),
      ),
    );
  }
}

class _LanguagesField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> languages;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String> onRemove;

  const _LanguagesField({
    required this.controller,
    required this.languages,
    required this.onSubmit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DoctorUnderlineTextField(
                controller: controller,
                hint: 'Type a language and press Add...',
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => onSubmit(controller.text),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (languages.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: languages
                .map(
                  (lang) => _LanguageChip(
                    label: lang,
                    onRemove: () => onRemove(lang),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _LanguageChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 10,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
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
            child: const Icon(
              Icons.verified_outlined,
              size: 30,
              color: Colors.white,
            ),
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Complete all steps to earn your verified badge.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
