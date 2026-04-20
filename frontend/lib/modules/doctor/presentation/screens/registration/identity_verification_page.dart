import 'package:frontend/modules/doctor/presentation/screens/registration/profile_completed_page.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_onboarding_progress.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_section_card.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_upload_box.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/router/onboarding_page_route.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  String? _idFrontFileName;
  String? _idBackFileName;
  String? _licenseFileName;

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
              stepTitle: 'Step 4: Identity &\nLicense Verification',
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
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.policy_outlined,
                                  size: 18,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Verification Policy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'To maintain the highest clinical standards, we require a valid government-issued ID and your active medical practicing license.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.labelColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _PendingStatusBadge(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Required fields indicator ──────────
                    _RequiredFieldsRow(
                      govIdUploaded: _idFrontFileName != null,
                      licenseUploaded: _licenseFileName != null,
                    ),

                    const SizedBox(height: 20),

                    // ── Encryption banner ──────────────────
                    const _EncryptionBanner(),

                    const SizedBox(height: 28),

                    // ── Government ID ──────────────────────
                    _UploadSectionHeader(
                      icon: Icons.badge_outlined,
                      title: 'Government-Issued ID',
                      subtitle: 'Required',
                      description:
                          "Upload a clear photo of your Passport, Aadhar Card, or Driver's License. Ensure all text is legible.",
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: DoctorUploadBox(
                            label: 'Front Side',
                            subtitle: 'JPG, PNG or PDF',
                            fileName: _idFrontFileName,
                            onTap: () {}
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DoctorUploadBox(
                            label: 'Back Side',
                            subtitle: 'JPG, PNG or PDF',
                            fileName: _idBackFileName,
                            onTap: () {}
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Medical License ────────────────────
                    _UploadSectionHeader(
                      icon: Icons.verified_user_outlined,
                      iconColor: AppColors.successGreen,
                      title: 'Medical Practicing License',
                      subtitle: 'Required',
                      description:
                          'Provide a scan of your current active license. The license number and expiry date must be clearly visible.',
                    ),

                    DoctorDropFileBox(
                      fileName: _licenseFileName,
                      onTap: () {}
                    ),

                    const SizedBox(height: 28),

                    // ── Admin status ───────────────────────
                    const _AdminStatusCard(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            DoctorBottomBar(
              showBack: true,
              showSaveDraft: true,
              nextLabel: 'Complete Profile',
              onNext: () {
                Navigator.push(
                  context,
                  smoothOnboardingRoute(const ProfileCompletedPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _RequiredFieldsRow extends StatelessWidget {
  final bool govIdUploaded;
  final bool licenseUploaded;

  const _RequiredFieldsRow({
    required this.govIdUploaded,
    required this.licenseUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RequiredChip(label: 'Government ID', done: false, required: true),
        const SizedBox(width: 10),
        _RequiredChip(label: 'Medical License', done: false , required: false,),
        const SizedBox(width: 10),
        _RequiredChip(label: 'ID Back', done: false, required: false),
      ],
    );
  }
}

class _RequiredChip extends StatelessWidget {
  final String label;
  final bool done;
  final bool required;

  const _RequiredChip({
    required this.label,
    required this.done,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.successGreen
        : required
        ? const Color(0xFFDC2626)
        : AppColors.labelColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (required && !done) ...[
            const SizedBox(width: 3),
            Text(
              '*',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UploadSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final String description;

  const _UploadSectionHeader({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primaryColor;
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: color),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Required',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.labelColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
      ],
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
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EncryptionBanner extends StatelessWidget {
  const _EncryptionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.85),
            AppColors.primaryColor,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank-Grade Encryption',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'All documents are encrypted with AES-256 protocols and stored securely.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
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
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              size: 17,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADMIN VERIFICATION STATUS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Verification date will appear here after admin approval.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.softMuted,
                    fontStyle: FontStyle.italic,
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
