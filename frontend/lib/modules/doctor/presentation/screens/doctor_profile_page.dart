import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/doctor/presentation/screens/profile/doctor_edit_consultation_page.dart';
import 'package:frontend/modules/doctor/presentation/screens/profile/doctor_edit_personal_info_page.dart';
import 'package:frontend/modules/doctor/presentation/screens/profile/doctor_edit_qualifications_page.dart' hide DoctorEditConsultationPage;
import 'package:frontend/modules/doctor/presentation/screens/profile/doctor_edit_schedule_page.dart';
import 'package:image_picker/image_picker.dart';

// ── Doctor state model (replace with provider/bloc later) ─────────────────────

class DoctorProfileData {
  String name;
  String specialty;
  String bio;
  String email;
  String phone;
  String address;
  String city;
  String state;
  String country;
  String experience;
  String languages;
  String registrationNumber;
  String council;
  String onlineFee;
  String offlineFee;
  bool isVerified;
  bool isLive;
  bool notificationsEnabled;
  bool appointmentReminders;
  bool newPatientAlerts;
  File? profilePhoto;
  double rating;
  int reviewCount;
  int totalPatients;

  DoctorProfileData({
    this.name = 'Dr. Julian Vance',
    this.specialty = 'Internal Medicine Specialist',
    this.bio =
        'Board-certified internal medicine physician with over 12 years of '
        'clinical experience. Specializing in preventive care, chronic disease '
        'management, and patient-centered holistic approaches.',
    this.email = 'julian.vance@hospital.com',
    this.phone = '+91 98765 43210',
    this.address = '123 Medical Street, Suite 400',
    this.city = 'Bangalore',
    this.state = 'Karnataka',
    this.country = 'India',
    this.experience = '12',
    this.languages = 'English, Hindi, Kannada',
    this.registrationNumber = 'KA-MED-2041',
    this.council = 'Medical Council of India (MCI)',
    this.onlineFee = '800',
    this.offlineFee = '1200',
    this.isVerified = true,
    this.isLive = true,
    this.notificationsEnabled = true,
    this.appointmentReminders = true,
    this.newPatientAlerts = false,
    this.profilePhoto,
    this.rating = 4.9,
    this.reviewCount = 128,
    this.totalPatients = 3200,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _data = DoctorProfileData();
  final _picker = ImagePicker();

  Future<void> _pickPhoto() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img != null) setState(() => _data.profilePhoto = File(img.path));
  }

  void _go(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionDuration: const Duration(milliseconds: 270),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  String get _initials {
    final parts = _data.name.replaceAll('Dr. ', '').trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(hPad)),
          SliverToBoxAdapter(child: _buildProfileBanner(hPad)),
          SliverToBoxAdapter(child: _buildStatusToggles(hPad)),
          SliverToBoxAdapter(child: _buildStatsRow(hPad)),
          SliverToBoxAdapter(
            child: _buildSectionGroup(
              hPad: hPad,
              title: 'PROFILE',
              items: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Personal Information',
                  subtitle: _data.name,
                  color: AppColors.primaryColor,
                  onTap: () => _go(DoctorEditPersonalInfoPage(data: _data)),
                ),
                _MenuItem(
                  icon: Icons.medical_services_outlined,
                  label: 'Professional Details',
                  subtitle: _data.specialty,
                  color: AppColors.accentTeal,
                  onTap: () => _go(DoctorEditProfessionalPage(data: _data)),
                ),
                _MenuItem(
                  icon: Icons.school_outlined,
                  label: 'Qualifications',
                  subtitle: 'Degrees, certifications',
                  color: const Color(0xFF7C3AED),
                  onTap: () => _go(DoctorEditQualificationsPage(data: _data)),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSectionGroup(
              hPad: hPad,
              title: 'PRACTICE',
              items: [
                _MenuItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Schedule & Availability',
                  subtitle: 'Shifts, working days',
                  color: const Color(0xFF16A34A),
                  onTap: () => _go(DoctorScheduleSummaryPage(data: _data)),
                ),
                _MenuItem(
                  icon: Icons.payments_outlined,
                  label: 'Consultation Fees',
                  subtitle:
                      '₹${_data.onlineFee} online  •  ₹${_data.offlineFee} in-clinic',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _go(DoctorEditConsultationPage()),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSectionGroup(
              hPad: hPad,
              title: 'PREFERENCES',
              items: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  subtitle: _data.notificationsEnabled ? 'Enabled' : 'Disabled',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _go(DoctorNotificationsPage(data: _data)),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _buildSectionGroup(
              hPad: hPad,
              title: 'ACCOUNT',
              items: [
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  subtitle: 'FAQs, contact support',
                  color: AppColors.accentAmber,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  subtitle: 'Terms, data usage',
                  color: const Color(0xFF0891B2),
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.star_border_rounded,
                  label: 'Rate the App',
                  subtitle: 'Share your feedback',
                  color: const Color(0xFFF59E0B),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: _buildLogout(hPad)),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(double hPad) {
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
            children: const [
              Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Manage your clinical presence',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(
                Icons.settings_outlined,
                size: 20,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile Banner ─────────────────────────────────────────────────────────

  Widget _buildProfileBanner(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      image: _data.profilePhoto != null
                          ? DecorationImage(
                              image: FileImage(_data.profilePhoto!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _data.profilePhoto == null
                        ? Center(
                            child: Text(
                              _initials,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 11,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _data.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _data.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _data.email,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < _data.rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_half_rounded,
                          size: 14,
                          color: const Color(0xFFFBBF24),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${_data.rating}  (${_data.reviewCount})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit button
            GestureDetector(
              onTap: () => _go(DoctorEditPersonalInfoPage(data: _data)),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Toggles ──────────────────────────────────────────────────────────

  Widget _buildStatusToggles(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatusToggleCard(
              icon: Icons.verified_outlined,
              label: 'Verification',
              value: _data.isVerified,
              activeColor: const Color(0xFF16A34A),
              activeBg: const Color(0xFFF0FDF4),
              activeBorder: const Color(0xFFBBF7D0),
              activeLabel: 'Verified',
              inactiveLabel: 'Not Verified',
              onChanged: (v) => setState(() => _data.isVerified = v),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatusToggleCard(
              icon: Icons.wifi_tethering_rounded,
              label: 'Profile Status',
              value: _data.isLive,
              activeColor: AppColors.primaryColor,
              activeBg: AppColors.primarySurface,
              activeBorder: AppColors.primaryColor,
              activeLabel: 'Live',
              inactiveLabel: 'Hidden',
              onChanged: (v) => setState(() => _data.isLive = v),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────────────────

  Widget _buildStatsRow(double hPad) {
    final stats = [
      {
        'icon': Icons.people_outline,
        'value': '${(_data.totalPatients / 1000).toStringAsFixed(1)}K+',
        'label': 'Patients',
        'color': AppColors.primaryColor,
        'bg': AppColors.primarySurface,
      },
      {
        'icon': Icons.timeline_outlined,
        'value': '${_data.experience}+',
        'label': 'Years Exp.',
        'color': AppColors.accentTeal,
        'bg': const Color(0xFFE0F7FA),
      },
      {
        'icon': Icons.thumb_up_outlined,
        'value': '98%',
        'label': 'Satisfaction',
        'color': const Color(0xFF7C3AED),
        'bg': const Color(0xFFEDE9FB),
      },
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: s['bg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      s['icon'] as IconData,
                      color: s['color'] as Color,
                      size: 17,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    s['value'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section Group ───────────────────────────────────────────────────────────

  Widget _buildSectionGroup({
    required double hPad,
    required String title,
    required List<_MenuItem> items,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedText,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final isLast = i == items.length - 1;
                return _MenuItemTile(item: item, isLast: isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout ──────────────────────────────────────────────────────────────────

  Widget _buildLogout(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEEEE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.dangerDark),
              SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dangerDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status Toggle Card ────────────────────────────────────────────────────────

class _StatusToggleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Color activeColor;
  final Color activeBg;
  final Color activeBorder;
  final String activeLabel;
  final String inactiveLabel;
  final ValueChanged<bool> onChanged;

  const _StatusToggleCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.activeColor,
    required this.activeBg,
    required this.activeBorder,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value ? activeBg : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? activeBorder : AppColors.borderColor,
          width: value ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: value ? activeColor : AppColors.mutedText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value ? activeLabel : inactiveLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: value ? activeColor : AppColors.labelColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ── Menu Item model + tile ────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;
  final bool isLast;

  const _MenuItemTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(height: 1, indent: 68, color: AppColors.borderColor),
        ],
      ),
    );
  }
}
