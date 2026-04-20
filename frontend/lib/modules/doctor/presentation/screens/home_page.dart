import 'package:frontend/modules/doctor/presentation/screens/doctor/doctor_earnings_banner.dart';
import 'package:frontend/modules/doctor/presentation/screens/doctor/doctor_header.dart';
import 'package:frontend/modules/doctor/presentation/screens/doctor/doctor_patient_insights.dart';
import 'package:frontend/modules/doctor/presentation/screens/doctor/doctor_quick_actions.dart';
import 'package:frontend/modules/doctor/presentation/screens/doctor/doctor_schedule_section.dart';
import 'package:frontend/modules/doctor/presentation/screens/doctor/doctor_stat_cards.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: DoctorHeader()),
          const SliverToBoxAdapter(child: DoctorStatCards()),
          const SliverToBoxAdapter(child: DoctorQuickActions()),
          const SliverToBoxAdapter(child: DoctorEarningsBanner()),
          const SliverToBoxAdapter(child: DoctorScheduleSection()),
          const SliverToBoxAdapter(child: DoctorPatientInsights()),
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  MediaQuery.of(context).padding.bottom + (isDesktop ? 48 : 32),
            ),
          ),
        ],
      ),
    );
  }
}
