import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/enums.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/admin/admin_layout.dart';
import 'package:frontend/modules/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/modules/auth/presentation/screens/login_page.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_header.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_link_text.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_page_card.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_primary_button.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_text_field.dart';
import 'package:frontend/modules/doctor/presentation/screens/registration/basic_information.dart';
import 'package:frontend/modules/user/presentation/screens/registration/user_registration_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final UserRole role;
  const RegisterPage({super.key, this.role = UserRole.user});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Handle state changes → navigate ───────────────────────────────────────
  void _handleAuthState(AuthState? previous, AuthState next) {
    if (!mounted) return;

    // Register success → go to complete profile
    if (next is AuthRegistered) {
      // ← AuthRegistered not AuthNeedsProfile
      _routeToCompleteProfile(
        next.user.role, // ← userType not role
        next.user.name, // ← fullName not name
        next.user.email,
      );
    }
  }

  void _routeToCompleteProfile(String role, String fullName, String email) {
    final destination = switch (role) {
      'doctor' => const BasicInformation(),
      'admin' => const AdminLayout(),
      _ => UserRegistrationPage(
        name: fullName, // ← pass fullName
        email: email,
      ),
    };
    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute(destination),
      (route) => false,
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _register() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Clear any previous error before new attempt
    ref.read(authProvider.notifier).clearError();
    ref
        .read(authProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(), // ← fullName
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: widget.role.apiValue, // maps UserRole.user → 'patient'
        );
  }

  void _goToLogin() =>
      Navigator.pushReplacement(context, _fadeRoute(const LoginPage()));

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );

  // ── Role-specific values ──────────────────────────────────────────────────
  String get _roleLabel => switch (widget.role) {
    UserRole.doctor => 'Practitioner',
    UserRole.admin => 'Administrator',
    UserRole.user => 'Patient',
  };

  Color get _roleColor => switch (widget.role) {
    UserRole.doctor => AppColors.accentTeal,
    UserRole.admin => AppColors.accentAmber,
    UserRole.user => AppColors.primaryColor,
  };

  IconData get _roleIcon => switch (widget.role) {
    UserRole.doctor => Icons.spa_rounded,
    UserRole.admin => Icons.admin_panel_settings_rounded,
    UserRole.user => Icons.favorite_rounded,
  };

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, _handleAuthState);

    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final errorMessage = authState is AuthError ? authState.message : null;
    final spacing = Responsive.sectionSpacing(context);

    return AuthPageCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────
            AuthPageHeader(
              icon: _roleIcon,
              title: 'Create Account',
              subtitle: 'Registering as $_roleLabel',
              iconColor: _roleColor,
              useGradient: false,
            ),

            SizedBox(height: spacing),

            // ── Full name ─────────────────────────────────
            AuthTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Enter your complete name',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              accentColor: _roleColor,
              validator: (v) {
                if (v!.trim().isEmpty) return 'Full name is required';
                if (v.trim().length < 2) return 'Name too short';
                if (!RegExp(r"^[a-zA-Z\s'\-\.]+$").hasMatch(v.trim())) {
                  return 'Name contains invalid characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Email ─────────────────────────────────────
            AuthTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              accentColor: _roleColor,
              validator: (v) {
                if (v!.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Password ──────────────────────────────────
            AuthTextField(
              controller: _passCtrl,
              label: 'Password',
              hint: 'Create a secure password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              showToggle: true,
              accentColor: _roleColor,
              validator: (v) {
                if (v!.isEmpty) return 'Password is required';
                if (v.length < 8) {
                  return 'Minimum 8 characters';
                }
                if (!RegExp(r'[A-Z]').hasMatch(v)) {
                  return 'Must contain at least one uppercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(v)) {
                  return 'Must contain at least one number';
                }
                if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
                  return 'Must contain at least one special character';
                }
                return null;
              },
            ),

            // ── Error banner ──────────────────────────────
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              _ErrorBanner(message: errorMessage, color: _roleColor),
            ],

            SizedBox(height: spacing),

            // ── Register button ───────────────────────────
            AuthPrimaryButton(
              label: 'Register Now',
              onTap: isLoading ? null : _register,
              isLoading: isLoading,
              color: _roleColor,
            ),

            const SizedBox(height: 22),

            // ── Login link ────────────────────────────────
            AuthLinkText(
              prefix: 'Already have an account? ',
              linkText: 'Log In',
              onTap: _goToLogin,
              linkColor: _roleColor,
            ),

            const SizedBox(height: 20),

            const AuthFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final Color color;
  const _ErrorBanner({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dangerRed.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 15,
            color: AppColors.dangerRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.dangerRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
