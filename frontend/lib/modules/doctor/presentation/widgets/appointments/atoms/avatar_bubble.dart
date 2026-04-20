import 'package:flutter/material.dart';

/// Circular avatar that shows two-letter initials on a soft tinted background.
/// Used in appointment list cards, detail pages, and the full history page.
class AvatarBubble extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  final double fontSize;

  const AvatarBubble({
    super.key,
    required this.initials,
    required this.color,
    this.size = 48,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}
