import 'package:frontend/core/constants/api_constansts.dart';
import 'package:frontend/core/errors/app_exceptions.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/storage/shared_pref_service.dart';
import 'package:frontend/modules/auth/data/datasources/auth_api.dart';
import 'package:frontend/modules/auth/data/models/user_model.dart';

class AuthRepository {
  AuthRepository({AuthApi? authApi, SharedPrefService? prefs})
    : _api = authApi ?? AuthApi(),
      _prefs = prefs ?? SharedPrefService.instance;

  final AuthApi _api;
  final SharedPrefService _prefs;

  // ─── Validation ───────────────────────────────────────────────────────────
  String? _validateRegisterFields({
    required String name,
    required String email,
    required String password,
  }) {
    if (name.trim().isEmpty) return 'Full name is required.';
    if (name.trim().length < 2) return 'Name must be at least 2 characters.';
    if (!RegExp(r"^[a-zA-Z\s'\-\.]+$").hasMatch(name.trim())) {
      return 'Name can only contain letters, spaces, hyphens, or apostrophes.';
    }
    if (email.trim().isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      return 'Enter a valid email address.';
    }
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  String? _validateLoginFields({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      return 'Enter a valid email address.';
    }
    if (password.isEmpty) return 'Password is required.';
    return null;
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final error = _validateRegisterFields(
      name: name,
      email: email,
      password: password,
    );
    if (error != null) throw ServerException(error, statusCode: 0);

    final user = await _api.register(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      role: role,
    );

    // is_profile_completed comes from backend — always false on register
    await _prefs.saveUser(
      userId: user.userId,
      role: user.role,
      token: user.token,
      refreshToken: user.refreshToken,
      name: user.name,
      email: user.email,
      isProfileComplete: user.isProfileComplete, // false from backend
      onboardingStep: user.onboardingStep, // 0 from backend
    );

    return user;
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final error = _validateLoginFields(email: email, password: password);
    if (error != null) throw ServerException(error, statusCode: 0);

    final user = await _api.login(
      email: email.trim().toLowerCase(),
      password: password,
    );

    // Check profile status from backend response first
    // then cross-check with GET profile endpoint for accuracy
    bool isComplete = user.isProfileComplete;
    int step = user.onboardingStep;

    // If backend says not complete, double-check via GET endpoint
    // This handles new device / cleared data scenarios
    if (!isComplete) {
      final profileCheck = await _checkProfileFromApi();
      isComplete = profileCheck.$1;
      step = profileCheck.$2;
    }

    await _prefs.saveUser(
      userId: user.userId,
      role: user.role,
      token: user.token,
      refreshToken: user.refreshToken,
      name: user.name,
      email: user.email,
      isProfileComplete: isComplete,
      onboardingStep: step,
    );

    return user.copyWith(isProfileComplete: isComplete, onboardingStep: step);
  }

  // ─── Check profile via GET endpoint ──────────────────────────────────────
  // Returns (isComplete, onboardingStep)
  Future<(bool, int)> _checkProfileFromApi() async {
    try {
      final dio = DioClient.instance.client;
      final response = await dio.get(ApiConstansts.userCompleteProfile);
      final data = response.data is Map && response.data['data'] is Map
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      final isComplete = data['is_profile_completed'] as bool? ?? false;
      final step = data['onboarding_step'] as int? ?? 0;
      return (isComplete, step);
    } catch (_) {
      // Fallback to SharedPrefs if API fails
      return (_prefs.isProfileComplete(), _prefs.getOnboardingStep());
    }
  }

  // ─── Restore session ──────────────────────────────────────────────────────
  UserModel? tryRestoreSession() {
    final token = _prefs.getToken();
    final role = _prefs.getRole();
    final name = _prefs.getName();
    final email = _prefs.getEmail();
    final userId = _prefs.getUserId();
    final refreshToken = _prefs.getRefreshToken();

    if (token == null ||
        role == null ||
        name == null ||
        email == null ||
        userId == null) {
      return null;
    }

    return UserModel(
      userId: userId,
      role: role,
      token: token,
      refreshToken: refreshToken ?? '',
      name: name,
      email: email,
      isProfileComplete: _prefs.isProfileComplete(),
      onboardingStep: _prefs.getOnboardingStep(),
    );
  }

  // ─── Update onboarding step ───────────────────────────────────────────────
  Future<void> updateOnboardingStep(int step) async {
    await _prefs.setOnboardingStep(step);
  }

  // ─── Mark profile complete ────────────────────────────────────────────────
  Future<void> markProfileComplete() async {
    await _prefs.setProfileComplete();
  }

  bool get isLoggedIn => _prefs.isLoggedIn;

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _api.logout();
    await _prefs.clearUser();
  }
}
