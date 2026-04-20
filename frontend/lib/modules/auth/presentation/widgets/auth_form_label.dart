import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

/// A small bold label placed above form fields.
///
/// Usage:
/// ```dart
/// AppFormLabel('Email Address')
/// ```
class AuthFormLabel extends StatelessWidget {
  final String text;

  const AuthFormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
    );
  }
}
