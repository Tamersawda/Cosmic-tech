UPDATE users u
SET is_profile_completed = TRUE,
    onboarding_step = 3
WHERE EXISTS (
  SELECT 1 FROM patients p WHERE p.userId = u.id
);
