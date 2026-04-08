import 'package:frontend/modules/user/screens/user_appointments_page.dart';
import 'package:frontend/modules/user/screens/user_doctors_page.dart';
import 'package:frontend/modules/user/screens/user_home_page.dart';
import 'package:frontend/modules/user/screens/user_profile_page.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class MainUserLayout extends StatefulWidget {
  const MainUserLayout({super.key});

  @override
  State<MainUserLayout> createState() => _MainUserLayoutState();
}

class _MainUserLayoutState extends State<MainUserLayout>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnims;
  late final List<Animation<double>> _slideAnims;

  static const _navItems = [
    _NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services_rounded,
      label: 'Doctors',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Appointments',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  final List<Widget> _pages = const [
    UserHomePage(),
    UserDoctorsPage(),
    UserAppointmentsPage(),
    UserProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _navItems.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _scaleAnims = _controllers
        .map(
          (c) => Tween<double>(
            begin: 1.0,
            end: 1.18,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)),
        )
        .toList();

    _slideAnims = _controllers
        .map(
          (c) => Tween<double>(
            begin: 0.0,
            end: -4.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    _controllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    _controllers[_currentIndex].reverse();
    setState(() => _currentIndex = index);
    _controllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) => _buildNavItem(i)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = _currentIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0, _slideAnims[index].value),
              child: Transform.scale(
                scale: _scaleAnims[index].value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pill background + icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      width: isActive ? 52 : 36,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primarySurface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            key: ValueKey(isActive),
                            size: 22,
                            color: isActive
                                ? AppColors.primaryColor
                                : AppColors.softMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Label
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? AppColors.primaryColor
                            : AppColors.softMuted,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
