# Doctor Onboarding Schema Refactoring — Documentation

## Overview

This document describes the refactored doctor onboarding database schema for the Therapy Booking & Video Consultation Platform. The refactoring replaces multiple boolean flags (`is_verified`, `is_profile_approved`, `is_profile_completed`) with a proper state machine using `profile_status` ENUM and `registration_step` ENUM.

---

## 1. Profile Status Model

### Status Definitions

| Status | Description | Who Triggers |
|---|---|---|
| `draft` | Doctor is filling onboarding steps. Default for new registrations. | System (on registration) |
| `submitted` | All 6 steps completed, sent for admin review. | Doctor (submit action) |
| `approved` | Admin approved the profile. Payout setup needed. | Admin |
| `rejected` | Admin rejected. Doctor must revise and resubmit. | Admin |
| `payout_pending` | Approved but payout details not yet submitted. | System (auto on approve) |
| `active` | Fully onboarded: approved + payout set up. Dashboard access. | System (on payout verify) |
| `suspended` | Admin suspended the doctor account. | Admin |

### Status Transition Rules (State Machine)

```
                ┌──────────┐
                │  draft   │
                └────┬─────┘
                     │ doctor submits
                     ▼
                ┌──────────┐    admin     ┌──────────┐
                │ submitted├─────────────►│ rejected │
                └────┬─────┘   approves   └────┬─────┘
                     │                          │ doctor resubmits
                     │ admin approves           ▼
                     ▼                     ┌──────────┐
               ┌──────────┐                │  draft   │
               │ approved │                └──────────┘
               └────┬─────┘
                    │ payout verified
                    ▼
               ┌──────────┐
               │  active  │
               └────┬─────┘
                    │ admin suspends
                    ▼
               ┌──────────┐
               │suspended │
               └──────────┘
```

### Allowed Transitions Table

| From | To | Trigger |
|---|---|---|
| `draft` | `submitted` | Doctor completes all 6 steps and submits |
| `draft` | `suspended` | Admin suspends during onboarding |
| `submitted` | `approved` | Admin approves profile |
| `submitted` | `rejected` | Admin rejects with reason |
| `submitted` | `suspended` | Admin suspends |
| `approved` | `payout_pending` | Payout submitted |
| `approved` | `active` | Payout already verified |
| `approved` | `suspended` | Admin suspends |
| `rejected` | `draft` | Doctor starts resubmission |
| `rejected` | `suspended` | Admin suspends |
| `payout_pending` | `active` | Payout verified |
| `payout_pending` | `suspended` | Admin suspends |
| `active` | `suspended` | Admin suspends |
| `suspended` | `draft` | Admin reinstates (if needed) |
| `suspended` | `active` | Admin reinstates |

---

## 2. Registration Steps

### Step Definitions

| Step Value | Order | Description |
|---|---|---|
| `basic_info` | 1 | Personal info: name, gender, DOB, phone, photo |
| `professional_details` | 2 | Specialty, therapy approaches, bio |
| `qualifications` | 3 | Degrees, institutes, certificates |
| `professional_registration` | 4 | Medical license, RCI registration |
| `work_experience` | 5 | Employment history, organization |
| `session_fee` | 6 | Pricing tiers, session duration |
| `completed` | 7 | All steps done, ready for submission |

### Data Type: ENUM

**Why ENUM over VARCHAR or INT:**
- Database-level validation — no invalid values possible
- Stored as integers internally (compact)
- Self-documenting — no lookup tables needed
- Values are fixed at design time

### Sequential Enforcement
Steps must be completed in order. The `ProfileStatusService` enforces that only forward-by-one transitions are valid (except when a rejected profile resets to `basic_info`).

---

## 3. ER Diagram (Text Representation)

```
┌──────────────────────┐
│        users          │
│──────────────────────│
│ id (PK, UUID)        │
│ email (UNIQUE)        │
│ password              │
│ full_name             │
│ user_type (ENUM)      │
│ is_active             │
│ is_email_verified     │
│ created_at            │
│ updated_at            │
└──────────┬───────────┘
           │ 1:1
           ▼
┌──────────────────────────┐
│    doctor_profiles        │
│──────────────────────────│
│ user_id (PK, FK→users)   │
│ profile_status (ENUM)  ◄── New
│ registration_step (ENUM) ◄── New
│ admin_note (TEXT)       ◄── New
│ submitted_at (DATETIME) ◄── New
│ reviewed_at (DATETIME)  ◄── New
│ reviewed_by (UUID)      ◄── New (FK→users)
│ gender                  │
│ date_of_birth           │
│ phone_number            │
│ primary_specialty       │
│ license_number          │
│ languages_spoken (JSON) │
│ video_rate / audio_rate │
│ consultation_duration   │
│ is_active               │
│ created_at / updated_at │
└──────┬──────┬──────┬────┘
       │      │      │
       │      │      │ 1:N
       │      │      ▼
       │      │  ┌──────────────────────┐
       │      │  │  doctor_documents     │
       │      │  │──────────────────────│
       │      │  │ id (PK, UUID)        │
       │      │  │ doctor_id (FK)       │
       │      │  │ document_type (ENUM) │
       │      │  │ file_url             │
       │      │  │ verification_status  │
       │      │  │ rejection_reason     │
       │      │  │ verified_by (FK)     │
       │      │  │ verified_at          │
       │      │  └──────────────────────┘
       │      │
       │      │ 1:N
       │      ▼
       │  ┌──────────────────────┐
       │  │  doctor_payouts       │
       │  │──────────────────────│
       │  │ id (PK, UUID)        │
       │  │ doctor_id (FK)       │
       │  │ provider (VARCHAR)   │
       │  │ account_holder_name  │
       │  │ bank_name            │
       │  │ account_number       │
       │  │ ifsc_code            │
       │  │ upi_id               │
       │  │ pan_number           │
       │  │ status (ENUM)        │
       │  │ verified_by (FK)     │
       │  └──────────────────────┘
       │
       │ 1:N
       ▼
┌──────────────────────┐
│ doctor_qualifications │
│──────────────────────│
│ id (PK, UUID)        │
│ doctor_id (FK)       │
│ degree               │
│ institution          │
│ passing_year         │
│ verification_status  │
└──────────────────────┘

┌──────────────────────────┐
│ doctor_verification_logs  │
│──────────────────────────│
│ id (PK, UUID)            │
│ doctor_id (FK→profiles)  │
│ action (ENUM)            │
│ previous_status          │
│ new_status               │
│ admin_id (FK→users)      │
│ admin_notes              │
│ created_at               │
└──────────────────────────┘
```

---

## 4. MySQL Table Definitions (Post-Migration)

### doctor_profiles (Modified)

```sql
CREATE TABLE doctor_profiles (
  user_id               CHAR(36) NOT NULL,
  profile_status        ENUM('draft','submitted','approved','rejected','payout_pending','active','suspended') 
                        NOT NULL DEFAULT 'draft',
  registration_step     ENUM('basic_info','professional_details','qualifications','professional_registration','work_experience','session_fee','completed') 
                        NOT NULL DEFAULT 'basic_info',
  gender                ENUM('male','female','other','prefer_not_to_say') NOT NULL DEFAULT 'other',
  date_of_birth         DATE DEFAULT NULL,
  phone_number          VARCHAR(30) DEFAULT NULL,
  profile_photo_url     VARCHAR(255) DEFAULT NULL,
  primary_specialty     VARCHAR(150) NOT NULL DEFAULT '',
  sub_specializations   JSON DEFAULT NULL,
  therapy_approaches    JSON DEFAULT NULL,
  professional_bio      TEXT DEFAULT NULL,
  govt_id_front_url     VARCHAR(500) DEFAULT NULL,
  govt_id_back_url      VARCHAR(500) DEFAULT NULL,
  license_number        VARCHAR(100) NOT NULL DEFAULT '',
  medical_council       VARCHAR(100) NOT NULL DEFAULT '',
  languages_spoken      JSON NOT NULL,
  video_enabled         TINYINT(1) NOT NULL DEFAULT 1,
  video_rate            DECIMAL(10,2) DEFAULT NULL,
  audio_enabled         TINYINT(1) NOT NULL DEFAULT 1,
  audio_rate            DECIMAL(10,2) DEFAULT NULL,
  session_fee_tier      ENUM('799','999','1499','1999','2499') DEFAULT NULL,
  pricing_justification TEXT DEFAULT NULL,
  consultation_duration ENUM('30min','45min','60min') NOT NULL DEFAULT '60min',
  buffer_time           ENUM('5min','10min','15min','30min') NOT NULL DEFAULT '10min',
  is_active             TINYINT(1) DEFAULT 1,
  admin_note            TEXT DEFAULT NULL,
  submitted_at          DATETIME DEFAULT NULL,
  reviewed_at           DATETIME DEFAULT NULL,
  reviewed_by           CHAR(36) DEFAULT NULL,
  created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_doctor_license (license_number),
  INDEX idx_profile_status (profile_status),
  INDEX idx_registration_step (registration_step),
  INDEX idx_doctor_specialty (primary_specialty),
  INDEX idx_doctor_city (city),
  INDEX idx_reviewed_by (reviewed_by),
  CONSTRAINT fk_doctor_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_dp_reviewed_by FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### doctor_documents (Enhanced)

```sql
CREATE TABLE doctor_documents (
  id                  CHAR(36) NOT NULL DEFAULT (UUID()),
  doctor_id           CHAR(36) NOT NULL,
  document_type       ENUM('govt_id_front','govt_id_back','qualification_certificate','rci_certificate','experience_proof') NOT NULL,
  file_url            VARCHAR(255) NOT NULL,
  file_name           VARCHAR(255) NOT NULL,
  file_size           INT NOT NULL,
  mime_type           VARCHAR(50) NOT NULL,
  verification_status ENUM('pending','verified','rejected') DEFAULT 'pending',
  rejection_reason    TEXT DEFAULT NULL,
  verified_by         CHAR(36) DEFAULT NULL,
  uploaded_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  verified_at         DATETIME DEFAULT NULL,
  created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_doc_doctor (doctor_id),
  INDEX idx_doc_type (document_type),
  INDEX idx_doc_verification (verification_status),
  INDEX idx_doc_verified_by (verified_by),
  CONSTRAINT fk_doc_doctor FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_doc_verified_by FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### doctor_payouts (New)

```sql
CREATE TABLE doctor_payouts (
  id                    CHAR(36) NOT NULL DEFAULT (UUID()),
  doctor_id             CHAR(36) NOT NULL,
  provider              VARCHAR(50) NOT NULL DEFAULT 'bank',
  account_holder_name   VARCHAR(255) NOT NULL,
  bank_name             VARCHAR(255) DEFAULT NULL,
  account_number        VARCHAR(50) DEFAULT NULL,
  ifsc_code             VARCHAR(11) DEFAULT NULL,
  branch_name           VARCHAR(255) DEFAULT NULL,
  upi_id                VARCHAR(100) DEFAULT NULL,
  pan_number            VARCHAR(20) DEFAULT NULL,
  is_gst_registered     TINYINT(1) DEFAULT 0,
  gst_number            VARCHAR(15) DEFAULT NULL,
  provider_account_id   VARCHAR(255) DEFAULT NULL,
  terms_consent         TINYINT(1) NOT NULL DEFAULT 0,
  status                ENUM('pending','submitted','verified','rejected') NOT NULL DEFAULT 'pending',
  rejection_reason      TEXT DEFAULT NULL,
  submitted_at          DATETIME DEFAULT NULL,
  verified_at           DATETIME DEFAULT NULL,
  verified_by           CHAR(36) DEFAULT NULL,
  is_primary            TINYINT(1) DEFAULT 1,
  created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_payout_doctor (doctor_id),
  INDEX idx_payout_status (status),
  INDEX idx_payout_provider (provider),
  INDEX idx_payout_verified_by (verified_by),
  CONSTRAINT fk_payout_doctor FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_payout_verified_by FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 5. Index Recommendations

| Table | Index Name | Columns | Purpose |
|---|---|---|---|
| doctor_profiles | `idx_profile_status` | `profile_status` | Admin panel filtering by status |
| doctor_profiles | `idx_registration_step` | `registration_step` | Onboarding progress queries |
| doctor_profiles | `idx_doctor_specialty` | `primary_specialty` | Public doctor search |
| doctor_profiles | `idx_doctor_city` | `city` | Location-based search |
| doctor_profiles | `idx_reviewed_by` | `reviewed_by` | Audit trail queries |
| doctor_documents | `idx_doc_doctor` | `doctor_id` | Fetch docs per doctor |
| doctor_documents | `idx_doc_type` | `document_type` | Filter by doc type |
| doctor_documents | `idx_doc_verification` | `verification_status` | Admin pending queue |
| doctor_documents | `idx_doc_verified_by` | `verified_by` | Audit trail |
| doctor_payouts | `idx_payout_doctor` | `doctor_id` | Fetch payouts per doctor |
| doctor_payouts | `idx_payout_status` | `status` | Filter by verification status |
| doctor_payouts | `idx_payout_provider` | `provider` | Filter by payment method |
| doctor_verification_logs | `idx_log_doctor` | `doctor_id` | Audit trail per doctor |
| doctor_verification_logs | `idx_log_created` | `created_at` | Chronological queries |

---

## 6. Validation Rules

### Profile Status Transitions
- Only allowed transitions per state machine (enforced by `ProfileStatusService`)
- All transitions are logged to `doctor_verification_logs`
- `submitted_at` set once when status becomes `submitted`
- `reviewed_at` and `reviewed_by` set on `approved` or `rejected`

### Registration Steps
- Steps must progress sequentially (no skipping)
- Can save/continue at current step without advancing
- Reset to `basic_info` allowed when profile is rejected

### Doctor Documents
- Each document verified independently
- All required docs must be uploaded before submission: `govt_id_front`, `govt_id_back`, `qualification_certificate`
- Optional docs: `rci_certificate`, `experience_proof`
- Rejection requires a reason
- `verified_by` tracks which admin performed verification

### Doctor Payouts
- Only one active payout (status `submitted` or `verified`) per doctor
- Requires `terms_consent` = 1
- Account number uniqueness enforced
- Rejection requires a reason

---

## 7. Login Routing Logic (Pseudocode)

```
FUNCTION handleDoctorLogin(email, password):
    user = FIND user WHERE email = ? AND user_type = "doctor"
    
    IF user NOT FOUND:
        RETURN error("No account found")
    
    IF NOT verifyPassword(password, user.password):
        RETURN error("Invalid password")
    
    IF NOT user.is_active:
        RETURN error("Account deactivated")
    
    route = getLoginRoute(user.id)
    
    RETURN success(user, route)

FUNCTION getLoginRoute(userId):
    profile = SELECT profile_status, registration_step FROM doctor_profiles WHERE user_id = ?
    
    SWITCH profile.profile_status:
        CASE "draft":
            RETURN { route: "/onboarding/" + profile.registration_step, action: "resume_onboarding" }
        
        CASE "submitted":
            RETURN { route: "/onboarding/pending-review", action: "profile_under_review" }
        
        CASE "approved":
            IF hasActivePayout(userId):
                RETURN { route: "/doctor/dashboard", action: "dashboard" }
            ELSE:
                RETURN { route: "/onboarding/payout-setup", action: "payout_setup_required" }
        
        CASE "rejected":
            RETURN { route: "/onboarding?tab=revisions", action: "profile_rejected", admin_note: profile.admin_note }
        
        CASE "payout_pending":
            RETURN { route: "/onboarding/payout-setup", action: "payout_pending" }
        
        CASE "active":
            RETURN { route: "/doctor/dashboard", action: "dashboard" }
        
        CASE "suspended":
            RETURN { route: "/account-suspended", action: "account_suspended" }
        
        DEFAULT:
            RETURN { route: "/onboarding/basic-info", action: "start_onboarding" }
```

---

## 8. API Response Examples

### GET /api/doctor/status
```json
{
  "success": true,
  "data": {
    "user_id": "844c35cd-2a2b-47c1-959d-2dd77280eb64",
    "profile_status": "draft",
    "registration_step": "qualifications",
    "progress": {
      "total_steps": 6,
      "completed_steps": 2,
      "current_step": "qualifications",
      "percentage": 33
    },
    "has_payout": false,
    "submitted_at": null,
    "reviewed_at": null,
    "admin_note": null
  }
}
```

### POST /api/doctor/onboarding/complete-step
```json
// Request
{
  "current_step": "qualifications"
}

// Response - Success
{
  "success": true,
  "message": "Step 'qualifications' completed. Next: 'professional_registration'.",
  "data": {
    "next_step": "professional_registration",
    "progress": {
      "total_steps": 6,
      "completed_steps": 3,
      "current_step": "professional_registration",
      "percentage": 50
    }
  }
}
```

### POST /api/doctor/onboarding/submit
```json
// Response - Success
{
  "success": true,
  "message": "Profile submitted for review.",
  "data": {
    "profile_status": "submitted",
    "submitted_at": "2026-06-16T09:00:00Z"
  }
}

// Response - Error (incomplete)
{
  "success": false,
  "message": "Cannot submit: onboarding not complete. Current step: 'work_experience'."
}
```

### POST /api/admin/doctor/approve
```json
// Request
{
  "doctor_id": "844c35cd-2a2b-47c1-959d-2dd77280eb64",
  "note": "All documents verified. Profile looks good."
}

// Response
{
  "success": true,
  "message": "Profile transitioned from 'submitted' to 'approved'.",
  "data": {
    "previous_status": "submitted",
    "new_status": "approved"
  }
}
```

### POST /api/admin/doctor/reject
```json
// Request
{
  "doctor_id": "844c35cd-2a2b-47c1-959d-2dd77280eb64",
  "reason": "License certificate is illegible. Please upload a clearer copy.",
  "resume_step": "professional_registration"
}

// Response
{
  "success": true,
  "message": "Profile transitioned from 'submitted' to 'rejected'.",
  "data": {
    "previous_status": "submitted",
    "new_status": "rejected"
  }
}
```

### POST /api/doctor/payout/setup
```json
// Request
{
  "provider": "bank",
  "account_holder_name": "Dr. Smith",
  "bank_name": "HDFC Bank",
  "account_number": "1234567890",
  "ifsc_code": "HDFC0001234",
  "upi_id": null,
  "pan_number": "ABCPD1234E",
  "terms_consent": true
}

// Response
{
  "success": true,
  "message": "Payout details submitted for verification.",
  "data": {
    "payout_id": "uuid-here",
    "status": "submitted",
    "profile_status": "payout_pending"
  }
}
```

### POST /api/doctor/login
```json
// Request
{
  "email": "doctor@cosmic.com",
  "password": "securepassword"
}

// Response
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "jwt-token-here",
    "user": {
      "id": "844c35cd-...",
      "email": "doctor@cosmic.com",
      "full_name": "Dr. Smith",
      "profile_status": "draft",
      "registration_step": "work_experience"
    },
    "route": "/onboarding/work_experience",
    "action": "resume_onboarding"
  }
}
```

---

## 9. Migration Files

| File | Description |
|---|---|
| `backend/db/migrations/001_refactor_doctor_onboarding.sql` | Main migration: ALTER doctor_profiles, CREATE doctor_payouts, ALTER doctor_documents |

### Running the Migration

```bash
# From project root
mysql -u root -p therapy_booking < backend/db/migrations/001_refactor_doctor_onboarding.sql
```

### Rollback

The rollback script is included at the bottom of the migration file. Key steps:
1. Drop new columns from doctor_profiles
2. Drop doctor_documents.verified_by
3. Drop doctor_payouts table
4. Recreate dropped boolean columns

---

## 10. PHP Files Changed/Created

| File | Status | Description |
|---|---|---|
| `backend/services/ProfileStatusService.php` | **NEW** | State transition engine — single source of truth for status changes |
| `backend/services/DoctorLoginRouter.php` | **NEW** | Login routing logic based on profile_status |
| `backend/models/DoctorProfile.php` | **MODIFIED** | Updated to use profile_status, registration_step ENUMs |
| `backend/models/DoctorDocument.php` | **MODIFIED** | Added verified_by tracking, approval/rejection methods |
| `backend/models/DoctorPayouts.php` | **NEW** | New model for doctor_payouts table |
| `backend/models/Onboarding.php` | **MODIFIED** | Delegates to ProfileStatusService, cleaner step management |
| `backend/models/User.php` | **MODIFIED** | Removed old boolean references, added findDoctorWithStatus() |
| `backend/models/DoctorPayoutAccount.php` | **DEPRECATED** | Replaced by DoctorPayouts.php |

---

## 11. Backend Architecture Principles Applied

1. **Single Source of Truth**: `ProfileStatusService` is the ONLY place that changes `profile_status`
2. **State Machine Pattern**: Valid transitions are explicitly defined, invalid ones rejected
3. **Separation of Concerns**: Models handle data access, Services handle business logic
4. **Audit Trail**: All status changes logged to `doctor_verification_logs`
5. **Backward Compatibility**: Old methods kept as deprecated during migration
6. **Clean Naming**: `doctor_payouts` (not `doctor_payout_accounts`), `profile_status` (not `verification_status`)
7. **ENUM for Fixed Values**: Status and step values enforced at database level