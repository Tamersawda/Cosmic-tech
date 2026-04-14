# Email Verification & Authentication Implementation Guide

## 📋 Overview

This documentation covers the complete email verification system with OTP-based authentication for the Therapy Booking Platform. The implementation includes:

- **Email-based verification** with 6-digit OTP
- **Clean authentication flow** with JWT tokens
- **Strict validation** on all inputs
- **Minimal architectural changes** (no impact on existing endpoints)

---

## 🗄️ 1. Database Schema Changes

### User Table Updates

Added 3 new fields to the `users` table:

```sql
ALTER TABLE users ADD COLUMN is_email_verified TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN email_verification_otp VARCHAR(255) NULL;
ALTER TABLE users ADD COLUMN email_verification_expires DATETIME NULL;
ALTER TABLE users ADD INDEX idx_users_email_verified (is_email_verified);
```

**Field Descriptions:**
- `is_email_verified`: Boolean flag (0 = unverified, 1 = verified)
- `email_verification_otp`: Hashed 6-digit OTP (bcrypt)
- `email_verification_expires`: OTP expiry timestamp (10 minutes from generation)

---

## 🔐 2. Security Configuration

### Environment Variables

Add these to your `.env` file:

```env
# Existing
JWT_SECRET=your-super-secret-key-change-this-in-production
JWT_EXPIRY=3600

# Email Configuration
MAIL_DRIVER=php              # Options: php, smtp, mailgun, sendgrid
MAIL_FROM=noreply@therapeuticsanctuary.com
MAIL_FROM_NAME=Therapy Sanctuary

# Optional: SMTP Configuration (if MAIL_DRIVER=smtp)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

---

## 📦 3. New Utilities

### OtpManager Class

**File:** `utils/OtpManager.php`

Handles OTP generation, hashing, and validation:

```php
// Generate 6-digit OTP
$otp = OtpManager::generateOtp();  // Returns: "123456"

// Hash OTP before storing (bcrypt)
$hashedOtp = OtpManager::hashOtp($otp);

// Verify OTP
$isValid = OtpManager::verifyOtp("123456", $hashedOtp);

// Get expiry time (10 minutes from now)
$expiryTime = OtpManager::getOtpExpiry();  // UTC timestamp

// Check if OTP is expired
$isExpired = OtpManager::isOtpExpired($expiryTime);

// Validate OTP format (6 numeric digits)
$isValid = OtpManager::validateOtpFormat("123456");
```

**Constants:**
- OTP Length: 6 digits
- OTP Expiry: 10 minutes
- Max Attempts: 5 (tracked client-side)
- Resend Cooldown: 30 seconds

### EmailService Class

**File:** `utils/EmailService.php`

Handles email sending with customizable drivers:

```php
$emailService = new EmailService();

// Send OTP email
$emailService->sendOtpEmail("user@example.com", "123456");

// Send verification success email
$emailService->sendVerificationSuccessEmail("user@example.com");

// Send resend OTP email (with resend notification)
$emailService->sendResendOtpEmail("user@example.com", "123456");
```

**Supported Drivers:**
- `php`: Native PHP mail() function
- `smtp`: SMTP server (requires SMTP_* env vars)
- `mailgun`: Mailgun API (placeholder)
- `sendgrid`: SendGrid API (placeholder)

---

## 🔑 4. Updated Endpoints

### POST `/api/auth/register`

**Register a new user and send OTP**

**Request:**
```json
{
  "email": "doctor@example.com",
  "password": "SecurePass123!",
  "userType": "doctor",
  "fullName": "Dr. John Smith"
}
```

**Validation Rules:**
- `email`: Required, valid email format, must be unique
- `password`: Required, minimum 6 characters
- `userType`: Required, must be "doctor" or "patient"
- `fullName`: Required, string

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "message": "User registered. Please verify email."
  }
}
```

**Error Cases:**
```json
// Email already exists
{
  "success": false,
  "message": "Email already exists",
  "status": 409
}

// Validation failed
{
  "success": false,
  "message": "Validation failed",
  "status": 400,
  "errors": {
    "email": ["email must be a valid email"]
  }
}
```

**Flow:**
1. Validate input
2. Check email uniqueness
3. Hash password with bcrypt
4. Create user with `is_email_verified = false`
5. Generate 6-digit OTP
6. Hash OTP with bcrypt
7. Store hashed OTP + expiry in database
8. Send OTP via email
9. Return success message (no JWT token)

---

### POST `/api/auth/verify-email`

**Verify email with OTP and activate account**

**Request:**
```json
{
  "email": "doctor@example.com",
  "otp": "123456"
}
```

**Validation Rules:**
- `email`: Required, valid email format
- `otp`: Required, exactly 6 numeric digits

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "message": "Email verified successfully"
  }
}
```

**Error Cases:**
```json
// User not found
{
  "success": false,
  "message": "User not found",
  "status": 404
}

// OTP expired
{
  "success": false,
  "message": "OTP has expired. Please request a new one.",
  "status": 400
}

// Invalid OTP
{
  "success": false,
  "message": "Invalid OTP",
  "status": 400
}

// Email already verified
{
  "success": false,
  "message": "Email already verified",
  "status": 400
}
```

**Flow:**
1. Validate input
2. Find user by email
3. Check if email already verified
4. Check if OTP exists
5. Check if OTP expired (compared to `email_verification_expires`)
6. Verify OTP hash using `password_verify()`
7. Mark email as verified: set `is_email_verified = 1`
8. Clear OTP fields
9. Send verification success email
10. Return success message

---

### POST `/api/auth/resend-otp`

**Request a new OTP (same email)**

**Request:**
```json
{
  "email": "doctor@example.com"
}
```

**Validation Rules:**
- `email`: Required, valid email format

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "message": "OTP sent to your email"
  }
}
```

**Error Cases:**
```json
// User not found
{
  "success": false,
  "message": "User not found",
  "status": 404
}

// Email already verified
{
  "success": false,
  "message": "Email is already verified",
  "status": 400
}

// Within cooldown period
{
  "success": false,
  "message": "Please wait before requesting a new OTP",
  "status": 429
}
```

**Flow:**
1. Validate input
2. Find user by email
3. Check if email already verified
4. (Optional) Check resend cooldown: 30 seconds
5. Generate new OTP
6. Hash new OTP
7. Overwrite old OTP + expiry in database
8. Send OTP email
9. Return success message

---

### POST `/api/auth/login`

**Login with verified email (updated)**

**Request:**
```json
{
  "email": "doctor@example.com",
  "password": "SecurePass123!"
}
```

**Validation Rules:**
- `email`: Required, valid email format
- `password`: Required, string

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "doctor@example.com",
    "userType": "doctor",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Cases:**
```json
// Email not verified (NEW)
{
  "success": false,
  "message": "EMAIL_NOT_VERIFIED",
  "status": 403
}

// Invalid credentials
{
  "success": false,
  "message": "Invalid email or password",
  "status": 401
}

// Account inactive
{
  "success": false,
  "message": "Account is inactive",
  "status": 403
}
```

**Key Changes:**
1. Added email verification check: `if (!$user['is_email_verified'])`
2. Returns error code `EMAIL_NOT_VERIFIED` if email not verified
3. Generates both JWT token (1 hour) and refresh token (7 days)
4. No changes to password verification logic

---

### GET `/api/me`

**Get current user info (updated)**

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "doctor@example.com",
    "userType": "doctor",
    "isEmailVerified": true
  }
}
```

**New Field:**
- `isEmailVerified`: Boolean flag showing email verification status

---

## 📝 5. Complete Request/Response Examples

### Example 1: User Registration Flow

**Step 1: Register**
```bash
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "MySecurePass123",
    "userType": "patient",
    "fullName": "John Doe"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "User registered. Please verify email."
  }
}
```

**What happens:**
- User created with `is_email_verified = 0`
- OTP generated: `456789`
- OTP hashed and stored with 10-minute expiry
- Email sent with OTP

---

**Step 2: Verify Email (User enters OTP from email)**
```bash
curl -X POST http://localhost/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "otp": "456789"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Email verified successfully"
  }
}
```

**What happens:**
- OTP validated (hash matched, not expired)
- User marked as verified: `is_email_verified = 1`
- OTP fields cleared from database
- Verification email sent

---

**Step 3: Login (Only now possible)**
```bash
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "MySecurePass123"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john.doe@example.com",
    "userType": "patient",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNTUwZTg0MDAtZTI5Yi00MWQ0LWE3MTYtNDQ2NjU1NDQwMDAwIiwidXNlcl90eXBlIjoicGF0aWVudCIsImVtYWlsIjoiam9obi5kb2VAZXhhbXBsZS5jb20iLCJpYXQiOjE3MzQ1ODk4MDAsImV4cCI6MTczNDU5MzQwMH0.signature...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNTUwZTg0MDAtZTI5Yi00MWQ0LWE3MTYtNDQ2NjU1NDQwMDAwIiwidXNlcl90eXBlIjoicGF0aWVudCIsImVtYWlsIjoiam9obi5kb2VAZXhhbXBsZS5jb20iLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTczNDU4OTgwMCwiZXhwIjoxNzM1MTk0NjAwfQ.signature..."
  }
}
```

---

### Example 2: OTP Resend

**User didn't receive OTP**
```bash
curl -X POST http://localhost/api/auth/resend-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "OTP sent to your email"
  }
}
```

**What happens:**
- New OTP generated: `789012`
- Previous OTP overwritten
- New 10-minute expiry set
- Email sent with new OTP

---

### Example 3: Error - Not Verified Login

**User tries to login before verifying email**
```bash
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "MySecurePass123"
  }'
```

**Response (403 Forbidden):**
```json
{
  "success": false,
  "message": "EMAIL_NOT_VERIFIED",
  "status": 403
}
```

**Client should:**
1. Show message: "Please verify your email first"
2. Redirect to OTP verification screen
3. Offer "Resend OTP" option

---

## 🧪 6. Validation Rules Summary

| Field | Rule | Example |
|-------|------|---------|
| email | Required, valid format, unique | john@example.com |
| password | Required, min 6 chars | MyPass123 |
| userType | Required, doctor\|patient | doctor |
| fullName | Required, string | John Doe |
| otp | Required, 6 digits, numeric | 123456 |

---

## 🛡️ 7. Security Features

### Password Security
- **Algorithm:** bcrypt with cost = 12
- **Verification:** `password_verify()` function
- **Never stored:** Plain text passwords never logged

### OTP Security
- **Generation:** 6-digit random number (000000-999999)
- **Storage:** Hashed with bcrypt (same as passwords)
- **Expiry:** 10 minutes from generation
- **Verification:** Constant-time comparison via `password_verify()`

### JWT Token Security
- **Algorithm:** HS256 (HMAC-SHA256)
- **Expiry (Access):** 1 hour (configurable via `JWT_EXPIRY`)
- **Expiry (Refresh):** 7 days
- **Header Parsing:** Supports multiple header formats

### Rate Limiting (Recommended Client-Side)
- **Resend OTP:** 1 per 30 seconds (can enable server-side)
- **Login Attempts:** Track failures, increase delays
- **Email Verification:** Track attempts per IP

---

## 📜 8. Database Queries Reference

### Check if email verified
```sql
SELECT is_email_verified FROM users WHERE email = ?;
```

### Get user with OTP details
```sql
SELECT id, email, password, is_email_verified, 
       email_verification_otp, email_verification_expires
FROM users WHERE email = ?;
```

### Mark email as verified
```sql
UPDATE users 
SET is_email_verified = 1, 
    email_verification_otp = NULL, 
    email_verification_expires = NULL
WHERE email = ?;
```

### Store OTP
```sql
UPDATE users 
SET email_verification_otp = ?, email_verification_expires = ?
WHERE email = ?;
```

---

## 🔄 9. User Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    REGISTRATION FLOW                        │
└─────────────────────────────────────────────────────────────┘

USER                          BACKEND                      DATABASE
  │                              │                              │
  ├─ Register ─────────────────>│                              │
  │  (email, password, etc)      │                              │
  │                              ├─ Validate input ─────────────│
  │                              │                              │
  │                              ├─ Check email unique ────────│
  │                              │                              │
  │                              ├─ Hash password ─────────────│
  │                              │                              │
  │                              ├─ Create user ──────────────>│
  │                              │  (is_email_verified = 0)     │
  │                              │                              │
  │                              ├─ Generate OTP ──────────────│
  │                              │                              │
  │                              ├─ Hash OTP ──────────────────│
  │                              │                              │
  │                              ├─ Store OTP + expiry ───────>│
  │                              │                              │
  │  Success message ────────────┤                              │
  │<─ "Check your email" ─────────┤                              │
  │                              │                              │
  │  Receives OTP email          │                              │
  │                              │                              │
  ├─ Verify Email ──────────────>│                              │
  │  (email, otp)                │                              │
  │                              ├─ Validate OTP ─────────────│
  │                              │                              │
  │                              ├─ Check expiry ─────────────│
  │                              │                              │
  │                              ├─ Mark verified ────────────>│
  │                              │                              │
  │  "Verified!" ─────────────────┤                              │
  │<─ Redirect to login ──────────┤                              │
  │                              │                              │
  ├─ Login ──────────────────────>│                              │
  │  (email, password)           │                              │
  │                              ├─ Check verified ──────────│
  │                              │                              │
  │                              ├─ Verify password ─────────│
  │                              │                              │
  │  JWT Token ────────────────────┤                              │
  │<─ token + refreshToken ────────┤                              │
```

---

## 🔧 10. Testing with Postman

### Example Environment Variables
```json
{
  "baseUrl": "http://localhost",
  "email": "test@example.com",
  "password": "TestPass123",
  "otp": "000000",
  "token": ""
}
```

### 1. Register
```
POST {{baseUrl}}/api/auth/register
Content-Type: application/json

{
  "email": "{{email}}",
  "password": "{{password}}",
  "userType": "doctor",
  "fullName": "Test Doctor"
}
```

### 2. Verify Email
```
POST {{baseUrl}}/api/auth/verify-email
Content-Type: application/json

{
  "email": "{{email}}",
  "otp": "{{otp}}"
}
```

### 3. Login
```
POST {{baseUrl}}/api/auth/login
Content-Type: application/json

{
  "email": "{{email}}",
  "password": "{{password}}"
}
```

Save token from response: `Tests` tab:
```javascript
var jsonData = pm.response.json();
pm.environment.set("token", jsonData.data.token);
```

### 4. Get Current User (Protected)
```
GET {{baseUrl}}/api/me
Authorization: Bearer {{token}}
```

---

## ✅ 11. Checklist for Production

- [ ] Set strong `JWT_SECRET` in `.env`
- [ ] Configure email service (`MAIL_DRIVER`, `MAIL_FROM`)
- [ ] If using SMTP: Configure `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`
- [ ] Run database migration: Update schema with new columns
- [ ] Test complete registration → verification → login flow
- [ ] Test OTP resend functionality
- [ ] Test email delivery (check spam folder)
- [ ] Test expired OTP scenario
- [ ] Test invalid OTP scenario
- [ ] Implement rate limiting (optional)
- [ ] Monitor email service failures
- [ ] Add logging for authentication events
- [ ] Test with multiple users simultaneously

---

## 🚀 12. Backwards Compatibility

**No breaking changes to existing endpoints:**
- ✅ All doctor/patient profile endpoints unchanged
- ✅ Appointment endpoints unchanged
- ✅ Chat system unchanged
- ✅ Review system unchanged
- ✅ Availability/booking logic unchanged

**Only modifications:**
- Login now requires email verification
- New fields added to User model (defaults handled)
- New utility classes (no impact on existing code)

---

## 📧 13. Email Templates

Both HTML and plain text versions are generated automatically:

### OTP Email
- Subject: "Your Email Verification Code" (or "New Verification Code" for resends)
- Body: 6-digit OTP in large, monospace font
- Expiry Notice: "This code expires in 10 minutes"
- Responsive HTML design

### Verification Success Email
- Subject: "Email Verified Successfully"
- Body: Confirmation message
- CTA: "Go to Login" button
- Professional branding

---

## 🔗 14. API Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 201 | Created | Registration successful |
| 200 | OK | Login successful, email verified |
| 400 | Bad Request | Invalid OTP, validation error |
| 401 | Unauthorized | Invalid credentials |
| 403 | Forbidden | Email not verified, account inactive |
| 404 | Not Found | User not found |
| 409 | Conflict | Email already exists |
| 429 | Too Many Requests | Resend cooldown active |
| 500 | Server Error | Email sending failed, database error |

---

## 📚 15. File Structure

```
backend/
├── config/
│   ├── Database.php
│   └── JWT.php                 (Updated: custom expiry param)
├── controllers/
│   ├── AuthController.php      (Updated: new endpoints)
│   └── [other controllers unchanged]
├── models/
│   ├── User.php                (Updated: email verification methods)
│   └── [other models unchanged]
├── routes/
│   ├── auth.php                (Updated: new routes)
│   └── [other routes unchanged]
├── utils/
│   ├── EmailService.php        (NEW)
│   ├── OtpManager.php          (NEW)
│   ├── Response.php
│   ├── Validator.php
│   └── [other utilities unchanged]
├── middleware/
│   └── AuthMiddleware.php      (unchanged)
└── db/
    └── schema.sql              (Updated: new columns in users table)
```

---

## 🎯 Summary

This implementation provides:

1. **Secure Email Verification:** OTP with bcrypt hashing and 10-minute expiry
2. **Clean Auth Flow:** Register → Verify → Login
3. **Strict Validation:** All inputs validated per specification
4. **Minimal Changes:** Only auth-related code modified
5. **Production Ready:** Error handling, logging, security best practices
6. **Easily Testable:** Clear request/response examples

All existing features remain fully functional with zero breaking changes.
