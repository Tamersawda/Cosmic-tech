import 'package:flutter/material.dart';
import 'package:frontend/core/utils/colors.dart';

class DoctorFieldLabel extends StatelessWidget {
  final String text;

  const DoctorFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.labelColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class DoctorTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? prefix;
  final String? suffixText;
  final bool enabled;
  final bool filled;
  final Color? fillColor;
  final FormFieldValidator<String>? validator;

  const DoctorTextField({
    super.key,
    this.controller,
    required this.hint,
    this.keyboardType,
    this.suffix,
    this.prefix,
    this.suffixText,
    this.enabled = true,
    this.filled = true,
    this.fillColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.darkText,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.softMuted,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          fontSize: 15,
          color: AppColors.darkText,
          fontWeight: FontWeight.w600,
        ),
        suffixText: suffixText,
        suffixStyle: const TextStyle(fontSize: 13, color: AppColors.labelColor),
        suffixIcon: suffix,
        filled: filled,
        fillColor:
            fillColor ??
            (enabled
                ? AppColors.inputBg
                : AppColors.inputBg.withValues(alpha: 0.5)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class DoctorUnderlineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const DoctorUnderlineTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: AppColors.darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hintColor, fontSize: 15),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}

class DoctorLabeledField extends StatelessWidget {
  final String label;
  final Widget field;

  const DoctorLabeledField({
    super.key,
    required this.label,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [DoctorFieldLabel(label), field, const SizedBox(height: 16)],
    );
  }
}
