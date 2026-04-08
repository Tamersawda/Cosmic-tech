import 'package:frontend/modules/admin/admin_layout.dart';
import 'package:frontend/modules/auth/screens/forgot_password_page.dart';
import 'package:frontend/modules/auth/screens/registration_page.dart';
import 'package:frontend/modules/auth/widgets/auth_header.dart';
import 'package:frontend/modules/auth/widgets/auth_link_text.dart';
import 'package:frontend/modules/auth/widgets/auth_page_card.dart';
import 'package:frontend/modules/auth/widgets/auth_primary_button.dart';
import 'package:frontend/modules/auth/widgets/auth_text_field.dart';
import 'package:frontend/modules/doctor/router/main_doctor_layout.dart';
import 'package:frontend/modules/doctor/screens/patients/patients_profile_page.dart';
import 'package:frontend/modules/user/router/main_user_layout.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);

    final email = _emailCtrl.text.trim().toLowerCase();
    Widget destination;
    if (email == 'admin@demo.com') {
      destination = const AdminLayout();
    } else if (email.contains('doctor') || email.contains('doc@')) {
      destination = const MainDoctorLayout();
    } else {
      destination = const MainUserLayout();
    }

    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute(destination),
      (route) => false,
    );
  }

  void _goToForgotPassword() =>
      Navigator.push(context, _fadeRoute(const ForgotPasswordPage()));

  void _goToRegister() =>
      Navigator.pushReplacement(context, _fadeRoute(const RegisterPage()));

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
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

            const SizedBox(height: 36),

            // ── Email ──────────────────────────────────────
            AuthTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
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
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              showToggle: true,
              validator: (v) => v!.isEmpty ? 'Password is required' : null,
            ),

            const SizedBox(height: 10),

            // ── Forgot Password ────────────────────────────
            AuthStandaloneLink(
              label: 'Forgot Password?',
              onTap: _goToForgotPassword,
              alignment: Alignment.centerRight,
            ),

            const SizedBox(height: 22),

            // ── Demo Hint ─────────────────────────────────
            const _DemoHint(),

            const SizedBox(height: 18),

            // ── Login Button ───────────────────────────────
            AuthPrimaryButton(
              label: 'Sign In',
              onTap: _login,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 20),

            // ── Register Link ──────────────────────────────
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

// ── Demo hint banner ─────────────────────────────────────────────────────────

class _DemoHint extends StatelessWidget {
  const _DemoHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo: "admin@demo.com" → Admin  |  "doc@demo.com" → Doctor  |  anything else → Patient',
              style: TextStyle(fontSize: 11, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
