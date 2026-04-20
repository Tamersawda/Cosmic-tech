import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';

class PatientsProfilePage extends StatelessWidget {
  const PatientsProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final radius = Responsive.cardRadius(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ───
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Patient Profile',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Scrollable Content ───
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // ─── Patient Header Card ───
                    _buildPatientHeaderCard(radius),

                    const SizedBox(height: 14),

                    // ─── Quick Stats ───
                    _buildQuickStats(),

                    const SizedBox(height: 14),

                    // ─── Personal Information ───
                    _buildSectionCard(
                      label: 'PERSONAL INFORMATION',
                      radius: radius,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.cake_outlined,
                            'Date of Birth',
                            'March 14, 1988 (36 yrs)',
                          ),
                          _buildDivider(),
                          _buildInfoRow(Icons.wc_outlined, 'Gender', 'Male'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ─── Medical Conditions ───
                    _buildSectionCard(
                      label: 'MEDICAL CONDITIONS',
                      radius: radius,
                      child: const Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ConditionChip(
                            label: 'Type 2 Diabetes',
                            severity: _Severity.high,
                          ),
                          _ConditionChip(
                            label: 'Hypertension',
                            severity: _Severity.medium,
                          ),
                          _ConditionChip(
                            label: 'Hyperlipidemia',
                            severity: _Severity.medium,
                          ),
                          _ConditionChip(
                            label: 'Seasonal Allergies',
                            severity: _Severity.low,
                          ),
                          _ConditionChip(
                            label: 'Mild Asthma',
                            severity: _Severity.low,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ─── Visit History ───
                    _buildSectionCard(
                      label: 'VISIT HISTORY',
                      radius: radius,
                      child: Column(
                        children: [
                          _buildVisitRow(
                            date: 'Apr 1, 2026',
                            type: 'Follow-up',
                            doctor: 'Dr. Julian Vance',
                            note: 'Blood pressure check, medication review.',
                            isRecent: true,
                          ),
                          _buildDivider(),
                          _buildVisitRow(
                            date: 'Feb 15, 2026',
                            type: 'Routine Check-up',
                            doctor: 'Dr. Julian Vance',
                            note: 'Annual physical. Labs ordered.',
                          ),
                          _buildDivider(),
                          _buildVisitRow(
                            date: 'Nov 3, 2025',
                            type: 'Urgent Visit',
                            doctor: 'Dr. Priya Mehta',
                            note: 'Acute asthma episode, inhaler prescribed.',
                          ),
                          _buildDivider(),
                          _buildVisitRow(
                            date: 'Aug 20, 2025',
                            type: 'Follow-up',
                            doctor: 'Dr. Julian Vance',
                            note: 'Diabetes management, HbA1c 6.8%.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ─── Emergency Contact ───
                    _buildSectionCard(
                      label: 'EMERGENCY CONTACT',
                      radius: radius,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.person_outline_rounded,
                            'Name',
                            'Sarah Mitchell (Spouse)',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.phone_outlined,
                            'Phone',
                            '+1 (415) 555-0187',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.email_outlined,
                            'Email',
                            'sarah.mitchell@email.com',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ─── Insurance ───
                    _buildSectionCard(
                      label: 'INSURANCE',
                      radius: radius,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.shield_outlined,
                            'Provider',
                            'Blue Cross Blue Shield',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.confirmation_number_outlined,
                            'Policy No.',
                            'BCBS-4829103-A',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.people_outline_rounded,
                            'Group No.',
                            'GRP-00847',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.calendar_today_outlined,
                            'Valid Until',
                            'December 31, 2026',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Patient Header Card
  // ═══════════════════════════════════════════════

  Widget _buildPatientHeaderCard(double radius) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentTeal.withValues(alpha: 0.35),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'AM',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentTeal,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Active Patient',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Alex Mitchell',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Patient ID: #PAT-00482',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.labelColor,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactChip(Icons.phone_outlined, '+1 (415) 555-0192'),
              const SizedBox(width: 10),
              _buildContactChip(Icons.email_outlined, 'alex.m@email.com'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Quick Stats
  // ═══════════════════════════════════════════════

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatItem('8', 'Total Visits', Icons.calendar_month_outlined),
        const SizedBox(width: 10),
        _buildStatItem('3', 'Conditions', Icons.monitor_heart_outlined),
        const SizedBox(width: 10),
        _buildStatItem('36', 'Age (yrs)', Icons.person_outline_rounded),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Action Buttons
  // ═══════════════════════════════════════════════

  // ═══════════════════════════════════════════════
  //  Section Card
  // ═══════════════════════════════════════════════

  Widget _buildSectionCard({
    required String label,
    required Widget child,
    required double radius,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Info Row
  // ═══════════════════════════════════════════════

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.labelColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: AppColors.borderColor),
    );
  }

  // ═══════════════════════════════════════════════
  //  Visit Row
  // ═══════════════════════════════════════════════

  Widget _buildVisitRow({
    required String date,
    required String type,
    required String doctor,
    required String note,
    bool isRecent = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isRecent
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : AppColors.inputBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.medical_services_outlined,
            size: 18,
            color: isRecent ? AppColors.primaryColor : AppColors.labelColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (isRecent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$doctor · $date',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.labelColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                note,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.labelColor,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Supporting Types & Widgets
// ═══════════════════════════════════════════════

enum _Severity { high, medium, low }

class _ConditionChip extends StatelessWidget {
  final String label;
  final _Severity severity;

  const _ConditionChip({required this.label, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = severity == _Severity.high
        ? AppColors.dangerRed
        : severity == _Severity.medium
        ? AppColors.accentAmber
        : AppColors.accentTeal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
