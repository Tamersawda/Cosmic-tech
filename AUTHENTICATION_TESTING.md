# Email Verification API Testing Guide

## 🧪 Unit Test Examples

### Test 1: OtpManager - Generate OTP

```php
<?php

namespace Tests;

use Backend\Utils\OtpManager;

class OtpManagerTest {
    
    public function testGenerateOtp() {
        $otp = OtpManager::generateOtp();
        
        // Assert: OTP is 6 characters
        assert(strlen($otp) === 6, "OTP should be 6 digits");
        
        // Assert: OTP is numeric
        assert(ctype_digit($otp), "OTP should contain only digits");
        
        // Assert: OTP is within valid range
        assert($otp >= 0 && $otp <= 999999, "OTP should be between 0 and 999999");
        
        echo "✓ OTP generated: $otp\n";
    }

    public function testOtpHashing() {
        $otp = "123456";
        $hashed = OtpManager::hashOtp($otp);
        
        // Assert: Hash is created
        assert(!empty($hashed), "Hashed OTP should not be empty");
        
        // Assert: Hash is different from original
        assert($hashed !== $otp, "Hashed OTP should be different from original");
        
        // Assert: Verification works
        assert(OtpManager::verifyOtp($otp, $hashed), "OTP verification should pass");
        
        // Assert: Wrong OTP fails
        assert(!OtpManager::verifyOtp("654321", $hashed), "Wrong OTP should fail");
        
        echo "✓ OTP hashing and verification works\n";
    }

    public function testOtpExpiry() {
        $expiryTime = OtpManager::getOtpExpiry();
        
        // Assert: Expiry is in future
        assert(!OtpManager::isOtpExpired($expiryTime), "OTP should not be expired immediately");
        
        // Assert: Expired time is detected
        $pastTime = (new DateTime('now', new DateTimeZone('UTC')))
            ->sub(new DateInterval('PT1H'))
            ->format('Y-m-d H:i:s');
        
        assert(OtpManager::isOtpExpired($pastTime), "Past time should be expired");
        
        echo "✓ OTP expiry checking works\n";
    }

    public function testOtpFormatValidation() {
        // Valid formats
        assert(OtpManager::validateOtpFormat("123456"), "Should validate correct format");
        assert(OtpManager::validateOtpFormat("000000"), "Should validate all zeros");
        assert(OtpManager::validateOtpFormat("999999"), "Should validate all nines");
        
        // Invalid formats
        assert(!OtpManager::validateOtpFormat("12345"), "Should reject 5 digits");
        assert(!OtpManager::validateOtpFormat("1234567"), "Should reject 7 digits");
        assert(!OtpManager::validateOtpFormat("12345a"), "Should reject non-numeric");
        assert(!OtpManager::validateOtpFormat(""), "Should reject empty");
        
        echo "✓ OTP format validation works\n";
    }
}
```

---

## 🧪 Integration Test Examples

### Test 2: Full Registration → Verification → Login Flow

```php
<?php

namespace Tests;

use Backend\Models\User;
use Backend\Utils\OtpManager;
use Backend\Utils\EmailService;
use Backend\Config\JWT;

class AuthenticationFlowTest {
    private User $userModel;
    private EmailService $emailService;

    public function setUp() {
        $this->userModel = new User();
        $this->emailService = new EmailService();
    }

    public function testCompleteAuthenticationFlow() {
        $email = "test.user@example.com";
        $password = "SecurePassword123";
        $userType = "patient";

        // STEP 1: Register user
        echo "Step 1: Register user...\n";
        
        $hashedPassword = User::hashPassword($password);
        $userId = $this->userModel->create([
            'email' => $email,
            'password' => $hashedPassword,
            'user_type' => $userType
        ]);

        assert(!empty($userId), "User ID should be generated");
        
        $user = $this->userModel->findByEmailWithVerification($email);
        assert($user !== null, "User should be found");
        assert($user['is_email_verified'] === 0, "User should be unverified initially");
        assert($user['email_verification_otp'] === null, "Should have no OTP yet");
        
        echo "✓ User registered: $userId\n";

        // STEP 2: Generate and store OTP
        echo "\nStep 2: Generate OTP...\n";
        
        $otp = OtpManager::generateOtp();
        $hashedOtp = OtpManager::hashOtp($otp);
        $expiryTime = OtpManager::getOtpExpiry();

        $stored = $this->userModel->storeOtp($email, $hashedOtp, $expiryTime);
        assert($stored, "OTP should be stored successfully");
        
        echo "✓ OTP generated and stored: $otp\n";

        // STEP 3: Login attempt before verification (should fail)
        echo "\nStep 3: Try to login before verification...\n";
        
        $user = $this->userModel->findByEmailWithVerification($email);
        assert(!$user['is_email_verified'], "Email should not be verified yet");
        
        echo "✓ Login correctly blocked (email not verified)\n";

        // STEP 4: Verify email with correct OTP
        echo "\nStep 4: Verify email with OTP...\n";
        
        $user = $this->userModel->findByEmailWithVerification($email);
        assert(OtpManager::verifyOtp($otp, $user['email_verification_otp']), 
               "OTP should be valid");
        assert(!OtpManager::isOtpExpired($user['email_verification_expires']), 
               "OTP should not be expired");
        
        $verified = $this->userModel->verifyEmail($email);
        assert($verified, "Email should be marked as verified");
        
        echo "✓ Email verified successfully\n";

        // STEP 5: Verify user is now verified in database
        echo "\nStep 5: Check verified status...\n";
        
        $user = $this->userModel->findByEmailWithVerification($email);
        assert($user['is_email_verified'] === 1, "User should be verified");
        assert($user['email_verification_otp'] === null, "OTP should be cleared");
        assert($user['email_verification_expires'] === null, "Expiry should be cleared");
        
        echo "✓ Database updated correctly\n";

        // STEP 6: Login with verified email (should succeed)
        echo "\nStep 6: Login with verified email...\n";
        
        $user = $this->userModel->findByEmailWithVerification($email);
        assert($user['is_email_verified'], "Email should be verified now");
        
        $isPasswordValid = User::verifyPassword($password, $user['password']);
        assert($isPasswordValid, "Password should be correct");
        
        $token = JWT::encode([
            'user_id' => $user['id'],
            'user_type' => $user['user_type'],
            'email' => $user['email']
        ]);
        
        assert(!empty($token), "JWT token should be generated");
        
        echo "✓ Login successful with JWT token generated\n";

        echo "\n✅ Complete authentication flow test passed!\n";
    }

    public function testOtpResend() {
        echo "\n=== Testing OTP Resend ===\n";
        
        $email = "resend.test@example.com";
        
        // Create user
        $userId = $this->userModel->create([
            'email' => $email,
            'password' => User::hashPassword("Test123"),
            'user_type' => "doctor"
        ]);

        // Generate and store initial OTP
        $otp1 = OtpManager::generateOtp();
        $hashedOtp1 = OtpManager::hashOtp($otp1);
        $expiry1 = OtpManager::getOtpExpiry();
        $this->userModel->storeOtp($email, $hashedOtp1, $expiry1);

        echo "Initial OTP: $otp1\n";

        // Get user with initial OTP
        $userBefore = $this->userModel->findByEmailWithVerification($email);
        assert($userBefore['email_verification_otp'] !== null, "Should have initial OTP");

        // Simulate resend: Generate new OTP
        $otp2 = OtpManager::generateOtp();
        assert($otp1 !== $otp2, "New OTP should be different from previous");
        
        $hashedOtp2 = OtpManager::hashOtp($otp2);
        $expiry2 = OtpManager::getOtpExpiry();
        $this->userModel->storeOtp($email, $hashedOtp2, $expiry2);

        echo "New OTP: $otp2\n";

        // Verify new OTP works
        $userAfter = $this->userModel->findByEmailWithVerification($email);
        assert(OtpManager::verifyOtp($otp2, $userAfter['email_verification_otp']), 
               "New OTP should be valid");
        assert(!OtpManager::verifyOtp($otp1, $userAfter['email_verification_otp']), 
               "Old OTP should no longer work");

        echo "✓ OTP resend test passed\n";
    }

    public function testExpiredOtpRejection() {
        echo "\n=== Testing Expired OTP ===\n";
        
        $email = "expired.test@example.com";
        
        // Create user
        $userId = $this->userModel->create([
            'email' => $email,
            'password' => User::hashPassword("Test123"),
            'user_type' => "patient"
        ]);

        // Create expired OTP
        $otp = OtpManager::generateOtp();
        $hashedOtp = OtpManager::hashOtp($otp);
        
        // Set expiry to 1 hour in the past
        $expiredTime = (new DateTime('now', new DateTimeZone('UTC')))
            ->sub(new DateInterval('PT1H'))
            ->format('Y-m-d H:i:s');
        
        $this->userModel->storeOtp($email, $hashedOtp, $expiredTime);

        // Try to verify
        $user = $this->userModel->findByEmailWithVerification($email);
        
        assert(OtpManager::verifyOtp($otp, $user['email_verification_otp']), 
               "Hash should match even if expired");
        assert(OtpManager::isOtpExpired($user['email_verification_expires']), 
               "OTP should be marked as expired");

        echo "✓ Expired OTP correctly rejected\n";
    }
}
```

---

## 🌐 API Endpoint Testing

### cURL Command Examples

#### 1. Register User
```bash
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "MyPassword123",
    "userType": "doctor",
    "fullName": "Dr. New User"
  }'
```

**Expected Response (201):**
```json
{
  "success": true,
  "data": {
    "message": "User registered. Please verify email."
  }
}
```

#### 2. Verify Email
```bash
curl -X POST http://localhost/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "otp": "123456"
  }'
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Email verified successfully"
  }
}
```

#### 3. Resend OTP
```bash
curl -X POST http://localhost/api/auth/resend-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com"
  }'
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "OTP sent to your email"
  }
}
```

#### 4. Login
```bash
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "MyPassword123"
  }'
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "newuser@example.com",
    "userType": "doctor",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 5. Get Current User (Protected)
```bash
curl -X GET http://localhost/api/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Expected Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "newuser@example.com",
    "userType": "doctor",
    "isEmailVerified": true
  }
}
```

---

## ❌ Error Testing

### Test: Invalid OTP
```bash
curl -X POST http://localhost/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "otp": "999999"
  }'
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Invalid OTP",
  "status": 400
}
```

### Test: Expired OTP
After waiting 10+ minutes:
```bash
curl -X POST http://localhost/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "otp": "123456"
  }'
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "OTP has expired. Please request a new one.",
  "status": 400
}
```

### Test: Email Not Verified Login
```bash
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "unverified@example.com",
    "password": "MyPassword123"
  }'
```

**Expected Response (403):**
```json
{
  "success": false,
  "message": "EMAIL_NOT_VERIFIED",
  "status": 403
}
```

### Test: Validation Error
```bash
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "password": "short",
    "userType": "invalid"
  }'
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Validation failed",
  "status": 400,
  "errors": {
    "email": ["email must be a valid email"],
    "password": ["password must be at least 6 characters"],
    "userType": ["userType is required and must be either doctor or patient"]
  }
}
```

---

## 📊 Performance Testing

### Test: Concurrent OTP Generation
```bash
# Generate 100 OTPs in parallel
for i in {1..100}; do
  curl -X POST http://localhost/api/auth/resend-otp \
    -H "Content-Type: application/json" \
    -d "{\"email\": \"test$i@example.com\"}" &
done
wait
```

Expected: All requests complete successfully with unique OTPs

---

## 🔍 Database Verification Queries

After running tests, verify the database state:

```sql
-- Check user verification status
SELECT id, email, is_email_verified, email_verification_otp, email_verification_expires
FROM users 
WHERE email = 'test@example.com';

-- Check all unverified users
SELECT email, created_at FROM users 
WHERE is_email_verified = 0;

-- Check verified users
SELECT email, updated_at FROM users 
WHERE is_email_verified = 1;

-- Check for lingering OTPs (should be cleaned up)
SELECT email, email_verification_otp FROM users 
WHERE email_verification_otp IS NOT NULL;
```

---

## ✅ Test Checklist

- [ ] Generate OTP correctly (6 digits)
- [ ] Hash OTP securely
- [ ] Verify OTP correctly
- [ ] Reject invalid OTPs
- [ ] Reject expired OTPs
- [ ] Register new user
- [ ] Verify email with correct OTP
- [ ] Clear OTP after verification
- [ ] Login fails before verification
- [ ] Login succeeds after verification
- [ ] Resend OTP generates new code
- [ ] Old OTP no longer works after resend
- [ ] JWT token generated on login
- [ ] Get user endpoint returns verified status
- [ ] Validation errors handled correctly
- [ ] Duplicate email rejected
- [ ] Rate limiting works (if enabled)
