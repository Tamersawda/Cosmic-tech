import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Styled search bar with a leading search icon and a trailing clear button.
/// Manages its own text state; notifies parent via [onChanged].
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: AppColors.mutedText,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (v) {
                setState(() {});
                widget.onChanged(v);
              },
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedText,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: _clear,
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.mutedText,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
