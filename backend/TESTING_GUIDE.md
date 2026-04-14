# Phase 3 Manual Testing Guide

## Prerequisites
1. Database is set up with schema from `db/schema.sql`
2. `.env` file configured with:
   - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
   - JWT_SECRET
   - APP_ENV=development (for error details)

3. Server running: `php -S localhost:8080 api.php`

## Test Scenario

### Step 1: Create Test Users

**Doctor Registration:**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "dr.smith@test.com",
    "password": "SecurePass123",
    "userType": "doctor",
    "fullName": "Dr. James Smith"
  }'
```
Save the `access_token` as `$DOCTOR_TOKEN`

**Patient Registration:**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.patient@test.com",
    "password": "SecurePass123",
    "userType": "patient",
    "fullName": "John Patient"
  }'
```
Save the `access_token` as `$PATIENT_TOKEN`

### Step 2: Doctor Profile Setup

```bash
curl -X POST http://localhost:8080/api/doctors/setup \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DOCTOR_TOKEN" \
  -d '{
    "fullName": "Dr. James Smith",
    "gender": "male",
    "dateOfBirth": "1980-05-15",
    "phoneNumber": "+1-555-0100",
    "primarySpecialty": "Clinical Psychology",
    "yearsOfExperience": 12,
    "licenseNumber": "PSY-2024-001",
    "languagesSpoken": ["English", "Spanish"],
    "videoEnabled": true,
    "videoRate": 100.00,
    "consultationDuration": "50min",
    "bufferTime": "10min"
  }'
```

**Expected Response: 201**
```json
{
  "success": true,
  "data": {
    "doctor_id": "...",
    "profile_status": "completed",
    "message": "Doctor profile setup completed successfully",
    "profile": { ... }
  }
}
```

### Step 3: Patient Profile Setup

```bash
curl -X POST http://localhost:8080/api/patients/setup \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -d '{
    "firstName": "John",
    "lastName": "Patient",
    "gender": "male",
    "dateOfBirth": "1995-08-20",
    "phoneNumber": "+1-555-0200",
    "medicalHistory": "Anxiety disorder, currently managed"
  }'
```

**Expected Response: 201**

### Step 4: Test Appointment Booking

**4a. Book Valid Appointment**
```bash
curl -X POST http://localhost:8080/api/appointments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -d '{
    "doctorId": "<DOCTOR_USER_ID>",
    "scheduledDate": "2026-04-20",
    "scheduledTime": "14:00",
    "consultationType": "video"
  }'
```

**Expected Response: 201**
```json
{
  "success": true,
  "data": {
    "appointment_id": "...",
    "status": "scheduled",
    "scheduled_date": "2026-04-20",
    "scheduled_time": "14:00",
    "end_time": "14:50",
    "consultation_type": "video",
    "message": "Appointment booked successfully"
  }
}
```

**Save appointment_id as $APPOINTMENT_ID**

---

### Test 4b: Attempt Duplicate Booking (SHOULD FAIL)

```bash
curl -X POST http://localhost:8080/api/appointments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -d '{
    "doctorId": "<DOCTOR_USER_ID>",
    "scheduledDate": "2026-04-20",
    "scheduledTime": "14:00",
    "consultationType": "audio"
  }'
```

**Expected Response: 409**
```json
{
  "success": false,
  "message": "Doctor has an existing appointment at this time"
}
```

---

### Test 4c: Attempt Overlapping Booking (SHOULD FAIL)

```bash
curl -X POST http://localhost:8080/api/appointments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -d '{
    "doctorId": "<DOCTOR_USER_ID>",
    "scheduledDate": "2026-04-20",
    "scheduledTime": "14:30",
    "consultationType": "video"
  }'
```

**Expected Response: 409** (new_start 14:30 < existing_end 14:50)

---

### Test 4d: Attempt Past Time Booking (SHOULD FAIL)

```bash
curl -X POST http://localhost:8080/api/appointments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -d '{
    "doctorId": "<DOCTOR_USER_ID>",
    "scheduledDate": "2026-01-01",
    "scheduledTime": "10:00",
    "consultationType": "video"
  }'
```

**Expected Response: 400**

---

### Test 4e: Attempt Non-Whole-Hour Slot (SHOULD FAIL)

```bash
curl -X POST http://localhost:8080/api/appointments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -d '{
    "doctorId": "<DOCTOR_USER_ID>",
    "scheduledDate": "2026-04-21",
    "scheduledTime": "14:30",
    "consultationType": "video"
  }'
```

**Expected Response: 400** (must be whole hour)

---

### Step 5: Get Appointments

**Doctor View:**
```bash
curl -X GET "http://localhost:8080/api/doctors/appointments" \
  -H "Authorization: Bearer $DOCTOR_TOKEN"
```

**Expected Response: 200 with 1 appointment**

**Patient View:**
```bash
curl -X GET "http://localhost:8080/api/patients/appointments" \
  -H "Authorization: Bearer $PATIENT_TOKEN"
```

**Expected Response: 200 with 1 appointment**

---

### Step 6: Cancel Appointment

```bash
curl -X PATCH "http://localhost:8080/api/appointments/$APPOINTMENT_ID/cancel" \
  -H "Authorization: Bearer $PATIENT_TOKEN"
```

**Expected Response: 200**
```json
{
  "success": true,
  "data": {
    "appointment_id": "...",
    "status": "cancelled",
    "message": "Appointment cancelled successfully"
  }
}
```

---

## Validation Checklist

- [ ] Doctor profile created successfully
- [ ] Patient profile created successfully
- [ ] Valid appointment booked (201)
- [ ] Duplicate booking rejected (409)
- [ ] Overlapping booking rejected (409)
- [ ] Past time booking rejected (400)
- [ ] Non-whole-hour booking rejected (400)
- [ ] Doctor can view appointments
- [ ] Patient can view appointments
- [ ] Appointment can be cancelled (200)
- [ ] Cancelled appointment status updated
- [ ] Non-scheduled appointments cannot be cancelled

## Error Testing

### Unauthorized Access
```bash
curl -X POST http://localhost:8080/api/doctors/setup \
  -H "Content-Type: application/json" \
  -d '{"fullName": "..."}' 
```
**Expected: 401 Unauthorized**

### Role Enforcement
```bash
curl -X POST http://localhost:8080/api/doctors/setup \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -d '{"fullName": "..."}'
```
**Expected: 403 Forbidden**

### Missing Doctor
```bash
curl -X POST http://localhost:8080/api/appointments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -d '{
    "doctorId": "nonexistent-id",
    "scheduledDate": "2026-04-20",
    "scheduledTime": "14:00",
    "consultationType": "video"
  }'
```
**Expected: 404 Not Found**

## Success Criteria

All tests pass when:
1. ✓ Profiles created with correct data
2. ✓ Valid appointments book successfully
3. ✓ Overlaps are prevented (409)
4. ✓ Time slots are validated
5. ✓ End times calculated correctly (50 min + 10 min buffer)
6. ✓ Role-based access enforced
7. ✓ Cancellations work correctly
8. ✓ All HTTP status codes are correct

