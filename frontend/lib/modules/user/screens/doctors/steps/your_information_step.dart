import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class YourInformationStep extends StatefulWidget {
  const YourInformationStep({super.key});

  @override
  State<YourInformationStep> createState() => _YourInformationStepState();
}

class _YourInformationStepState extends State<YourInformationStep> {
  String? _selectedGender;

  final List<String> _genders = [
    'Male',
    'Female',
    'Non-Binary',
    'Other',
    'Prefer not to say',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please verify or update your details. This information helps your specialist prepare for the session.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedText,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // 1. Full Name
        _buildTextField(
          label: 'Full Name',
          initialValue: 'John Doe',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),

        // Row for Email and Phone if viewing on wider device, or Column for standard mobile
        _buildTextField(
          label: 'Email Address',
          initialValue: 'johndoe@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: 'Phone Number',
          initialValue: '+1 234 567 8900',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Row for Age and Gender
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildTextField(
                label: 'Age',
                initialValue: '28',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildGenderDropdown()),
          ],
        ),
        const SizedBox(height: 24),

        const Text(
          'Consultation Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),

        // Text Area for Primary Concern
        TextFormField(
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Primary reason for your visit (Optional)',
            alignLabelWithHint: true,
            hintText: 'Briefly describe what you would like to discuss...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.mutedText),
        prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      icon: const Icon(
        Icons.arrow_drop_down_rounded,
        color: AppColors.mutedText,
      ),
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(color: AppColors.mutedText),
        prefixIcon: const Icon(
          Icons.wc_rounded,
          color: AppColors.primaryColor,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
      items: _genders
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedGender = val;
        });
      },
    );
  }
}
