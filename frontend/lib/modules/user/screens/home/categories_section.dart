import 'package:frontend/modules/user/widgets/text_section.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/constants/responsive_data.dart';
import 'package:flutter/material.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.air_rounded,
      'label': 'Anxiety',
      'color': AppColors.primaryColor,
      'bg': AppColors.primarySurface,
      'selected': false,
    },
    {
      'icon': Icons.cloud_rounded,
      'label': 'Depression',
      'color': AppColors.accentPurple,
      'bg': Color(0xFFEDE9FB),
      'selected': true,
    },
    {
      'icon': Icons.bolt_rounded,
      'label': 'Stress',
      'color': AppColors.dangerRed,
      'bg': Color(0xFFFFEEEE),
      'selected': false,
    },
    {
      'icon': Icons.nightlight_round,
      'label': 'Sleep',
      'color': AppColors.accentSky,
      'bg': Color(0xFFE8F6FD),
      'selected': false,
    },
    {
      'icon': Icons.self_improvement_rounded,
      'label': 'Mindfulness',
      'color': AppColors.accentTeal,
      'bg': Color(0xFFE0F7FA),
      'selected': false,
    },
    {
      'icon': Icons.favorite_rounded,
      'label': 'Trauma',
      'color': AppColors.accentAmber,
      'bg': Color(0xFFFFF4E6),
      'selected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
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
          TextSection(
            title: 'Categories',
            actionLabel: 'See all',
            onActionTap: () {},
          ),
          const SizedBox(height: 14), // ← add this
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero, // ← add this
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 6 : (isTablet ? 4 : 3),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isDesktop ? 1.15 : 0.95,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) => _buildCategoryCard(_categories[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    final selected = cat['selected'] as bool;
    final color = cat['color'] as Color;
    final bg = cat['bg'] as Color;

    return GestureDetector(
      onTap: () => setState(() {
        for (var c in _categories) {
          c['selected'] = false;
        }
        cat['selected'] = true;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryColor : AppColors.borderColor,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primaryColor.withOpacity(0.28)
                  : Colors.black.withOpacity(0.05),
              blurRadius: selected ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.18) : bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                cat['icon'] as IconData,
                color: selected ? AppColors.white : color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cat['label'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
