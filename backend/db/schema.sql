-- ============================================================
-- Clinical Sanctuary - Online Therapy Booking Platform
-- Database Schema (MySQL)
-- Version: 1.0 MVP
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';

-- ============================================================
-- 1. USERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id                          CHAR(36)        NOT NULL DEFAULT (UUID()),
    email                       VARCHAR(255)    NOT NULL,
    password                    VARCHAR(255)    NOT NULL,          -- bcrypt/argon2 hashed
    user_type                   ENUM('admin', 'doctor', 'patient') NOT NULL,
    is_active                   TINYINT         NOT NULL DEFAULT 1,
    is_email_verified           TINYINT         NOT NULL DEFAULT 0,
    email_verification_otp      VARCHAR(255)    NULL,               -- hashed OTP (6 digits)
    email_verification_expires  DATETIME        NULL,               -- OTP expiry timestamp
    created_at                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email),
    INDEX idx_users_email (email),
    INDEX idx_users_user_type (user_type),
    INDEX idx_users_email_verified (is_email_verified)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 2. DOCTOR PROFILE TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_profiles (
    user_id                 CHAR(36)        NOT NULL,

    -- Personal
    full_name               VARCHAR(255)    NOT NULL,
    gender                  ENUM('male', 'female', 'other', 'prefer_not_to_say') NOT NULL,
    date_of_birth           DATE            NULL,
    phone_number            VARCHAR(30)     NULL,
    profile_photo           VARCHAR(500)    NULL,

    -- Professional
    primary_specialty       VARCHAR(150)    NOT NULL,
    sub_specializations     JSON            NULL,           -- ["Anxiety", "CBT"]
    years_of_experience     SMALLINT        NOT NULL DEFAULT 0,
    license_number          VARCHAR(100)    NOT NULL,
    medical_council         ENUM('AMA', 'GMC', 'MCI', 'RCP', 'Other') NOT NULL DEFAULT 'Other',
    languages_spoken        JSON            NOT NULL,       -- ["English", "Malayalam"]

    -- Consultation settings
    video_enabled           TINYINT         NOT NULL DEFAULT 1,
    video_rate              DECIMAL(10, 2)  NULL,
    audio_enabled           TINYINT         NOT NULL DEFAULT 1,
    audio_rate              DECIMAL(10, 2)  NULL,
    follow_up_rate          DECIMAL(10, 2)  NULL,
    consultation_duration   ENUM('30min', '45min', '60min') NOT NULL DEFAULT '60min',
    buffer_time             ENUM('5min', '10min', '15min', '30min') NOT NULL DEFAULT '10min',
    instant_booking_enabled TINYINT         NOT NULL DEFAULT 0,

    -- Location
    street_address          VARCHAR(255)    NULL,
    city                    VARCHAR(100)    NULL,
    state                   VARCHAR(100)    NULL,
    country                 VARCHAR(100)    NULL,
    postal_code             VARCHAR(20)     NULL,
    latitude                DECIMAL(10, 7)  NULL,
    longitude               DECIMAL(10, 7)  NULL,

    -- Verification
    is_verified             TINYINT         NOT NULL DEFAULT 0,
    verification_status     ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    trust_badge_earned      TINYINT         NOT NULL DEFAULT 0,

    -- Onboarding
    onboarding_current_step     TINYINT     NOT NULL DEFAULT 1,
    onboarding_completed_steps  JSON        NULL,           -- [1, 2, 3]
    onboarding_percentage       TINYINT     NOT NULL DEFAULT 0,

    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    UNIQUE KEY uq_doctor_license (license_number),
    INDEX idx_doctor_specialty (primary_specialty),
    INDEX idx_doctor_experience (years_of_experience),
    INDEX idx_doctor_verified (is_verified),

    CONSTRAINT fk_doctor_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 3. DOCTOR QUALIFICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_qualifications (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id           CHAR(36)        NOT NULL,
    institute_name      VARCHAR(255)    NOT NULL,
    degree              VARCHAR(150)    NOT NULL,
    specialization      VARCHAR(150)    NULL,
    year_of_completion  YEAR            NOT NULL,
    certificate_file    VARCHAR(500)    NULL,

    PRIMARY KEY (id),
    INDEX idx_qual_doctor (doctor_id),

    CONSTRAINT fk_qual_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 4. DOCTOR WEEKLY SCHEDULE TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS doctor_weekly_schedule (
    id              CHAR(36)    NOT NULL DEFAULT (UUID()),
    doctor_id       CHAR(36)    NOT NULL,
    day_of_week     TINYINT     NOT NULL,           -- 0=Sunday ... 6=Saturday
    is_available    TINYINT     NOT NULL DEFAULT 0,
    start_time      TIME        NULL,
    end_time        TIME        NULL,
    break_times     JSON        NULL,               -- [{"start":"13:00","end":"14:00"}]

    PRIMARY KEY (id),
    UNIQUE KEY uq_schedule_doctor_day (doctor_id, day_of_week),

    CONSTRAINT fk_schedule_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT chk_day_of_week CHECK (day_of_week BETWEEN 0 AND 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 5. PATIENT PROFILE TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_profiles (
    user_id                 CHAR(36)        NOT NULL,

    first_name              VARCHAR(100)    NOT NULL,
    last_name               VARCHAR(100)    NOT NULL,
    gender                  ENUM('male', 'female', 'other') NOT NULL,
    date_of_birth           DATE            NULL,
    phone_number            VARCHAR(30)     NULL,
    profile_photo           VARCHAR(500)    NULL,

    -- Medical (optional)
    medical_history         TEXT            NULL,
    allergies               JSON            NULL,           -- ["Penicillin"]
    current_medications     JSON            NULL,           -- ["Sertraline 50mg"]

    -- Emergency contact
    emergency_contact_name          VARCHAR(150)    NULL,
    emergency_contact_relationship  VARCHAR(100)    NULL,
    emergency_contact_phone         VARCHAR(30)     NULL,

    created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    INDEX idx_patient_phone (phone_number),

    CONSTRAINT fk_patient_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 6. APPOINTMENTS TABLE (CRITICAL)
-- ============================================================
CREATE TABLE IF NOT EXISTS appointments (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id           CHAR(36)        NOT NULL,
    patient_id          CHAR(36)        NOT NULL,

    scheduled_date      DATE            NOT NULL,
    scheduled_time      TIME            NOT NULL,
    end_time            TIME            NOT NULL,       -- stored explicitly

    consultation_type   ENUM('video', 'audio', 'chat') NOT NULL,
    status              ENUM('scheduled', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled')
                        NOT NULL DEFAULT 'scheduled',

    reason_for_visit    TEXT            NULL,
    notes               TEXT            NULL,
    recording_url       VARCHAR(500)    NULL,

    session_type        ENUM('individual', 'couple') NOT NULL DEFAULT 'individual',
    partner_name        VARCHAR(200)    NULL,
    partner_email       VARCHAR(255)    NULL,

    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    -- CRITICAL: One appointment per doctor per time slot
    UNIQUE KEY uq_appointment_slot (doctor_id, scheduled_date, scheduled_time),

    INDEX idx_appt_doctor_date (doctor_id, scheduled_date),
    INDEX idx_appt_patient_date (patient_id, scheduled_date),
    INDEX idx_appt_status (status),

    CONSTRAINT fk_appt_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_appt_patient
        FOREIGN KEY (patient_id) REFERENCES patient_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 7. CONSULTATION SESSIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS consultation_sessions (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    appointment_id      CHAR(36)        NOT NULL,
    started_at          DATETIME        NULL,
    ended_at            DATETIME        NULL,
    duration_minutes    SMALLINT        NULL,
    notes               TEXT            NULL,
    prescriptions       JSON            NULL,           -- ["Medication A 10mg"]
    follow_up_required  TINYINT         NOT NULL DEFAULT 0,
    next_follow_up_date DATE            NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_session_appointment (appointment_id),

    CONSTRAINT fk_session_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 8. MESSAGES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS messages (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    appointment_id  CHAR(36)        NOT NULL,
    sender_id       CHAR(36)        NOT NULL,
    content         TEXT            NOT NULL,
    message_type    ENUM('text', 'image', 'document') NOT NULL DEFAULT 'text',
    attachment_url  VARCHAR(500)    NULL,
    is_read         TINYINT         NOT NULL DEFAULT 0,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    INDEX idx_msg_appointment_time (appointment_id, created_at),

    CONSTRAINT fk_msg_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_msg_sender
        FOREIGN KEY (sender_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 9. REVIEWS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id       CHAR(36)        NOT NULL,
    patient_id      CHAR(36)        NOT NULL,
    appointment_id  CHAR(36)        NULL,
    rating          TINYINT         NOT NULL,
    title           VARCHAR(200)    NULL,
    comment         TEXT            NULL,
    is_verified     TINYINT         NOT NULL DEFAULT 0,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_review_patient_appointment (patient_id, appointment_id),
    INDEX idx_review_doctor (doctor_id),

    CONSTRAINT fk_review_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_review_patient
        FOREIGN KEY (patient_id) REFERENCES patient_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_review_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 10. DOCUMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS documents (
    id                  CHAR(36)    NOT NULL DEFAULT (UUID()),
    user_id             CHAR(36)    NOT NULL,
    document_type       ENUM('license', 'certificate', 'qualification', 'identity') NOT NULL,
    file_url            VARCHAR(500) NOT NULL,
    file_name           VARCHAR(255) NOT NULL,
    uploaded_at         DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verification_status ENUM('pending', 'verified', 'rejected') NOT NULL DEFAULT 'pending',

    PRIMARY KEY (id),
    INDEX idx_doc_user (user_id),

    CONSTRAINT fk_doc_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 11. NOTIFICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    id          CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id     CHAR(36)        NOT NULL,
    type        ENUM(
                    'appointment_scheduled',
                    'appointment_reminder',
                    'consultation_completed',
                    'review_received',
                    'profile_updated',
                    'verification_update'
                ) NOT NULL,
    title       VARCHAR(255)    NOT NULL,
    message     TEXT            NOT NULL,
    is_read     TINYINT         NOT NULL DEFAULT 0,
    related_id  CHAR(36)        NULL,               -- FK to appointment, review, etc.
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    INDEX idx_notif_user_read (user_id, is_read),
    INDEX idx_notif_created (created_at),

    CONSTRAINT fk_notif_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 12. REFRESH TOKENS TABLE (JWT invalidation support)
-- ============================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id     CHAR(36)        NOT NULL,
    token       VARCHAR(512)    NOT NULL,
    expires_at  DATETIME        NOT NULL,
    revoked     TINYINT         NOT NULL DEFAULT 0,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_token (token(255)),
    INDEX idx_rt_user (user_id),

    CONSTRAINT fk_rt_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
-- VALIDATION TEST DATA
-- Run these to verify schema integrity
-- ============================================================

-- Test 1: Insert a user (patient)
INSERT INTO users (id, email, password, user_type)
VALUES ('aaaaaaaa-0001-0001-0001-000000000001',
        'patient@test.com',
        '$2b$12$hashedpasswordhere',
        'patient');

-- Test 2: Insert a user (doctor)
INSERT INTO users (id, email, password, user_type)
VALUES ('bbbbbbbb-0002-0002-0002-000000000002',
        'doctor@test.com',
        '$2b$12$hashedpasswordhere',
        'doctor');

-- Test 3: Insert doctor profile linked to user
INSERT INTO doctor_profiles
    (user_id, full_name, gender, primary_specialty, license_number,
     languages_spoken, years_of_experience)
VALUES ('bbbbbbbb-0002-0002-0002-000000000002',
        'Dr. Arjun Menon', 'male', 'Clinical Psychology', 'LIC-2024-001',
        '["English", "Malayalam"]', 8);

-- Test 4: Insert patient profile
INSERT INTO patient_profiles (user_id, first_name, last_name, gender)
VALUES ('aaaaaaaa-0001-0001-0001-000000000001', 'Priya', 'Nair', 'female');

-- Test 5: Create an appointment
INSERT INTO appointments
    (id, doctor_id, patient_id, scheduled_date, scheduled_time, end_time,
     consultation_type, status)
VALUES ('cccccccc-0003-0003-0003-000000000003',
        'bbbbbbbb-0002-0002-0002-000000000002',
        'aaaaaaaa-0001-0001-0001-000000000001',
        '2026-04-15', '10:00:00', '11:00:00',
        'video', 'scheduled');

-- Test 6: Attempt DUPLICATE appointment → MUST FAIL (same doctor, date, time)
-- This INSERT should produce: ERROR 1062 (Duplicate entry)
-- INSERT INTO appointments
--     (id, doctor_id, patient_id, scheduled_date, scheduled_time, end_time,
--      consultation_type, status)
-- VALUES (UUID(),
--         'bbbbbbbb-0002-0002-0002-000000000002',
--         'aaaaaaaa-0001-0001-0001-000000000001',
--         '2026-04-15', '10:00:00', '11:00:00',
--         'audio', 'scheduled');

-- Test 7: Delete user → related records CASCADE
-- DELETE FROM users WHERE id = 'bbbbbbbb-0002-0002-0002-000000000002';
-- (doctor_profile, appointments etc. will cascade-delete automatically)

-- Clean up test data (uncomment to run after validation)
-- DELETE FROM users WHERE email IN ('patient@test.com', 'doctor@test.com');