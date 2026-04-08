import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class TextSection extends StatelessWidget {
  const TextSection({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = Responsive.horizontalPadding(context);
    return Padding(
      padding: EdgeInsets.only(right: hPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
