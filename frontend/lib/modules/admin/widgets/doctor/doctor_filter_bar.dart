import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class DoctorFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function(String) onSearchChanged;
  final int doctorCount;

  const DoctorFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.doctorCount,
  });

  final List<String> filters = const ["All", "Approved", "Pending"];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double searchWidth = 320;

        if (constraints.maxWidth < 600) {
          searchWidth = double.infinity;
        } else if (constraints.maxWidth < 900) {
          searchWidth = 250;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xfff3f4f6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              /// SEARCH
              SizedBox(
                width: searchWidth,
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search doctor name...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              /// FILTER ICON
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.filter_list),
              ),

              /// STATUS FILTER
              ...filters.map((filter) {
                final isSelected = selectedFilter == filter;

                return GestureDetector(
                  onTap: () => onFilterChanged(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),

              /// COUNT
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "$doctorCount doctors",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
