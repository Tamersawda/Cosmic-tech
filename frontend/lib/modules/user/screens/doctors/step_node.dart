import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class StepNode extends StatelessWidget {
  final int index;
  final String label;
  final bool active;
  final bool past;

  const StepNode({
    super.key,
    required this.index,
    required this.label,
    required this.active,
    required this.past,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circle
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppColors.primaryColor
                : past
                ? AppColors.primarySurface
                : AppColors.bgColor,
            border: Border.all(
              color: active
                  ? AppColors.primaryColor
                  : past
                  ? AppColors.primaryColor.withOpacity(0.3)
                  : AppColors.borderColor,
              width: active ? 2 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: past
                ? Icon(
                    Icons.check_rounded,
                    color: AppColors.primaryColor,
                    size: 17,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active ? AppColors.white : AppColors.mutedText,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        // Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 11,
            fontWeight: active || past ? FontWeight.w700 : FontWeight.w500,
            color: active
                ? AppColors.primaryColor
                : past
                ? AppColors.primaryColor.withOpacity(0.7)
                : AppColors.mutedText,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
