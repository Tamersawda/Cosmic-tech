import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/admin/admin_layout.dart';
import 'package:frontend/modules/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/modules/auth/presentation/screens/forgot_password_page.dart';
import 'package:frontend/modules/auth/presentation/screens/landing_page.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_header.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_link_text.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_page_card.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_primary_button.dart';
import 'package:frontend/modules/auth/presentation/widgets/auth_text_field.dart';
import 'package:frontend/modules/doctor/presentation/router/main_doctor_layout.dart';
import 'package:frontend/modules/doctor/presentation/screens/registration/basic_information.dart';
import 'package:frontend/modules/user/presentation/router/main_user_layout.dart';
import 'package:frontend/modules/user/presentation/screens/registration/user_registration_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Handle state changes → navigate ───────────────────────────────────────
  void _handleAuthState(AuthState? previous, AuthState next) {
    if (!mounted) return;

    // Login success → go to home based on role
    if (next is AuthAuthenticated) {
      _routeToHome(next.user.role);
    }

    // Login success but profile not done → resume profile
    // (happens when user registered but never finished profile,
    //  then closes app and logs in again)
    if (next is AuthRegistered) {
      _routeToCompleteProfile(
        next.user.role,
        next.user.name, // ← fullName not name
        next.user.email,
      );
    }
  }

  void _routeToHome(String role) {
    final destination = switch (role) {
      'admin' => const AdminLayout(),
      'doctor' => const MainDoctorLayout(),
      _ => const MainUserLayout(),
    };
    _pushAndRemove(destination);
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
    _pushAndRemove(destination);
  }

  void _pushAndRemove(Widget page) {
    Navigator.pushAndRemoveUntil(context, _fadeRoute(page), (route) => false);
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _login() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Clear any previous error before new attempt
    ref.read(authProvider.notifier).clearError();
    ref
        .read(authProvider.notifier)
        .login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
  }

  void _goToForgotPassword() =>
      Navigator.push(context, _fadeRoute(const ForgotPasswordPage()));

  void _goToRegister() =>
      Navigator.pushReplacement(context, _fadeRoute(const LandingPage()));

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );

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
            const AuthPageHeader(
              icon: Icons.lock_open_rounded,
              title: 'Welcome Back',
              subtitle: 'Sign in to your account',
            ),

            SizedBox(height: spacing),

            // ── Email ─────────────────────────────────────
            AuthTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
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
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              showToggle: true,
              validator: (v) => v!.isEmpty ? 'Password is required' : null,
            ),

            const SizedBox(height: 10),

            // ── Forgot password ───────────────────────────
            AuthStandaloneLink(
              label: 'Forgot Password?',
              onTap: _goToForgotPassword,
              alignment: Alignment.centerRight,
            ),

            // ── Error banner ──────────────────────────────
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              _ErrorBanner(message: errorMessage),
            ],

            SizedBox(height: spacing * 0.6),

            // ── Sign in button ────────────────────────────
            AuthPrimaryButton(
              label: 'Sign In',
              onTap: isLoading ? null : _login,
              isLoading: isLoading,
            ),

            const SizedBox(height: 20),

            // ── Register link ─────────────────────────────
            AuthLinkText(
              prefix: "Don't have an account? ",
              linkText: 'Create one',
              onTap: _goToRegister,
            ),

            const SizedBox(height: 16),

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
  const _ErrorBanner({required this.message});

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
