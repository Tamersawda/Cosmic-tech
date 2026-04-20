import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:flutter/material.dart';

/// Standalone page that lists all medical history entries for a patient.
class FullHistoryPage extends StatelessWidget {
  final String patientName;
  final String initials;
  final Color avatarColor;
  final List<String> history;

  const FullHistoryPage({
    super.key,
    required this.patientName,
    required this.initials,
    required this.avatarColor,
    required this.history,
  });

  static const _colors = [
    AppColors.primaryColor,
    AppColors.accentPurple,
    AppColors.dangerRed,
    AppColors.accentAmber,
    AppColors.accentTeal,
  ];

  static const _bgs = [
    AppColors.primarySurface,
    Color(0xFFEDE9FB),
    Color(0xFFFFEEEE),
    Color(0xFFFFF4E6),
    Color(0xFFE0F7FA),
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.fromLTRB(
                hPad,
                MediaQuery.of(context).padding.top + 10,
                hPad,
                16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Medical History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── History list ───────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.all(hPad),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((_, i) {
                final c = _colors[i % _colors.length];
                final bg = _bgs[i % _bgs.length];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_hospital_rounded,
                          color: c,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              history[i],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Recorded in medical history',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Chronic',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: c,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: history.length),
            ),
          ),
        ],
      ),
    );
  }
}
