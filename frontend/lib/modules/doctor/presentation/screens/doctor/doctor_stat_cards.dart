import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/doctor/presentation/widgets/section_label.dart';
import 'package:frontend/modules/doctor/presentation/widgets/home/stat_card.dart';

class DoctorStatCards extends StatelessWidget {
  const DoctorStatCards({super.key});

  static const _stats = [
    StatData(
      icon: Icons.calendar_today_rounded,
      value: '24',
      title: "Today's\nAppointments",
      color: AppColors.primaryColor,
      bg: AppColors.primarySurface,
      trend: '+3 vs yesterday',
      trendUp: true,
    ),
    StatData(
      icon: Icons.people_rounded,
      value: '1,245',
      title: 'Total\nPatients',
      color: AppColors.accentGreen,
      bg: Color(0xFFDCFCE7),
      trend: '+12 this week',
      trendUp: true,
    ),
    StatData(
      icon: Icons.account_balance_wallet_rounded,
      value: '₹1.52L',
      title: 'Total\nRevenue',
      color: AppColors.accentAmber,
      bg: Color(0xFFFFF4E6),
      trend: '+8% this month',
      trendUp: true,
    ),
    StatData(
      icon: Icons.star_rounded,
      value: '4.8',
      title: 'Average\nRating',
      color: AppColors.dangerRed,
      bg: Color(0xFFFFEEEE),
      trend: '320 reviews',
      trendUp: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label: 'Overview'),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: isMobile ? 1.1 : 1.2,
            children: _stats
                .map((s) => StatCard(data: s, isMobile: isMobile))
                .toList(),
          ),
        ],
      ),
    );
  }
}
