import 'package:frontend/modules/user/router/main_user_layout.dart';
import 'package:frontend/modules/user/screens/quiz/wellness_intro_screen.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/responsive_data.dart';

class UserRegistrationPage extends StatefulWidget {
  final String name;
  final String email;

  const UserRegistrationPage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  bool _isLoading = false;
  bool _agreed = false;
  String _selectedGender = 'Male';
  final _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      _showSnack('Please accept the Terms & Conditions', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    // Simulate network delay for completing registration
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => WellnessIntroScreen(
          onSkip: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainUserLayout()),
              (r) => false,
            );
          },
          onComplete: (result) {
            // 👉 Save result here (important)
            // Example: save to local storage / state

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainUserLayout()),
              (r) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.dangerRed : AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    // Extract first name for a friendly greeting if possible.
    String firstName = widget.name.split(' ').first;
    if (firstName.isEmpty) firstName = "there";

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background Header Decoration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 250,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Back Button (If they want to change their email/password)
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: isMobile ? 80 : 100,
                  bottom: 40,
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  width: isMobile ? double.infinity : 480,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkText.withOpacity(0.08),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(firstName),
                        const SizedBox(height: 32),

                        // ── Read Only Fields ─────────────────────────────────
                        _label('Email Address'),
                        const SizedBox(height: 6),
                        _buildReadOnlyField(
                          value: widget.email.isEmpty
                              ? "No email provided"
                              : widget.email,
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),

                        _label('Full Name'),
                        const SizedBox(height: 6),
                        _buildReadOnlyField(
                          value: widget.name.isEmpty
                              ? "No name provided"
                              : widget.name,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 20),

                        // ── Editable Fields ─────────────────────────────────
                        _label('Phone Number'),
                        const SizedBox(height: 6),
                        _buildField(
                          controller: _phoneCtrl,
                          hint: '+1 234 567 890',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.trim().isEmpty
                              ? 'Phone number is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        _label('Age'),
                        const SizedBox(height: 6),
                        _buildField(
                          controller: _ageCtrl,
                          hint: 'Enter your age',
                          icon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Age is required';
                            }
                            final age = int.tryParse(v);
                            if (age == null) return 'Enter a valid number';
                            if (age < 10 || age > 100) {
                              return 'Enter a valid age';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _label('Gender'),
                        const SizedBox(height: 6),
                        _buildGenderField(),

                        const SizedBox(height: 24),

                        // ── Terms & Conditions ──────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreed,
                                  activeColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _agreed = v ?? false),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _agreed = !_agreed),
                                  child: const Text.rich(
                                    TextSpan(
                                      text:
                                          'By checking this box, I acknowledge that I have read and agree to the ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.darkText,
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Submit Button ──────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Complete Profile Formulation',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _buildHeader(String firstName) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.waving_hand_rounded,
            size: 32,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Welcome, $firstName!",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "You're almost there! We just need a few more details to set up your account properly.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
  );

  Widget _buildReadOnlyField({required String value, required IconData icon}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText.withOpacity(0.6),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bgColor.withOpacity(0.5),
        prefixIcon: Icon(icon, size: 18, color: AppColors.mutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedText),
        filled: true,
        fillColor: AppColors.bgColor,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dangerRed),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.bgColor,
        prefixIcon: const Icon(
          Icons.wc_rounded,
          size: 18,
          color: AppColors.primaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      dropdownColor: AppColors.white,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.mutedText,
      ),
      items: _genders
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (v) => setState(() => _selectedGender = v!),
    );
  }
}
