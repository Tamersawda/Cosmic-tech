import 'package:frontend/modules/doctor/presentation/router/main_doctor_layout.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

class SubmissionSuccessPage extends StatefulWidget {
  const SubmissionSuccessPage({super.key});

  @override
  State<SubmissionSuccessPage> createState() => _SubmissionSuccessPageState();
}

class _SubmissionSuccessPageState extends State<SubmissionSuccessPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.elasticOut);
    _pulseCtrl.forward();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    // Stagger: fade in content after the icon animates
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 650;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopBar(
              title: 'Cosmic Tech',
              showHelpIcon: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 40,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // ── Animated check icon ──────────────────────────────
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.successGreen,
                              AppColors.accentGreen,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.successGreen
                                  .withValues(alpha: 0.30),
                              blurRadius: 36,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Badge ─────────────────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.successGreen
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          'ALL DETAILS SUBMITTED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.successGreen,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Headline ──────────────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: const Column(
                        children: [
                          Text(
                            'You\'re All Set! 🎉',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Your profile and payout details have been\nsuccessfully submitted for verification.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.labelColor,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── Submitted items checklist ─────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.fact_check_outlined,
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'SUBMISSION SUMMARY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const _CheckItem(
                              label: 'Basic Information',
                              icon: Icons.person_outline,
                            ),
                            const _CheckItem(
                              label: 'Professional Details',
                              icon: Icons.medical_services_outlined,
                            ),
                            const _CheckItem(
                              label: 'Qualifications',
                              icon: Icons.school_outlined,
                            ),
                            const _CheckItem(
                              label: 'Work Experience',
                              icon: Icons.work_outline,
                            ),
                            const _CheckItem(
                              label: 'Identity Verification',
                              icon: Icons.verified_user_outlined,
                            ),
                            const _CheckItem(
                              label: 'Payout Details',
                              icon: Icons.account_balance_outlined,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── What's next card ──────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WHAT HAPPENS NEXT?',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _TimelineStep(
                              step: '1',
                              title: 'Verification',
                              description:
                                  'Our team will review your credentials and documents within 24–48 hours.',
                            ),
                            _TimelineStep(
                              step: '2',
                              title: 'Approval Notification',
                              description:
                                  'You\'ll receive an email and in-app notification once approved.',
                            ),
                            _TimelineStep(
                              step: '3',
                              title: 'Go Live',
                              description:
                                  'Start accepting bookings, conduct sessions, and earn.',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Estimated time info ───────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor
                              .withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryColor
                                .withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.schedule_outlined,
                                size: 18,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Verification Time',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '24 – 48 hours · We\'ll notify you via email',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.labelColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Go Live / Dashboard button ────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainDoctorLayout(),
                          ),
                          (_) => false,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch_outlined,
                                size: 20, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Go to Dashboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Secondary: contact support ────────────────────────
                    TextButton(
                      onPressed: () {
                        // TODO: open support / help
                      },
                      child: const Text(
                        'Need help? Contact Support',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.labelColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Check item row ────────────────────────────────────────────────────────────

class _CheckItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLast;

  const _CheckItem({
    required this.label,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 15,
              color: AppColors.successGreen,
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: AppColors.labelColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          const Text(
            'Submitted',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timeline step ─────────────────────────────────────────────────────────────

class _TimelineStep extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final bool isLast;

  const _TimelineStep({
    required this.step,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 30,
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
