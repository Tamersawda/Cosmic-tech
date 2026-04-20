import 'dart:io';
import 'package:frontend/modules/doctor/screens/registration/professional_details.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_app_top_bar.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_bottom_navigation_bar.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_labeled_dropdown_button.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_labeled_text_field.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_onboarding_progress.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_section_card.dart';
import 'package:frontend/modules/doctor/widgets/registration/doctor_section_header.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/modules/doctor/router/onboarding_page_route.dart';

class BasicInformation extends StatefulWidget {
  const BasicInformation({super.key});

  @override
  State<BasicInformation> createState() => _BasicInformationState();
}

class _BasicInformationState extends State<BasicInformation> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  File? _profileImage;

  final _picker = ImagePicker();

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img != null) setState(() => _profileImage = File(img.path));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) =>
    '${d.year}'
    '${d.month.toString().padLeft(2, '0')} / '
    '${d.day.toString().padLeft(2, '0')} / '
  ;

  // ── Validators ────────────────────────────────────────────────────────────

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (v.trim().length < 10) return 'Enter a valid phone number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorTopBar(),

            const DoctorOnboardingProgress(
              currentStep: 1,
              stepTitle: 'Step 1: Basic Information',
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Let's start with your personal identity\nand contact details.",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mutedText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Profile Photo ─────────────────────
                      DoctorSectionCard(
                        child: Column(
                          children: [
                            _ProfilePhotoWidget(
                              image: _profileImage,
                              onTap: _pickImage,
                            ),
                            const SizedBox(height: 20),

                            DoctorLabeledField(
                              label: 'Full Name',
                              field: DoctorTextField(
                                controller: _nameCtrl,
                                hint: 'Dr. First Last',
                                fillColor: AppColors.inputBgLight,
                                validator: _requiredValidator,
                              ),
                            ),

                            // Gender
                            DoctorLabeledField(
                              label: 'Gender',
                              field: DoctorDropdownFormField(
                                value: _selectedGender,
                                hint: 'Select Gender',
                                items: _genderOptions,
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v),
                              ),
                            ),

                            // DOB
                            DoctorFieldLabel('Date of Birth'),
                            const SizedBox(height: 6),
                            _DatePickerTile(
                              selectedDate: _selectedDate,
                              formatted: _selectedDate != null
                                  ? _formatDate(_selectedDate!)
                                  : null,
                              onTap: _pickDate,
                            ),
                          ],
                        ),
                      ),

                      // ── Contact Information ───────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DoctorSectionHeader(
                              icon: Icons.alternate_email,
                              title: 'Contact Information',
                              iconColor: AppColors.accentTeal,
                            ),

                            DoctorLabeledField(
                              label: 'Email Address',
                              field: DoctorTextField(
                                controller: _emailCtrl,
                                hint: 'doctor@hospital.com',
                                keyboardType: TextInputType.emailAddress,
                                fillColor: AppColors.inputBgLight,
                                validator: _emailValidator,
                              ),
                            ),

                            DoctorLabeledField(
                              label: 'Phone Number',
                              field: DoctorTextField(
                                controller: _phoneCtrl,
                                hint: '+91 98765 43210',
                                keyboardType: TextInputType.phone,
                                fillColor: AppColors.inputBgLight,
                                validator: _phoneValidator,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Professional Address ──────────────
                      DoctorSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DoctorSectionHeader(
                              icon: Icons.location_on_outlined,
                              title: 'Clinic / Personal Address',
                              iconColor: AppColors.accentGreen,
                            ),

                            DoctorLabeledField(
                              label: 'Street Address',
                              field: DoctorTextField(
                                controller: _streetCtrl,
                                hint: '123 Medical Street, Suite 400',
                                fillColor: AppColors.inputBgLight,
                                validator: _requiredValidator,
                              ),
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: DoctorLabeledField(
                                    label: 'City',
                                    field: DoctorTextField(
                                      controller: _cityCtrl,
                                      hint: 'Bangalore',
                                      fillColor: AppColors.inputBgLight,
                                      validator: _requiredValidator,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DoctorLabeledField(
                                    label: 'State',
                                    field: DoctorTextField(
                                      controller: _stateCtrl,
                                      hint: 'Karnataka',
                                      fillColor: AppColors.inputBgLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: DoctorLabeledField(
                                    label: 'Country',
                                    field: DoctorTextField(
                                      controller: _countryCtrl,
                                      hint: 'India',
                                      fillColor: AppColors.inputBgLight,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DoctorLabeledField(
                                    label: 'Pincode',
                                    field: DoctorTextField(
                                      controller: _pincodeCtrl,
                                      hint: '560001',
                                      keyboardType: TextInputType.number,
                                      fillColor: AppColors.inputBgLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            DoctorBottomBar(
              showBack: false,
              nextLabel: 'Next Step',
              onNext: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    smoothOnboardingRoute(const ProfessionalDetails()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _ProfilePhotoWidget extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const _ProfilePhotoWidget({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.borderColor,
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    width: 2.5,
                  ),
                  image: image != null
                      ? DecorationImage(
                          image: FileImage(image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: image == null
                    ? const Icon(
                        Icons.person,
                        size: 52,
                        color: AppColors.hintColor,
                      )
                    : null,
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'PROFILE PHOTO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Tap to upload  •  JPEG / PNG  •  Max 5MB',
          style: TextStyle(fontSize: 11, color: AppColors.mutedText),
        ),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime? selectedDate;
  final String? formatted;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.selectedDate,
    required this.formatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDate = selectedDate != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasDate
                ? AppColors.primaryColor.withValues(alpha: 0.4)
                : AppColors.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 17,
              color: hasDate ? AppColors.primaryColor : AppColors.mutedText,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                formatted ?? 'DD / MM / YYYY',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                  color: hasDate ? AppColors.darkText : AppColors.hintColor,
                ),
              ),
            ),
            if (hasDate)
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
