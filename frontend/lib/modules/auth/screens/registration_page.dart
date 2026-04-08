import 'package:frontend/modules/admin/admin_layout.dart';
import 'package:frontend/modules/auth/screens/login_page.dart';
import 'package:frontend/modules/user/screens/registration/user_registration_page.dart';
import 'package:frontend/modules/auth/widgets/auth_header.dart';
import 'package:frontend/modules/auth/widgets/auth_link_text.dart';
import 'package:frontend/modules/auth/widgets/auth_page_card.dart';
import 'package:frontend/modules/auth/widgets/auth_primary_button.dart';
import 'package:frontend/modules/auth/widgets/auth_text_field.dart';
import 'package:frontend/modules/doctor/screens/patients/patients_profile_page.dart';
import 'package:frontend/modules/doctor/screens/registration/basic_information.dart';
import 'package:frontend/core/constants/enums.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final UserRole role;

  const RegisterPage({super.key, this.role = UserRole.user});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Widget destination;
    switch (widget.role) {
      case UserRole.doctor:
        destination = const BasicInformation();
        break;
      case UserRole.admin:
        destination = const AdminLayout();
        break;
      case UserRole.user:
        destination = UserRegistrationPage(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        );
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute(destination),
      (route) => false,
    );
  }

  void _goToLogin() =>
      Navigator.pushReplacement(context, _fadeRoute(const LoginPage()));

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );

  // ── Role-specific values ───────────────────────────────────────────────────

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

            const SizedBox(height: 30),

            // ── Full Name ──────────────────────────────────
            AuthTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Enter your complete name',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              accentColor: _roleColor,
              validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
            ),

            const SizedBox(height: 16),

            // ── Email ──────────────────────────────────────
            AuthTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              accentColor: _roleColor,
              validator: (v) {
                if (v!.isEmpty) return 'Email is required';
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Password ───────────────────────────────────
            AuthTextField(
              controller: _passwordCtrl,
              label: 'Password',
              hint: 'Create a secure password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              showToggle: true,
              accentColor: _roleColor,
              validator: (v) {
                if (v!.isEmpty) return 'Password is required';
                if (v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            // ── Register Button ───────────────────────────
            AuthPrimaryButton(
              label: 'Register Now',
              onTap: _register,
              isLoading: _isLoading,
              color: _roleColor,
            ),

            const SizedBox(height: 22),

            // ── Login Link ────────────────────────────────
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
