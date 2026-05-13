-- Migration: Create/recreate doctor_qualifications with expanded schema
-- Run: php backend/run_migration.php OR import directly via phpMyAdmin

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS doctor_qualifications;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE doctor_qualifications (
  id            CHAR(36)      NOT NULL DEFAULT (UUID()),
  doctor_id     CHAR(36)      NOT NULL,
  title         VARCHAR(255)  NOT NULL,
  degree        VARCHAR(255)  NULL,
  institution   VARCHAR(255)  NULL,
  year          SMALLINT      NULL,
  document_path VARCHAR(1024) NULL,
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_qual_doctor (doctor_id),

  CONSTRAINT fk_qual_doctor
    FOREIGN KEY (doctor_id)
    REFERENCES doctor_profiles(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
