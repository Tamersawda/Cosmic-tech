import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

/// A circular icon badge used at the top of auth page cards.
///
/// Usage:
/// ```dart
/// AppHeaderIcon(icon: Icons.lock_open_rounded)
/// AppHeaderIcon(icon: Icons.spa_rounded, color: AppColors.accentTeal)
/// AppHeaderIcon(icon: Icons.lock_reset, useGradient: false)
/// ```
class AuthHeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final bool useGradient;
  final double size;

  const AuthHeaderIcon({
    super.key,
    required this.icon,
    this.color,
    this.useGradient = true,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: useGradient ? null : effectiveColor,
        gradient: useGradient
            ? const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.white, size: size * 0.44),
    );
  }
}

/// Centered header block: icon + title + optional subtitle.
/// Used at the top of every auth card.
///
/// Usage:
/// ```dart
/// AppPageHeader(
///   icon: Icons.lock_open_rounded,
///   title: 'Welcome Back',
///   subtitle: 'Sign in to your account',
/// )
/// ```
class AuthPageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final bool useGradient;

  const AuthPageHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          AuthHeaderIcon(
            icon: icon,
            color: iconColor,
            useGradient: useGradient,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
          ],
        ],
      ),
    );
  }
}
