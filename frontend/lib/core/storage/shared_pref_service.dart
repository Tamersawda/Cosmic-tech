import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  SharedPrefService._();
  static final SharedPrefService instance = SharedPrefService._();

  SharedPreferences? _prefs;

  static const String _tokenKey    = 'token';
  static const String _roleKey     = 'role';
  static const String _nameKey = 'full_name';
  static const String _emailKey    = 'email';

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
    required String role,
    required String token,
    required String name,
    required String email,
  }) async {
    await Future.wait([
      _safePrefs.setString(_roleKey,     role),
      _safePrefs.setString(_tokenKey,    token),
      _safePrefs.setString(_nameKey, name),
      _safePrefs.setString(_emailKey,    email),
    ]);
  }

  // ─── Read ──────────────────────────────────────────────────────────────────
  String? getToken()    => _safePrefs.getString(_tokenKey);
  String? getRole()     => _safePrefs.getString(_roleKey);
  String? getName() => _safePrefs.getString(_nameKey);
  String? getEmail()    => _safePrefs.getString(_emailKey);

  bool get isLoggedIn => getToken() != null;

  // ─── Clear ─────────────────────────────────────────────────────────────────
  Future<void> clearUser() async {
    await Future.wait([
      _safePrefs.remove(_tokenKey),
      _safePrefs.remove(_roleKey),
      _safePrefs.remove(_nameKey),
      _safePrefs.remove(_emailKey),
    ]);
  }

  Future<void> clearAll() async => _safePrefs.clear();
}