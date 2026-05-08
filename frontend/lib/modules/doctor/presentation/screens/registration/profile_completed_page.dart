import 'package:frontend/modules/doctor/presentation/router/main_doctor_layout.dart';
import 'package:frontend/modules/doctor/presentation/screens/registration/payout_page.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_feature_card.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_section_card.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

// ── Status enums ──────────────────────────────────────────────────────────────

enum DoctorStatus { pendingVerification, approved, rejected }
enum PayoutStatus { notAdded, pending, verified }
enum RegistrationType { rci, other, supervised, none }

class ProfileCompletedPage extends StatefulWidget {
  final DoctorStatus doctorStatus;
  final PayoutStatus payoutStatus;
  final RegistrationType registrationType;

  const ProfileCompletedPage({
    super.key,
    this.doctorStatus = DoctorStatus.approved,
    this.payoutStatus = PayoutStatus.notAdded,
    this.registrationType = RegistrationType.none,
  });

  @override
  State<ProfileCompletedPage> createState() => _ProfileCompletedPageState();
}

class _ProfileCompletedPageState extends State<ProfileCompletedPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Computed properties ───────────────────────────────────────────────────

  bool get _isPending => widget.doctorStatus == DoctorStatus.pendingVerification;
  bool get _isApproved => widget.doctorStatus == DoctorStatus.approved;
  bool get _isLive => _isApproved && widget.payoutStatus == PayoutStatus.verified;
  bool get _isApprovedNoPayout => _isApproved && widget.payoutStatus != PayoutStatus.verified;

  String get _profileTag {
    return switch (widget.registrationType) {
      RegistrationType.rci => 'RCI Licensed',
      RegistrationType.other => 'Verified Therapist',
      RegistrationType.supervised => 'Supervised Practitioner',
      RegistrationType.none => 'Verified Therapist',
    };
  }

  Color get _profileTagColor {
    return switch (widget.registrationType) {
      RegistrationType.rci => AppColors.primaryColor,
      RegistrationType.other => const Color(0xFF0891B2),
      RegistrationType.supervised => const Color(0xFF7C3AED),
      RegistrationType.none => const Color(0xFF0891B2),
    };
  }

  IconData get _profileTagIcon {
    return switch (widget.registrationType) {
      RegistrationType.rci => Icons.verified,
      RegistrationType.other => Icons.workspace_premium_outlined,
      RegistrationType.supervised => Icons.supervised_user_circle_outlined,
      RegistrationType.none => Icons.workspace_premium_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            DoctorTopBar(
              title: 'Clinical Sanctuary',
              showHelpIcon: false,
              trailing: const _TherapistAvatar(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── Access state banner ──────────────────────────────────
                    _AccessStateBanner(
                      isPending: _isPending,
                      isLive: _isLive,
                      isApprovedNoPayout: _isApprovedNoPayout,
                    ),

                    const SizedBox(height: 24),

                    // ── Status icon + badge ──────────────────────────────────
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: _StatusIcon(
                        isPending: _isPending,
                        isLive: _isLive,
                        isApprovedNoPayout: _isApprovedNoPayout,
                      ),
                    ),

                    const SizedBox(height: 16),

                    FadeTransition(
                      opacity: _fadeAnim,
                      child: _StatusBadge(
                        isPending: _isPending,
                        isLive: _isLive,
                        isApprovedNoPayout: _isApprovedNoPayout,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Headline + subtitle ──────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: _StatusHeadline(
                        isPending: _isPending,
                        isLive: _isLive,
                        isApprovedNoPayout: _isApprovedNoPayout,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Profile tag ──────────────────────────────────────────
                    _ProfileTagCard(
                      tag: _profileTag,
                      color: _profileTagColor,
                      icon: _profileTagIcon,
                    ),

                    const SizedBox(height: 16),

                    // ── Pending: restrictions + what's next ──────────────────
                    if (_isPending) ...[
                      const _RestrictionsCard(),
                      const SizedBox(height: 16),
                      const _WhatHappensNextCard(),
                      const SizedBox(height: 16),
                      _EditProfileButton(),
                    ],

                    // ── Approved, no payout: payout CTA ─────────────────────
                    if (_isApprovedNoPayout) ...[
                      const _ApprovedAccessCard(),
                      const SizedBox(height: 16),
                      _PayoutCta(onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PayoutPage()),
                      )),
                    ],

                    // ── Live: full access card + feature cards ───────────────
                    if (_isLive) ...[
                      const _LiveAccessCard(),
                      const SizedBox(height: 16),
                      const DoctorFeatureCard(
                        icon: Icons.workspace_premium_outlined,
                        title: 'Digital Credentials',
                        subtitle: 'Visible to patients. Fully verified.',
                        iconBgColor: AppColors.primaryColor,
                      ),
                      const DoctorFeatureCard(
                        icon: Icons.calendar_month_outlined,
                        title: 'Smart Scheduling',
                        subtitle: 'Booking slots are now active.',
                        iconBgColor: AppColors.primaryColor,
                      ),
                      const DoctorFeatureCard(
                        icon: Icons.payments_outlined,
                        title: 'Earnings Active',
                        subtitle: 'Payouts enabled. Start earning.',
                        iconBgColor: AppColors.primaryColor,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ── Bottom Action Button ─────────────────────────────────
                    if (_isApprovedNoPayout) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PayoutPage()),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Proceed to Payout Setup',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],

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

// ── Access State Banner ───────────────────────────────────────────────────────

class _AccessStateBanner extends StatelessWidget {
  final bool isPending;
  final bool isLive;
  final bool isApprovedNoPayout;

  const _AccessStateBanner({
    required this.isPending,
    required this.isLive,
    required this.isApprovedNoPayout,
  });

  @override
  Widget build(BuildContext context) {
    if (isPending) {
      return _BannerTile(
        icon: Icons.lock_outline,
        label: 'No bookings · Not visible · No calls',
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFECACA),
      );
    }
    if (isApprovedNoPayout) {
      return _BannerTile(
        icon: Icons.visibility_outlined,
        label: 'Visible to patients · Cannot earn yet',
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFDE68A),
      );
    }
    // Live
    return _BannerTile(
      icon: Icons.check_circle_outline,
      label: 'Fully active · Bookings open · Earnings live',
      color: AppColors.successGreen,
      bgColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFBBF7D0),
    );
  }
}

class _BannerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _BannerTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Status icon ───────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final bool isPending;
  final bool isLive;
  final bool isApprovedNoPayout;

  const _StatusIcon({required this.isPending, required this.isLive, required this.isApprovedNoPayout});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = isPending
        ? (const Color(0xFFD97706), Icons.hourglass_top_rounded)
        : isApprovedNoPayout
            ? (const Color(0xFF0891B2), Icons.payments_outlined)
            : (AppColors.successGreen, Icons.rocket_launch_outlined);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(icon, size: 48, color: Colors.white),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isPending;
  final bool isLive;
  final bool isApprovedNoPayout;

  const _StatusBadge({required this.isPending, required this.isLive, required this.isApprovedNoPayout});

  @override
  Widget build(BuildContext context) {
    final (String text, Color bg, Color border, Color textColor) = isPending
        ? ('PENDING REVIEW', const Color(0xFFFEF3C7), const Color(0xFFFDE68A), const Color(0xFF92400E))
        : isApprovedNoPayout
            ? ('PROFILE APPROVED', const Color(0xFFE0F2FE), const Color(0xFFBAE6FD), const Color(0xFF0369A1))
            : ('FULLY LIVE', const Color(0xFFDCFCE7), const Color(0xFFBBF7D0), const Color(0xFF166534));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 1),
      ),
    );
  }
}

// ── Status headline ───────────────────────────────────────────────────────────

class _StatusHeadline extends StatelessWidget {
  final bool isPending;
  final bool isLive;
  final bool isApprovedNoPayout;

  const _StatusHeadline({required this.isPending, required this.isLive, required this.isApprovedNoPayout});

  @override
  Widget build(BuildContext context) {
    final (String title, String subtitle) = isPending
        ? (
            'Submitted for Verification!',
            'Your profile is under review. Our admin team\nwill verify your credentials within 24–48 hours.',
          )
        : isApprovedNoPayout
            ? (
                'Profile Approved 🎉',
                'You\'re verified! Add your payout details\nto start accepting bookings and earning.',
              )
            : (
                'You\'re Live! 🚀',
                'Full access granted. Accept bookings,\ngo live, and start earning today.',
              );

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.darkText),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.labelColor, height: 1.5),
        ),
      ],
    );
  }
}

// ── Profile tag card ──────────────────────────────────────────────────────────

class _ProfileTagCard extends StatelessWidget {
  final String tag;
  final Color color;
  final IconData icon;

  const _ProfileTagCard({required this.tag, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PROFILE TAG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.mutedText, letterSpacing: 0.8)),
              const SizedBox(height: 2),
              Text(tag, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Restrictions card ─────────────────────────────────────────────────────────

class _RestrictionsCard extends StatelessWidget {
  const _RestrictionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.hourglass_empty, size: 16, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'VERIFICATION IN PROGRESS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF92400E), letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Until your profile is approved:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
          const SizedBox(height: 8),
          _RestrictionRow(icon: Icons.calendar_today_outlined, text: 'Cannot accept patient bookings'),
          _RestrictionRow(icon: Icons.visibility_off_outlined, text: 'Not visible to patients'),
          _RestrictionRow(icon: Icons.videocam_off_outlined, text: 'Cannot start audio / video calls'),
        ],
      ),
    );
  }
}

class _RestrictionRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RestrictionRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFFD97706)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF92400E))),
        ],
      ),
    );
  }
}

// ── Approved access card (no payout yet) ─────────────────────────────────────

class _ApprovedAccessCard extends StatelessWidget {
  const _ApprovedAccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF0891B2)),
              SizedBox(width: 8),
              Text('ACCESS STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0369A1), letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 12),
          _AccessRow(icon: Icons.check_circle_outline, text: 'Visible to patients', ok: true),
          _AccessRow(icon: Icons.check_circle_outline, text: 'Profile searchable', ok: true),
          _AccessRow(icon: Icons.cancel_outlined, text: 'Cannot earn yet — add payout details', ok: false),
          _AccessRow(icon: Icons.cancel_outlined, text: 'Booking payments on hold', ok: false),
        ],
      ),
    );
  }
}

class _AccessRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool ok;

  const _AccessRow({required this.icon, required this.text, required this.ok});

  @override
  Widget build(BuildContext context) {
    final color = ok ? const Color(0xFF059669) : const Color(0xFFDC2626);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ── Live access card ──────────────────────────────────────────────────────────

class _LiveAccessCard extends StatelessWidget {
  const _LiveAccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.rocket_launch_outlined, size: 16, color: Color(0xFF059669)),
              SizedBox(width: 8),
              Text('FULL ACCESS ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF166534), letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 12),
          _AccessRow(icon: Icons.check_circle_outline, text: 'Accept patient bookings', ok: true),
          _AccessRow(icon: Icons.check_circle_outline, text: 'Go live with audio / video calls', ok: true),
          _AccessRow(icon: Icons.check_circle_outline, text: 'Earn and receive payouts', ok: true),
        ],
      ),
    );
  }
}

// ── Payout CTA ────────────────────────────────────────────────────────────────

class _PayoutCta extends StatelessWidget {
  final VoidCallback onTap;
  const _PayoutCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_outlined, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ADD PAYOUT DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
                  SizedBox(height: 4),
                  Text('Set up bank & UPI to start earning', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('Takes less than 2 minutes', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── What happens next ─────────────────────────────────────────────────────────

class _WhatHappensNextCard extends StatelessWidget {
  const _WhatHappensNextCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WHAT HAPPENS NEXT?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.8)),
          const SizedBox(height: 14),
          _NextStep(step: '1', title: 'Admin Review', description: 'Our team verifies your ID and credentials.'),
          _NextStep(step: '2', title: 'Approval or Feedback', description: 'You will be notified via email and in-app.'),
          _NextStep(step: '3', title: 'Add Payout Details', description: 'Set up bank account and UPI to earn.'),
          _NextStep(step: '4', title: 'Full Access Granted', description: 'Accept bookings, go live, start sessions.', isLast: true),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final bool isLast;

  const _NextStep({required this.step, required this.title, required this.description, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(step, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 28,
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
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Edit profile button ───────────────────────────────────────────────────────

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, size: 16, color: AppColors.labelColor),
            SizedBox(width: 8),
            Text('Edit Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.labelColor)),
          ],
        ),
      ),
    );
  }
}


// ── Private sub-widgets ───────────────────────────────────────────────────────

class _TherapistAvatar extends StatelessWidget {
  const _TherapistAvatar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
          child: const Center(child: Text('T', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
        ),
        const SizedBox(width: 8),
        const Text('Therapist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
      ],
    );
  }
}
