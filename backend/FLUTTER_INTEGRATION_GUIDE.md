# Flutter ↔ Backend Integration Guide

> Built from direct analysis of your Flutter source files and PHP backend.

---

## Current State (What Exists)

```
modules/auth/data/datasources/auth_api.dart            ← EMPTY (needs writing)
modules/auth/data/repositories/auth_respository.dart   ← EMPTY (needs writing)
modules/auth/presentation/screens/login_page.dart      ← Fake delay, no API call
modules/auth/presentation/screens/registration_page.dart ← Fake delay, no API call
modules/user/presentation/screens/registration/user_registration_page.dart ← Fake delay
```

---

## Step 1 — Add Dependencies

In your Flutter project's `pubspec.yaml`, add:

```yaml
dependencies:
  http: ^1.2.1
  shared_preferences: ^2.2.3
```

Then run:

```bash
flutter pub get
```

---

## Step 2 — Create the Auth Response Model

**File to CREATE:**
`lib/modules/auth/data/models/auth_response_model.dart`

```dart
class AuthResponseModel {
  final String id;
  final String email;
  final String role;        // "doctor" | "user" | "admin"
  final String token;
  final String refreshToken;

  AuthResponseModel({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    required this.refreshToken,
  });

  /// Parses the flat JSON the backend returns:
  /// { "id": "...", "email": "...", "role": "...", "token": "...", "refreshToken": "..." }
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id:           json['id']           as String,
      email:        json['email']        as String,
      role:         json['role']         as String,
      token:        json['token']        as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
```

> **Important:** The backend returns a **flat** JSON object — no `data` wrapper.
> `fromJson` reads directly from the root level.

---

## Step 3 — Fill in `auth_api.dart`

**File to EDIT:**
`modules/auth/data/datasources/auth_api.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/modules/auth/data/models/auth_response_model.dart';

class AuthApi {
  // ── Change this to match your environment ──────────────────────────
  // Android emulator : http://10.0.2.2/Therapy%20Booking/backend
  // iOS simulator/web: http://localhost/Therapy%20Booking/backend
  // Real device      : http://YOUR_PC_IP/Therapy%20Booking/backend
  static const String _base = 'http://localhost/Therapy%20Booking/backend';

  // ── REGISTER ───────────────────────────────────────────────────────
  /// POST /api/auth/register
  /// [userType] must be "doctor" or "user"
  static Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String userType,
    required String fullName,
  }) async {
    final uri = Uri.parse('$_base/api/auth/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email':    email,
        'password': password,
        'userType': userType,   // "doctor" | "user"
        'fullName': fullName,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return AuthResponseModel.fromJson(body);
    }

    // Backend error format: { "message": "Email already exists" }
    throw Exception(body['message'] ?? 'Registration failed');
  }

  // ── LOGIN ──────────────────────────────────────────────────────────
  /// POST /api/auth/login
  static Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_base/api/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email':    email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(body);
    }

    // Backend error format: { "message": "Invalid email or password" }
    throw Exception(body['message'] ?? 'Login failed');
  }
}
```

---

## Step 4 — Fill in `auth_respository.dart`

**File to EDIT:**
`modules/auth/data/repositories/auth_respository.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/modules/auth/data/datasources/auth_api.dart';
import 'package:frontend/modules/auth/data/models/auth_response_model.dart';

class AuthRepository {
  static const _keyToken        = 'auth_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyRole         = 'auth_role';
  static const _keyUserId       = 'auth_user_id';
  static const _keyEmail        = 'auth_email';

  // ── REGISTER ───────────────────────────────────────────────────────
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String userType,
    required String fullName,
  }) async {
    final result = await AuthApi.register(
      email:    email,
      password: password,
      userType: userType,
      fullName: fullName,
    );
    await _saveSession(result);
    return result;
  }

  // ── LOGIN ──────────────────────────────────────────────────────────
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final result = await AuthApi.login(email: email, password: password);
    await _saveSession(result);
    return result;
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyEmail);
  }

  // ── GET SAVED ROLE ──────────────────────────────────────────────────
  Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  // ── GET SAVED TOKEN ─────────────────────────────────────────────────
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ── PRIVATE: persist session ────────────────────────────────────────
  Future<void> _saveSession(AuthResponseModel data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken,        data.token);
    await prefs.setString(_keyRefreshToken, data.refreshToken);
    await prefs.setString(_keyRole,         data.role);
    await prefs.setString(_keyUserId,       data.id);
    await prefs.setString(_keyEmail,        data.email);
  }
}
```

---

## Step 5 — Update `registration_page.dart`

**File to EDIT:**
`modules/auth/presentation/screens/registration_page.dart`

### 5a. Add import at the top

```dart
import 'package:frontend/modules/auth/data/repositories/auth_respository.dart';
```

### 5b. Add repository field inside `_RegisterPageState`

```dart
// Add alongside _nameCtrl, _emailCtrl, _passwordCtrl
final _authRepo = AuthRepository();
```

### 5c. Replace the entire `_register()` method

**REMOVE (current fake implementation):**
```dart
Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  await Future.delayed(const Duration(milliseconds: 900)); // ← remove
  if (!mounted) return;
  setState(() => _isLoading = false);

  Widget destination;
  switch (widget.role) {
    case UserRole.doctor: destination = const BasicInformation(); break;
    case UserRole.admin:  destination = const AdminLayout(); break;
    case UserRole.user:   destination = UserRegistrationPage(...); break;
  }
  Navigator.pushAndRemoveUntil(...);
}
```

**REPLACE WITH:**
```dart
Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    // Map Flutter UserRole enum → backend userType string
    final userType = widget.role == UserRole.doctor ? 'doctor' : 'user';

    final result = await _authRepo.register(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      userType: userType,
      fullName: _nameCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate based on role confirmed by the backend
    Widget destination;
    switch (result.role) {
      case 'doctor':
        destination = const BasicInformation();
        break;
      case 'admin':
        destination = const AdminLayout();
        break;
      default: // 'user'
        destination = UserRegistrationPage(
          name:  _nameCtrl.text.trim(),
          email: result.email,
        );
    }

    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute(destination),
      (route) => false,
    );

  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

---

## Step 6 — Update `login_page.dart`

**File to EDIT:**
`modules/auth/presentation/screens/login_page.dart`

### 6a. Add import at the top

```dart
import 'package:frontend/modules/auth/data/repositories/auth_respository.dart';
```

### 6b. Add repository field inside `_LoginPageState`

```dart
final _authRepo = AuthRepository();
```

### 6c. Replace the entire `_login()` method

**REMOVE (current fake implementation):**
```dart
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  await Future.delayed(const Duration(milliseconds: 900)); // ← remove

  final email = _emailCtrl.text.trim().toLowerCase();
  Widget destination;
  if (email == 'admin@demo.com') {          // ← remove email string matching
    destination = const AdminLayout();
  } else if (email.contains('doctor') || email.contains('doc@')) {
    destination = const MainDoctorLayout();
  } else {
    destination = const MainUserLayout();
  }
  Navigator.pushAndRemoveUntil(...);
}
```

**REPLACE WITH:**
```dart
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  try {
    final result = await _authRepo.login(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate based on the role the backend returns
    Widget destination;
    switch (result.role) {
      case 'doctor':
        destination = const MainDoctorLayout();
        break;
      case 'admin':
        destination = const AdminLayout();
        break;
      default: // 'user'
        destination = const MainUserLayout();
    }

    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute(destination),
      (route) => false,
    );

  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

> You can also **delete the `_DemoHint` widget** (lines 162–189 in `login_page.dart`) —
> it's no longer relevant once real login is connected.

---

## Summary of All Files to Touch

| File | Action |
|---|---|
| `pubspec.yaml` | Add `http` + `shared_preferences` |
| `modules/auth/data/models/auth_response_model.dart` | **CREATE NEW** |
| `modules/auth/data/datasources/auth_api.dart` | **FILL IN** (was empty) |
| `modules/auth/data/repositories/auth_respository.dart` | **FILL IN** (was empty) |
| `modules/auth/presentation/screens/registration_page.dart` | Replace `_register()` method |
| `modules/auth/presentation/screens/login_page.dart` | Replace `_login()` method |

---

## Testing Checklist

Test in this exact order after wiring up:

- [ ] Register as **Doctor** → lands on `BasicInformation` screen
- [ ] Register as **User/Patient** → lands on `UserRegistrationPage`
- [ ] Register with a **duplicate email** → snackbar shows `"Email already exists"`
- [ ] Login with **correct credentials** → routes to the correct layout by `role`
- [ ] Login with **wrong password** → snackbar shows `"Invalid email or password"`
- [ ] Kill and reopen app → token is persisted via `SharedPreferences`

---

## Device URL Reference

| Running on | `_base` value in `auth_api.dart` |
|---|---|
| Web browser / iOS Simulator | `http://localhost/Therapy%20Booking/backend` |
| Android Emulator | `http://10.0.2.2/Therapy%20Booking/backend` |
| Real device (same WiFi as PC) | `http://YOUR_PC_LAN_IP/Therapy%20Booking/backend` |

---

## Backend API Contract (Reference)

### POST `/api/auth/register`
**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepass",
  "userType": "doctor",
  "fullName": "Dr. Alice Smith"
}
```
**Success Response (201):**
```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "role": "doctor",
  "token": "eyJ...",
  "refreshToken": "eyJ..."
}
```
**Error Response:**
```json
{ "message": "Email already exists" }
```

---

### POST `/api/auth/login`
**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepass"
}
```
**Success Response (200):**
```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "role": "doctor",
  "token": "eyJ...",
  "refreshToken": "eyJ..."
}
```
**Error Response:**
```json
{ "message": "Invalid email or password" }
```
