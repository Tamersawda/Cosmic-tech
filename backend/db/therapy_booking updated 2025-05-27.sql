-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 26, 2026 at 07:01 AM
-- Server version: 8.4.7
-- PHP Version: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `therapy_booking`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
CREATE TABLE IF NOT EXISTS `appointments` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_time` time NOT NULL,
  `end_time` time NOT NULL,
  `consultation_type` enum('video','audio','chat') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'video',
  `status` enum('scheduled','in_progress','completed','cancelled','no_show','rescheduled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'scheduled',
  `reason_for_visit` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `recording_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_type` enum('individual','couple') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'individual',
  `partner_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `partner_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_appointment_slot` (`doctor_id`,`scheduled_date`,`scheduled_time`),
  KEY `idx_appt_doctor_date` (`doctor_id`,`scheduled_date`),
  KEY `idx_appt_patient_date` (`client_id`,`scheduled_date`),
  KEY `idx_appt_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `available_slots`
--

DROP TABLE IF EXISTS `available_slots`;
CREATE TABLE IF NOT EXISTS `available_slots` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slot_date` date NOT NULL,
  `slot_time` time NOT NULL,
  `end_time` time NOT NULL,
  `duration_minutes` smallint NOT NULL DEFAULT '60',
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_slot` (`doctor_id`,`slot_date`,`slot_time`),
  KEY `idx_slot_doctor_date` (`doctor_id`,`slot_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `client_profiles`
--

DROP TABLE IF EXISTS `client_profiles`;
CREATE TABLE IF NOT EXISTS `client_profiles` (
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `age` tinyint UNSIGNED DEFAULT NULL,
  `gender` enum('male','female','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `date_of_birth` date DEFAULT NULL,
  `phone_number` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_photo` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `allergies` json DEFAULT NULL,
  `current_medications` json DEFAULT NULL,
  `emergency_contact_name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_relationship` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emergency_contact_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  KEY `idx_patient_phone` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `client_profiles`
--

INSERT INTO `client_profiles` (`user_id`, `full_name`, `age`, `gender`, `date_of_birth`, `phone_number`, `profile_photo`, `allergies`, `current_medications`, `emergency_contact_name`, `emergency_contact_relationship`, `emergency_contact_phone`, `created_at`, `updated_at`) VALUES
('0d36ee4a-51de-4966-b311-7d4dea7d7d03', '', NULL, 'female', '1995-05-15', '+1987654321', NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-30 02:24:03', '2026-04-30 03:20:29'),
('295ffac0-2ec5-4c84-8b89-62ab03ac3394', '', NULL, 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-23 04:40:13', '2026-05-23 04:40:13'),
('454c72f1-2b3c-4d9c-8cf5-06f6844b09ee', 'Jane Client', NULL, 'female', '1995-06-15', '+919876543211', NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-23 09:12:01', '2026-04-23 12:21:08'),
('6a59e094-4e19-4e49-aba5-45eaf648f0d2', 'Test Patient 4', NULL, 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-22 13:00:21', '2026-04-22 13:00:21'),
('6bcf8aff-5987-4c12-a978-384b012c356b', 'Jane Doe', 28, 'female', NULL, '+919876543211', NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-23 06:31:54', '2026-04-23 06:33:56'),
('9f9bf64c-4b3f-4116-96db-3267582d1400', 'James Doe', NULL, 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-22 09:03:33', '2026-04-22 09:03:33'),
('d5c530d0-70d8-4ddc-af80-8e1115117425', 'Jane Cilus', NULL, 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-23 09:24:38', '2026-04-23 09:24:38'),
('dee52f5d-0cf6-4c68-b404-c94d5fcd6df4', 'Jane Doe', NULL, 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-22 07:51:27', '2026-04-22 07:51:27');

-- --------------------------------------------------------

--
-- Table structure for table `consultation_sessions`
--

DROP TABLE IF EXISTS `consultation_sessions`;
CREATE TABLE IF NOT EXISTS `consultation_sessions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `appointment_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `duration_minutes` smallint DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `prescriptions` json DEFAULT NULL,
  `follow_up_required` tinyint(1) NOT NULL DEFAULT '0',
  `next_follow_up_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_session_appointment` (`appointment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `doctor_documents`
--

DROP TABLE IF EXISTS `doctor_documents`;
CREATE TABLE IF NOT EXISTS `doctor_documents` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_type` enum('govt_id_front','govt_id_back','qualification_certificate','rci_certificate','experience_proof') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Type of document being uploaded',
  `file_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Secure URL to uploaded file',
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Original filename',
  `file_size` int NOT NULL COMMENT 'File size in bytes',
  `mime_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'MIME type of file',
  `verification_status` enum('pending','verified','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT 'Admin verification status',
  `rejection_reason` text COLLATE utf8mb4_unicode_ci COMMENT 'Reason for rejection if applicable',
  `uploaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `verified_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_doc_doctor` (`doctor_id`),
  KEY `idx_doc_type` (`document_type`),
  KEY `idx_doc_verification` (`verification_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `doctor_experiences`
--

DROP TABLE IF EXISTS `doctor_experiences`;
CREATE TABLE IF NOT EXISTS `doctor_experiences` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `organization` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `verification_status` enum('pending','verified','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT 'Verification status by admin',
  `work_type` enum('hospital','private_practice','ngo','online_platform','other') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'hospital',
  `custom_work_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `years_of_experience` int DEFAULT '0',
  `experience_proof` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_exp_doctor` (`doctor_id`),
  KEY `idx_experiences_verification` (`verification_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `doctor_experiences`
--

INSERT INTO `doctor_experiences` (`id`, `doctor_id`, `organization`, `role`, `start_date`, `end_date`, `created_at`, `updated_at`, `verification_status`, `work_type`, `custom_work_type`, `years_of_experience`, `experience_proof`) VALUES
('9e3a1faf-5662-11f1-accb-60e9aa1f2004', '844c35cd-2a2b-47c1-959d-2dd77280eb64', 'City Mental Health Clinic', 'Senior Clinical Psychologist', '2018-01-15', NULL, '2026-05-23 04:48:18', '2026-05-26 06:37:20', 'pending', 'hospital', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `doctor_payout_accounts`
--

DROP TABLE IF EXISTS `doctor_payout_accounts`;
CREATE TABLE IF NOT EXISTS `doctor_payout_accounts` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_holder_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ifsc_code` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bank_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pan_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_gst_registered` tinyint(1) DEFAULT '0',
  `gst_number` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `terms_consent` tinyint(1) NOT NULL DEFAULT '0',
  `verification_status` enum('pending','verified','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `is_primary` tinyint(1) DEFAULT '1' COMMENT 'Primary payout account',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payout_account` (`doctor_id`,`account_number`),
  KEY `idx_payout_doctor` (`doctor_id`),
  KEY `idx_payout_primary` (`doctor_id`,`is_primary`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `doctor_profiles`
--

DROP TABLE IF EXISTS `doctor_profiles`;
CREATE TABLE IF NOT EXISTS `doctor_profiles` (
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `gender` enum('male','female','other','prefer_not_to_say') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'other',
  `date_of_birth` date DEFAULT NULL,
  `phone_number` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_photo` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `primary_specialty` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `primary_title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `secondary_title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sub_specializations` json DEFAULT NULL,
  `therapy_approaches` json DEFAULT NULL,
  `professional_bio` text COLLATE utf8mb4_unicode_ci,
  `govt_id_front_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `govt_id_back_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registration_type` enum('rci','none') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'none',
  `rci_crr_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rci_certificate_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `self_declaration_accepted` tinyint(1) NOT NULL DEFAULT '0',
  `license_number` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `medical_council` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `languages_spoken` json NOT NULL,
  `video_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `video_rate` decimal(10,2) DEFAULT NULL,
  `audio_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `audio_rate` decimal(10,2) DEFAULT NULL,
  `follow_up_rate` decimal(10,2) DEFAULT NULL,
  `session_fee_tier` enum('799','999','1499','1999','2499') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pricing_justification` text COLLATE utf8mb4_unicode_ci,
  `consultation_duration` enum('30min','45min','60min') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '60min',
  `buffer_time` enum('5min','10min','15min','30min') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '10min',
  `instant_booking_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `street_address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postal_code` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_profile_approved` tinyint(1) DEFAULT '0',
  `trust_badge_earned` tinyint(1) NOT NULL DEFAULT '0',
  `submitted_at` datetime DEFAULT NULL,
  `onboarding_current_step` tinyint NOT NULL DEFAULT '1',
  `onboarding_completed_steps` json DEFAULT NULL,
  `onboarding_percentage` tinyint NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  `profile_photo_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `verification_status` enum('pending','approved','rejected','action_required') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `consultation_duration_minutes` int DEFAULT '60' COMMENT 'Standard consultation duration',
  `specializations` json DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_doctor_license` (`license_number`),
  KEY `idx_doctor_specialty` (`primary_specialty`),
  KEY `idx_doctor_verified` (`is_verified`),
  KEY `idx_doctor_city` (`city`),
  KEY `idx_doctor_verification_status` (`verification_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `doctor_profiles`
--

INSERT INTO `doctor_profiles` (`user_id`, `full_name`, `gender`, `date_of_birth`, `phone_number`, `profile_photo`, `primary_specialty`, `primary_title`, `secondary_title`, `sub_specializations`, `therapy_approaches`, `professional_bio`, `govt_id_front_url`, `govt_id_back_url`, `registration_type`, `rci_crr_number`, `rci_certificate_url`, `self_declaration_accepted`, `license_number`, `medical_council`, `languages_spoken`, `video_enabled`, `video_rate`, `audio_enabled`, `audio_rate`, `follow_up_rate`, `session_fee_tier`, `pricing_justification`, `consultation_duration`, `buffer_time`, `instant_booking_enabled`, `street_address`, `city`, `state`, `country`, `postal_code`, `latitude`, `longitude`, `is_verified`, `is_profile_approved`, `trust_badge_earned`, `submitted_at`, `onboarding_current_step`, `onboarding_completed_steps`, `onboarding_percentage`, `created_at`, `updated_at`, `is_active`, `profile_photo_url`, `verification_status`, `consultation_duration_minutes`, `specializations`) VALUES
('60ae70cf-f6d9-4553-b9a9-cf937cad650a', '', 'other', NULL, NULL, NULL, 'General Practice', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'none', NULL, NULL, 0, 'TEMP_60ae70cf', 'Other', '[\"English\"]', 1, NULL, 1, NULL, NULL, NULL, NULL, '60min', '10min', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 1, NULL, 0, '2026-05-22 23:03:38', '2026-05-22 23:03:38', 1, NULL, 'pending', 60, NULL),
('844c35cd-2a2b-47c1-959d-2dd77280eb64', '', 'other', NULL, NULL, NULL, 'General Practice', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'none', NULL, NULL, 0, 'TEMP_844c35cd', 'Other', '[\"English\"]', 1, NULL, 1, NULL, NULL, NULL, NULL, '60min', '10min', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 1, NULL, 0, '2026-05-22 23:11:24', '2026-05-22 23:11:24', 1, NULL, 'pending', 60, NULL),
('a7ae0ad5-ed30-4626-bb20-2fc932c82636', '', 'other', NULL, NULL, NULL, 'General Practice', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'none', NULL, NULL, 0, 'TEMP_a7ae0ad5', 'Other', '[\"English\"]', 1, NULL, 1, NULL, NULL, NULL, NULL, '60min', '10min', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 1, NULL, 0, '2026-05-22 23:09:56', '2026-05-22 23:09:56', 1, NULL, 'pending', 60, NULL),
('fade25ee-fe7d-4de9-b5a0-8358279c9046', '', 'other', NULL, NULL, NULL, 'General Practice', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'none', NULL, NULL, 0, 'TEMP_fade25ee', 'Other', '[\"English\"]', 1, NULL, 1, NULL, NULL, NULL, NULL, '60min', '10min', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 1, NULL, 0, '2026-05-23 00:07:00', '2026-05-23 00:07:00', 1, NULL, 'pending', 60, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `doctor_qualifications`
--

DROP TABLE IF EXISTS `doctor_qualifications`;
CREATE TABLE IF NOT EXISTS `doctor_qualifications` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `qualification_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `institution` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `specialization` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `passing_year` smallint DEFAULT NULL,
  `certificate_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `verification_status` enum('pending','verified','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `degree` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` smallint DEFAULT NULL,
  `document_path` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_qual_doctor` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `doctor_verification_logs`
--

DROP TABLE IF EXISTS `doctor_verification_logs`;
CREATE TABLE IF NOT EXISTS `doctor_verification_logs` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` enum('step_started','step_completed','step_submitted','profile_submitted_for_review','profile_approved','profile_rejected','resubmission_requested','document_verified','document_rejected') COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_number` int DEFAULT NULL COMMENT 'Which onboarding step this action relates to',
  `previous_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `details` json DEFAULT NULL COMMENT 'Additional details about the action',
  `admin_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Admin who performed the action',
  `admin_notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Notes from admin',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_log_doctor` (`doctor_id`),
  KEY `idx_log_action` (`action`),
  KEY `idx_log_created` (`created_at`),
  KEY `fk_log_admin` (`admin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `doctor_verification_logs`
--

INSERT INTO `doctor_verification_logs` (`id`, `doctor_id`, `action`, `step_number`, `previous_status`, `new_status`, `details`, `admin_id`, `admin_notes`, `created_at`) VALUES
('9e40562f-5662-11f1-accb-60e9aa1f2004', '844c35cd-2a2b-47c1-959d-2dd77280eb64', 'step_started', 5, NULL, NULL, NULL, NULL, NULL, '2026-05-23 10:18:18');

-- --------------------------------------------------------

--
-- Table structure for table `doctor_weekly_schedule`
--

DROP TABLE IF EXISTS `doctor_weekly_schedule`;
CREATE TABLE IF NOT EXISTS `doctor_weekly_schedule` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `day_of_week` tinyint NOT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT '0',
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `break_times` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_schedule_doctor_day` (`doctor_id`,`day_of_week`)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
CREATE TABLE IF NOT EXISTS `documents` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `document_type` enum('license','certificate','qualification','identity') COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `verification_status` enum('pending','verified','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `idx_doc_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
CREATE TABLE IF NOT EXISTS `messages` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `appointment_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sender_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_type` enum('text','image','document') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attachment_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_msg_appointment_time` (`appointment_id`,`created_at`),
  KEY `idx_msg_recipient` (`recipient_id`),
  KEY `fk_msg_sender` (`sender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('appointment_scheduled','appointment_reminder','consultation_completed','review_received','profile_updated','verification_update') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `related_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notif_user_read` (`user_id`,`is_read`),
  KEY `idx_notif_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(512) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `revoked` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_token` (`token`(255)),
  KEY `idx_rt_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `doctor_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `client_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `appointment_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rating` tinyint NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_review_patient_appointment` (`client_id`,`appointment_id`),
  KEY `idx_review_doctor` (`doctor_id`),
  KEY `fk_review_appointment` (`appointment_id`)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `user_type` enum('admin','doctor','client') COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_profile_completed` tinyint(1) DEFAULT '0',
  `is_email_verified` tinyint(1) NOT NULL DEFAULT '1',
  `email_verification_otp` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verification_expires` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `registration_step` int DEFAULT '0' COMMENT 'Current onboarding step (0=not started, 1-7=step number, 8=completed)',
  `submitted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_email` (`email`),
  KEY `idx_users_user_type` (`user_type`),
  KEY `idx_users_registration_step` (`registration_step`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `full_name`, `user_type`, `is_active`, `is_profile_completed`, `is_email_verified`, `email_verification_otp`, `email_verification_expires`, `created_at`, `updated_at`, `registration_step`, `submitted_at`) VALUES
('0d36ee4a-51de-4966-b311-7d4dea7d7d03', 'john@example.com', '$2y$12$s9C9ztjiI/fevICciyjSLuO68OI1A0ZFsw/a3fTLoltb0dupy5rle', 'John Doe', 'client', 1, 0, 1, NULL, NULL, '2026-04-30 02:24:03', '2026-05-20 00:29:36', 1, NULL),
('295ffac0-2ec5-4c84-8b89-62ab03ac3394', 'client1779511213@example.com', '$2y$12$aSlF9FHWQ9MaJP6ku61dyeD.4lAIJiCenbcs4PKl4VK1tTGxhnDbO', 'Client Test User', 'client', 1, 0, 1, NULL, NULL, '2026-05-23 04:40:13', '2026-05-23 04:40:13', 0, NULL),
('454c72f1-2b3c-4d9c-8cf5-06f6844b09ee', 'client@example.com', '$2y$12$upvA9P/nOD78.y09anis2.16mLF8paButWrSgbKMvslBgzbeE8sTW', 'Jane Client', 'client', 1, 0, 1, NULL, NULL, '2026-04-23 09:12:01', '2026-04-23 09:12:01', 0, NULL),
('60ae70cf-f6d9-4553-b9a9-cf937cad650a', 'doctor1779510817@example.com', '$2y$12$drKuorSvCtHBihg/c4gzLO0VoZpDQ6LOtVDuemw/BeOV/53BReN2K', 'Dr. Test User', 'doctor', 1, 0, 1, NULL, NULL, '2026-05-23 04:33:38', '2026-05-23 04:33:38', 0, NULL),
('6a59e094-4e19-4e49-aba5-45eaf648f0d2', 'test_patient4@example.com', '$2y$12$vI.MmoVOtmVsnUD0enkv7e7dDxfoCKx04Etp3HEQbZ1uzWR7VeTFS', 'Test Patient 4', 'client', 1, 0, 1, NULL, NULL, '2026-04-22 13:00:21', '2026-04-23 13:39:54', 0, NULL),
('6bcf8aff-5987-4c12-a978-384b012c356b', 'patient@example.com', '$2y$12$NKFOd.PcNh.9kfZkyoo5xujhWr0nZoYiWkBM.J9oH4zrV1D3oN2Mu', 'Jane Patient', 'client', 1, 0, 1, NULL, NULL, '2026-04-23 06:31:54', '2026-04-23 13:39:54', 0, NULL),
('844c35cd-2a2b-47c1-959d-2dd77280eb64', 'tester@eample.com', '$2y$12$DDoPAeJ6kC./Qf8xEe36UeCVePOq/FGE3uSHvYIUqV2N0FVfKtLVu', 'Dr. Test User', 'doctor', 1, 0, 1, NULL, NULL, '2026-05-23 04:41:24', '2026-05-23 04:41:24', 0, NULL),
('9f9bf64c-4b3f-4116-96db-3267582d1400', 'patient_test2@example.com', '$2y$12$UN6T4mZaiwNO9yM3xM9zdOQ/pruAlYJQJijBqxL52TwTlp6ZIr/qC', 'James Doe', 'client', 1, 0, 1, NULL, NULL, '2026-04-22 09:03:33', '2026-04-23 13:39:54', 0, NULL),
('a7ae0ad5-ed30-4626-bb20-2fc932c82636', 'doctor1779511196@example.com', '$2y$12$bX7pn61o7j5AFj7hs8AuUuqgaz159U.rDdG5WGmEXLBkFQIPKjZwi', 'Dr. Test User', 'doctor', 1, 0, 1, NULL, NULL, '2026-05-23 04:39:56', '2026-05-23 04:39:56', 0, NULL),
('d5c530d0-70d8-4ddc-af80-8e1115117425', 'jane@example.com', '$2y$12$Yif6eN6n7S9NAlYzHO9o1uSezyixAtHalnnKmRG2jeqgs7PZbOG3i', 'Jane Cilus', 'client', 1, 0, 1, NULL, NULL, '2026-04-23 09:24:38', '2026-04-23 09:24:38', 0, NULL),
('dda3e89a-3eeb-11f1-bad6-60e9aa1f2004', 'admin@cosmictech.com', '$2y$12$Kk0G8lB7Yn5p5uY7p5uY7e5uY7p5uY7p5uY7p5uY7p5uY7p5uY7p5', 'Super Admin', 'admin', 1, 0, 1, NULL, NULL, '2026-04-23 08:10:18', '2026-04-23 08:10:18', 0, NULL),
('dee52f5d-0cf6-4c68-b404-c94d5fcd6df4', 'patient_test@example.com', '$2y$12$dxFxNIXEPgVyQa0ROwJwdOccVmJH3Pwu99vYHttL3K3/.QOmCgZeG', 'Jane Doe', 'client', 1, 0, 1, NULL, NULL, '2026-04-22 07:51:27', '2026-04-23 13:39:54', 0, NULL),
('fade25ee-fe7d-4de9-b5a0-8358279c9046', 'adam@eample.com', '$2y$12$ct1QqbZySNxAGMa4stpdEOBVqXfGXzMLYmAPxl3fY9ocAkS9AKfF2', 'Dr. Test User', 'doctor', 1, 0, 1, NULL, NULL, '2026-05-23 05:37:00', '2026-05-23 05:37:00', 0, NULL);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `fk_appt_client` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_appt_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `available_slots`
--
ALTER TABLE `available_slots`
  ADD CONSTRAINT `fk_slot_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `client_profiles`
--
ALTER TABLE `client_profiles`
  ADD CONSTRAINT `fk_patient_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `consultation_sessions`
--
ALTER TABLE `consultation_sessions`
  ADD CONSTRAINT `fk_session_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `doctor_documents`
--
ALTER TABLE `doctor_documents`
  ADD CONSTRAINT `fk_doc_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `doctor_experiences`
--
ALTER TABLE `doctor_experiences`
  ADD CONSTRAINT `fk_exp_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `doctor_payout_accounts`
--
ALTER TABLE `doctor_payout_accounts`
  ADD CONSTRAINT `fk_payout_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `doctor_profiles`
--
ALTER TABLE `doctor_profiles`
  ADD CONSTRAINT `fk_doctor_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `doctor_qualifications`
--
ALTER TABLE `doctor_qualifications`
  ADD CONSTRAINT `fk_qual_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `doctor_verification_logs`
--
ALTER TABLE `doctor_verification_logs`
  ADD CONSTRAINT `fk_log_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_log_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `doctor_weekly_schedule`
--
ALTER TABLE `doctor_weekly_schedule`
  ADD CONSTRAINT `fk_schedule_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `fk_doc_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `fk_msg_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_msg_recipient` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_msg_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `fk_rt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `fk_review_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_review_client` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_review_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctor_profiles` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
