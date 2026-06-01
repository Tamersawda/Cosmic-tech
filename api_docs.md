### Detailed API Endpoints (Parsed from Postman Collection)

### 🔐 1. Authentication

#### Register Doctor
**Method:** `POST`  
**Endpoint:** `/api/auth/register`  

**Headers:**
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "name": "Dr. Test User",
  "email": "doctor{{$timestamp}}@example.com",
  "password": "SecurePass123!",
  "role": "doctor"
}
```

---

#### Register Client
**Method:** `POST`  
**Endpoint:** `/api/auth/register`  

**Headers:**
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "name": "Client Test User",
  "email": "client{{$timestamp}}@example.com",
  "password": "SecurePass123!",
  "role": "client"
}
```

---

#### Login
**Method:** `POST`  
**Endpoint:** `/api/auth/login`  

**Headers:**
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "email": "doctor@example.com",
  "password": "SecurePass123!"
}
```

---

#### Get Current User (me)
**Method:** `GET`  
**Endpoint:** `/api/auth/me`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### Logout
**Method:** `POST`  
**Endpoint:** `/api/auth/logout`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### [NEGATIVE] Register – missing role
**Method:** `POST`  
**Endpoint:** `/api/auth/register`  

**Headers:**
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "name": "No Role User",
  "email": "norole@test.com",
  "password": "Pass123!"
}
```

---

#### [NEGATIVE] Login – wrong password
**Method:** `POST`  
**Endpoint:** `/api/auth/login`  

**Headers:**
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "email": "doctor@example.com",
  "password": "WrongPassword!"
}
```

---

### 👨‍⚕️ 2. Doctor Onboarding – Step 1: Basic Info

#### Save Basic Information
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/basic-info`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: multipart/form-data

**Body (FormData):**
- `phoneNumber` (text)
- `gender` (text)
- `dateOfBirth` (text)
- `profilePhoto` (file)

---

#### Get Basic Information
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/basic-info`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

### 👨‍⚕️ 3. Doctor Onboarding – Step 2: Professional Details

#### Save Professional Details
**Method:** `POST`  
**Endpoint:** ``  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: multipart/form-data

**Body (FormData):**
- `primaryTitle` (text)
- `secondaryTitle` (text)
- `specializations` (text)
- `languagesSpoken` (text)
- `professionalBio` (text)
- `therapyApproaches` (text)
- `govtIdFront` (file)
- `govtIdBack` (file)

---

#### Get Professional Details
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/professional-details`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

### 👨‍⚕️ 4. Doctor Onboarding – Step 3: Qualifications

#### Add Qualification
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/qualifications`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: multipart/form-data

**Body (FormData):**
- `qualificationName` (text)
- `institution` (text)
- `passingYear` (text)
- `certificateUrl` (file)

---

#### List Qualifications
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/qualifications`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### Update Qualification
**Method:** `PUT`  
**Endpoint:** `/api/doctors/onboarding/qualifications/{{qualificationId}}`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "qualificationName": "Doctor of Philosophy (PhD) in Clinical Psychology",
  "passingYear": 2015
}
```

---

#### Delete Qualification
**Method:** `DELETE`  
**Endpoint:** `/api/doctors/onboarding/qualifications/{{qualificationId}}`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### [NEGATIVE] Upload invalid file type
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/qualifications`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: multipart/form-data

**Body (FormData):**
- `qualificationName` (text)
- `passingYear` (text)
- `document` (file)
- `institution` (text)

---

### 👨‍⚕️ 5. Doctor Onboarding – Step 4: Professional Registration

#### Save Professional Registration (RCI/Verification)
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/professional-registration`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: multipart/form-data

**Body (FormData):**
- `registrationType` (text)
- `rciCrrNumber` (text)
- `selfDeclarationAccepted` (text)
- `rciCertificate` (file)

---

#### Get Professional Registration
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/professional-registration`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

### 👨‍⚕️ 6. Doctor Onboarding – Step 5: Work Experience

#### Add Experience
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/work-experience`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "organization": "City Mental Health Clinic",
  "role": "Senior Clinical Psychologist",
  "workType": "clinic",
  "startDate": "2018-01-15",
  "endDate": null
}
```

---

#### List Experiences
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/work-experience`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### Update Experience
**Method:** `PUT`  
**Endpoint:** `/api/doctors/onboarding/work-experience/{{experienceId}}`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "organization": "Advanced Mental Health Center",
  "role": "Lead Psychologist"
}
```

---

#### Delete Experience
**Method:** `DELETE`  
**Endpoint:** `/api/doctors/onboarding/work-experience/{{experienceId}}`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### [NEGATIVE] Create – missing endDate for past employment
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/work-experience`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "organization": "Bad Hospital",
  "role": "Doctor",
  "workType": "hospital",
  "startDate": "2020-01-01"
}
```

---

### 👨‍⚕️ 7. Doctor Onboarding – Step 6: Session Fee (Pricing)

#### Save Session Fee
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/session-fee`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "sessionFeeTier": "999",
  "pricingJustification": "Based on my experience level and market research in my area"
}
```

---

#### Get Session Fee
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/session-fee`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

### 👨‍⚕️ 9. Doctor Onboarding – Step 8: Payout

#### Save Payout Information
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/payout`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "accountHolderName": "Dr. Jane Smith",
  "accountNumber": "1234567890",
  "ifscCode": "HDFC0001234",
  "bankName": "HDFC Bank",
  "branchName": "New York Branch",
  "panNumber": "ABCDE1234F",
  "isGstRegistered": false,
  "gstNumber": null,
  "termsConsent": true
}
```

---

#### Get Payout Information
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/payout`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

### ✅ 10. Doctor Onboarding – Submission & Status

#### Get Onboarding Status
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/status`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### Submit Onboarding
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/submit`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{}
```

---

### 🛡️ 11. Admin Management

#### List All Doctors
**Method:** `GET`  
**Endpoint:** `/api/admin/doctors`  

**Headers:**
- `Authorization`: Bearer {{adminToken}}

---

#### Verify Doctor
**Method:** `PUT`  
**Endpoint:** `/api/admin/doctors/{{doctorId}}/verify`  

**Headers:**
- `Authorization`: Bearer {{adminToken}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "status": "approved",
  "notes": "Profile verified successfully"
}
```

---

#### Get Admin Dashboard
**Method:** `GET`  
**Endpoint:** `/api/admin/dashboard`  

**Headers:**
- `Authorization`: Bearer {{adminToken}}

---

#### [DEPRECATED] Verify Doctor (old endpoint)
**Method:** `PATCH`  
**Endpoint:** `/api/admin/verify-doctor`  

**Headers:**
- `Authorization`: Bearer {{adminToken}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "doctorId": "{{doctorId}}",
  "status": "approved"
}
```

---

#### [NEGATIVE] List doctors – non-admin token
**Method:** `GET`  
**Endpoint:** `/api/admin/doctors`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

### 📅 12. Appointments

#### Book Appointment
**Method:** `POST`  
**Endpoint:** `/api/appointments`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "doctorId": "{{doctorId}}",
  "scheduledDate": "2026-06-15",
  "scheduledTime": "10:00",
  "consultationType": "video",
  "reason": "Anxiety consultation"
}
```

---

#### List My Appointments
**Method:** `GET`  
**Endpoint:** `/api/appointments`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### Get Appointment Details
**Method:** `GET`  
**Endpoint:** `/api/appointments/{{appointmentId}}`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

#### Cancel Appointment
**Method:** `PATCH`  
**Endpoint:** `/api/appointments/{{appointmentId}}/cancel`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "reason": "Schedule conflict",
  "cancellationReason": "Personal emergency"
}
```

---

#### Get Available Slots
**Method:** `GET`  
**Endpoint:** `/api/appointments/available-slots?doctorId={{doctorId}}&date=2026-06-15`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

### 🔧 13. DEPRECATED ENDPOINTS

#### [DEPRECATED] Setup Doctor Profile (Old)
**Method:** `POST`  
**Endpoint:** `/api/doctors/setup`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: multipart/form-data

**Body (FormData):**
- `gender` (text)
- `dateOfBirth` (text)
- `phoneNumber` (text)
- `profilePhoto` (file)

---

#### [DEPRECATED] Setup Client Profile (Old)
**Method:** `POST`  
**Endpoint:** `/api/clients/setup`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "step": 1,
  "gender": "female",
  "dateOfBirth": "1995-05-15",
  "phoneNumber": "+1987654321"
}
```

---

#### [NEGATIVE] Add Qualification – missing institution
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/qualifications`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: multipart/form-data

**Body (FormData):**
- `qualificationName` (text)
- `passingYear` (text)
- `institution` (text)

---

#### [NEGATIVE] Save Pricing – invalid session fee tier
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/session-fee`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "sessionFeeTier": "500",
  "pricingJustification": "This tier value is invalid"
}
```

---

#### [NEGATIVE] Save Pricing – justification too short
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/session-fee`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "sessionFeeTier": "999",
  "pricingJustification": "Too short"
}
```

---

#### [NEGATIVE] Save Payout – missing termsConsent
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/payout`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "accountHolderName": "Dr. Test",
  "accountNumber": "1234567890",
  "ifscCode": "HDFC0001234",
  "bankName": "HDFC Bank",
  "branchName": "Branch",
  "panNumber": "ABCDE1234F"
}
```

---

#### [NEGATIVE] Save Payout – termsConsent=false
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/payout`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "accountHolderName": "Dr. Test",
  "accountNumber": "1234567890",
  "ifscCode": "HDFC0001234",
  "bankName": "HDFC",
  "branchName": "Branch",
  "panNumber": "ABCDE1234F",
  "termsConsent": false
}
```

---

#### [NEGATIVE] Add Experience – missing endDate for past work
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/work-experience`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "organization": "Past Clinic",
  "role": "Consultant",
  "workType": "clinic",
  "startDate": "2018-01-01"
}
```

---

#### [NEGATIVE] Add Experience – workType='other' without customWorkType
**Method:** `POST`  
**Endpoint:** `/api/doctors/onboarding/work-experience`  

**Headers:**
- `Authorization`: Bearer {{token}}
- `Content-Type`: application/json

**Body (JSON):**
```json
{
  "organization": "Unknown Org",
  "role": "Consultant",
  "workType": "other",
  "startDate": "2024-01-01"
}
```

---

#### [NEGATIVE] API call – Missing Authorization header
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/basic-info`  

---

#### [NEGATIVE] API call – Invalid JWT token
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/basic-info`  

**Headers:**
- `Authorization`: Bearer INVALID_TOKEN_12345

---

#### [NEGATIVE] API call – Non-existent resource
**Method:** `GET`  
**Endpoint:** `/api/doctors/onboarding/qualifications/non-existent-id`  

**Headers:**
- `Authorization`: Bearer {{token}}

---

