import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/enums.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/modules/auth/presentation/screens/login_page.dart';
import 'package:frontend/modules/auth/presentation/screens/registration_page.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  void _navigateFade(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for auth state — if somehow already authenticated, skip landing
    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is AuthAuthenticated) {
        _routeToHome(context, next.user.role);
      }
    });

    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? 380 : 420,
              ),
              child: Column(
                children: [
                  // ── Hero card ───────────────────────────
                  _HeroCard(isMobile: isMobile),

                  SizedBox(height: Responsive.sectionSpacing(context)),

                  // ── Doctor button ───────────────────────
                  _LandingButton(
                    label: "Create Doctor's Account",
                    icon: Icons.spa_rounded,
                    backgroundColor: AppColors.accentTeal,
                    foregroundColor: AppColors.white,
                    onTap: () => _navigateFade(
                      context,
                      const RegisterPage(role: UserRole.doctor),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── User button ─────────────────────────
                  _LandingButton(
                    label: 'Create a Patient Account',
                    icon: Icons.favorite_rounded,
                    backgroundColor: AppColors.primarySurface,
                    foregroundColor: AppColors.primaryColor,
                    onTap: () => _navigateFade(
                      context,
                      const RegisterPage(role: UserRole.user),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Already have account ────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateFade(
                          context,
                          const LoginPage(),
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Footer ──────────────────────────────
                  const Text(
                    'Trusted by over 1,200 specialists nationwide',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _routeToHome(BuildContext context, String role) {
    // Import your home layouts at top of file
    // This is called only if user lands here already authenticated
    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin/home');
        break;
      case 'doctor':
        Navigator.pushReplacementNamed(context, '/doctor/home');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/user/home');
    }
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final bool isMobile;
  const _HeroCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 340 : 380,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          Responsive.cardRadius(context),
        ),
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
                size: isMobile ? 200 : 240,
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
              child: const Icon(
                Icons.spa_rounded,
                color: AppColors.white,
                size: 26,
              ),
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
                  'The Clinical\nSanctuary',
                  style: TextStyle(
                    fontSize: isMobile ? 30 : 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'A mindful workspace designed\nfor modern psychiatric practice.',
                  style: TextStyle(
                    fontSize: 15,
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

// ── Landing button ────────────────────────────────────────────────────────────
class _LandingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _LandingButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}