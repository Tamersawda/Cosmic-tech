# Email Verification Implementation - Deployment Checklist

## ✅ Pre-Deployment

### Code Review
- [ ] All new files created:
  - [ ] `utils/EmailService.php`
  - [ ] `utils/OtpManager.php`
  - [ ] `db/migration_email_verification.sql`
  - [ ] `AUTHENTICATION_GUIDE.md`
  - [ ] `AUTHENTICATION_TESTING.md`
  - [ ] `API_QUICK_REFERENCE.md`

- [ ] All files updated:
  - [ ] `db/schema.sql` - User table updated
  - [ ] `models/User.php` - Verification methods added
  - [ ] `controllers/AuthController.php` - New endpoints implemented
  - [ ] `routes/auth.php` - New routes added
  - [ ] `config/JWT.php` - Custom expiry support

### Testing
- [ ] Unit tests pass for OtpManager
- [ ] Unit tests pass for EmailService
- [ ] Integration tests pass for full auth flow
- [ ] cURL manual tests verified
- [ ] Error scenario tests verified
- [ ] Database queries verified

### Code Quality
- [ ] No PHP syntax errors
- [ ] No undefined variables
- [ ] All imports present
- [ ] Consistent code style
- [ ] Comments and docstrings present
- [ ] Error logging implemented

---

## 📦 Deployment Steps

### Step 1: Backup Database
```bash
# Create full database backup
mysqldump -u root -p therapy_booking_db > therapy_booking_db_backup_$(date +%Y%m%d_%H%M%S).sql

# Verify backup
ls -lh therapy_booking_db_backup_*.sql
```

### Step 2: Update Database Schema
```bash
# Run migration script
mysql -u root -p therapy_booking_db < backend/db/migration_email_verification.sql

# Verify columns added
mysql -u root -p therapy_booking_db -e "DESCRIBE users;"
```

**Verify output includes:**
- `is_email_verified` - tinyint(1) NOT NULL DEFAULT 0
- `email_verification_otp` - varchar(255) NULL
- `email_verification_expires` - datetime NULL

### Step 3: Deploy Code
```bash
# Copy new files to production
cp backend/utils/EmailService.php /production/backend/utils/
cp backend/utils/OtpManager.php /production/backend/utils/

# Update existing files
cp backend/models/User.php /production/backend/models/
cp backend/controllers/AuthController.php /production/backend/controllers/
cp backend/routes/auth.php /production/backend/routes/
cp backend/config/JWT.php /production/backend/config/
cp backend/db/schema.sql /production/backend/db/
```

### Step 4: Configure Environment Variables
```bash
# Edit .env file
cat >> .env << EOF

# Email Configuration
MAIL_DRIVER=php
MAIL_FROM=noreply@therapeuticsanctuary.com
MAIL_FROM_NAME=Therapy Sanctuary

# If using SMTP (optional)
# SMTP_HOST=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USERNAME=your-email@gmail.com
# SMTP_PASSWORD=your-app-password
EOF

# Verify
grep MAIL_ .env
```

### Step 5: Clear Cache (if applicable)
```bash
# Clear PHP opcode cache
sudo service php-fpm reload

# Or for Apache
sudo service apache2 reload
```

### Step 6: Test Endpoints
```bash
# Test register
curl -X POST http://production-url/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123",
    "userType": "doctor",
    "fullName": "Test Doctor"
  }'

# Test verify (use OTP from email)
curl -X POST http://production-url/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "otp": "123456"
  }'

# Test login
curl -X POST http://production-url/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123"
  }'

# Test protected endpoint
curl -X GET http://production-url/api/me \
  -H "Authorization: Bearer <token-from-login>"
```

---

## 🔧 Configuration Options

### Email Driver Setup

#### Option 1: PHP Mail (Default)
```env
MAIL_DRIVER=php
MAIL_FROM=noreply@therapeuticsanctuary.com
MAIL_FROM_NAME=Therapy Sanctuary
```

#### Option 2: SMTP
```env
MAIL_DRIVER=smtp
MAIL_FROM=noreply@therapeuticsanctuary.com
MAIL_FROM_NAME=Therapy Sanctuary
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=app-password-from-google
```

#### Option 3: Mailgun (Future)
```env
MAIL_DRIVER=mailgun
MAILGUN_DOMAIN=sandbox.mailgun.org
MAILGUN_SECRET=key-xxx
```

---

## 📊 Monitoring & Logging

### Key Metrics to Track
- [ ] Registration attempts (success/failure)
- [ ] OTP generation count
- [ ] OTP verification success rate
- [ ] Email delivery success rate
- [ ] Login attempts (success/failure)
- [ ] Email verification time (average)

### Log Files to Monitor
```bash
# PHP Error Log
tail -f /var/log/php-fpm/error.log

# Application Log
tail -f /var/log/therapy-booking/application.log

# Search for authentication errors
grep -i "registration error\|login error\|email" /var/log/therapy-booking/application.log
```

### Alerts to Setup
- [ ] Alert on 5+ failed login attempts from same IP
- [ ] Alert on email sending failures
- [ ] Alert on database connection errors
- [ ] Alert on OTP generation failures

---

## 🔄 Rollback Plan

If issues occur after deployment:

### Option 1: Rollback Code Only
```bash
# Restore previous version of files from backup
git revert <commit-hash>
# or
cp /backups/models/User.php backend/models/User.php
cp /backups/controllers/AuthController.php backend/controllers/AuthController.php
# ... restore other files
sudo service apache2 reload
```

### Option 2: Rollback Database
```bash
# Restore from backup (only if data integrity issue)
# CAUTION: This will lose all new registrations since deployment

mysql -u root -p therapy_booking_db < therapy_booking_db_backup_YYYYMMDD_HHMMSS.sql

# Verify
mysql -u root -p therapy_booking_db -e "DESCRIBE users;"
```

### Option 3: Disable New Feature Temporarily
```php
// In AuthController.php, temporarily redirect to old flow
public function register(): void {
    // Temporarily show maintenance message
    Response::error('Registration temporarily disabled for maintenance', 503);
}
```

---

## 📋 Post-Deployment Verification

### Immediate (Within 1 hour)
- [ ] No PHP errors in logs
- [ ] Database connection working
- [ ] Email sending working (test email)
- [ ] Registration endpoint accessible
- [ ] Login endpoint accessible
- [ ] GET /api/me endpoint accessible
- [ ] No database integrity issues

### Short-term (Next 24 hours)
- [ ] Monitor registration volume
- [ ] Monitor failed login attempts
- [ ] Check email delivery rate
- [ ] Monitor database performance
- [ ] Check email queue (if any)
- [ ] Verify no unverified users stuck in system

### Long-term (1 week)
- [ ] Review authentication success rate
- [ ] Review OTP expiry patterns
- [ ] Check for users abandoning verification
- [ ] Analyze email template effectiveness
- [ ] Performance optimization if needed

---

## 📞 Support Contact Info

### During Deployment
Keep these contacts available:
- Database Administrator: _________________
- DevOps Engineer: _________________
- Email Service Provider: _________________
- Security Lead: _________________

### Issue Escalation
1. Check logs first: `grep -i error /var/log/php*`
2. Verify database: `DESCRIBE users;`
3. Test endpoint manually: `curl http://localhost/api/auth/register`
4. Contact Database Administrator if schema issue
5. Contact DevOps Engineer for environment issues

---

## 🧪 UAT (User Acceptance Testing)

### Test Scenarios
1. **Happy Path**
   - [ ] Register new user
   - [ ] Receive OTP email
   - [ ] Enter OTP correctly
   - [ ] Email verified
   - [ ] Login successful

2. **Invalid OTP**
   - [ ] Register user
   - [ ] Enter wrong OTP
   - [ ] Get error message
   - [ ] Can retry

3. **Expired OTP**
   - [ ] Register user
   - [ ] Wait 10+ minutes
   - [ ] Try to verify
   - [ ] Get expiry error
   - [ ] Resend OTP

4. **Before Verification**
   - [ ] Register user
   - [ ] Try to login
   - [ ] Get EMAIL_NOT_VERIFIED error
   - [ ] Cannot access protected endpoints

5. **Resend OTP**
   - [ ] Register user
   - [ ] Resend OTP
   - [ ] New OTP works
   - [ ] Old OTP doesn't work

### Test Users
Create test accounts:
- `doctor1@test.com` (Doctor)
- `patient1@test.com` (Patient)
- `admin@test.com` (For testing)

---

## 📈 Performance Baseline

Capture these before and after deployment:

```sql
-- Query performance before any optimization
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';
EXPLAIN SELECT * FROM users WHERE is_email_verified = 1;

-- Check table size
SELECT 
    TABLE_NAME,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'therapy_booking_db' AND TABLE_NAME = 'users';
```

---

## 🔐 Security Post-Deployment

- [ ] HTTPS enabled for all endpoints
- [ ] JWT_SECRET strong and unique
- [ ] No sensitive data in logs
- [ ] Database user has limited privileges
- [ ] Email credentials stored securely
- [ ] CORS headers configured
- [ ] Rate limiting enabled (if needed)

---

## ✨ Sign-off

**Deployment Date:** _______________

**Deployed By:** _______________

**Verified By:** _______________

**Sign-off:** _______________

---

## 📚 Documentation Links

- Full Guide: `AUTHENTICATION_GUIDE.md`
- API Reference: `API_QUICK_REFERENCE.md`
- Testing Guide: `AUTHENTICATION_TESTING.md`
- Migration Script: `db/migration_email_verification.sql`
