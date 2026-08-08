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
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'national_id' => $this->national_id,
            'role' => $this->role->value,
            'patient_code' => $this->when($this->role === UserRole::Patient, $this->patient_code),
            'is_active' => $this->is_active,
            'email_verified_at' => $this->email_verified_at?->toIso8601String(),
            'phone_verified_at' => $this->phone_verified_at?->toIso8601String(),
            'profile' => new PatientProfileResource($this->whenLoaded('patientProfile')),
            'guardians' => UserResource::collection($this->whenLoaded('guardians')),
            'patients' => UserResource::collection($this->whenLoaded('patients')),
            'created_at' => $this->created_at->toIso8601String(),
            'updated_at' => $this->updated_at->toIso8601String(),
            'is_profile_completed' => (bool) $this->is_profile_completed,
        ];
    }
}
