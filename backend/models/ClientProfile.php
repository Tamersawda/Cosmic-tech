<?php

namespace Backend\Models;

use Backend\Config\Database;
use PDO;

/**
 * ClientProfile Model
 * Manages the client_profiles table.
 */
class ClientProfile
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Get a client profile by user ID.
     */
    public function findByUserId(string $userId): ?array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM client_profiles
            WHERE user_id = ?
            LIMIT 1
        ');
        $stmt->execute([$userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Save profile data and advance onboarding state atomically.
     *
     * Strict execution order (per spec):
     *   1. BEGIN TRANSACTION
     *   2. Lock user row with SELECT … FOR UPDATE
     *   3. Re-validate incoming step against the locked DB value
     *   4. Confirm at least one valid profile field is present
     *   5. UPDATE client_profiles (profile data)
     *   6. Verify profile UPDATE succeeded (rowCount > 0 OR record exists)
     *   7. UPDATE users onboarding_step [+ is_profile_completed]
     *   8. COMMIT
     *   On any failure → ROLLBACK + throw
     *
     * @param string $userId
     * @param array  $fields        Raw request input (camelCase keys)
     * @param int    $incomingStep  Already range-checked by controller (1–3)
     * @param bool   $isCompleted   Explicit completion flag
     * @throws \RuntimeException   with a user-facing message on validation failure
     * @throws \Exception          on DB failure
     */
    public function saveStepAndState(string $userId, array $fields, int $incomingStep, bool $isCompleted): void
    {

        // ------------------------------------------------------------------
        // Field map: camelCase input → snake_case client_profiles column.
        // ------------------------------------------------------------------
        $allowedFields = [
            'name' => 'full_name',
            'gender' => 'gender',
            'dateOfBirth' => 'date_of_birth',
            'phoneNumber' => 'phone_number',
            'allergies' => 'allergies',
            'currentMedications' => 'current_medications',
        ];

        // ------------------------------------------------------------------
        // Build the profile SET clause.
        // Fix 4: No silent skip (controller already rejects empty values).
        // ------------------------------------------------------------------
        $setClause = [];
        $params = [];

        foreach ($fields as $key => $value) {
            if ($key === 'emergencyContact') {
                if (is_array($value)) {
                    if (isset($value['name'])) {
                        $setClause[] = 'emergency_contact_name = ?';
                        $params[] = $value['name'];
                    }
                    if (isset($value['relationship'])) {
                        $setClause[] = 'emergency_contact_relationship = ?';
                        $params[] = $value['relationship'];
                    }
                    // Fix 3 mapping: Use 'phoneNumber' as validated by controller
                    if (isset($value['phoneNumber'])) {
                        $setClause[] = 'emergency_contact_phone = ?';
                        $params[] = $value['phoneNumber'];
                    }
                }
            } elseif (isset($allowedFields[$key])) {
                $dbField = $allowedFields[$key];
                $setClause[] = "{$dbField} = ?";
                $params[] = is_array($value) ? json_encode($value) : $value;
            }
        }

        // ------------------------------------------------------------------
        // Fix 7 & 8: Single transaction flow using same PDO instance ($this->db).
        // ------------------------------------------------------------------
        $this->db->beginTransaction();

        try {
            // --------------------------------------------------------------
            // STEP 2: Row-level lock.
            // --------------------------------------------------------------
            $lockStmt = $this->db->prepare(
                'SELECT onboarding_step, is_profile_completed FROM users WHERE id = ? FOR UPDATE'
            );
            $lockStmt->execute([$userId]);
            $lockedRow = $lockStmt->fetch(PDO::FETCH_ASSOC);

            if (!$lockedRow) {
                throw new \RuntimeException('User not found');
            }

            $lockedStep = (int) $lockedRow['onboarding_step'];
            $lockedCompleted = (bool) $lockedRow['is_profile_completed'];

            if ($lockedCompleted) {
                throw new \RuntimeException('Profile already completed');
            }

            // --------------------------------------------------------------
            // STEP 3: Re-validate step (Fix 9 & 10).
            // --------------------------------------------------------------
            if ($incomingStep !== $lockedStep && $incomingStep !== $lockedStep + 1) {
                throw new \RuntimeException('Invalid onboarding step sequence');
            }

            // --------------------------------------------------------------
            // STEP 4: Require valid profile fields.
            // --------------------------------------------------------------
            if (empty($setClause)) {
                if ($incomingStep === $lockedStep + 1) {
                    throw new \RuntimeException('Cannot advance step without required data');
                }
                throw new \RuntimeException('No valid data provided for this step');
            }

            // --------------------------------------------------------------
            // STEP 5: UPDATE client_profiles.
            // --------------------------------------------------------------
            $setClause[] = 'updated_at = UTC_TIMESTAMP()';
            $params[] = $userId;

            $sql = 'UPDATE client_profiles SET ' . implode(', ', $setClause) . ' WHERE user_id = ?';
            $profStmt = $this->db->prepare($sql);
            $profStmt->execute($params);

            // --------------------------------------------------------------
            // STEP 6: Verify profile update success (Fix 1).
            // --------------------------------------------------------------
            if ($profStmt->rowCount() === 0) {
                // If rowCount is 0, verify record exists (could be a no-op update).
                $chkStmt = $this->db->prepare('SELECT id FROM client_profiles WHERE user_id = ?');
                $chkStmt->execute([$userId]);
                if (!$chkStmt->fetch()) {
                    throw new \RuntimeException('Profile record does not exist');
                }
                // Record exists → treat as successful no-op.
            }

            // --------------------------------------------------------------
            // STEP 7: Update onboarding state (Fix 6).
            // --------------------------------------------------------------
            $stateStmt = $this->db->prepare(
                'UPDATE users SET onboarding_step = ?, is_profile_completed = ? WHERE id = ?'
            );
            $stateStmt->execute([$incomingStep, $isCompleted ? 1 : 0, $userId]);

            // --------------------------------------------------------------
            // STEP 8: Commit.
            // --------------------------------------------------------------
            $this->db->commit();

        } catch (\Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }

    /**
     * Get a client's appointments, optionally filtered by status.
     * Joins users for doctor name and doctor_profiles for specialty.
     */
    public function getAppointments(string $clientId, ?string $status = null): array
    {
        $query = '
            SELECT
                a.id,
                a.doctor_id,
                a.client_id,
                a.scheduled_date,
                a.scheduled_time,
                a.end_time,
                a.consultation_type,
                a.status,
                u.full_name       AS doctor_name,
                d.primary_specialty
            FROM appointments a
            JOIN doctor_profiles d ON a.doctor_id = d.user_id
            JOIN users u ON d.user_id = u.id
            WHERE a.client_id = ?
        ';

        $params = [$clientId];

        if ($status !== null) {
            $query .= ' AND a.status = ?';
            $params[] = $status;
        }

        $query .= ' ORDER BY a.scheduled_date ASC, a.scheduled_time ASC';

        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Check whether a client profile exists for the given user ID.
     */
    public function exists(string $clientId): bool
    {
        $stmt = $this->db->prepare('
            SELECT 1 FROM client_profiles WHERE user_id = ? LIMIT 1
        ');
        $stmt->execute([$clientId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) !== false;
    }
}
