# API Documentation: Therapy Booking Platform

## 1. Project Overview
This API provides a robust backend for a therapy booking system, supporting three primary roles:
- **Client**: Users seeking therapy.
- **Doctor**: Professionals providing therapy.
- **Admin**: System administrators.

### Authentication Flow
The system uses **JWT (JSON Web Token)** for authentication. Users must register, login to receive a token, and then include that token in the `Authorization` header for all protected requests.

---

## 2. Base Configuration
- **Base URL**: `http://<your-server-ip>/api`
- **Default Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer <your_jwt_token>`

---

## 3. Authentication APIs

### POST /api/auth/register
Register a new user identity.
- **Request Body**:
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "securePassword123",
  "userType": "client" // or "doctor"
}
```
- **Success Response (201)**:
```json
{
  "success": true,
  "data": {
    "userId": "uuid-string",
    "fullName": "John Doe",
    "email": "john@example.com",
    "userType": "client",
    "token": "jwt-token-string",
    "refreshToken": "refresh-token-string"
  }
}
```

### POST /api/auth/login
Authenticate and receive tokens.
- **Request Body**:
```json
{
  "email": "john@example.com",
  "password": "securePassword123"
}
```
- **Success Response (200)**: Same as register.

### POST /api/auth/logout
Invalidate the current session.
- **Headers**: Requires `Authorization` header.
- **Success Response (200)**:
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### GET /api/auth/me
Get current authenticated user identity.
- **Headers**: Requires `Authorization` header.
- **Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "userId": "uuid-string",
    "email": "john@example.com",
    "fullName": "John Doe",
    "userType": "client",
    "isEmailVerified": true
  }
}
```

---

## 4. Client APIs

### POST /api/clients/setup
Complete the client profile.
- **Rules**: 
  - **Forbidden Fields**: `fullName`, `firstName`, `lastName`, `age`, `medicalHistory`.
- **Request Body**:
```json
{
  "gender": "male", // male | female | other
  "dateOfBirth": "1990-01-01",
  "phoneNumber": "+1234567890"
}
```
- **Success Response (201)**:
```json
{
  "success": true,
  "message": "Client profile created successfully"
}
```

### GET /api/clients/profile
Retrieve current client's profile.
- **Success Response (200)**:
```json
{
  "success": true,
  "data": {
    "gender": "male",
    "dateOfBirth": "1990-01-01",
    "phoneNumber": "+1234567890"
  }
}
```

---

## 5. Doctor APIs

### POST /api/doctors/setup
Complete the professional doctor profile.
- **Rules**: 
  - **Forbidden Fields**: `fullName`, `firstName`, `lastName`, `age`.
- **Request Body**:
```json
{
  "gender": "female",
  "dateOfBirth": "1985-05-20",
  "phoneNumber": "+9876543210",
  "primarySpecialty": "Clinical Psychology",
  "subSpecializations": ["Anxiety", "CBT"],
  "yearsOfExperience": 10,
  "licenseNumber": "PSY-12345",
  "languagesSpoken": ["English", "Spanish"],
  "videoEnabled": true,
  "videoRate": 100.0,
  "consultationDuration": "60min", // 30min | 45min | 60min
  "bufferTime": "10min" // 5min | 10min | 15min | 30min
}
```

### GET /api/doctors/profile
Retrieve current doctor's profile.

### GET /api/doctors
List all available doctors.
- **Success Response (200)**:
```json
{
  "success": true,
  "data": [
    {
      "user_id": "uuid",
      "full_name": "Dr. Smith",
      "primary_specialty": "Psychology",
      "video_rate": 150.0
    }
  ]
}
```

---

## 6. Admin APIs

### POST /api/admin/create-admin
Create a new admin user. Restricted to existing admins.
- **Request Body**: Same as register but with `userType: admin`.

---

## 7. Request & Response Structure

### Standard Success
```json
{
  "success": true,
  "data": { ... } // or "message": "string"
}
```

### Standard Error
```json
{
  "success": false,
  "message": "Descriptive error message",
  "errors": { ... } // Optional validation field details
}
```

---

## 8. Important Backend Rules
- **Identity vs Profile Separation**: Name and Email belong to the `users` table. Setup APIs **must not** contain identity fields.
- **Forbidden Fields**: Sending `fullName`, `age`, or `firstName/lastName` to setup endpoints will result in a `400 Bad Request`.
- **Derived Data**: Age is **not** stored in the database. Calculate age in Flutter using the `dateOfBirth` field.
- **Validation**: Strict validation is applied to enums (gender, duration, etc.) and data types.

---

## 9. Flutter Integration Guide

### Authentication Flow
1. Call `/api/auth/register` or `/api/auth/login`.
2. Extract the `token` from the response.
3. Persist the token locally.
4. Add the token to the header of every subsequent request.

### Token Storage (shared_preferences)
```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}
```

### API Service Example (http package)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://your-api.com/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/clients/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> setupClient(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/clients/setup"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}
```

---

## 10. Best Practices
- **Token Management**: Intercept `401 Unauthorized` responses to trigger a logout or token refresh flow.
- **Form Validation**: Validate email format and password length in Flutter before making API calls.
- **Data Integrity**: Never hardcode names in profile setup; the backend pulls names from the authenticated user record.
- **Calculations**: Use a helper function in Flutter to compute Age from `dateOfBirth`.
