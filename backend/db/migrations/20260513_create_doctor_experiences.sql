-- Migration: Create doctor_experiences table
-- Run: import via phpMyAdmin or CLI

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS doctor_experiences;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE doctor_experiences (
  id               CHAR(36)      NOT NULL DEFAULT (UUID()),
  doctor_id        CHAR(36)      NOT NULL,
  company          VARCHAR(255)  NOT NULL,
  role_title       VARCHAR(255)  NOT NULL,
  employment_type  ENUM('full_time','part_time','contract','freelance','internship','other')
                   NOT NULL DEFAULT 'full_time',
  currently_working TINYINT(1)   NOT NULL DEFAULT 0,
  start_date       DATE          NOT NULL,
  end_date         DATE          NULL,
  description      TEXT          NULL,
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_exp_doctor (doctor_id),

  CONSTRAINT fk_exp_doctor
    FOREIGN KEY (doctor_id)
    REFERENCES doctor_profiles(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
