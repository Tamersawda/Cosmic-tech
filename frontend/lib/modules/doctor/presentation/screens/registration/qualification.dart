import 'package:frontend/modules/doctor/presentation/screens/registration/identity_verification_page.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_info_banner.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_labeled_text_field.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_onboarding_progress.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_section_card.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_upload_box.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/router/onboarding_page_route.dart';

// ── Local entry model ─────────────────────────────────────────────────────────

class _QualEntry {
  final String type; // 'UG' | 'PG' | 'Additional'
  final TextEditingController degree = TextEditingController();
  final TextEditingController institution = TextEditingController();
  final TextEditingController year = TextEditingController();
  String? fileName;

  _QualEntry({required this.type});

  void dispose() {
    degree.dispose();
    institution.dispose();
    year.dispose();
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class Qualifications extends StatefulWidget {
  const Qualifications({super.key});

  @override
  State<Qualifications> createState() => _QualificationsState();
}

class _QualificationsState extends State<Qualifications> {
  // UG — exactly one, fixed, cannot be removed
  final _ugEntry = _QualEntry(type: 'UG');

  // PG — starts with one, more can be added
  final List<_QualEntry> _pgEntries = [_QualEntry(type: 'PG')];

  // Additional — optional, starts empty
  final List<_QualEntry> _additionalEntries = [];

  @override
  void dispose() {
    _ugEntry.dispose();
    for (final e in [..._pgEntries, ..._additionalEntries]) {
      e.dispose();
    }
    super.dispose();
  }

  void _addPg() => setState(() => _pgEntries.add(_QualEntry(type: 'PG')));

  void _removePg(int i) {
    if (_pgEntries.length <= 1) return; // keep at least one
    _pgEntries[i].dispose();
    setState(() => _pgEntries.removeAt(i));
  }

  void _addAdditional() =>
      setState(() => _additionalEntries.add(_QualEntry(type: 'Additional')));

  void _removeAdditional(int i) {
    _additionalEntries[i].dispose();
    setState(() => _additionalEntries.removeAt(i));
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

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
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required _QualEntry entry,
    required Color accentColor,
    Widget? trailingAction,
    String degreeHint = 'e.g. Doctor of Medicine (MD)',
    String institutionHint = 'e.g. Johns Hopkins University',
  }) {
    return DoctorSectionCard(
      border: Border(left: BorderSide(color: accentColor, width: 3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailingAction != null)
            Align(alignment: Alignment.centerRight, child: trailingAction),

          DoctorLabeledField(
            label: 'Degree Name',
            field: DoctorTextField(controller: entry.degree, hint: degreeHint),
          ),

          DoctorLabeledField(
            label: 'Institution / University',
            field: DoctorTextField(
              controller: entry.institution,
              hint: institutionHint,
            ),
          ),

          DoctorLabeledField(
            label: 'Completion Year',
            field: DoctorTextField(
              controller: entry.year,
              hint: 'YYYY',
              keyboardType: TextInputType.number,
            ),
          ),

          const SizedBox(height: 4),

          // Certificate upload
          const Center(
            child: Text(
              'CERTIFICATE / MARKSHEET',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.labelColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),

          DoctorCertificateUploadBox(
            fileName: entry.fileName,
            onTap: () => setState(() => entry.fileName = 'certificate.pdf'),
          ),
        ],
      ),
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
              currentStep: 3,
              stepTitle: 'Step 3: Qualifications',
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── UG Section ──────────────────────────
                    _buildSectionLabel(
                      'UG',
                      const Color(0xFF0891B2),
                      'Undergraduate Degree  (e.g. MBBS, BDS, BHMS)',
                    ),

                    _buildCard(
                      entry: _ugEntry,
                      accentColor: const Color(0xFF0891B2),
                      degreeHint: 'e.g. MBBS, BDS, BHMS',
                      institutionHint: 'e.g. Bangalore Medical College',
                    ),

                    const SizedBox(height: 8),

                    // ── PG Section ──────────────────────────
                    _buildSectionLabel(
                      'PG',
                      AppColors.primaryColor,
                      'Postgraduate Degree  (e.g. MD, MS, DNB, MCh)',
                    ),

                    ...List.generate(
                      _pgEntries.length,
                      (i) => _buildCard(
                        entry: _pgEntries[i],
                        accentColor: AppColors.primaryColor,
                        degreeHint: 'e.g. MD, MS, DNB, MCh',
                        institutionHint: 'e.g. AIIMS Delhi',
                        trailingAction: _pgEntries.length > 1
                            ? _removeButton(() => _removePg(i))
                            : null,
                      ),
                    ),

                    _addButton('Add Another PG Qualification', _addPg),

                    // ── Additional Section ──────────────────
                    _buildSectionLabel(
                      'Additional',
                      const Color(0xFF16A34A),
                      'Fellowship, Diploma, Certification  (optional)',
                    ),

                    if (_additionalEntries.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 28,
                              color: Color(0xFF16A34A),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'No additional certifications added',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(
                        _additionalEntries.length,
                        (i) => _buildCard(
                          entry: _additionalEntries[i],
                          accentColor: const Color(0xFF16A34A),
                          degreeHint: 'e.g. Fellowship in Cardiology, PGDCC',
                          institutionHint: 'e.g. Apollo Hospital, NHI',
                          trailingAction: _removeButton(
                            () => _removeAdditional(i),
                          ),
                        ),
                      ),

                    _addButton(
                      'Add Fellowship / Certification',
                      _addAdditional,
                    ),

                    // ── Tip banner ──────────────────────────
                    DoctorInfoBanner.teal(
                      title: 'Verification Tip',
                      description:
                          'Uploading clear, high-resolution copies of your certificates speeds up our verification process by up to 48 hours.',
                      icon: Icons.lightbulb_outline,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            DoctorBottomBar(
              showBack: true,
              onNext: () => Navigator.push(
                context,
                smoothOnboardingRoute(const IdentityVerificationPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
