# Therapy Booking Platform - Database Schema Documentation

**Version:** 1.0  
**Database:** MySQL  
**Last Updated:** April 5, 2026

---

## Table of Contents
1. [Users](#1-users-table)
2. [Doctor Profiles](#2-doctor-profiles-table)
3. [Doctor Qualifications](#3-doctor-qualifications-table)
4. [Doctor Weekly Schedule](#4-doctor-weekly-schedule-table)
5. [Patient Profiles](#5-patient-profiles-table)
6. [Appointments](#6-appointments-table)
7. [Consultation Sessions](#7-consultation-sessions-table)
8. [Messages](#8-messages-table)
9. [Reviews](#9-reviews-table)
10. [Documents](#10-documents-table)
11. [Notifications](#11-notifications-table)
12. [Refresh Tokens](#12-refresh-tokens-table)

---

## 1. Users Table

**Purpose:** Core user authentication and account management for all users (admin, doctor, patient)

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY, NOT NULL | UUID identifier |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User email address |
| `password` | VARCHAR(255) | NOT NULL | Hashed password (bcrypt/argon2) |
| `user_type` | ENUM | NOT NULL | Values: 'admin', 'doctor', 'patient' |
| `is_active` | TINYINT(1) | DEFAULT 1 | Account active status |
| `created_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Account creation timestamp |
| `updated_at` | DATETIME | AUTO UPDATE | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE KEY (email)
- INDEX (email)
- INDEX (user_type)

---

## 2. Doctor Profiles Table

**Purpose:** Detailed professional information about doctors

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `user_id` | CHAR(36) | PRIMARY KEY, FK → users.id | References user account |
| **Personal Info** |
| `full_name` | VARCHAR(255) | NOT NULL | Doctor's full name |
| `gender` | ENUM | NOT NULL | Values: 'male', 'female', 'other', 'prefer_not_to_say' |
| `date_of_birth` | DATE | NULL | Date of birth |
| `phone_number` | VARCHAR(30) | NULL | Contact phone number |
| `profile_photo` | VARCHAR(500) | NULL | Photo URL |
| **Professional Info** |
| `primary_specialty` | VARCHAR(150) | NOT NULL | Main specialization (e.g., "Child Psychology") |
| `sub_specializations` | JSON | NULL | Array of additional specializations |
| `years_of_experience` | SMALLINT | DEFAULT 0 | Years of professional experience |
| `license_number` | VARCHAR(100) | UNIQUE, NOT NULL | Professional license number |
| `medical_council` | ENUM | DEFAULT 'Other' | Values: 'AMA', 'GMC', 'MCI', 'RCP', 'Other' |
| `languages_spoken` | JSON | NOT NULL | Array of languages (e.g., ["English", "Malayalam"]) |
| **Consultation Settings** |
| `video_enabled` | TINYINT(1) | DEFAULT 1 | Video consultation available |
| `video_rate` | DECIMAL(10,2) | NULL | Video consultation rate |
| `audio_enabled` | TINYINT(1) | DEFAULT 1 | Audio consultation available |
| `audio_rate` | DECIMAL(10,2) | NULL | Audio consultation rate |
| `follow_up_rate` | DECIMAL(10,2) | NULL | Follow-up consultation rate |
| `consultation_duration` | ENUM | DEFAULT '60min' | Values: '30min', '45min', '60min' |
| `buffer_time` | ENUM | DEFAULT '10min' | Values: '5min', '10min', '15min', '30min' |
| `instant_booking_enabled` | TINYINT(1) | DEFAULT 0 | Allow instant bookings |
| **Location** |
| `street_address` | VARCHAR(255) | NULL | Street address |
| `city` | VARCHAR(100) | NULL | City name |
| `state` | VARCHAR(100) | NULL | State/Region |
| `country` | VARCHAR(100) | NULL | Country |
| `postal_code` | VARCHAR(20) | NULL | Postal/Zip code |
| `latitude` | DECIMAL(10,7) | NULL | Geographic latitude |
| `longitude` | DECIMAL(10,7) | NULL | Geographic longitude |
| **Verification** |
| `is_verified` | TINYINT(1) | DEFAULT 0 | Profile verification status |
| `verification_status` | ENUM | DEFAULT 'pending' | Values: 'pending', 'approved', 'rejected' |
| `trust_badge_earned` | TINYINT(1) | DEFAULT 0 | Trust badge status |
| **Onboarding** |
| `onboarding_current_step` | TINYINT | DEFAULT 1 | Current onboarding step |
| `onboarding_completed_steps` | JSON | NULL | Array of completed steps (e.g., [1, 2, 3]) |
| `onboarding_percentage` | TINYINT | DEFAULT 0 | Onboarding completion percentage |
| `created_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Profile creation timestamp |
| `updated_at` | DATETIME | AUTO UPDATE | Last update timestamp |

**Indexes:**
- PRIMARY KEY (user_id)
- UNIQUE KEY (license_number)
- INDEX (primary_specialty)
- INDEX (years_of_experience)
- INDEX (is_verified)

---

## 3. Doctor Qualifications Table

**Purpose:** Store educational qualifications and certifications for doctors

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `doctor_id` | CHAR(36) | NOT NULL, FK → doctor_profiles.user_id | References doctor |
| `institute_name` | VARCHAR(255) | NOT NULL | Educational institution name |
| `degree` | VARCHAR(150) | NOT NULL | Degree earned (e.g., "MD", "PhD") |
| `specialization` | VARCHAR(150) | NULL | Specialization within degree |
| `year_of_completion` | YEAR | NOT NULL | Year degree was completed |
| `certificate_file` | VARCHAR(500) | NULL | Certificate file URL |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (doctor_id)

---

## 4. Doctor Weekly Schedule Table

**Purpose:** Define weekly recurring availability schedule for each doctor

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `doctor_id` | CHAR(36) | NOT NULL, FK → doctor_profiles.user_id | References doctor |
| `day_of_week` | TINYINT | NOT NULL | Day number (0=Sunday, 6=Saturday) |
| `is_available` | TINYINT(1) | DEFAULT 0 | Doctor available on this day |
| `start_time` | TIME | NULL | Start working time (e.g., "09:00:00") |
| `end_time` | TIME | NULL | End working time (e.g., "17:00:00") |
| `break_times` | JSON | NULL | Array of breaks (e.g., [{"start":"13:00","end":"14:00"}]) |

**Constraints:**
- UNIQUE KEY (doctor_id, day_of_week)
- CHECK (day_of_week BETWEEN 0 AND 6)

**Indexes:**
- PRIMARY KEY (id)

---

## 5. Patient Profiles Table

**Purpose:** Detailed personal and medical information about patients

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `user_id` | CHAR(36) | PRIMARY KEY, FK → users.id | References user account |
| **Personal Info** |
| `first_name` | VARCHAR(100) | NOT NULL | Patient's first name |
| `last_name` | VARCHAR(100) | NOT NULL | Patient's last name |
| `gender` | ENUM | NOT NULL | Values: 'male', 'female', 'other' |
| `date_of_birth` | DATE | NULL | Date of birth |
| `phone_number` | VARCHAR(30) | NULL | Contact phone number |
| `profile_photo` | VARCHAR(500) | NULL | Photo URL |
| **Medical Info** |
| `medical_history` | TEXT | NULL | Medical history |
| `allergies` | JSON | NULL | Array of allergies (e.g., ["Penicillin"]) |
| `current_medications` | JSON | NULL | Array of medications (e.g., ["Sertraline 50mg"]) |
| **Emergency Contact** |
| `emergency_contact_name` | VARCHAR(150) | NULL | Emergency contact person name |
| `emergency_contact_relationship` | VARCHAR(100) | NULL | Relationship to patient |
| `emergency_contact_phone` | VARCHAR(30) | NULL | Emergency contact phone |
| `created_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Profile creation timestamp |
| `updated_at` | DATETIME | AUTO UPDATE | Last update timestamp |

**Indexes:**
- PRIMARY KEY (user_id)
- INDEX (phone_number)

---

## 6. Appointments Table

**Purpose:** Core table tracking all therapy appointment bookings between doctors and patients

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `doctor_id` | CHAR(36) | NOT NULL, FK → doctor_profiles.user_id | References doctor |
| `patient_id` | CHAR(36) | NOT NULL, FK → patient_profiles.user_id | References patient |
| `scheduled_date` | DATE | NOT NULL | Appointment date |
| `scheduled_time` | TIME | NOT NULL | Appointment start time |
| `end_time` | TIME | NOT NULL | Appointment end time |
| `consultation_type` | ENUM | NOT NULL | Values: 'video', 'audio', 'chat' |
| `status` | ENUM | DEFAULT 'scheduled' | Values: 'scheduled', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled' |
| `reason_for_visit` | TEXT | NULL | Patient's reason for consultation |
| `notes` | TEXT | NULL | General notes |
| `recording_url` | VARCHAR(500) | NULL | Session recording URL |
| `session_type` | ENUM | DEFAULT 'individual' | Values: 'individual', 'couple' |
| `partner_name` | VARCHAR(200) | NULL | Partner name (if couple session) |
| `partner_email` | VARCHAR(255) | NULL | Partner email (if couple session) |
| `created_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Appointment creation timestamp |
| `updated_at` | DATETIME | AUTO UPDATE | Last update timestamp |

**Constraints:**
- UNIQUE KEY (doctor_id, scheduled_date, scheduled_time) - *Prevents double-booking*

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE KEY (doctor_id, scheduled_date, scheduled_time)
- INDEX (doctor_id, scheduled_date)
- INDEX (patient_id, scheduled_date)
- INDEX (status)

---

## 7. Consultation Sessions Table

**Purpose:** Track session details and clinical notes for completed consultations

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `appointment_id` | CHAR(36) | UNIQUE, NOT NULL, FK → appointments.id | References appointment |
| `started_at` | DATETIME | NULL | Session start timestamp |
| `ended_at` | DATETIME | NULL | Session end timestamp |
| `duration_minutes` | SMALLINT | NULL | Session duration in minutes |
| `notes` | TEXT | NULL | Clinical notes from doctor |
| `prescriptions` | JSON | NULL | Array of prescriptions (e.g., ["Medication A 10mg"]) |
| `follow_up_required` | TINYINT(1) | DEFAULT 0 | Follow-up needed |
| `next_follow_up_date` | DATE | NULL | Scheduled follow-up date |

**Constraints:**
- UNIQUE KEY (appointment_id) - *One session per appointment*

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE KEY (appointment_id)

---

## 8. Messages Table

**Purpose:** Chat/messaging system for communication between users during consultations

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `appointment_id` | CHAR(36) | NOT NULL, FK → appointments.id | References appointment |
| `sender_id` | CHAR(36) | NOT NULL, FK → users.id | References sender |
| `content` | TEXT | NOT NULL | Message content |
| `message_type` | ENUM | DEFAULT 'text' | Values: 'text', 'image', 'document' |
| `attachment_url` | VARCHAR(500) | NULL | File URL (if attachment) |
| `is_read` | TINYINT(1) | DEFAULT 0 | Message read status |
| `created_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Message creation timestamp |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (appointment_id, created_at)

---

## 9. Reviews Table

**Purpose:** Track patient reviews and ratings for doctors

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `doctor_id` | CHAR(36) | NOT NULL, FK → doctor_profiles.user_id | References doctor |
| `patient_id` | CHAR(36) | NOT NULL, FK → patient_profiles.user_id | References patient |
| `appointment_id` | CHAR(36) | NULL, FK → appointments.id | References appointment |
| `rating` | TINYINT | NOT NULL | Rating value (1-5 stars) |
| `title` | VARCHAR(200) | NULL | Review title |
| `comment` | TEXT | NULL | Review comment |
| `is_verified` | TINYINT(1) | DEFAULT 0 | Verified review status |
| `created_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Review creation timestamp |

**Constraints:**
- UNIQUE KEY (patient_id, appointment_id) - *One review per patient per appointment*
- CHECK (rating BETWEEN 1 AND 5)

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE KEY (patient_id, appointment_id)
- INDEX (doctor_id)

---

## 10. Documents Table

**Purpose:** Store verification documents for doctors and users

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `user_id` | CHAR(36) | NOT NULL, FK → users.id | References user |
| `document_type` | ENUM | NOT NULL | Values: 'license', 'certificate', 'qualification', 'identity' |
| `file_url` | VARCHAR(500) | NOT NULL | Document file URL |
| `file_name` | VARCHAR(255) | NOT NULL | Document file name |
| `uploaded_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Upload timestamp |
| `verification_status` | ENUM | DEFAULT 'pending' | Values: 'pending', 'verified', 'rejected' |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (user_id)

---

## 11. Notifications Table

**Purpose:** System notifications for users about activities and updates

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `user_id` | CHAR(36) | NOT NULL, FK → users.id | References user |
| `type` | ENUM | NOT NULL | Values: 'appointment_scheduled', 'appointment_reminder', 'consultation_completed', 'review_received', 'profile_updated', 'verification_update' |
| `title` | VARCHAR(255) | NOT NULL | Notification title |
| `message` | TEXT | NOT NULL | Notification message |
| `is_read` | TINYINT(1) | DEFAULT 0 | Read status |
| `related_id` | CHAR(36) | NULL | FK to related entity (appointment, review, etc.) |
| `created_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Creation timestamp |

**Indexes:**
- PRIMARY KEY (id)
- INDEX (user_id, is_read)
- INDEX (created_at)

---

## 12. Refresh Tokens Table

**Purpose:** JWT token management for session invalidation and token refresh

| Column | Type | Constraints | Description |
|--------|------|-----------|-------------|
| `id` | CHAR(36) | PRIMARY KEY | UUID identifier |
| `user_id` | CHAR(36) | NOT NULL, FK → users.id | References user |
| `token` | VARCHAR(512) | UNIQUE, NOT NULL | Refresh token (hashed, max 255 chars indexed) |
| `expires_at` | DATETIME | NOT NULL | Token expiration timestamp |
| `revoked` | TINYINT(1) | DEFAULT 0 | Token revocation status |
| `created_at` | DATETIME | DEFAULT UTC_TIMESTAMP() | Token creation timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE KEY (token - 255 char prefix)
- INDEX (user_id)

---

## Key Relationships & Constraints

### Foreign Key Relationships:
```
users (1) ──→ (Many) doctor_profiles
           ──→ (Many) patient_profiles
           ──→ (Many) documents
           ──→ (Many) notifications
           ──→ (Many) refresh_tokens

doctor_profiles (1) ──→ (Many) doctor_qualifications
                   ──→ (Many) doctor_weekly_schedule
                   ──→ (Many) appointments
                   ──→ (Many) reviews

patient_profiles (1) ──→ (Many) appointments
                    ──→ (Many) reviews

appointments (1) ──→ (1) consultation_sessions
            ──→ (Many) messages
            ──→ (Many) reviews
```

### Critical Constraints:
1. **Unique Doctor-Time Slots:** Prevents double-booking (`UNIQUE(doctor_id, scheduled_date, scheduled_time)`)
2. **One Session per Appointment:** Each appointment has max one consultation session
3. **One Review per Appointment:** Patient can review appointment only once
4. **Cascade Delete:** Deleting a user cascades to all related records

---

## Database Encoding

- **Character Set:** UTF8MB4 (supports emoji and special characters)
- **Collation:** utf8mb4_unicode_ci (case-insensitive sorting)
- **Engine:** InnoDB (ACID transactions, foreign keys)

---

## Best Practices Implemented

✅ UUID for all primary keys  
✅ Timestamps for audit trails (created_at, updated_at)  
✅ JSON columns for flexible data storage  
✅ Proper indexing for query performance  
✅ Foreign key constraints for data integrity  
✅ Unique constraints to prevent duplicates  
✅ ENUMs for fixed value sets  
✅ Validation checks (e.g., rating between 1-5)  
