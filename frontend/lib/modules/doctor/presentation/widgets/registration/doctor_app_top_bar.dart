import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class DoctorTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool showHelpIcon;

  const DoctorTopBar({
    super.key,
    this.title = 'Complete Your Profile',
    this.trailing,
    this.showHelpIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leading: icon + title
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_hospital_outlined,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),

              // Trailing: custom widget, help icon, or nothing
              trailing ??
                  (showHelpIcon
                      ? Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            size: 18,
                            color: AppColors.labelColor,
                          ),
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderColor),
      ],
    );
  }
}
