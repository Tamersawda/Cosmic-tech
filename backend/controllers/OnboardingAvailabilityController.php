<?php

namespace Backend\Controllers;

use Backend\Models\DoctorWeeklySchedule;
use Backend\Models\Onboarding;
use Backend\Utils\Response;
use Backend\Utils\Validator;

require_once __DIR__ . '/../models/DoctorWeeklySchedule.php';
require_once __DIR__ . '/../models/Onboarding.php';
require_once __DIR__ . '/../utils/Response.php';
require_once __DIR__ . '/../utils/Validator.php';

/**
 * OnboardingAvailabilityController
 * Handles Step 7: Availability Setup
 *
 * POST /api/doctors/onboarding/availability
 *   Save / replace the full weekly availability schedule.
 *   Accepts an array of day schedules.
 *
 * GET  /api/doctors/onboarding/availability
 *   Retrieve current weekly schedule.
 *
 * PUT  /api/doctors/onboarding/availability/{id}
 *   Update a single day slot.
 *
 * DELETE /api/doctors/onboarding/availability/{id}
 *   Remove a single day slot.
 *
 * Payload schema (POST):
 * {
 *   "schedule": [
 *     {
 *       "dayOfWeek": 1,           // 0=Sun … 6=Sat (required)
 *       "isAvailable": true,      // required
 *       "startTime": "09:00",     // required when isAvailable=true
 *       "endTime": "17:00",       // required when isAvailable=true
 *       "breakTimes": [           // optional
 *         { "start": "13:00", "end": "14:00" }
 *       ]
 *     }
 *   ]
 * }
 */
class OnboardingAvailabilityController
{
    private DoctorWeeklySchedule $scheduleModel;
    private Onboarding $onboardingModel;
    private Validator $validator;

    public function __construct()
    {
        $this->scheduleModel  = new DoctorWeeklySchedule();
        $this->onboardingModel = new Onboarding();
        $this->validator       = new Validator();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST — Save / replace weekly availability
    // ─────────────────────────────────────────────────────────────────────────
    public function saveAvailability($user): void
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        if (empty($input['schedule']) || !is_array($input['schedule'])) {
            Response::error(
                'Validation failed', 400, 'VALIDATION_ERROR',
                ['schedule' => 'schedule array is required and must contain at least one day']
            );
            return;
        }

        $schedule = $input['schedule'];
        $errors   = [];

        foreach ($schedule as $idx => $day) {
            $key = "schedule[{$idx}]";

            if (!isset($day['dayOfWeek']) || !is_int($day['dayOfWeek']) ||
                $day['dayOfWeek'] < 0 || $day['dayOfWeek'] > 6) {
                $errors["{$key}.dayOfWeek"] = 'dayOfWeek must be an integer 0–6 (0=Sunday)';
            }

            if (!isset($day['isAvailable'])) {
                $errors["{$key}.isAvailable"] = 'isAvailable is required';
            }

            if (!empty($day['isAvailable'])) {
                if (empty($day['startTime'])) {
                    $errors["{$key}.startTime"] = 'startTime is required when isAvailable is true';
                }
                if (empty($day['endTime'])) {
                    $errors["{$key}.endTime"] = 'endTime is required when isAvailable is true';
                }

                // Validate time format and logic
                if (!empty($day['startTime']) && !empty($day['endTime'])) {
                    $start = strtotime("1970-01-01 {$day['startTime']}");
                    $end   = strtotime("1970-01-01 {$day['endTime']}");
                    if ($end <= $start) {
                        $errors["{$key}.endTime"] = 'endTime must be after startTime';
                    }
                }
            }
        }

        if (!empty($errors)) {
            Response::error('Validation failed', 400, 'VALIDATION_ERROR', $errors);
            return;
        }

        try {
            // Upsert each day
            $savedCount = 0;
            foreach ($schedule as $day) {
                $breakTimes = isset($day['breakTimes']) && is_array($day['breakTimes'])
                    ? $day['breakTimes']
                    : null;

                $this->scheduleModel->upsert($userId, [
                    'day_of_week'  => (int)$day['dayOfWeek'],
                    'is_available' => (int)(!empty($day['isAvailable'])),
                    'start_time'   => $day['startTime'] ?? null,
                    'end_time'     => $day['endTime']   ?? null,
                    'break_times'  => $breakTimes ? json_encode($breakTimes) : null,
                ]);

                $savedCount++;
            }

            // Update onboarding step tracker
            $this->onboardingModel->updateRegistrationStep($userId, 7);
            $this->onboardingModel->logVerificationAction($userId, 'step_completed', 7);

            Response::success([
                'message'    => 'Availability schedule saved successfully',
                'savedDays'  => $savedCount,
                'step'       => 7,
                'nextStep'   => 8,
            ], 200);

        } catch (\Exception $e) {
            Response::error('Failed to save availability: ' . $e->getMessage(), 500);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET — Retrieve weekly schedule
    // ─────────────────────────────────────────────────────────────────────────
    public function getAvailability($user): void
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $rows = $this->scheduleModel->findByDoctor($userId);

        // Return all 7 days — fill in missing days as unavailable
        $byDay = [];
        foreach ($rows as $row) {
            $byDay[(int)$row['day_of_week']] = $row;
        }

        $daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        $schedule   = [];

        for ($d = 0; $d <= 6; $d++) {
            if (isset($byDay[$d])) {
                $row = $byDay[$d];
                $schedule[] = [
                    'id'          => $row['id'],
                    'dayOfWeek'   => $d,
                    'dayName'     => $daysOfWeek[$d],
                    'isAvailable' => (bool)$row['is_available'],
                    'startTime'   => $row['start_time'],
                    'endTime'     => $row['end_time'],
                    'breakTimes'  => $row['break_times']
                        ? json_decode($row['break_times'], true)
                        : [],
                ];
            } else {
                $schedule[] = [
                    'id'          => null,
                    'dayOfWeek'   => $d,
                    'dayName'     => $daysOfWeek[$d],
                    'isAvailable' => false,
                    'startTime'   => null,
                    'endTime'     => null,
                    'breakTimes'  => [],
                ];
            }
        }

        Response::success(['schedule' => $schedule]);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PUT — Update a single day slot
    // ─────────────────────────────────────────────────────────────────────────
    public function updateSlot($user, string $id): void
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $input = $this->getJsonInput();

        // Verify ownership
        $slot = $this->scheduleModel->findById($id);
        if (!$slot || $slot['doctor_id'] !== $userId) {
            Response::error('Slot not found', 404);
            return;
        }

        try {
            $updateData = [];

            if (isset($input['isAvailable'])) {
                $updateData['is_available'] = (int)$input['isAvailable'];
            }
            if (isset($input['startTime'])) {
                $updateData['start_time'] = $input['startTime'];
            }
            if (isset($input['endTime'])) {
                $updateData['end_time'] = $input['endTime'];
            }
            if (isset($input['breakTimes'])) {
                $updateData['break_times'] = is_array($input['breakTimes'])
                    ? json_encode($input['breakTimes'])
                    : null;
            }

            if (!empty($updateData)) {
                $this->scheduleModel->update($id, $updateData);
            }

            Response::success(['message' => 'Slot updated successfully', 'id' => $id]);

        } catch (\Exception $e) {
            Response::error('Failed to update slot: ' . $e->getMessage(), 500);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DELETE — Remove a single day slot
    // ─────────────────────────────────────────────────────────────────────────
    public function deleteSlot($user, string $id): void
    {
        $userId = $this->extractUserId($user);
        if (!$userId) {
            Response::error('Unauthorized', 401, 'UNAUTHORIZED');
            return;
        }

        $slot = $this->scheduleModel->findById($id);
        if (!$slot || $slot['doctor_id'] !== $userId) {
            Response::error('Slot not found', 404);
            return;
        }

        try {
            $this->scheduleModel->delete($id);
            Response::success(['message' => 'Slot removed successfully', 'id' => $id]);
        } catch (\Exception $e) {
            Response::error('Failed to delete slot: ' . $e->getMessage(), 500);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────
    private function extractUserId($user): ?string
    {
        return is_array($user)
            ? ($user['id'] ?? $user['userId'] ?? null)
            : ($user->userId ?? $user->user_id ?? $user->id ?? null);
    }

    private function getJsonInput(): array
    {
        $input = json_decode(file_get_contents('php://input'), true);
        return is_array($input) ? $input : [];
    }
}
