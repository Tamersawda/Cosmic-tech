-- ============================================================
-- THERAPY BOOKING SYSTEM - FINAL COMPLETE DATABASE SCHEMA
-- ============================================================

CREATE DATABASE IF NOT EXISTS therapy_booking_db 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE therapy_booking_db;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL DEFAULT '',
    user_type ENUM('admin','doctor','patient') NOT NULL,

    is_active BOOLEAN DEFAULT TRUE,

    is_email_verified TINYINT(1) DEFAULT 0,
    email_verification_otp VARCHAR(255),
    email_verification_expires DATETIME,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 2. DOCTOR PROFILES
-- ============================================================
CREATE TABLE doctor_profiles (
    user_id CHAR(36) PRIMARY KEY,

    full_name VARCHAR(255) NOT NULL,
    gender ENUM('male','female','other','prefer_not_to_say') NOT NULL,
    date_of_birth DATE,
    phone_number VARCHAR(30),
    profile_photo VARCHAR(500),

    primary_specialty VARCHAR(150) NOT NULL,
    sub_specializations JSON,
    years_of_experience SMALLINT DEFAULT 0,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    medical_council VARCHAR(100) NOT NULL,
    languages_spoken JSON NOT NULL,

    video_enabled BOOLEAN DEFAULT TRUE,
    video_rate DECIMAL(10,2),
    audio_enabled BOOLEAN DEFAULT TRUE,
    audio_rate DECIMAL(10,2),
    follow_up_rate DECIMAL(10,2),

    consultation_duration ENUM('30min','45min','60min') DEFAULT '60min',
    buffer_time ENUM('5min','10min','15min','30min') DEFAULT '10min',
    instant_booking_enabled BOOLEAN DEFAULT FALSE,

    street_address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),

    is_verified BOOLEAN DEFAULT FALSE,
    verification_status ENUM('pending','approved','rejected') DEFAULT 'pending',
    trust_badge_earned BOOLEAN DEFAULT FALSE,

    onboarding_current_step TINYINT DEFAULT 1,
    onboarding_completed_steps JSON,
    onboarding_percentage TINYINT DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 3. DOCTOR QUALIFICATIONS
-- ============================================================
CREATE TABLE doctor_qualifications (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    doctor_id CHAR(36) NOT NULL,
    institute_name VARCHAR(255) NOT NULL,
    degree VARCHAR(150) NOT NULL,
    specialization VARCHAR(150),
    year_of_completion YEAR NOT NULL,
    certificate_file VARCHAR(500),

    FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 4. DOCTOR WEEKLY SCHEDULE
-- ============================================================
CREATE TABLE doctor_weekly_schedule (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    doctor_id CHAR(36) NOT NULL,
    day_of_week TINYINT NOT NULL,
    is_available BOOLEAN DEFAULT FALSE,
    start_time TIME,
    end_time TIME,
    break_times JSON,

    UNIQUE KEY uq_schedule (doctor_id, day_of_week),

    FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 5. PATIENT PROFILES
-- ============================================================
CREATE TABLE patient_profiles (
    user_id CHAR(36) PRIMARY KEY,

    full_name VARCHAR(200) NOT NULL,
    gender ENUM('male','female','other') NOT NULL,
    date_of_birth DATE,
    phone_number VARCHAR(30),
    profile_photo VARCHAR(500),

    medical_history TEXT,
    allergies JSON,
    current_medications JSON,

    emergency_contact_name VARCHAR(150),
    emergency_contact_relationship VARCHAR(100),
    emergency_contact_phone VARCHAR(30),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 6. APPOINTMENTS
-- ============================================================
CREATE TABLE appointments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    doctor_id CHAR(36) NOT NULL,
    patient_id CHAR(36) NOT NULL,

    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    end_time TIME NOT NULL,

    consultation_type ENUM('video','audio','chat') NOT NULL,
    status ENUM('scheduled','in_progress','completed','cancelled','no_show','rescheduled') DEFAULT 'scheduled',

    reason_for_visit TEXT,
    notes TEXT,
    recording_url VARCHAR(500),

    session_type ENUM('individual','couple') DEFAULT 'individual',
    partner_name VARCHAR(200),
    partner_email VARCHAR(255),

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_slot (doctor_id, scheduled_date, scheduled_time),

    FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id),
    FOREIGN KEY (patient_id) REFERENCES patient_profiles(user_id)
) ENGINE=InnoDB;

-- ============================================================
-- 7. CONSULTATION SESSIONS
-- ============================================================
CREATE TABLE consultation_sessions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    appointment_id CHAR(36) NOT NULL,
    started_at DATETIME,
    ended_at DATETIME,
    duration_minutes SMALLINT,
    notes TEXT,
    prescriptions JSON,
    follow_up_required BOOLEAN DEFAULT FALSE,
    next_follow_up_date DATE,

    UNIQUE KEY uq_session (appointment_id),

    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 8. MESSAGES
-- ============================================================
CREATE TABLE messages (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    appointment_id CHAR(36) NOT NULL,
    sender_id CHAR(36) NOT NULL,

    content TEXT NOT NULL,
    message_type ENUM('text','image','document') DEFAULT 'text',
    attachment_url VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 9. REVIEWS
-- ============================================================
CREATE TABLE reviews (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    doctor_id CHAR(36) NOT NULL,
    patient_id CHAR(36) NOT NULL,
    appointment_id CHAR(36),
    rating TINYINT NOT NULL,
    title VARCHAR(200),
    comment TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_review (patient_id, appointment_id),

    FOREIGN KEY (doctor_id) REFERENCES doctor_profiles(user_id),
    FOREIGN KEY (patient_id) REFERENCES patient_profiles(user_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- 10. DOCUMENTS
-- ============================================================
CREATE TABLE documents (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    document_type ENUM('license','certificate','qualification','identity') NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    verification_status ENUM('pending','verified','rejected') DEFAULT 'pending',

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 11. NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    type ENUM(
        'appointment_scheduled',
        'appointment_reminder',
        'consultation_completed',
        'review_received',
        'profile_updated',
        'verification_update'
    ) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_id CHAR(36),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- 12. REFRESH TOKENS
-- ============================================================
CREATE TABLE refresh_tokens (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    token VARCHAR(512) NOT NULL,
    expires_at DATETIME NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_token (token(255)),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;