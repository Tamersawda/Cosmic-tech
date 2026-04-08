import 'package:frontend/modules/doctor/widgets/appointments/cards/app_search_bar.dart';
import 'package:frontend/modules/doctor/widgets/appointments/cards/appointment_card.dart';
import 'package:frontend/modules/doctor/widgets/appointments/cards/appointments_page_header.dart';
import 'package:frontend/modules/doctor/widgets/appointments/cards/empty_state_view.dart';
import 'package:frontend/modules/doctor/widgets/appointments/cards/filter_chip_bar.dart';
import 'package:frontend/modules/doctor/widgets/appointments/cards/summary_strip.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:frontend/modules/doctor/models/appointment_model.dart';
import 'package:frontend/modules/doctor/screens/appointments/appointment_details_page.dart';
import 'package:flutter/material.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  static const _filters = [
    'All',
    'Upcoming',
    'Confirmed',
    'Pending',
    'Completed',
    'Cancelled',
  ];

  // ── Avatar color palette ─────────────────────────────────────────────────
  static const _avatarColors = [
    AppColors.primaryColor,
    AppColors.accentPurple,
    AppColors.accentTeal,
    AppColors.accentAmber,
    AppColors.accentSky,
    AppColors.accentGreen,
    AppColors.dangerRed,
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  // ── Sample data ──────────────────────────────────────────────────────────
  final List<Appointment> _appointments = [
    Appointment(
      name: 'Priya Sharma',
      initials: 'PS',
      gender: 'Female',
      age: 28,
      date: 'March 10, 2026',
      time: '10:30 AM',
      type: 'Video',
      fee: '₹500',
      status: 'Confirmed',
      reason: 'Follow-up consultation for headaches',
      history: ['Migraine (chronic)', 'Hypertension', 'Allergic to Penicillin'],
    ),
    Appointment(
      name: 'Rahul Mehta',
      initials: 'RM',
      gender: 'Male',
      age: 35,
      date: 'March 11, 2026',
      time: '11:00 AM',
      type: 'Clinic',
      fee: '₹600',
      status: 'Pending',
      reason: 'Chest pain and breathing difficulty',
      history: ['Asthma', 'High cholesterol'],
    ),
    Appointment(
      name: 'Ankit Verma',
      initials: 'AV',
      gender: 'Male',
      age: 42,
      date: 'March 12, 2026',
      time: '02:00 PM',
      type: 'Video',
      fee: '₹800',
      status: 'Completed',
      reason: 'Cardiology review and medication check',
      history: ['Hypertension', 'Type 2 Diabetes'],
    ),
    Appointment(
      name: 'Sneha Pillai',
      initials: 'SP',
      gender: 'Female',
      age: 31,
      date: 'March 13, 2026',
      time: '04:30 PM',
      type: 'Clinic',
      fee: '₹450',
      status: 'Cancelled',
      reason: 'Routine therapy session',
      history: ['Anxiety disorder', 'Insomnia'],
    ),
  ];

  // ── Derived values ───────────────────────────────────────────────────────
  List<Appointment> get _filtered => _appointments.where((a) {
    final matchSearch =
        _searchQuery.isEmpty ||
        a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        a.reason.toLowerCase().contains(_searchQuery.toLowerCase());
    final matchFilter = _selectedFilter == 'All' || a.status == _selectedFilter;
    return matchSearch && matchFilter;
  }).toList();

  List<SummaryTileData> get _summaryTiles => [
    SummaryTileData(
      label: 'Today',
      value:
          '${_appointments.where((a) => a.status == 'Confirmed' || a.status == 'Pending').length}',
      icon: Icons.today_rounded,
      color: AppColors.primaryColor,
      bg: AppColors.primarySurface,
    ),
    SummaryTileData(
      label: 'Completed',
      value: '${_appointments.where((a) => a.status == 'Completed').length}',
      icon: Icons.check_circle_rounded,
      color: AppColors.accentGreen,
      bg: const Color(0xFFDCFCE7),
    ),
    SummaryTileData(
      label: 'Pending',
      value: '${_appointments.where((a) => a.status == 'Pending').length}',
      icon: Icons.hourglass_bottom_rounded,
      color: AppColors.accentAmber,
      bg: const Color(0xFFFFF4E6),
    ),
    SummaryTileData(
      label: 'Total',
      value: '${_appointments.length}',
      icon: Icons.people_rounded,
      color: AppColors.accentPurple,
      bg: const Color(0xFFEDE9FB),
    ),
  ];

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: AppointmentsPageHeader(
                isMobile: isMobile,
                onAddTap: () {},
              ),
            ),
          ),

          // Summary strip
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
              child: SummaryStrip(tiles: _summaryTiles, isMobile: isMobile),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
              child: AppSearchBar(
                hintText: 'Search patient name or issue...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // Filter chip bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: FilterChipBar(
                filters: _filters,
                selected: _selectedFilter,
                onSelect: (f) => setState(() => _selectedFilter = f),
                horizontalPadding: hPad,
              ),
            ),
          ),

          // List or empty state
          _filtered.isEmpty
              ? const SliverToBoxAdapter(child: EmptyStateView())
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => AppointmentCard(
                        appointment: _filtered[i],
                        avatarColor: _avatarColor(i),
                        isMobile: isMobile,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppointmentDetailsPage(
                              appointment: _filtered[i],
                              avatarColor: _avatarColor(i),
                            ),
                          ),
                        ),
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
                ),

          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ),
        ],
      ),
    );
  }
}
