import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/user/presentation/provider/user_profile_provider.dart';
import 'package:frontend/modules/user/presentation/router/main_user_layout.dart';
import 'package:frontend/modules/user/presentation/screens/quiz/wellness_intro_screen.dart';
import 'package:intl/intl.dart';

class UserRegistrationPage extends ConsumerStatefulWidget {
  const UserRegistrationPage({super.key});

  @override
  ConsumerState<UserRegistrationPage> createState() =>
      _UserRegistrationPageState();
}

class _UserRegistrationPageState extends ConsumerState<UserRegistrationPage> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl   = TextEditingController();

  bool   _agreed         = false;
  String _selectedGender = 'Male';
  String _selectedDob    = '';

  bool _phoneTouched  = false;
  bool _dobTouched    = false;
  bool _agreedTouched = false;

  // Loaded from SharedPreferences — no API call needed
  late String _name;
  late String _email;

  final _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    // Read directly from SharedPreferences — already saved at register
    final info = ref.read(userProfileProvider.notifier).getBasicInfo();
    _name  = info.name;
    _email = info.email;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  // ── DOB picker ────────────────────────────────────────────────────────────
  Future<void> _pickDob() async {
    final now     = DateTime.now();
    final picked  = await showDatePicker(
      context:     context,
      initialDate: DateTime(now.year - 25),
      firstDate:   DateTime(now.year - 100),
      lastDate:    DateTime(now.year - 10),
      helpText:    'Select Date of Birth',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   AppColors.primaryColor,
            onPrimary: AppColors.white,
            surface:   AppColors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _dobTouched  = true;
        _selectedDob = DateFormat('yyyy-MM-dd').format(picked);
        _dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // ── Handle state changes ──────────────────────────────────────────────────
  void _handleProfileState(UserProfileState? previous, UserProfileState next) {
    if (!mounted) return;

    if (next is UserProfileSuccess) {
      // authProvider.completeProfile() already called inside provider
      // Just navigate
      _goToWellness();
    }

    if (next is UserProfileError) {
      _showSnack(next.message, isError: true);
      ref.read(userProfileProvider.notifier).clearError();
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _submit() {
    setState(() {
      _phoneTouched  = true;
      _dobTouched    = true;
      _agreedTouched = true;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDob.isEmpty) {
      _showSnack('Please select your date of birth.', isError: true);
      return;
    }
    if (!_agreed) {
      _showSnack('Please accept the Terms & Conditions.', isError: true);
      return;
    }

    ref.read(userProfileProvider.notifier).submitProfile(
      phone:  _phoneCtrl.text.trim(),
      dob:    _selectedDob,
      gender: _selectedGender,
      agreed: _agreed,
    );
  }

  // ── Navigation — only reachable after API success ─────────────────────────
  void _goToWellness() {
    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute(
        WellnessIntroScreen(
          onSkip:     () => _goToHome(),
          onComplete: (_) => _goToHome(),
        ),
      ),
      (route) => false,
    );
  }

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute(const MainUserLayout()),
      (route) => false,
    );
  }

  // ── Back guard ────────────────────────────────────────────────────────────
  Future<bool> _onWillPop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Leave setup?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Your profile is not complete yet.\n'
          'You must finish setup before using the app.',
          style: TextStyle(color: AppColors.mutedText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.dangerRed),
            ),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:         Text(msg),
          backgroundColor: isError
              ? AppColors.dangerRed
              : AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder:        (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child:   child,
        ),
      );

  bool get _isFormComplete =>
      _phoneCtrl.text.trim().length >= 7 &&
      _selectedDob.isNotEmpty &&
      _agreed;

  @override
  Widget build(BuildContext context) {
    ref.listen<UserProfileState>(userProfileProvider, _handleProfileState);

    final profileState = ref.watch(userProfileProvider);
    final isLoading    = profileState is UserProfileLoading;
    final isMobile     = Responsive.isMobile(context);
    final firstName    = _name.split(' ').first.isEmpty
        ? 'there'
        : _name.split(' ').first;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // ── Background gradient ──────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                height: 250,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin:  Alignment.topLeft,
                      end:    Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // ── Progress bar ─────────────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Step 2 of 2 — Complete Profile',
                          style: TextStyle(
                            fontSize:   11,
                            color:      AppColors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:           _isFormComplete ? 1.0 : 0.5,
                            backgroundColor: AppColors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.white,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main content ─────────────────────────────
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top:    isMobile ? 100 : 120,
                    bottom: 40,
                    left:   Responsive.horizontalPadding(context),
                    right:  Responsive.horizontalPadding(context),
                  ),
                  child: Container(
                    width: isMobile ? double.infinity : 480,
                    padding: EdgeInsets.all(isMobile ? 24 : 32),
                    decoration: BoxDecoration(
                      color:        AppColors.white,
                      borderRadius: BorderRadius.circular(
                        Responsive.cardRadius(context),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:        AppColors.darkText.withOpacity(0.08),
                          blurRadius:   30,
                          spreadRadius: 4,
                          offset:       const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize:       MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(firstName),
                          SizedBox(height: Responsive.sectionSpacing(context)),

                          // ── Read-only: Email ──────────────
                          _label('Email Address'),
                          const SizedBox(height: 6),
                          _buildReadOnlyField(
                            value: _email.isEmpty ? 'Not available' : _email,
                            icon:  Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),

                          // ── Read-only: Full name ──────────
                          _label('Full Name'),
                          const SizedBox(height: 6),
                          _buildReadOnlyField(
                            value: _name.isEmpty ? 'Not available' : _name,
                            icon:  Icons.person_outline_rounded,
                          ),

                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 20),

                          // ── Phone ─────────────────────────
                          _label('Phone Number *'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller:   _phoneCtrl,
                            hint:         '+91 98765 43210',
                            icon:         Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-\s()]'),
                              ),
                            ],
                            onChanged: (_) =>
                                setState(() => _phoneTouched = true),
                            validator: (v) {
                              if (!_phoneTouched) return null;
                              if (v!.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              if (v.trim().length < 7) {
                                return 'Enter a valid phone number';
                              }
                              if (!RegExp(r'^[0-9+\-\s()]+$')
                                  .hasMatch(v.trim())) {
                                return 'Invalid characters in phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // ── Date of Birth ──────────────────
                          _label('Date of Birth *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _dobCtrl,
                            readOnly:   true,
                            onTap:      _pickDob,
                            validator: (v) {
                              if (!_dobTouched) return null;
                              if (_selectedDob.isEmpty) {
                                return 'Date of birth is required';
                              }
                              return null;
                            },
                            style: const TextStyle(
                              fontSize:   14,
                              fontWeight: FontWeight.w500,
                              color:      AppColors.darkText,
                            ),
                            decoration: InputDecoration(
                              hintText:  'Select your date of birth',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color:    AppColors.mutedText,
                              ),
                              filled:    true,
                              fillColor: AppColors.bgColor,
                              prefixIcon: const Icon(
                                Icons.cake_outlined,
                                size:  18,
                                color: AppColors.primaryColor,
                              ),
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size:  18,
                                color: AppColors.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:   BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.dangerRed,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Gender ─────────────────────────
                          _label('Gender *'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value:     _selectedGender,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v!),
                            decoration: InputDecoration(
                              filled:    true,
                              fillColor: AppColors.bgColor,
                              prefixIcon: const Icon(
                                Icons.wc_rounded,
                                size:  18,
                                color: AppColors.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:   BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize:   14,
                              fontWeight: FontWeight.w500,
                              color:      AppColors.darkText,
                            ),
                            dropdownColor: AppColors.white,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.mutedText,
                            ),
                            items: _genders
                                .map((g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 24),

                          // ── Terms ──────────────────────────
                          _buildTermsCheckbox(),

                          if (_agreedTouched && !_agreed) ...[
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size:  13,
                                  color: AppColors.dangerRed,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'You must accept the Terms & Conditions',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:    AppColors.dangerRed,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          SizedBox(height: Responsive.sectionSpacing(context)),

                          // ── Submit ─────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor:
                                    AppColors.primaryColor.withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width:  20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color:       AppColors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Complete Profile',
                                      style: TextStyle(
                                        fontSize:   15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              '* All fields are required',
                              style: TextStyle(
                                fontSize: 11,
                                color:    AppColors.mutedText,
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
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _buildHeader(String firstName) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.waving_hand_rounded,
            size:  32,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome, $firstName!',
          style: const TextStyle(
            fontSize:   24,
            fontWeight: FontWeight.w800,
            color:      AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "You're almost there! Complete your profile\nto start using the app.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color:    AppColors.mutedText,
            height:   1.4,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w600,
          color:      AppColors.darkText,
        ),
      );

  Widget _buildReadOnlyField({
    required String   value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly:     true,
      style: TextStyle(
        fontSize:   14,
        fontWeight: FontWeight.w500,
        color:      AppColors.darkText.withOpacity(0.6),
      ),
      decoration: InputDecoration(
        filled:     true,
        fillColor:  AppColors.bgColor.withOpacity(0.5),
        prefixIcon: Icon(icon, size: 18, color: AppColors.mutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController     controller,
    required String                    hint,
    required IconData                  icon,
    TextInputType                      keyboardType     = TextInputType.text,
    List<TextInputFormatter>?          inputFormatters,
    String? Function(String?)?         validator,
    void Function(String)?             onChanged,
  }) {
    return TextFormField(
      controller:      controller,
      keyboardType:    keyboardType,
      inputFormatters: inputFormatters,
      validator:       validator,
      onChanged:       onChanged,
      style: const TextStyle(
        fontSize:   14,
        fontWeight: FontWeight.w500,
        color:      AppColors.darkText,
      ),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: const TextStyle(
          fontSize: 13, color: AppColors.mutedText,
        ),
        filled:    true,
        fillColor: AppColors.bgColor,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dangerRed),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dangerRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14,
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _agreedTouched && !_agreed
            ? AppColors.dangerRed.withOpacity(0.05)
            : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _agreedTouched && !_agreed
              ? AppColors.dangerRed.withOpacity(0.4)
              : AppColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24, height: 24,
            child: Checkbox(
              value:       _agreed,
              activeColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (v) => setState(() {
                _agreed        = v ?? false;
                _agreedTouched = true;
              }),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _agreed        = !_agreed;
                _agreedTouched = true;
              }),
              child: const Text.rich(
                TextSpan(
                  text:  'I have read and agree to the ',
                  style: TextStyle(
                    fontSize: 12,
                    color:    AppColors.darkText,
                    height:   1.4,
                  ),
                  children: [
                    TextSpan(
                      text:  'Terms & Conditions',
                      style: TextStyle(
                        color:      AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text:  'Privacy Policy',
                      style: TextStyle(
                        color:      AppColors.primaryColor,
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
    );
  }
}