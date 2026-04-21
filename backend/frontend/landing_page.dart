import 'package:frontend/core/utils/enums.dart';
import 'package:frontend/modules/auth/presentation/screens/registration_page.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _navigateFade(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: _LandingCard(
              title: 'The Clinical\nSanctuary',
              subtitle:
                  'A mindful workspace designed\nfor modern psychiatric practice.',
              icon: Icons.spa_rounded,
              primaryBtnText: "Create Doctor's Account",
              secondaryBtnText: 'Create a user Account',
              footerText: 'Trusted by over 1,200 specialists nationwide',
              onPrimaryTap: () => _navigateFade(
                context,
                const RegisterPage(role: UserRole.doctor),
              ),
              onSecondaryTap: () => _navigateFade(
                context,
                const RegisterPage(role: UserRole.user),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Landing card extracted as a private widget ───────────────────────────────

class _LandingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryBtnText;
  final String secondaryBtnText;
  final String footerText;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  const _LandingCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryBtnText,
    required this.secondaryBtnText,
    required this.footerText,
    required this.onPrimaryTap,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          children: [
            // ── Hero gradient card ─────────────────────────
            _HeroCard(title: title, subtitle: subtitle, icon: icon),

            const SizedBox(height: 30),

            // ── Primary button ─────────────────────────────
            _LandingButton(
              label: primaryBtnText,
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              onTap: onPrimaryTap,
            ),

            // ── Secondary button ───────────────────────────
            if (secondaryBtnText.isNotEmpty) ...[
              const SizedBox(height: 16),
              _LandingButton(
                label: secondaryBtnText,
                backgroundColor: AppColors.primarySurface,
                foregroundColor: AppColors.primaryColor,
                onTap: onSecondaryTap,
              ),
            ] else
              const SizedBox(height: 72),

            const SizedBox(height: 36),

            // ── Footer ─────────────────────────────────────
            Text(
              footerText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero gradient card ────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.wellnessBannerGradient,
        ),
      ),
      child: Stack(
        children: [
          // Decorative background icon
          Positioned(
            right: -40,
            bottom: 20,
            child: Transform.rotate(
              angle: -0.1,
              child: Icon(
                Icons.eco_rounded,
                size: 240,
                color: AppColors.white.withOpacity(0.4),
              ),
            ),
          ),

          // Top icon badge
          Positioned(
            left: 24,
            top: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 26),
            ),
          ),

          // Title + subtitle
          Positioned(
            left: 24,
            bottom: 30,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.darkText,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
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

// ── Landing action button ─────────────────────────────────────────────────────

class _LandingButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _LandingButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
