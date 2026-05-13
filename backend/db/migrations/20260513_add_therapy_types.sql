-- Migration: Add therapy_types to doctor_profiles
-- Purpose: Allow doctors to specify if they do individual, couple, or other therapy.

ALTER TABLE doctor_profiles ADD COLUMN therapy_types JSON NULL AFTER sub_specializations;
