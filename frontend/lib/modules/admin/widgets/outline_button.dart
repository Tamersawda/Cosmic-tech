import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool selected;

  const CustomOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primaryColor : Colors.transparent,
        foregroundColor: selected ? Colors.white : AppColors.textColor,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
          color: selected ? AppColors.primaryColor : AppColors.textColor,
          width: 1.2,
        ),
      ),
      child: Text(text),
    );
  }
}
