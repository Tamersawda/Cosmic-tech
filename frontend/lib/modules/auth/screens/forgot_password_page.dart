import 'package:frontend/modules/auth/screens/login_page.dart';
import 'package:frontend/modules/auth/widgets/auth_header.dart';
import 'package:frontend/modules/auth/widgets/auth_link_text.dart';
import 'package:frontend/modules/auth/widgets/auth_page_card.dart';
import 'package:frontend/modules/auth/widgets/auth_primary_button.dart';
import 'package:frontend/modules/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageCard(
      useGradient: true,
      child: _ForgotPasswordForm(emailCtrl: _emailCtrl),
    );
  }
}

// ── Form body extracted as a private widget ─────────────────────────────────

class _ForgotPasswordForm extends StatelessWidget {
  final TextEditingController emailCtrl;

  const _ForgotPasswordForm({required this.emailCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const AuthPageHeader(
            icon: Icons.lock_reset,
            title: 'Forgot Password',
            subtitle: 'Enter your email to reset password',
            useGradient: false,
          ),

          const SizedBox(height: 24),

          AuthTextField(
            controller: emailCtrl,
            hint: 'Enter your email',
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

          const SizedBox(height: 20),

          AuthPrimaryButton(
            label: 'Send Reset Link',
            onTap: () {
              // TODO: wire up reset logic
            },
          ),

          const SizedBox(height: 16),

          AuthStandaloneLink(
            label: 'Back to Login',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
    );
  }
}
