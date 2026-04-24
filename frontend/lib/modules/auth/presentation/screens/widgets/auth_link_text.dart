import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

/// A tappable rich-text row for auth navigation links.
/// e.g. "Don't have an account? Create one"
///
/// Usage:
/// ```dart
/// AppLinkText(
///   prefix: "Don't have an account? ",
///   linkText: 'Create one',
///   onTap: _goToRegister,
/// )
/// ```
class AuthLinkText extends StatelessWidget {
  final String prefix;
  final String linkText;
  final VoidCallback onTap;
  final Color? linkColor;

  const AuthLinkText({
    super.key,
    required this.prefix,
    required this.linkText,
    required this.onTap,
    this.linkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            text: prefix,
            style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
            children: [
              TextSpan(
                text: linkText,
                style: TextStyle(
                  color: linkColor ?? AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A standalone tappable text link (e.g. "Back to Login", "Forgot Password?").
///
/// Usage:
/// ```dart
/// AppStandaloneLink(label: 'Forgot Password?', onTap: _goToForgotPassword)
/// AppStandaloneLink(label: 'Back to Login', onTap: () => Navigator.pop(context))
/// ```
class AuthStandaloneLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Alignment alignment;

  const AuthStandaloneLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

/// Standard copyright footer used at the bottom of all auth pages.
class AuthFooter extends StatelessWidget {
  final String text;

  const AuthFooter({super.key, this.text = '© 2026 DemoDoctor Platform'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
      ),
    );
  }
}
