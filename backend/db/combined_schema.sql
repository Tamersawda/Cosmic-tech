-- ============================================================
-- Clinical Sanctuary - Online Therapy Booking Platform
-- Database Schema (MySQL)
-- Version: 2.1 MVP — COMBINED, CORRECTED & API-ALIGNED
--
-- This is the single source of truth.  Every table name,
-- column name, and data-type matches the PHP model queries
-- exactly (snake_case, CHAR(36) UUIDs, enum values, etc.)
--
-- Sources reconciled:
--   schema.sql               (original base, merge-conflict resolved)
--   schema_fix.sql           (VARCHAR(191) email fix, enum fix)
--   migration_role_alignment.sql  (full_name, user_type 'user' enum)
--   models/User.php          (users, doctor_profiles, patient_profiles)
--   models/DoctorProfile.php (doctor_profiles, doctor_qualifications)
--   models/PatientProfile.php (patient_profiles)
--   models/Appointment.php   (appointments)
--   models/Message.php       (messages)
-- ============================================================

CREATE DATABASE IF NOT EXISTS therapy_booking
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE therapy_booking;

SET FOREIGN_KEY_CHECKS = 0;
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';


-- ============================================================
-- DROP TABLES IN SAFE ORDER (most-dependent first)
-- ============================================================
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS documents;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS consultation_sessions;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS available_slots;
DROP TABLE IF EXISTS doctor_weekly_schedule;
DROP TABLE IF EXISTS doctor_experiences;
DROP TABLE IF EXISTS doctor_qualifications;
DROP TABLE IF EXISTS doctor_profiles;
DROP TABLE IF EXISTS client_profiles;
DROP TABLE IF EXISTS users;


-- ============================================================
-- 1. USERS TABLE
-- PHP references: id, email, password, user_type, full_name,
--                 is_active, is_email_verified,
--                 email_verification_otp, email_verification_expires,
--                 created_at, updated_at
-- Notes:
--   • id is CHAR(36) — PHP generates UUID strings (generateUUID())
--   • email VARCHAR(191) — safe for utf8mb4 unique index
--   • user_type ENUM includes 'user' (role alignment applied)
--   • full_name stored here (migration_role_alignment.sql intent)
--   • is_email_verified, otp fields reserved for future OTP flow
-- ============================================================
CREATE TABLE users (
    id                          CHAR(36)        NOT NULL DEFAULT (UUID()),
    email                       VARCHAR(191)    NOT NULL,
    password                    VARCHAR(255)    NOT NULL,
    full_name                   VARCHAR(255)    NOT NULL DEFAULT '',
    user_type                   ENUM('admin', 'doctor', 'client') NOT NULL,
    is_active                   TINYINT(1)      NOT NULL DEFAULT 1,
    is_profile_complete         BOOLEAN         DEFAULT FALSE,
    is_profile_approved         BOOLEAN         DEFAULT FALSE,
    onboarding_step             INT             DEFAULT 0,

    -- Reserved for future OTP email-verification flow (not active in MVP)
    is_email_verified           TINYINT(1)      NOT NULL DEFAULT 1,
    email_verification_otp      VARCHAR(255)    NULL,
    email_verification_expires  DATETIME        NULL,

    created_at                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email    (email),
    INDEX idx_users_email        (email),
    INDEX idx_users_user_type    (user_type),
    INDEX idx_users_active       (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 2. DOCTOR PROFILES TABLE
-- PHP references: user_id, full_name, gender, date_of_birth,
--   phone_number, profile_photo, primary_specialty,
--   sub_specializations, years_of_experience, license_number,
--   medical_council, languages_spoken, video_enabled,
--   video_rate, audio_enabled, audio_rate, follow_up_rate,
--   consultation_duration, buffer_time, instant_booking_enabled,
--   street_address, city, state, country, postal_code,
--   latitude, longitude, is_verified, verification_status,
--   trust_badge_earned, onboarding_current_step,
--   onboarding_completed_steps, onboarding_percentage,
--   created_at, updated_at
-- ============================================================
CREATE TABLE doctor_profiles (
    user_id                     CHAR(36)        NOT NULL,

    full_name                   VARCHAR(255)    NOT NULL DEFAULT '',
    gender                      ENUM('male', 'female', 'other', 'prefer_not_to_say') NOT NULL DEFAULT 'other',
    date_of_birth               DATE            NULL,
    phone_number                VARCHAR(30)     NULL,
    profile_photo_url           VARCHAR(255)    NULL,
    is_active                   TINYINT(1)      NOT NULL DEFAULT 1,

    primary_specialty           VARCHAR(150)    NOT NULL DEFAULT '',
    sub_specializations         JSON            NULL,
    therapy_types               JSON            NULL,
    years_of_experience         SMALLINT        NOT NULL DEFAULT 0,
    license_number              VARCHAR(100)    NOT NULL DEFAULT '',
    medical_council             VARCHAR(100)    NOT NULL DEFAULT '',
    languages_spoken            JSON            NOT NULL,

    video_enabled               TINYINT(1)      NOT NULL DEFAULT 1,
    video_rate                  DECIMAL(10,2)   NULL,
    audio_enabled               TINYINT(1)      NOT NULL DEFAULT 1,
    audio_rate                  DECIMAL(10,2)   NULL,
    follow_up_rate              DECIMAL(10,2)   NULL,
    consultation_duration       ENUM('30min', '45min', '60min') NOT NULL DEFAULT '60min',
    buffer_time                 ENUM('5min', '10min', '15min', '30min') NOT NULL DEFAULT '10min',
    instant_booking_enabled     TINYINT(1)      NOT NULL DEFAULT 0,

    street_address              VARCHAR(255)    NULL,
    city                        VARCHAR(100)    NULL,
    state                       VARCHAR(100)    NULL,
    country                     VARCHAR(100)    NULL,
    postal_code                 VARCHAR(20)     NULL,
    latitude                    DECIMAL(10,7)   NULL,
    longitude                   DECIMAL(10,7)   NULL,

    is_verified                 TINYINT(1)      NOT NULL DEFAULT 0,
    is_profile_approved         BOOLEAN         NOT NULL DEFAULT FALSE,
    verification_status         ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    trust_badge_earned          TINYINT(1)      NOT NULL DEFAULT 0,

    onboarding_current_step     TINYINT         NOT NULL DEFAULT 1,
    onboarding_completed_steps  JSON            NULL,
    onboarding_percentage       TINYINT         NOT NULL DEFAULT 0,

    created_at                  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    UNIQUE KEY uq_doctor_license    (license_number),
    INDEX idx_doctor_specialty      (primary_specialty),
    INDEX idx_doctor_experience     (years_of_experience),
    INDEX idx_doctor_verified       (is_verified),
    INDEX idx_doctor_city           (city),
    INDEX idx_doctor_active         (is_active),

    CONSTRAINT fk_doctor_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 3. CLIENT PROFILES TABLE
-- PHP references: user_id, full_name, gender, date_of_birth,
--   phone_number, allergies, current_medications,
--   emergency_contact_name/relationship/phone, created_at, updated_at
-- Note: Renamed from patient_profiles. Matches ClientProfile.php
-- ============================================================
CREATE TABLE client_profiles (
    user_id                         CHAR(36)        NOT NULL,

    full_name                       VARCHAR(200)    NOT NULL DEFAULT '',
    gender                          ENUM('male', 'female', 'other') NOT NULL DEFAULT 'other',
    date_of_birth                   DATE            NULL,
    phone_number                    VARCHAR(30)     NULL,
    profile_photo                   VARCHAR(500)    NULL,

    -- Medical (optional)
    allergies                       JSON            NULL,
    current_medications             JSON            NULL,

    -- Emergency contact
    emergency_contact_name          VARCHAR(150)    NULL,
    emergency_contact_relationship  VARCHAR(100)    NULL,
    emergency_contact_phone         VARCHAR(30)     NULL,

    created_at                      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    INDEX idx_client_phone (phone_number),

    CONSTRAINT fk_client_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 4. DOCTOR QUALIFICATIONS TABLE
-- ============================================================
CREATE TABLE doctor_qualifications (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id           CHAR(36)        NOT NULL,
    title               VARCHAR(255)    NOT NULL,
    degree              VARCHAR(255)    NULL,
    institution         VARCHAR(255)    NULL,
    year                SMALLINT        NULL,
    document_path       VARCHAR(1024)   NULL,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    INDEX idx_qual_doctor (doctor_id),

    CONSTRAINT fk_qual_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 4b. DOCTOR EXPERIENCES TABLE
-- ============================================================
CREATE TABLE doctor_experiences (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id           CHAR(36)        NOT NULL,
    company             VARCHAR(255)    NOT NULL,
    role_title          VARCHAR(255)    NOT NULL,
    employment_type     ENUM('full_time','part_time','contract','freelance','internship','other')
                        NOT NULL DEFAULT 'full_time',
    currently_working   TINYINT(1)      NOT NULL DEFAULT 0,
    start_date          DATE            NOT NULL,
    end_date            DATE            NULL,
    description         TEXT            NULL,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    INDEX idx_exp_doctor (doctor_id),

    CONSTRAINT fk_exp_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 5. DOCTOR WEEKLY SCHEDULE TABLE
-- ============================================================
CREATE TABLE doctor_weekly_schedule (
    id              CHAR(36)    NOT NULL DEFAULT (UUID()),
    doctor_id       CHAR(36)    NOT NULL,
    day_of_week     TINYINT     NOT NULL,   -- 0 = Sunday … 6 = Saturday
    is_available    TINYINT(1)  NOT NULL DEFAULT 0,
    start_time      TIME        NULL,
    end_time        TIME        NULL,
    break_times     JSON        NULL,       -- [{"start":"13:00","end":"14:00"}]

    PRIMARY KEY (id),
    UNIQUE KEY uq_schedule_doctor_day (doctor_id, day_of_week),

    CONSTRAINT fk_schedule_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT chk_day_of_week CHECK (day_of_week BETWEEN 0 AND 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 6. APPOINTMENTS TABLE
-- PHP references: id, doctor_id, client_id, scheduled_date,
--   scheduled_time, end_time, consultation_type, status,
--   notes, created_at, updated_at
-- ============================================================
CREATE TABLE appointments (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id           CHAR(36)        NOT NULL,
    client_id           CHAR(36)        NOT NULL,

    scheduled_date      DATE            NOT NULL,
    scheduled_time      TIME            NOT NULL,
    end_time            TIME            NOT NULL,

    consultation_type   ENUM('video', 'audio', 'chat') NOT NULL DEFAULT 'video',
    status              ENUM('scheduled', 'in_progress', 'completed',
                             'cancelled', 'no_show', 'rescheduled')
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
    UNIQUE KEY uq_appointment_slot      (doctor_id, scheduled_date, scheduled_time),
    INDEX idx_appt_doctor_date          (doctor_id, scheduled_date),
    INDEX idx_appt_client_date          (client_id, scheduled_date),
    INDEX idx_appt_status               (status),

    CONSTRAINT fk_appt_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_appt_client
        FOREIGN KEY (client_id) REFERENCES client_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 7. CONSULTATION SESSIONS TABLE
-- ============================================================
CREATE TABLE consultation_sessions (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    appointment_id      CHAR(36)        NOT NULL,
    started_at          DATETIME        NULL,
    ended_at            DATETIME        NULL,
    duration_minutes    SMALLINT        NULL,
    notes               TEXT            NULL,
    prescriptions       JSON            NULL,
    follow_up_required  TINYINT(1)      NOT NULL DEFAULT 0,
    next_follow_up_date DATE            NULL,

    PRIMARY KEY (id),
    UNIQUE KEY uq_session_appointment (appointment_id),

    CONSTRAINT fk_session_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 8. MESSAGES TABLE
-- PHP references: id, appointment_id, sender_id, content,
--   message_type, is_read, created_at, updated_at
-- Note: Message.php also uses recipient_id, subject in its
--   standalone create() / getInbox() / getSent() methods.
--   These columns are added here so that code path doesn't fail.
-- ============================================================
CREATE TABLE messages (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    appointment_id  CHAR(36)        NULL,       -- NULL for standalone messages
    sender_id       CHAR(36)        NOT NULL,
    recipient_id    CHAR(36)        NULL,       -- used by standalone messaging
    content         TEXT            NOT NULL,
    message_type    ENUM('text', 'image', 'document') NOT NULL DEFAULT 'text',
    subject         VARCHAR(255)    NULL,       -- used by standalone messaging
    attachment_url  VARCHAR(500)    NULL,
    is_read         TINYINT(1)      NOT NULL DEFAULT 0,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    INDEX idx_msg_appointment_time  (appointment_id, created_at),
    INDEX idx_msg_recipient         (recipient_id),

    CONSTRAINT fk_msg_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_msg_sender
        FOREIGN KEY (sender_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_msg_recipient
        FOREIGN KEY (recipient_id) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 9. REVIEWS TABLE
-- ============================================================
CREATE TABLE reviews (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    doctor_id       CHAR(36)        NOT NULL,
    client_id       CHAR(36)        NOT NULL,
    appointment_id  CHAR(36)        NULL,
    rating          TINYINT         NOT NULL,
    title           VARCHAR(200)    NULL,
    comment         TEXT            NULL,
    is_verified     TINYINT(1)      NOT NULL DEFAULT 0,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_review_client_appointment (client_id, appointment_id),
    INDEX idx_review_doctor (doctor_id),

    CONSTRAINT fk_review_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_review_client
        FOREIGN KEY (client_id) REFERENCES client_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_review_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 10. DOCUMENTS TABLE
-- ============================================================
CREATE TABLE documents (
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
CREATE TABLE notifications (
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
    is_read     TINYINT(1)      NOT NULL DEFAULT 0,
    related_id  CHAR(36)        NULL,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    INDEX idx_notif_user_read   (user_id, is_read),
    INDEX idx_notif_created     (created_at),

    CONSTRAINT fk_notif_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 12. REFRESH TOKENS TABLE
-- ============================================================
CREATE TABLE refresh_tokens (
    id          CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id     CHAR(36)        NOT NULL,
    token       VARCHAR(512)    NOT NULL,
    expires_at  DATETIME        NOT NULL,
    revoked     TINYINT(1)      NOT NULL DEFAULT 0,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_token     (token(255)),
    INDEX idx_rt_user       (user_id),

    CONSTRAINT fk_rt_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 5: Create available_slots
CREATE TABLE IF NOT EXISTS available_slots (
    id               CHAR(36)   NOT NULL DEFAULT (UUID()),
    doctor_id        CHAR(36)   NOT NULL,
    slot_date        DATE       NOT NULL,
    slot_time        TIME       NOT NULL,
    end_time         TIME       NOT NULL,
    duration_minutes SMALLINT   NOT NULL DEFAULT 60,
    is_available     TINYINT(1) NOT NULL DEFAULT 1,
    created_at       DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_slot (doctor_id, slot_date, slot_time),
    INDEX idx_slot_doctor_date (doctor_id, slot_date),
    CONSTRAINT fk_slot_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- END OF SCHEMA v2.1
-- ============================================================
