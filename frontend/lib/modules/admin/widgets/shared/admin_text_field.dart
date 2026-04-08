import 'package:flutter/material.dart';

class AdminTextField extends StatelessWidget {
  final String? topLabel; // The text to display above the input field
  final String? label; // The floating label inside the input field
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final int maxLines;
  final Function(String)? onChanged;

  // Styling overrides
  final bool? filled;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final EdgeInsetsGeometry? contentPadding;

  const AdminTextField({
    super.key,
    this.topLabel,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.maxLines = 1,
    this.onChanged,
    this.filled,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    Widget field = TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        filled: filled,
        fillColor: fillColor,
        contentPadding: contentPadding,
        border:
            border ??
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
      ),
    );

    if (topLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topLabel!, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          field,
        ],
      );
    }
    return field;
  }
}
