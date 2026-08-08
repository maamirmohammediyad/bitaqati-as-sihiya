<?php

declare(strict_types=1);

namespace App\Services;

use Illuminate\Support\Facades\Log;

class AuditLogService
{
    public function log(
        string $userId,
        string $action,
        string $entityType,
        string $entityId,
        ?array $oldValues = null,
        ?array $newValues = null,
        ?string $ipAddress = null,
        ?string $userAgent = null,
    ): void {
        try {
            \App\Domain\Models\AuditLog::create([
                'user_id' => $userId,
                'action' => $action,
                'entity_type' => $entityType,
                'entity_id' => $entityId,
                'old_values' => $oldValues,
                'new_values' => $newValues,
                'ip_address' => $ipAddress ?? request()->ip(),
                'user_agent' => $userAgent ?? request()->userAgent(),
            ]);
        } catch (\Throwable $e) {
            Log::error('Failed to write audit log: ' . $e->getMessage());
        }
    }

    public function logLogin(string $userId, ?string $ipAddress = null): void
    {
        $this->log(
            userId: $userId,
            action: 'login',
            entityType: 'user',
            entityId: $userId,
            ipAddress: $ipAddress,
        );
    }

    public function logLogout(string $userId): void
    {
        $this->log(
            userId: $userId,
            action: 'logout',
            entityType: 'user',
            entityId: $userId,
        );
    }

    public function logProfileUpdate(string $userId, array $oldValues, array $newValues): void
    {
        $this->log(
            userId: $userId,
            action: 'profile_updated',
            entityType: 'patient_profile',
            entityId: $userId,
            oldValues: $oldValues,
            newValues: $newValues,
        );
    }

    public function logSosTrigger(string $userId, string $eventId): void
    {
        $this->log(
            userId: $userId,
            action: 'sos_triggered',
            entityType: 'emergency_event',
            entityId: $eventId,
        );
    }
}
