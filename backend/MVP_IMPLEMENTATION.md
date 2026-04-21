# MVP Implementation Guide - Therapy Booking Platform

**Version:** 1.0 MVP  
**Updated:** April 2026  
**Scope:** Authentication, User Management, and Profile Setup

---

## 🎯 Overview

This document describes the complete MVP implementation for the therapy booking platform backend. The system is designed to be **clean**, **production-ready**, and **future-proof** with room for OTP verification without major refactoring.

### Key Features
- ✅ User registration (doctor/patient)
- ✅ User login with JWT tokens
- ✅ Password hashing (bcrypt)
- ✅ Refresh token support
- ✅ Doctor profile schema alignment
- ✅ Patient profile schema alignment
- ✅ File upload handling (documents, certificates, photos)
- ✅ Comprehensive validation
- ❌ Email OTP verification (reserved for future implementation)

---

## 📊 Database Schema Updates

### 1. Users Table
**Key Changes:**
- `is_email_verified` default changed to **1 (true)**
- Email verification is NOT required in MVP
- OTP fields are reserved for future implementation

```sql
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- bcrypt hashed
    user_type ENUM('admin', 'doctor', 'patient') NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    is_email_verified TINYINT(1) DEFAULT 1,  -- ✅ Changed
    email_verification_otp VARCHAR(255) NULL,  -- Reserved
    email_verification_expires DATETIME NULL,  -- Reserved
    created_at DATETIME DEFAULT UTC_TIMESTAMP(),
    updated_at DATETIME DEFAULT UTC_TIMESTAMP() ON UPDATE UTC_TIMESTAMP()
);
```

### 2. Doctor Profiles Table
**Key Changes:**
- New address fields: `street_address`, `city`, `state`, `country`, `postal_code`
- New fields: `sub_specializations`, `profile_photo`
- Removed deprecated fields

```sql
CREATE TABLE doctor_profiles (
    user_id CHAR(36) PRIMARY KEY,
    -- Personal Info
    full_name VARCHAR(255) NOT NULL,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say') NOT NULL,
    date_of_birth DATE NULL,
    phone_number VARCHAR(30) NULL,
    profile_photo VARCHAR(500) NULL,  -- File URL
    
    -- Professional
    primary_specialty VARCHAR(150) NOT NULL,
    sub_specializations JSON NULL,  -- ["Anxiety", "CBT"]
    years_of_experience SMALLINT DEFAULT 0,  -- 0-60
    license_number VARCHAR(100) UNIQUE NOT NULL,
    languages_spoken JSON NOT NULL,  -- ["English", "Malayalam"]
    
    -- Address
    street_address VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    state VARCHAR(100) NULL,
    country VARCHAR(100) NULL,
    postal_code VARCHAR(20) NULL,
    
    -- Consultation Settings
    video_enabled TINYINT(1) DEFAULT 1,
    video_rate DECIMAL(10,2) NULL,
    consultation_duration ENUM('30min', '45min', '60min') DEFAULT '60min',
    buffer_time ENUM('5min', '10min', '15min', '30min') DEFAULT '10min',
    
    -- Verification & Onboarding
    is_verified TINYINT(1) DEFAULT 0,
    verification_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    onboarding_percentage TINYINT DEFAULT 0,
    
    created_at DATETIME DEFAULT UTC_TIMESTAMP(),
    updated_at DATETIME DEFAULT UTC_TIMESTAMP() ON UPDATE UTC_TIMESTAMP()
);
```

### 3. Doctor Qualifications Table
**Key Changes:**
- Removed `specialization` field
- `year_of_completion` remains as YEAR type

```sql
CREATE TABLE doctor_qualifications (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    doctor_id CHAR(36) NOT NULL,
    degree VARCHAR(150) NOT NULL,  -- e.g., "B.Tech Psychology"
    institute_name VARCHAR(255) NOT NULL,
    year_of_completion YEAR NOT NULL,
    certificate_file VARCHAR(500) NULL,  -- File URL
    
    FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id) ON DELETE CASCADE
);
```

### 4. Patient Profiles Table
**Key Changes:**
- Replaced `first_name`, `last_name` with `full_name`
- Added `age` field
- Removed `date_of_birth` (replaced by age)

```sql
CREATE TABLE patient_profiles (
    user_id CHAR(36) PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,  -- ✅ Changed
    age TINYINT NULL,  -- 1-120
    gender ENUM('male', 'female', 'other') NOT NULL,
    phone_number VARCHAR(30) NULL,
    profile_photo VARCHAR(500) NULL,
    
    -- Medical Info (Optional)
    medical_history TEXT NULL,
    allergies JSON NULL,
    current_medications JSON NULL,
    
    created_at DATETIME DEFAULT UTC_TIMESTAMP(),
    updated_at DATETIME DEFAULT UTC_TIMESTAMP() ON UPDATE UTC_TIMESTAMP(),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 5. Documents Table
**Purpose:** Store uploaded documents (identity, license, certificates)

```sql
CREATE TABLE documents (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    document_type ENUM('license', 'certificate', 'qualification', 'identity') NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    uploaded_at DATETIME DEFAULT UTC_TIMESTAMP(),
    verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
    
    INDEX idx_user_type (user_id, document_type),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## 🔐 Authentication APIs

### POST /api/auth/register
Register a new user (doctor or patient).

**Request:**
```json
{
    "email": "dr.john@example.com",
    "password": "SecurePass123",
    "userType": "doctor",
    "fullName": "Dr. John Smith"
}
```

**Validation Rules:**
- `email`: Must be valid format and unique
- `password`: Minimum 6 characters
- `userType`: Either "doctor" or "patient"
- `fullName`: Required string

**Response (201):**
```json
{
    "success": true,
    "data": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "email": "dr.john@example.com",
        "userType": "doctor"
    }
}
```

**Error Cases:**
- `400`: Validation failed
- `409`: Email already exists

---

### POST /api/auth/login
Authenticate user and receive JWT tokens.

**Request:**
```json
{
    "email": "dr.john@example.com",
    "password": "SecurePass123"
}
```

**Validation Rules:**
- `email`: Valid format required
- `password`: Non-empty string

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "email": "dr.john@example.com",
        "userType": "doctor",
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
}
```

**Token Details:**
- `token`: Access token (expires in 1 hour)
- `refreshToken`: Refresh token (expires in 7 days)

**Error Cases:**
- `401`: Invalid credentials
- `403`: Account inactive
- `400`: Validation failed

---

### GET /api/auth/me
Get current authenticated user information.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "email": "dr.john@example.com",
        "userType": "doctor",
        "isEmailVerified": true
    }
}
```

**Error Cases:**
- `401`: Unauthorized (invalid token)
- `404`: User not found

---

## 👤 Doctor Profile API

### POST /api/doctor-profile/setup
Setup complete doctor profile.

**Request:**
```json
{
    "fullName": "Dr. John Smith",
    "gender": "male",
    "dateOfBirth": "1985-03-15",
    "phoneNumber": "+91-9876543210",
    "profilePhoto": "url_to_photo.jpg",
    "primarySpecialty": "Clinical Psychology",
    "subSpecializations": ["Anxiety", "Depression", "PTSD"],
    "yearsOfExperience": 12,
    "licenseNumber": "LIC-2024-001",
    "languagesSpoken": ["English", "Malayalam", "Hindi"],
    "streetAddress": "123 Medical Plaza",
    "city": "Bangalore",
    "state": "Karnataka",
    "country": "India",
    "postalCode": "560001"
}
```

**Validation Rules:**
- `dateOfBirth`: YYYY-MM-DD format
- `yearsOfExperience`: Integer between 0-60
- `languagesSpoken`: Array of strings
- `phoneNumber`: Valid phone format
- `profilePhoto`: File URL

---

## 🧑‍⚕️ Patient Profile API

### POST /api/patient-profile/setup
Setup complete patient profile.

**Request:**
```json
{
    "fullName": "Priya Sharma",
    "age": 28,
    "gender": "female",
    "phoneNumber": "+91-9876543211",
    "profilePhoto": "url_to_photo.jpg",
    "medicalHistory": "Previous anxiety treatment"
}
```

**Validation Rules:**
- `fullName`: Required string
- `age`: Integer between 1-120
- `gender`: one of ["male", "female", "other"]
- `phoneNumber`: Valid phone format

---

## 📄 Qualifications Management

### POST /api/doctor-profile/qualifications
Add a qualification to doctor's profile.

**Request:**
```json
{
    "degree": "M.Tech Psychology",
    "instituteName": "University of Delhi",
    "yearOfCompletion": 2012,
    "certificateFile": "url_to_certificate.pdf"
}
```

**Response (201):**
```json
{
    "success": true,
    "data": {
        "id": "qual-550e8400-e29b-41d4",
        "degree": "M.Tech Psychology",
        "instituteName": "University of Delhi",
        "yearOfCompletion": 2012,
        "certificateFile": "url_to_certificate.pdf"
    }
}
```

### GET /api/doctor-profile/qualifications
Get all qualifications for doctor.

**Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": "qual-550e8400-e29b-41d4",
            "degree": "M.Tech Psychology",
            "instituteName": "University of Delhi",
            "yearOfCompletion": 2012,
            "certificateFile": "url_to_certificate.pdf"
        }
    ]
}
```

### PUT /api/doctor-profile/qualifications/{id}
Update qualification details.

### DELETE /api/doctor-profile/qualifications/{id}
Delete a qualification.

---

## 📂 File Upload Handling

### Profile Photo Upload
**Endpoint:** `POST /api/profile/photo`

**File Validation:**
- Allowed types: JPG, PNG
- Max size: 5MB
- Multiple photos allowed (replaces previous)

**Request (multipart/form-data):**
```
POST /api/profile/photo
File: photo.jpg (form field: "file")
Authorization: Bearer <token>
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "fileUrl": "/uploads/profile-photos/user_id_timestamp.jpg"
    }
}
```

### Document Upload
**Endpoint:** `POST /api/documents/upload`

**File Validation:**
- Allowed types: JPG, PNG, PDF
- Max size: 10MB
- Multiple documents allowed

**Request (multipart/form-data):**
```
POST /api/documents/upload
File: license.pdf (form field: "file")
documentType: "license" (form field)
Authorization: Bearer <token>
```

**Response (201):**
```json
{
    "success": true,
    "data": {
        "id": "doc-550e8400-e29b-41d4",
        "documentType": "license",
        "fileUrl": "/uploads/documents/user_id/license_timestamp.pdf"
    }
}
```

### Certificate Upload
**Endpoint:** `POST /api/qualifications/{id}/certificate`

**File Validation:**
- Allowed types: JPG, PNG, PDF
- Max size: 10MB

**Response (200):**
```json
{
    "success": true,
    "data": {
        "certificateFile": "/uploads/certificates/doctor_id/qual_id_timestamp.pdf"
    }
}
```

---

## ✅ Validation Rules Reference

### Email Validation
- Valid format (RFC 5322)
- Unique in database
- Case-insensitive storage

### Password Validation
- Minimum 6 characters
- Hashed with bcrypt (cost=12)
- Never returned in API responses

### Date Validation (dateOfBirth)
- Format: `YYYY-MM-DD`
- Must be valid calendar date
- Example: `1985-03-15` ✅, `1985/03/15` ❌

### Age Validation
- Range: 1-120
- Type: integer
- Required for patient profiles

### Years of Experience Validation
- Range: 0-60
- Type: integer
- Required for doctor profiles

### Phone Number Validation
- Format: 10-15 characters
- Allowed: digits, spaces, hyphens, plus sign, parentheses
- Examples:
  - `+91-9876543210` ✅
  - `(555) 123-4567` ✅
  - `9876543210` ✅

### Gender Validation
- Values: "male", "female", "other", "prefer_not_to_say" (doctors), "other" (patients)
- Case-sensitive

### Array Fields Validation
- `languagesSpoken`: Array of strings
- `subSpecializations`: Array of strings
- `allergies`: Array of strings
- `currentMedications`: Array of strings

---

## 🔒 Security Considerations

### Password Security
```php
// Hashing
$hashedPassword = User::hashPassword($password);

// Verification
$isValid = User::verifyPassword($plainPassword, $hashedPassword);

// Uses bcrypt with cost=12
// More secure than plain hashing
```

### JWT Token Security
```php
// Access Token (1 hour expiry)
$token = JWT::encode([
    'user_id' => $userId,
    'user_type' => $userType,
    'email' => $email
]);

// Refresh Token (7 days expiry)
$refreshToken = JWT::encode([
    'user_id' => $userId,
    'user_type' => $userType,
    'email' => $email,
    'type' => 'refresh'
], 7 * 24 * 3600);
```

### Email Field Protection
**CRITICAL:** Email is NOT editable after registration
- Enforced at API level (profile update endpoints ignore email)
- Email uniqueness enforced at database level
- Email changes would require separate verification process

### File Upload Security
- File type validation (whitelist only)
- File size validation (10MB max)
- MIME type verification
- Unique filename generation
- Proper file permissions (644)

---

## 🚀 Future Implementation: Email OTP Verification

The backend is designed to support OTP verification **without major refactoring**. Here's how to add it:

### 1. Update Registration
```php
// In AuthController::register()
// Currently: is_email_verified = true
// Future:   is_email_verified = false
//           Generate and send OTP

$otp = OtpManager::generateOtp();
$hashedOtp = OtpManager::hashOtp($otp);
$this->userModel->storeOtp($email, $hashedOtp, expiryTime);
$this->emailService->sendOtpEmail($email, $otp);

// Response: "Please verify email with OTP sent to your email"
```

### 2. Add Verify Email Endpoint
```php
public function verifyEmail(): void {
    // Validate OTP against stored hash
    // Mark email as verified
    // Send success email
}
```

### 3. Add Resend OTP Endpoint
```php
public function resendOtp(): void {
    // Generate new OTP
    // Send to email
    // Enforce cooldown (optional)
}
```

### 4. Update Login Validation
```php
// Currently: Email verification NOT checked
// Future:   if (!$user['is_email_verified']) {
//               throw EmailNotVerifiedException
//           }
```

### Reserved Database Fields
```sql
-- Already in users table
email_verification_otp VARCHAR(255) NULL
email_verification_expires DATETIME NULL

-- No schema changes needed!
```

---

## 📋 Setup Instructions

### 1. Database Initialization
```bash
# Execute schema file
mysql -u root -p therapy_booking < db/schema.sql

# Or manually run SQL commands
CREATE DATABASE therapy_booking;
USE therapy_booking;
-- ... (copy schema.sql contents)
```

### 2. Environment Configuration
Create `.env` file:
```env
DATABASE_HOST=localhost
DATABASE_USER=root
DATABASE_PASSWORD=your_password
DATABASE_NAME=therapy_booking

JWT_SECRET=your_secret_key_here
JWT_EXPIRY=3600

APP_ENV=development
```

### 3. Directory Permissions
```bash
# Create upload directories
mkdir -p public/uploads/profile-photos
mkdir -p public/uploads/documents
mkdir -p public/uploads/certificates

# Set permissions
chmod -R 755 public/uploads
```

### 4. Testing with Postman
Import the provided `postman/Complete-Therapy-Booking-API.postman_collection.json`

**Test Sequence:**
1. POST /api/auth/register (create account)
2. POST /api/auth/login (get tokens)
3. GET /api/auth/me (verify authentication)
4. POST /api/doctor-profile/setup (setup profile)
5. POST /api/doctor-profile/qualifications (add qualification)

---

## 🔄 Error Handling

### Standard Error Response Format
```json
{
    "success": false,
    "message": "Description of error",
    "errors": {
        "field_name": ["Specific error message"]
    }
}
```

### Common HTTP Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad request (validation error)
- `401`: Unauthorized (invalid token)
- `403`: Forbidden (account inactive)
- `404`: Not found
- `409`: Conflict (email exists)
- `500`: Server error

---

## 📊 Database Relationships

```
users
├── doctor_profiles (1:1)
│   ├── doctor_qualifications (1:N)
│   ├── available_slots (1:N)
│   └── appointments (1:N)
├── patient_profiles (1:1)
│   └── appointments (1:N)
├── documents (1:N)
├── messages (1:N)
└── notifications (1:N)

appointments
├── messages (1:N)
├── consultation_sessions (1:1)
└── reviews (1:N)
```

---

## 📝 Code Organization

```
backend/
├── config/
│   ├── Database.php         # DB connection
│   └── JWT.php              # Token handling
├── controllers/
│   ├── AuthController.php   # ✅ Updated
│   ├── DoctorProfileController.php
│   └── PatientProfileController.php
├── models/
│   ├── User.php             # ✅ Updated
│   ├── DoctorProfile.php    # ✅ Updated
│   └── PatientProfile.php   # ✅ Updated
├── middleware/
│   └── AuthMiddleware.php   # Authentication
├── utils/
│   ├── Validator.php        # ✅ Updated
│   ├── Response.php         # API responses
│   └── FileUploadHandler.php # ✅ New
├── routes/
│   └── auth.php             # ✅ Updated
└── db/
    └── schema.sql           # ✅ Updated
```

---

## ✨ Production Checklist

- [ ] Database migrated
- [ ] JWT_SECRET configured (strong, random)
- [ ] Upload directories created with proper permissions
- [ ] HTTPS enabled on server
- [ ] CORS properly configured
- [ ] Rate limiting implemented
- [ ] Logging configured
- [ ] Error handling in production mode
- [ ] Database backups scheduled
- [ ] API documentation updated
- [ ] Postman collection verified
- [ ] Load testing completed

---

## 📞 Support & Maintenance

For questions or issues:
1. Check logs: `error_log`
2. Verify database connectivity
3. Ensure JWT_SECRET is configured
4. Check file upload permissions
5. Review validation rules in code

---

**Last Updated:** April 20, 2026  
**Status:** MVP Ready for Deployment ✅
