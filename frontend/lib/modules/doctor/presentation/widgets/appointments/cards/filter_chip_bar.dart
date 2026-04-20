import 'package:frontend/core/utils/colors.dart';
import 'package:flutter/material.dart';

/// Horizontally scrolling animated filter chip bar.
/// Pass [filters], [selected], and [onSelect] to control state externally.
class FilterChipBar extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;
  final double horizontalPadding;

  const FilterChipBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelect,
    this.horizontalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final active = selected == filters[i];
          return GestureDetector(
            onTap: () => onSelect(filters[i]),
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
                          color: AppColors.primaryColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  filters[i],
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
    );
  }
}
