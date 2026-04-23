<?php

namespace Backend\Controllers;

use Backend\Models\Message;
use Backend\Utils\Response;
use Backend\Middleware\AuthMiddleware;

class MessageController {
    private Message $messageModel;

    public function __construct() {
        $this->messageModel = new Message();
    }

    /**
     * Send a message
     * POST /api/appointments/{id}/messages
     */
    public function send(object $payload, string $appointmentId): void {
        AuthMiddleware::requireRoles($payload, ['doctor', 'client']);

        $userId = $payload->userId ?? $payload->user_id;
        $input = $this->getInputData();

        // Validate input
        if (empty($input['content'])) {
            Response::error('Message content is required', 400);
            return;
        }

        $content = trim($input['content']);
        $messageType = $input['messageType'] ?? 'text';

        // Validate message type (MVP: text only)
        if ($messageType !== 'text') {
            Response::error('Only text messages are supported', 400);
            return;
        }

        // Validate content length
        if (strlen($content) > 5000) {
            Response::error('Message content exceeds maximum length (5000 characters)', 400);
            return;
        }

        try {
            $messageId = $this->messageModel->sendMessage(
                $appointmentId,
                $userId,
                $content,
                $messageType
            );

            Response::success([
                'messageId' => $messageId,
                'timestamp' => date('c'),
                'message' => 'Message sent successfully'
            ], 201);

        } catch (\Exception $e) {
            $message = $e->getMessage();

            if ($message === 'Appointment not found') {
                Response::error('Appointment not found', 404);
            } else if ($message === 'Unauthorized') {
                Response::error('You do not belong to this appointment', 403);
            } else if ($message === 'Cannot send messages for this appointment') {
                Response::error('Messages can only be sent during scheduled or in-progress appointments', 400);
            } else {
                error_log("Send message error: " . $message);
                Response::error('Failed to send message', 500);
            }
        }
    }

    /**
     * Get appointment messages
     * GET /api/appointments/{id}/messages
     */
    public function getAppointmentMessages(object $payload, string $appointmentId): void {
        AuthMiddleware::requireRoles($payload, ['doctor', 'client']);

        $userId = $payload->userId ?? $payload->user_id;
        $page = (int)($_GET['page'] ?? 1);
        $limit = (int)($_GET['limit'] ?? 50);

        // Validate pagination parameters
        if ($page < 1) {
            $page = 1;
        }
        if ($limit < 1 || $limit > 100) {
            $limit = 50;
        }

        try {
            $messages = $this->messageModel->getMessages(
                $appointmentId,
                $userId,
                $page,
                $limit
            );

            Response::success([
                'messages' => $messages,
                'count' => count($messages),
                'page' => $page,
                'limit' => $limit
            ], 200);

        } catch (\Exception $e) {
            $message = $e->getMessage();

            if ($message === 'Appointment not found') {
                Response::error('Appointment not found', 404);
            } else if ($message === 'Unauthorized') {
                Response::error('You do not belong to this appointment', 403);
            } else {
                error_log("Get messages error: " . $message);
                Response::error('Failed to fetch messages', 500);
            }
        }
    }

    /**
     * New message sending (standalone, not appointment-specific)
     * POST /api/messages
     */
    public function sendMessage(object $payload): void {
        AuthMiddleware::requireRoles($payload, ['doctor', 'client']);

        $userId = $payload->userId ?? $payload->user_id;
        $input = $this->getInputData();

        // Validate input
        if (empty($input['message_body']) && empty($input['content'])) {
            Response::error('Message content is required', 400);
            return;
        }

        $content = trim($input['message_body'] ?? $input['content'] ?? '');
        $recipientId = $input['recipient_id'] ?? null;

        if (empty($recipientId)) {
            Response::error('Recipient ID is required', 400);
            return;
        }

        try {
            $messageId = $this->messageModel->create([
                'sender_id' => $userId,
                'recipient_id' => $recipientId,
                'content' => $content,
                'message_type' => $input['message_type'] ?? 'text',
                'subject' => $input['subject'] ?? null
            ]);

            Response::success(['id' => $messageId], 201);

        } catch (\Exception $e) {
            error_log("Send message error: " . $e->getMessage());
            Response::error('Failed to send message', 500);
        }
    }

    /**
     * Get inbox messages
     * GET /api/messages/inbox
     */
    public function getInbox(object $payload): void {
        try {
            $messages = $this->messageModel->getInbox($payload->userId ?? $payload->user_id);
            Response::success(['messages' => $messages, 'count' => count($messages)], 200);

        } catch (\Exception $e) {
            error_log("Get inbox error: " . $e->getMessage());
            Response::error('Failed to fetch inbox', 500);
        }
    }

    /**
     * Get sent messages
     * GET /api/messages/sent
     */
    public function getSent(object $payload): void {
        try {
            $messages = $this->messageModel->getSent($payload->userId ?? $payload->user_id);
            Response::success(['messages' => $messages, 'count' => count($messages)], 200);

        } catch (\Exception $e) {
            error_log("Get sent error: " . $e->getMessage());
            Response::error('Failed to fetch sent messages', 500);
        }
    }

    /**
     * Get single message by ID
     * GET /api/messages/{id}
     */
    public function get(object $payload, string $messageId): void {
        try {
            $message = $this->messageModel->getById($messageId);

            if (!$message) {
                Response::error('Message not found', 404);
                return;
            }

            Response::success(['message' => $message], 200);

        } catch (\Exception $e) {
            error_log("Get message error: " . $e->getMessage());
            Response::error('Failed to fetch message', 500);
        }
    }

    /**
     * Update message (mark as read)
     * PUT /api/messages/{id}
     */
    public function update(object $payload, string $messageId): void {
        $input = $this->getInputData();

        try {
            $this->messageModel->update($messageId, $input);
            Response::success(['id' => $messageId], 200);

        } catch (\Exception $e) {
            error_log("Update message error: " . $e->getMessage());
            Response::error('Failed to update message', 500);
        }
    }

    /**
     * Delete message
     * DELETE /api/messages/{id}
     */
    public function delete(object $payload, string $messageId): void {
        try {
            $this->messageModel->delete($messageId);
            Response::success(['id' => $messageId], 200);

        } catch (\Exception $e) {
            error_log("Delete message error: " . $e->getMessage());
            Response::error('Failed to delete message', 500);
        }
    }

    /**
     * Parse input data from request
     */
    private function getInputData(): array {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true) ?? [];
        return array_merge($_GET, $_POST, $data);
    }
}
