import 'package:frontend/modules/doctor/presentation/screens/registration/work_experience_page.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_labeled_text_field.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_onboarding_progress.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_section_card.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_upload_box.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/router/onboarding_page_route.dart';

enum _RegOption { rci, none }

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  // ── Professional Registration ─────────────────────────────────────────────
  _RegOption? _selectedReg;

  // RCI fields
  final _rciNumberCtrl = TextEditingController();
  String? _rciCertFileName;


  // Not-registered fields

  bool _selfDeclAgreed = false;

  @override
  void dispose() {
    _rciNumberCtrl.dispose();
    super.dispose();
  }

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TermsModal(),
    );
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
              currentStep: 4,
              stepTitle: 'Step 4: Professional\nRegistration',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // ── Policy card ────────────────────────
                    DoctorSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.policy_outlined, size: 18, color: AppColors.primaryColor),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Verification Policy',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'To maintain the highest clinical standards, we require proof of your active medical practicing license or professional registration.',
                            style: TextStyle(fontSize: 13, color: AppColors.labelColor, height: 1.5),
                          ),
                          const SizedBox(height: 14),
                          const _PendingStatusBadge(),
                        ],
                      ),
                    ),


                    // ── Professional Registration ──────────
                    DoctorSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_outlined, size: 16, color: AppColors.primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'PROFESSIONAL REGISTRATION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Container(height: 1, color: AppColors.borderColor)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Are you registered with a regulatory body?',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText, height: 1.5),
                          ),
                          const SizedBox(height: 12),

                          // ── Radio-style option tiles ──────────────────────
                          _RegOptionTile(
                            icon: Icons.verified,
                            label: 'Yes – RCI Registered',
                            sublabel: 'Rehabilitation Council of India',
                            accentColor: AppColors.primaryColor,
                            selected: _selectedReg == _RegOption.rci,
                            onTap: () => setState(() => _selectedReg = _RegOption.rci),
                          ),
                          const SizedBox(height: 8),
                          _RegOptionTile(
                            icon: Icons.info_outline,
                            label: 'No – Not Registered',
                            sublabel: 'Submit education proof & self-declaration',
                            accentColor: const Color(0xFFD97706),
                            selected: _selectedReg == _RegOption.none,
                            onTap: () => setState(() => _selectedReg = _RegOption.none),
                          ),

                          // ── Dynamic: RCI ───────────────────────────────────
                          if (_selectedReg == _RegOption.rci) ...[
                            const SizedBox(height: 20),
                            _DynamicBlock(
                              icon: Icons.verified,
                              title: 'RCI Registered Therapist',
                              subtitle: 'Higher trust badge · Priority ranking',
                              color: AppColors.primaryColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  const _FieldLabel('RCI Registration Number (CRR No.) *'),
                                  const SizedBox(height: 8),
                                  DoctorUnderlineTextField(
                                    controller: _rciNumberCtrl,
                                    hint: 'e.g. CRR-12345',
                                  ),
                                  const SizedBox(height: 16),
                                  const _FieldLabel('Upload RCI Certificate  (optional)'),
                                  const SizedBox(height: 8),
                                  DoctorUploadBox(
                                    label: 'RCI Certificate',
                                    subtitle: 'JPG, PNG or PDF',
                                    fileName: _rciCertFileName,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ── Dynamic: Not registered ────────────────────────
                          if (_selectedReg == _RegOption.none) ...[
                            const SizedBox(height: 20),

                            // Self-Declaration block
                            _DynamicBlock(
                              icon: Icons.draw_outlined,
                              title: 'Self-Declaration',
                              subtitle: 'Required for non-registered practitioners',
                              color: const Color(0xFFD97706),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 14),
                                  // Declaration preview
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFBEB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFFDE68A)),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Self-Declaration for Non-RCI Psychology Professionals',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E), height: 1.4),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'By proceeding, I confirm that:',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                                        ),
                                        SizedBox(height: 8),
                                        _DeclPoint('I am not registered with the Rehabilitation Council of India (RCI)'),
                                        _DeclPoint('I will not present myself as a "Clinical Psychologist" or any legally restricted title'),
                                        _DeclPoint('I provide only supportive, non-clinical counseling within my competence (e.g., stress, anxiety, relationships, self-development)'),
                                        _DeclPoint('I will not diagnose, treat, or manage severe psychiatric or clinical mental health conditions'),
                                        _DeclPoint('I will refer high-risk or clinical cases to licensed professionals when required'),
                                        _DeclPoint('I will not prescribe medication or provide medical advice'),
                                        _DeclPoint('All information submitted by me is true and verifiable'),
                                        _DeclPoint('I will follow ethical practices, maintain confidentiality, and comply with platform policies'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Agree checkbox
                                  GestureDetector(
                                    onTap: () => setState(() => _selfDeclAgreed = !_selfDeclAgreed),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _selfDeclAgreed
                                            ? AppColors.primaryColor.withValues(alpha: 0.06)
                                            : AppColors.inputBgLight,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _selfDeclAgreed
                                              ? AppColors.primaryColor.withValues(alpha: 0.4)
                                              : AppColors.borderColor,
                                          width: _selfDeclAgreed ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 180),
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: _selfDeclAgreed ? AppColors.primaryColor : Colors.transparent,
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                color: _selfDeclAgreed ? AppColors.primaryColor : AppColors.mutedText,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: _selfDeclAgreed
                                                ? const Icon(Icons.check, size: 13, color: Colors.white)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'I agree to the terms and accept full responsibility for my services',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.darkText, height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // View Full Terms button
                                  GestureDetector(
                                    onTap: _showTermsModal,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.25)),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.open_in_new_rounded, size: 15, color: AppColors.primaryColor),
                                          SizedBox(width: 8),
                                          Text(
                                            'View Full Terms',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Admin status ───────────────────────
                    const _AdminStatusCard(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            DoctorBottomBar(
              showBack: true,
              showSaveDraft: true,
              nextLabel: 'Next Step',
              onNext: () => Navigator.push(
                context,
                smoothOnboardingRoute(const WorkExperiencePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Terms Modal ───────────────────────────────────────────────────────────────

class _TermsModal extends StatelessWidget {
  const _TermsModal();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.gavel_outlined, size: 18, color: AppColors.primaryColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Full Terms & Conditions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Self-Declaration for Non-RCI Psychology Professionals',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkText),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By proceeding, I confirm that:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                  ),
                  SizedBox(height: 10),
                  _DeclPoint('I am not registered with the Rehabilitation Council of India (RCI)'),
                  _DeclPoint('I will not present myself as a "Clinical Psychologist" or any legally restricted title'),
                  _DeclPoint('I provide only supportive, non-clinical counseling within my competence (e.g., stress, anxiety, relationships, self-development)'),
                  _DeclPoint('I will not diagnose, treat, or manage severe psychiatric or clinical mental health conditions'),
                  _DeclPoint('I will refer high-risk or clinical cases to licensed professionals when required'),
                  _DeclPoint('I will not prescribe medication or provide medical advice'),
                  _DeclPoint('All information submitted by me is true and verifiable'),
                  _DeclPoint('I will follow ethical practices, maintain confidentiality, and comply with platform policies'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Close',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _RegOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  const _RegOptionTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accentColor.withValues(alpha: 0.06) : AppColors.inputBgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accentColor.withValues(alpha: 0.5) : AppColors.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? accentColor.withValues(alpha: 0.12) : AppColors.borderColor.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: selected ? accentColor : AppColors.mutedText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? accentColor : AppColors.darkText,
                    ),
                  ),
                  Text(sublabel, style: const TextStyle(fontSize: 11, color: AppColors.mutedText)),
                ],
              ),
            ),
            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accentColor : AppColors.borderColor,
                  width: selected ? 5 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;

  const _DynamicBlock({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.mutedText)),
                  ],
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.labelColor),
    );
  }
}

class _DeclPoint extends StatelessWidget {
  final String text;
  const _DeclPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.45)),
          ),
        ],
      ),
    );
  }
}

class _PendingStatusBadge extends StatelessWidget {
  const _PendingStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_empty, size: 16, color: Color(0xFFD97706)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Documents are reviewed within 24-48 business hours after submission.',
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatusCard extends StatelessWidget {
  const _AdminStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.mutedText.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.admin_panel_settings_outlined, size: 17, color: AppColors.mutedText),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADMIN VERIFICATION STATUS',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 0.7),
                ),
                SizedBox(height: 3),
                Text(
                  'Verification date will appear here after admin approval.',
                  style: TextStyle(fontSize: 12, color: AppColors.softMuted, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}