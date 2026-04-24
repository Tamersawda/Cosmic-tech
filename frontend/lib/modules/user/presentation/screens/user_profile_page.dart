import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/modules/auth/presentation/screens/landing_page.dart';
import 'package:frontend/modules/user/presentation/screens/profile/user_edit_profile_page.dart';
import 'package:frontend/modules/user/presentation/screens/profile/user_health_information_page.dart';
import 'package:frontend/modules/user/presentation/screens/profile/user_help_faqs_page.dart';
import 'package:frontend/modules/user/presentation/screens/profile/user_language_page.dart';
import 'package:frontend/modules/user/presentation/screens/profile/user_payment_methods_page.dart';
import 'package:frontend/modules/user/presentation/screens/profile/user_privacy_policy_page.dart';
import 'package:frontend/modules/user/presentation/screens/profile/user_rate_app_page.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  bool _notificationsEnabled = true;
  bool _reminderEnabled      = false;

  static const List<Map<String, dynamic>> _menuGroups = [
    {
      'title': 'Account',
      'items': [
        {
          'icon':     Icons.person_outline_rounded,
          'label':    'Edit Profile',
          'trailing': true,
          'color':    AppColors.primaryColor,
        },
        {
          'icon':     Icons.health_and_safety_outlined,
          'label':    'Health Information',
          'trailing': true,
          'color':    AppColors.accentGreen,
        },
        {
          'icon':     Icons.credit_card_rounded,
          'label':    'Payment Methods',
          'trailing': true,
          'color':    AppColors.accentAmber,
        },
      ],
    },
    {
      'title': 'Preferences',
      'items': [
        {
          'icon':   Icons.notifications_outlined,
          'label':  'Notifications',
          'toggle': 'notifications',
          'color':  AppColors.accentPurple,
        },
        {
          'icon':   Icons.alarm_rounded,
          'label':  'Session Reminders',
          'toggle': 'reminder',
          'color':  AppColors.accentSky,
        },
        {
          'icon':  Icons.language_rounded,
          'label': 'Language',
          'value': 'English',
          'color': AppColors.accentTeal,
        },
      ],
    },
    {
      'title': 'Support',
      'items': [
        {
          'icon':     Icons.help_outline_rounded,
          'label':    'Help & FAQs',
          'trailing': true,
          'color':    AppColors.accentAmber,
        },
        {
          'icon':     Icons.privacy_tip_outlined,
          'label':    'Privacy Policy',
          'trailing': true,
          'color':    AppColors.accentPurple,
        },
        {
          'icon':     Icons.star_border_rounded,
          'label':    'Rate the App',
          'trailing': true,
          'color':    AppColors.accentGreen,
        },
      ],
    },
  ];

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log Out',
              style: TextStyle(
                color:      AppColors.dangerRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    // Call auth provider logout
    // This clears SharedPrefs + calls API
    await ref.read(authProvider.notifier).logout();
  }

  // ── Listen for auth state changes → navigate to landing ──────────────────
  void _handleAuthState(AuthState? previous, AuthState next) {
    if (!mounted) return;
    if (next is AuthUnauthenticated) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LandingPage(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve:  Curves.easeOut,
            ),
            child: child,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for logout state change
    ref.listen<AuthState>(authProvider, _handleAuthState);

    final authState = ref.watch(authProvider);
    final isLoggingOut = authState is AuthLoading;

    // Read user data from provider
    final user = ref.watch(currentUserProvider);
    final hPad    = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, hPad, isMobile),
          ),
          SliverToBoxAdapter(
            child: _buildProfileBanner(context, hPad, isMobile, user),
          ),
          SliverToBoxAdapter(
            child: _buildStatsRow(hPad, isMobile),
          ),
          for (final group in _menuGroups)
            SliverToBoxAdapter(
              child: _buildMenuGroup(context, group, hPad, isMobile),
            ),
          SliverToBoxAdapter(
            child: _buildLogout(hPad, isLoggingOut),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 32,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double hPad, bool isMobile) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        hPad,
        MediaQuery.of(context).padding.top + 14,
        hPad,
        18,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  fontSize:   isMobile ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color:      AppColors.darkText,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Manage your account',
                style: TextStyle(
                  fontSize:   13,
                  color:      AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width:  42,
            height: 42,
            decoration: BoxDecoration(
              color:        AppColors.bgColor,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: AppColors.borderColor),
            ),
            child: const Icon(
              Icons.settings_outlined,
              size:  20,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile Banner ────────────────────────────────────────────────────────
  Widget _buildProfileBanner(
    BuildContext context,
    double hPad,
    bool isMobile,
    // ← receives user from provider
    dynamic user,
  ) {
    // Use real data from provider, fallback to placeholder
    final name     = user?.name  ?? 'User';
    final email    = user?.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          boxShadow: [
            BoxShadow(
              color:      AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset:     const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with initials
            Container(
              width:  isMobile ? 64 : 78,
              height: isMobile ? 64 : 78,
              decoration: BoxDecoration(
                color:  Colors.white.withOpacity(0.2),
                shape:  BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize:   isMobile ? 26 : 32,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize:   isMobile ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color:      AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color:    Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical:   4,
                    ),
                    decoration: BoxDecoration(
                      color:        Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Member since Jan 2025',
                      style: TextStyle(
                        fontSize:   10,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit icon
            GestureDetector(
              onTap: () => _navigateFade(const UserEditProfilePage()),
              child: Container(
                width:  38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size:  17,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(double hPad, bool isMobile) {
    final stats = [
      {
        'label': 'Sessions',
        'value': '12',
        'icon':  Icons.video_call_rounded,
        'color': AppColors.primaryColor,
        'bg':    AppColors.primarySurface,
      },
      {
        'label': 'Doctors',
        'value': '4',
        'icon':  Icons.medical_services_rounded,
        'color': AppColors.accentPurple,
        'bg':    const Color(0xFFEDE9FB),
      },
      {
        'label': 'Day Streak',
        'value': '7',
        'icon':  Icons.local_fire_department_rounded,
        'color': AppColors.accentAmber,
        'bg':    const Color(0xFFFFF4E6),
      },
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: i < stats.length - 1 ? 10 : 0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical:   14,
              ),
              decoration: BoxDecoration(
                color:        AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border:       Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color:      Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset:     const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width:  36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:        s['bg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      s['icon'] as IconData,
                      color: s['color'] as Color,
                      size:  18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s['value'] as String,
                    style: TextStyle(
                      fontSize:   isMobile ? 18 : 22,
                      fontWeight: FontWeight.w800,
                      color:      AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label'] as String,
                    style: const TextStyle(
                      fontSize:   10,
                      color:      AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Menu group ────────────────────────────────────────────────────────────
  Widget _buildMenuGroup(
    BuildContext context,
    Map<String, dynamic> group,
    double hPad,
    bool isMobile,
  ) {
    final items = group['items'] as List<Map<String, dynamic>>;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (group['title'] as String).toUpperCase(),
            style: const TextStyle(
              fontSize:      11,
              fontWeight:    FontWeight.w700,
              color:         AppColors.mutedText,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color:        AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border:       Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset:     const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final i      = e.key;
                final item   = e.value;
                final isLast = i == items.length - 1;
                return _buildMenuItem(item, isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isLast) {
    final color      = item['color']    as Color;
    final hasToggle  = item.containsKey('toggle');
    final hasValue   = item.containsKey('value');
    final hasTrailing = item['trailing'] == true;

    bool toggleValue = false;
    if (hasToggle) {
      toggleValue = item['toggle'] == 'notifications'
          ? _notificationsEnabled
          : _reminderEnabled;
    }

    return GestureDetector(
      onTap: hasToggle
          ? () {
              setState(() {
                if (item['toggle'] == 'notifications') {
                  _notificationsEnabled = !_notificationsEnabled;
                } else {
                  _reminderEnabled = !_reminderEnabled;
                }
              });
            }
          : () => _handleMenuTap(item['label'] as String),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical:   14,
            ),
            child: Row(
              children: [
                Container(
                  width:  36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:        color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: color,
                    size:  18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item['label'],
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.darkText,
                    ),
                  ),
                ),
                if (hasValue)
                  Text(
                    item['value'],
                    style: const TextStyle(
                      fontSize:   12,
                      color:      AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (hasToggle)
                  Switch(
                    value:    toggleValue,
                    onChanged: (_) {
                      setState(() {
                        if (item['toggle'] == 'notifications') {
                          _notificationsEnabled = !_notificationsEnabled;
                        } else {
                          _reminderEnabled = !_reminderEnabled;
                        }
                      });
                    },
                    activeThumbColor:     AppColors.primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                if (hasTrailing)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size:  13,
                    color: AppColors.mutedText,
                  ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height:    1,
              thickness: 1,
              indent:    66,
              color:     AppColors.borderColor,
            ),
        ],
      ),
    );
  }

  // ── Logout button ─────────────────────────────────────────────────────────
  Widget _buildLogout(double hPad, bool isLoggingOut) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: GestureDetector(
        onTap: isLoggingOut ? null : _logout, // ← disabled while logging out
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:        const Color(0xFFFFEEEE),
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: isLoggingOut
              // Show spinner while logout API call is in progress
              ? const Center(
                  child: SizedBox(
                    width:  20,
                    height: 20,
                    child:  CircularProgressIndicator(
                      color:       AppColors.dangerRed,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size:  18,
                      color: AppColors.dangerDark,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize:   14,
                        fontWeight: FontWeight.w700,
                        color:      AppColors.dangerDark,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _navigateFade(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration:        const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child:   child,
        ),
      ),
    );
  }

  void _handleMenuTap(String label) {
    switch (label) {
      case 'Edit Profile':
        _navigateFade(const UserEditProfilePage());
      case 'Health Information':
        _navigateFade(const UserHealthInformationPage());
      case 'Payment Methods':
        _navigateFade(const UserPaymentMethodsPage());
      case 'Language':
        _navigateFade(const UserLanguagePage());
      case 'Help & FAQs':
        _navigateFade(const UserHelpFaqsPage());
      case 'Privacy Policy':
        _navigateFade(const UserPrivacyPolicyPage());
      case 'Rate the App':
        _navigateFade(const UserRateAppPage());
    }
  }
}