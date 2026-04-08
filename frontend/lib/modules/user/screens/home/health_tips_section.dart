import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class HealthTipsSection extends StatelessWidget {
  const HealthTipsSection({super.key});

  static const List<Map<String, dynamic>> _tips = [
    {
      'icon': Icons.water_drop_rounded,
      'label': 'Stay\nHydrated',
      'color': AppColors.primaryColor,
      'bg': AppColors.primarySurface,
    },
    {
      'icon': Icons.bedtime_rounded,
      'label': 'Sleep\n8 Hours',
      'color': AppColors.accentPurple,
      'bg': Color(0xFFEDE9FB),
    },
    {
      'icon': Icons.air_rounded,
      'label': 'Deep\nBreathing',
      'color': AppColors.accentSky,
      'bg': Color(0xFFE8F6FD),
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
        hPad,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY TIPS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedText,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _tips.asMap().entries.map((entry) {
              final i = entry.key;
              final t = entry.value;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < _tips.length - 1 ? 12 : 0),
                  padding: EdgeInsets.all(isMobile ? 14 : 18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: t['bg'] as Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          t['icon'] as IconData,
                          color: t['color'] as Color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t['label'] as String,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
