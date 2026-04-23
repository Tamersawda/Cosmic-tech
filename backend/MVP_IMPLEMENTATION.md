# Therapy Booking Platform — Backend API Reference

**Version:** 2.0 (Audited & Hardened)
**Last Updated:** April 2026
**Base URL (local):** `http://localhost/Therapy Booking/backend`
**Postman Collection:** `postman/Therapy-Booking-MVP-API.postman_collection.json`

---

## ⚡ Quick Start for Flutter Developers

### 1. Base URL Setup (Dio)
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'http://10.0.2.2/Therapy Booking/backend', // Android emulator
  // baseUrl: 'http://localhost/Therapy Booking/backend', // iOS simulator
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  headers: {'Content-Type': 'application/json'},
));
```

### 2. Attach JWT Token
After login, attach the token to every protected request:
```dart
dio.options.headers['Authorization'] = 'Bearer $token';
```

### 3. Universal Response Shape
**Every** response from this API follows this exact envelope:

```json
// Success
{ "success": true,  "data": { ... } }

// Error
{ "success": false, "message": "Human-readable error" }

// Validation Error (400)
{ "success": false, "message": "field: error description" }
```

```dart
// Dart model to parse every response
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
}
```

---

## 🔐 Authentication

### POST `/api/auth/register`

Register a new user. Returns a token immediately — no email verification step.

**Request body:**
```json
{
  "name":     "Dr. Alice Smith",
  "email":    "alice@example.com",
  "password": "SecurePass123",
  "role":     "doctor"
}
```

> ⚠️ **Critical field names for Flutter:**
> - Field is `"name"` — NOT `"fullName"`, NOT `"firstName"/"lastName"`
> - Field is `"role"` — NOT `"userType"`, NOT `"user_type"`
> - `"role"` must be exactly `"doctor"` or `"user"` — `"patient"` will be rejected with 400

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "id":           "550e8400-e29b-41d4-a716-446655440000",
    "name":         "Dr. Alice Smith",
    "email":        "alice@example.com",
    "role":         "doctor",
    "token":        "eyJhbGci...",
    "refreshToken": "eyJhbGci..."
  }
}
```

**Error cases:**
| Code | Message |
|------|---------|
| `400` | `role must be one of admin, doctor, or user` |
| `400` | `name is required` |
| `400` | `password must be at least 6 characters` |
| `409` | `Email already exists` |

---

### POST `/api/auth/login`

**Request body:**
```json
{
  "email":    "alice@example.com",
  "password": "SecurePass123"
}
```

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id":           "550e8400-e29b-41d4-a716-446655440000",
    "name":         "Dr. Alice Smith",
    "email":        "alice@example.com",
    "role":         "doctor",
    "token":        "eyJhbGci...",
    "refreshToken": "eyJhbGci..."
  }
}
```

> 💡 **Flutter tip:** Save `role` from this response. Use it to route the user:
> - `role == 'doctor'` → Doctor home screen → call `/api/doctors/setup`
> - `role == 'user'` → Patient home screen → call `/api/patients/setup`

**Token details:**
- `token` — access token, **expires in 1 hour**. Use in `Authorization: Bearer <token>` header.
- `refreshToken` — expires in **7 days**. Store securely (e.g. `flutter_secure_storage`).

**Error cases:**
| Code | Message |
|------|---------|
| `401` | `Invalid credentials` |
| `403` | `Account is inactive` |

---

### GET `/api/auth/me`

Get the authenticated user's info. Use to validate a stored token on app launch.

**Headers:** `Authorization: Bearer <token>`

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id":              "550e8400-e29b-41d4-a716-446655440000",
    "email":           "alice@example.com",
    "role":            "doctor",
    "fullName":        "Dr. Alice Smith",
    "isEmailVerified": true
  }
}
```

---

## 👨‍⚕️ Doctor Profile

### POST `/api/doctors/setup`

Sets up the doctor's full profile. Call this after registration/login when `profileStatus != 'completed'`.

**Headers:** `Authorization: Bearer <doctorToken>` (role must be `"doctor"`)

**Request body:**
```json
{
  "fullName":            "Dr. Alice Smith",
  "gender":              "female",
  "dateOfBirth":         "1985-03-15",
  "phoneNumber":         "+919876543210",
  "primarySpecialty":    "Clinical Psychology",
  "subSpecializations":  ["Anxiety", "Depression", "PTSD"],
  "yearsOfExperience":   12,
  "licenseNumber":       "LIC-2024-001",
  "medicalCouncil":      "MCI",
  "languagesSpoken":     ["English", "Hindi"],
  "videoEnabled":        true,
  "videoRate":           1500,
  "audioEnabled":        true,
  "audioRate":           1000,
  "consultationDuration":"60min",
  "bufferTime":          "10min",
  "streetAddress":       "123 Medical Plaza",
  "city":                "Bangalore",
  "state":               "Karnataka",
  "country":             "India",
  "postalCode":          "560001"
}
```

**Field constraints:**
| Field | Type | Allowed values |
|-------|------|----------------|
| `gender` | string | `male` `female` `other` `prefer_not_to_say` |
| `dateOfBirth` | string | `YYYY-MM-DD` format |
| `yearsOfExperience` | integer | `0`–`60` |
| `consultationDuration` | string | `30min` `45min` `60min` — **⚠️ NOT `50min`** |
| `bufferTime` | string | `5min` `10min` `15min` `30min` |
| `videoEnabled` / `audioEnabled` | boolean | `true` / `false` |

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "doctorId":      "550e8400-...",
    "profileStatus": "completed",
    "profile": {
      "fullName":         "Dr. Alice Smith",
      "primarySpecialty": "Clinical Psychology",
      "yearsOfExperience": 12,
      "licenseNumber":    "LIC-2024-001"
    }
  }
}
```

---

### GET `/api/doctor-profile`

Get the logged-in doctor's own profile.

**Headers:** `Authorization: Bearer <doctorToken>`

---

### GET `/api/doctor-profile/{id}`

Get any doctor's profile by their UUID. Used by patients to view doctor details.

**Headers:** `Authorization: Bearer <patientToken>`

---

### GET `/api/doctors`

List all doctors (for patient browsing/search screen).

**Headers:** `Authorization: Bearer <patientToken>`

---

### GET `/api/doctors/appointments`

Get the doctor's own appointment list.

**Headers:** `Authorization: Bearer <doctorToken>`

**Optional query:** `?status=scheduled` | `completed` | `cancelled`

---

### POST `/api/doctors/qualifications`

Add a degree/qualification to the doctor's profile.

**Headers:** `Authorization: Bearer <doctorToken>`

**Request body:**
```json
{
  "degree":           "MD Psychiatry",
  "instituteName":    "AIIMS Delhi",
  "yearOfCompletion": 2012,
  "certificateFile":  "https://..."
}
```

**Response `201`:**
```json
{
  "success": true,
  "data": { "id": "qual-uuid-..." }
}
```

---

### GET `/api/doctors/qualifications`
### PUT `/api/doctors/qualifications/{id}`
### DELETE `/api/doctors/qualifications/{id}`

Standard CRUD for qualifications. All require `Authorization: Bearer <doctorToken>`.

---

## 🧑‍💼 Patient Profile

### POST `/api/patients/setup`

Sets up the patient's profile. Call after registration when `profileStatus != 'completed'`.

**Headers:** `Authorization: Bearer <patientToken>` (role must be `"user"`)

**Request body:**
```json
{
  "fullName":       "Jane Doe",
  "gender":         "female",
  "dateOfBirth":    "1995-06-15",
  "phoneNumber":    "+919876543211",
  "age":            28,
  "medicalHistory": "No known allergies"
}
```

> ⚠️ **Critical:** role must be `"user"` in JWT — the old `"patient"` role does NOT exist.

**Field constraints:**
| Field | Required | Notes |
|-------|----------|-------|
| `fullName` | ✅ | Full name string |
| `gender` | ✅ | `male` `female` `other` |
| `dateOfBirth` | ✅ | `YYYY-MM-DD` format |
| `phoneNumber` | ✅ | Any valid format |
| `age` | optional | Integer |
| `medicalHistory` | optional | Free text |

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "patientId":     "550e8400-...",
    "profileStatus": "completed",
    "profile": {
      "fullName":    "Jane Doe",
      "gender":      "female",
      "phoneNumber": "+919876543211",
      "age":         28
    }
  }
}
```

---

### GET `/api/patient-profile`

Get the logged-in patient's own profile.

**Headers:** `Authorization: Bearer <patientToken>`

---

### GET `/api/patient-profile/{id}`

Get a specific patient's profile by UUID. Typically called by doctors.

---

### GET `/api/patients/appointments`

Get the patient's own appointments.

**Headers:** `Authorization: Bearer <patientToken>`

**Optional query:** `?status=scheduled` | `completed` | `cancelled`

---

## 📅 Appointments

### POST `/api/appointments`

Book an appointment with a doctor.

**Headers:** `Authorization: Bearer <patientToken>` (role: `"user"`)

**Request body:**
```json
{
  "doctorId":         "doctor-uuid-here",
  "scheduledDate":    "2025-12-01",
  "scheduledTime":    "10:00",
  "consultationType": "video"
}
```

**Field constraints:**
| Field | Format | Notes |
|-------|--------|-------|
| `scheduledDate` | `YYYY-MM-DD` | Must be future date |
| `scheduledTime` | `HH:00` | **Whole-hour slots only** — `10:30` will be rejected |
| `consultationType` | string | `video` `audio` `chat` |

**Response `201`:**
```json
{
  "success": true,
  "data": {
    "id":               "appt-uuid-...",
    "status":           "scheduled",
    "scheduledDate":    "2025-12-01",
    "scheduledTime":    "10:00",
    "endTime":          "10:50",
    "consultationType": "video"
  }
}
```

**Error cases:**
| Code | Message |
|------|---------|
| `400` | `Only whole-hour time slots are allowed` |
| `400` | `Appointment must be scheduled for a future date and time` |
| `404` | `Doctor not found` |
| `404` | `Patient profile not found — complete your profile first` |
| `409` | `Doctor already has an appointment at this time` |
| `409` | `You already have an appointment at this time` |

---

### GET `/api/appointments`

List all appointments for the logged-in user (works for both doctors and patients).

**Headers:** `Authorization: Bearer <token>`

---

### GET `/api/appointments/{id}`

Get a single appointment. Only the doctor or patient on that appointment can view it.

---

### PATCH `/api/appointments/{id}/cancel`

Cancel a scheduled appointment.

**Headers:** `Authorization: Bearer <patientToken>` (role: `"user"`)

Only `status == "scheduled"` appointments can be cancelled.

---

### PUT `/api/appointments/{id}`

Update appointment details (doctors only for status changes).

**Headers:** `Authorization: Bearer <doctorToken>`

---

## 💬 Messages

### POST `/api/appointments/{id}/messages`

Send a message within an appointment thread.

**Headers:** `Authorization: Bearer <token>` (doctor or patient)

**Request body:**
```json
{
  "content":     "Hello Doctor, I have a question.",
  "messageType": "text"
}
```

---

### GET `/api/appointments/{id}/messages`

Get messages for an appointment.

**Query params:** `?page=1&limit=50`

---

### POST `/api/messages`

Send a standalone message (outside of any appointment).

**Request body:**
```json
{
  "recipient_id": "uuid-of-recipient",
  "content":      "Hi, I would like to book a follow-up.",
  "subject":      "Follow-up query"
}
```

---

### GET `/api/messages/inbox`
### GET `/api/messages/sent`
### GET `/api/messages/{id}`
### PUT `/api/messages/{id}` — mark read: `{ "is_read": true }`
### DELETE `/api/messages/{id}`

---

## 🩺 Consultations

Managed by doctors after an appointment starts.

### POST `/api/consultations/{appointmentId}/start`

Start a consultation session. Appointment must be `"scheduled"`.

**Headers:** `Authorization: Bearer <doctorToken>`

---

### POST `/api/consultations/{appointmentId}/end`

End the session and add notes.

**Request body:**
```json
{
  "notes": "Patient responding well to CBT approach."
}
```

---

### PUT `/api/consultations/{id}`

Update session notes/prescriptions/follow-up date.

**Request body:**
```json
{
  "notes":                "Updated session notes",
  "prescriptions":        ["Sertraline 50mg", "Clonazepam 0.25mg"],
  "next_follow_up_date":  "2025-12-15"
}
```

> ⚠️ The field is `next_follow_up_date` — NOT `follow_up_date`

---

### GET `/api/consultations/patient` — patient's sessions
### GET `/api/consultations/doctor` — doctor's sessions
### GET `/api/consultations/{id}` — single session

---

## 🔒 Role Reference

| Who | `role` value | Profile setup endpoint |
|-----|-------------|----------------------|
| Patient | `"user"` | `POST /api/patients/setup` |
| Doctor | `"doctor"` | `POST /api/doctors/setup` |
| Admin | `"admin"` | (admin panel — not in Flutter MVP) |

> ⚠️ `"patient"` as a role value **does not exist** in this system. Always use `"user"`.

---

## 🗂️ JWT Payload

The decoded JWT contains:
```json
{
  "user_id": "550e8400-...",
  "role":    "doctor",
  "email":   "alice@example.com",
  "iat":     1714000000,
  "exp":     1714003600
}
```

Use `role` to show/hide UI sections in Flutter. Never trust the role from local storage alone — validate with `GET /api/auth/me` on app start.

---

## 🗄️ Database

**Single source of truth:** `db/combined_schema.sql`

Run this once to create all tables:
```
phpMyAdmin → Import → combined_schema.sql → Go
```

**Tables:**
```
users                  — accounts (all roles)
doctor_profiles        — 1:1 with users (doctor only)
patient_profiles       — 1:1 with users (patient only)
doctor_qualifications  — 1:N with doctor_profiles
doctor_weekly_schedule — 1:N with doctor_profiles
appointments           — links doctor_profile ↔ patient_profile
consultation_sessions  — 1:1 with appointments
messages               — linked to appointments or standalone
reviews                — patient → doctor, per appointment
documents              — uploaded files
notifications          — per-user notification log
refresh_tokens         — stored refresh tokens
```

---

## 📂 Project Structure

```
backend/
├── api.php                        ← single entry point (all requests go here)
├── .htaccess                      ← routes everything to api.php
├── .env                           ← DB_NAME, JWT_SECRET, APP_ENV
├── config/
│   ├── Database.php               ← PDO singleton
│   └── JWT.php                    ← encode / decode
├── controllers/
│   ├── AuthController.php         ✅ audited
│   ├── DoctorProfileController.php ✅ audited
│   ├── PatientProfileController.php ✅ audited
│   ├── AppointmentController.php  ✅ audited
│   ├── ConsultationController.php
│   └── MessageController.php
├── models/
│   ├── User.php                   ✅ audited
│   ├── DoctorProfile.php          ✅ audited
│   ├── PatientProfile.php         ✅ audited
│   ├── Appointment.php
│   └── Consultation.php           ✅ audited
├── middleware/
│   └── AuthMiddleware.php         ✅ audited
├── utils/
│   ├── Response.php               ✅ audited
│   └── Validator.php
├── routes/
│   └── auth.php                   ✅ audited
└── db/
    └── combined_schema.sql        ← run this to create the database
```

---

## ⚙️ Environment File (`.env`)

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=therapy_booking

JWT_SECRET=your_strong_random_secret_here

APP_ENV=development
```

> When `APP_ENV=development`, raw exception messages are returned. Change to `production` before deployment to show generic error messages.

---

## ❌ Common Mistakes (Flutter Integration)

| Mistake | Correct |
|---------|---------|
| Sending `"role": "patient"` | Send `"role": "user"` |
| Sending `"userType"` field | Send `"role"` field |
| Sending `"firstName"` + `"lastName"` | Send `"fullName"` |
| Booking `"scheduledTime": "10:30"` | Use `"10:00"` (whole hours only) |
| Using `"consultationDuration": "50min"` | Use `"30min"` `"45min"` or `"60min"` |
| Using `"follow_up_date"` in consultation | Use `"next_follow_up_date"` |
| Not sending `Content-Type: application/json` | Always include this header |
| Reading `data.userType` from response | Read `data.role` |

---

## ✅ Flutter Test Flow (Postman → Flutter)

```
1. POST /api/auth/register   → save token + id + role
2. POST /api/auth/login      → save token + refreshToken
3. GET  /api/auth/me         → verify token works
4. POST /api/doctors/setup   → complete doctor profile (role: doctor)
   OR
   POST /api/patients/setup  → complete patient profile (role: user)
5. GET  /api/doctors         → patient browses doctors
6. POST /api/appointments    → patient books slot
7. GET  /api/appointments    → both sides view bookings
8. POST /api/consultations/{id}/start → doctor starts session
9. POST /api/consultations/{id}/end   → doctor ends session
```

---

## 🚀 Production Checklist

- [x] Database created from `combined_schema.sql`
- [x] All git conflict markers removed from source files
- [x] Legacy `api/auth/` stubs deleted (were intercepting routes)
- [x] Role values standardized (`user` not `patient`)
- [x] JWT mints `role` claim (not `user_type`)
- [ ] `JWT_SECRET` set to a strong random value (not default)
- [ ] `APP_ENV=production` set
- [ ] HTTPS enabled
- [ ] CORS restricted to Flutter app origin
- [ ] Rate limiting on `/api/auth/login` and `/api/auth/register`
- [ ] Database backups scheduled
- [ ] Error logging to file (not stdout)
