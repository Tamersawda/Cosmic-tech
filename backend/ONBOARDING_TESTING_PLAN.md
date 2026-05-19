# Doctor Onboarding - Manual QA Testing Plan

**Version:** 1.0  
**Date:** May 17, 2026  
**Environment:** Development/Staging  

---

## 🎯 Testing Overview

This document outlines comprehensive manual QA testing for the Doctor Onboarding workflow. All tests should be executed in sequence to validate the complete user journey.

### Prerequisites

- Access to development/staging backend
- Postman or API client with saved collection
- Database access for verification queries
- Email testing setup (mailhog/mailtrap)

---

## 📋 Test Scenarios

### TEST SET 1: Authentication & Initialization

#### T1.1 - Doctor Registration
**Objective:** Verify doctor can register successfully

**Steps:**
1. Open Postman → POST /api/auth/register
2. Send:
   ```json
   {
     "name": "Dr. Test User",
     "email": "test.doctor@example.com",
     "password": "TestPass123",
     "role": "doctor"
   }
   ```
3. Verify response contains:
   - `success: true`
   - `data.id` (UUID)
   - `data.token` (JWT)
   - `data.refreshToken`

**Expected Result:** ✅ 201 Created

---

#### T1.2 - Verify Initial Onboarding State
**Objective:** Confirm doctor profile is created with correct initial state

**Steps:**
1. Get JWT token from T1.1
2. Query database:
   ```sql
   SELECT registration_step, onboarding_completed, verification_status
   FROM users u
   JOIN doctor_profiles dp ON u.id = dp.user_id
   WHERE u.email = 'test.doctor@example.com';
   ```
3. Verify values:
   - `registration_step: 0`
   - `onboarding_completed: 0`
   - `verification_status: draft`

**Expected Result:** ✅ Correct initial state

---

### TEST SET 2: Step 1 - Basic Information

#### T2.1 - Save Basic Info with Valid Data
**Objective:** Verify Step 1 endpoint saves personal information

**Steps:**
1. POST /api/doctors/onboarding/basic-info
2. Body (form-data):
   ```
   phoneNumber: 9876543210
   gender: male
   dateOfBirth: 1990-05-15
   profilePhoto: <select PNG/JPG file, max 2MB>
   ```
3. Verify response:
   - `success: true`
   - `data.step: 1`
   - `data.nextStep: 2`

**Expected Result:** ✅ 200 OK

---

#### T2.2 - Verify Profile Photo Upload
**Objective:** Confirm photo is uploaded and stored securely

**Steps:**
1. Execute T2.1
2. Query database:
   ```sql
   SELECT profile_photo_url FROM doctor_profiles
   WHERE user_id = '<doctor_id>';
   ```
3. Verify:
   - `profile_photo_url` is not NULL
   - File exists in `/backend/uploads/profile-photos/`
   - File has randomized name (not original)

**Expected Result:** ✅ Photo uploaded with secure naming

---

#### T2.3 - Validate Phone Number
**Objective:** Ensure phone validation rejects invalid numbers

**Steps:**
1. POST /api/doctors/onboarding/basic-info
2. Send invalid phone: `phoneNumber: 123`
3. Verify error response:
   - `success: false`
   - Error message contains "phone" and "10"

**Expected Result:** ✅ 400 Validation Error

---

#### T2.4 - Validate Date of Birth
**Objective:** Ensure DOB validation rejects invalid dates

**Test Cases:**
- Future date → ❌ Error
- 10 years old → ❌ Error (under 18)
- Invalid format → ❌ Error
- Valid 1985 → ✅ Success

**Expected Result:** ✅ All validations work

---

#### T2.5 - Retrieve Saved Basic Info
**Objective:** Verify saved data can be retrieved

**Steps:**
1. GET /api/doctors/onboarding/basic-info
2. Verify response contains:
   - `phoneNumber: 9876543210`
   - `gender: male`
   - `dateOfBirth: 1990-05-15`
   - `profilePhoto: <URL>`

**Expected Result:** ✅ 200 OK, correct data

---

### TEST SET 3: Step 2 - Professional Details

#### T3.1 - Save Professional Details
**Objective:** Verify Step 2 endpoint saves expertise

**Steps:**
1. POST /api/doctors/onboarding/professional-details
2. Body (form-data):
   ```json
   {
     "primaryTitle": "Clinical Psychologist",
     "secondaryTitle": "Therapist",
     "specializations": [
       {
         "category": "Anxiety Issues",
         "subSpecializations": ["Panic attacks", "Social anxiety"]
       }
     ],
     "therapyApproaches": ["CBT", "DBT"],
     "languages": ["English", "Hindi"],
     "bio": "I specialize in anxiety disorders and trauma therapy..."
   }
   ```
3. Add files:
   - `govtIdFront: <PDF/PNG>`
   - `govtIdBack: <PDF/PNG>`
4. Verify response:
   - `success: true`
   - `data.step: 2`

**Expected Result:** ✅ 200 OK

---

#### T3.2 - Verify Government ID Upload
**Objective:** Confirm govt IDs are securely stored

**Steps:**
1. Query database:
   ```sql
   SELECT govt_id_front_url, govt_id_back_url FROM doctor_profiles
   WHERE user_id = '<doctor_id>';
   ```
2. Verify files exist in `/backend/uploads/govt-id/`

**Expected Result:** ✅ Both files uploaded and stored

---

#### T3.3 - Validate Bio Length
**Objective:** Ensure bio length limit is enforced

**Steps:**
1. POST /api/doctors/onboarding/professional-details
2. Send bio > 600 characters
3. Verify error message about length limit

**Expected Result:** ✅ 400 Validation Error

---

#### T3.4 - Retrieve Professional Details
**Objective:** Verify saved details can be retrieved

**Steps:**
1. GET /api/doctors/onboarding/professional-details
2. Verify all fields are returned correctly

**Expected Result:** ✅ 200 OK, complete data

---

### TEST SET 4: Step 3 - Qualifications

#### T4.1 - Add Single Qualification
**Objective:** Verify qualification CRUD works

**Steps:**
1. POST /api/doctors/onboarding/qualifications
2. Body (form-data):
   ```json
   {
     "degree": "M.A. Clinical Psychology",
     "institution": "Delhi University",
     "specialization": "Cognitive Behavioral Therapy",
     "passingYear": 2010,
     "certificate": <PDF file>
   }
   ```
3. Verify response:
   - `success: true`
   - `data.id` returned

**Expected Result:** ✅ 201 Created

---

#### T4.2 - Add Multiple Qualifications
**Objective:** Verify multiple qualifications can be added

**Steps:**
1. Execute T4.1 (qualification 1)
2. Add second qualification with different degree/institution
3. Verify both can be added

**Expected Result:** ✅ Both qualifications stored

---

#### T4.3 - List Qualifications
**Objective:** Verify all qualifications are retrievable

**Steps:**
1. GET /api/doctors/onboarding/qualifications
2. Verify response contains:
   - `count: 2`
   - Both qualifications in list
   - All fields present

**Expected Result:** ✅ 200 OK, complete list

---

#### T4.4 - Update Qualification
**Objective:** Verify qualification can be updated

**Steps:**
1. Get qualification ID from T4.1
2. PUT /api/doctors/onboarding/qualifications/{id}
3. Send updated data:
   ```json
   {
     "specialization": "Mindfulness-Based Cognitive Therapy"
   }
   ```
4. Verify response confirms update

**Expected Result:** ✅ 200 OK

---

#### T4.5 - Delete Qualification
**Objective:** Verify qualification can be deleted

**Steps:**
1. DELETE /api/doctors/onboarding/qualifications/{id}
2. Verify response: `success: true`
3. GET list again and verify count decreased

**Expected Result:** ✅ 200 OK, qualification removed

---

#### T4.6 - Validate Passing Year
**Objective:** Ensure year validation works

**Test Cases:**
- Year 1800 → ❌ Error
- Future year → ❌ Error
- Current year → ✅ Success
- 2010 → ✅ Success

**Expected Result:** ✅ Year validation works

---

### TEST SET 5: Step 4 - Professional Registration

#### T5.1 - Save RCI Registration
**Objective:** Verify RCI registration is saved

**Steps:**
1. POST /api/doctors/onboarding/verification
2. Body (form-data):
   ```json
   {
     "registrationType": "rci",
     "rciNumber": "A-12345/2010",
     "rciCertificate": <PDF file>,
     "selfDeclarationAgreed": true
   }
   ```
3. Verify response: `success: true`

**Expected Result:** ✅ 200 OK

---

#### T5.2 - Save Self-Declaration Only
**Objective:** Verify non-RCI registration option works

**Steps:**
1. POST /api/doctors/onboarding/verification
2. Body:
   ```json
   {
     "registrationType": "none",
     "selfDeclarationAgreed": true
   }
   ```
3. Verify response: `success: true`

**Expected Result:** ✅ 200 OK

---

#### T5.3 - Retrieve Registration Details
**Objective:** Verify saved registration details can be retrieved

**Steps:**
1. GET /api/doctors/onboarding/verification
2. Verify correct registration type returned

**Expected Result:** ✅ 200 OK

---

### TEST SET 6: Step 5 - Work Experience

#### T6.1 - Add Single Experience
**Objective:** Verify experience CRUD works

**Steps:**
1. POST /api/doctors/onboarding/experiences
2. Body (form-data):
   ```json
   {
     "organization": "Apollo Hospitals",
     "role": "Senior Therapist",
     "workType": "hospital",
     "startDate": "2018-01-15",
     "endDate": "2022-06-30",
     "currentlyWorking": false,
     "description": "Provided therapy services...",
     "proofDocument": <PDF file>
   }
   ```
3. Verify response: `success: true`

**Expected Result:** ✅ 201 Created

---

#### T6.2 - Add Current Work Experience
**Objective:** Verify current work (no end date) is accepted

**Steps:**
1. POST /api/doctors/onboarding/experiences
2. Body:
   ```json
   {
     "organization": "Private Practice",
     "role": "Therapist",
     "workType": "private_practice",
     "startDate": "2022-07-01",
     "currentlyWorking": true,
     "endDate": null
   }
   ```
3. Verify response: `success: true`

**Expected Result:** ✅ 201 Created

---

#### T6.3 - Validate Date Range
**Objective:** Ensure end date must be after start date

**Steps:**
1. POST /api/doctors/onboarding/experiences
2. Send endDate before startDate
3. Verify error response

**Expected Result:** ✅ 400 Validation Error

---

#### T6.4 - List Experiences
**Objective:** Verify all experiences are retrievable

**Steps:**
1. GET /api/doctors/onboarding/experiences
2. Verify count matches added experiences
3. Verify all fields present

**Expected Result:** ✅ 200 OK, complete list

---

#### T6.5 - Update Experience
**Objective:** Verify experience can be updated

**Steps:**
1. PUT /api/doctors/onboarding/experiences/{id}
2. Update role: `"role": "Lead Therapist"`
3. Verify update successful

**Expected Result:** ✅ 200 OK

---

#### T6.6 - Delete Experience
**Objective:** Verify experience can be deleted

**Steps:**
1. DELETE /api/doctors/onboarding/experiences/{id}
2. Verify response: `success: true`
3. GET list and verify count decreased

**Expected Result:** ✅ 200 OK

---

### TEST SET 7: Step 6 - Session Pricing

#### T7.1 - Save Pricing
**Objective:** Verify pricing is saved correctly

**Steps:**
1. POST /api/doctors/onboarding/pricing
2. Body:
   ```json
   {
     "sessionPrice": 999,
     "consultationDuration": "60min",
     "followUpPrice": 599,
     "currency": "INR"
   }
   ```
3. Verify response: `success: true`

**Expected Result:** ✅ 200 OK

---

#### T7.2 - Validate Price Range
**Objective:** Ensure price validation works

**Test Cases:**
- Negative price → ❌ Error
- Zero price → ❌ Error
- 99999.99 → ✅ Success
- 999 → ✅ Success

**Expected Result:** ✅ Price validation works

---

#### T7.3 - Retrieve Pricing
**Objective:** Verify pricing can be retrieved

**Steps:**
1. GET /api/doctors/onboarding/pricing
2. Verify all fields returned correctly

**Expected Result:** ✅ 200 OK

---

### TEST SET 8: Step 7 - Payout Setup

#### T8.1 - Save Payout Account
**Objective:** Verify payout account is saved

**Steps:**
1. POST /api/doctors/onboarding/payout
2. Body:
   ```json
   {
     "accountHolderName": "Dr. Test User",
     "accountNumber": "123456789012",
     "ifscCode": "HDFC0000001",
     "bankName": "HDFC Bank",
     "branchName": "Delhi Main",
     "panNumber": "AAAAA0000A",
     "isGstRegistered": true,
     "gstNumber": "18AABCT1234H1Z0"
   }
   ```
3. Verify response: `success: true`

**Expected Result:** ✅ 200 OK

---

#### T8.2 - Validate PAN Number
**Objective:** Ensure PAN format validation works

**Test Cases:**
- Invalid format → ❌ Error
- "AAAAA0000A" → ✅ Success

**Expected Result:** ✅ PAN validation works

---

#### T8.3 - Validate IFSC Code
**Objective:** Ensure IFSC format validation works

**Test Cases:**
- Invalid format → ❌ Error
- "HDFC0000001" → ✅ Success

**Expected Result:** ✅ IFSC validation works

---

#### T8.4 - Validate GST Number
**Objective:** Ensure GST format validation works

**Test Cases:**
- Invalid format → ❌ Error
- "18AABCT1234H1Z0" → ✅ Success

**Expected Result:** ✅ GST validation works

---

#### T8.5 - Retrieve Payout Account
**Objective:** Verify payout account can be retrieved

**Steps:**
1. GET /api/doctors/onboarding/payout
2. Verify all fields returned correctly

**Expected Result:** ✅ 200 OK

---

### TEST SET 9: Onboarding Submission

#### T9.1 - Submit Complete Onboarding
**Objective:** Verify all 7 steps can be submitted

**Prerequisites:**
- All steps 1-7 completed successfully

**Steps:**
1. POST /api/doctors/onboarding/submit
2. Verify response:
   - `success: true`
   - `data.verificationStatus: "submitted"`
   - `data.message` contains "admin review"

**Expected Result:** ✅ 200 OK

---

#### T9.2 - Verify Onboarding Status After Submit
**Objective:** Confirm status is updated in database

**Steps:**
1. Query database:
   ```sql
   SELECT onboarding_completed, verification_status FROM users u
   JOIN doctor_profiles dp ON u.id = dp.user_id
   WHERE u.id = '<doctor_id>';
   ```
2. Verify:
   - `onboarding_completed: 1`
   - `verification_status: submitted`

**Expected Result:** ✅ Correct status

---

#### T9.3 - Submit with Incomplete Steps
**Objective:** Verify submission fails when steps missing

**Steps:**
1. Create new doctor, complete only Step 1-3
2. POST /api/doctors/onboarding/submit
3. Verify error:
   - `success: false`
   - `code: INCOMPLETE_STEPS`
   - Details list missing steps

**Expected Result:** ✅ 400 Error with details

---

#### T9.4 - Get Onboarding Status
**Objective:** Verify status endpoint returns current state

**Steps:**
1. After submission, GET /api/doctors/onboarding/status
2. Verify response contains:
   - `registrationStep: 7`
   - `onboardingCompleted: true`
   - `verificationStatus: submitted`

**Expected Result:** ✅ 200 OK

---

### TEST SET 10: Admin Verification

#### T10.1 - List Pending Onboardings
**Objective:** Verify admin can see submitted profiles

**Steps:**
1. Use admin token
2. GET /api/admin/onboarding/pending
3. Verify response:
   - `count > 0`
   - Submitted doctor visible in list
   - Fields: id, email, full_name, verification_status, submitted_at

**Expected Result:** ✅ 200 OK

---

#### T10.2 - Get Onboarding Details
**Objective:** Verify admin can see complete profile

**Steps:**
1. Use admin token
2. GET /api/admin/onboarding/{doctorId}
3. Verify response contains:
   - `profile` with all submitted data
   - `verificationLogs` with history

**Expected Result:** ✅ 200 OK

---

#### T10.3 - Approve Profile
**Objective:** Verify admin can approve profile

**Steps:**
1. Use admin token
2. POST /api/admin/onboarding/{doctorId}/approve
3. Verify response:
   - `success: true`
   - `data.verificationStatus: approved`

**Expected Result:** ✅ 200 OK

---

#### T10.4 - Verify Approval in Database
**Objective:** Confirm approval is persisted

**Steps:**
1. Query database:
   ```sql
   SELECT verification_status, is_profile_approved, reviewed_at
   FROM doctor_profiles WHERE user_id = '<doctor_id>';
   ```
2. Verify:
   - `verification_status: approved`
   - `is_profile_approved: 1`
   - `reviewed_at` is not NULL

**Expected Result:** ✅ Correct values

---

#### T10.5 - Reject Profile
**Objective:** Verify admin can reject profile

**Steps:**
1. Create new doctor, complete onboarding
2. Use admin token
3. POST /api/admin/onboarding/{doctorId}/reject
4. Body: `{"reason": "Certificate not clear"}`
5. Verify response:
   - `success: true`
   - `data.verificationStatus: rejected`

**Expected Result:** ✅ 200 OK

---

#### T10.6 - Request Resubmission
**Objective:** Verify admin can request resubmission

**Steps:**
1. Create new doctor, complete onboarding
2. Use admin token
3. POST /api/admin/onboarding/{doctorId}/request-resubmission
4. Body: `{"reason": "Please reupload clearer copies"}`
5. Verify response:
   - `success: true`
   - `data.verificationStatus: resubmission_required`

**Expected Result:** ✅ 200 OK

---

### TEST SET 11: Verification Logs

#### T11.1 - Verify Audit Trail
**Objective:** Confirm all actions are logged

**Steps:**
1. Complete steps T1 through T9
2. Query database:
   ```sql
   SELECT action, step_number, admin_id, created_at
   FROM doctor_verification_logs
   WHERE doctor_id = '<doctor_id>'
   ORDER BY created_at;
   ```
3. Verify log entries for:
   - Step 1 completed
   - Step 2 completed
   - ... Step 7 completed
   - profile_submitted_for_review

**Expected Result:** ✅ Complete audit trail

---

#### T11.2 - Verify Admin Actions Logged
**Objective:** Confirm admin actions are tracked

**Steps:**
1. Approve a profile (T10.3)
2. Query database for admin action:
   ```sql
   SELECT action, admin_id, created_at FROM doctor_verification_logs
   WHERE doctor_id = '<doctor_id>' AND action = 'profile_approved';
   ```
3. Verify:
   - Action logged
   - Admin ID recorded
   - Timestamp recorded

**Expected Result:** ✅ Admin action logged

---

### TEST SET 12: File Upload Security

#### T12.1 - Block Executable Files
**Objective:** Verify .php files cannot be uploaded

**Steps:**
1. Create test.php file
2. Try to upload as profile photo
3. Verify error: file type not allowed

**Expected Result:** ✅ 400 Error

---

#### T12.2 - Enforce File Size Limit
**Objective:** Verify large files are rejected

**Steps:**
1. Create > 5MB PDF file
2. Try to upload as qualification certificate
3. Verify error: file too large

**Expected Result:** ✅ 400 Error

---

#### T12.3 - Validate MIME Type
**Objective:** Verify MIME type detection works

**Steps:**
1. Rename .jpg to .pdf
2. Upload as certification
3. Verify either:
   - Accepted if MIME correct
   - Rejected if MIME detection catches mismatch

**Expected Result:** ✅ MIME validation works

---

### TEST SET 13: Edge Cases

#### T13.1 - Duplicate Account Number
**Objective:** Verify duplicate account numbers are rejected

**Steps:**
1. Create doctor 1, add payout with account 123456789012
2. Create doctor 2, try to add same account
3. Verify error

**Expected Result:** ✅ 400 Error

---

#### T13.2 - Resume After Logout
**Objective:** Verify doctor can resume onboarding

**Steps:**
1. Complete Step 1-3
2. Logout
3. Login again
4. GET /api/doctors/onboarding/status
5. Verify `registrationStep: 3`
6. Continue to Step 4

**Expected Result:** ✅ Can resume correctly

---

#### T13.3 - Go Back and Edit
**Objective:** Verify doctor can edit previous steps

**Steps:**
1. Complete all 7 steps
2. Edit Step 1 (update phone number)
3. POST updated data to Step 1 endpoint
4. Verify update saved
5. Re-verify after refetch

**Expected Result:** ✅ Can edit and update

---

#### T13.4 - Unauthorized Access
**Objective:** Verify endpoints require authentication

**Steps:**
1. Try to access /api/doctors/onboarding/basic-info without token
2. Verify error: 401 Unauthorized

**Expected Result:** ✅ 401 Error

---

#### T13.5 - Non-Doctor User
**Objective:** Verify non-doctors cannot access onboarding

**Steps:**
1. Register as "client" user
2. Try to POST /api/doctors/onboarding/basic-info
3. Verify error

**Expected Result:** ✅ 403 Forbidden or 400 Error

---

## 📊 Test Execution Matrix

| Test Set | Scenario Count | Priority | Status |
|----------|---|---|---|
| T1 | Auth & Init | Critical | ⬜ To Do |
| T2 | Basic Info | Critical | ⬜ To Do |
| T3 | Professional | Critical | ⬜ To Do |
| T4 | Qualifications | Critical | ⬜ To Do |
| T5 | Registration | Critical | ⬜ To Do |
| T6 | Experience | Critical | ⬜ To Do |
| T7 | Pricing | Critical | ⬜ To Do |
| T8 | Payout | Critical | ⬜ To Do |
| T9 | Submission | Critical | ⬜ To Do |
| T10 | Admin Verify | High | ⬜ To Do |
| T11 | Audit Logs | High | ⬜ To Do |
| T12 | Security | High | ⬜ To Do |
| T13 | Edge Cases | Medium | ⬜ To Do |

**Total Tests:** 73  
**Critical:** 63  
**High:** 7  
**Medium:** 3  

---

## ✅ Pass Criteria

- ✅ All critical tests pass
- ✅ All high priority tests pass
- ✅ No security issues found
- ✅ No data corruption
- ✅ All emails sent correctly
- ✅ Database integrity maintained
- ✅ Complete audit trail recorded

---

## 🐛 Bug Report Template

```
Title: [Test ID] - Brief Description
Priority: Critical|High|Medium|Low
Environment: Development|Staging|Production

Steps to Reproduce:
1. ...
2. ...
3. ...

Expected Result:
- ...

Actual Result:
- ...

Error Messages:
- ...

Attachments:
- Screenshots
- Postman collection export
- Database queries
```

---

## 📝 Sign-Off

**Test Execution Date:** ___________
**Executed By:** ___________
**Result:** ✅ Pass | ❌ Fail | ⚠️ Conditional Pass

**Notes:**
```
_______________________________________
_______________________________________
_______________________________________
```

