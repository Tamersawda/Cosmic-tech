import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:frontend/modules/user/screens/doctors/doctor_booking_page.dart';
import 'package:flutter/material.dart';

class UserDoctorsPage extends StatefulWidget {
  const UserDoctorsPage({super.key});

  @override
  State<UserDoctorsPage> createState() => _UserDoctorsPageState();
}

class _UserDoctorsPageState extends State<UserDoctorsPage> {
  int _selectedFilter = 0;
  String _searchQuery = '';

  static const _filters = [
    'All',
    'Available',
    'Psychiatrist',
    'Therapist',
    'Counsellor',
  ];

  static const List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Ananya Verma',
      'spec': 'Clinical Psychologist',
      'rating': '4.8',
      'exp': '10 Yrs',
      'fee': '₹800',
      'available': true,
      'color': AppColors.primaryColor,
      'initials': 'AV',
      'patients': '320+',
      'about':
          'Specialist in CBT and mindfulness-based therapy for anxiety and depression.',
    },
    {
      'name': 'Dr. Rohan Mehta',
      'spec': 'Psychiatrist',
      'rating': '4.9',
      'exp': '14 Yrs',
      'fee': '₹1200',
      'available': true,
      'color': AppColors.accentPurple,
      'initials': 'RM',
      'patients': '540+',
      'about':
          'Expert in mood disorders, schizophrenia and psychopharmacology.',
    },
    {
      'name': 'Dr. Sneha Pillai',
      'spec': 'Therapist',
      'rating': '4.7',
      'exp': '7 Yrs',
      'fee': '₹600',
      'available': false,
      'color': AppColors.accentSky,
      'initials': 'SP',
      'patients': '210+',
      'about': 'Focuses on trauma-informed care and relationship therapy.',
    },
    {
      'name': 'Dr. Kabir Nair',
      'spec': 'Counsellor',
      'rating': '4.6',
      'exp': '5 Yrs',
      'fee': '₹500',
      'available': true,
      'color': AppColors.accentAmber,
      'initials': 'KN',
      'patients': '180+',
      'about':
          'Specialises in student wellness, stress management and career counselling.',
    },
    {
      'name': 'Dr. Priya Sharma',
      'spec': 'Psychiatrist',
      'rating': '4.8',
      'exp': '11 Yrs',
      'fee': '₹1000',
      'available': true,
      'color': AppColors.accentGreen,
      'initials': 'PS',
      'patients': '410+',
      'about':
          'Experienced in child and adolescent psychiatry and family therapy.',
    },
    {
      'name': 'Dr. Arjun Das',
      'spec': 'Therapist',
      'rating': '4.5',
      'exp': '6 Yrs',
      'fee': '₹550',
      'available': false,
      'color': AppColors.accentTeal,
      'initials': 'AD',
      'patients': '160+',
      'about': 'Specialises in grief counselling, PTSD and somatic therapy.',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _doctors.where((d) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          d['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          d['spec'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesFilter = _selectedFilter == 0
          ? true
          : _selectedFilter == 1
          ? d['available'] == true
          : d['spec'].toString().contains(_filters[_selectedFilter]);

      return matchesSearch && matchesFilter;
    }).toList();
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

          // ── Search Bar ──────────────────────────────────────
          SliverToBoxAdapter(child: _buildSearchBar(hPad)),

          // ── Filter Chips ────────────────────────────────────
          SliverToBoxAdapter(child: _buildFilters(hPad)),

          // ── Stats Row ───────────────────────────────────────
          SliverToBoxAdapter(child: _buildStatsRow(hPad, isMobile)),

          // ── Doctor List ─────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
            sliver: _filtered.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) =>
                          _DoctorCard(doc: _filtered[i], isMobile: isMobile),
                      childCount: _filtered.length,
                    ),
                  ),
          ),

          // ── Bottom spacing ───────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ),
        ],
      ),
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
                'Find a Doctor',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Book your session in minutes',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Sort icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, color: AppColors.mutedText, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search doctors, specialties...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _searchQuery = ''),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.mutedText,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(double hPad) {
    return Padding(
      padding: EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          itemCount: _filters.length,
          itemBuilder: (_, i) {
            final active = _selectedFilter == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    _filters[i],
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

  Widget _buildStatsRow(double hPad, bool isMobile) {
    final available = _doctors.where((d) => d['available'] == true).length;
    final stats = [
      {
        'label': 'Total Doctors',
        'value': '${_doctors.length}',
        'icon': Icons.people_rounded,
        'color': AppColors.primaryColor,
        'bg': AppColors.primarySurface,
      },
      {
        'label': 'Available Now',
        'value': '$available',
        'icon': Icons.check_circle_rounded,
        'color': AppColors.accentGreen,
        'bg': Color(0xFFDCFCE7),
      },
      {
        'label': 'Specialties',
        'value': '6+',
        'icon': Icons.medical_services_rounded,
        'color': AppColors.accentPurple,
        'bg': Color(0xFFEDE9FB),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No doctors found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

// ── Doctor Card ────────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final bool isMobile;

  const _DoctorCard({required this.doc, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final color = doc['color'] as Color;
    final isAvail = doc['available'] as bool;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: isMobile ? 60 : 70,
                  height: isMobile ? 60 : 70,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      doc['initials'],
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doc['name'],
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          // Availability badge
                          _AvailabilityBadge(isAvail: isAvail),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doc['spec'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating row
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            doc['rating'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.borderColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.work_history_rounded,
                            size: 13,
                            color: AppColors.mutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doc['exp'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.borderColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.people_rounded,
                            size: 13,
                            color: AppColors.mutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doc['patients'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // About
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                doc['about'],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.labelColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Footer row
            Row(
              children: [
                // Fee
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
                      doc['fee'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorBookingPage(doc: doc),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
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
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool isAvail;
  const _AvailabilityBadge({required this.isAvail});

  @override
  Widget build(BuildContext context) {
    if (isAvail) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Available',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Unavailable',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.dangerDark,
          ),
        ),
      );
    }
  }
}
