<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Domain\Enums\UserRole;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $role = $this->role instanceof UserRole
            ? $this->role
            : null;

        return [
            'id' => (string) $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'national_id' => $this->national_id,

            'employee_code' => $this->when(
                $role === UserRole::HealthWorker,
                $this->employee_code,
            ),

            'role' => $role?->value ?? $this->role,

            'patient_code' => $this->when(
                $role === UserRole::Patient,
                $this->patient_code,
            ),

            'is_active' => (bool) $this->is_active,
            'verification_status' => $this->accountVerificationDocument?->status ?? 'unsubmitted',
            'email_verified_at' => $this->email_verified_at?->toIso8601String(),
            'phone_verified_at' => $this->phone_verified_at?->toIso8601String(),

            'profile' => $this->whenLoaded(
                'patientProfile',
                fn () => $this->patientProfile
                    ? new PatientProfileResource($this->patientProfile)
                    : null,
            ),

            'guardians' => UserResource::collection(
                $this->whenLoaded('guardians'),
            ),

            'patients' => UserResource::collection(
                $this->whenLoaded('patients'),
            ),

            'hospitals' => $this->whenLoaded(
                'hospitals',
                fn () => $this->hospitals
                    ->map(fn ($hospital): array => [
                        'id' => (string) $hospital->id,
                        'name' => $hospital->name,
                        'address' => $hospital->address,
                        'phone' => $hospital->phone,
                        'is_active' => (bool) $hospital->is_active,
                        'status' => $hospital->status,

                        'staff_role' => $hospital->pivot?->role instanceof \BackedEnum
                            ? $hospital->pivot->role->value
                            : $hospital->pivot?->role,

                        'staff_is_active' => (bool) (
                            $hospital->pivot?->is_active ?? false
                        ),

                        'joined_at' => $hospital->pivot?->joined_at?->toIso8601String(),
                    ])
                    ->values()
                    ->all(),
            ),

            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'is_profile_completed' => (bool) $this->is_profile_completed,
        ];
    }
}