import 'package:frontend/modules/doctor/router/main_doctor_layout.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_feature_card.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_section_card.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfileCompletedPage extends StatefulWidget {
  const ProfileCompletedPage({super.key});

  @override
  State<ProfileCompletedPage> createState() => _ProfileCompletedPageState();
}

class _ProfileCompletedPageState extends State<ProfileCompletedPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with doctor avatar
            DoctorTopBar(
              title: 'Clinical Sanctuary',
              showHelpIcon: false,
              trailing: const _DoctorAvatar(),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Step completion dots
                    const _StepCompletionDots(totalSteps: 5),

                    const SizedBox(height: 32),

                    // Animated success icon
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // SUCCESS badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SUCCESS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.successGreen,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Profile Complete!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your professional profile is 100% complete\nand ready for patients.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.labelColor,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Feature cards — uses DoctorFeatureCard
                    const DoctorFeatureCard(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Digital Credentials',
                      subtitle: 'Verified and live for public view.',
                      iconBgColor: AppColors.primaryColor,
                    ),
                    const DoctorFeatureCard(
                      icon: Icons.calendar_month_outlined,
                      title: 'Smart Scheduling',
                      subtitle: 'Active slots available for booking.',
                      iconBgColor: AppColors.primaryColor,
                    ),

                    const SizedBox(height: 8),

                    // Dashboard button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainDoctorLayout(),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Go to Dashboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resource image cards
                    _ImageCard(
                      label: 'RESOURCE',
                      title: 'Hospitality Guide',
                      overlayColor: const Color(0xFF475569),
                      bgIcon: Icons.menu_book_outlined,
                    ),
                    _ImageCard(
                      label: 'NEXT STEP',
                      title: 'Patient Interaction',
                      overlayColor: const Color(0xFF0F766E),
                      bgIcon: Icons.people_outline,
                    ),

                    // Concierge support card — uses DoctorSectionCard
                    DoctorSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SUPPORT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Concierge Onboarding',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {},
                            child: const Row(
                              children: [
                                Text(
                                  'Book a Call',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.phone_outlined,
                                  size: 16,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'JV',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Dr. Julian Vance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class _StepCompletionDots extends StatelessWidget {
  final int totalSteps;

  const _StepCompletionDots({required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (i) {
          final isLast = i == totalSteps - 1;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isLast
                      ? AppColors.primaryColor
                      : AppColors.successLight,
                  shape: BoxShape.circle,
                  boxShadow: isLast
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isLast ? Icons.verified : Icons.check,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 20,
                  height: 2,
                  color: AppColors.successLight,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String label;
  final String title;
  final Color overlayColor;
  final IconData bgIcon;

  const _ImageCard({
    required this.label,
    required this.title,
    required this.overlayColor,
    required this.bgIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            overlayColor.withValues(alpha: 0.7),
            overlayColor.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              bgIcon,
              size: 120,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
