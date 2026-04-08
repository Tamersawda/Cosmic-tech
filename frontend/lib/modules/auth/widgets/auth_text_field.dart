import 'package:frontend/modules/auth/widgets/auth_form_label.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool showToggle;
  final String? Function(String?)? validator;
  final Color accentColor;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showToggle = false,
    this.validator,
    this.accentColor = AppColors.primaryColor,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AuthFormLabel(widget.label!),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscure,
          validator: widget.validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
            filled: true,
            fillColor: AppColors.bgColor,
            prefixIcon: Icon(
              widget.prefixIcon,
              size: 18,
              color: widget.accentColor,
            ),
            suffixIcon: widget.showToggle
                ? GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.mutedText,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.dangerRed),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.accentColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
