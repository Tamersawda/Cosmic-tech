import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/widgets/home/patient_insights_widgets.dart';

class DoctorPatientInsights extends StatelessWidget {
  const DoctorPatientInsights({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PATIENT INSIGHTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedText,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          // Rating + satisfaction card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Big rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overall Rating',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: isMobile ? 36 : 42,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkText,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '/ 5.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.mutedText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < 4
                                    ? Icons.star_rounded
                                    : Icons.star_half_rounded,
                                color: AppColors.accentAmber,
                                size: 18,
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Based on 320 reviews',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Satisfaction breakdown
                    Expanded(
                      child: Column(
                        children: [
                          RatingBar(
                            label: '5★',
                            value: 0.72,
                            color: AppColors.accentGreen,
                          ),
                          const SizedBox(height: 8),
                          RatingBar(
                            label: '4★',
                            value: 0.18,
                            color: AppColors.accentAmber,
                          ),
                          const SizedBox(height: 8),
                          RatingBar(
                            label: '3★',
                            value: 0.06,
                            color: AppColors.accentSky,
                          ),
                          const SizedBox(height: 8),
                          RatingBar(
                            label: '2★',
                            value: 0.03,
                            color: AppColors.softMuted,
                          ),
                          const SizedBox(height: 8),
                          RatingBar(
                            label: '1★',
                            value: 0.01,
                            color: AppColors.dangerRed,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.borderColor),
                const SizedBox(height: 16),
                // Bottom stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InsightStat(
                      label: 'New Patients',
                      value: '48',
                      icon: Icons.person_add_rounded,
                      color: AppColors.primaryColor,
                      bg: AppColors.primarySurface,
                    ),
                    InsightStat(
                      label: 'Returning',
                      value: '272',
                      icon: Icons.replay_rounded,
                      color: AppColors.accentGreen,
                      bg: const Color(0xFFDCFCE7),
                    ),
                    InsightStat(
                      label: 'Avg Session',
                      value: '42m',
                      icon: Icons.timer_rounded,
                      color: AppColors.accentPurple,
                      bg: const Color(0xFFEDE9FB),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
