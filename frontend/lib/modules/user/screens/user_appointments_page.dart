import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class UserAppointmentsPage extends StatefulWidget {
  const UserAppointmentsPage({super.key});

  @override
  State<UserAppointmentsPage> createState() => _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends State<UserAppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  static const _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  static const List<Map<String, dynamic>> _appointments = [
    {
      'doctor': 'Dr. Ananya Verma',
      'spec': 'Clinical Psychologist',
      'initials': 'AV',
      'color': AppColors.primaryColor,
      'date': 'Today',
      'time': '10:30 AM',
      'type': 'Video Call',
      'fee': '₹800',
      'status': 'upcoming',
      'note': 'CBT Session — Anxiety & Mindfulness',
    },
    {
      'doctor': 'Dr. Rohan Mehta',
      'spec': 'Psychiatrist',
      'initials': 'RM',
      'color': AppColors.accentPurple,
      'date': 'Tomorrow',
      'time': '2:00 PM',
      'type': 'In-Person',
      'fee': '₹1200',
      'status': 'upcoming',
      'note': 'Follow-up for medication review',
    },
    {
      'doctor': 'Dr. Sneha Pillai',
      'spec': 'Therapist',
      'initials': 'SP',
      'color': AppColors.accentSky,
      'date': 'Mar 30, 2026',
      'time': '11:00 AM',
      'type': 'Video Call',
      'fee': '₹600',
      'status': 'upcoming',
      'note': 'Trauma-informed therapy session',
    },
    {
      'doctor': 'Dr. Kabir Nair',
      'spec': 'Counsellor',
      'initials': 'KN',
      'color': AppColors.accentAmber,
      'date': 'Mar 20, 2026',
      'time': '9:00 AM',
      'type': 'Video Call',
      'fee': '₹500',
      'status': 'completed',
      'note': 'Career stress & goal setting',
    },
    {
      'doctor': 'Dr. Priya Sharma',
      'spec': 'Psychiatrist',
      'initials': 'PS',
      'color': AppColors.accentGreen,
      'date': 'Mar 15, 2026',
      'time': '3:30 PM',
      'type': 'In-Person',
      'fee': '₹1000',
      'status': 'completed',
      'note': 'Adolescent mental wellness check-in',
    },
    {
      'doctor': 'Dr. Arjun Das',
      'spec': 'Therapist',
      'initials': 'AD',
      'color': AppColors.accentTeal,
      'date': 'Mar 10, 2026',
      'time': '12:00 PM',
      'type': 'Video Call',
      'fee': '₹550',
      'status': 'cancelled',
      'note': 'PTSD & somatic therapy',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    final statusKey = ['upcoming', 'completed', 'cancelled'][_selectedTab];
    return _appointments.where((a) => a['status'] == statusKey).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context, hPad, isMobile)),

          // ── Summary Cards ────────────────────────────────────
          SliverToBoxAdapter(child: _buildSummaryCards(hPad, isMobile)),

          // ── Tabs ─────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildTabs(hPad)),

          // ── List ─────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
            sliver: _filtered.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _AppointmentCard(
                        appt: _filtered[i],
                        isMobile: isMobile,
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
          ),

          // ── Bottom spacing ────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

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
                'Appointments',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Manage your sessions',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double hPad, bool isMobile) {
    final upcoming = _appointments
        .where((a) => a['status'] == 'upcoming')
        .length;
    final completed = _appointments
        .where((a) => a['status'] == 'completed')
        .length;
    final cancelled = _appointments
        .where((a) => a['status'] == 'cancelled')
        .length;

    final stats = [
      {
        'label': 'Upcoming',
        'value': '$upcoming',
        'icon': Icons.schedule_rounded,
        'color': AppColors.primaryColor,
        'bg': AppColors.primarySurface,
      },
      {
        'label': 'Completed',
        'value': '$completed',
        'icon': Icons.check_circle_rounded,
        'color': AppColors.accentGreen,
        'bg': const Color(0xFFDCFCE7),
      },
      {
        'label': 'Cancelled',
        'value': '$cancelled',
        'icon': Icons.cancel_rounded,
        'color': AppColors.dangerRed,
        'bg': const Color(0xFFFFEEEE),
      },
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: s['bg'] as Color,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      s['icon'] as IconData,
                      color: s['color'] as Color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['value'] as String,
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          s['label'] as String,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

  Widget _buildTabs(double hPad) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          itemCount: _tabs.length,
          itemBuilder: (_, i) {
            final active = _selectedTab == i;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedTab = i);
                _tabController.animateTo(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryColor : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? AppColors.primaryColor
                        : AppColors.borderColor,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.white : AppColors.labelColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 34,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No appointments here',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Book a session with a doctor to get started',
            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: AppColors.primaryColor,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: AppColors.white),
      label: const Text(
        'Book Session',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ── Appointment Card ──────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appt;
  final bool isMobile;

  const _AppointmentCard({required this.appt, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final color = appt['color'] as Color;
    final status = appt['status'] as String;
    final isUpcoming = status == 'upcoming';
    final isCompleted = status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Doctor info row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: isMobile ? 52 : 60,
                  height: isMobile ? 52 : 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      appt['initials'],
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appt['doctor'],
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          _StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        appt['spec'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Date / time / type row
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_month_rounded,
                            label: '${appt['date']} • ${appt['time']}',
                          ),
                          _InfoChip(
                            icon: appt['type'] == 'Video Call'
                                ? Icons.videocam_rounded
                                : Icons.location_on_rounded,
                            label: appt['type'],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Session note ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 14,
                    color: AppColors.mutedText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appt['note'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.labelColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Footer ──
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Fee',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.softMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appt['fee'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isUpcoming) ...[
                  _OutlineButton(label: 'Reschedule', onTap: () {}),
                  const SizedBox(width: 10),
                  _PrimaryButton(
                    label: 'Join',
                    icon: Icons.videocam_rounded,
                    onTap: () {},
                  ),
                ] else if (isCompleted) ...[
                  _PrimaryButton(
                    label: 'Rebook',
                    icon: Icons.refresh_rounded,
                    onTap: () {},
                  ),
                ] else ...[
                  _OutlineButton(label: 'View Details', onTap: () {}),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable pieces ─────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, textColor;
    String label;
    switch (status) {
      case 'completed':
        bg = const Color(0xFFDCFCE7);
        textColor = AppColors.accentGreen;
        label = 'Completed';
        break;
      case 'cancelled':
        bg = const Color(0xFFFFEEEE);
        textColor = AppColors.dangerDark;
        label = 'Cancelled';
        break;
      default:
        bg = AppColors.primarySurface;
        textColor = AppColors.primaryColor;
        label = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.mutedText),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }
}
