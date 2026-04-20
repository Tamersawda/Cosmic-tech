import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

/// App bar for the Appointment Detail page.
/// Shows a back button, title + appointment ID, and a more-options button.
class DetailAppBar extends StatelessWidget {
  final bool isMobile;
  final String appointmentId;
  final VoidCallback onMoreTap;

  const DetailAppBar({
    super.key,
    required this.isMobile,
    required this.appointmentId,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        0,
        MediaQuery.of(context).padding.top + 10,
        0,
        14,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointment Details',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                appointmentId,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onMoreTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
