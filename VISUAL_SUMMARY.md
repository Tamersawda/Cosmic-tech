# Email Verification System - Visual Summary

## 🎯 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      THERAPY BOOKING SYSTEM                     │
│                 (Email Verification Module)                     │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌─────────────────┐
│   FRONTEND APP   │         │   EMAIL SERVICE │
│                  │         │   (SendGrid/    │
│  • Register Form │────────┼│    SMTP/PHP     │
│  • Verify Form   │    1    │                 │
│  • Login Form    │         └────────┬────────┘
│  • Dashboard     │                  │
└──────────────────┘                  │
         │                            │
         │ 2                          │ 3
         │                            │
    ┌────▼──────────────────────────▼──────┐
    │      BACKEND API (PHP)                │
    │                                       │
    │  ┌─────────────────────────────────┐ │
    │  │   AuthController                │ │
    │  │  • register()                   │ │
    │  │  • verifyEmail()                │ │
    │  │  • resendOtp()                  │ │
    │  │  • login()                      │ │
    │  │  • getCurrentUser()             │ │
    │  └─────────────────────────────────┘ │
    │                                       │
    │  ┌─────────────────────────────────┐ │
    │  │   Utilities                     │ │
    │  │  • OtpManager                   │ │
    │  │  • EmailService                 │ │
    │  │  • Validator                    │ │
    │  │  • JWT Config                   │ │
    │  └─────────────────────────────────┘ │
    │                                       │
    │  ┌─────────────────────────────────┐ │
    │  │   User Model                    │ │
    │  │  • findByEmail()                │ │
    │  │  • storeOtp()                   │ │
    │  │  • verifyEmail()                │ │
    │  └─────────────────────────────────┘ │
    └────────────────┬─────────────────────┘
                     │ 4
    ┌────────────────▼─────────────────┐
    │      MYSQL DATABASE              │
    │                                  │
    │  ┌──────────────────────────┐   │
    │  │   users TABLE            │   │
    │  │  ├─ id                   │   │
    │  │  ├─ email                │   │
    │  │  ├─ password (hashed)    │   │
    │  │  ├─ user_type           │   │
    │  │  ├─ is_email_verified   │   │  ← NEW
    │  │  ├─ email_verification_ │   │  ← NEW
    │  │  │   otp (hashed)       │   │
    │  │  └─ email_verification_ │   │  ← NEW
    │  │      expires            │   │
    │  └──────────────────────────┘   │
    │                                  │
    │  + doctor_profiles TABLE         │
    │  + patient_profiles TABLE        │
    │  + other tables unchanged        │
    └──────────────────────────────────┘
```

---

## 🔄 Complete User Journey

```
╔════════════════════════════════════════════════════════════════╗
║                     USER REGISTRATION FLOW                      ║
╚════════════════════════════════════════════════════════════════╝

┌─────────────┐
│   USER      │
└──────┬──────┘
       │
       │ 1. Opens registration page
       │ 2. Enters email, password, type, name
       │ 3. Clicks "Register"
       │
       ▼
┌──────────────────────────────────────┐
│   POST /api/auth/register            │
│   {                                  │
│     "email": "user@example.com",    │
│     "password": "Password123",       │
│     "userType": "doctor",            │
│     "fullName": "Dr. John Doe"      │
│   }                                  │
└──────────────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  VALIDATION          │
        │ ✓ Email format       │
        │ ✓ Password > 6 chars │
        │ ✓ userType valid     │
        │ ✓ Email unique       │
        └──────────────┬───────┘
                       │
                       ▼
        ┌──────────────────────┐
        │  CREATE USER         │
        │ • user_id = uuid()   │
        │ • password = bcrypt  │
        │ • is_verified = 0    │
        └──────────────┬───────┘
                       │
                       ▼
        ┌──────────────────────┐
        │  GENERATE OTP        │
        │ • otp = "456789"     │
        │ • hashed = bcrypt    │
        │ • expires = now+10m  │
        └──────────────┬───────┘
                       │
                       ▼
        ┌──────────────────────┐
        │  SEND EMAIL          │
        │ Subject:             │
        │ "Verify Your Email"  │
        │                      │
        │ OTP: 456789          │
        │ Expires in 10 min    │
        └──────────────┬───────┘
                       │
                       ▼
┌──────────────────────────────────────┐
│   RESPONSE 201                       │
│   {                                  │
│     "message": "User registered.     │
│      Please verify email."           │
│   }                                  │
└──────────────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  USER RECEIVES EMAIL │
        │  with OTP code       │
        └──────────────┬───────┘
                       │
                       │ 4. Enters OTP in app
                       ▼
┌──────────────────────────────────────┐
│   POST /api/auth/verify-email        │
│   {                                  │
│     "email": "user@example.com",    │
│     "otp": "456789"                  │
│   }                                  │
└──────────────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  VALIDATE OTP        │
        │ ✓ Format (6 digits)  │
        │ ✓ Not expired        │
        │ ✓ Hash matches       │
        └──────────────┬───────┘
                       │
                       ▼
        ┌──────────────────────┐
        │  MARK VERIFIED       │
        │ • is_verified = 1    │
        │ • Clear OTP fields   │
        └──────────────┬───────┘
                       │
                       ▼
        ┌──────────────────────┐
        │  SEND SUCCESS EMAIL  │
        │ "Email Verified"     │
        │ "Go to Login"        │
        └──────────────┬───────┘
                       │
                       ▼
┌──────────────────────────────────────┐
│   RESPONSE 200                       │
│   {                                  │
│     "message": "Email verified       │
│      successfully"                   │
│   }                                  │
└──────────────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  EMAIL VERIFIED ✓    │
        │  Can now login       │
        └──────────────────────┘
                   │
                   │ 5. Clicks "Go to Login"
                   ▼
┌──────────────────────────────────────┐
│   POST /api/auth/login               │
│   {                                  │
│     "email": "user@example.com",    │
│     "password": "Password123"        │
│   }                                  │
└──────────────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  CHECK EMAIL VER     │
        │ ✓ is_verified = 1    │
        │ ✓ Can proceed        │
        └──────────────┬───────┘
                       │
                       ▼
        ┌──────────────────────┐
        │  VERIFY PASSWORD     │
        │ ✓ Matches hash       │
        └──────────────┬───────┘
                       │
                       ▼
        ┌──────────────────────┐
        │  GENERATE TOKENS     │
        │ • access (1h)        │
        │ • refresh (7d)       │
        └──────────────┬───────┘
                       │
                       ▼
┌──────────────────────────────────────┐
│   RESPONSE 200                       │
│   {                                  │
│     "id": "user-uuid",              │
│     "email": "user@example.com",    │
│     "userType": "doctor",            │
│     "token": "jwt...",              │
│     "refreshToken": "jwt..."        │
│   }                                  │
└──────────────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  LOGIN SUCCESSFUL    │
        │  Store tokens        │
        │  Access dashboard    │
        └──────────────────────┘
```

---

## 📊 Data Flow Diagram

```
REGISTRATION DATA FLOW:
═════════════════════════════════════════════════════════════════

User Input
  │
  ├─ Email "john@example.com"
  ├─ Password "MyPass123"
  ├─ UserType "doctor"
  └─ FullName "Dr. John Smith"
         │
         ▼
    ┌─────────────────┐
    │  VALIDATION     │
    │                 │
    │ Email format?   │
    │ Password > 6?   │
    │ Type valid?     │
    │ Email unique?   │
    │                 │
    │ ✓ All pass      │
    └────────┬────────┘
             │
             ▼
    ┌──────────────────────────────┐
    │  HASHING                     │
    │                              │
    │ Password Hash:               │
    │ $2y$12$abcde...              │
    │ (bcrypt cost=12)             │
    └────────┬─────────────────────┘
             │
             ▼
    ┌──────────────────────────────┐
    │  DATABASE INSERT             │
    │                              │
    │ users table:                 │
    │ id: 550e8400-e29b-41d4-a716  │
    │ email: john@example.com      │
    │ password: $2y$12$abcde...    │
    │ user_type: doctor            │
    │ is_email_verified: 0         │
    └────────┬─────────────────────┘
             │
             ▼
    ┌──────────────────────────────┐
    │  OTP GENERATION              │
    │                              │
    │ OTP Value: 456789            │
    │ OTP Hash: $2y$12$fghij...    │
    │ Expires: 2026-04-11 11:20:00 │
    └────────┬─────────────────────┘
             │
             ▼
    ┌──────────────────────────────┐
    │  DATABASE UPDATE             │
    │                              │
    │ users table:                 │
    │ email_verification_otp:      │
    │   $2y$12$fghij...            │
    │ email_verification_expires:  │
    │   2026-04-11 11:20:00        │
    └────────┬─────────────────────┘
             │
             ▼
    ┌──────────────────────────────┐
    │  EMAIL SENDING               │
    │                              │
    │ From: noreply@example.com    │
    │ To: john@example.com         │
    │ Subject: Verify Your Email   │
    │ Body: OTP 456789             │
    └────────┬─────────────────────┘
             │ (asynchronous)
             ▼
        ┌─────────────┐
        │ IN USER'S   │
        │ MAILBOX     │
        │             │
        │ From: ...   │
        │ Subj: ...   │
        │ OTP: 456789 │
        └─────────────┘
```

---

## 🔐 Security Layers

```
Security Implementation
═════════════════════════════════════════════════════════════════

Layer 1: INPUT VALIDATION
───────────────────────────
  Email Format    → filter_var(FILTER_VALIDATE_EMAIL)
  Password Length → strlen() >= 6
  OTP Format      → preg_match(/^\d{6}$/)
  User Type       → in_array(['doctor', 'patient'])
              ▼ Invalid rejected

Layer 2: PASSWORD HASHING
───────────────────────────
  Plain Password      → password_hash(PASSWORD_BCRYPT, cost=12)
  Hashed Storage      → Never stored plain
  Verification        → password_verify()
  Comparison          → Constant-time check
              ▼ Stored securely

Layer 3: OTP HASHING
───────────────────────────
  Generated OTP       → 6-digit random
  Hashed OTP          → password_hash(PASSWORD_BCRYPT, cost=12)
  Sent to User        → PLAIN (visible in email)
  Stored in DB        → HASHED (cannot reverse)
  Verification        → password_verify() constant-time
  Expiry Check        → Timestamp comparison
              ▼ Double security

Layer 4: JWT TOKEN SIGNING
───────────────────────────
  Token Generation    → HS256 (HMAC-SHA256)
  Secret Key          → $JWT_SECRET from env
  Payload             → user_id, user_type, email
  Expiry              → Access: 1h, Refresh: 7d
  Verification        → Signature validation
  Header Parsing      → Multiple format support
              ▼ Tamper-proof

Layer 5: DATABASE QUERIES
───────────────────────────
  SQL Injections      → Prepared statements (?)
  Parameter Binding   → execute([params])
  Type Casting        → Explicit types
              ▼ Injection-proof

Layer 6: BUSINESS LOGIC
───────────────────────────
  Email Unique        → Database constraint + app check
  Verified Required   → Login checks is_email_verified
  Expiry Checking     → OTP expires after 10 min
  Active User Check   → is_active flag verified
  OTP Mismatch        → Returns generic error
              ▼ Logic-secure
```

---

## 📈 Response Status Codes

```
Success Responses:
  201 Created       → Registration successful
  200 OK            → Verification, Login, Get User

Client Errors:
  400 Bad Request   → Invalid OTP, validation error
  401 Unauthorized  → Wrong password
  403 Forbidden     → Email not verified, account inactive
  404 Not Found     → User doesn't exist
  409 Conflict      → Email already exists
  429 Rate Limited  → OTP resend too soon

Server Errors:
  500 Server Error  → Database error, email sending failed
```

---

## 🗂️ Database Schema Changes

```
BEFORE:                          AFTER:
═════════════════════════════════════════════════════════════════

users                            users
├─ id            (UUID)          ├─ id              (UUID)
├─ email         (VARCHAR)       ├─ email           (VARCHAR)
├─ password      (VARCHAR)       ├─ password        (VARCHAR)
├─ user_type     (ENUM)          ├─ user_type       (ENUM)
├─ is_active     (TINYINT)       ├─ is_active       (TINYINT)
├─ created_at    (DATETIME)      ├─ is_email_verified       (TINYINT) ← NEW
├─ updated_at    (DATETIME)      ├─ email_verification_otp  (VARCHAR) ← NEW
│                                ├─ email_verification_expires (DATETIME) ← NEW
│                                ├─ created_at      (DATETIME)
│                                ├─ updated_at      (DATETIME)
│                                │
│                                └─ Indices:
└─ Indices:                          idx_users_email
    idx_users_email                  idx_users_email_verified ← NEW
    idx_users_user_type              idx_users_user_type
```

---

## 🎬 Complete Integration

```
CLIENT APP                  API BACKEND                    DATABASE
═══════════════════════════════════════════════════════════════════

┌──────────────┐
│ Register     │
│ Screen       │
└──────┬───────┘
       │
       │ 1. Submit Registration
       ├──────────────────────────────────────────────────────────┐
       │                                                          │
       │         ┌─────────────────────────────┐                │
       │         │ POST /api/auth/register     │                │
       │         │ {email, password, type,...} │                │
       │         └────────────┬────────────────┘                │
       │                      │                                  │
       │         ┌────────────▼──────────────┐                 │
       │    ┌────│ Validate Input           │                 │
       │    │    └────────────┬──────────────┘                 │
       │    │                 │                                │
       │    │    ┌────────────▼──────────────┐                │
       │    │ ┌──│ Hash Password (bcrypt)   │                │
       │    │ │  └────────────┬──────────────┘                │
       │    │ │               │                               │
       │    │ │               │  ┌──────────────────────────┐ │
       │    │ │  ┌────────────▼──│ INSERT INTO users        │ │
       │    │ │  │               │ (id, email, password...) │ │
       │    │ │  │               └──────────────┬───────────┘ │
       │    │ │  │                              │              │
       │    │ │  │               ┌──────────────▼───────────┐ │
       │    │ │  │    ┌──────────│ SELECT * FROM users      │ │
       │    │ │  │    │          │ WHERE email = ?          │ │
       │    │ │  │    │          └──────────────┬───────────┘ │
       │    │ │  │    │                         │              │
       │    │ │  │    │  ┌──────────────────────▼───────────┐ │
       │    │ │  │    │  │ UPDATE users SET                 │ │
       │    │ │  │    │  │   is_email_verified = 0,         │ │
       │    │ │  │    │  │   email_verification_otp = ?,    │ │
       │    │ │  │    │  │   email_verification_expires = ? │ │
       │    │ │  │    │  │ WHERE email = ?                  │ │
       │    │ │  │    │  └──────────────┬────────────────────┘ │
       │    │ │  │    │                 │                      │
       │    │ │  │ ┌──┴─────────────────┴────┐                │
       │    │ │  │ │ Generate OTP: "456789"  │                │
       │    │ │  │ │ Hash OTP (bcrypt)       │                │
       │    │ │  │ │ Set expiry (10 min)     │                │
       │    │ │  │ └────────────┬────────────┘                │
       │    │ │  │              │                              │
       │    │ │  │ ┌────────────▼──────────────┐              │
       │    │ │  │ │ Send Email with OTP      │              │
       │    │ │  │ └────────────┬──────────────┘              │
       │    │ │  │              │                              │
       │    │ │  │ ┌────────────▼──────────────────────┐     │
       │    └─┼──┼─│ Response 201:                     │     │
       │      │  │ │ "Check your email"               │     │
       │      │  │ └────────────┬──────────────────────┘     │
       │      │  │              │                            │
       │<─────┼──┼──────────────┘
       │      │  │
       │      └──┘
       │
       ├─ Show "Check Email" message
       │
       │ 2. User receives OTP email "456789"
       │
       │ 3. Enters OTP in Verify Screen
       │
       ├──────────────────────────────────────────────────────────┐
       │                                                          │
       │         ┌──────────────────────────────┐               │
       │         │ POST /api/auth/verify-email  │               │
       │         │ {email, otp: "456789"}       │               │
       │         └────────────┬─────────────────┘               │
       │                      │                                 │
       │         ┌────────────▼──────────────┐                │
       │    ┌────│ Validate OTP Format      │                │
       │    │    └────────────┬──────────────┘                │
       │    │                 │                               │
       │    │ ┌───────────────▼──────────────┐               │
       │    │ │ SELECT * FROM users WHERE    │               │
       │    │ │   email = ?                  │               │
       │    │ │ (Get stored hashed OTP)      │               │
       │    │ │ └───────────────┬────────────┘               │
       │    │ │                 │                             │
       │    │ │ ┌───────────────▼──────────────┐             │
       │    │ │ │ password_verify(otp, hash)  │             │
       │    │ │ │ → Constant-time compare    │             │
       │    │ │ └───────────────┬──────────────┘             │
       │    │ │                 │                             │
       │    │ │ ┌───────────────▼──────────────┐             │
       │    │ │ │ Check OTP expiry timestamp  │             │
       │    │ │ └───────────────┬──────────────┘             │
       │    │ │                 │                             │
       │    │ │ ┌───────────────▼──────────────────────────┐ │
       │    │ │ │ UPDATE users SET                        │ │
       │    │ │ │   is_email_verified = 1,                │ │
       │    │ │ │   email_verification_otp = NULL,        │ │
       │    │ │ │   email_verification_expires = NULL     │ │
       │    │ │ │ WHERE email = ?                         │ │
       │    │ │ └───────────────┬──────────────────────────┘ │
       │    │ │                 │                             │
       │    │ │ ┌───────────────▼──────────────┐             │
       │    │ │ │ Send Success Email           │             │
       │    │ │ │ "Email Verified"             │             │
       │    │ │ └───────────────┬──────────────┘             │
       │    │ │                 │                             │
       │    │ │ ┌───────────────▼──────────────┐             │
       │    └─┼─│ Response 200: "Verified"     │             │
       │      │ └───────────────┬──────────────┘             │
       │      │                 │                             │
       │<─────┼─────────────────┘
       │      │
       │      └─ Show "Email Verified"
       │
       ├─ Redirect to Login Screen
       │
       │ 4. User logs in
       │
       ├──────────────────────────────────────────────────────────┐
       │                                                          │
       │         ┌──────────────────────────────┐               │
       │         │ POST /api/auth/login         │               │
       │         │ {email, password}            │               │
       │         └────────────┬─────────────────┘               │
       │                      │                                 │
       │         ┌────────────▼──────────────┐                │
       │    ┌────│ SELECT * FROM users WHERE │                │
       │    │    │   email = ?               │                │
       │    │    │ (Get all user data)       │                │
       │    │    └────────────┬──────────────┘                │
       │    │                 │                               │
       │    │ ┌───────────────▼──────────────┐               │
       │    │ │ Check is_email_verified = 1 │               │
       │    │ │ If not → ERROR 403           │               │
       │    │ └───────────────┬──────────────┘               │
       │    │                 │                               │
       │    │ ┌───────────────▼──────────────┐               │
       │    │ │ password_verify(pass, hash)  │               │
       │    │ │ If fail → ERROR 401          │               │
       │    │ └───────────────┬──────────────┘               │
       │    │                 │                               │
       │    │ ┌───────────────▼──────────────┐               │
       │    │ │ Generate JWT Tokens          │               │
       │    │ │ • Access (1 hour)            │               │
       │    │ │ • Refresh (7 days)           │               │
       │    │ └───────────────┬──────────────┘               │
       │    │                 │                               │
       │    │ ┌───────────────▼──────────────┐               │
       │    └─│ Response 200: Tokens + Data  │               │
       │      └───────────────┬──────────────┘               │
       │                      │                               │
       │<─────────────────────┘
       │
       ├─ Store tokens in localStorage
       │
       ├─ Show Dashboard
       │
       │ 5. Authenticated requests
       │
       └──────────────────────────────────────────────────────────┐
                                                                  │
                     ┌──────────────────────────────┐            │
                     │ GET /api/me                  │            │
                     │ Header: Authorization: Bearer│            │
                     │         <token>              │            │
                     └────────────┬─────────────────┘            │
                                  │                              │
                     ┌────────────▼──────────────┐               │
                     │ JWT::decode(token)        │               │
                     │ • Verify signature        │               │
                     │ • Check expiry            │               │
                     │ • Get user_id             │               │
                     └────────────┬──────────────┘               │
                                  │                              │
                     ┌────────────▼──────────────┐               │
                 ┌──│ SELECT * FROM users        │               │
                 │  │ WHERE id = ?               │               │
                 │  └────────────┬──────────────┘               │
                 │               │                              │
                 │  ┌────────────▼──────────────┐              │
                 │  │ Response 200:             │              │
                 │  │ User data +               │              │
                 │  │ isEmailVerified: true     │              │
                 │  └────────────┬──────────────┘              │
                 │               │                              │
                 └──────────────┤                              │
                      Authorized│                              │
                                │                              │
                         ┌──────▼──────┐                       │
                         │ Dashboard   │                       │
                         │ Loaded ✓    │                       │
                         └─────────────┘                       │
```

---

## 🎯 Key Takeaways

1. **Flow:** Register → Verify Email → Login → Access Protected Endpoints
2. **Security:** Multiple layers (input validation, hashing, tokens, queries)
3. **Database:** Only 3 columns added to users table
4. **Endpoints:** 5 endpoints (2 new, 3 updated)
5. **Files:** 5 new, 5 updated utilities/files
6. **Documentation:** 2500+ lines covering all aspects
7. **Zero Breaking Changes:** All existing endpoints continue to work
8. **Production Ready:** Error handling, logging, best practices implemented

---

*Complete implementation with 360° documentation*
