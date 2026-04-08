import 'package:frontend/modules/user/widgets/text_section.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class DoctorsSection extends StatelessWidget {
  const DoctorsSection({super.key});

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
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        hPad,
        Responsive.sectionSpacing(context),
        0,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSection(
            title: 'Top Psychiatrists',
            actionLabel: 'View all',
            onActionTap: () {},
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isMobile ? 230 : 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _doctors.length,
              padding: EdgeInsets.only(right: hPad),
              itemBuilder: (_, i) =>
                  _DoctorCard(doc: _doctors[i], isMobile: isMobile),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final bool isMobile;

  const _DoctorCard({required this.doc, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final color = doc['color'] as Color;
    final isAvail = doc['available'] as bool;
    final cardWidth = isMobile ? 165.0 : 190.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 14),
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
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Availability badge
            _buildAvailabilityBadge(isAvail),
            const SizedBox(height: 10),
            // Avatar
            Container(
              width: isMobile ? 56 : 64,
              height: isMobile ? 56 : 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  doc['initials'],
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              doc['name'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              doc['spec'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Rating & experience
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: AppColors.borderColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  doc['exp'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Fee + Book button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Fee',
                      style: TextStyle(fontSize: 9, color: AppColors.softMuted),
                    ),
                    Text(
                      doc['fee'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(
                        fontSize: 11,
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

  Widget _buildAvailabilityBadge(bool isAvail) {
    if (isAvail) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Available Now',
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
