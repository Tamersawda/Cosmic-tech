import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/doctor/screens/doctor_profile_page.dart';
import 'package:image_picker/image_picker.dart';

class DoctorEditPersonalInfoPage extends StatefulWidget {
  final DoctorProfileData data;

  const DoctorEditPersonalInfoPage({super.key, required this.data});

  @override
  State<DoctorEditPersonalInfoPage> createState() =>
      _DoctorEditPersonalInfoPageState();
}

class _DoctorEditPersonalInfoPageState
    extends State<DoctorEditPersonalInfoPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;

  File? _photo;
  bool _saving = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _nameCtrl    = TextEditingController(text: d.name);
    _bioCtrl     = TextEditingController(text: d.bio);
    _emailCtrl   = TextEditingController(text: d.email);
    _phoneCtrl   = TextEditingController(text: d.phone);
    _addressCtrl = TextEditingController(text: d.address);
    _cityCtrl    = TextEditingController(text: d.city);
    _stateCtrl   = TextEditingController(text: d.state);
    _countryCtrl = TextEditingController(text: d.country);
    _photo       = d.profilePhoto;
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _bioCtrl, _emailCtrl, _phoneCtrl,
      _addressCtrl, _cityCtrl, _stateCtrl, _countryCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final img = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (img != null) setState(() => _photo = File(img.path));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    final d = widget.data;
    d.name         = _nameCtrl.text.trim();
    d.bio          = _bioCtrl.text.trim();
    d.email        = _emailCtrl.text.trim();
    d.phone        = _phoneCtrl.text.trim();
    d.address      = _addressCtrl.text.trim();
    d.city         = _cityCtrl.text.trim();
    d.state        = _stateCtrl.text.trim();
    d.country      = _countryCtrl.text.trim();
    d.profilePhoto = _photo;
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal information updated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Photo ────────────────────────────────
            _PhotoSection(photo: _photo, onTap: _pickPhoto),
            const SizedBox(height: 20),

            // ── Basic ────────────────────────────────
            _SectionCard(
              title: 'BASIC INFORMATION',
              children: [
                _Field(label: 'Full Name', controller: _nameCtrl,
                    hint: 'Dr. First Last',
                    icon: Icons.person_outline_rounded),
                _FieldDivider(),
                _MultiLineField(
                  label: 'About / Bio',
                  controller: _bioCtrl,
                  hint: 'Describe your clinical background and expertise...',
                  maxLines: 5,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Contact ──────────────────────────────
            _SectionCard(
              title: 'CONTACT',
              children: [
                _Field(label: 'Email', controller: _emailCtrl,
                    hint: 'doctor@hospital.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                _FieldDivider(),
                _Field(label: 'Phone', controller: _phoneCtrl,
                    hint: '+91 98765 43210',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
              ],
            ),

            const SizedBox(height: 14),

            // ── Address ──────────────────────────────
            _SectionCard(
              title: 'CLINIC / HOSPITAL ADDRESS',
              children: [
                _Field(label: 'Street Address', controller: _addressCtrl,
                    hint: '123 Medical Street, Suite 400',
                    icon: Icons.location_on_outlined),
                _FieldDivider(),
                Row(
                  children: [
                    Expanded(
                      child: _Field(label: 'City', controller: _cityCtrl,
                          hint: 'Bangalore',
                          icon: Icons.apartment_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(label: 'State', controller: _stateCtrl,
                          hint: 'Karnataka',
                          icon: Icons.map_outlined),
                    ),
                  ],
                ),
                _FieldDivider(),
                _Field(label: 'Country', controller: _countryCtrl,
                    hint: 'India',
                    icon: Icons.public_outlined),
              ],
            ),

            const SizedBox(height: 28),

            _SaveButton(saving: _saving, onTap: _save),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const _BackButton(),
        title: const Text(
          'Personal Information',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      );
}

// ── DoctorEditProfessionalPage ────────────────────────────────────────────────

class DoctorEditProfessionalPage extends StatefulWidget {
  final DoctorProfileData data;

  const DoctorEditProfessionalPage({super.key, required this.data});

  @override
  State<DoctorEditProfessionalPage> createState() =>
      _DoctorEditProfessionalPageState();
}

class _DoctorEditProfessionalPageState
    extends State<DoctorEditProfessionalPage> {
  late final TextEditingController _specCtrl;
  late final TextEditingController _expCtrl;
  late final TextEditingController _regCtrl;
  late final TextEditingController _langCtrl;
  String? _selectedCouncil;
  final _langInput = TextEditingController();
  late List<String> _languages;
  bool _saving = false;

  final List<String> _councils = [
    'Medical Council of India (MCI)',
    'National Medical Commission (NMC)',
    'American Medical Association (AMA)',
    'General Medical Council (GMC)',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _specCtrl        = TextEditingController(text: d.specialty);
    _expCtrl         = TextEditingController(text: d.experience);
    _regCtrl         = TextEditingController(text: d.registrationNumber);
    _langCtrl        = TextEditingController(text: d.languages);
    _selectedCouncil = d.council;
    _languages       = d.languages
        .split(',')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _specCtrl.dispose(); _expCtrl.dispose();
    _regCtrl.dispose(); _langCtrl.dispose(); _langInput.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    final d = widget.data;
    d.specialty          = _specCtrl.text.trim();
    d.experience         = _expCtrl.text.trim();
    d.registrationNumber = _regCtrl.text.trim();
    d.council            = _selectedCouncil ?? d.council;
    d.languages          = _languages.join(', ');
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Professional details updated.')),
      );
    }
  }

  void _addLanguage() {
    final lang = _langInput.text.trim().toUpperCase();
    if (lang.isNotEmpty && !_languages.contains(lang)) {
      setState(() {
        _languages.add(lang);
        _langInput.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const _BackButton(),
        title: const Text('Professional Details',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SectionCard(
              title: 'SPECIALIZATION',
              children: [
                _Field(label: 'Primary Specialization', controller: _specCtrl,
                    hint: 'e.g. Internal Medicine',
                    icon: Icons.medical_services_outlined),
                _FieldDivider(),
                _Field(label: 'Years of Experience', controller: _expCtrl,
                    hint: '12',
                    icon: Icons.timeline_outlined,
                    keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'LICENSING',
              children: [
                _Field(label: 'Registration Number', controller: _regCtrl,
                    hint: 'KA-MED-2041',
                    icon: Icons.badge_outlined),
                _FieldDivider(),
                _DropdownField(
                  label: 'Medical Council',
                  value: _selectedCouncil,
                  items: _councils,
                  icon: Icons.account_balance_outlined,
                  onChanged: (v) => setState(() => _selectedCouncil = v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'LANGUAGES SPOKEN',
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _langInput,
                              decoration: InputDecoration(
                                hintText: 'Add a language...',
                                hintStyle: const TextStyle(
                                    color: AppColors.mutedText, fontSize: 13),
                                filled: true,
                                fillColor: AppColors.bgColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 1.5),
                                ),
                              ),
                              onSubmitted: (_) => _addLanguage(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _addLanguage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Add',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      if (_languages.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _languages
                              .map((l) => _LangChip(
                                    label: l,
                                    onRemove: () =>
                                        setState(() => _languages.remove(l)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _SaveButton(saving: _saving, onTap: _save),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  final File? photo;
  final VoidCallback onTap;

  const _PhotoSection({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySurface,
                  border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      width: 2.5),
                  image: photo != null
                      ? DecorationImage(
                          image: FileImage(photo!), fit: BoxFit.cover)
                      : null,
                ),
                child: photo == null
                    ? const Icon(Icons.person, size: 40,
                        color: AppColors.primaryColor)
                    : null,
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt,
                    size: 13, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap to change photo',
            style: TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderColor),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.labelColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 13, color: AppColors.mutedText),
            prefixIcon: Icon(icon, size: 17, color: AppColors.primaryColor),
            filled: true,
            fillColor: AppColors.bgColor,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
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
              borderSide:
                  const BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiLineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _MultiLineField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.labelColor)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 14, color: AppColors.darkText, height: 1.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 13, color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.bgColor,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: AppColors.primaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.labelColor)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    hint: const Text('Select...',
                        style: TextStyle(
                            color: AppColors.mutedText, fontSize: 13)),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.labelColor, size: 18),
                    items: items
                        .map((i) => DropdownMenuItem(
                            value: i, child: Text(i)))
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 14);
}

class _LangChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _LangChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close,
                  size: 10, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onTap;

  const _SaveButton({required this.saving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Text('Save Changes',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 16, color: AppColors.darkText),
      ),
    );
  }
}
