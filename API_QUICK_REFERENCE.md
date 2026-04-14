# Email Verification API - Quick Reference

## 🚀 Quick Start

### 1. Register
```bash
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "Password123",
  "userType": "doctor|patient",
  "fullName": "Full Name"
}
```
**Response:** `{ "message": "User registered. Please verify email." }`

### 2. Verify Email
```bash
POST /api/auth/verify-email
Content-Type: application/json

{
  "email": "user@example.com",
  "otp": "123456"
}
```
**Response:** `{ "message": "Email verified successfully" }`

### 3. Resend OTP
```bash
POST /api/auth/resend-otp
Content-Type: application/json

{
  "email": "user@example.com"
}
```
**Response:** `{ "message": "OTP sent to your email" }`

### 4. Login
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "Password123"
}
```
**Response:** 
```json
{
  "id": "user-id",
  "email": "user@example.com",
  "userType": "doctor",
  "token": "jwt-token",
  "refreshToken": "refresh-token"
}
```

### 5. Get Current User (Protected)
```bash
GET /api/me
Authorization: Bearer <token>
```
**Response:**
```json
{
  "id": "user-id",
  "email": "user@example.com",
  "userType": "doctor",
  "isEmailVerified": true
}
```

---

## 📋 Validation Rules

| Field | Min/Max | Pattern | Example |
|-------|---------|---------|---------|
| email | - | valid email | user@example.com |
| password | 6-255 | string | MyPass123 |
| userType | - | doctor\|patient | doctor |
| fullName | 1-255 | string | John Doe |
| otp | 6 digits | `^\d{6}$` | 123456 |

---

## ⚡ Key Info

- **OTP Expiry:** 10 minutes
- **Token Expiry:** 1 hour (access), 7 days (refresh)
- **Resend Cooldown:** 30 seconds (optional)
- **OTP Hashing:** bcrypt (cost=12)
- **Password Hashing:** bcrypt (cost=12)
- **JWT Algorithm:** HS256

---

## ❌ Error Codes

| Code | Message | Meaning |
|------|---------|---------|
| 400 | Invalid OTP | Wrong code entered |
| 400 | OTP expired | Code older than 10 min |
| 400 | Email already verified | Already verified |
| 401 | Invalid email or password | Wrong credentials |
| 403 | EMAIL_NOT_VERIFIED | Email not verified yet |
| 403 | Account inactive | User deactivated |
| 404 | User not found | Email doesn't exist |
| 409 | Email already exists | Registration duplicate |

---

## 🔐 Security Checklist

- ✅ Passwords hashed with bcrypt
- ✅ OTP hashed before storage
- ✅ OTP has 10-minute expiry
- ✅ Email verification required for login
- ✅ JWT tokens with 1-hour expiry
- ✅ Refresh tokens with 7-day expiry
- ✅ All inputs validated
- ✅ SQL injection protected (prepared statements)
- ✅ XSS protected (JSON responses)
- ✅ CORS ready

---

## 📝 Status Codes

- **201:** Created (user registered)
- **200:** OK (verified, logged in)
- **400:** Bad Request (validation error)
- **401:** Unauthorized (invalid credentials)
- **403:** Forbidden (not verified, inactive)
- **404:** Not Found (user doesn't exist)
- **409:** Conflict (email exists)
- **429:** Rate Limited (resend too soon)
- **500:** Server Error

---

## 🔗 Files Modified

1. `db/schema.sql` - Added verification columns
2. `models/User.php` - Added verification methods
3. `controllers/AuthController.php` - New endpoints
4. `routes/auth.php` - New routes
5. `config/JWT.php` - Custom expiry support

## 📦 New Files

1. `utils/EmailService.php` - Email sending
2. `utils/OtpManager.php` - OTP handling
3. `db/migration_email_verification.sql` - Migration script
4. `AUTHENTICATION_GUIDE.md` - Full documentation
5. `AUTHENTICATION_TESTING.md` - Test examples

---

## 🚦 Flow Diagram

```
Register → Email with OTP → Verify OTP → Login → JWT Token
```

---

## 💡 Tips

- OTP is sent via email automatically
- Use same email for all endpoints
- Token must be in `Authorization: Bearer <token>` header
- Only verified users can login
- Old OTP invalid after resend
- OTP expires after 10 minutes
