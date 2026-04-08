import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class DoctorEditProfessionalPage extends StatefulWidget {
  const DoctorEditProfessionalPage({super.key});

  @override
  State<DoctorEditProfessionalPage> createState() =>
      _DoctorEditProfessionalPageState();
}

class _DoctorEditProfessionalPageState
    extends State<DoctorEditProfessionalPage> {
  String? _selectedSpecialty = 'Psychiatry';
  String? _selectedCouncil   = 'National Medical Commission (NMC)';
  int _yearsOfExperience     = 8;
  bool _isSaving             = false;

  final _subSpecCtrl   = TextEditingController(text: 'Child & Adolescent Psychiatry');
  final _regNumberCtrl = TextEditingController(text: 'NMC-78432');
  final _langInput     = TextEditingController();

  final List<String> _languages = ['ENGLISH', 'HINDI'];

  final List<String> _specialties = [
    'Cardiology', 'Dermatology', 'Emergency Medicine', 'Family Medicine',
    'Gastroenterology', 'General Medicine', 'Neurology', 'Oncology',
    'Orthopedics', 'Pediatrics', 'Psychiatry', 'Radiology',
    'Surgery', 'Urology', 'Other',
  ];

  final List<String> _councils = [
    'Medical Council of India (MCI)',
    'National Medical Commission (NMC)',
    'American Medical Association (AMA)',
    'General Medical Council (GMC)',
    'Royal College of Physicians',
    'Other',
  ];

  @override
  void dispose() {
    _subSpecCtrl.dispose();
    _regNumberCtrl.dispose();
    _langInput.dispose();
    super.dispose();
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

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Professional details updated'),
      backgroundColor: AppColors.accentGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [

          // ── Specialization ─────────────────────────────────────────────────
          _sectionHeader('Specialization',
              Icons.medical_services_outlined, AppColors.primaryColor),
          _card([
            _dropdown(
              hint:      'Primary Specialization',
              value:     _selectedSpecialty,
              icon:      Icons.local_hospital_outlined,
              items:     _specialties,
              onChanged: (v) => setState(() => _selectedSpecialty = v),
            ),
            const Divider(height: 1, color: AppColors.borderColor),
            _textField(
              ctrl: _subSpecCtrl,
              hint: 'Sub-Specialization (optional)',
              icon: Icons.biotech_outlined,
            ),
          ]),

          const SizedBox(height: 16),

          // ── Licensing ──────────────────────────────────────────────────────
          _sectionHeader('Medical Licensing',
              Icons.verified_outlined, AppColors.accentTeal),
          _card([
            _textField(
              ctrl: _regNumberCtrl,
              hint: 'Registration Number (e.g. MCI-12345)',
              icon: Icons.badge_outlined,
            ),
            const Divider(height: 1, color: AppColors.borderColor),
            _dropdown(
              hint:      'Medical Council',
              value:     _selectedCouncil,
              icon:      Icons.account_balance_outlined,
              items:     _councils,
              onChanged: (v) => setState(() => _selectedCouncil = v),
            ),
          ]),

          const SizedBox(height: 16),

          // ── Experience ─────────────────────────────────────────────────────
          _sectionHeader('Experience & Languages',
              Icons.workspace_premium_outlined, const Color(0xFF7C3AED)),
          _card([
            // Experience stepper
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Years of Experience',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _stepBtn(Icons.remove, () {
                          if (_yearsOfExperience > 0) {
                            setState(() => _yearsOfExperience--);
                          }
                        }),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$_yearsOfExperience',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkText),
                              ),
                              const Text('years',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mutedText)),
                            ],
                          ),
                        ),
                        _stepBtn(Icons.add,
                            () => setState(() => _yearsOfExperience++)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.borderColor),

            // Languages
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Languages Spoken',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _langInput,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.darkText),
                          decoration: InputDecoration(
                            hintText: 'Type a language and press Add...',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: AppColors.mutedText),
                            filled: true,
                            fillColor: AppColors.bgColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
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
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Add',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
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
                          .map((lang) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.25)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(lang,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryColor)),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => setState(
                                          () => _languages.remove(lang)),
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 10,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ]),

          const SizedBox(height: 28),
          _saveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() => AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Professional Details',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText)),
            Text('Specialty, licensing & experience',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w400)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      );

  Widget _sectionHeader(String title, IconData icon, Color color) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText)),
          ],
        ),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: children),
      );

  Widget _textField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 13, color: AppColors.mutedText),
          prefixIcon:
              Icon(icon, size: 18, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );

  Widget _dropdown({
    required String hint,
    required String? value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.mutedText)),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon:
                Icon(icon, size: 18, color: AppColors.primaryColor),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          dropdownColor: AppColors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.mutedText),
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      );

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryColor),
        ),
      );

  Widget _saveButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isSaving
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
