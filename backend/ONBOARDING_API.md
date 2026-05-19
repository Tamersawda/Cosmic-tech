# Doctor Onboarding API Documentation

**Version:** 3.0 - Restructured Workflow Engine  
**Date:** May 17, 2026  
**Status:** Production Ready  

---

## 🏗️ Architecture Overview

The Doctor Onboarding system is now a **structured 7-step workflow** with proper state management, document tracking, and admin verification.

### Previous Architecture (Deprecated)
- ❌ POST /api/doctors/setup (monolithic endpoint)
- ❌ Single giant payload
- ❌ No partial saves
- ❌ No progress tracking

### New Architecture (Current)
- ✅ **7 step-based endpoints** for partial saves
- ✅ **Resumable workflow** - doctors can save progress and return later
- ✅ **Proper state tracking** - registration step + verification status
- ✅ **Document management** - secure file uploads with verification
- ✅ **Admin review** - comprehensive verification workflow
- ✅ **Audit logging** - full verification history

---

## 📋 Onboarding Workflow

### Steps

1. **Basic Information** - Personal identity & contact
2. **Professional Details** - Expertise, specializations, government ID
3. **Qualifications** - Education credentials (multi-record CRUD)
4. **Professional Registration** - License/RCI registration
5. **Work Experience** - Employment history (multi-record CRUD)
6. **Session Pricing** - Consultation fees and duration
7. **Payout Setup** - Banking and tax information

### States

```
draft
  ↓
in_progress (after Step 1+)
  ↓
submitted (after final submission)
  ↓
under_review (admin is reviewing)
  ↓
├─→ approved (profile active, can take appointments)
├─→ rejected (returns to draft, needs fixes)
└─→ resubmission_required (specific issues to fix)
```

---

## 🔐 Authentication

All onboarding endpoints require:
```
Authorization: Bearer {jwtToken}
```

Obtained from:
- POST /api/auth/register
- POST /api/auth/login

---

## 📡 Onboarding Endpoints

### STEP 1: Basic Information

#### POST /api/doctors/onboarding/basic-info

Save personal identity and contact details.

**Request (Multipart/Form-Data):**
```json
{
  "phoneNumber": "9876543210",
  "gender": "male",  // "male" | "female" | "other" | "prefer_not_to_say"
  "dateOfBirth": "1985-05-15",
  "profilePhoto": <File> // JPEG/PNG, max 2MB
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Basic information saved successfully",
    "step": 1,
    "nextStep": 2
  }
}
```

**Validation Errors:**
- `phoneNumber`: Must be at least 10 digits
- `gender`: Must be one of the allowed values
- `dateOfBirth`: Must be valid date, 18+ years old
- `profilePhoto`: Required, max 2MB, JPEG/PNG only

---

#### GET /api/doctors/onboarding/basic-info

Retrieve saved basic information.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "profilePhoto": "uploads/profile-photos/doctor_uuid.jpg",
    "phoneNumber": "9876543210",
    "gender": "male",
    "dateOfBirth": "1985-05-15"
  }
}
```

---

### STEP 2: Professional Details

#### POST /api/doctors/onboarding/professional-details

Save professional expertise and government ID.

**Request (Multipart/Form-Data):**
```json
{
  "primaryTitle": "Clinical Psychologist",
  "secondaryTitle": "Therapist",  // optional
  "specializations": [
    {
      "category": "Anxiety Issues",
      "subSpecializations": ["Panic attacks", "Social anxiety"]
    },
    {
      "category": "Depression & Mood",
      "subSpecializations": ["Major depression"]
    }
  ],
  "therapyApproaches": ["CBT", "DBT", "Person-Centered"],
  "languages": ["English", "Hindi", "Tamil"],
  "bio": "Professional biography (max 600 chars)",
  "govtIdFront": <File>,  // PDF/PNG/JPEG, max 5MB
  "govtIdBack": <File>    // PDF/PNG/JPEG, max 5MB
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Professional details saved successfully",
    "step": 2,
    "nextStep": 3
  }
}
```

---

#### GET /api/doctors/onboarding/professional-details

Retrieve saved professional details.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "primaryTitle": "Clinical Psychologist",
    "secondaryTitle": "Therapist",
    "specializations": [...],
    "therapyApproaches": ["CBT", "DBT"],
    "languages": ["English", "Hindi"],
    "bio": "...",
    "govtIdFront": "uploads/govt-id/uuid/front_uuid.pdf",
    "govtIdBack": "uploads/govt-id/uuid/back_uuid.pdf"
  }
}
```

---

### STEP 3: Qualifications (CRUD)

#### POST /api/doctors/onboarding/qualifications

Add a new qualification with certificate.

**Request (Multipart/Form-Data):**
```json
{
  "degree": "M.A. Clinical Psychology",
  "institution": "Delhi University",
  "specialization": "Cognitive Behavioral Therapy",  // optional
  "passingYear": 2010,
  "certificate": <File>  // PDF/PNG/JPEG, max 5MB
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "qual-uuid-123",
    "message": "Qualification added successfully"
  }
}
```

---

#### GET /api/doctors/onboarding/qualifications

List all qualifications.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "count": 2,
    "qualifications": [
      {
        "id": "qual-uuid-1",
        "degree": "M.A. Clinical Psychology",
        "institution": "Delhi University",
        "specialization": "CBT",
        "passingYear": 2010,
        "certificateUrl": "uploads/qualifications/uuid/cert_123.pdf",
        "verificationStatus": "pending",
        "createdAt": "2026-05-17T10:30:00Z"
      }
    ]
  }
}
```

---

#### PUT /api/doctors/onboarding/qualifications/{id}

Update qualification.

**Request (JSON):**
```json
{
  "degree": "M.A. Clinical Psychology",
  "institution": "Delhi University",
  "specialization": "Cognitive Behavioral Therapy",
  "passingYear": 2010
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Qualification updated successfully",
    "id": "qual-uuid-123"
  }
}
```

---

#### DELETE /api/doctors/onboarding/qualifications/{id}

Delete qualification.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Qualification deleted successfully",
    "id": "qual-uuid-123"
  }
}
```

---

### STEP 4: Professional Registration & Verification

#### POST /api/doctors/onboarding/verification

Save professional registration details.

**Request (Multipart/Form-Data):**
```json
{
  "registrationType": "rci",  // "rci" | "none"
  "rciNumber": "A-12345/2010",  // required if registrationType = "rci"
  "rciCertificate": <File>,     // PDF/PNG/JPEG, max 5MB
  "selfDeclarationAgreed": true
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Verification details saved successfully",
    "step": 4,
    "nextStep": 5
  }
}
```

---

#### GET /api/doctors/onboarding/verification

Retrieve saved registration details.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "registrationType": "rci",
    "rciNumber": "A-12345/2010",
    "rciCertificate": "uploads/registration-certificates/uuid/cert_123.pdf"
  }
}
```

---

### STEP 5: Work Experience (CRUD)

#### POST /api/doctors/onboarding/experiences

Add work experience.

**Request (Multipart/Form-Data):**
```json
{
  "organization": "Apollo Hospitals",
  "role": "Senior Therapist",
  "workType": "hospital",  // "hospital" | "private_practice" | "ngo" | "online_platform" | "other"
  "customWorkType": null,  // required if workType = "other"
  "startDate": "2018-01-15",
  "endDate": "2022-06-30",  // null if currentlyWorking = true
  "currentlyWorking": false,
  "description": "Provided individual and group therapy...",
  "proofDocument": <File>  // PDF/PNG/JPEG, max 5MB
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "exp-uuid-123",
    "message": "Experience added successfully"
  }
}
```

---

#### GET /api/doctors/onboarding/experiences

List all work experiences.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "count": 2,
    "experiences": [
      {
        "id": "exp-uuid-1",
        "organization": "Apollo Hospitals",
        "role": "Senior Therapist",
        "workType": "hospital",
        "customWorkType": null,
        "startDate": "2018-01-15",
        "endDate": "2022-06-30",
        "currentlyWorking": false,
        "description": "...",
        "proofDocumentUrl": "uploads/experience-proof/uuid/proof_123.pdf",
        "verificationStatus": "pending",
        "createdAt": "2026-05-17T10:30:00Z"
      }
    ]
  }
}
```

---

#### PUT /api/doctors/onboarding/experiences/{id}

Update experience.

**Request (JSON):**
```json
{
  "organization": "Apollo Hospitals",
  "role": "Lead Therapist",
  "workType": "hospital",
  "currentlyWorking": true
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Experience updated successfully",
    "id": "exp-uuid-1"
  }
}
```

---

#### DELETE /api/doctors/onboarding/experiences/{id}

Delete experience.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Experience deleted successfully",
    "id": "exp-uuid-1"
  }
}
```

---

### STEP 6: Session Pricing

#### POST /api/doctors/onboarding/pricing

Save consultation pricing.

**Request (JSON):**
```json
{
  "sessionPrice": 999,
  "consultationDuration": "60min",  // "30min" | "45min" | "60min"
  "followUpPrice": 599,  // optional
  "currency": "INR"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Pricing information saved successfully",
    "step": 6,
    "nextStep": 7
  }
}
```

---

#### GET /api/doctors/onboarding/pricing

Retrieve pricing information.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "sessionPrice": 999,
    "consultationDuration": "60min",
    "followUpPrice": 599,
    "currency": "INR"
  }
}
```

---

### STEP 7: Payout Setup

#### POST /api/doctors/onboarding/payout

Save banking and tax information.

**Request (JSON):**
```json
{
  "accountHolderName": "Dr. John Doe",
  "accountNumber": "123456789012",
  "ifscCode": "HDFC0000001",
  "bankName": "HDFC Bank",
  "branchName": "Delhi Main Branch",
  "panNumber": "AAAAA0000A",
  "isGstRegistered": true,
  "gstNumber": "18AABCT1234H1Z0"  // required if isGstRegistered = true
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "payout-uuid-123",
    "message": "Payout information saved successfully",
    "step": 7,
    "nextStep": 8
  }
}
```

---

#### GET /api/doctors/onboarding/payout

Retrieve payout information.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "payout-uuid-123",
    "accountHolderName": "Dr. John Doe",
    "accountNumber": "123456789012",
    "ifscCode": "HDFC0000001",
    "bankName": "HDFC Bank",
    "branchName": "Delhi Main Branch",
    "panNumber": "AAAAA0000A",
    "isGstRegistered": true,
    "gstNumber": "18AABCT1234H1Z0",
    "verificationStatus": "pending"
  }
}
```

---

### STEP 8: Final Submission

#### POST /api/doctors/onboarding/submit

Submit complete onboarding for admin review.

**Validations (all required):**
- ✅ Step 1: Basic info (phone, gender, DOB)
- ✅ Step 2: Professional details + govt ID
- ✅ Step 3: At least 1 qualification
- ✅ Step 4: Registration type (RCI or self-declaration)
- ✅ Step 5: At least 1 experience
- ✅ Step 6: Pricing information
- ✅ Step 7: Payout account

**Request (Empty Body):**
```
POST /api/doctors/onboarding/submit
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Onboarding submitted successfully for admin review",
    "verificationStatus": "submitted",
    "nextSteps": "Your profile will be reviewed by our team. You will be notified via email once the review is complete."
  }
}
```

**Error (400) - Incomplete Steps:**
```json
{
  "success": false,
  "message": "Cannot submit: incomplete steps",
  "code": "INCOMPLETE_STEPS",
  "details": [
    "Step 3 (Qualifications): At least one qualification is required",
    "Step 5 (Work Experience): At least one experience entry is required"
  ]
}
```

---

#### GET /api/doctors/onboarding/status

Get current onboarding status.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "registrationStep": 7,
    "onboardingCompleted": false,
    "verificationStatus": "submitted",
    "submittedAt": "2026-05-17T10:30:00Z",
    "reviewedAt": null,
    "rejectionReason": null
  }
}
```

---

## 🔑 Admin Endpoints

### GET /api/admin/onboarding/pending

List doctors pending verification (paginated).

**Query Parameters:**
- `limit` (optional): Default 50
- `offset` (optional): Default 0

**Response (200):**
```json
{
  "success": true,
  "data": {
    "count": 5,
    "limit": 50,
    "offset": 0,
    "doctors": [
      {
        "id": "doctor-uuid-1",
        "email": "doctor@example.com",
        "full_name": "Dr. John Doe",
        "verification_status": "submitted",
        "submitted_at": "2026-05-17T10:00:00Z"
      }
    ]
  }
}
```

---

### GET /api/admin/onboarding/{doctorId}

Get complete onboarding details for a doctor.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "profile": {
      "user_id": "doctor-uuid-1",
      "full_name": "Dr. John Doe",
      "email": "doctor@example.com",
      "phone_number": "9876543210",
      "gender": "male",
      "date_of_birth": "1985-05-15",
      "primary_title": "Clinical Psychologist",
      "sub_specializations": [...],
      "therapy_types": [...],
      "languages_spoken": [...],
      "registration_type": "rci",
      "rci_number": "A-12345/2010",
      "session_price": 999,
      "consultation_duration": "60min",
      "verification_status": "submitted",
      "submitted_at": "2026-05-17T10:00:00Z",
      "reviewed_at": null,
      "rejected_reason": null
    },
    "verificationLogs": [
      {
        "id": "log-uuid-1",
        "action": "step_completed",
        "step_number": 1,
        "created_at": "2026-05-17T09:00:00Z"
      },
      {
        "id": "log-uuid-2",
        "action": "profile_submitted_for_review",
        "created_at": "2026-05-17T10:00:00Z"
      }
    ]
  }
}
```

---

### POST /api/admin/onboarding/{doctorId}/approve

Approve doctor's onboarding profile.

**Request (Empty):**
```
POST /api/admin/onboarding/{doctorId}/approve
Authorization: Bearer {adminToken}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "doctorId": "doctor-uuid-1",
    "verificationStatus": "approved",
    "message": "Doctor profile approved successfully"
  }
}
```

**Effects:**
- Sets `verification_status` to `approved`
- Sets `is_profile_approved` to `true`
- Sends approval email to doctor
- Doctor can now accept appointments

---

### POST /api/admin/onboarding/{doctorId}/reject

Reject doctor's onboarding profile.

**Request (JSON):**
```json
{
  "reason": "Certificate of RCI registration is not clearly visible. Please upload a clearer copy."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "doctorId": "doctor-uuid-1",
    "verificationStatus": "rejected",
    "message": "Doctor profile rejected"
  }
}
```

**Effects:**
- Sets `verification_status` to `rejected`
- Stores rejection reason
- Sends rejection email with reason
- Doctor can restart onboarding

---

### POST /api/admin/onboarding/{doctorId}/request-resubmission

Request doctor to fix specific issues and resubmit.

**Request (JSON):**
```json
{
  "reason": "Your government ID needs to show both sides clearly. Please reupload the documents and resubmit."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "doctorId": "doctor-uuid-1",
    "verificationStatus": "resubmission_required",
    "message": "Doctor requested to resubmit profile"
  }
}
```

**Effects:**
- Sets `verification_status` to `resubmission_required`
- Stores the specific issues
- Sends email to doctor with requirements
- Doctor can edit and resubmit

---

## 🔒 Error Handling

All errors follow the standard response format:

```json
{
  "success": false,
  "message": "Error description",
  "code": "ERROR_CODE",
  "details": {
    "fieldName": "field specific error"
  }
}
```

### Common Error Codes

| Code | Status | Meaning |
|------|--------|---------|
| `UNAUTHORIZED` | 401 | No token or invalid token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `VALIDATION_ERROR` | 400 | Input validation failed |
| `NOT_FOUND` | 404 | Resource not found |
| `INCOMPLETE_STEPS` | 400 | Onboarding not complete |
| `FILE_ERROR` | 400 | File upload failed |
| `SERVER_ERROR` | 500 | Internal server error |

---

## 📝 Request/Response Examples

### Complete Flow Example

**1. Register Doctor**
```bash
POST /api/auth/register
{
  "name": "Dr. John Doe",
  "email": "john@example.com",
  "password": "SecurePass123",
  "role": "doctor"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "doctor-uuid-123",
    "token": "eyJhbGci...",
    "refreshToken": "eyJhbGci..."
  }
}
```

**2. Save Basic Info**
```bash
POST /api/doctors/onboarding/basic-info
Authorization: Bearer {token}
Content-Type: multipart/form-data

phoneNumber=9876543210
gender=male
dateOfBirth=1985-05-15
profilePhoto=<file>
```

**3. Save Professional Details**
```bash
POST /api/doctors/onboarding/professional-details
Authorization: Bearer {token}
Content-Type: multipart/form-data

primaryTitle=Clinical Psychologist
specializations=[...]
therapyApproaches=[...]
languages=[...]
bio=...
govtIdFront=<file>
govtIdBack=<file>
```

**4. Add Qualifications**
```bash
POST /api/doctors/onboarding/qualifications
Authorization: Bearer {token}
Content-Type: multipart/form-data

degree=M.A. Clinical Psychology
institution=Delhi University
passingYear=2010
certificate=<file>
```

**5. Submit Onboarding**
```bash
POST /api/doctors/onboarding/submit
Authorization: Bearer {token}
```

---

## 🗄️ Database Schema

### Key Tables

- `users` - User identity with `registration_step`, `onboarding_completed`
- `doctor_profiles` - Doctor profile with verification status and metadata
- `doctor_qualifications` - Qualifications with verification status
- `doctor_experiences` - Work experience with verification status
- `doctor_documents` - Uploaded documents with verification
- `doctor_payout_accounts` - Banking information
- `doctor_verification_logs` - Audit trail of all verification actions

---

## 🚀 Frontend Integration

### State Management

```dart
// Doctor tracks current step
int currentStep = 1;

// Doctor can resume from where they left off
getOnboardingStatus()
  .then((status) {
    currentStep = status['registrationStep'];
  });

// Doctor completes each step
saveStepData(step, data)
  .then((response) {
    if (response.success) {
      currentStep = response['nextStep'];
      navigateToStep(currentStep);
    }
  });

// Final submission
submitOnboarding()
  .then((response) {
    if (response.success) {
      showSuccessScreen();
      // Doctor waits for admin review
    }
  });
```

---

## ✅ Status: Production Ready

This documentation describes the complete, production-ready onboarding system. All endpoints are implemented, tested, and ready for frontend integration.

