import 'package:frontend/modules/doctor/screens/patients/patients_profile_page.dart';
import 'package:flutter/material.dart';

class _PatientData {
  final String name;
  final int age;
  final String lastSession;
  final bool isHighPriority;
  final List<String> tags;
  final Color avatarColor;
  final String initials;

  const _PatientData({
    required this.name,
    required this.age,
    required this.lastSession,
    required this.isHighPriority,
    required this.tags,
    required this.avatarColor,
    required this.initials,
  });
}

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All Patients';

  final List<String> _filters = [
    'All Patients',
    'Anxiety',
    'Depression',
    'PTSD',
    'OCD',
    'Bipolar II',
    'ADHD',
    'Sleep Disorder',
  ];

  final List<_PatientData> _allPatients = const [
    _PatientData(
      name: 'Elena Rodriguez',
      age: 34,
      lastSession: 'OCT 24, 2023',
      isHighPriority: true,
      tags: ['Anxiety', 'OCD'],
      avatarColor: Color(0xFF6366F1),
      initials: 'ER',
    ),
    _PatientData(
      name: 'Marcus Chen',
      age: 52,
      lastSession: 'OCT 21, 2023',
      isHighPriority: false,
      tags: ['Depression', 'Sleep Disorder'],
      avatarColor: Color(0xFF0EA5E9),
      initials: 'MC',
    ),
    _PatientData(
      name: 'Sarah Jenkins',
      age: 28,
      lastSession: 'OCT 19, 2023',
      isHighPriority: false,
      tags: ['PTSD'],
      avatarColor: Color(0xFFF59E0B),
      initials: 'SJ',
    ),
    _PatientData(
      name: 'David Miller',
      age: 41,
      lastSession: 'OCT 15, 2023',
      isHighPriority: true,
      tags: ['Bipolar II', 'ADHD'],
      avatarColor: Color(0xFF10B981),
      initials: 'DM',
    ),
  ];

  List<_PatientData> get _filteredPatients {
    final query = _searchController.text.toLowerCase();
    return _allPatients.where((p) {
      final matchesSearch =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.tags.any((t) => t.toLowerCase().contains(query));
      final matchesFilter =
          _selectedFilter == 'All Patients' || p.tags.contains(_selectedFilter);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color _tagBgColor(String tag) {
    switch (tag) {
      case 'Anxiety':
        return const Color(0xFFDBEAFE);
      case 'OCD':
        return const Color(0xFFE0E7FF);
      case 'Depression':
        return const Color(0xFFD1FAE5);
      case 'Sleep Disorder':
        return const Color(0xFFDDD6FE);
      case 'PTSD':
        return const Color(0xFFFEF3C7);
      case 'Bipolar II':
        return const Color(0xFFFFE4E6);
      case 'ADHD':
        return const Color(0xFFCCFBF1);
      default:
        return AppColors.bgColor;
    }
  }

  Color _tagTextColor(String tag) {
    switch (tag) {
      case 'Anxiety':
        return const Color(0xFF1E40AF);
      case 'OCD':
        return const Color(0xFF3730A3);
      case 'Depression':
        return const Color(0xFF065F46);
      case 'Sleep Disorder':
        return const Color(0xFF5B21B6);
      case 'PTSD':
        return const Color(0xFF92400E);
      case 'Bipolar II':
        return const Color(0xFF9F1239);
      case 'ADHD':
        return const Color(0xFF115E59);
      default:
        return const Color(0xFF475569);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 15, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: 'Search patients by name or ID...',
          hintStyle: const TextStyle(
            color: AppColors.softMuted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.mutedText,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.labelColor,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityBadge(bool isHighPriority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighPriority ? const Color(0xFFFEE2E2) : AppColors.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighPriority
              ? const Color(0xFFFCA5A5)
              : AppColors.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHighPriority)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: const BoxDecoration(
                color: AppColors.dangerRed,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            isHighPriority ? 'HIGH\nPRIORITY' : 'ROUTINE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isHighPriority
                  ? AppColors.dangerDark
                  : AppColors.labelColor,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _tagBgColor(tag),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: _tagTextColor(tag),
        ),
      ),
    );
  }

  Widget _buildPatientCard(_PatientData patient) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: patient.isHighPriority
            ? Border.all(color: const Color(0xFFFCA5A5).withValues(alpha: 0.4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: patient.avatarColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: patient.avatarColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    patient.initials,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: patient.avatarColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${patient.name}, ${patient.age}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPriorityBadge(patient.isHighPriority),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LAST SESSION: ${patient.lastSession}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.labelColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: patient.tags.map((t) => _buildConditionTag(t)).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientsProfilePage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.borderColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.inputBg.withValues(alpha: 0.5),
              ),
              child: const Text(
                'View Full Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_outlined,
              size: 36,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No patients found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filters.',
            style: TextStyle(fontSize: 13, color: AppColors.labelColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patients = _filteredPatients;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Clinical Sanctuary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: Color(0xFF475569),
                          ),
                          Positioned(
                            top: 8,
                            right: 9,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.dangerRed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search + Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 14),
                  _buildFilterChips(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Patient List
            Expanded(
              child: patients.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        return _buildPatientCard(patients[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
