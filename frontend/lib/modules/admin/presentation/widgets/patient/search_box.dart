import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffe5e7eb)),
        borderRadius: BorderRadius.circular(10),
      ),

      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: "Search...",
        ),
      ),
    );
  }
}
