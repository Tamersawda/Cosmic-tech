import 'package:frontend/modules/user/presentation/screens/home/categories_section.dart';
import 'package:frontend/modules/user/presentation/screens/home/doctors_section.dart';
import 'package:frontend/modules/user/presentation/screens/home/health_tips_section.dart';
import 'package:frontend/modules/user/presentation/screens/home/home_carousel.dart';
import 'package:frontend/modules/user/presentation/screens/home/home_header.dart';
import 'package:frontend/modules/user/presentation/screens/home/upcoming_appointments.dart';
import 'package:frontend/modules/user/presentation/screens/home/wellness_banner.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: HomeHeader()),
          const SliverToBoxAdapter(child: HomeCarousel()),
          const SliverToBoxAdapter(child: CategoriesSection()),
          const SliverToBoxAdapter(child: DoctorsSection()),
          const SliverToBoxAdapter(child: WellnessBanner()),
          SliverToBoxAdapter(child: UpcomingAppointments()),
          const SliverToBoxAdapter(child: HealthTipsSection()),
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
