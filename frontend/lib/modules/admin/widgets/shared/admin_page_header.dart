import 'package:flutter/material.dart';

class AdminPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: action != null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: const TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}
