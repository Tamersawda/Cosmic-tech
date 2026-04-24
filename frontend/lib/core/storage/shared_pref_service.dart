import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  SharedPrefService._();
  static final SharedPrefService instance = SharedPrefService._();

  SharedPreferences? _prefs;

  // ─── Keys ─────────────────────────────────────────────────────────────────
  static const String _tokenKey             = 'token';
  static const String _refreshTokenKey      = 'refresh_token';
  static const String _userIdKey            = 'user_id';
  static const String _roleKey          = 'role';
  static const String _nameKey          = 'name';
  static const String _emailKey             = 'email';
  static const String _isProfileCompleteKey = 'is_profile_complete';
  static const String _onboardingStepKey    = 'onboarding_step';

  // ─── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _safePrefs {
    assert(
      _prefs != null,
      'SharedPrefService not initialised. '
      'Call SharedPrefService.instance.init() in main() first.',
    );
    return _prefs!;
  }

  // ─── Write ─────────────────────────────────────────────────────────────────
  Future<void> saveUser({
    required String userId,
    required String role,
    required String token,
    required String refreshToken,
    required String name,
    required String email,
    bool isProfileComplete = false,
    int  onboardingStep    = 0,
  }) async {
    await Future.wait([
      _safePrefs.setString(_userIdKey,       userId),
      _safePrefs.setString(_roleKey,     role),
      _safePrefs.setString(_tokenKey,        token),
      _safePrefs.setString(_refreshTokenKey, refreshToken),
      _safePrefs.setString(_nameKey,     name),
      _safePrefs.setString(_emailKey,        email),
      _safePrefs.setBool(_isProfileCompleteKey, isProfileComplete),
      _safePrefs.setInt(_onboardingStepKey,  onboardingStep),
    ]);
  }

  // Called after each onboarding step completes
  Future<void> setOnboardingStep(int step) async {
    await _safePrefs.setInt(_onboardingStepKey, step);
  }

  // Called when profile is fully complete
  Future<void> setProfileComplete() async {
    await Future.wait([
      _safePrefs.setBool(_isProfileCompleteKey, true),
      _safePrefs.setInt(_onboardingStepKey,     99), // sentinel value
    ]);
  }

  // ─── Read ──────────────────────────────────────────────────────────────────
  String? getToken()        => _safePrefs.getString(_tokenKey);
  String? getRefreshToken() => _safePrefs.getString(_refreshTokenKey);
  String? getUserId()       => _safePrefs.getString(_userIdKey);
  String? getRole()     => _safePrefs.getString(_roleKey);
  String? getName()     => _safePrefs.getString(_nameKey);
  String? getEmail()        => _safePrefs.getString(_emailKey);
  bool    isProfileComplete()  => _safePrefs.getBool(_isProfileCompleteKey) ?? false;
  int     getOnboardingStep()  => _safePrefs.getInt(_onboardingStepKey)     ?? 0;

  bool get isLoggedIn => getToken() != null;

  // ─── Clear ─────────────────────────────────────────────────────────────────
  Future<void> clearUser() async {
    await Future.wait([
      _safePrefs.remove(_tokenKey),
      _safePrefs.remove(_refreshTokenKey),
      _safePrefs.remove(_userIdKey),
      _safePrefs.remove(_roleKey),
      _safePrefs.remove(_nameKey),
      _safePrefs.remove(_emailKey),
      _safePrefs.remove(_isProfileCompleteKey),
      _safePrefs.remove(_onboardingStepKey),
    ]);
  }

  Future<void> clearAll() async => _safePrefs.clear();
}