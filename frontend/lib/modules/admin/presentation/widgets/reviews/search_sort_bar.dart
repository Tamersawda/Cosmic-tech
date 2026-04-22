import 'package:flutter/material.dart';

class SearchSortBar extends StatelessWidget {
  final String search;
  final String sortOption;
  final Function(String) onSearch;
  final Function(String) onSortChanged;

  const SearchSortBar({
    super.key,
    required this.search,
    required this.sortOption,
    required this.onSearch,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffe5e7eb)),
            ),
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: "Search patient or doctor",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        /// SORT LABEL
        const Text(
          "Sort by:",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),

        const SizedBox(width: 10),

        /// SORT DROPDOWN
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xffe5e7eb)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),

          child: DropdownButton<String>(
            value: sortOption,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down),

            items: const [
              DropdownMenuItem(
                value: "Highest Rating",
                child: Text("Highest Rating"),
              ),

              DropdownMenuItem(
                value: "Lowest Rating",
                child: Text("Lowest Rating"),
              ),

              DropdownMenuItem(value: "Newest", child: Text("Newest")),

              DropdownMenuItem(value: "Oldest", child: Text("Oldest")),
            ],

            onChanged: (v) => onSortChanged(v!),
          ),
        ),
      ],
    );
  }
}
