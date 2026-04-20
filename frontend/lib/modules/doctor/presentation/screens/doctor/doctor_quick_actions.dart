import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/widgets/section_label.dart';
import 'package:frontend/modules/doctor/presentation/widgets/home/action_tile.dart';

class DoctorQuickActions extends StatelessWidget {
  const DoctorQuickActions({super.key});

  static const _actions = [
    ActionData(
      icon: Icons.edit_calendar_rounded,
      title: 'View\nSchedule',
      color: AppColors.primaryColor,
      bg: AppColors.primarySurface,
    ),
    ActionData(
      icon: Icons.people_alt_rounded,
      title: 'Patients\nList',
      color: AppColors.accentGreen,
      bg: Color(0xFFDCFCE7),
    ),
    ActionData(
      icon: Icons.bar_chart_rounded,
      title: 'Earnings\nReport',
      color: AppColors.accentAmber,
      bg: Color(0xFFFFF4E6),
    ),
    ActionData(
      icon: Icons.chat_bubble_rounded,
      title: 'Messages',
      color: AppColors.accentSky,
      bg: Color(0xFFE0F7FA),
    ),
    ActionData(
      icon: Icons.medication_rounded,
      title: 'Prescriptions',
      color: AppColors.accentPurple,
      bg: Color(0xFFEDE9FB),
    ),
    ActionData(
      icon: Icons.insert_chart_outlined_rounded,
      title: 'Analytics',
      color: AppColors.dangerRed,
      bg: Color(0xFFFFEEEE),
    ),
    ActionData(
      icon: Icons.rate_review_rounded,
      title: 'Reviews',
      color: AppColors.accentTeal,
      bg: Color(0xFFE0F7FA),
    ),
    ActionData(
      icon: Icons.settings_rounded,
      title: 'Settings',
      color: AppColors.labelColor,
      bg: AppColors.inputBg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final cols = isMobile ? 4 : (isTablet ? 6 : 8);

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
          const SectionLabel(label: 'Quick Actions'),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8,
            children: _actions.map((a) => ActionTile(data: a)).toList(),
          ),
        ],
      ),
    );
  }
}
