import 'package:frontend/modules/doctor/presentation/screens/registration/profile_completed_page.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_onboarding_progress.dart';
import 'package:frontend/modules/doctor/presentation/widgets/registration/doctor_section_card.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/router/onboarding_page_route.dart';

// ── Pricing tier model ────────────────────────────────────────────────────────

class _PricingTier {
  final String name;
  final int price;
  final Color accentColor;
  final IconData icon;
  final List<String> traits;

  const _PricingTier({
    required this.name,
    required this.price,
    required this.accentColor,
    required this.icon,
    required this.traits,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────

class SessionFeePage extends StatefulWidget {
  const SessionFeePage({super.key});

  @override
  State<SessionFeePage> createState() => _SessionFeePageState();
}

class _SessionFeePageState extends State<SessionFeePage> {
  int? _selectedIndex;
  final _justificationCtrl = TextEditingController();
  bool _submitAttempted = false;

  static const List<_PricingTier> _tiers = [
    _PricingTier(
      name: 'Starter',
      price: 799,
      accentColor: Color(0xFF10B981),
      icon: Icons.eco_outlined,
      traits: ['Fresh graduates', 'Limited experience', 'Building client base'],
    ),
    _PricingTier(
      name: 'Standard',
      price: 999,
      accentColor: Color(0xFF0EA5E9),
      icon: Icons.trending_up_outlined,
      traits: ['1–3 years experience', 'Solid foundation', 'Growing practice'],
    ),
    _PricingTier(
      name: 'Professional',
      price: 1499,
      accentColor: Color(0xFF7C3AED),
      icon: Icons.workspace_premium_outlined,
      traits: ['3–5 years experience', 'Specialised support', 'Proven outcomes'],
    ),
    _PricingTier(
      name: 'Senior',
      price: 1999,
      accentColor: Color(0xFFF59E0B),
      icon: Icons.star_outline,
      traits: ['5–10 years experience', 'Niche expertise', 'Advanced skills'],
    ),
    _PricingTier(
      name: 'Expert',
      price: 2499,
      accentColor: Color(0xFFEF4444),
      icon: Icons.diamond_outlined,
      traits: ['10+ years experience', 'High credibility', 'Industry leader'],
    ),
  ];

  // ── Earnings calculations ─────────────────────────────────────────────────

  double get _sessionFee => _selectedIndex != null
      ? _tiers[_selectedIndex!].price.toDouble()
      : 0;

  double get _platformFee => _sessionFee * 0.2879;
  double get _tds => _sessionFee * 0.10;
  double get _youReceive => _sessionFee - _platformFee - _tds;

  @override
  void dispose() {
    _justificationCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    setState(() => _submitAttempted = true);
    if (_selectedIndex == null) return;

    Navigator.push(
      context,
      smoothOnboardingRoute(const ProfileCompletedPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 650;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopBar(),

            const DoctorOnboardingProgress(
              currentStep: 6,
              stepTitle: 'Step 6: Session Fee',
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header text ──────────────────────────────────────
                    const Text(
                      'Set Your Session Fee',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose a pricing tier that reflects your experience and expertise.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.labelColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Info banner ──────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your pricing will be reviewed before going live',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'This ensures fair and consistent pricing across the platform.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.labelColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Tier selection ───────────────────────────────────
                    ...List.generate(_tiers.length, (i) {
                      final tier = _tiers[i];
                      final isSelected = _selectedIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PricingCard(
                          tier: tier,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedIndex = i),
                        ),
                      );
                    }),

                    // ── Validation error ─────────────────────────────────
                    if (_submitAttempted && _selectedIndex == null) ...[
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.error_outline,
                              size: 14, color: Color(0xFFDC2626)),
                          SizedBox(width: 6),
                          Text(
                            'Please select a pricing tier to continue',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Earnings preview (appears after selection) ───────
                    if (_selectedIndex != null) ...[
                      const SizedBox(height: 8),
                      _EarningsPreviewCard(
                        sessionFee: _sessionFee,
                        platformFee: _platformFee,
                        tds: _tds,
                        youReceive: _youReceive,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Justification field ──────────────────────────────
                    DoctorSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit_note_outlined,
                                  size: 16, color: AppColors.primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'PRICING JUSTIFICATION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.mutedText
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Optional',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Why did you choose this pricing?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _justificationCtrl,
                            maxLength: 200,
                            maxLines: 3,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkText,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'e.g. 3 years experience in anxiety & relationship counselling',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: AppColors.hintColor,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBgLight,
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Platform rule note ────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 16, color: Color(0xFFD97706)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Final pricing is subject to admin approval. You may be contacted if adjustments are required.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            DoctorBottomBar(
              showBack: true,
              showSaveDraft: true,
              nextLabel: 'Continue',
              onNext: _onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pricing card ──────────────────────────────────────────────────────────────

class _PricingCard extends StatelessWidget {
  final _PricingTier tier;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingCard({
    required this.tier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? tier.accentColor.withValues(alpha: 0.06)
              : AppColors.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? tier.accentColor
                : AppColors.borderColor,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tier.accentColor.withValues(alpha: 0.10),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // ── Icon ───────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? tier.accentColor.withValues(alpha: 0.12)
                    : AppColors.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                tier.icon,
                size: 22,
                color: isSelected
                    ? tier.accentColor
                    : AppColors.mutedText,
              ),
            ),
            const SizedBox(width: 14),

            // ── Name + traits ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tier.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? tier.accentColor
                              : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tier.accentColor
                              .withValues(alpha: isSelected ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '₹${tier.price}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: tier.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tier.traits.join(' · '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.labelColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── Radio indicator ────────────────────────────────────
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? tier.accentColor
                  : AppColors.mutedText,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Earnings preview card ─────────────────────────────────────────────────────

class _EarningsPreviewCard extends StatelessWidget {
  final double sessionFee;
  final double platformFee;
  final double tds;
  final double youReceive;

  const _EarningsPreviewCard({
    required this.sessionFee,
    required this.platformFee,
    required this.tds,
    required this.youReceive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                'YOUR EARNINGS PER SESSION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rows
          _EarningsRow(
            label: 'Session Fee',
            value: '₹${sessionFee.toStringAsFixed(0)}',
            color: Colors.white,
            isBold: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: Color(0xFF2D2D44),
            ),
          ),
          _EarningsRow(
            label: 'Platform Fee (~28.79%)',
            value: '− ₹${platformFee.toStringAsFixed(0)}',
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 8),
          _EarningsRow(
            label: 'TDS (~10%)',
            value: '− ₹${tds.toStringAsFixed(0)}',
            color: const Color(0xFFEF4444),
          ),

          const SizedBox(height: 14),

          // You receive
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.successGreen.withValues(alpha: 0.15),
                  AppColors.successGreen.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.successGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 18, color: AppColors.successGreen),
                const SizedBox(width: 10),
                const Text(
                  'You Receive',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${youReceive.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            'Final payout may vary based on tax applicability.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _EarningsRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? Colors.white : const Color(0xFF94A3B8),
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
