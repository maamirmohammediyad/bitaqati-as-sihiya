<?php

declare(strict_types=1);

namespace App\Domain\Actions\Patient;

use App\Domain\Models\PatientProfile;
use App\Services\AuditLogService;
use Illuminate\Support\Facades\DB;

class CompleteProfileAction
{
    public function __construct(
        private readonly AuditLogService $auditLogService,
    ) {}

    public function execute(string $userId, array $data): PatientProfile
    {
        return DB::transaction(function () use ($userId, $data): PatientProfile {
            try {
                // بدّلنا firstOrFail إلى firstOrCreate
                $profile = PatientProfile::firstOrCreate(
                    ['user_id' => $userId],
                    ['is_profile_complete' => false],
                );

                $oldValues = $profile->toArray();

                $profile->fill($data);
                $profile->is_profile_complete = true;
                $profile->save();

                $this->auditLogService->logProfileUpdate(
                    $userId,
                    $oldValues,
                    $profile->toArray(),
                );

                return $profile->fresh();
            } catch (\Throwable $e) {
                \Log::error('CompleteProfileAction error: '.$e->getMessage(), [
                    'trace'   => $e->getTraceAsString(),
                    'user_id' => $userId,
                    'data'    => $data,
                ]);

                throw $e; // ما زلنا نرميه حتى يظهر كـ 500 لو فيه خطأ حقيقي آخر
            }
        });
    }
}