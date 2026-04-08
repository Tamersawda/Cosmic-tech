import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class WellnessBanner extends StatelessWidget {
  const WellnessBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        hPad,
        Responsive.sectionSpacing(context),
        hPad,
        0,
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 22 : 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.wellnessBannerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Mental\nWellness Tips',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D1B6E),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simple practices to keep your mind at peace every day.',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: const Color(0xFF4A3A8E),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 24,
                        vertical: isMobile ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: isMobile ? 72 : 90,
                  height: isMobile ? 72 : 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.self_improvement_rounded,
                    size: isMobile ? 36 : 44,
                    color: AppColors.accentPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
