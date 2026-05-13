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

---

## 11. Detailed Endpoints (derived from controllers)

Note: The following is generated from the PHP controller implementations. It lists every implemented endpoint, required auth/role, expected request fields, common query parameters, and sample success responses. Use this as a reference for exact parameter names (camelCase vs snake_case) and validation rules.

- **Auth**
  - POST `/api/auth/register` — Register user (role: `client` or `doctor`).
    - Body: `fullName`, `email`, `password`, `userType` (`client|doctor`).
    - Response (201): `{ success: true, data: { userId, fullName, email, userType, token, refreshToken, is_profile_completed, onboarding_step } }`
    - Errors: 400 validation, 409 duplicate email.

  - POST `/api/auth/login` — Login.
    - Body: `email`, `password`.
    - Response (200): `{ success: true, data: { userId, fullName, email, userType, token, refreshToken, is_profile_completed, onboarding_step } }`
    - Errors: 400 validation, 401 invalid credentials, 403 inactive account.

  - POST `/api/auth/logout` — Logout (requires `Authorization: Bearer <token>`).
    - Response (200): `{ success: true, message: 'Logged out successfully' }`

  - GET `/api/auth/me` — Get current user (requires auth).
    - Response (200): `{ success: true, data: { userId, email, fullName, userType, isEmailVerified } }`

- **Clients**
  - POST `/api/clients/setup` — Multi-step onboarding (role: `client`).
    - Body: required `step` (1..3). Allowed fields per step:
      - Step 1: `name`, `gender`, `dateOfBirth`, `phoneNumber`.
      - Step 2: `medicalHistory`, `allergies`, `currentMedications`.
      - Step 3: `emergencyContact` (object: `name`, `phoneNumber`).
    - Response (200): `{ success: true, data: { onboarding_step, is_profile_completed }}`
    - Errors: 400 on forbidden fields, invalid sequence, missing/empty values.

  - GET `/api/clients/profile` — Get own client profile (role: `client`).
    - Response (200): `{ success: true, data: { client: { ...client profile fields... } } }`

  - GET `/api/clients/appointments` — Get client's appointments (role: `client`).
    - Query: optional `status`.
    - Response (200): `{ appointments: [...], count: N }`

- **Doctors**
  - POST `/api/doctors/setup` — Create/update doctor profile (multipart/form-data; role: `doctor`).
    - Required form fields: `gender`, `dateOfBirth`, `phoneNumber`, `primarySpecialty`, `yearsOfExperience`, `licenseNumber`, `languagesSpoken` (JSON array), `videoEnabled` (boolean), `videoRate`, `consultationDuration` (`30min|45min|60min`), `bufferTime` (`5min|10min|15min|30min`), plus `profilePhoto` file upload (JPG/PNG <= 2MB).
    - Response (201): `{ message: 'Doctor profile created successfully', profile_photo_url }`
    - Errors: 400 validation, forbidden fields (e.g., `fullName`), 500 storage error.

  - GET `/api/doctors` — List doctors (implementation currently calls with auth; may be public in future).
    - Response (200): Array of doctor objects (camelCased fields like `primarySpecialty`, `yearsOfExperience`).

  - GET `/api/doctors/profile` — Get own doctor profile (role: `doctor`).

  - GET `/api/doctors/{id}` — Get doctor public profile (may be restricted to verified/active doctors for non-admin viewers).

  - PATCH `/api/doctors/status` — Update `isActive` (role: `doctor`).
    - Body: `{ isActive: true|false }`.

  - GET `/api/doctors/appointments` — Delegates to appointments controller to return doctor's appointments (role: `doctor`).

  - **Qualifications (CRUD)**
    - POST `/api/doctors/{id}/qualifications` — Create qualification (multipart/form-data; role: `doctor` or `admin`).
      - Fields: `title` (required), `institution`, `year`, `document` (file, max 5MB, PDF/PNG/JPEG).
      - Response (201): `{ success: true, data: { ... } }`
    - GET `/api/doctors/{id}/qualifications` — List qualifications for doctor.
      - Response (200): `{ success: true, data: [ ... ] }`
    - PUT `/api/doctors/{id}/qualifications/{qual_id}` — Update qualification (JSON).
      - Body: `title`, `institution`, `year`.
    - DELETE `/api/doctors/{id}/qualifications/{qual_id}` — Delete qualification.

- **Available Slots**
  - POST `/api/available-slots` — Create slot (role: `doctor`).
    - Body: `slot_date` (YYYY-MM-DD), `slot_time` (HH:MM), `duration_minutes` (number), `is_available` (optional boolean).
    - Response (201): `{ id: slotId }`

  - GET `/api/available-slots/{id}` — Get slot details.
    - Response (200): `{ slot: { ... } }`

  - GET `/api/available-slots/doctor/{doctorId}` — List slots for doctor.
    - Response (200): `{ slots: [...], count }`

  - GET `/api/appointments/available-slots` — Get available slots (client-facing helper).
    - Query: `doctorId`, `fromDate` (YYYY-MM-DD), `toDate` (YYYY-MM-DD). Role: `client`.
    - Response (200): `{ availableSlots: [...], count }`

  - PUT `/api/available-slots/{id}` — Update slot (role: `doctor`).
  - DELETE `/api/available-slots/{id}` — Delete slot (role: `doctor`).

- **Appointments**
  - POST `/api/appointments` — Book appointment (role: `client`).
    - Body: `doctorId`, `scheduledDate` (YYYY-MM-DD), `scheduledTime` (HH:MM or HH:MM:SS), optional `durationMinutes`, optional `consultationType` (`video|audio|chat`).
    - Behavior: validates formats, computes `endTime` from `durationMinutes` (default 50), checks doctor/client overlap via `hasOverlappingAppointment` & `hasClientConflict`.
    - Response (201): `{ id, message, scheduledDate, scheduledTime, endTime }`
    - Errors: 400 validation/format, 409 conflict (doctor or client overlap).

  - GET `/api/appointments` — List own appointments (client/doctor/admin). Query: optional `status`.
    - Response (200): `{ appointments: [...], count }`

  - GET `/api/appointments/{id}` — Get appointment (authorized participants or admin).
    - Response (200): `{ appointment: { ... } }`

  - PUT `/api/appointments/{id}` — Update appointment (participants or admin). Body supports `status`, `notes`, `scheduled_date`, `scheduled_time`.
  - PATCH `/api/appointments/{id}/cancel` — Cancel appointment (participants or admin). Only `scheduled` status can be cancelled.

- **Consultations**
  - POST `/api/consultations` — Create consultation record (role: `doctor`).
    - Response (201): `{ id }`

  - POST `/api/consultations/{id}/start` — Start consultation (doctor or client; role checked). Returns consultation/session info (201).
  - POST `/api/consultations/{id}/end` — End consultation (role: `doctor`), optional body: `notes`. Response (200) confirms status `completed`.

  - GET `/api/consultations/{id}` — Get consultation details.
  - PUT `/api/consultations/{id}` — Update consultation (doctor).
  - GET `/api/consultations/client` — List client's consultations (role: `client`).
  - GET `/api/consultations/doctor` — List doctor's consultations (role: `doctor`).

- **Messages**
  - POST `/api/appointments/{id}/messages` — Send message within appointment (roles: `doctor`, `client`).
    - Body: `content` (required), optional `messageType` (`text` only in MVP).
    - Response (201): `{ messageId, timestamp, message }`

  - GET `/api/appointments/{id}/messages` — List messages for appointment (roles: doctor/client). Query: `page`, `limit`.

  - POST `/api/messages` — Send standalone message (roles: doctor/client).
    - Body: `recipient_id`, `message_body` or `content`, optional `subject`.
    - Response (201): `{ id }`

  - GET `/api/messages/inbox` — Inbox for current user.
  - GET `/api/messages/sent` — Sent messages.
  - GET `/api/messages/{id}` — Get single message.
  - PUT `/api/messages/{id}` — Update message (e.g., mark read).
  - DELETE `/api/messages/{id}` — Delete message.

- **Admin**
  - POST `/api/admin/create-admin` — Create admin user (role: `admin`).
    - Body: `fullName`, `email`, `password`.
    - Response (201): `{ id, message }`

  - PATCH `/api/admin/verify-doctor` — Verify or reject doctor (role: `admin`).
    - Body: `doctorId`, `status` (`approved|rejected`).
    - Response (200): `{ doctorId, status, message }`

  - GET `/api/admin/doctors` — List all doctors (admin only). Response includes verification and active flags.
  - GET `/api/admin/appointments` — List all appointments system-wide. Query: optional `status`.

---

If you'd like, I will now: (A) expand each endpoint with exact example requests/responses, or (B) produce a machine-readable OpenAPI spec (YAML/JSON) based on these controllers. Which do you prefer? 
